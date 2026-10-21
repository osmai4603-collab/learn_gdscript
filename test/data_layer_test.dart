import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/app_settings.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/repositories/settings_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/data/sqlite/migrations.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('migrations are idempotent and persisted settings/progress survive reopen', () async {
    final directory = await Directory.systemTemp.createTemp('learn-gdscript-db-');
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/app.sqlite3';

    final firstDatabase = DatabaseHelper(databasePathProvider: () async => path);
    final db = await firstDatabase.database;
    migrateDatabase(db);
    expect(db.select('PRAGMA user_version').single['user_version'], currentSchemaVersion);

    final settings = SettingsRepository(firstDatabase);
    final progress = ProgressRepository(firstDatabase);
    await settings.save(
       AppSettings(locale: Locale('en'), themeMode: ThemeMode.dark),
    );
    final savedProgress = UserProgress(
      visitorId: 'visitor-1',
      currentUnitId: 'basics',
      currentLessonId: 'intro',
      totalXP: 10,
      currentStreak: 2,
      longestStreak: 4,
      lastActiveDate: DateTime.utc(2026, 10, 21),
      lessonsProgress: const {
        'intro': LessonProgress(
          lessonId: 'intro',
          status: LessonStatus.completed,
          exercisesCompleted: 1,
          exercisesTotal: 1,
          attempts: 2,
          hintsUsed: 1,
          savedCode: 'print("ok")',
        ),
      },
      earnedBadges: const ['first-step'],
    );
    await progress.save(savedProgress);
    await firstDatabase.close();

    final reopened = DatabaseHelper(databasePathProvider: () async => path);
    expect(await SettingsRepository(reopened).load(), isA<AppSettings>());
    final restoredSettings = await SettingsRepository(reopened).load();
    expect(restoredSettings.locale, const Locale('en'));
    expect(restoredSettings.themeMode, ThemeMode.dark);
    final restoredProgress = await ProgressRepository(reopened).load('visitor-1');
    expect(restoredProgress?.toJson(), savedProgress.toJson());
    await reopened.close();
  });

  test('reports databases newer than the supported schema', () async {
    final directory = await Directory.systemTemp.createTemp('learn-gdscript-db-');
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/newer.sqlite3';
    final old = sqlite.sqlite3.open(path);
    old.execute('PRAGMA user_version = ${currentSchemaVersion + 1}');
    old.close();

    final helper = DatabaseHelper(databasePathProvider: () async => path);
    await expectLater(helper.database, throwsA(isA<StateError>()));
    await helper.close();
  });

  test('settings default to Arabic and system theme', () async {
    final helper = DatabaseHelper(inMemory: true);
    final settings = await SettingsRepository(helper).load();
    expect(settings.locale, const Locale('ar'));
    expect(settings.themeMode, ThemeMode.system);
    await helper.close();
  });
}
