import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider({
    required this._repository,
    required AppSettings initialSettings,
  }) : _settings = initialSettings;

  final SettingsRepository _repository;
  AppSettings _settings;
  int _revision = 0;

  AppSettings get settings => _settings;
  Locale get locale => _settings.locale;
  ThemeMode get themeMode => _settings.themeMode;

  Future<void> setLocale(Locale locale) =>
      _update(AppSettings(locale: locale, themeMode: _settings.themeMode));

  Future<void> setThemeMode(ThemeMode themeMode) =>
      _update(AppSettings(locale: _settings.locale, themeMode: themeMode));

  Future<void> _update(AppSettings next) async {
    final previous = _settings;
    final revision = ++_revision;
    _settings = next;
    notifyListeners();
    try {
      await _repository.save(next);
    } on Object {
      if (revision == _revision) {
        _settings = previous;
        notifyListeners();
      }
      rethrow;
    }
  }
}
