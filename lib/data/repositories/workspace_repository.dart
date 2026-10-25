import 'dart:convert';
import 'dart:io';

import '../../core/constants/gdscript_constants.dart';
import '../sqlite/database_helper.dart';

const _excludedWorkspaceDirectories = {
  '.git',
  '.godot',
  '.dart_tool',
  'build',
  'node_modules',
  'vendor',
  'target',
  'dist',
};

class WorkspaceFileSnapshot {
  const WorkspaceFileSnapshot({
    required this.uri,
    required this.relativePath,
    required this.content,
    required this.modifiedMillis,
  });

  final String uri;
  final String relativePath;
  final String content;
  final int modifiedMillis;
}

class WorkspaceSearchMatch {
  const WorkspaceSearchMatch({
    required this.relativePath,
    required this.line,
    required this.column,
    required this.preview,
  });

  final String relativePath;
  final int line;
  final int column;
  final String preview;
}

class WorkspaceRepository {
  WorkspaceRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<WorkspaceFileSnapshot>> discoverAndSetWorkspace(
    String rootPath,
  ) async {
    final requestedRoot = Directory(rootPath).absolute;
    if (!await requestedRoot.exists()) {
      throw FileSystemException(
        'Workspace directory does not exist.',
        rootPath,
      );
    }
    final resolvedRoot = await requestedRoot.resolveSymbolicLinks();
    final pending = <Directory>[Directory(resolvedRoot)];
    final files = <WorkspaceFileSnapshot>[];

    while (pending.isNotEmpty) {
      final directory = pending.removeLast();
      await for (final entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        final name = entity.path
            .split(Platform.pathSeparator)
            .where((segment) => segment.isNotEmpty)
            .last;
        if (name.startsWith('.')) continue;
        final type = await FileSystemEntity.type(
          entity.path,
          followLinks: false,
        );
        if (type == FileSystemEntityType.link) continue;
        if (type == FileSystemEntityType.directory) {
          if (!_excludedWorkspaceDirectories.contains(name)) {
            pending.add(Directory(entity.path));
          }
          continue;
        }
        if (type != FileSystemEntityType.file ||
            !entity.path.endsWith(GDScriptConstants.fileExtension)) {
          continue;
        }
        if (files.length >= GDScriptConstants.maximumWorkspaceFiles) {
          throw FileSystemException(
            'Workspace exceeds the '
            '${GDScriptConstants.maximumWorkspaceFiles}-file limit.',
            entity.path,
          );
        }

        final file = File(entity.path);
        final stat = await file.stat();
        if (stat.size > GDScriptConstants.maximumWorkspaceFileBytes) {
          throw FileSystemException(
            'GDScript file exceeds the '
            '${GDScriptConstants.maximumWorkspaceFileBytes}-byte limit.',
            entity.path,
          );
        }
        final content = utf8.decode(await file.readAsBytes());
        final relativePath = entity.path
            .substring(resolvedRoot.length)
            .replaceFirst(RegExp(r'^[/\\]'), '')
            .replaceAll(r'\', '/');
        final uri = file.absolute.uri;
        if (!uri.path.startsWith(Directory(resolvedRoot).uri.path)) {
          throw FileSystemException(
            'Workspace file resolves outside the workspace.',
            entity.path,
          );
        }
        files.add(
          WorkspaceFileSnapshot(
            uri: uri.toString(),
            relativePath: relativePath,
            content: content,
            modifiedMillis: stat.modified.millisecondsSinceEpoch,
          ),
        );
      }
    }

    files.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    await setWorkspace(resolvedRoot, files);
    return List.unmodifiable(files);
  }

  Future<String?> getRootPath() async {
    final db = await _databaseHelper.database;
    final rows = db.select(
      'SELECT root_path FROM workspace_state WHERE singleton_id = 1',
    );
    return rows.isEmpty ? null : rows.single['root_path'] as String;
  }

  Future<void> setRootPath(String rootPath) async {
    final db = await _databaseHelper.database;
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute(
        'INSERT INTO workspace_state (singleton_id, root_path) VALUES (1, ?) '
        'ON CONFLICT(singleton_id) DO UPDATE SET root_path = excluded.root_path',
        [rootPath],
      );
      db.execute('DELETE FROM workspace_files');
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> setWorkspace(
    String rootPath,
    List<WorkspaceFileSnapshot> files,
  ) async {
    final db = await _databaseHelper.database;
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute(
        'INSERT INTO workspace_state (singleton_id, root_path) VALUES (1, ?) '
        'ON CONFLICT(singleton_id) DO UPDATE SET root_path = excluded.root_path',
        [rootPath],
      );
      db.execute('DELETE FROM workspace_files');
      for (final file in files) {
        db.execute(
          '''
          INSERT INTO workspace_files
            (uri, relative_path, content, modified_millis)
          VALUES (?, ?, ?, ?)
          ''',
          [file.uri, file.relativePath, file.content, file.modifiedMillis],
        );
      }
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> removeWorkspace() async {
    final db = await _databaseHelper.database;
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute('DELETE FROM workspace_files');
      db.execute('DELETE FROM workspace_state');
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<List<WorkspaceFileSnapshot>> loadFiles() async {
    final db = await _databaseHelper.database;
    return [
      for (final row in db.select(
        'SELECT uri, relative_path, content, modified_millis '
        'FROM workspace_files ORDER BY relative_path',
      ))
        WorkspaceFileSnapshot(
          uri: row['uri'] as String,
          relativePath: row['relative_path'] as String,
          content: row['content'] as String,
          modifiedMillis: row['modified_millis'] as int,
        ),
    ];
  }

  Future<List<WorkspaceSearchMatch>> searchText(
    String query, {
    bool caseSensitive = false,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw ArgumentError.value(
        query,
        'query',
        'Search query cannot be empty.',
      );
    }
    final searchQuery = caseSensitive
        ? normalizedQuery
        : normalizedQuery.toLowerCase();
    final matches = <WorkspaceSearchMatch>[];
    for (final file in await loadFiles()) {
      final lines = file.content.split('\n');
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        final line = lines[lineIndex];
        final searchableLine = caseSensitive ? line : line.toLowerCase();
        var offset = 0;
        while (offset <= searchableLine.length - searchQuery.length) {
          final match = searchableLine.indexOf(searchQuery, offset);
          if (match < 0) break;
          matches.add(
            WorkspaceSearchMatch(
              relativePath: file.relativePath,
              line: lineIndex + 1,
              column: match + 1,
              preview: line,
            ),
          );
          offset = match + searchQuery.length;
        }
      }
    }
    return List.unmodifiable(matches);
  }

  Future<void> replaceFiles(List<WorkspaceFileSnapshot> files) async {
    final db = await _databaseHelper.database;
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute('DELETE FROM workspace_files');
      for (final file in files) {
        db.execute(
          '''
          INSERT INTO workspace_files
            (uri, relative_path, content, modified_millis)
          VALUES (?, ?, ?, ?)
          ''',
          [file.uri, file.relativePath, file.content, file.modifiedMillis],
        );
      }
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> saveGDScriptFile(String uri, String content) async {
    if (utf8.encode(content).length >
        GDScriptConstants.maximumWorkspaceFileBytes) {
      throw ArgumentError.value(
        content,
        'content',
        'File exceeds the size limit.',
      );
    }
    final parsedUri = Uri.parse(uri);
    if (parsedUri.scheme != 'file' ||
        !parsedUri.path.endsWith(GDScriptConstants.fileExtension)) {
      throw ArgumentError.value(
        uri,
        'uri',
        'Only GDScript files can be saved.',
      );
    }

    final rootPath = await getRootPath();
    if (rootPath == null) throw StateError('No workspace is selected.');
    final files = await loadFiles();
    final matchingFile = files.indexWhere((snapshot) => snapshot.uri == uri);
    if (matchingFile == -1) {
      throw StateError('File is not part of the indexed workspace.');
    }
    final root = Directory(rootPath);
    final resolvedRoot = await root.resolveSymbolicLinks();
    final file = File.fromUri(parsedUri).absolute;
    if (!file.path.startsWith('$resolvedRoot${Platform.pathSeparator}')) {
      throw ArgumentError.value(uri, 'uri', 'File is outside the workspace.');
    }
    if (await FileSystemEntity.type(file.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw ArgumentError.value(uri, 'uri', 'Symbolic links cannot be saved.');
    }
    final resolvedParent = await Directory(
      file.parent.path,
    ).resolveSymbolicLinks();
    if (resolvedParent != resolvedRoot &&
        !resolvedParent.startsWith('$resolvedRoot${Platform.pathSeparator}')) {
      throw ArgumentError.value(uri, 'uri', 'File is outside the workspace.');
    }
    if (!await file.exists()) {
      throw FileSystemException('Workspace file no longer exists.', file.path);
    }

    await file.writeAsString(content, flush: true);
    final stat = await file.stat();
    files[matchingFile] = WorkspaceFileSnapshot(
      uri: uri,
      relativePath: files[matchingFile].relativePath,
      content: content,
      modifiedMillis: stat.modified.millisecondsSinceEpoch,
    );
    await replaceFiles(files);
  }
}
