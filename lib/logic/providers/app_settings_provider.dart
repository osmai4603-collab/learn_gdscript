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
  int get editorFontSize => _settings.editorFontSize;
  bool get showStreakInUi => _settings.showStreakInUi;

  Future<void> setLocale(Locale locale) => _update(
    AppSettings(
      locale: locale,
      themeMode: _settings.themeMode,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> setThemeMode(ThemeMode themeMode) => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: themeMode,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> completeOnboarding() => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: _settings.themeMode,
      hasCompletedOnboarding: true,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> setEditorFontSize(int fontSize) => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: _settings.themeMode,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: fontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> setShowStreakInUi(bool show) => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: _settings.themeMode,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: show,
    ),
  );

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
