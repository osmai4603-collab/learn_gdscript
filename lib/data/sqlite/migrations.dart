import 'package:sqlite3/common.dart';

const currentSchemaVersion = 1;

void migrateDatabase(CommonDatabase database) {
  final currentVersion =
      database.select('PRAGMA user_version').single['user_version'] as int;
  if (currentVersion > currentSchemaVersion) {
    throw StateError(
      'Database schema $currentVersion is newer than supported schema '
      '$currentSchemaVersion.',
    );
  }
  if (currentVersion == currentSchemaVersion) return;

  database.execute('BEGIN IMMEDIATE');
  try {
    if (currentVersion < 1) _createVersion1(database);
    database.execute('PRAGMA user_version = $currentSchemaVersion');
    database.execute('COMMIT');
  } on Object {
    database.execute('ROLLBACK');
    rethrow;
  }
}

void _createVersion1(CommonDatabase database) {
  database.execute('''
    CREATE TABLE user_progress (
      visitor_id TEXT PRIMARY KEY NOT NULL,
      current_unit_id TEXT NOT NULL,
      current_lesson_id TEXT NOT NULL,
      total_xp INTEGER NOT NULL CHECK (total_xp >= 0),
      current_streak INTEGER NOT NULL CHECK (current_streak >= 0),
      longest_streak INTEGER NOT NULL CHECK (longest_streak >= current_streak),
      last_active_date TEXT NOT NULL
    )
  ''');
  database.execute('''
    CREATE TABLE lesson_progress (
      visitor_id TEXT NOT NULL REFERENCES user_progress(visitor_id) ON DELETE CASCADE,
      lesson_id TEXT NOT NULL,
      status TEXT NOT NULL CHECK (status IN ('notStarted', 'inProgress', 'completed')),
      exercises_completed INTEGER NOT NULL CHECK (exercises_completed >= 0),
      exercises_total INTEGER NOT NULL CHECK (exercises_total >= 0),
      attempts INTEGER NOT NULL CHECK (attempts >= 0),
      hints_used INTEGER NOT NULL CHECK (hints_used >= 0),
      started_at TEXT,
      completed_at TEXT,
      saved_code TEXT,
      PRIMARY KEY (visitor_id, lesson_id)
    )
  ''');
  database.execute('''
    CREATE TABLE earned_badges (
      visitor_id TEXT NOT NULL REFERENCES user_progress(visitor_id) ON DELETE CASCADE,
      badge_id TEXT NOT NULL,
      PRIMARY KEY (visitor_id, badge_id)
    )
  ''');
  database.execute('''
    CREATE TABLE app_settings (
      key TEXT PRIMARY KEY NOT NULL,
      value TEXT NOT NULL
    )
  ''');
  database.execute('''
    CREATE TABLE workspace_state (
      singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
      root_path TEXT NOT NULL
    )
  ''');
  database.execute('''
    CREATE TABLE workspace_files (
      uri TEXT PRIMARY KEY NOT NULL,
      relative_path TEXT NOT NULL,
      content TEXT NOT NULL,
      modified_millis INTEGER NOT NULL
    )
  ''');
  database.execute(
    'CREATE INDEX workspace_files_path ON workspace_files(relative_path)',
  );
}
