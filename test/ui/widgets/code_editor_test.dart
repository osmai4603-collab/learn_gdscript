import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
