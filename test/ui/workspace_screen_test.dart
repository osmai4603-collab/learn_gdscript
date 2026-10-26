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
    const updatedCode = 'print("saved")';
    await tester.enterText(editor, updatedCode);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(repository.savedContent, updatedCode);

    final resizeHandle = find.byKey(
      const ValueKey('workspace-dock-resize-handle'),
    );
    expect(resizeHandle, findsOneWidget);
    final initialHandleY = tester.getTopLeft(resizeHandle).dy;
    await tester.drag(resizeHandle, const Offset(0, -40));
    await tester.pump();
    expect(tester.getTopLeft(resizeHandle).dy, lessThan(initialHandleY - 25));

    await tester.tap(find.byIcon(Icons.play_arrow));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(find.text('saved'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pump();
    expect(find.text('saved'), findsNothing);

    await tester.enterText(editor, 'var value: =');
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('inline-diagnostic-line-1')),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.play_arrow));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    final errorOutputs = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .where((entry) => entry.data!.contains('ERROR'))
        .toList();
    expect(errorOutputs, isNotEmpty);
    expect(
      errorOutputs.every(
        (entry) =>
            entry.style?.color ==
            Theme.of(
              tester.element(find.byType(Scaffold).last),
            ).colorScheme.error,
      ),
      isTrue,
    );

    await tester.tap(find.text('Problems'));
    await tester.pump();
    expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);

    await tester.enterText(editor, 'func run():\n    var unused = 1\n    pass');
    await tester.pump(const Duration(milliseconds: 300));
    final warningAnnotation = find.byKey(
      const ValueKey('inline-diagnostic-line-2'),
    );
    expect(warningAnnotation, findsOneWidget);
    final warningText = tester.widget<Text>(
      find.descendant(of: warningAnnotation, matching: find.byType(Text)),
    );
    expect(
      warningText.style?.color,
      Theme.of(
        tester.element(find.byType(Scaffold).last),
      ).colorScheme.secondary,
    );
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
