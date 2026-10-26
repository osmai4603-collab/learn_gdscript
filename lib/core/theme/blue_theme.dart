import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/gdscript_theme.dart';
import 'package:learn_gdscript/core/theme/theme_data.dart';

final class BlueTheme implements GDScriptTheme {
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

  @override
  TextTheme getTextTheme({
    required ColorScheme colorScheme,
    required String basicFontFamily,
    required String headingFontFamily,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.55,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      labelLarge: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
    );
  }

  @override
  ThemeData get light {
    return AppTheme.buildThemeData(
      colorScheme: _lightScheme,
      textTheme: getTextTheme(
        colorScheme: _lightScheme,
        basicFontFamily: basicFontFamily,
        headingFontFamily: headingFontFamily,
      ),
    );
  }

  @override
  ThemeData get dark {
    return AppTheme.buildThemeData(
      colorScheme: _darkScheme,
      textTheme: getTextTheme(
        colorScheme: _darkScheme,
        basicFontFamily: 'IBM Plex Sans',
        headingFontFamily: 'IBM Plex Sans Arabic',
      ),
    );
  }

  @override
  String get basicFontFamily => 'IBM Plex Sans';

  @override
  String get headingFontFamily => 'IBM Plex Sans Arabic';

  @override
  AppBarTheme appBarTheme({required ColorScheme colorScheme}) {
    return AppBarTheme(
      backgroundColor: _lightScheme.surfaceContainerLow,
      foregroundColor: _lightScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    );
  }

  BlueThemeBorderRadius? _borderRadius;
  @override
  GDScriptBorderRadius get borderRadius {
    return _borderRadius ??= BlueThemeBorderRadius();
  }

  BlueThemeSpacing? _spacing;
  @override
  GDScriptSpacing get spacing {
    return _spacing ??= BlueThemeSpacing();
  }

  @override
  ElevatedButtonThemeData? elevatedButtonTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: TextStyle(
          fontFamily: basicFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        iconAlignment: .end,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
        ),
      ),
    );
  }

  @override
  FilledButtonThemeData? filledButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme}) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: TextStyle(
          fontFamily: basicFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        iconAlignment: .end,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
        ),
      ),
    );
  }

  @override
  IconButtonThemeData? iconButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme}) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.small),
        ),
        iconSize: 17,
      ),
    );
  }

  @override
  InputDecorationTheme? inputDecorationTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      hintStyle: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      labelStyle: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius.small),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  OutlinedButtonThemeData? outlinedButtonTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
          side: BorderSide(color: colorScheme.primary),
        ),
        foregroundColor: colorScheme.onPrimary,
        textStyle: TextStyle(
          fontFamily: basicFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
      ),
    );
  }

  @override
  TextButtonThemeData? textButtonTheme({required ColorScheme colorScheme, required TextTheme textTheme}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: TextStyle(
          fontFamily: basicFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
        ),
      ),
    );
  }

  @override
  ListTileThemeData? listTileTheme({required ColorScheme colorScheme, required TextTheme textTheme}) {
    // TODO: implement listTileTheme
    throw UnimplementedError();
  }

  @override
  ProgressIndicatorThemeData? progressIndicatorTheme({required ColorScheme colorScheme, required TextTheme textTheme}) {
    // TODO: implement progressIndicatorTheme
    throw UnimplementedError();
  }
}

class BlueThemeSpacing implements GDScriptSpacing {
  @override
  double get extraLarge => 32.0;

  @override
  double get largeMedium => 20.0;

  @override
  double get extraSmall => 4.0;

  @override
  double get large => 24.0;

  @override
  double get medium => 16.0;

  @override
  double get smallMedium => 12.0;

  @override
  double get small => 8.0;
}

class BlueThemeBorderRadius implements GDScriptBorderRadius {
  @override
  double get extraLarge => 24.0;

  @override
  double get large => 16.0;

  @override
  double get medium => 16.0;

  @override
  double get small => 8.0;
}
