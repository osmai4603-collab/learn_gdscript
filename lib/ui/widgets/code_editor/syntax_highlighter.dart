import 'package:flutter/material.dart';

import '../../../core/theme/code_editor_theme.dart';

class GDScriptSyntaxHighlighter {
  static final _tokenPattern = RegExp(
    r"""#[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b(?:func|var|const|if|elif|else|for|while|in|return|break|continue|pass|class|extends|match|and|or|not|true|false|null|self|as|is)\b|\b\d+(?:\.\d+)?\b|\b[A-Za-z_]\w*(?=\s*\()|\b(?:int|float|bool|String|Array|Dictionary|Vector2|Vector3|Node|Object)\b|==|!=|<=|>=|[+\-*\/%=<>!]""",
  );

  List<TextSpan> highlight(String code, CodeEditorTheme theme) {
    final spans = <TextSpan>[];
    var offset = 0;
    for (final match in _tokenPattern.allMatches(code)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: code.substring(offset, match.start)));
      }
      final token = match.group(0)!;
      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(color: _colorFor(token, theme)),
        ),
      );
      offset = match.end;
    }
    if (offset < code.length) spans.add(TextSpan(text: code.substring(offset)));
    return spans;
  }

  Color _colorFor(String token, CodeEditorTheme theme) {
    if (token.startsWith('#')) return theme.comment;
    if (token.startsWith('"') || token.startsWith("'")) return theme.string;
    if (RegExp(r'^\d').hasMatch(token)) return theme.number;
    if (RegExp(r'^(int|float|bool|String|Array|Dictionary|Vector2|Vector3|Node|Object)$')
        .hasMatch(token)) {
      return theme.type;
    }
    if (RegExp(r'^(==|!=|<=|>=|[+\-*\/%=<>!])$').hasMatch(token)) {
      return theme.operator;
    }
    if (RegExp(
      r'^(func|var|const|if|elif|else|for|while|in|return|break|continue|pass|class|extends|match|and|or|not|true|false|null|self|as|is)$',
    ).hasMatch(token)) {
      return theme.keyword;
    }
    return theme.function;
  }
}
