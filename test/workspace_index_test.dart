import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/repositories/workspace_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/logic/services/language_server_client.dart';
import 'package:learn_gdscript/logic/services/lsp_transport.dart';
import 'package:learn_gdscript/logic/services/workspace_index_service.dart';

import 'helpers/fake_lsp_transport.dart';

void main() {
  const experimentalCapabilities = {
    'gdscriptUpdateWorkspaceFiles': true,
    'gdscriptSearchWorkspaceText': true,
  };

  test(
    'discovers GDScript files, excludes generated/hidden folders, and refreshes deltas',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'learn-gdscript-workspace-',
      );
      final outside = await Directory.systemTemp.createTemp(
        'learn-gdscript-outside-',
      );
      final database = DatabaseHelper(inMemory: true);
      final repository = WorkspaceRepository(database);
      final transport = FakeLspTransport(
        serverCapabilities: {
          'textDocumentSync': {'openClose': true, 'change': 2},
          'workspace': {
            'workspaceFolders': {'supported': true},
          },
          'experimental': experimentalCapabilities,
        },
      );
      final client = LanguageServerClient(transport);
      await client.initialize();
      final index = WorkspaceIndexService(
        repository: repository,
        client: client,
      );
      addTearDown(() async {
        await index.dispose();
        await client.dispose();
        await database.close();
        await root.delete(recursive: true);
        await outside.delete(recursive: true);
      });

      final script = File('${root.path}/main.gd');
      await script.writeAsString('var value = 1\n');
      await File('${root.path}/notes.txt').writeAsString('ignore me');
      await Directory('${root.path}/.godot').create();
      await File(
        '${root.path}/.godot/cache.gd',
      ).writeAsString('var hidden = true');
      await Directory('${root.path}/build').create();
      await File(
        '${root.path}/build/generated.gd',
      ).writeAsString('var generated = true');
      await Directory('${root.path}/scripts').create();
      final nested = File('${root.path}/scripts/helper.gd');
      await nested.writeAsString('class_name Helper\n');
      await File(
        '${outside.path}/outside.gd',
      ).writeAsString('var outside = true');

      await index.selectWorkspace(root.path);
      expect(await repository.getRootPath(), await root.resolveSymbolicLinks());
      var snapshots = await repository.loadFiles();
      expect(snapshots.map((file) => file.relativePath), [
        'main.gd',
        'scripts/helper.gd',
      ]);
      final firstUpdate = transport.messages.last;
      expect(firstUpdate['method'], 'gdscript/updateWorkspaceFiles');
      final firstParams = firstUpdate['params'] as Map<String, Object?>;
      expect(firstParams['files'], hasLength(2));
      expect(
        transport.messages.any(
          (message) =>
              message['method'] == 'workspace/didChangeWorkspaceFolders',
        ),
        isTrue,
      );

      await script.writeAsString('var value = 2\n');
      final added = File('${root.path}/new.gd');
      await added.writeAsString('var added = true\n');
      await _waitFor(
        'new file creation',
        () async => (await repository.loadFiles()).any(
          (file) => file.relativePath == 'new.gd',
        ),
      );
      await nested.delete();
      await _waitFor(
        'file deletion',
        () async => (await repository.loadFiles()).every(
          (file) => file.relativePath != 'scripts/helper.gd',
        ),
      );
      snapshots = await repository.loadFiles();
      expect(snapshots.map((file) => file.relativePath), ['main.gd', 'new.gd']);
      expect(
        snapshots.singleWhere((file) => file.relativePath == 'main.gd').content,
        'var value = 2\n',
      );
      final delta = transport.messages.last;
      final deltaParams = delta['params'] as Map<String, Object?>;
      expect(deltaParams['files'], isEmpty);
      expect(deltaParams['removedUris'], [nested.uri.toString()]);

      final uri = script.uri;
      await index.openDocument(uri, 'var value = 3\n');
      await index.changeDocument(uri, 'var value = 4\n', version: 2);
      await expectLater(
        index.changeDocument(uri, 'var value = 5\n', version: 2),
        throwsArgumentError,
      );
      await index.refresh();
      snapshots = await repository.loadFiles();
      expect(
        snapshots.singleWhere((file) => file.uri == uri.toString()).content,
        'var value = 4\n',
      );
      await index.saveDocument(uri, text: 'var value = 6\n');
      await script.writeAsString('var value = 6\n');
      await index.closeDocument(uri);
      snapshots = await repository.loadFiles();
      expect(
        snapshots.singleWhere((file) => file.uri == uri.toString()).content,
        'var value = 6\n',
      );

      await index.removeWorkspace();
      expect(await repository.getRootPath(), isNull);
      expect(await repository.loadFiles(), isEmpty);
    },
  );

  test(
    'keeps previous snapshot when server rejects an indexing update',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'learn-gdscript-workspace-',
      );
      final database = DatabaseHelper(inMemory: true);
      final repository = WorkspaceRepository(database);
      final transport = FakeLspTransport(
        serverCapabilities: {
          'workspace': {
            'workspaceFolders': {'supported': true},
          },
          'experimental': experimentalCapabilities,
        },
      );
      final client = LanguageServerClient(transport);
      await client.initialize();
      final index = WorkspaceIndexService(
        repository: repository,
        client: client,
      );
      addTearDown(() async {
        await index.dispose();
        await client.dispose();
        await database.close();
        await root.delete(recursive: true);
      });
      await File('${root.path}/main.gd').writeAsString('var value = 1\n');

      transport.errorMethod = 'gdscript/updateWorkspaceFiles';
      await expectLater(
        index.selectWorkspace(root.path),
        throwsA(isA<LspRpcException>()),
      );
      expect(await repository.getRootPath(), isNull);
      expect(await repository.loadFiles(), isEmpty);
    },
  );

  test('re-sends a full snapshot when the language server restarts', () async {
    final root = await Directory.systemTemp.createTemp(
      'learn-gdscript-workspace-',
    );
    final database = DatabaseHelper(inMemory: true);
    final repository = WorkspaceRepository(database);
    final transport = FakeLspTransport(
      serverCapabilities: {
        'workspace': {
          'workspaceFolders': {'supported': true},
        },
        'experimental': experimentalCapabilities,
      },
    );
    final client = LanguageServerClient(transport);
    await client.initialize();
    final index = WorkspaceIndexService(
      repository: repository,
      client: client,
    );
    addTearDown(() async {
      await index.dispose();
      await client.dispose();
      await database.close();
      await root.delete(recursive: true);
    });

    await File('${root.path}/main.gd').writeAsString('var main = true\n');
    await File('${root.path}/helper.gd').writeAsString('var helper = true\n');
    await index.selectWorkspace(root.path);
    final previous = await repository.loadFiles();
    transport.messages.clear();
    transport.errorMethod = 'gdscript/updateWorkspaceFiles';

    await expectLater(
      index.synchronizeWorkspace(),
      throwsA(isA<LspRpcException>()),
    );
    final retained = await repository.loadFiles();
    expect(retained.map((file) => file.uri), previous.map((file) => file.uri));
    expect(
      retained.map((file) => file.content),
      previous.map((file) => file.content),
    );

    transport.errorMethod = null;
    await index.synchronizeWorkspace();
    final folderChange = transport.messages.firstWhere(
      (message) => message['method'] == 'workspace/didChangeWorkspaceFolders',
    );
    final folderParams = folderChange['params'] as Map<String, Object?>;
    final folderEvent = folderParams['event'] as Map<String, Object?>;
    expect(folderEvent['added'], hasLength(1));

    final update = transport.messages.lastWhere(
      (message) => message['method'] == 'gdscript/updateWorkspaceFiles',
    );
    final updateParams = update['params'] as Map<String, Object?>;
    expect(updateParams['files'], hasLength(2));
    expect(updateParams['removedUris'], isEmpty);
  });

  test('rejects oversized and invalid UTF-8 workspace files', () async {
    final root = await Directory.systemTemp.createTemp(
      'learn-gdscript-workspace-',
    );
    addTearDown(() => root.delete(recursive: true));
    await File('${root.path}/large.gd').writeAsString('x' * (1024 * 1024 + 1));
    await expectLater(
      const IoWorkspaceFileSystem().discover(root.path),
      throwsA(isA<WorkspaceIndexException>()),
    );

    await File('${root.path}/large.gd').delete();
    await File('${root.path}/invalid.gd').writeAsBytes([0xFF, 0xFE]);
    await expectLater(
      const IoWorkspaceFileSystem().discover(root.path),
      throwsA(isA<WorkspaceIndexException>()),
    );
  });
}

Future<void> _waitFor(
  String description,
  Future<bool> Function() condition,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!await condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Workspace index did not observe $description.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}
