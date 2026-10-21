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
    return AppSettings.fromJson({
      'language': values['language'] ?? AppConstants.defaultLanguageCode,
      'themeMode': values['themeMode'] ?? ThemeMode.system.name,
    });
  }

  Future<void> save(AppSettings settings) async {
    final json = settings.toJson();
    final language = json['language']! as String;
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
