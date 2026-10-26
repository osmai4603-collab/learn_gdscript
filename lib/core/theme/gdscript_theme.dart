
import 'package:flutter/material.dart';

abstract interface class GDScriptTheme {
  ThemeData get light;
  ThemeData get dark;
  TextTheme getTextTheme({
    required ColorScheme colorScheme,
    required String basicFontFamily,
    required String headingFontFamily,
  });
  String get basicFontFamily;
  String get headingFontFamily;
  GDScriptSpacing get spacing;
  GDScriptBorderRadius get borderRadius;
  InputDecorationTheme?  inputDecorationTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  FilledButtonThemeData? filledButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  ElevatedButtonThemeData? elevatedButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  OutlinedButtonThemeData? outlinedButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  TextButtonThemeData? textButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  AppBarTheme? appBarTheme({required ColorScheme colorScheme});
  IconButtonThemeData? iconButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  ListTileThemeData? listTileTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  ProgressIndicatorThemeData? progressIndicatorTheme({required ColorScheme colorScheme, required TextTheme textTheme});
  
}


abstract interface class GDScriptSpacing {
  double get extraSmall;
  double get small;
  double get medium;
  double get smallMedium;
  double get largeMedium;
  double get large;
  double get extraLarge;
}

abstract interface class GDScriptBorderRadius {
  double get small;
  double get medium;
  double get large;
  double get extraLarge;
}