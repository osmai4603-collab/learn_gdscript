import 'dart:convert';
import 'dart:io';

import '../../core/constants/gdscript_constants.dart';
import '../sqlite/database_helper.dart';

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

class WorkspaceRepository {
  WorkspaceRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

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
      throw ArgumentError.value(content, 'content', 'File exceeds the size limit.');
    }
    final parsedUri = Uri.parse(uri);
    if (parsedUri.scheme != 'file' ||
        !parsedUri.path.endsWith(GDScriptConstants.fileExtension)) {
      throw ArgumentError.value(uri, 'uri', 'Only GDScript files can be saved.');
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
