import 'package:sqlite3/common.dart';

const currentSchemaVersion = 6;

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
    if (currentVersion < 2) _createVersion2(database);
    if (currentVersion < 4) _createVersion4(database);
    if (currentVersion < 5) _createVersion5(database);
    if (currentVersion < 6) _createVersion6(database);
    database.execute('PRAGMA user_version = $currentSchemaVersion');
    database.execute('COMMIT');
  } on Object {
    database.execute('ROLLBACK');
    rethrow;
  }
}

void _createVersion4(CommonDatabase database) {
  database.execute('''
    CREATE TABLE home_dashboard_state (
      visitor_id TEXT PRIMARY KEY NOT NULL
        REFERENCES user_progress(visitor_id) ON DELETE CASCADE,
      playground_code TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
}

void _createVersion5(CommonDatabase database) {
  database.execute('''
    CREATE TABLE IF NOT EXISTS onboarding_state (
      visitor_id TEXT PRIMARY KEY NOT NULL,
      current_step INTEGER NOT NULL CHECK (current_step BETWEEN 0 AND 3),
      selected_tier TEXT NOT NULL CHECK (
        selected_tier IN ('absoluteBeginner', 'transitionDev', 'godotVeteran')
      ),
      current_question_index INTEGER NOT NULL CHECK (current_question_index >= 0),
      question_ids TEXT NOT NULL,
      selected_answers TEXT NOT NULL,
      recommended_unit_id TEXT,
      recommended_lesson_id TEXT,
      status TEXT NOT NULL CHECK (
        status IN ('inProgress', 'completed', 'skipped')
      ),
      updated_at TEXT NOT NULL,
      CHECK (
        (recommended_unit_id IS NULL AND recommended_lesson_id IS NULL) OR
        (recommended_unit_id IS NOT NULL AND recommended_lesson_id IS NOT NULL)
      )
    )
  ''');
}

void _createVersion6(CommonDatabase database) {
  database.execute('''
    CREATE TABLE review_schedules (
      visitor_id TEXT NOT NULL
        REFERENCES user_progress(visitor_id) ON DELETE CASCADE,
      card_id TEXT NOT NULL,
      concept_id TEXT NOT NULL,
      repetition_count INTEGER NOT NULL CHECK (repetition_count >= 0),
      easiness_factor REAL NOT NULL CHECK (easiness_factor >= 1.3),
      interval_days INTEGER NOT NULL CHECK (interval_days >= 0),
      last_reviewed_at TEXT NOT NULL,
      next_review_at TEXT NOT NULL,
      last_rating TEXT NOT NULL CHECK (
        last_rating IN ('again', 'hard', 'good', 'easy')
      ),
      PRIMARY KEY (visitor_id, card_id)
    )
  ''');
  database.execute(
    'CREATE INDEX review_schedules_due '
    'ON review_schedules(visitor_id, next_review_at)',
  );
}

void _createVersion2(CommonDatabase database) {
  database.execute(
    'ALTER TABLE earned_badges ADD COLUMN earned_at TEXT',
  );
  database.execute(
    'ALTER TABLE user_progress ADD COLUMN first_try_solved_count '
    'INTEGER NOT NULL DEFAULT 0 CHECK (first_try_solved_count >= 0)',
  );
  database.execute(
    'ALTER TABLE user_progress ADD COLUMN syntax_explorer_uses '
    'INTEGER NOT NULL DEFAULT 0 CHECK (syntax_explorer_uses >= 0)',
  );
  database.execute(
    'ALTER TABLE user_progress ADD COLUMN has_executed_print '
    'INTEGER NOT NULL DEFAULT 0 CHECK (has_executed_print IN (0, 1))',
  );
  database.execute(
    "ALTER TABLE lesson_progress ADD COLUMN exercises_with_solution_viewed "
    "TEXT NOT NULL DEFAULT '[]'",
  );
  database.execute(
    "ALTER TABLE lesson_progress ADD COLUMN exercise_attempts "
    "TEXT NOT NULL DEFAULT '{}'",
  );
  database.execute(
    "ALTER TABLE lesson_progress ADD COLUMN exercise_hints "
    "TEXT NOT NULL DEFAULT '{}'",
  );
  database.execute('''
    CREATE TABLE xp_transactions (
      visitor_id TEXT NOT NULL REFERENCES user_progress(visitor_id) ON DELETE CASCADE,
      id TEXT NOT NULL,
      amount INTEGER NOT NULL,
      reason TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      entity_id TEXT,
      PRIMARY KEY (visitor_id, id)
    )
  ''');
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
