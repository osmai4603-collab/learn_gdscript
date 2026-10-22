import 'package:flutter/material.dart';

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

  static CodeEditorTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const CodeEditorTheme(
            background: Color(0xFF171B1A),
            foreground: Color(0xFFE2E8E5),
            lineNumber: Color(0xFF87948E),
            selection: Color(0xFF315C4F),
            cursor: Color(0xFF9DE0C4),
            keyword: Color(0xFFCE93D8),
            string: Color(0xFFA5D6A7),
            number: Color(0xFFFFCC80),
            comment: Color(0xFF82938B),
            function: Color(0xFF80CBC4),
            type: Color(0xFF90CAF9),
            operator: Color(0xFFFFAB91),
            errorLine: Color(0x44EF5350),
            matchedBracket: Color(0x5539A886),
            foldGutter: Color(0xFF87948E),
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
