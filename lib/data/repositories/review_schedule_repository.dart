import '../models/review_schedule.dart';
import '../sqlite/database_helper.dart';

class ReviewScheduleRepository {
  ReviewScheduleRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<Map<String, ReviewSchedule>> loadSchedules(String visitorId) async {
    final database = await _databaseHelper.database;
    final rows = database.select(
      'SELECT card_id, concept_id, repetition_count, easiness_factor, '
      'interval_days, last_reviewed_at, next_review_at, last_rating '
      'FROM review_schedules WHERE visitor_id = ?',
      [visitorId],
    );
    return {
      for (final row in rows)
        row['card_id'] as String: ReviewSchedule(
          cardId: row['card_id'] as String,
          conceptId: row['concept_id'] as String,
          repetitionCount: row['repetition_count'] as int,
          easinessFactor: (row['easiness_factor'] as num).toDouble(),
          intervalDays: row['interval_days'] as int,
          lastReviewedAt: DateTime.parse(row['last_reviewed_at'] as String)
              .toUtc(),
          nextReviewAt: DateTime.parse(row['next_review_at'] as String).toUtc(),
          lastRating: Sm2Rating.values.byName(row['last_rating'] as String),
        ),
    };
  }

  Future<void> saveSchedule({
    required String visitorId,
    required ReviewSchedule schedule,
  }) async {
    final database = await _databaseHelper.database;
    database.execute(
      '''
      INSERT INTO review_schedules (
        visitor_id, card_id, concept_id, repetition_count, easiness_factor,
        interval_days, last_reviewed_at, next_review_at, last_rating
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(visitor_id, card_id) DO UPDATE SET
        concept_id = excluded.concept_id,
        repetition_count = excluded.repetition_count,
        easiness_factor = excluded.easiness_factor,
        interval_days = excluded.interval_days,
        last_reviewed_at = excluded.last_reviewed_at,
        next_review_at = excluded.next_review_at,
        last_rating = excluded.last_rating
      ''',
      [
        visitorId,
        schedule.cardId,
        schedule.conceptId,
        schedule.repetitionCount,
        schedule.easinessFactor,
        schedule.intervalDays,
        schedule.lastReviewedAt.toIso8601String(),
        schedule.nextReviewAt.toIso8601String(),
        schedule.lastRating.name,
      ],
    );
  }

  Future<List<ReviewSchedule>> loadDueSchedules({
    required String visitorId,
    required DateTime now,
  }) async {
    final schedules = await loadSchedules(visitorId);
    final currentTime = now.toUtc();
    return schedules.values
        .where((schedule) => !schedule.nextReviewAt.isAfter(currentTime))
        .toList(growable: false)
      ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
  }
}
