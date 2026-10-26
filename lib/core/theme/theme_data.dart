import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/text_theme.dart';

sealed class AppTheme {
  static final _lightScheme = const ColorScheme.light().copyWith(
    primary: Color(0xFF176B9A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD9EDFA),
    onPrimaryContainer: Color(0xFF103B56),
    secondary: Color(0xFFA64F0A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFE3CC),
    onSecondaryContainer: Color(0xFF542600),
    tertiary: Color(0xFF18723D),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD9F4E2),
    onTertiaryContainer: Color(0xFF103C22),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF7F9FC),
    onSurface: Color(0xFF191D24),
    onSurfaceVariant: Color(0xFF454E59),
    inverseSurface: Color(0xFF2E333B),
    onInverseSurface: Color(0xFFF0F1F4),
    inversePrimary: Color(0xFF91CDFF),
    surfaceDim: Color(0xFFD8DDE5),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F6FA),
    surfaceContainer: Color(0xFFEDF1F6),
    surfaceContainerHigh: Color(0xFFE6EBF2),
    surfaceContainerHighest: Color(0xFFDDE4EC),
    outline: Color(0xFF687482),
    outlineVariant: Color(0xFFC2CBD5),
    surfaceTint: Color(0xFF176B9A),
  );

  static final _darkScheme = const ColorScheme.dark().copyWith(
    primary: Color(0xFF91CDFF),
    onPrimary: Color(0xFF003350),
    primaryContainer: Color(0xFF5397CA),
    onPrimaryContainer: Color(0xFF002C46),
    secondary: Color(0xFFFFB783),
    onSecondary: Color(0xFF4F2500),
    secondaryContainer: Color(0xFFDB7619),
    onSecondaryContainer: Color(0xFF451F00),
    tertiary: Color(0xFF4AE183),
    onTertiary: Color(0xFF003919),
    tertiaryContainer: Color(0xFF00A657),
    onTertiaryContainer: Color(0xFF003115),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF0F141B),
    onSurface: Color(0xFFDEE2EC),
    onSurfaceVariant: Color(0xFFC0C7D0),
    surfaceDim: Color(0xFF0F141B),
    surfaceBright: Color(0xFF343941),
    surfaceContainerLowest: Color(0xFF090F15),
    surfaceContainerLow: Color(0xFF171C23),
    surfaceContainer: Color(0xFF1B2027),
    surfaceContainerHigh: Color(0xFF252A32),
    surfaceContainerHighest: Color(0xFF30353D),
    outline: Color(0xFF8A919A),
    outlineVariant: Color(0xFF40484F),
    surfaceTint: Color(0xFF91CDFF),
  );

  static ThemeData get light {
    return buildThemeData(
      colorScheme: _lightScheme,
      textTheme: AppTextTheme.getTextTheme(
        colorScheme: _lightScheme,
        basicFontFamily: 'IBM Plex Sans',
        headingFontFamily: 'IBM Plex Sans',
      ),
    );
  }

  static ThemeData get dark {
    return buildThemeData(
      colorScheme: _darkScheme,
      textTheme: AppTextTheme.getTextTheme(
        colorScheme: _darkScheme,
        basicFontFamily: 'IBM Plex Sans',
        headingFontFamily: 'IBM Plex Sans',
      ),
    );
  }

  static ThemeData buildThemeData({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      fontFamily: 'IBM Plex Sans',
      fontFamilyFallback: const ['IBM Plex Sans Arabic'],
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainerLow,
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: getInputDecorationTheme(colorScheme: colorScheme),
      elevatedButtonTheme: getElevatedButtonTheme(colorScheme: colorScheme),
      filledButtonTheme: getFilledButtonTheme(colorScheme: colorScheme),
      outlinedButtonTheme: getOutlinedButtonTheme(colorScheme: colorScheme),
      textButtonTheme: getTextButtonTheme(colorScheme: colorScheme),
      appBarTheme: getAppBarTheme(colorScheme: colorScheme),
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
      iconButtonTheme: getIconTheme(colorScheme: colorScheme),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        collapsedBackgroundColor: colorScheme.surfaceContainerLow,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static InputDecorationTheme getInputDecorationTheme({
    required ColorScheme colorScheme,
  }) {
    return InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: colorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  static FilledButtonThemeData getFilledButtonTheme({
    required ColorScheme colorScheme,
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        minimumSize: const Size(48, 48),
        elevation: 0,
        iconAlignment: .end,
      ),
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme({
    required ColorScheme colorScheme,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        minimumSize: const Size(35, 35),
        maximumSize: const Size.fromHeight(35),
        elevation: 0,
        iconAlignment: .end,
        // controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  static OutlinedButtonThemeData getOutlinedButtonTheme({
    required ColorScheme colorScheme,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        side: BorderSide(color: colorScheme.outlineVariant),
        minimumSize: const Size(35, 35),
        iconAlignment: .end,
      ),
    );
  }

  static TextButtonThemeData getTextButtonTheme({
    required ColorScheme colorScheme,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        iconAlignment: .end,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  static AppBarTheme getAppBarTheme({required ColorScheme colorScheme}) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }

  static IconButtonThemeData getIconTheme({required ColorScheme colorScheme}) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        fixedSize: const Size.square(30),
        maximumSize: const Size.square(30),
        minimumSize: const Size.square(30),
        iconSize: 17,
        alignment: Alignment.center,
        padding: EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
    );
  }

  static ThemeData of(BuildContext context) {
    return Theme.of(context);
  }
}
