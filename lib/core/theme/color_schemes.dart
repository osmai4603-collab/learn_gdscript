import 'package:flutter/material.dart';

sealed class AppColorScheme {
  static ColorScheme get light {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF478CBF),
      brightness: Brightness.light,
    ).copyWith(
      secondary: const Color(0xFFE67E22),
      tertiary: const Color(0xFF2ECC71),
    );
  }

  static ColorScheme get dark {
    return const ColorScheme.dark().copyWith(
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
  }
}
