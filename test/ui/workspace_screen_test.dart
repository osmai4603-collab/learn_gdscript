import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:learn_gdscript/data/repositories/workspace_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/logic/services/code_runner_service.dart';
import 'package:learn_gdscript/ui/screens/workspace/workspace_screen.dart';
import 'package:learn_gdscript/ui/widgets/code_editor/code_editor_widget.dart';

void main() {
  testWidgets('desktop loading skeleton fits a short viewport', (tester) async {
    tester.view.physicalSize = const Size(1280, 689);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _WaitingWorkspaceRepository(
      DatabaseHelper(inMemory: true),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WorkspaceScreen(repository: repository),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('empty workspace does not request diagnostics without a file', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WorkspaceScreen(repository: _EmptyWorkspaceRepository()),
      ),
    );
    for (var frame = 0; frame < 8; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('opening a GDScript file uses the shared code editor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final codeRunner = CodeRunnerService();
    addTearDown(codeRunner.dispose);
    final repository = _SingleFileWorkspaceRepository();
    await tester.pumpWidget(
      Provider<CodeRunnerService>.value(
        value: codeRunner,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkspaceScreen(repository: repository),
        ),
      ),
    );
    for (var frame = 0; frame < 8; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    await tester.tap(find.text('main.gd').first);
    await tester.pump();

    expect(find.byType(CodeEditorWidget), findsOneWidget);
    final editor = find.descendant(
      of: find.byType(CodeEditorWidget),
      matching: find.byType(TextField),
    );
    expect(editor, findsOneWidget);
    const updatedCode = 'func run():\n    print("saved")';
    await tester.enterText(editor, updatedCode);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(repository.savedContent, updatedCode);
    expect(tester.takeException(), isNull);
  });
}

class _WaitingWorkspaceRepository extends WorkspaceRepository {
  _WaitingWorkspaceRepository(super.databaseHelper);

  @override
  Future<String?> getRootPath() => Completer<String?>().future;
}

class _EmptyWorkspaceRepository extends WorkspaceRepository {
  _EmptyWorkspaceRepository() : super(DatabaseHelper(inMemory: true));

  @override
  Future<String?> getRootPath() async => '/project';

  @override
  Future<List<WorkspaceFileSnapshot>> loadFiles() async => const [];
}

class _SingleFileWorkspaceRepository extends WorkspaceRepository {
  _SingleFileWorkspaceRepository() : super(DatabaseHelper(inMemory: true));

  String? savedContent;

  final _file = WorkspaceFileSnapshot(
    uri: Uri.file('/project/main.gd').toString(),
    relativePath: 'main.gd',
    content: 'func run():\n    pass',
    modifiedMillis: 0,
  );

  @override
  Future<String?> getRootPath() async => '/project';

  @override
  Future<List<WorkspaceFileSnapshot>> loadFiles() async => [_file];

  @override
  Future<void> saveGDScriptFile(String uri, String content) async {
    savedContent = content;
  }
}
