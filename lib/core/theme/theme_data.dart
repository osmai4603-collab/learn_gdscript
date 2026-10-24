import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/color_schemes.dart';
import 'package:learn_gdscript/core/theme/text_theme.dart';

sealed class AppTheme {
  static ThemeData get light {
    final colorScheme = AppColorScheme.light;
    return _buildThemeData(
      colorScheme: colorScheme,
      textTheme: AppTextTheme.getTextTheme(
        colorScheme: colorScheme,
        basicFontFamily: 'IBM Plex Sans',
        headingFontFamily: 'IBM Plex Sans',
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = AppColorScheme.dark;
    return _buildThemeData(
      colorScheme: colorScheme,
      textTheme: AppTextTheme.getTextTheme(
        colorScheme: colorScheme,
        basicFontFamily: 'IBM Plex Sans',
        headingFontFamily: 'IBM Plex Sans',
      ),
    );
  }

  static ThemeData _buildThemeData({
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

  static ElevatedButtonThemeData getElevatedButtonTheme({
    required ColorScheme colorScheme,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        minimumSize: const Size(48, 48),
        elevation: 0,
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
        minimumSize: const Size(48, 48),
      ),
    );
  }

  static TextButtonThemeData getTextButtonTheme({
    required ColorScheme colorScheme,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
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

  static ThemeData of(BuildContext context) {
    return Theme.of(context);
  }
}
