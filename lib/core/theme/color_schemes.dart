import 'package:flutter/material.dart';

extension AppSemanticColorScheme on ColorScheme {
  Color get successContainer => brightness == Brightness.dark
      ? const Color(0xFF14532D)
      : const Color(0xFFDCFCE7);

  Color get achievement => brightness == Brightness.dark
      ? const Color(0xFFA855F7)
      : const Color(0xFF7E22CE);

  Color get achievementVariant => brightness == Brightness.dark
      ? const Color(0xFFCAA7FF)
      : const Color(0xFF6B21A8);
}
