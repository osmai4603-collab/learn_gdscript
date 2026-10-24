import 'package:flutter/material.dart';
import 'package:sqlite3/common.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_settings.dart';
import '../sqlite/database_helper.dart';

class SettingsRepository {
  SettingsRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<AppSettings> load() async {
    final db = await _databaseHelper.database;
    final values = {
      for (final row in db.select('SELECT key, value FROM app_settings'))
        row['key'] as String: row['value'] as String,
    };
    final onboardingValue = values['hasCompletedOnboarding'];
    if (onboardingValue != null &&
        onboardingValue != 'true' &&
        onboardingValue != 'false') {
      throw const FormatException(
        'Stored onboarding completion setting is invalid.',
      );
    }
    final fontSizeValue = values['editorFontSize'];
    final fontSize = fontSizeValue == null ? 14 : int.tryParse(fontSizeValue);
    if (fontSize == null) {
      throw const FormatException('Stored editor font size is invalid.');
    }
    final showStreakValue = values['showStreakInUi'];
    if (showStreakValue != null &&
        showStreakValue != 'true' &&
        showStreakValue != 'false') {
      throw const FormatException('Stored streak visibility setting is invalid.');
    }
    return AppSettings.fromJson({
      'language': values['language'] ?? AppConstants.defaultLanguageCode,
      'themeMode': values['themeMode'] ?? ThemeMode.system.name,
      'themeVariant': values['themeVariant'] ?? AppThemeVariant.academy.name,
      'hasCompletedOnboarding': onboardingValue == 'true',
      'editorFontSize': fontSize,
      'showStreakInUi': showStreakValue == null || showStreakValue == 'true',
    });
  }

  Future<void> save(AppSettings settings) async {
    final json = settings.toJson();
    final language = json['language']! as String;
    final onboarding = json['hasCompletedOnboarding']! as bool;
    final editorFontSize = json['editorFontSize']! as int;
    final showStreakInUi = json['showStreakInUi']! as bool;
    if (!AppConstants.supportedLanguageCodes.contains(language)) {
      throw ArgumentError.value(
        language,
        'locale',
        'Only ar and en are supported.',
      );
    }
    final db = await _databaseHelper.database;
    _transaction(db, () {
      _write(db, 'language', language);
      _write(db, 'themeMode', json['themeMode']! as String);
      _write(db, 'themeVariant', json['themeVariant']! as String);
      _write(db, 'hasCompletedOnboarding', onboarding.toString());
      _write(db, 'editorFontSize', editorFontSize.toString());
      _write(db, 'showStreakInUi', showStreakInUi.toString());
    });
  }

  static void _write(CommonDatabase db, String key, String value) {
    db.execute(
      'INSERT INTO app_settings (key, value) VALUES (?, ?) '
      'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      [key, value],
    );
  }

  static void _transaction(CommonDatabase db, void Function() operation) {
    db.execute('BEGIN IMMEDIATE');
    try {
      operation();
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}
