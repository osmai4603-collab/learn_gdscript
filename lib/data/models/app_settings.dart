import 'package:flutter/material.dart';

import 'model_json.dart';

@immutable
class AppSettings {
  final Locale locale;
  final ThemeMode themeMode;
  final bool hasCompletedOnboarding;
  final int editorFontSize;
  final bool showStreakInUi;

  AppSettings({
    this.locale = const Locale('ar'),
    this.themeMode = ThemeMode.system,
    this.hasCompletedOnboarding = false,
    this.editorFontSize = 14,
    this.showStreakInUi = true,
  }) : assert(locale.languageCode == 'ar' || locale.languageCode == 'en'),
       assert(editorFontSize == 12 || editorFontSize == 14 || editorFontSize == 16);

  factory AppSettings.fromJson(JsonObject json) {
    final language = requiredString(json, 'language');
    if (language != 'ar' && language != 'en') {
      throw FormatException('Unsupported language "$language".');
    }
    final theme = requiredString(json, 'themeMode');
    final themeMode = ThemeMode.values.where((value) => value.name == theme);
    if (themeMode.isEmpty) {
      throw FormatException('Unsupported theme mode "$theme".');
    }
    final onboarding = json['hasCompletedOnboarding'];
    if (onboarding != null && onboarding is! bool) {
      throw const FormatException(
        'Field "hasCompletedOnboarding" must be a boolean.',
      );
    }
    final fontSize = json['editorFontSize'];
    if (fontSize != null &&
        (fontSize is! int || !const [12, 14, 16].contains(fontSize))) {
      throw const FormatException(
        'Field "editorFontSize" must be 12, 14, or 16.',
      );
    }
    final showStreak = json['showStreakInUi'];
    if (showStreak != null && showStreak is! bool) {
      throw const FormatException(
        'Field "showStreakInUi" must be a boolean.',
      );
    }
    return AppSettings(
      locale: Locale(language),
      themeMode: themeMode.first,
      hasCompletedOnboarding: onboarding as bool? ?? false,
      editorFontSize: fontSize as int? ?? 14,
      showStreakInUi: showStreak as bool? ?? true,
    );
  }

  JsonObject toJson() => {
    'language': locale.languageCode,
    'themeMode': themeMode.name,
    'hasCompletedOnboarding': hasCompletedOnboarding,
    'editorFontSize': editorFontSize,
    'showStreakInUi': showStreakInUi,
  };
}
