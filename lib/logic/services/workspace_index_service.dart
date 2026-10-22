import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/constants/gdscript_constants.dart';
import '../../data/repositories/workspace_repository.dart';
import 'language_server_client.dart';

const _excludedDirectoryNames = {
  '.git',
  '.godot',
  '.dart_tool',
  'build',
  'node_modules',
  'vendor',
  'target',
  'dist',
};

class WorkspaceFileIssue {
  const WorkspaceFileIssue(this.path, this.message);

  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

class WorkspaceIndexException implements Exception {
  WorkspaceIndexException(this.issues);

  final List<WorkspaceFileIssue> issues;

  @override
  String toString() =>
      'Workspace indexing failed:\n${issues.map((issue) => issue.toString()).join('\n')}';
}

class WorkspaceIndexRollbackException implements Exception {
  const WorkspaceIndexRollbackException(
    this.operationError,
    this.rollbackError,
  );

  final Object operationError;
  final Object rollbackError;

  @override
  String toString() =>
      'Workspace sync failed ($operationError), and restoring the previous '
      'server workspace also failed ($rollbackError).';
}

abstract interface class WorkspaceFileSystem {
  Future<List<WorkspaceFileSnapshot>> discover(String rootPath);
}

class IoWorkspaceFileSystem implements WorkspaceFileSystem {
  const IoWorkspaceFileSystem({
    this.maximumFileCount = GDScriptConstants.maximumWorkspaceFiles,
    this.maximumFileBytes = GDScriptConstants.maximumWorkspaceFileBytes,
  });

  final int maximumFileCount;
  final int maximumFileBytes;

  @override
  Future<List<WorkspaceFileSnapshot>> discover(String rootPath) async {
    final root = Directory(rootPath).absolute;
    if (!await root.exists()) {
      throw FileSystemException(
        'Workspace directory does not exist.',
        rootPath,
      );
    }
    final resolvedRoot = await root.resolveSymbolicLinks();
    final files = <WorkspaceFileSnapshot>[];
    final issues = <WorkspaceFileIssue>[];
    final pendingDirectories = <Directory>[Directory(resolvedRoot)];

    while (pendingDirectories.isNotEmpty) {
      final directory = pendingDirectories.removeLast();
      try {
        await for (final entity in directory.list(
          recursive: false,
          followLinks: false,
        )) {
          final name = _basename(entity.path);
          if (name.startsWith('.')) continue;
          final type = await FileSystemEntity.type(
            entity.path,
            followLinks: false,
          );
          if (type == FileSystemEntityType.link) continue;
          if (type == FileSystemEntityType.directory) {
            if (!_excludedDirectoryNames.contains(name)) {
              pendingDirectories.add(Directory(entity.path));
            }
            continue;
          }
          if (type != FileSystemEntityType.file ||
              !entity.path.endsWith(GDScriptConstants.fileExtension)) {
            continue;
          }
          if (files.length >= maximumFileCount) {
            issues.add(
              WorkspaceFileIssue(
                entity.path,
                'Workspace exceeds the $maximumFileCount-file server limit.',
              ),
            );
            continue;
          }
          try {
            final file = File(entity.path);
            final stat = await file.stat();
            if (stat.size > maximumFileBytes) {
              issues.add(
                WorkspaceFileIssue(
                  entity.path,
                  'File exceeds the $maximumFileBytes-byte server limit.',
                ),
              );
              continue;
            }
            final contents = await file.readAsBytes();
            if (contents.length > maximumFileBytes) {
              issues.add(
                WorkspaceFileIssue(
                  entity.path,
                  'File exceeds the $maximumFileBytes-byte server limit.',
                ),
              );
              continue;
            }
            final text = utf8.decode(contents);
            final relative = entity.path
                .substring(resolvedRoot.length)
                .replaceFirst(RegExp(r'^[/\\]'), '')
                .replaceAll(r'\', '/');
            final uri = File(entity.path).absolute.uri;
            if (!uri.path.startsWith(Directory(resolvedRoot).uri.path)) {
              issues.add(
                WorkspaceFileIssue(
                  entity.path,
                  'File resolves outside the workspace.',
                ),
              );
              continue;
            }
            files.add(
              WorkspaceFileSnapshot(
                uri: uri.toString(),
                relativePath: relative,
                content: text,
                modifiedMillis: stat.modified.millisecondsSinceEpoch,
              ),
            );
          } on FileSystemException catch (error) {
            issues.add(WorkspaceFileIssue(entity.path, error.message));
          } on FormatException catch (error) {
            issues.add(WorkspaceFileIssue(entity.path, error.message));
          }
        }
      } on FileSystemException catch (error) {
        issues.add(WorkspaceFileIssue(directory.path, error.message));
      }
    }

    if (issues.isNotEmpty) throw WorkspaceIndexException(issues);
    files.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return files;
  }

  static String _basename(String path) {
    return path.split(Platform.pathSeparator).last;
  }
}

class WorkspaceIndexService {
  WorkspaceIndexService({
    required this._repository,
    required this._client,
    this._fileSystem = const IoWorkspaceFileSystem(),
  });

  static const _batchBytesLimit = 2 * 1024 * 1024;
  static const _batchFilesLimit = 32;
  static const _batchRemovedUrisLimit = 256;

  final WorkspaceRepository _repository;
  final LanguageServerClient _client;
  final WorkspaceFileSystem _fileSystem;
  final Map<String, WorkspaceFileSnapshot> _openDocuments = {};
  final Map<String, int> _openVersions = {};
  final StreamController<Object> _watchErrors =
      StreamController<Object>.broadcast();
  final Map<String, StreamSubscription<FileSystemEvent>> _watchSubscriptions =
      {};
  Timer? _refreshTimer;
  Future<void> _queuedRefresh = Future<void>.value();
  bool _disposed = false;

  Stream<Object> get watchErrors => _watchErrors.stream;

  Future<void> selectWorkspace(String rootPath) async {
    _ensureActive();
    if (_openDocuments.isNotEmpty) {
      throw StateError('Close open documents before changing workspace.');
    }
    final normalizedRoot = await Directory(rootPath).resolveSymbolicLinks();
    final next = await _fileSystem.discover(normalizedRoot);
    final previousRoot = await _repository.getRootPath();
    final previous = await _repository.loadFiles();
    final nextUris = next.map((file) => file.uri).toSet();
    final newRoot = Directory(normalizedRoot).uri;
    final oldRoot = previousRoot == null ? null : Directory(previousRoot).uri;
    final changedRoot = previousRoot != normalizedRoot;
    if (changedRoot) {
      await _client.changeWorkspaceFolders(
        added: [newRoot],
        removed: oldRoot == null ? const [] : [oldRoot],
      );
    }
    try {
      await _sendUpdates(
        upserts: next,
        removals: previous
            .map((file) => file.uri)
            .where((uri) => !nextUris.contains(uri))
            .toList(growable: false),
      );
    } on Object catch (operationError, operationStack) {
      if (changedRoot) {
        try {
          await _client.changeWorkspaceFolders(
            added: oldRoot == null ? const [] : [oldRoot],
            removed: [newRoot],
          );
          if (oldRoot != null) {
            await _sendUpdates(upserts: previous, removals: const []);
          }
        } on Object catch (rollbackError) {
          throw WorkspaceIndexRollbackException(operationError, rollbackError);
        }
      }
      Error.throwWithStackTrace(operationError, operationStack);
    }
    await _repository.setWorkspace(normalizedRoot, next);
    await _startWatching(normalizedRoot);
  }

  Future<void> removeWorkspace() async {
    _ensureActive();
    final root = await _repository.getRootPath();
    if (root == null) return;
    final rootUri = Directory(root).uri;
    await _stopWatching();
    final previous = await _repository.loadFiles();
    try {
      await _client.changeWorkspaceFolders(added: const [], removed: [rootUri]);
      await _repository.removeWorkspace();
    } on Object catch (operationError, operationStack) {
      try {
        await _client.changeWorkspaceFolders(
          added: [rootUri],
          removed: const [],
        );
        await _sendUpdates(upserts: previous, removals: const []);
      } on Object catch (rollbackError) {
        throw WorkspaceIndexRollbackException(operationError, rollbackError);
      }
      await _startWatching(root);
      Error.throwWithStackTrace(operationError, operationStack);
    }
    _openDocuments.clear();
    _openVersions.clear();
  }

  Future<void> synchronizeWorkspace() async {
    _ensureActive();
    final root = await _repository.getRootPath();
    if (root == null) throw StateError('No workspace has been selected.');
    final discovered = await _fileSystem.discover(root);
    final previous = await _repository.loadFiles();
    final nextByUri = _snapshotByUri(discovered);

    await _client.changeWorkspaceFolders(
      added: [Directory(root).uri],
      removed: const [],
    );
    await _sendUpdates(
      upserts: nextByUri.values.toList(growable: false),
      removals: previous
          .map((file) => file.uri)
          .where((uri) => !nextByUri.containsKey(uri))
          .toList(growable: false),
    );
    await _repository.replaceFiles(nextByUri.values.toList(growable: false));
    await _syncWatchers(root);
  }

  Map<String, WorkspaceFileSnapshot> _snapshotByUri(
    List<WorkspaceFileSnapshot> discovered,
  ) {
    final snapshots = <String, WorkspaceFileSnapshot>{};
    for (final file in discovered) {
      final text = _openDocuments[file.uri]?.content ?? file.content;
      snapshots[file.uri] = WorkspaceFileSnapshot(
        uri: file.uri,
        relativePath: file.relativePath,
        content: text,
        modifiedMillis: file.modifiedMillis,
      );
    }
    for (final openFile in _openDocuments.values) {
      snapshots.putIfAbsent(openFile.uri, () => openFile);
    }
    return snapshots;
  }

  Future<void> refresh() async {
    _ensureActive();
    final root = await _repository.getRootPath();
    if (root == null) throw StateError('No workspace has been selected.');
    final discovered = await _fileSystem.discover(root);
    final previous = await _repository.loadFiles();
    final previousByUri = {for (final file in previous) file.uri: file};
    final nextByUri = _snapshotByUri(discovered);
    final updates = <WorkspaceFileSnapshot>[];
    for (final next in nextByUri.values) {
      final old = previousByUri[next.uri];
      if (old == null || old.content != next.content) updates.add(next);
    }
    final removed = previousByUri.keys
        .where((uri) => !nextByUri.containsKey(uri))
        .toList(growable: false);
    if (updates.isNotEmpty || removed.isNotEmpty) {
      await _sendUpdates(upserts: updates, removals: removed);
    }
    await _repository.replaceFiles(nextByUri.values.toList(growable: false));
    await _syncWatchers(root);
  }

  Future<void> openDocument(Uri uri, String text, {int version = 1}) async {
    _ensureActive();
    if (version < 1) throw ArgumentError.value(version, 'version');
    final snapshot = await _snapshotForOpenDocument(uri, text);
    await _client.openDocument(uri, text, version: version);
    _openDocuments[uri.toString()] = snapshot;
    _openVersions[uri.toString()] = version;
  }

  Future<void> changeDocument(
    Uri uri,
    String text, {
    required int version,
  }) async {
    _ensureActive();
    if (!_openDocuments.containsKey(uri.toString())) {
      throw StateError('Cannot change a document that is not open.');
    }
    final previousVersion = _openVersions[uri.toString()]!;
    if (version <= previousVersion) {
      throw ArgumentError.value(
        version,
        'version',
        'Must increase per change.',
      );
    }
    await _client.changeDocument(uri, text, version: version);
    _openDocuments[uri.toString()] = await _snapshotForOpenDocument(uri, text);
    _openVersions[uri.toString()] = version;
  }

  Future<void> saveDocument(Uri uri, {required String text}) async {
    _ensureActive();
    if (!_openDocuments.containsKey(uri.toString())) {
      throw StateError('Cannot save a document that is not open.');
    }
    final key = uri.toString();
    if (_openDocuments[key]!.content != text) {
      final version = _openVersions[key]! + 1;
      await _client.changeDocument(uri, text, version: version);
      _openVersions[key] = version;
    }
    _openDocuments[key] = await _snapshotForOpenDocument(uri, text);
    await refresh();
  }

  Future<void> closeDocument(Uri uri) async {
    _ensureActive();
    await _client.closeDocument(uri);
    _openDocuments.remove(uri.toString());
    _openVersions.remove(uri.toString());
    await refresh();
  }

  Future<WorkspaceFileSnapshot> _snapshotForOpenDocument(
    Uri uri,
    String text,
  ) async {
    if (uri.scheme != 'file' ||
        !uri.path.endsWith(GDScriptConstants.fileExtension)) {
      throw ArgumentError.value(
        uri,
        'uri',
        'Only file-based .gd documents are supported.',
      );
    }
    if (utf8.encode(text).length >
        GDScriptConstants.maximumWorkspaceFileBytes) {
      throw WorkspaceIndexException([
        WorkspaceFileIssue(
          uri.path,
          'Open document exceeds the ${GDScriptConstants.maximumWorkspaceFileBytes}-byte language-server limit.',
        ),
      ]);
    }
    final root = await _repository.getRootPath();
    if (root == null) {
      throw StateError('Select a workspace before opening files.');
    }
    final resolvedRoot = await Directory(root).resolveSymbolicLinks();
    final file = File.fromUri(uri).absolute;
    final path = file.path;
    if (!path.startsWith('$resolvedRoot${Platform.pathSeparator}')) {
      throw ArgumentError.value(
        uri,
        'uri',
        'Document is outside the workspace.',
      );
    }
    final realParent = await Directory(file.parent.path).resolveSymbolicLinks();
    if (realParent != resolvedRoot &&
        !realParent.startsWith('$resolvedRoot${Platform.pathSeparator}')) {
      throw ArgumentError.value(
        uri,
        'uri',
        'Document resolves outside the workspace.',
      );
    }
    if (await FileSystemEntity.type(path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw ArgumentError.value(uri, 'uri', 'Symbolic links are not indexed.');
    }
    final modified = await file.exists()
        ? (await file.stat()).modified.millisecondsSinceEpoch
        : DateTime.now().millisecondsSinceEpoch;
    return WorkspaceFileSnapshot(
      uri: file.uri.toString(),
      relativePath: path
          .substring(resolvedRoot.length + 1)
          .replaceAll(r'\', '/'),
      content: text,
      modifiedMillis: modified,
    );
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    await _stopWatching();
    await _queuedRefresh;
    await _watchErrors.close();
  }

  Future<void> _startWatching(String rootPath) async {
    await _syncWatchers(rootPath);
  }

  Future<void> _syncWatchers(String rootPath) async {
    final directories = await _watchableDirectories(rootPath);
    final removed = _watchSubscriptions.keys
        .where((path) => !directories.contains(path))
        .toList(growable: false);
    for (final path in removed) {
      await _watchSubscriptions.remove(path)?.cancel();
    }
    for (final path in directories) {
      if (_watchSubscriptions.containsKey(path)) continue;
      _watchSubscriptions[path] = Directory(path).watch().listen(
        (_) => _scheduleRefresh(),
        onError: (Object error, StackTrace stackTrace) {
          if (!_watchErrors.isClosed) {
            _watchErrors.addError(error, stackTrace);
          }
        },
        cancelOnError: false,
      );
    }
  }

  Future<List<String>> _watchableDirectories(String rootPath) async {
    final directories = <String>[];
    final pending = <Directory>[Directory(rootPath)];
    while (pending.isNotEmpty) {
      final directory = pending.removeLast();
      directories.add(directory.path);
      await for (final entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        final name = IoWorkspaceFileSystem._basename(entity.path);
        if (name.startsWith('.')) continue;
        final type = await FileSystemEntity.type(
          entity.path,
          followLinks: false,
        );
        if (type == FileSystemEntityType.directory &&
            !_excludedDirectoryNames.contains(name)) {
          pending.add(Directory(entity.path));
        }
      }
    }
    return directories;
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(milliseconds: 150), () {
      _refreshTimer = null;
      _queuedRefresh = _queuedRefresh.then((_) async {
        try {
          await refresh();
        } on Object catch (error, stackTrace) {
          if (!_watchErrors.isClosed) {
            _watchErrors.addError(error, stackTrace);
          }
        }
      });
    });
  }

  Future<void> _stopWatching() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    final subscriptions = _watchSubscriptions.values.toList(growable: false);
    _watchSubscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('WorkspaceIndexService has been disposed.');
    }
  }

  Future<void> _sendUpdates({
    required List<WorkspaceFileSnapshot> upserts,
    required List<String> removals,
  }) async {
    final batches = _batches(upserts);
    if (batches.isEmpty && removals.isEmpty) return;
    var removedIndex = 0;
    for (final batch in batches) {
      final removedEnd = (removedIndex + _batchRemovedUrisLimit).clamp(
        0,
        removals.length,
      );
      await _client.updateWorkspaceFiles(
        files: [
          for (final file in batch) {'uri': file.uri, 'text': file.content},
        ],
        removedUris: removals.sublist(removedIndex, removedEnd),
      );
      removedIndex = removedEnd;
    }
    while (removedIndex < removals.length) {
      final removedEnd = (removedIndex + _batchRemovedUrisLimit).clamp(
        0,
        removals.length,
      );
      await _client.updateWorkspaceFiles(
        files: const [],
        removedUris: removals.sublist(removedIndex, removedEnd),
      );
      removedIndex = removedEnd;
    }
  }

  static List<List<WorkspaceFileSnapshot>> _batches(
    List<WorkspaceFileSnapshot> files,
  ) {
    final result = <List<WorkspaceFileSnapshot>>[];
    var current = <WorkspaceFileSnapshot>[];
    var currentBytes = 0;
    for (final file in files) {
      final size = utf8.encode(file.content).length;
      if (size > GDScriptConstants.maximumWorkspaceFileBytes) {
        throw WorkspaceIndexException([
          WorkspaceFileIssue(
            file.relativePath,
            'File exceeds the ${GDScriptConstants.maximumWorkspaceFileBytes}-byte language-server limit.',
          ),
        ]);
      }
      if (current.isNotEmpty &&
          (current.length >= _batchFilesLimit ||
              currentBytes + size > _batchBytesLimit)) {
        result.add(current);
        current = <WorkspaceFileSnapshot>[];
        currentBytes = 0;
      }
      current.add(file);
      currentBytes += size;
    }
    if (current.isNotEmpty) result.add(current);
    return result;
  }
}
