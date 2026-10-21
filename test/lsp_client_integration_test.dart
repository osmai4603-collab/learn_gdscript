import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'communicates with the LSP server over stdio across multiple files',
    () async {
      final serverDirectory = _serverDirectory();
      if (serverDirectory == null) {
        markTestSkipped(
          'Set GDSCRIPT_LSP_PATH or place gdscript_lsp beside this project.',
        );
      }
      final workspace = await Directory.systemTemp.createTemp(
        'learn-gdscript-lsp-',
      );
      addTearDown(() => workspace.delete(recursive: true));
      final workspaceUri = Uri.directory(workspace.path);
      final client = await _LspProcessClient.start(serverDirectory!);
      addTearDown(client.dispose);

      final capabilities = await client.initialize(workspaceUri);
      expect(capabilities['completionProvider'], isNotNull);
      expect(capabilities['foldingRangeProvider'], isNotNull);
      expect(capabilities['documentFormattingProvider'], isNotNull);
      expect(capabilities['documentHighlightProvider'], isNotNull);
      expect(capabilities['referencesProvider'], isNotNull);
      expect(capabilities['workspaceSymbolProvider'], isNotNull);
      expect(capabilities['semanticTokensProvider'], isNotNull);

      final mainUri = Uri.file('${workspace.path}/main.gd').toString();
      final helperUri = Uri.file('${workspace.path}/helper.gd').toString();
      final usageUri = Uri.file('${workspace.path}/usage.gd').toString();
      await client.request('gdscript/updateWorkspaceFiles', {
        'files': [
          {
            'uri': helperUri,
            'text': 'class_name Helper\nfunc shared_name():\n    pass\n',
          },
          {
            'uri': usageUri,
            'text': 'class_name Usage\nfunc call_it():\n    shared_name()\n',
          },
        ],
        'removedUris': [],
      });

      var text =
          'class_name Main\nfunc run():\n    var value=1\n    shared_name()\n    print("hello")\n';
      await client.notify('textDocument/didOpen', {
        'textDocument': {
          'uri': mainUri,
          'languageId': 'gdscript',
          'version': 1,
          'text': text,
        },
      });
      final diagnostics = await client.waitForNotification(
        'textDocument/publishDiagnostics',
        where: (params) => params['uri'] == mainUri,
      );
      expect(diagnostics['diagnostics'], isA<List<dynamic>>());

      final diagnosticUri = Uri.file(
        '${workspace.path}/diagnostics.gd',
      ).toString();
      await client.notify('textDocument/didOpen', {
        'textDocument': {
          'uri': diagnosticUri,
          'languageId': 'gdscript',
          'version': 1,
          'text': 'func broken(:\n    pass\n',
        },
      });
      final invalidDiagnostics = await client.waitForNotification(
        'textDocument/publishDiagnostics',
        where: (params) => params['uri'] == diagnosticUri,
      );
      expect(invalidDiagnostics['diagnostics'], isNotEmpty);
      await client.notify('textDocument/didChange', {
        'textDocument': {'uri': diagnosticUri, 'version': 2},
        'contentChanges': [
          {'text': 'var corrected = 1\n'},
        ],
      });
      final correctedDiagnostics = await client.waitForNotification(
        'textDocument/publishDiagnostics',
        where: (params) => params['uri'] == diagnosticUri,
      );
      expect(correctedDiagnostics['diagnostics'], isEmpty);

      final completion = await client.request('textDocument/completion', {
        'textDocument': {'uri': mainUri},
        'position': {'line': 2, 'character': 14},
      });
      final completionItems = completion is List
          ? completion
          : (completion as Map<String, dynamic>)['items'] as List<dynamic>;
      expect(completionItems, isNotEmpty);

      final semanticTokens =
          await client.request('textDocument/semanticTokens/full', {
                'textDocument': {'uri': mainUri},
              })
              as Map<String, dynamic>;
      expect(semanticTokens['data'], isA<List>());

      final foldingRanges = await client.request('textDocument/foldingRange', {
        'textDocument': {'uri': mainUri},
      });
      expect(foldingRanges, isA<List>());
      expect(foldingRanges, isNotEmpty);

      final selections = await client.request('textDocument/selectionRange', {
        'textDocument': {'uri': mainUri},
        'positions': [
          {'line': 3, 'character': 6},
        ],
      });
      expect(selections, isA<List>());
      expect(selections, isNotEmpty);

      final highlights = await client.request(
        'textDocument/documentHighlight',
        {
          'textDocument': {'uri': mainUri},
          'position': {'line': 4, 'character': 9},
        },
      );
      expect(highlights, hasLength(2));

      final edits = await client.request('textDocument/formatting', {
        'textDocument': {'uri': mainUri},
        'options': {'tabSize': 4, 'insertSpaces': true},
      });
      expect(edits, isA<List>());
      expect(edits, isNotEmpty);

      final symbols =
          await client.request('workspace/symbol', {'query': 'Helper'})
              as List<dynamic>;
      expect(symbols.map((symbol) => symbol['name']), contains('Helper'));

      final definition =
          await client.request('textDocument/definition', {
                'textDocument': {'uri': mainUri},
                'position': {'line': 3, 'character': 6},
              })
              as List<dynamic>;
      expect(definition, hasLength(1));
      expect(definition.single['uri'], helperUri);

      final references =
          await client.request('textDocument/references', {
                'textDocument': {'uri': mainUri},
                'position': {'line': 3, 'character': 6},
                'context': {'includeDeclaration': true},
              })
              as List<dynamic>;
      expect(references, hasLength(3));
      expect(
        references.map((reference) => reference['uri']),
        containsAll([mainUri, helperUri, usageUri]),
      );

      final textMatches =
          await client.request('gdscript/searchWorkspaceText', {
                'query': 'shared_name',
              })
              as List<dynamic>;
      expect(textMatches, hasLength(3));

      text = text.replaceFirst('value=1', 'value = 2');
      await client.notify('textDocument/didChange', {
        'textDocument': {'uri': mainUri, 'version': 2},
        'contentChanges': [
          {'text': text},
        ],
      });
      final updatedDiagnostics = await client.waitForNotification(
        'textDocument/publishDiagnostics',
        where: (params) => params['uri'] == mainUri,
      );
      expect(updatedDiagnostics['diagnostics'], isA<List<dynamic>>());

      await client.request('gdscript/updateWorkspaceFiles', {
        'files': [],
        'removedUris': [usageUri],
      });
      final remainingReferences =
          await client.request('textDocument/references', {
                'textDocument': {'uri': mainUri},
                'position': {'line': 3, 'character': 6},
                'context': {'includeDeclaration': true},
              })
              as List<dynamic>;
      expect(remainingReferences, hasLength(2));

      await client.notify('workspace/didChangeWorkspaceFolders', {
        'event': {
          'added': [],
          'removed': [
            {'uri': workspaceUri.toString(), 'name': 'integration-test'},
          ],
        },
      });
      final symbolsAfterWorkspaceRemoval =
          await client.request('workspace/symbol', {'query': 'Helper'})
              as List<dynamic>;
      expect(symbolsAfterWorkspaceRemoval, isEmpty);

      await client.shutdown();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

String _dartExecutable() {
  final configured = Platform.environment['DART_EXECUTABLE'];
  if (configured != null && File(configured).existsSync()) return configured;

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final dart = File(
      '$flutterRoot/bin/cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}',
    );
    if (dart.existsSync()) return dart.path;
  }

  var parent = File(Platform.resolvedExecutable).absolute.parent;
  while (parent.path != parent.parent.path) {
    final dart = File(
      '${parent.path}/bin/cache/dart-sdk/bin/dart'
      '${Platform.isWindows ? '.exe' : ''}',
    );
    if (dart.existsSync()) return dart.path;
    parent = parent.parent;
  }

  final resolved = File(Platform.resolvedExecutable);
  if (resolved.uri.pathSegments.last ==
      'dart${Platform.isWindows ? '.exe' : ''}') {
    return resolved.path;
  }
  throw StateError(
    'Could not locate the Dart executable. Set DART_EXECUTABLE or '
    'FLUTTER_ROOT.',
  );
}

Directory? _serverDirectory() {
  final configuredPath = Platform.environment['GDSCRIPT_LSP_PATH'];
  if (configuredPath != null && configuredPath.isNotEmpty) {
    final configured = Directory(configuredPath).absolute;
    return configured.existsSync() ? configured : null;
  }
  final sibling = Directory('${Directory.current.parent.path}/gdscript_lsp');
  return sibling.existsSync() ? sibling : null;
}

class _LspProcessClient {
  _LspProcessClient._(this.process) : _chunks = StreamIterator(process.stdout) {
    _stderrSubscription = process.stderr
        .transform(utf8.decoder)
        .listen(_stderrOutput.write);
  }

  final Process process;
  final StreamIterator<List<int>> _chunks;
  final StringBuffer _stderrOutput = StringBuffer();
  final List<int> _buffer = [];
  final Map<int, Completer<Map<String, dynamic>>> _responses = {};
  final List<Map<String, dynamic>> _notifications = [];
  Completer<void>? _notificationChanged;
  late final StreamSubscription<Map<String, dynamic>> _messageSubscription;
  late final StreamSubscription<String> _stderrSubscription;
  var _nextId = 1;

  static Future<_LspProcessClient> start(Directory serverDirectory) async {
    final process = await Process.start(_dartExecutable(), [
      'run',
      'bin/gdscript_lsp.dart',
      '--log-level=off',
    ], workingDirectory: serverDirectory.path);
    final client = _LspProcessClient._(process);
    client._messageSubscription = client._readMessages().listen(
      (message) {
        final id = message['id'];
        if (id is int && client._responses.containsKey(id)) {
          client._responses.remove(id)!.complete(message);
        } else {
          client._notifications.add(message);
          final changed = client._notificationChanged;
          client._notificationChanged = null;
          if (changed != null && !changed.isCompleted) changed.complete();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        for (final response in client._responses.values) {
          if (!response.isCompleted) response.completeError(error, stackTrace);
        }
        client._responses.clear();
      },
      onDone: () {
        for (final response in client._responses.values) {
          if (!response.isCompleted) {
            response.completeError(
              StateError(
                'LSP process exited before responding. '
                'stderr: ${client._stderrOutput}',
              ),
            );
          }
        }
        client._responses.clear();
      },
    );
    return client;
  }

  Future<Map<String, dynamic>> initialize(Uri workspaceUri) async {
    final response = await request('initialize', {
      'processId': pid,
      'rootUri': workspaceUri.toString(),
      'capabilities': {},
      'workspaceFolders': [
        {'uri': workspaceUri.toString(), 'name': 'integration-test'},
      ],
    });
    final result = response as Map<String, dynamic>;
    await notify('initialized', const {});
    return result['capabilities'] as Map<String, dynamic>;
  }

  Future<Object?> request(String method, Map<String, Object?> params) async {
    final id = _nextId++;
    final completer = Completer<Map<String, dynamic>>();
    _responses[id] = completer;
    await _send({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    });
    final response = await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException(
        'Timed out waiting for LSP request $method (#$id). '
        'stderr: $_stderrOutput',
      ),
    );
    if (response.containsKey('error')) {
      throw StateError('LSP $method failed: ${response['error']}');
    }
    return response['result'];
  }

  Future<void> notify(String method, Map<String, Object?> params) =>
      _send({'jsonrpc': '2.0', 'method': method, 'params': params});

  Future<Map<String, dynamic>> waitForNotification(
    String method, {
    required bool Function(Map<String, dynamic> params) where,
  }) async {
    final existingIndex = _notifications.indexWhere(
      (message) =>
          message['method'] == method &&
          message['params'] is Map<String, dynamic> &&
          where(message['params'] as Map<String, dynamic>),
    );
    if (existingIndex >= 0) {
      return _notifications.removeAt(existingIndex)['params']
          as Map<String, dynamic>;
    }
    while (true) {
      final changed = _notificationChanged ??= Completer<void>();
      await changed.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException(
          'Timed out waiting for LSP notification $method. '
          'stderr: $_stderrOutput',
        ),
      );
      final matchingIndex = _notifications.indexWhere(
        (message) =>
            message['method'] == method &&
            message['params'] is Map<String, dynamic> &&
            where(message['params'] as Map<String, dynamic>),
      );
      if (matchingIndex >= 0) {
        return _notifications.removeAt(matchingIndex)['params']
            as Map<String, dynamic>;
      }
    }
  }

  Future<void> shutdown() async {
    await request('shutdown', const {});
    await notify('exit', const {});
    await process.stdin.close();
    final code = await process.exitCode.timeout(const Duration(seconds: 20));
    if (code != 0) {
      throw StateError('LSP process exited with code $code: $_stderrOutput');
    }
  }

  Future<void> dispose() async {
    final exitCode = process.exitCode;
    if (!await _hasExited(exitCode)) {
      process.kill();
      await exitCode.timeout(const Duration(seconds: 20));
    }
    await _messageSubscription.cancel();
    await _stderrSubscription.cancel();
    await _chunks.cancel();
  }

  Future<bool> _hasExited(Future<int> exitCode) async {
    try {
      await exitCode.timeout(const Duration(milliseconds: 1));
      return true;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> _send(Map<String, Object?> message) async {
    final body = utf8.encode(jsonEncode(message));
    process.stdin
      ..add(ascii.encode('Content-Length: ${body.length}\r\n\r\n'))
      ..add(body);
    await process.stdin.flush();
  }

  Stream<Map<String, dynamic>> _readMessages() async* {
    while (await _chunks.moveNext()) {
      _buffer.addAll(_chunks.current);
      while (true) {
        final headerEnd = _findHeaderEnd();
        if (headerEnd < 0) break;
        final headers = ascii.decode(_buffer.sublist(0, headerEnd));
        final contentLength = int.parse(
          headers
              .split('\r\n')
              .singleWhere(
                (header) => header.toLowerCase().startsWith('content-length:'),
              )
              .split(':')
              .last
              .trim(),
        );
        final bodyStart = headerEnd + 4;
        final messageEnd = bodyStart + contentLength;
        if (_buffer.length < messageEnd) break;
        final body = _buffer.sublist(bodyStart, messageEnd);
        _buffer.removeRange(0, messageEnd);
        yield (jsonDecode(utf8.decode(body)) as Map).cast<String, dynamic>();
      }
    }
  }

  int _findHeaderEnd() {
    for (var index = 0; index <= _buffer.length - 4; index++) {
      if (_buffer[index] == 13 &&
          _buffer[index + 1] == 10 &&
          _buffer[index + 2] == 13 &&
          _buffer[index + 3] == 10) {
        return index;
      }
    }
    return -1;
  }
}
