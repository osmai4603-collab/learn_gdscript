import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/gdscript_theme.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';

final class GodotArabicIdeTheme implements GDScriptTheme {
  static const godotBlue = Color(0xFF478CBF);
  static const questGold = Color(0xFFFFD43B);
  static const runtimeEmerald = Color(0xFF40C057);
  static const debuggerCoral = Color(0xFFFF6B6B);
  static const codeFontFamily = CodeEditorTheme.codeFontFamily;

  static const editorLightTheme = CodeEditorTheme(
    background: Color(0xFFF5F8FA),
    foreground: Color(0xFF1E232A),
    lineNumber: Color(0xFF5C697D),
    selection: Color(0x33478CBF),
    cursor: Color(0xFF478CBF),
    keyword: Color(0xFFB42318),
    string: Color(0xFF176B9A),
    number: Color(0xFF8E6D00),
    comment: Color(0xFF5C697D),
    function: Color(0xFF176B9A),
    type: Color(0xFF176B9A),
    operator: Color(0xFF1E232A),
    errorLine: Color(0x33BA1A1A),
    matchedBracket: Color(0x55478CBF),
    foldGutter: Color(0xFF5C697D),
    success: Color(0xFF18823B),
    achievement: Color(0xFF8E6D00),
  );

  static const editorDarkTheme = CodeEditorTheme(
    background: Color(0xFF1E232A),
    foreground: Color(0xFFDEE2EC),
    lineNumber: Color(0xFF5C697D),
    selection: Color(0x33478CBF),
    cursor: Color(0xFF91CDFF),
    keyword: Color(0xFFFF7B72),
    string: Color(0xFFA5D6FF),
    number: questGold,
    comment: Color(0xFF8A919A),
    function: godotBlue,
    type: godotBlue,
    operator: Color(0xFFDEE2EC),
    errorLine: Color(0x44FF6B6B),
    matchedBracket: Color(0x55478CBF),
    foldGutter: Color(0xFF5C697D),
    success: runtimeEmerald,
    achievement: questGold,
  );

  static final _lightScheme = const ColorScheme.light().copyWith(
    primary: Color(0xFF176B9A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD9EDFA),
    onPrimaryContainer: Color(0xFF103B56),
    secondary: Color(0xFF8E6D00),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFE082),
    onSecondaryContainer: Color(0xFF3C2F00),
    tertiary: Color(0xFF18823B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFB9F6C2),
    onTertiaryContainer: Color(0xFF00390F),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF5F7FA),
    onSurface: Color(0xFF1E232A),
    onSurfaceVariant: Color(0xFF4C5665),
    inverseSurface: Color(0xFF2C3138),
    onInverseSurface: Color(0xFFF0F1F4),
    inversePrimary: Color(0xFF91CDFF),
    surfaceDim: Color(0xFFD8DDE5),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF0F2F5),
    surfaceContainer: Color(0xFFE9EDF2),
    surfaceContainerHigh: Color(0xFFE1E6ED),
    surfaceContainerHighest: Color(0xFFD8DEE7),
    outline: Color(0xFF687482),
    outlineVariant: Color(0xFFC2CBD5),
    surfaceTint: godotBlue,
  );

  static final _darkScheme = const ColorScheme.dark().copyWith(
    primary: Color(0xFF91CDFF),
    onPrimary: Color(0xFF003350),
    primaryContainer: Color(0xFF5397CA),
    onPrimaryContainer: Color(0xFF002C46),
    inversePrimary: Color(0xFF0C6494),
    secondary: Color(0xFFEFC52B),
    onSecondary: Color(0xFF3C2F00),
    secondaryContainer: Color(0xFFD1AA00),
    onSecondaryContainer: Color(0xFF504000),
    tertiary: Color(0xFF61DF72),
    onTertiary: Color(0xFF00390F),
    tertiaryContainer: Color(0xFF1DA741),
    onTertiaryContainer: Color(0xFF00320C),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0F141A),
    onSurface: Color(0xFFDEE2EC),
    onSurfaceVariant: Color(0xFFC0C7D0),
    inverseSurface: Color(0xFFDEE2EC),
    onInverseSurface: Color(0xFF2C3138),
    surfaceDim: Color(0xFF0F141A),
    surfaceBright: Color(0xFF353941),
    surfaceContainerLowest: Color(0xFF090F15),
    surfaceContainerLow: Color(0xFF171C23),
    surfaceContainer: Color(0xFF1B2027),
    surfaceContainerHigh: Color(0xFF252A31),
    surfaceContainerHighest: Color(0xFF30353C),
    outline: Color(0xFF8A919A),
    outlineVariant: Color(0xFF40484F),
    surfaceTint: Color(0xFF91CDFF),
    primaryFixed: Color(0xFFCCE5FF),
    primaryFixedDim: Color(0xFF91CDFF),
    onPrimaryFixed: Color(0xFF001E31),
    onPrimaryFixedVariant: Color(0xFF004B72),
    secondaryFixed: Color(0xFFFFE082),
    secondaryFixedDim: Color(0xFFECC228),
    onSecondaryFixed: Color(0xFF231B00),
    onSecondaryFixedVariant: Color(0xFF564500),
    tertiaryFixed: Color(0xFF7FFD8B),
    tertiaryFixedDim: Color(0xFF61DF72),
    onTertiaryFixed: Color(0xFF002106),
    onTertiaryFixedVariant: Color(0xFF00531A),
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
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.375,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.42,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.625,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.57,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: basicFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.02,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: codeFontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  TextTheme getCodeTextTheme({required ColorScheme colorScheme}) {
    return TextTheme(
      bodyLarge: TextStyle(
        fontFamily: codeFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: codeFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.54,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: codeFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: colorScheme.onSurface,
      ),
    );
  }

  ThemeData _buildThemeData({
    required ColorScheme colorScheme,
    required CodeEditorTheme editorTheme,
  }) {
    final textTheme = getTextTheme(
      colorScheme: colorScheme,
      basicFontFamily: basicFontFamily,
      headingFontFamily: headingFontFamily,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      fontFamily: basicFontFamily,
      fontFamilyFallback: const ['IBM Plex Sans Arabic'],
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[editorTheme],
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainerHigh,
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: inputDecorationTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      elevatedButtonTheme: elevatedButtonTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      filledButtonTheme: filledButtonTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      outlinedButtonTheme: outlinedButtonTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      textButtonTheme: textButtonTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      appBarTheme: appBarTheme(colorScheme: colorScheme),
      listTileTheme: listTileTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      progressIndicatorTheme: progressIndicatorTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          fontFamily: basicFontFamily,
          color: colorScheme.onSurface,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      iconButtonTheme: iconButtonTheme(
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        collapsedBackgroundColor: colorScheme.surfaceContainerLow,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  ThemeData get light =>
      _buildThemeData(
        colorScheme: _lightScheme,
        editorTheme: editorLightTheme,
      );

  @override
  ThemeData get dark =>
      _buildThemeData(
        colorScheme: _darkScheme,
        editorTheme: editorDarkTheme,
      );

  @override
  String get basicFontFamily => 'IBM Plex Sans';

  @override
  String get headingFontFamily => 'IBM Plex Sans';

  GodotArabicIdeBorderRadius? _borderRadius;

  @override
  GDScriptBorderRadius get borderRadius {
    return _borderRadius ??= GodotArabicIdeBorderRadius();
  }

  GodotArabicIdeSpacing? _spacing;

  @override
  GDScriptSpacing get spacing {
    return _spacing ??= GodotArabicIdeSpacing();
  }

  @override
  ElevatedButtonThemeData? elevatedButtonTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: godotBlue,
        foregroundColor: Colors.white,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
        ),
        minimumSize: const Size(48, 48),
        elevation: 0,
        iconAlignment: .end,
      ),
    );
  }

  @override
  FilledButtonThemeData? filledButtonTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: godotBlue,
        foregroundColor: Colors.white,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
        ),
        minimumSize: const Size(48, 48),
        elevation: 0,
        iconAlignment: .end,
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
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outlineVariant),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
        ),
        minimumSize: const Size(48, 48),
        iconAlignment: .end,
      ),
    );
  }

  @override
  TextButtonThemeData? textButtonTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: godotBlue,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.medium),
        ),
        iconAlignment: .end,
      ),
    );
  }

  @override
  InputDecorationTheme? inputDecorationTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius.medium),
      borderSide: const BorderSide(color: Color(0xFF3A4454)),
    );

    return InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: const Color(0xFF171B20),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelStyle: textTheme.bodyMedium,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius.medium),
        borderSide: const BorderSide(color: godotBlue, width: 1.5),
      ),
    );
  }

  @override
  AppBarTheme? appBarTheme({required ColorScheme colorScheme}) {
    return AppBarTheme(
      backgroundColor: colorScheme.surfaceContainerLow,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  IconButtonThemeData? iconButtonTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        fixedSize: const Size.square(32),
        minimumSize: const Size.square(32),
        iconSize: 18,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.small),
        ),
      ),
    );
  }

  @override
  ListTileThemeData? listTileTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return ListTileThemeData(
      dense: true,
      tileColor: colorScheme.surfaceContainerLow,
      textColor: colorScheme.onSurface,
      iconColor: colorScheme.onSurfaceVariant,
      contentPadding: EdgeInsets.symmetric(horizontal: spacing.medium),
      minVerticalPadding: spacing.extraSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.large),
      ),
    );
  }

  @override
  ProgressIndicatorThemeData? progressIndicatorTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return ProgressIndicatorThemeData(
      color: godotBlue,
      linearTrackColor: colorScheme.surfaceContainerHigh,
      circularTrackColor: colorScheme.surfaceContainerHigh,
    );
  }
}

class GodotArabicIdeSpacing implements GDScriptSpacing {
  @override
  double get extraLarge => 40;

  @override
  double get largeMedium => 24;

  @override
  double get extraSmall => 4;

  @override
  double get large => 24;

  @override
  double get medium => 16;

  @override
  double get smallMedium => 12;

  @override
  double get small => 8;
}

class GodotArabicIdeBorderRadius implements GDScriptBorderRadius {
  @override
  double get extraLarge => 12;

  @override
  double get large => 8;

  @override
  double get medium => 4;

  @override
  double get small => 2;
}
