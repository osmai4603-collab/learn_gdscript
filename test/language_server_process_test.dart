import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/logic/services/language_server_client.dart';

void main() {
  test(
    'runs the typed client against gdscript_lsp through initialize to exit',
    () async {
      final serverDirectory = _serverDirectory();
      if (serverDirectory == null) {
        markTestSkipped(
          'Set GDSCRIPT_LSP_PATH or place gdscript_lsp beside this project.',
        );
      }
      final workspace = await Directory.systemTemp.createTemp(
        'learn-gdscript-client-',
      );
      addTearDown(() => workspace.delete(recursive: true));
      final client = await LanguageServerClient.start(
        executablePath: _dartExecutable(),
        arguments: ['run', 'bin/gdscript_lsp.dart', '--log-level=off'],
        workingDirectory: serverDirectory!.path,
      );
      addTearDown(client.dispose);

      final capabilities = await client.initialize(
        rootUri: workspace.uri,
        workspaceFolders: [workspace.uri],
      );
      expect(capabilities['completionProvider'], isNotNull);
      expect(capabilities['semanticTokensProvider'], isNotNull);
      expect(capabilities['experimental'], {
        'gdscriptUpdateWorkspaceFiles': true,
        'gdscriptSearchWorkspaceText': true,
      });

      final uri = Uri.file('${workspace.path}/main.gd');
      final diagnostics = client.notifications
          .where(
            (notification) =>
                notification.method == 'textDocument/publishDiagnostics' &&
                notification.params['uri'] == uri.toString(),
          )
          .first
          .timeout(const Duration(seconds: 20));
      await client.openDocument(uri, 'class_name Main\nfunc run():\n    pri\n');
      await diagnostics;

      final completion = await client.complete(uri, 2, 7);
      final items = completion is List
          ? completion
          : (completion as Map<String, Object?>)['items'] as List<Object?>;
      expect(items, isNotEmpty);

      final indexedUri = Uri.file('${workspace.path}/indexed.gd');
      await client.updateWorkspaceFiles(
        files: [
          {
            'uri': indexedUri.toString(),
            'text': 'var workspace_index_marker = true\n',
          },
        ],
        removedUris: const [],
      );
      final searchResults = await client.searchWorkspace(
        'workspace_index_marker',
      );
      expect(searchResults, isA<List<Object?>>());
      expect(
        (searchResults! as List<Object?>).single,
        containsPair('uri', indexedUri.toString()),
      );

      await client.updateWorkspaceFiles(
        files: const [],
        removedUris: [indexedUri.toString()],
      );
      expect(await client.searchWorkspace('workspace_index_marker'), isEmpty);

      await client.updateWorkspaceFiles(
        files: [
          {
            'uri': indexedUri.toString(),
            'text': 'var workspace_index_marker = true\n',
          },
        ],
        removedUris: const [],
      );
      await client.changeWorkspaceFolders(
        added: const [],
        removed: [workspace.uri],
      );
      expect(await client.searchWorkspace('workspace_index_marker'), isEmpty);

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
      '$flutterRoot/bin/cache/dart-sdk/bin/dart'
      '${Platform.isWindows ? '.exe' : ''}',
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
