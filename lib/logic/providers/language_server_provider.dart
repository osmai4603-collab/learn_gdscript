import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:learn_gdscript/logic/services/lsp_transport.dart';

import '../../data/repositories/workspace_repository.dart';
import '../services/language_server_client.dart';
import '../services/language_server_factory.dart';
import '../services/workspace_index_service.dart';

class LanguageServerProvider extends ChangeNotifier {
  LanguageServerProvider({
    required this._workspaceRepository,
    this._factory = const LanguageServerFactory(),
  });

  final WorkspaceRepository _workspaceRepository;
  final LanguageServerFactory _factory;
  LanguageServerClient? _client;
  WorkspaceIndexService? _index;
  StreamSubscription<LspNotification>? _notifications;
  final Map<String, Uri> _documents = {};
  final Set<String> _workspaceDocumentUris = {};
  final Map<String, List<Map<String, Object?>>> _diagnostics = {};
  String? _rootPath;
  Object? _lastError;
  bool _connecting = false;
  int _indexedFileCount = 0;

  bool get isConnected => _client != null;
  bool get isConnecting => _connecting;
  String? get rootPath => _rootPath;
  Object? get lastError => _lastError;
  int get indexedFileCount => _indexedFileCount;
  LanguageServerClient? get client => _client;
  Map<String, List<Map<String, Object?>>> get diagnosticsByUri =>
      Map<String, List<Map<String, Object?>>>.unmodifiable({
        for (final entry in _diagnostics.entries)
          entry.key: List<Map<String, Object?>>.unmodifiable(
            entry.value.map(Map<String, Object?>.unmodifiable),
          ),
      });

  Future<void> loadSavedWorkspace() async {
    _rootPath = await _workspaceRepository.getRootPath();
    notifyListeners();
  }

  List<Map<String, Object?>> diagnosticsForLesson(String lessonId) {
    final uri = _documents[lessonId];
    return uri == null
        ? const []
        : _diagnostics[uri.toString()] ?? const [];
  }

  Future<void> connect(
    String rootPath, {
    String? executablePath,
  }) async {
    if (_connecting) throw StateError('Language server connection is in progress.');
    if (isConnected) await disconnect();
    _connecting = true;
    _lastError = null;
    notifyListeners();
    LanguageServerClient? client;
    WorkspaceIndexService? index;
    try {
      final root = Directory(rootPath).absolute;
      if (!await root.exists()) {
        throw FileSystemException('Workspace directory does not exist.', rootPath);
      }
      final resolvedRoot = await root.resolveSymbolicLinks();
      client = await _factory
          .resolve(executablePath: executablePath)
          .start();
      await client.initialize(
        rootUri: Directory(resolvedRoot).uri,
        workspaceFolders: [Directory(resolvedRoot).uri],
      );
      index = WorkspaceIndexService(
        repository: _workspaceRepository,
        client: client,
      );
      await index.selectWorkspace(resolvedRoot);
      _client = client;
      _index = index;
      _rootPath = resolvedRoot;
      _indexedFileCount = (await _workspaceRepository.loadFiles()).length;
      _notifications = client.notifications.listen(_handleNotification);
    } on Object catch (error) {
      _lastError = error;
      if (index != null) await index.dispose();
      if (client != null) await client.dispose();
      rethrow;
    } finally {
      _connecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    final index = _index;
    final client = _client;
    final notificationSubscription = _notifications;
    await notificationSubscription?.cancel();
    if (client != null) {
      for (final uri in [..._documents.values, ..._workspaceDocumentUris.map(Uri.parse)]) {
        await client.closeDocument(uri);
      }
    }
    await index?.dispose();
    await client?.dispose();
    _index = null;
    _client = null;
    _notifications = null;
    _documents.clear();
    _workspaceDocumentUris.clear();
    _diagnostics.clear();
    _rootPath = null;
    _indexedFileCount = 0;
    _lastError = null;
    notifyListeners();
  }

  Future<void> openLessonDocument(String lessonId, String code) async {
    final client = _requireClient();
    final rootPath = _rootPath;
    if (rootPath == null) throw StateError('No workspace is selected.');
    final uri = Uri.file(
      '$rootPath${Platform.pathSeparator}.learn_gdscript${Platform.pathSeparator}$lessonId.gd',
    );
    await client.openDocument(uri, code);
    _documents[lessonId] = uri;
    _diagnostics.remove(uri.toString());
    notifyListeners();
  }

  Future<void> syncLessonDocument(String lessonId, String code) async {
    final client = _requireClient();
    final uri = _documents[lessonId];
    if (uri == null) {
      await openLessonDocument(lessonId, code);
      return;
    }
    final version = _documentVersions.update(
      lessonId,
      (version) => version + 1,
      ifAbsent: () => 2,
    );
    await client.changeDocument(uri, code, version: version);
  }

  final Map<String, int> _documentVersions = {};

  Future<void> closeLessonDocument(String lessonId) async {
    final uri = _documents.remove(lessonId);
    _documentVersions.remove(lessonId);
    if (uri == null || _client == null) return;
    await _client!.closeDocument(uri);
    _diagnostics.remove(uri.toString());
    notifyListeners();
  }

  Future<List<String>> completeLessonDocument(
    String lessonId,
    String code,
    int cursorOffset,
  ) async {
    final client = _requireClient();
    final uri = _documents[lessonId];
    if (uri == null) {
      await openLessonDocument(lessonId, code);
      return completeLessonDocument(lessonId, code, cursorOffset);
    }
    await syncLessonDocument(lessonId, code);
    final offset = cursorOffset.clamp(0, code.length);
    final beforeCursor = code.substring(0, offset);
    final line = '\n'.allMatches(beforeCursor).length;
    final lineStart = beforeCursor.lastIndexOf('\n') + 1;
    final character = beforeCursor.length - lineStart;
    final raw = await client.complete(uri, line, character);
    final items = raw is List
        ? raw
        : raw is Map
        ? raw['items']
        : null;
    if (items is! List) return const [];
    return [
      for (final item in items)
        if (item is Map &&
            (item['insertText'] is String || item['label'] is String))
          (item['insertText'] ?? item['label']) as String,
    ];
  }

  Future<String?> formatLessonDocument(String lessonId, String code) async {
    final client = _requireClient();
    final uri = _documents[lessonId];
    if (uri == null) throw StateError('Lesson document is not open.');
    await syncLessonDocument(lessonId, code);
    final response = await client.formatDocument(uri);
    if (response is! List || response.isEmpty) return null;
    final edits = <_TextEdit>[];
    for (final item in response) {
      if (item is! Map ||
          item['range'] is! Map ||
          item['newText'] is! String) {
        throw const FormatException('Language server returned an invalid text edit.');
      }
      final range = item['range'] as Map;
      final start = range['start'];
      final end = range['end'];
      if (start is! Map || end is! Map) {
        throw const FormatException('Language server returned an invalid edit range.');
      }
      edits.add(
        _TextEdit(
          _offsetForPosition(code, start),
          _offsetForPosition(code, end),
          item['newText'] as String,
        ),
      );
    }
    edits.sort((a, b) => b.start.compareTo(a.start));
    var formatted = code;
    for (final edit in edits) {
      formatted = formatted.replaceRange(edit.start, edit.end, edit.text);
    }
    await syncLessonDocument(lessonId, formatted);
    return formatted;
  }

  Future<Object?> hoverLessonDocument(
    String lessonId,
    int line,
    int character,
  ) {
    final uri = _documents[lessonId];
    if (uri == null) throw StateError('Lesson document is not open.');
    return _requireClient().hover(uri, line, character);
  }

  Future<Object?> signatureHelp(
    String lessonId,
    int line,
    int character,
  ) {
    final uri = _documents[lessonId];
    if (uri == null) throw StateError('Lesson document is not open.');
    return _requireClient().signatureHelp(uri, line, character);
  }

  Future<Object?> foldingRanges(String lessonId) {
    final uri = _documents[lessonId];
    if (uri == null) throw StateError('Lesson document is not open.');
    return _requireClient().foldingRanges(uri);
  }

  Future<Object?> semanticTokens(String lessonId) {
    final uri = _documents[lessonId];
    if (uri == null) throw StateError('Lesson document is not open.');
    return _requireClient().semanticTokens(uri);
  }

  Future<Object?> searchWorkspace(String query) =>
      _requireClient().searchWorkspace(query);

  Future<Object?> workspaceSymbols(String query) =>
      _requireClient().workspaceSymbols(query);

  Future<void> synchronizeWorkspace() async {
    final index = _index;
    if (index == null) throw StateError('Language server is not connected.');
    await index.synchronizeWorkspace();
    _indexedFileCount = (await _workspaceRepository.loadFiles()).length;
    notifyListeners();
  }

  Future<void> openWorkspaceDocument(Uri uri, String code) async {
    final index = _index;
    if (index == null) throw StateError('Language server is not connected.');
    final key = uri.toString();
    if (_workspaceDocumentUris.contains(key)) return;
    await index.openDocument(uri, code);
    _workspaceDocumentUris.add(key);
  }

  Future<void> changeWorkspaceDocument(Uri uri, String code) async {
    final index = _index;
    if (index == null) throw StateError('Language server is not connected.');
    final key = uri.toString();
    if (!_workspaceDocumentUris.contains(key)) {
      await openWorkspaceDocument(uri, code);
      return;
    }
    final version = _workspaceDocumentVersions.update(
      key,
      (version) => version + 1,
      ifAbsent: () => 2,
    );
    await index.changeDocument(uri, code, version: version);
  }

  final Map<String, int> _workspaceDocumentVersions = {};

  Future<void> saveWorkspaceDocument(Uri uri, String code) async {
    final index = _index;
    if (index == null) throw StateError('Language server is not connected.');
    if (!_workspaceDocumentUris.contains(uri.toString())) {
      throw StateError('Workspace document is not open.');
    }
    await index.saveDocument(uri, text: code);
    _indexedFileCount = (await _workspaceRepository.loadFiles()).length;
    notifyListeners();
  }

  Future<void> closeWorkspaceDocument(Uri uri) async {
    final key = uri.toString();
    if (!_workspaceDocumentUris.remove(key)) return;
    _workspaceDocumentVersions.remove(key);
    final index = _index;
    if (index != null) await index.closeDocument(uri);
    _diagnostics.remove(key);
    notifyListeners();
  }

  List<Map<String, Object?>> diagnosticsForUri(String uri) =>
      _diagnostics[uri] ?? const [];

  LanguageServerClient _requireClient() {
    final client = _client;
    if (client == null) throw StateError('Language server is not connected.');
    return client;
  }

  void _handleNotification(LspNotification notification) {
    if (notification.method != 'textDocument/publishDiagnostics') return;
    final uri = notification.params['uri'];
    final rawDiagnostics = notification.params['diagnostics'];
    if (uri is! String || rawDiagnostics is! List) {
      _lastError = const FormatException(
        'Language server published malformed diagnostics.',
      );
      notifyListeners();
      return;
    }
    _diagnostics[uri] = [
      for (final diagnostic in rawDiagnostics)
        if (diagnostic is Map)
          Map<String, Object?>.from(diagnostic),
    ];
    notifyListeners();
  }

  static int _offsetForPosition(String code, Object position) {
    if (position is! Map ||
        position['line'] is! int ||
        position['character'] is! int) {
      throw const FormatException(
        'Language server returned an invalid text position.',
      );
    }
    final targetLine = position['line'] as int;
    final targetCharacter = position['character'] as int;
    if (targetLine < 0 || targetCharacter < 0) {
      throw const FormatException(
        'Language server returned a negative text position.',
      );
    }
    var line = 0;
    var offset = 0;
    while (line < targetLine && offset < code.length) {
      if (code.codeUnitAt(offset++) == 10) line++;
    }
    if (line != targetLine) {
      throw const FormatException(
        'Language server returned a text position outside the document.',
      );
    }
    final lineEnd = code.indexOf('\n', offset);
    final maximum = lineEnd < 0 ? code.length : lineEnd;
    return (offset + targetCharacter).clamp(offset, maximum).toInt();
  }
}

class _TextEdit {
  const _TextEdit(this.start, this.end, this.text);

  final int start;
  final int end;
  final String text;
}
