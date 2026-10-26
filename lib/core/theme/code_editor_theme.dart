import 'package:flutter/material.dart';
import 'arabic_ide_theme.dart';

@immutable
class CodeEditorTheme {
  const CodeEditorTheme({
    required this.background,
    required this.foreground,
    required this.lineNumber,
    required this.selection,
    required this.cursor,
    required this.keyword,
    required this.string,
    required this.number,
    required this.comment,
    required this.function,
    required this.type,
    required this.operator,
    required this.errorLine,
    required this.matchedBracket,
    required this.foldGutter,
    this.borderRadius = 12,
  });

  final Color background;
  final Color foreground;
  final Color lineNumber;
  final Color selection;
  final Color cursor;
  final Color keyword;
  final Color string;
  final Color number;
  final Color comment;
  final Color function;
  final Color type;
  final Color operator;
  final Color errorLine;
  final Color matchedBracket;
  final Color foldGutter;
  final double borderRadius;

  static CodeEditorTheme of(BuildContext context) {
    final theme = Theme.of(context);
    final syntaxColors = theme.extension<ArabicIdeSyntaxColors>();
    if (syntaxColors != null) {
      return CodeEditorTheme(
        background: theme.brightness == Brightness.dark
            ? const Color(0xFF1E232A)
            : theme.colorScheme.surfaceContainerLow,
        foreground: theme.colorScheme.onSurface,
        lineNumber: const Color(0xFF5C697D),
        selection: const Color(0x33478CBF),
        cursor: const Color(0xFF91CDFF),
        keyword: syntaxColors.keyword,
        string: syntaxColors.string,
        number: syntaxColors.target,
        comment: syntaxColors.comment,
        function: syntaxColors.builtIn,
        type: syntaxColors.builtIn,
        operator: theme.colorScheme.onSurface,
        errorLine: const Color(0x44FF6B6B),
        matchedBracket: const Color(0x55478CBF),
        foldGutter: const Color(0xFF5C697D),
        borderRadius: 4,
      );
    }
    final brightness = theme.brightness;
    return brightness == Brightness.dark
        ? const CodeEditorTheme(
            background: Color(0xFF161B22),
            foreground: Color(0xFFE6EDF3),
            lineNumber: Color(0xFF8B949E),
            selection: Color(0x33478CBF),
            cursor: Color(0xFF91CDFF),
            keyword: Color(0xFFC678DD),
            string: Color(0xFF98C379),
            number: Color(0xFFD19A66),
            comment: Color(0xFF5C6370),
            function: Color(0xFF61AFEF),
            type: Color(0xFF91CDFF),
            operator: Color(0xFFE6EDF3),
            errorLine: Color(0x44E06C75),
            matchedBracket: Color(0x55478CBF),
            foldGutter: Color(0xFF8B949E),
          )
        : const CodeEditorTheme(
            background: Color(0xFFF5F8F6),
            foreground: Color(0xFF202923),
            lineNumber: Color(0xFF718078),
            selection: Color(0xFFCDE6DA),
            cursor: Color(0xFF356B5B),
            keyword: Color(0xFF7B1FA2),
            string: Color(0xFF2E7D32),
            number: Color(0xFFB45309),
            comment: Color(0xFF718078),
            function: Color(0xFF00695C),
            type: Color(0xFF1565C0),
            operator: Color(0xFFAD4D1F),
            errorLine: Color(0x33D32F2F),
            matchedBracket: Color(0x4439A886),
            foldGutter: Color(0xFF718078),
          );
  }
}
