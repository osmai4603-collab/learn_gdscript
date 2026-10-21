import 'package:flutter/material.dart';

sealed class AppColorScheme {
  static ColorScheme get light {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF356B5B),
      brightness: Brightness.light,
    );
  }

  static ColorScheme get dark {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF82C9AF),
      brightness: Brightness.dark,
    );
  }
}
