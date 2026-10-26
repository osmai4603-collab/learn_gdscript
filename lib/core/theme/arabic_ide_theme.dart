import 'package:flutter/material.dart';

class ArabicIdeSyntaxColors extends ThemeExtension<ArabicIdeSyntaxColors> {
  const ArabicIdeSyntaxColors({
    required this.keyword,
    required this.builtIn,
    required this.string,
    required this.target,
    required this.comment,
    required this.error,
  });

  final Color keyword;
  final Color builtIn;
  final Color string;
  final Color target;
  final Color comment;
  final Color error;

  @override
  ArabicIdeSyntaxColors copyWith({
    Color? keyword,
    Color? builtIn,
    Color? string,
    Color? target,
    Color? comment,
    Color? error,
  }) {
    return ArabicIdeSyntaxColors(
      keyword: keyword ?? this.keyword,
      builtIn: builtIn ?? this.builtIn,
      string: string ?? this.string,
      target: target ?? this.target,
      comment: comment ?? this.comment,
      error: error ?? this.error,
    );
  }

  @override
  ArabicIdeSyntaxColors lerp(
    covariant ArabicIdeSyntaxColors? other,
    double t,
  ) {
    if (other == null) return this;
    return ArabicIdeSyntaxColors(
      keyword: Color.lerp(keyword, other.keyword, t)!,
      builtIn: Color.lerp(builtIn, other.builtIn, t)!,
      string: Color.lerp(string, other.string, t)!,
      target: Color.lerp(target, other.target, t)!,
      comment: Color.lerp(comment, other.comment, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

sealed class ArabicIdeTheme {
  static const syntaxColors = ArabicIdeSyntaxColors(
    keyword: Color(0xFFFF7B72),
    builtIn: Color(0xFF478CBF),
    string: Color(0xFFA5D6FF),
    target: Color(0xFFFFD43B),
    comment: Color(0xFF5C697D),
    error: Color(0xFFFF6B6B),
  );

  static String codeFontFamily(BuildContext context) {
    return 'JetBrains Mono';
    // return Theme.of(context).extension<ArabicIdeSyntaxColors>() == null
    //     ? 'monospace'
    //     : 'JetBrains Mono';
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF478CBF),
      brightness: Brightness.light,
    ).copyWith(
      secondary: const Color(0xFF8A6A00),
      tertiary: const Color(0xFF168137),
      error: const Color(0xFFB42318),
    );
    return _build(colorScheme);
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF91CDFF),
      onPrimary: Color(0xFF003350),
      primaryContainer: Color(0xFF5397CA),
      onPrimaryContainer: Color(0xFF002C46),
      secondary: Color(0xFFEFC52B),
      onSecondary: Color(0xFF3C2F00),
      secondaryContainer: Color(0xFFD1AA00),
      onSecondaryContainer: Color(0xFF504000),
      tertiary: Color(0xFF61DF72),
      onTertiary: Color(0xFF00390F),
      tertiaryContainer: Color(0xFF1DA741),
      onTertiaryContainer: Color(0xFF00320C),
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF0F141A),
      onSurface: Color(0xFFDEE2EC),
      onSurfaceVariant: Color(0xFFC0C7D0),
      inverseSurface: Color(0xFFDEE2EC),
      onInverseSurface: Color(0xFF2C3138),
      inversePrimary: Color(0xFF0C6494),
      surfaceDim: Color(0xFF0F141A),
      surfaceBright: Color(0xFF353941),
      surfaceContainerLowest: Color(0xFF090F15),
      surfaceContainerLow: Color(0xFF1E232A),
      surfaceContainer: Color(0xFF282F3B),
      surfaceContainerHigh: Color(0xFF343D4C),
      surfaceContainerHighest: Color(0xFF30353C),
      outline: Color(0xFF8A919A),
      outlineVariant: Color(0xFF3A4454),
      surfaceTint: Color(0xFF91CDFF),
    );
    return _build(colorScheme);
  }

  static ThemeData _build(ColorScheme colorScheme) {
    final dark = colorScheme.brightness == Brightness.dark;
    final baseTextTheme = Typography.material2021().black.apply(
      fontFamily: 'IBM Plex Sans',
      displayColor: colorScheme.onSurface,
      bodyColor: colorScheme.onSurface,
    );
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.375,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.42,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.625,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.57,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12, height: 1.5),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: 'JetBrains Mono',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
    const controlRadius = 4.0;
    const actionColor = Color(0xFF478CBF);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      fontFamily: 'IBM Plex Sans',
      fontFamilyFallback: const ['IBM Plex Sans Arabic'],
      textTheme: textTheme,
      extensions: const [syntaxColors],
      scaffoldBackgroundColor: dark
          ? const Color(0xFF14181D)
          : colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: dark
          ? const Color(0xFF282F3B)
          : colorScheme.surfaceContainerLow,
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF282F3B) : colorScheme.surfaceContainerLow,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: dark
                ? const Color(0x143A4454)
                : colorScheme.outlineVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? const Color(0x143A4454) : colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: dark
            ? const Color(0xFF171B20)
            : colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF3A4454) : colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF3A4454) : colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: actionColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          minimumSize: const Size(48, 48),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: dark
              ? const Color(0xFF1E232A)
              : colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          side: BorderSide(
            color: dark ? const Color(0xFF3A4454) : colorScheme.outlineVariant,
          ),
          minimumSize: const Size(48, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark
            ? const Color(0xFF14181D)
            : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHigh,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
