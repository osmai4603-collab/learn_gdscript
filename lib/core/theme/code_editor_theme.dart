import 'package:flutter/material.dart';

@immutable
class CodeEditorTheme {
  const CodeEditorTheme({
    required this.background,
    required this.foreground,
    required this.lineNumber,
    required this.selection,
    required this.cursor,
  });

  final Color background;
  final Color foreground;
  final Color lineNumber;
  final Color selection;
  final Color cursor;

  static CodeEditorTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const CodeEditorTheme(
            background: Color(0xFF171B1A),
            foreground: Color(0xFFE2E8E5),
            lineNumber: Color(0xFF87948E),
            selection: Color(0xFF315C4F),
            cursor: Color(0xFF9DE0C4),
          )
        : const CodeEditorTheme(
            background: Color(0xFFF5F8F6),
            foreground: Color(0xFF202923),
            lineNumber: Color(0xFF718078),
            selection: Color(0xFFCDE6DA),
            cursor: Color(0xFF356B5B),
          );
  }
}
