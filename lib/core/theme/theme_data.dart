


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
        basicFontFamily: 'Roboto',
        headingFontFamily: 'Roboto',
      ),
    );
  }
  
  static ThemeData get dark {
    final colorScheme = AppColorScheme.dark;
    return _buildThemeData(
      colorScheme: colorScheme,
      textTheme: AppTextTheme.getTextTheme(
        colorScheme: colorScheme,
        basicFontFamily: 'Roboto',
        headingFontFamily: 'Roboto',
      ),
    );
  }

  static ThemeData _buildThemeData({required ColorScheme colorScheme, required TextTheme textTheme}) {
    return ThemeData(
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      textTheme: textTheme,
    );
  }

  static InputDecorationTheme getInputDecorationTheme({required ColorScheme colorScheme}) {
    return InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme({required ColorScheme colorScheme}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData getOutlinedButtonTheme({required ColorScheme colorScheme}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  static TextButtonThemeData getTextButtonTheme({required ColorScheme colorScheme}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
      ),
    );
  }

  static AppBarTheme getAppBarTheme({required ColorScheme colorScheme}) {
    return AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
    );
  }

  static ThemeData of(BuildContext context) {
    return Theme.of(context);
  }
}