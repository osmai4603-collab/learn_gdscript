import 'package:flutter/material.dart';
import 'package:gdscript_engine/gdscript_engine.dart';

import '../../../core/theme/editor_theme_extension.dart';

class GDScriptSyntaxHighlighter {
  static final _tokenPattern = RegExp(
    r"""#[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b(?:func|var|const|if|elif|else|for|while|in|return|break|continue|pass|class|extends|match|and|or|not|true|false|null|self|as|is)\b|\b\d+(?:\.\d+)?\b|\b[A-Za-z_]\w*(?=\s*\()|\b(?:int|float|bool|String|Array|Dictionary|Vector2|Vector3|Node|Object)\b|==|!=|<=|>=|[+\-*\/%=<>!]""",
  );

  List<TextSpan> highlight(
    String code,
    CodeEditorTheme theme, {
    List<SyntaxHighlight>? engineHighlights,
    List<SemanticHighlight>? semanticHighlights,
    (int, int)? matchingBracketOffsets,
  }) {
    if (engineHighlights != null) {
      return _highlightEngineTokens(
        code,
        theme,
        engineHighlights,
        semanticHighlights ?? const [],
        matchingBracketOffsets,
      );
    }
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

  List<TextSpan> _highlightEngineTokens(
    String code,
    CodeEditorTheme theme,
    List<SyntaxHighlight> highlights,
    List<SemanticHighlight> semanticHighlights,
    (int, int)? matchingBracketOffsets,
  ) {
    final orderedSyntax = highlights.toList()
      ..sort((a, b) => a.offset.compareTo(b.offset));
    final orderedSemantic = semanticHighlights.toList()
      ..sort((a, b) => a.offset.compareTo(b.offset));
    final boundaries = <int>{0, code.length};
    for (final highlight in orderedSyntax) {
      boundaries
        ..add(highlight.offset.clamp(0, code.length).toInt())
        ..add(
          (highlight.offset + highlight.length).clamp(0, code.length).toInt(),
        );
    }
    for (final highlight in orderedSemantic) {
      boundaries
        ..add(highlight.offset.clamp(0, code.length).toInt())
        ..add(
          (highlight.offset + highlight.length).clamp(0, code.length).toInt(),
        );
    }
    if (matchingBracketOffsets != null) {
        for (final offset in matchingBracketOffsets.$1 ==
                matchingBracketOffsets.$2
            ? [matchingBracketOffsets.$1]
            : [matchingBracketOffsets.$1, matchingBracketOffsets.$2]) {
          boundaries
            ..add(offset.clamp(0, code.length).toInt())
            ..add((offset + 1).clamp(0, code.length).toInt());
        }
    }
    final offsets = boundaries.toList()..sort();
    final spans = <TextSpan>[];
    var syntaxIndex = 0;
    var semanticIndex = 0;
    for (var index = 0; index < offsets.length - 1; index++) {
      final start = offsets[index];
      final end = offsets[index + 1];
      if (start == end) continue;
      while (syntaxIndex < orderedSyntax.length &&
          orderedSyntax[syntaxIndex].offset +
                  orderedSyntax[syntaxIndex].length <=
              start) {
        syntaxIndex++;
      }
      while (semanticIndex < orderedSemantic.length &&
          orderedSemantic[semanticIndex].offset +
                  orderedSemantic[semanticIndex].length <=
              start) {
        semanticIndex++;
      }
      final syntax =
          syntaxIndex < orderedSyntax.length &&
              orderedSyntax[syntaxIndex].offset <= start &&
              orderedSyntax[syntaxIndex].offset +
                      orderedSyntax[syntaxIndex].length >=
                  end
          ? orderedSyntax[syntaxIndex]
          : null;
      final semantic =
          semanticIndex < orderedSemantic.length &&
              orderedSemantic[semanticIndex].offset <= start &&
              orderedSemantic[semanticIndex].offset +
                      orderedSemantic[semanticIndex].length >=
                  end
          ? orderedSemantic[semanticIndex]
          : null;
      final color = semantic == null
          ? syntax == null
                ? null
                : _colorForEngineKind(syntax.kind, theme)
          : _colorForSemanticKind(semantic.kind, theme);
      final isMatchedBracket =
          matchingBracketOffsets != null &&
          (start == matchingBracketOffsets.$1 ||
              start == matchingBracketOffsets.$2);
      spans.add(
        TextSpan(
          text: code.substring(start, end),
          style: color == null && !isMatchedBracket
              ? null
              : TextStyle(
                  color: color,
                  backgroundColor: isMatchedBracket
                      ? theme.matchedBracket
                      : null,
                ),
        ),
      );
    }
    return spans;
  }

  Color _colorForSemanticKind(String kind, CodeEditorTheme theme) =>
      switch (kind) {
        'class' || 'enum' => theme.type,
        'function' || 'method' || 'signal' => theme.function,
        'parameter' || 'variable' || 'property' => theme.foreground,
        _ => theme.foreground,
      };

  Color _colorForEngineKind(HighlightKind kind, CodeEditorTheme theme) =>
      switch (kind) {
        HighlightKind.keyword ||
        HighlightKind.controlFlow ||
        HighlightKind.annotation => theme.keyword,
        HighlightKind.string || HighlightKind.nodePath => theme.string,
        HighlightKind.number => theme.number,
        HighlightKind.comment => theme.comment,
        HighlightKind.type ||
        HighlightKind.classKind ||
        HighlightKind.constant => theme.type,
        HighlightKind.function ||
        HighlightKind.builtinFunction ||
        HighlightKind.signal => theme.function,
        HighlightKind.operator || HighlightKind.punctuation => theme.operator,
        HighlightKind.identifier ||
        HighlightKind.variable ||
        HighlightKind.property => theme.foreground,
      };

  Color _colorFor(String token, CodeEditorTheme theme) {
    if (token.startsWith('#')) return theme.comment;
    if (token.startsWith('"') || token.startsWith("'")) return theme.string;
    if (RegExp(r'^\d').hasMatch(token)) return theme.number;
    if (RegExp(
      r'^(int|float|bool|String|Array|Dictionary|Vector2|Vector3|Node|Object)$',
    ).hasMatch(token)) {
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
