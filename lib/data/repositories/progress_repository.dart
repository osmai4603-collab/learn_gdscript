import 'dart:convert';

import '../models/gamification_models.dart';
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
      'SELECT badge_id, earned_at FROM earned_badges '
      'WHERE visitor_id = ? ORDER BY badge_id',
      [visitorId],
    );
    final transactionRows = db.select(
      'SELECT id, amount, reason, timestamp, entity_id FROM xp_transactions '
      'WHERE visitor_id = ? ORDER BY timestamp, id',
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
      firstTrySolvedCount: row['first_try_solved_count'] as int,
      syntaxExplorerUses: row['syntax_explorer_uses'] as int,
      hasExecutedPrint: (row['has_executed_print'] as int) == 1,
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
            exercisesWithSolutionViewed: [
              for (final id
                  in jsonDecode(
                    lesson['exercises_with_solution_viewed'] as String,
                  )
                      as List<Object?>)
                if (id is String) id,
            ],
            exerciseAttempts: _decodeCounts(lesson['exercise_attempts']),
            exerciseHints: _decodeCounts(lesson['exercise_hints']),
          ),
      },
      earnedBadges: [
        for (final badge in badgeRows) badge['badge_id'] as String,
      ],
      earnedBadgeDates: {
        for (final badge in badgeRows)
          if (badge['earned_at'] case final String date)
            badge['badge_id'] as String: DateTime.parse(date),
      },
      xpTransactions: [
        for (final transaction in transactionRows)
          XpTransaction(
            id: transaction['id'] as String,
            amount: transaction['amount'] as int,
            reason: XpReason.values.byName(transaction['reason'] as String),
            timestamp: DateTime.parse(transaction['timestamp'] as String),
            relatedEntityId: transaction['entity_id'] as String?,
          ),
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
          current_streak, longest_streak, last_active_date,
          first_try_solved_count, syntax_explorer_uses, has_executed_print
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(visitor_id) DO UPDATE SET
          current_unit_id = excluded.current_unit_id,
          current_lesson_id = excluded.current_lesson_id,
          total_xp = excluded.total_xp,
          current_streak = excluded.current_streak,
          longest_streak = excluded.longest_streak,
          last_active_date = excluded.last_active_date,
          first_try_solved_count = excluded.first_try_solved_count,
          syntax_explorer_uses = excluded.syntax_explorer_uses,
          has_executed_print = excluded.has_executed_print
        ''',
        [
          progress.visitorId,
          progress.currentUnitId,
          progress.currentLessonId,
          progress.totalXP,
          progress.currentStreak,
          progress.longestStreak,
          progress.lastActiveDate.toIso8601String(),
          progress.firstTrySolvedCount,
          progress.syntaxExplorerUses,
          progress.hasExecutedPrint ? 1 : 0,
        ],
      );
      db.execute('DELETE FROM lesson_progress WHERE visitor_id = ?', [
        progress.visitorId,
      ]);
      db.execute('DELETE FROM earned_badges WHERE visitor_id = ?', [
        progress.visitorId,
      ]);
      db.execute('DELETE FROM xp_transactions WHERE visitor_id = ?', [
        progress.visitorId,
      ]);
      for (final lesson in progress.lessonsProgress.values) {
        db.execute(
          '''
          INSERT INTO lesson_progress (
            visitor_id, lesson_id, status, exercises_completed, exercises_total,
            attempts, hints_used, started_at, completed_at, saved_code,
            exercises_with_solution_viewed, exercise_attempts, exercise_hints
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
            jsonEncode(lesson.exercisesWithSolutionViewed),
            jsonEncode(lesson.exerciseAttempts),
            jsonEncode(lesson.exerciseHints),
          ],
        );
      }
      for (final badgeId in progress.earnedBadges) {
        db.execute(
          'INSERT INTO earned_badges (visitor_id, badge_id, earned_at) '
          'VALUES (?, ?, ?)',
          [
            progress.visitorId,
            badgeId,
            progress.earnedBadgeDates[badgeId]?.toIso8601String(),
          ],
        );
      }
      for (final transaction in progress.xpTransactions) {
        db.execute(
          'INSERT INTO xp_transactions '
          '(visitor_id, id, amount, reason, timestamp, entity_id) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [
            progress.visitorId,
            transaction.id,
            transaction.amount,
            transaction.reason.name,
            transaction.timestamp.toIso8601String(),
            transaction.relatedEntityId,
          ],
        );
      }
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> clear(String visitorId) async {
    final db = await _databaseHelper.database;
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute('DELETE FROM earned_badges WHERE visitor_id = ?', [visitorId]);
      db.execute('DELETE FROM xp_transactions WHERE visitor_id = ?', [
        visitorId,
      ]);
      db.execute('DELETE FROM lesson_progress WHERE visitor_id = ?', [
        visitorId,
      ]);
      db.execute('DELETE FROM user_progress WHERE visitor_id = ?', [visitorId]);
      db.execute('COMMIT');
    } on Object {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  static DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String);

  static Map<String, int> _decodeCounts(Object? json) {
    final decoded = jsonDecode(json as String);
    if (decoded is! Map) {
      throw const FormatException('Stored exercise counts must be an object.');
    }
    final counts = <String, int>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String || entry.value is! int || entry.value < 0) {
        throw const FormatException(
          'Stored exercise counts must be non-negative integers.',
        );
      }
      counts[entry.key as String] = entry.value as int;
    }
    return counts;
  }
}
