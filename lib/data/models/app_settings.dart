import 'package:flutter/material.dart';

import 'model_json.dart';

@immutable
class AppSettings {
  final Locale locale;
  final ThemeMode themeMode;

  AppSettings({
    this.locale = const Locale('ar'),
    this.themeMode = ThemeMode.system,
  }) : assert(locale.languageCode == 'ar' || locale.languageCode == 'en');

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
    return AppSettings(locale: Locale(language), themeMode: themeMode.first);
  }

  JsonObject toJson() => {
    'language': locale.languageCode,
    'themeMode': themeMode.name,
  };
}
