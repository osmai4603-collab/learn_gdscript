import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gdscript_engine/gdscript_engine.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/ui/widgets/code_editor/code_editor_widget.dart';
import 'package:learn_gdscript/ui/widgets/code_editor/syntax_highlighter.dart';

void main() {
  test('error and warning diagnostics color spans and their source lines', () {
    const code = 'var broken = 1\nvar unsure = 2';
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
      success: Colors.green,
      achievement: Colors.orange,
    );
    final source = Source.memory(code);
    final diagnostics = [
      Diagnostic.error(
        'Invalid expression',
        SourceLocation.fromOffsets(source, 4, 6),
      ),
      Diagnostic.warning(
        'Suspicious value',
        SourceLocation.fromOffsets(source, 19, 6),
      ),
    ];

    for (final engineHighlights in <List<SyntaxHighlight>?>[null, const []]) {
      final spans = GDScriptSyntaxHighlighter().highlight(
        code,
        theme,
        engineHighlights: engineHighlights,
        diagnostics: diagnostics,
        errorColor: Colors.red,
        warningColor: Colors.orange,
      );

      final errorSpan = spans.singleWhere((span) => span.text == 'broken');
      expect(errorSpan.style?.decorationColor, Colors.red);
      expect(errorSpan.style?.decorationStyle, TextDecorationStyle.wavy);
      expect(
        errorSpan.style?.backgroundColor,
        Colors.red.withValues(alpha: 0.2),
      );

      final warningSpan = spans.singleWhere((span) => span.text == 'unsure');
      expect(warningSpan.style?.decorationColor, Colors.orange);
      expect(warningSpan.style?.decorationStyle, TextDecorationStyle.wavy);
      expect(
        warningSpan.style?.backgroundColor,
        Colors.orange.withValues(alpha: 0.14),
      );
    }
  });

  testWidgets('editor refreshes its text spans when diagnostics arrive', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.linux),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: CodeEditorWidget(
              initialCode: 'var broken = 1\nvar unsure = 3',
              onDiagnosticsRequested: (code) {
                final source = Source.memory(code);
                return [
                  Diagnostic.error(
                    'Invalid expression',
                    SourceLocation.fromOffsets(source, 4, 6),
                  ),
                  Diagnostic.warning(
                    'Suspicious value',
                    SourceLocation.fromOffsets(source, 19, 6),
                  ),
                ];
              },
            ),
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    var controllerNotifications = 0;
    field.controller!.addListener(() => controllerNotifications++);
    await tester.enterText(
      find.byType(TextField),
      'var broken = 2\nvar unsure = 3',
    );
    controllerNotifications = 0;
    await tester.pump(const Duration(milliseconds: 300));

    expect(controllerNotifications, greaterThan(0));
    final textSpan = field.controller!.buildTextSpan(
      context: tester.element(find.byType(TextField)),
      style: field.style,
      withComposing: false,
    );
    final errorSpan = _textSpans(
      textSpan,
    ).singleWhere((span) => span.toPlainText() == 'broken');
    expect(errorSpan.style?.decorationStyle, TextDecorationStyle.wavy);
    expect(
      find.byKey(const ValueKey('inline-diagnostic-line-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('inline-diagnostic-line-2')),
      findsOneWidget,
    );
    expect(find.text('Invalid expression'), findsWidgets);
    expect(find.text('Suspicious value'), findsWidgets);
    expect(find.text('var broken = 2\nvar unsure = 3'), findsOneWidget);
    expect(field.controller!.text, 'var broken = 2\nvar unsure = 3');

    final diagnosticFinder = find.byKey(
      const ValueKey('inline-diagnostic-line-1'),
    );
    expect(
      find.descendant(
        of: diagnosticFinder,
        matching: find.byTooltip('Invalid expression'),
      ),
      findsOneWidget,
    );
  });
}

Iterable<TextSpan> _textSpans(InlineSpan span) sync* {
  if (span is! TextSpan) return;
  yield span;
  for (final child in span.children ?? const <InlineSpan>[]) {
    yield* _textSpans(child);
  }
}
