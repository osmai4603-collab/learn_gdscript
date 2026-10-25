import 'package:flutter/material.dart';

import '../../data/models/async_state.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider({
    required this._repository,
    required AppSettings initialSettings,
  }) : _settings = initialSettings,
       _state = AsyncState.data(initialSettings);

  final SettingsRepository _repository;
  AppSettings _settings;
  AsyncState<AppSettings> _state;
  int _revision = 0;

  AppSettings get settings => _settings;
  AsyncState<AppSettings> get state => _state;
  Locale get locale => _settings.locale;
  ThemeMode get themeMode => _settings.themeMode;
  AppThemeVariant get themeVariant => _settings.themeVariant;
  int get editorFontSize => _settings.editorFontSize;
  bool get showStreakInUi => _settings.showStreakInUi;

  Future<void> reload() async {
    final revision = ++_revision;
    _state = const AsyncState.loading();
    notifyListeners();
    try {
      final settings = await _repository.load();
      if (revision != _revision) return;
      _settings = settings;
      _state = AsyncState.data(settings);
      notifyListeners();
    } on Object catch (error) {
      if (revision == _revision) {
        _state = AsyncState.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> setLocale(Locale locale) => _update(
    AppSettings(
      locale: locale,
      themeMode: _settings.themeMode,
      themeVariant: _settings.themeVariant,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> setThemeMode(ThemeMode themeMode) => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: themeMode,
      themeVariant: _settings.themeVariant,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> setThemeVariant(AppThemeVariant themeVariant) => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: _settings.themeMode,
      themeVariant: themeVariant,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> completeOnboarding() => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: _settings.themeMode,
      themeVariant: _settings.themeVariant,
      hasCompletedOnboarding: true,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> setEditorFontSize(int fontSize) => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: _settings.themeMode,
      themeVariant: _settings.themeVariant,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: fontSize,
      showStreakInUi: _settings.showStreakInUi,
    ),
  );

  Future<void> setShowStreakInUi(bool show) => _update(
    AppSettings(
      locale: _settings.locale,
      themeMode: _settings.themeMode,
      themeVariant: _settings.themeVariant,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
      editorFontSize: _settings.editorFontSize,
      showStreakInUi: show,
    ),
  );

  Future<void> _update(AppSettings next) async {
    final previous = _settings;
    final revision = ++_revision;
    _settings = next;
    _state = AsyncState.data(next);
    notifyListeners();
    try {
      await _repository.save(next);
    } on Object {
      if (revision == _revision) {
        _settings = previous;
        _state = AsyncState.data(previous);
        notifyListeners();
      }
      rethrow;
    }
  }
}
