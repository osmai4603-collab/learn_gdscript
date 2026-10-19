
import 'package:flutter/material.dart';

sealed class AppTextTheme {
   static TextTheme getTextTheme({required ColorScheme colorScheme, required String basicFontFamily, required String headingFontFamily}) {
    return TextTheme(
      displayLarge: getDisplayLarge(colorScheme: colorScheme, headingFontFamily: headingFontFamily),
      displayMedium: getDisplayMedium(colorScheme: colorScheme, headingFontFamily: headingFontFamily),
      displaySmall: getDisplaySmall(colorScheme: colorScheme, headingFontFamily: headingFontFamily),
      headlineLarge: getHeadlineLarge(colorScheme: colorScheme, headingFontFamily: headingFontFamily),
      headlineMedium: getHeadlineMedium(colorScheme: colorScheme, headingFontFamily: headingFontFamily),
      headlineSmall: getHeadlineSmall(colorScheme: colorScheme, headingFontFamily: headingFontFamily),
      titleLarge: getTitleLarge(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      titleMedium: getTitleMedium(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      titleSmall: getTitleSmall(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      bodyLarge: getBodyLarge(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      bodyMedium: getBodyMedium(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      bodySmall: getBodySmall(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      labelLarge: getLabelLarge(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      labelMedium: getLabelMedium(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
      labelSmall: getLabelSmall(colorScheme: colorScheme, basicFontFamily: basicFontFamily),
    );
  }

  static TextStyle getDisplayLarge({required ColorScheme colorScheme, required String headingFontFamily}) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getDisplayMedium({required ColorScheme colorScheme, required String headingFontFamily}) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getDisplaySmall({required ColorScheme colorScheme, required String headingFontFamily}) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getHeadlineLarge({required ColorScheme colorScheme, required String headingFontFamily}) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getHeadlineMedium({required ColorScheme colorScheme, required String headingFontFamily}) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getHeadlineSmall({required ColorScheme colorScheme, required String headingFontFamily}) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getTitleLarge({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getTitleMedium({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getTitleSmall({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getBodyLarge({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getBodyMedium({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getBodySmall({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getLabelLarge({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getLabelMedium({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle getLabelSmall({required ColorScheme colorScheme, required String basicFontFamily}) {
    return TextStyle(
      fontFamily: basicFontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: colorScheme.onSurface,
    );
  }

}