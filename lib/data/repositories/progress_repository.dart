import '../models/progress_models.dart';
import '../sqlite/database_helper.dart';

class ProgressRepository {
  ProgressRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<UserProgress?> load(String visitorId) async {
    final db = await _databaseHelper.database;
    final rows = db.select('SELECT * FROM user_progress WHERE visitor_id = ?', [
      visitorId,
    ]);
    if (rows.isEmpty) return null;
    final row = rows.single;
    final lessonRows = db.select(
      'SELECT * FROM lesson_progress WHERE visitor_id = ?',
      [visitorId],
    );
    final badgeRows = db.select(
      'SELECT badge_id FROM earned_badges WHERE visitor_id = ? ORDER BY badge_id',
      [visitorId],
    );
    return UserProgress(
      visitorId: row['visitor_id'] as String,
      currentUnitId: row['current_unit_id'] as String,
      currentLessonId: row['current_lesson_id'] as String,
      totalXP: row['total_xp'] as int,
      currentStreak: row['current_streak'] as int,
      longestStreak: row['longest_streak'] as int,
      lastActiveDate: DateTime.parse(row['last_active_date'] as String),
      lessonsProgress: {
        for (final lesson in lessonRows)
          lesson['lesson_id'] as String: LessonProgress(
            lessonId: lesson['lesson_id'] as String,
            status: LessonStatus.values.byName(lesson['status'] as String),
            exercisesCompleted: lesson['exercises_completed'] as int,
            exercisesTotal: lesson['exercises_total'] as int,
            attempts: lesson['attempts'] as int,
            hintsUsed: lesson['hints_used'] as int,
            startedAt: _parseDate(lesson['started_at']),
            completedAt: _parseDate(lesson['completed_at']),
            savedCode: lesson['saved_code'] as String?,
          ),
      },
      earnedBadges: [
        for (final badge in badgeRows) badge['badge_id'] as String,
      ],
    );
  }

  Future<void> save(UserProgress progress) async {
    final db = await _databaseHelper.database;
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute(
        '''
        INSERT INTO user_progress (
          visitor_id, current_unit_id, current_lesson_id, total_xp,
          current_streak, longest_streak, last_active_date
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(visitor_id) DO UPDATE SET
          current_unit_id = excluded.current_unit_id,
          current_lesson_id = excluded.current_lesson_id,
          total_xp = excluded.total_xp,
          current_streak = excluded.current_streak,
          longest_streak = excluded.longest_streak,
          last_active_date = excluded.last_active_date
        ''',
        [
          progress.visitorId,
          progress.currentUnitId,
          progress.currentLessonId,
          progress.totalXP,
          progress.currentStreak,
          progress.longestStreak,
          progress.lastActiveDate.toIso8601String(),
        ],
      );
      db.execute('DELETE FROM lesson_progress WHERE visitor_id = ?', [
        progress.visitorId,
      ]);
      db.execute('DELETE FROM earned_badges WHERE visitor_id = ?', [
        progress.visitorId,
      ]);
      for (final lesson in progress.lessonsProgress.values) {
        db.execute(
          '''
          INSERT INTO lesson_progress (
            visitor_id, lesson_id, status, exercises_completed, exercises_total,
            attempts, hints_used, started_at, completed_at, saved_code
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            progress.visitorId,
            lesson.lessonId,
            lesson.status.name,
            lesson.exercisesCompleted,
            lesson.exercisesTotal,
            lesson.attempts,
            lesson.hintsUsed,
            lesson.startedAt?.toIso8601String(),
            lesson.completedAt?.toIso8601String(),
            lesson.savedCode,
          ],
        );
      }
      for (final badgeId in progress.earnedBadges) {
        db.execute(
          'INSERT INTO earned_badges (visitor_id, badge_id) VALUES (?, ?)',
          [progress.visitorId, badgeId],
        );
      }
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  static DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
