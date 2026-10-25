import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/models/review_schedule.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/repositories/review_schedule_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';

void main() {
  test('review schedules persist independently for each visitor', () async {
    final database = DatabaseHelper(inMemory: true);
    addTearDown(database.close);
    final progressRepository = ProgressRepository(database);
    for (final visitorId in ['visitor-a', 'visitor-b']) {
      await progressRepository.save(
        UserProgress(
          visitorId: visitorId,
          currentUnitId: 'unit-1',
          currentLessonId: 'lesson-1',
          totalXP: 0,
          currentStreak: 0,
          longestStreak: 0,
          lastActiveDate: DateTime.utc(2026, 10, 25),
          lessonsProgress: const {},
          earnedBadges: const [],
        ),
      );
    }

    final repository = ReviewScheduleRepository(database);
    final schedule = ReviewSchedule(
      cardId: 'exercise-1',
      conceptId: 'concept-1',
      repetitionCount: 2,
      easinessFactor: 2.36,
      intervalDays: 6,
      lastReviewedAt: DateTime.utc(2026, 10, 25, 9),
      nextReviewAt: DateTime.utc(2026, 10, 31, 9),
      lastRating: Sm2Rating.hard,
    );
    await repository.saveSchedule(visitorId: 'visitor-a', schedule: schedule);

    final loaded = (await repository.loadSchedules('visitor-a'))['exercise-1'];
    expect(loaded?.cardId, schedule.cardId);
    expect(loaded?.conceptId, schedule.conceptId);
    expect(loaded?.repetitionCount, schedule.repetitionCount);
    expect(loaded?.easinessFactor, schedule.easinessFactor);
    expect(loaded?.nextReviewAt, schedule.nextReviewAt);
    expect(await repository.loadSchedules('visitor-b'), isEmpty);

    await repository.saveSchedule(
      visitorId: 'visitor-a',
      schedule: ReviewSchedule(
        cardId: 'exercise-1',
        conceptId: 'concept-1',
        repetitionCount: 0,
        easinessFactor: 1.7,
        intervalDays: 0,
        lastReviewedAt: DateTime.utc(2026, 10, 25, 10),
        nextReviewAt: DateTime.utc(2026, 10, 25, 10, 10),
        lastRating: Sm2Rating.again,
      ),
    );
    expect(
      (await repository.loadSchedules('visitor-a'))['exercise-1']?.lastRating,
      Sm2Rating.again,
    );
    expect(
      (await repository.loadDueSchedules(
        visitorId: 'visitor-a',
        now: DateTime.utc(2026, 10, 25, 10),
      )),
      isEmpty,
    );
    expect(
      (await repository.loadDueSchedules(
        visitorId: 'visitor-a',
        now: DateTime.utc(2026, 10, 25, 10, 10),
      )),
      hasLength(1),
    );
  });
}
