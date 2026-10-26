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
    List<Diagnostic> diagnostics = const [],
    (int, int)? matchingBracketOffsets,
    Color? errorColor,
    Color? warningColor,
  }) {
    final diagnosticLines = _diagnosticLines(code, diagnostics);
    final resolvedErrorColor = errorColor ?? theme.errorLine;
    final resolvedWarningColor = warningColor ?? theme.achievement;
    if (engineHighlights != null) {
      return _highlightEngineTokens(
        code,
        theme,
        engineHighlights,
        semanticHighlights ?? const [],
        diagnostics,
        diagnosticLines,
        matchingBracketOffsets,
        resolvedErrorColor,
        resolvedWarningColor,
      );
    }
    final spans = <TextSpan>[];
    var offset = 0;
    for (final match in _tokenPattern.allMatches(code)) {
      if (match.start > offset) {
        spans.addAll(
          _decorateRange(
            code,
            offset,
            match.start,
            null,
            diagnostics,
            diagnosticLines,
            resolvedErrorColor,
            resolvedWarningColor,
          ),
        );
      }
      final token = match.group(0)!;
      spans.addAll(
        _decorateRange(
          code,
          match.start,
          match.end,
          TextStyle(color: _colorFor(token, theme)),
          diagnostics,
          diagnosticLines,
          resolvedErrorColor,
          resolvedWarningColor,
        ),
      );
      offset = match.end;
    }
    if (offset < code.length) {
      spans.addAll(
        _decorateRange(
          code,
          offset,
          code.length,
          null,
          diagnostics,
          diagnosticLines,
          resolvedErrorColor,
          resolvedWarningColor,
        ),
      );
    }
    return spans;
  }

  List<TextSpan> _highlightEngineTokens(
    String code,
    CodeEditorTheme theme,
    List<SyntaxHighlight> highlights,
    List<SemanticHighlight> semanticHighlights,
    List<Diagnostic> diagnostics,
    List<_DiagnosticLineRange> diagnosticLines,
    (int, int)? matchingBracketOffsets,
    Color errorColor,
    Color warningColor,
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
    for (final diagnostic in diagnostics) {
      boundaries
        ..add(diagnostic.location.offset.clamp(0, code.length).toInt())
        ..add(
          (diagnostic.location.offset + diagnostic.location.length)
              .clamp(0, code.length)
              .toInt(),
        );
    }
    for (final range in diagnosticLines) {
      boundaries
        ..add(range.start)
        ..add(range.end);
    }
    if (matchingBracketOffsets != null) {
      for (final offset
          in matchingBracketOffsets.$1 == matchingBracketOffsets.$2
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
      spans.addAll(
        _decorateRange(
          code,
          start,
          end,
          color == null && !isMatchedBracket
              ? null
              : TextStyle(
                  color: color,
                  backgroundColor: isMatchedBracket
                      ? theme.matchedBracket
                      : null,
                ),
          diagnostics,
          diagnosticLines,
          errorColor,
          warningColor,
        ),
      );
    }
    return spans;
  }

  List<TextSpan> _decorateRange(
    String code,
    int start,
    int end,
    TextStyle? baseStyle,
    List<Diagnostic> diagnostics,
    List<_DiagnosticLineRange> diagnosticLines,
    Color errorColor,
    Color warningColor,
  ) {
    final boundaries = <int>{start, end};
    for (final diagnostic in diagnostics) {
      final diagnosticStart = diagnostic.location.offset
          .clamp(start, end)
          .toInt();
      final diagnosticEnd =
          (diagnostic.location.offset + diagnostic.location.length)
              .clamp(start, end)
              .toInt();
      if (diagnosticStart > start && diagnosticStart < end) {
        boundaries.add(diagnosticStart);
      }
      if (diagnosticEnd > start && diagnosticEnd < end) {
        boundaries.add(diagnosticEnd);
      }
    }
    for (final range in diagnosticLines) {
      if (range.start > start && range.start < end) boundaries.add(range.start);
      if (range.end > start && range.end < end) boundaries.add(range.end);
    }

    final offsets = boundaries.toList()..sort();
    final spans = <TextSpan>[];
    for (var index = 0; index < offsets.length - 1; index++) {
      final sliceStart = offsets[index];
      final sliceEnd = offsets[index + 1];
      if (sliceStart >= sliceEnd) continue;

      Diagnostic? activeDiagnostic;
      for (final diagnostic in diagnostics) {
        final diagnosticStart = diagnostic.location.offset;
        final diagnosticEnd = diagnosticStart + diagnostic.location.length;
        if (diagnosticStart < sliceEnd && diagnosticEnd > sliceStart) {
          if (activeDiagnostic == null ||
              (diagnostic.severity == DiagnosticSeverity.error &&
                  activeDiagnostic.severity != DiagnosticSeverity.error)) {
            activeDiagnostic = diagnostic;
          }
        }
      }
      final coveringRanges = diagnosticLines.where(
        (range) => range.start <= sliceStart && sliceEnd <= range.end,
      );
      final hasErrorLine = coveringRanges.any((range) => range.isError);
      final hasWarningLine =
          !hasErrorLine && coveringRanges.any((range) => !range.isError);
      final isError = activeDiagnostic?.severity == DiagnosticSeverity.error;
      final isWarning =
          activeDiagnostic?.severity == DiagnosticSeverity.warning;
      final decorationColor = isError
          ? errorColor
          : isWarning
          ? warningColor
          : null;
      final lineBackground = hasErrorLine
          ? errorColor.withValues(alpha: 0.2)
          : hasWarningLine
          ? warningColor.withValues(alpha: 0.14)
          : null;
      final style =
          (baseStyle ??
                  (decorationColor != null || lineBackground != null
                      ? const TextStyle()
                      : null))
              ?.copyWith(
                backgroundColor: baseStyle?.backgroundColor ?? lineBackground,
                decoration: decorationColor == null
                    ? baseStyle?.decoration
                    : TextDecoration.underline,
                decorationColor: decorationColor ?? baseStyle?.decorationColor,
                decorationStyle: decorationColor == null
                    ? baseStyle?.decorationStyle
                    : TextDecorationStyle.wavy,
              );
      spans.add(
        TextSpan(
          text: code.substring(sliceStart, sliceEnd),
          style: style == null && lineBackground == null
              ? null
              : (style ?? const TextStyle()).copyWith(
                  backgroundColor: style?.backgroundColor ?? lineBackground,
                ),
        ),
      );
    }
    return spans;
  }

  List<_DiagnosticLineRange> _diagnosticLines(
    String code,
    List<Diagnostic> diagnostics,
  ) {
    if (diagnostics.isEmpty || code.isEmpty) return const [];
    final severities = <int, bool>{};
    for (final diagnostic in diagnostics) {
      if (diagnostic.severity != DiagnosticSeverity.error &&
          diagnostic.severity != DiagnosticSeverity.warning) {
        continue;
      }
      final endOffset =
          (diagnostic.location.offset + diagnostic.location.length)
              .clamp(0, code.length)
              .toInt();
      final endLine = _lineAtOffset(code, endOffset);
      for (var line = diagnostic.location.line; line <= endLine; line++) {
        if (diagnostic.severity == DiagnosticSeverity.error ||
            !severities.containsKey(line)) {
          severities[line] = diagnostic.severity == DiagnosticSeverity.error;
        }
      }
    }

    final ranges = <_DiagnosticLineRange>[];
    var offset = 0;
    final lines = code.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final isError = severities[index + 1];
      final length = lines[index].length;
      if (isError != null && length > 0) {
        ranges.add(_DiagnosticLineRange(offset, offset + length, isError));
      }
      offset += length + 1;
    }
    return ranges;
  }

  int _lineAtOffset(String code, int offset) {
    var line = 1;
    for (var index = 0; index < offset; index++) {
      if (code.codeUnitAt(index) == 0x0A) line++;
    }
    return line;
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

class _DiagnosticLineRange {
  const _DiagnosticLineRange(this.start, this.end, this.isError);

  final int start;
  final int end;
  final bool isError;
}
