import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/app_settings.dart';
import 'package:learn_gdscript/data/models/gamification_models.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/home_dashboard_repository.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/repositories/settings_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/data/sqlite/migrations.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('home playground draft persists per visitor', () async {
    final database = DatabaseHelper(inMemory: true);
    addTearDown(database.close);
    final progressRepository = ProgressRepository(database);
    await progressRepository.save(
      UserProgress(
        visitorId: 'dashboard-visitor',
        currentUnitId: 'basics',
        currentLessonId: 'intro',
        totalXP: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: DateTime.utc(2026, 10, 24),
        lessonsProgress: const {},
        earnedBadges: const [],
      ),
    );

    final dashboardRepository = HomeDashboardRepository(database);
    await dashboardRepository.savePlaygroundCode(
      visitorId: 'dashboard-visitor',
      code: 'print("saved draft")',
      updatedAt: DateTime.utc(2026, 10, 24),
    );

    expect(
      await dashboardRepository.loadPlaygroundCode('dashboard-visitor'),
      'print("saved draft")',
    );
    expect(
      await dashboardRepository.loadPlaygroundCode('another-visitor'),
      isNull,
    );
  });

  test(
    'migrations are idempotent and persisted settings/progress survive reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'learn-gdscript-db-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final path = '${directory.path}/app.sqlite3';

      final firstDatabase = DatabaseHelper(
        databasePathProvider: () async => path,
      );
      final db = await firstDatabase.database;
      migrateDatabase(db);
      expect(
        db.select('PRAGMA user_version').single['user_version'],
        currentSchemaVersion,
      );

      final settings = SettingsRepository(firstDatabase);
      final progress = ProgressRepository(firstDatabase);
      await settings.save(
        AppSettings(
          locale: Locale('en'),
          themeMode: ThemeMode.dark,
          themeVariant: AppThemeVariant.arabicIde,
          showStreakInUi: false,
        ),
      );
      final savedProgress = UserProgress(
        visitorId: 'visitor-1',
        currentUnitId: 'basics',
        currentLessonId: 'intro',
        totalXP: 10,
        currentStreak: 2,
        longestStreak: 4,
        lastActiveDate: DateTime.utc(2026, 10, 21),
        lessonsProgress: {
          'intro': LessonProgress(
            lessonId: 'intro',
            status: LessonStatus.completed,
            exercisesCompleted: 1,
            exercisesTotal: 1,
            attempts: 2,
            hintsUsed: 1,
            savedCode: 'print("ok")',
            exercisesWithSolutionViewed: const ['exercise-1'],
            exerciseAttempts: const {'exercise-1': 2},
            exerciseHints: const {'exercise-1': 1},
          ),
        },
        earnedBadges: const ['first-step'],
        earnedBadgeDates: {'first-step': DateTime.utc(2026, 10, 21)},
        xpTransactions: [
          XpTransaction(
            id: 'xp-1',
            amount: 15,
            reason: XpReason.exerciseFirstTry,
            timestamp: DateTime.utc(2026, 10, 21),
            relatedEntityId: 'lesson-1',
          ),
        ],
        firstTrySolvedCount: 1,
        syntaxExplorerUses: 2,
        hasExecutedPrint: true,
      );
      await progress.save(savedProgress);
      final invalidReplacement = UserProgress(
        visitorId: savedProgress.visitorId,
        currentUnitId: savedProgress.currentUnitId,
        currentLessonId: savedProgress.currentLessonId,
        totalXP: 99,
        currentStreak: 2,
        longestStreak: 4,
        lastActiveDate: savedProgress.lastActiveDate,
        lessonsProgress: savedProgress.lessonsProgress,
        earnedBadges: const ['duplicate', 'duplicate'],
      );
      await expectLater(
        progress.save(invalidReplacement),
        throwsA(isA<SqliteException>()),
      );
      expect(
        (await progress.load('visitor-1'))?.totalXP,
        savedProgress.totalXP,
      );
      await firstDatabase.close();

      final reopened = DatabaseHelper(databasePathProvider: () async => path);
      expect(await SettingsRepository(reopened).load(), isA<AppSettings>());
      final restoredSettings = await SettingsRepository(reopened).load();
      expect(restoredSettings.locale, const Locale('en'));
      expect(restoredSettings.themeMode, ThemeMode.dark);
      expect(restoredSettings.themeVariant, AppThemeVariant.arabicIde);
      expect(restoredSettings.showStreakInUi, isFalse);
      final restoredProgress = await ProgressRepository(
        reopened,
      ).load('visitor-1');
      expect(restoredProgress?.toJson(), savedProgress.toJson());
      await reopened.close();
    },
  );

  test('reports databases newer than the supported schema', () async {
    final directory = await Directory.systemTemp.createTemp(
      'learn-gdscript-db-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/newer.sqlite3';
    final old = sqlite.sqlite3.open(path);
    old.execute('PRAGMA user_version = ${currentSchemaVersion + 1}');
    old.close();

    final helper = DatabaseHelper(databasePathProvider: () async => path);
    await expectLater(helper.database, throwsA(isA<StateError>()));
    await helper.close();
  });

  test('database opening failures remain explicit', () async {
    final directory = await Directory.systemTemp.createTemp(
      'learn-gdscript-db-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final helper = DatabaseHelper(
      databasePathProvider: () async => '${directory.path}/missing/app.sqlite3',
    );
    await expectLater(helper.database, throwsA(isA<SqliteException>()));
    await helper.close();
  });

  test('settings default to Arabic and system theme', () async {
    final helper = DatabaseHelper(inMemory: true);
    final settings = await SettingsRepository(helper).load();
    expect(settings.locale, const Locale('ar'));
    expect(settings.themeMode, ThemeMode.system);
    await helper.close();
  });

  test('version 1 progress data migrates to gamification storage', () {
    final database = sqlite.sqlite3.open(':memory:');
    database.execute('''
      CREATE TABLE user_progress (
        visitor_id TEXT PRIMARY KEY NOT NULL,
        current_unit_id TEXT NOT NULL,
        current_lesson_id TEXT NOT NULL,
        total_xp INTEGER NOT NULL,
        current_streak INTEGER NOT NULL,
        longest_streak INTEGER NOT NULL,
        last_active_date TEXT NOT NULL
      )
    ''');
    database.execute('''
      CREATE TABLE lesson_progress (
        visitor_id TEXT NOT NULL,
        lesson_id TEXT NOT NULL,
        status TEXT NOT NULL,
        exercises_completed INTEGER NOT NULL,
        exercises_total INTEGER NOT NULL,
        attempts INTEGER NOT NULL,
        hints_used INTEGER NOT NULL,
        started_at TEXT,
        completed_at TEXT,
        saved_code TEXT,
        PRIMARY KEY (visitor_id, lesson_id)
      )
    ''');
    database.execute('''
      CREATE TABLE earned_badges (
        visitor_id TEXT NOT NULL,
        badge_id TEXT NOT NULL,
        PRIMARY KEY (visitor_id, badge_id)
      )
    ''');
    database.execute(
      "INSERT INTO user_progress VALUES "
      "('visitor', 'unit', 'lesson', 12, 2, 4, '2026-10-21')",
    );
    database.execute(
      "INSERT INTO earned_badges VALUES ('visitor', 'badge_first_line')",
    );
    database.execute('PRAGMA user_version = 1');

    migrateDatabase(database);

    expect(
      database.select('PRAGMA user_version').single['user_version'],
      currentSchemaVersion,
    );
    final progress = database.select(
      'SELECT * FROM user_progress WHERE visitor_id = ?',
      ['visitor'],
    ).single;
    expect(progress['first_try_solved_count'], 0);
    expect(progress['syntax_explorer_uses'], 0);
    expect(progress['has_executed_print'], 0);
    expect(
      database.select(
        'SELECT earned_at FROM earned_badges WHERE badge_id = ?',
        ['badge_first_line'],
      ).single['earned_at'],
      isNull,
    );
    expect(
      database.select(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name = 'xp_transactions'",
      ),
      hasLength(1),
    );
    database.close();
  });
}
