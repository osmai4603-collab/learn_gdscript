import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gdscript_engine/gdscript_engine.dart';
import 'package:learn_gdscript/core/theme/arabic_ide_theme.dart';
import 'package:learn_gdscript/core/theme/code_editor_theme.dart';
import 'package:learn_gdscript/core/theme/color_schemes.dart';
import 'package:learn_gdscript/core/theme/theme_data.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/ui/widgets/code_editor/code_editor_widget.dart';
import 'package:learn_gdscript/ui/widgets/code_editor/syntax_highlighter.dart';

void main() {
  test('dark theme uses the Godot developer academy palette', () {
    final colorScheme = AppColorScheme.dark;
    final theme = AppTheme.dark;

    expect(colorScheme.surface, const Color(0xFF0F141B));
    expect(colorScheme.primary, const Color(0xFF91CDFF));
    expect(colorScheme.secondary, const Color(0xFFFFB783));
    expect(colorScheme.tertiary, const Color(0xFF4AE183));
    expect(theme.scaffoldBackgroundColor, colorScheme.surface);
    expect(theme.cardColor, const Color(0xFF171C23));
    expect(theme.textTheme.bodyMedium?.fontFamily, 'IBM Plex Sans');
  });

  test('Arabic IDE theme is separate and uses its own palette', () {
    final theme = ArabicIdeTheme.dark;

    expect(theme.scaffoldBackgroundColor, const Color(0xFF14181D));
    expect(theme.colorScheme.secondary, const Color(0xFFEFC52B));
    expect(theme.colorScheme.tertiary, const Color(0xFF61DF72));
    expect(theme.cardColor, const Color(0xFF282F3B));
    expect(AppTheme.dark.colorScheme.secondary, const Color(0xFFFFB783));
  });

  testWidgets('editor is LTR and accepts code input in Arabic', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const Scaffold(
          body: CodeEditorWidget(initialCode: 'print("Hello")'),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.textDirection, TextDirection.ltr);
    await tester.enterText(find.byType(TextField), 'var score = 10');
    expect(find.text('var score = 10'), findsOneWidget);
  });

  testWidgets('editor accepts rich completion items and applies insert text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: CodeEditorWidget(
            initialCode: 'pri',
            onCompletionItemsRequested: (_, _) async => const [
              CompletionItem(
                label: 'print',
                kind: CompletionKind.function,
                detail: 'Built-in function',
                insertText: 'print()',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pump();
    expect(find.text('Built-in function'), findsOneWidget);

    await tester.tap(find.text('print'));
    await tester.pump();
    final editor = tester.widget<TextField>(find.byType(TextField));
    expect(editor.controller!.text, 'print()');
    expect(editor.controller!.selection.extentOffset, 6);
  });

  testWidgets('editor inserts matching delimiters around the caret', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CodeEditorWidget(initialCode: '')),
      ),
    );
    final field = find.byType(TextField);
    await tester.tap(field);
    await tester.enterText(field, '(');
    await tester.pump();

    final editor = tester.widget<TextField>(field);
    expect(editor.controller!.text, '()');
    expect(editor.controller!.selection.extentOffset, 1);
  });

  testWidgets('editor invokes save from the Ctrl+S shortcut', (tester) async {
    var saveCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodeEditorWidget(
            initialCode: 'print("save")',
            onSave: () async => saveCount++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(saveCount, 1);
  });

  testWidgets('editor restores the selection when switching documents', (
    tester,
  ) async {
    var activeDocument = 'first';
    final selections = <String, TextSelection>{
      'first': const TextSelection.collapsed(offset: 2),
      'second': const TextSelection.collapsed(offset: 4),
    };
    final code = {'first': 'first code', 'second': 'second code'};

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                TextButton(
                  onPressed: () => setState(
                    () => activeDocument = activeDocument == 'first'
                        ? 'second'
                        : 'first',
                  ),
                  child: const Text('Switch document'),
                ),
                Expanded(
                  child: CodeEditorWidget(
                    documentId: activeDocument,
                    initialCode: code[activeDocument]!,
                    initialSelection: selections[activeDocument],
                    onSelectionChanged: (selection) {
                      selections[activeDocument] = selection;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    TextField editor = tester.widget(find.byType(TextField));
    expect(editor.controller!.text, 'first code');
    expect(editor.controller!.selection.extentOffset, 2);

    await tester.tap(find.text('Switch document'));
    await tester.pump();
    editor = tester.widget(find.byType(TextField));
    expect(editor.controller!.text, 'second code');
    expect(editor.controller!.selection.extentOffset, 4);

    await tester.tap(find.text('Switch document'));
    await tester.pump();
    editor = tester.widget(find.byType(TextField));
    expect(editor.controller!.text, 'first code');
    expect(editor.controller!.selection.extentOffset, 2);
  });

  testWidgets('editor theme exposes readable syntax colors in both themes', (
    tester,
  ) async {
    for (final theme in [ThemeData.light(), ThemeData.dark()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) =>
                Text(CodeEditorTheme.of(context).keyword.toString()),
          ),
        ),
      );
      expect(find.byType(Text), findsOneWidget);
    }
  });

  test('syntax highlighter colors GDScript token groups', () {
    final spans = GDScriptSyntaxHighlighter().highlight(
      'var answer = 42 # result',
      const CodeEditorTheme(
        background: Colors.black,
        foreground: Colors.white,
        lineNumber: Colors.grey,
        selection: Colors.blue,
        cursor: Colors.white,
        keyword: Colors.purple,
        string: Colors.green,
        number: Colors.orange,
        comment: Colors.grey,
        function: Colors.teal,
        type: Colors.blue,
        operator: Colors.red,
        errorLine: Colors.red,
        matchedBracket: Colors.cyan,
        foldGutter: Colors.grey,
      ),
    );
    expect(
      spans.where((span) => span.text == 'var').single.style?.color,
      Colors.purple,
    );
    expect(
      spans.where((span) => span.text == '42').single.style?.color,
      Colors.orange,
    );
    expect(
      spans.where((span) => span.text == '# result').single.style?.color,
      Colors.grey,
    );
  });

  test('syntax highlighter marks matching brackets', () {
    const theme = CodeEditorTheme(
      background: Colors.black,
      foreground: Colors.white,
      lineNumber: Colors.grey,
      selection: Colors.blue,
      cursor: Colors.white,
      keyword: Colors.purple,
      string: Colors.green,
      number: Colors.orange,
      comment: Colors.grey,
      function: Colors.teal,
      type: Colors.blue,
      operator: Colors.red,
      errorLine: Colors.red,
      matchedBracket: Colors.cyan,
      foldGutter: Colors.grey,
    );

    final spans = GDScriptSyntaxHighlighter().highlight(
      '()',
      theme,
      engineHighlights: const [],
      matchingBracketOffsets: (0, 1),
    );

    expect(spans.map((span) => span.text), ['(', ')']);
    expect(spans.map((span) => span.style?.backgroundColor), [
      Colors.cyan,
      Colors.cyan,
    ]);
  });
}
