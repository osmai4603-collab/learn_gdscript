import 'package:flutter/material.dart';

@immutable
class CodeEditorTheme extends ThemeExtension<CodeEditorTheme> {
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
    required this.success,
    required this.achievement,
    this.borderRadius = 4,
  });

  static const codeFontFamily = 'JetBrains Mono';

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
  @override
  final Color type;
  final Color operator;
  final Color errorLine;
  final Color matchedBracket;
  final Color foldGutter;
  final Color success;
  final Color achievement;
  final double borderRadius;

  static CodeEditorTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CodeEditorTheme>() ??
        CodeEditorTheme.fromColorScheme(theme.colorScheme);
  }

  factory CodeEditorTheme.fromColorScheme(ColorScheme colorScheme) {
    final muted = colorScheme.onSurfaceVariant;
    final foreground = colorScheme.onSurface;
    return CodeEditorTheme(
      background: colorScheme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerLowest
          : colorScheme.surfaceContainerLow,
      foreground: foreground,
      lineNumber: muted,
      selection: colorScheme.primary.withValues(alpha: 0.2),
      cursor: colorScheme.primary,
      keyword: colorScheme.primary,
      string: colorScheme.tertiary,
      number: colorScheme.secondary,
      comment: muted,
      function: colorScheme.primary,
      type: colorScheme.tertiary,
      operator: foreground,
      errorLine: colorScheme.error.withValues(alpha: 0.2),
      matchedBracket: colorScheme.primary.withValues(alpha: 0.33),
      foldGutter: muted,
      success: colorScheme.tertiary,
      achievement: colorScheme.secondary,
    );
  }

  @override
  CodeEditorTheme copyWith({
    Color? background,
    Color? foreground,
    Color? lineNumber,
    Color? selection,
    Color? cursor,
    Color? keyword,
    Color? string,
    Color? number,
    Color? comment,
    Color? function,
    Color? type,
    Color? operator,
    Color? errorLine,
    Color? matchedBracket,
    Color? foldGutter,
    Color? success,
    Color? achievement,
    double? borderRadius,
  }) {
    return CodeEditorTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      lineNumber: lineNumber ?? this.lineNumber,
      selection: selection ?? this.selection,
      cursor: cursor ?? this.cursor,
      keyword: keyword ?? this.keyword,
      string: string ?? this.string,
      number: number ?? this.number,
      comment: comment ?? this.comment,
      function: function ?? this.function,
      type: type ?? this.type,
      operator: operator ?? this.operator,
      errorLine: errorLine ?? this.errorLine,
      matchedBracket: matchedBracket ?? this.matchedBracket,
      foldGutter: foldGutter ?? this.foldGutter,
      success: success ?? this.success,
      achievement: achievement ?? this.achievement,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  CodeEditorTheme lerp(
    covariant ThemeExtension<CodeEditorTheme>? other,
    double t,
  ) {
    if (other is! CodeEditorTheme) return this;

    return CodeEditorTheme(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      lineNumber: Color.lerp(lineNumber, other.lineNumber, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      cursor: Color.lerp(cursor, other.cursor, t)!,
      keyword: Color.lerp(keyword, other.keyword, t)!,
      string: Color.lerp(string, other.string, t)!,
      number: Color.lerp(number, other.number, t)!,
      comment: Color.lerp(comment, other.comment, t)!,
      function: Color.lerp(function, other.function, t)!,
      type: Color.lerp(type, other.type, t)!,
      operator: Color.lerp(operator, other.operator, t)!,
      errorLine: Color.lerp(errorLine, other.errorLine, t)!,
      matchedBracket: Color.lerp(matchedBracket, other.matchedBracket, t)!,
      foldGutter: Color.lerp(foldGutter, other.foldGutter, t)!,
      success: Color.lerp(success, other.success, t)!,
      achievement: Color.lerp(achievement, other.achievement, t)!,
      borderRadius: borderRadius + (other.borderRadius - borderRadius) * t,
    );
  }
}

@immutable
class CodeTextTheme extends ThemeExtension<CodeTextTheme> {
  const CodeTextTheme({
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
  });

  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  static CodeTextTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CodeTextTheme>() ??
        CodeTextTheme.fromColorScheme(theme.colorScheme);
  }

  factory CodeTextTheme.fromColorScheme(ColorScheme colorScheme) {
    return CodeTextTheme(
      bodyLarge: TextStyle(
        fontFamily: CodeEditorTheme.codeFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: CodeEditorTheme.codeFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.54,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: CodeEditorTheme.codeFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: colorScheme.onSurface,
      ),
    );
  }

  @override
  CodeTextTheme copyWith({
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
  }) {
    return CodeTextTheme(
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
    );
  }

  @override
  CodeTextTheme lerp(
    covariant ThemeExtension<CodeTextTheme>? other,
    double t,
  ) {
    if (other is! CodeTextTheme) return this;
    return CodeTextTheme(
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
    );
  }
}
