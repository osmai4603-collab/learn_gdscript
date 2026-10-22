import 'dart:async';
import 'dart:convert';

import '../../core/constants/gdscript_constants.dart';
import 'lsp_process_transport.dart';
import 'lsp_transport.dart';

typedef LspObject = Map<String, Object?>;

class LanguageServerClient {
  LanguageServerClient(this._transport) {
    _stdoutSubscription = _transport.stdoutBytes.listen(
      _onBytes,
      onError: _onTransportError,
      onDone: _onStdoutDone,
      cancelOnError: false,
    );
    _stderrSubscription = _transport.stderrBytes.listen(
      (bytes) => _stderrBytes += bytes.length,
      onError: _onTransportError,
      cancelOnError: false,
    );
  }

  final LspTransport _transport;
  final LspFrameDecoder _decoder = LspFrameDecoder();
  final Map<int, Completer<Object?>> _pending = {};
  final StreamController<LspNotification> _notifications =
      StreamController<LspNotification>.broadcast();
  late final StreamSubscription<List<int>> _stdoutSubscription;
  late final StreamSubscription<List<int>> _stderrSubscription;
  int _nextId = 1;
  int _stderrBytes = 0;
  bool _initialized = false;
  bool _closing = false;
  bool _closed = false;
  bool _transportFailed = false;
  LspObject? _serverCapabilities;

  Stream<LspNotification> get notifications => _notifications.stream;
  LspObject? get serverCapabilities => _serverCapabilities;

  static Future<LanguageServerClient> start({
    required String executablePath,
    List<String> arguments = const [],
    String? workingDirectory,
  }) async {
    final transport = await ProcessLspTransport.start(
      executablePath,
      arguments: arguments,
      workingDirectory: workingDirectory,
    );
    return LanguageServerClient(transport);
  }

  Future<LspObject> initialize({
    Uri? rootUri,
    List<Uri> workspaceFolders = const [],
  }) async {
    if (_initialized) {
      throw StateError('LSP client is already initialized.');
    }
    final result = await request('initialize', {
      'processId': null,
      'rootUri': rootUri?.toString(),
      'capabilities': const <String, Object?>{},
      'workspaceFolders': [
        for (final uri in workspaceFolders)
          {
            'uri': uri.toString(),
            'name': uri.pathSegments.isEmpty
                ? 'workspace'
                : uri.pathSegments.last,
          },
      ],
    });
    final response = _asObject(result, 'initialize result');
    final capabilities = _asObject(
      response['capabilities'],
      'server capabilities',
    );
    await notify('initialized', const {});
    _serverCapabilities = capabilities;
    _initialized = true;
    return capabilities;
  }

  Future<Object?> request(String method, LspObject params) {
    final handle = requestCancelable(method, params);
    return handle.result;
  }

  LspRequestHandle requestCancelable(String method, LspObject params) {
    if (_closed || _closing) {
      throw StateError('LSP client is closing or closed.');
    }
    if (!_initialized && method != 'initialize') {
      throw StateError('LSP client must be initialized before "$method".');
    }
    final id = _nextId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;
    final handle = LspRequestHandle(
      id: id,
      result: completer.future,
      cancel: () => cancelRequest(id),
    );
    _send({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    }).catchError((Object error, StackTrace stackTrace) {
      _completeError(id, error, stackTrace);
    });
    return handle;
  }

  Future<void> notify(String method, LspObject params) async {
    if (_closed) throw StateError('LSP client is closed.');
    await _send({'jsonrpc': '2.0', 'method': method, 'params': params});
  }

  Future<void> cancelRequest(int id) async {
    if (!_pending.containsKey(id)) return;
    await notify(r'$/cancelRequest', {'id': id});
  }

  Future<void> openDocument(Uri uri, String text, {int version = 1}) =>
      _withSyncCapability(
        'openClose',
        () => notify('textDocument/didOpen', {
          'textDocument': {
            'uri': uri.toString(),
            'languageId': GDScriptConstants.languageId,
            'version': version,
            'text': text,
          },
        }),
      );

  Future<void> changeDocument(Uri uri, String text, {required int version}) =>
      _withSyncCapability(
        'change',
        () => notify('textDocument/didChange', {
          'textDocument': {'uri': uri.toString(), 'version': version},
          'contentChanges': [
            {'text': text},
          ],
        }),
      );

  Future<void> saveDocument(Uri uri, {String? text}) => _withSyncCapability(
    'save',
    () => notify('textDocument/didSave', {
      'textDocument': {'uri': uri.toString()},
      'text': ?text,
    }),
  );

  Future<void> closeDocument(Uri uri) => _withSyncCapability(
    'openClose',
    () => notify('textDocument/didClose', {
      'textDocument': {'uri': uri.toString()},
    }),
  );

  Future<Object?> complete(Uri uri, int line, int character) {
    _requireCapability('completionProvider');
    return request('textDocument/completion', {
      'textDocument': {'uri': uri.toString()},
      'position': {'line': line, 'character': character},
    });
  }

  Future<Object?> semanticTokens(Uri uri) {
    _requireCapability('semanticTokensProvider');
    return request('textDocument/semanticTokens/full', {
      'textDocument': {'uri': uri.toString()},
    });
  }

  Future<Object?> hover(Uri uri, int line, int character) => _positionRequest(
    'hoverProvider',
    'textDocument/hover',
    uri,
    line,
    character,
  );

  Future<Object?> signatureHelp(Uri uri, int line, int character) =>
      _positionRequest(
        'signatureHelpProvider',
        'textDocument/signatureHelp',
        uri,
        line,
        character,
      );

  Future<Object?> definition(Uri uri, int line, int character) =>
      _positionRequest(
        'definitionProvider',
        'textDocument/definition',
        uri,
        line,
        character,
      );

  Future<Object?> references(
    Uri uri,
    int line,
    int character, {
    bool includeDeclaration = true,
  }) {
    _requireCapability('referencesProvider');
    return request('textDocument/references', {
      'textDocument': {'uri': uri.toString()},
      'position': {'line': line, 'character': character},
      'context': {'includeDeclaration': includeDeclaration},
    });
  }

  Future<Object?> foldingRanges(Uri uri) {
    _requireCapability('foldingRangeProvider');
    return request('textDocument/foldingRange', {
      'textDocument': {'uri': uri.toString()},
    });
  }

  Future<Object?> selectionRanges(Uri uri, List<LspObject> positions) {
    _requireCapability('selectionRangeProvider');
    return request('textDocument/selectionRange', {
      'textDocument': {'uri': uri.toString()},
      'positions': positions,
    });
  }

  Future<Object?> documentHighlights(Uri uri, int line, int character) =>
      _positionRequest(
        'documentHighlightProvider',
        'textDocument/documentHighlight',
        uri,
        line,
        character,
      );

  Future<Object?> formatDocument(
    Uri uri, {
    int tabSize = 4,
    bool insertSpaces = true,
  }) {
    _requireCapability('documentFormattingProvider');
    return request('textDocument/formatting', {
      'textDocument': {'uri': uri.toString()},
      'options': {'tabSize': tabSize, 'insertSpaces': insertSpaces},
    });
  }

  Future<Object?> workspaceSymbols(String query) {
    _requireCapability('workspaceSymbolProvider');
    return request('workspace/symbol', {'query': query});
  }

  Future<Object?> searchWorkspace(String query, {bool caseSensitive = false}) {
    _requireExperimentalCapability('gdscriptSearchWorkspaceText');
    return request('gdscript/searchWorkspaceText', {
      'query': query,
      'caseSensitive': caseSensitive,
    });
  }

  Future<void> updateWorkspaceFiles({
    required List<LspObject> files,
    required List<String> removedUris,
  }) async {
    _requireExperimentalCapability('gdscriptUpdateWorkspaceFiles');
    await request('gdscript/updateWorkspaceFiles', {
      'files': files,
      'removedUris': removedUris,
    });
  }

  Future<void> changeWorkspaceFolders({
    required List<Uri> added,
    required List<Uri> removed,
  }) {
    final workspace = _serverCapabilities?['workspace'];
    final folders = workspace is Map ? workspace['workspaceFolders'] : null;
    if (folders is! Map || folders['supported'] != true) {
      throw UnsupportedError(
        'The language server did not advertise workspace folders.',
      );
    }
    return notify('workspace/didChangeWorkspaceFolders', {
      'event': {
        'added': [
          for (final uri in added)
            {'uri': uri.toString(), 'name': _workspaceFolderName(uri)},
        ],
        'removed': [
          for (final uri in removed)
            {'uri': uri.toString(), 'name': _workspaceFolderName(uri)},
        ],
      },
    });
  }

  Future<void> shutdown() async {
    if (_closed) return;
    Object? shutdownError;
    StackTrace? shutdownStack;
    if (_initialized) {
      try {
        await request(
          'shutdown',
          const {},
        ).timeout(const Duration(seconds: 10));
      } on Object catch (error, stackTrace) {
        shutdownError = error;
        shutdownStack = stackTrace;
      }
    }
    _closing = true;
    try {
      await _send({'jsonrpc': '2.0', 'method': 'exit'});
    } finally {
      await _transport.closeInput();
    }
    try {
      final exitCode = await _transport.exitCode.timeout(
        const Duration(seconds: 10),
      );
      if (exitCode != 0) {
        throw StateError(
          'Language server exited with status $exitCode after shutdown.',
        );
      }
    } on TimeoutException {
      await _transport.kill();
      throw TimeoutException('Language server did not exit after shutdown.');
    } finally {
      await _finish();
    }
    if (shutdownError != null) {
      Error.throwWithStackTrace(shutdownError, shutdownStack!);
    }
  }

  Future<void> dispose() async {
    if (_closed) return;
    if (_initialized && !_transportFailed) {
      await shutdown();
    } else {
      await _transport.kill();
      await _finish();
    }
  }

  Future<Object?> _positionRequest(
    String capability,
    String method,
    Uri uri,
    int line,
    int character,
  ) {
    _requireCapability(capability);
    return request(method, {
      'textDocument': {'uri': uri.toString()},
      'position': {'line': line, 'character': character},
    });
  }

  void _requireCapability(String capability) {
    final value = _serverCapabilities?[capability];
    if (value == null || value == false) {
      throw UnsupportedError(
        'The language server did not advertise $capability.',
      );
    }
  }

  void _requireExperimentalCapability(String capability) {
    final experimental = _serverCapabilities?['experimental'];
    if (experimental is! Map || experimental[capability] != true) {
      throw UnsupportedError(
        'The language server did not advertise experimental.$capability.',
      );
    }
  }

  Future<void> _withSyncCapability(
    String option,
    Future<void> Function() operation,
  ) {
    final sync = _serverCapabilities?['textDocumentSync'];
    final supported = switch (option) {
      'openClose' => sync is Map && sync['openClose'] == true,
      'change' =>
        sync is int
            ? sync > 0
            : sync is Map && sync['change'] is int && sync['change'] != 0,
      'save' => sync is Map && sync['save'] != null && sync['save'] != false,
      _ => false,
    };
    if (!supported) {
      throw UnsupportedError(
        'The language server did not advertise textDocumentSync.$option.',
      );
    }
    return operation();
  }

  Future<void> _send(LspObject message) {
    if (_closed) throw StateError('LSP transport is closed.');
    final bytes = utf8.encode(jsonEncode(message));
    final header = ascii.encode('Content-Length: ${bytes.length}\r\n\r\n');
    return _transport.write([...header, ...bytes]);
  }

  void _onBytes(List<int> bytes) {
    try {
      for (final message in _decoder.add(bytes)) {
        _dispatch(message);
      }
    } on Object catch (error, stackTrace) {
      _onTransportError(error, stackTrace);
      unawaited(_transport.kill());
    }
  }

  void _dispatch(LspObject message) {
    final id = message['id'];
    if (id is int) {
      final completer = _pending.remove(id);
      if (completer == null) return;
      if (message['error'] case final error?) {
        final errorObject = _asObject(error, 'JSON-RPC error');
        final code = errorObject['code'];
        final text = errorObject['message'];
        if (code is! int || text is! String) {
          completer.completeError(
            const FormatException('Malformed JSON-RPC error response.'),
          );
        } else {
          completer.completeError(
            LspRpcException(code, text, data: errorObject['data']),
          );
        }
      } else {
        completer.complete(message['result']);
      }
      return;
    }
    final method = message['method'];
    if (method is String) {
      final params = message['params'];
      _notifications.add(
        LspNotification(
          method,
          params == null ? const {} : _asObject(params, '$method params'),
        ),
      );
    }
  }

  void _onTransportError(Object error, StackTrace stackTrace) {
    _transportFailed = true;
    for (final completer in _pending.values) {
      if (!completer.isCompleted) completer.completeError(error, stackTrace);
    }
    _pending.clear();
    if (!_notifications.isClosed) _notifications.addError(error, stackTrace);
  }

  void _onStdoutDone() {
    if (_closing || _closed) return;
    _transportFailed = true;
    _onTransportError(
      StateError(
        'LSP stdout closed unexpectedly (stderr bytes received: $_stderrBytes).',
      ),
      StackTrace.current,
    );
    unawaited(_transport.kill());
  }

  void _completeError(int id, Object error, StackTrace stackTrace) {
    final completer = _pending.remove(id);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  Future<void> _finish() async {
    if (_closed) return;
    _closed = true;
    for (final entry in _pending.entries) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(StateError('LSP client closed.'));
      }
    }
    _pending.clear();
    await _stdoutSubscription.cancel();
    await _stderrSubscription.cancel();
    await _notifications.close();
  }

  static LspObject _asObject(Object? value, String description) {
    if (value is! Map) throw FormatException('$description must be an object.');
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw FormatException('$description keys must be strings.');
    }
  }

  static String _workspaceFolderName(Uri uri) {
    for (final segment in uri.pathSegments.reversed) {
      if (segment.isNotEmpty) return segment;
    }
    return 'workspace';
  }
}

class LspRequestHandle {
  const LspRequestHandle({
    required this.id,
    required this.result,
    required this.cancel,
  });

  final int id;
  final Future<Object?> result;
  final Future<void> Function() cancel;
}
