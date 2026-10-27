import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';

void main() {
  test('loads legacy progress without losing user data', () {
    const completedLessonIds = [
      'lesson_01_hello',
      'lesson_02_comments',
      'lesson_15_errors',
      'lesson_03_variables',
      'lesson_04_types',
      'lesson_16_casting',
      'lesson_17_strings',
      'lesson_18_enums',
      'lesson_05_operations',
      'lesson_06_if_else',
    ];
    final lessonsProgress = {
      for (final lessonId in completedLessonIds)
        lessonId: {
          'lessonId': lessonId,
          'status': 'completed',
          'exercisesCompleted': 10,
          'exercisesTotal': 10,
          'attempts': 12,
          'hintsUsed': 2,
          'savedCode': 'print("saved $lessonId")',
        },
    };
    final legacyJson = <String, Object?>{
      'visitorId': 'legacy-visitor',
      'currentUnitId': 'unit_04_loops',
      'currentLessonId': 'lesson_06_if_else',
      'totalXP': 1500,
      'currentStreak': 5,
      'longestStreak': 12,
      'lastActiveDate': '2026-10-27T12:00:00.000Z',
      'lessonsProgress': lessonsProgress,
      'earnedBadges': ['first_steps', 'loop_master'],
    };

    final migrated = UserProgress.fromJson(legacyJson);

    expect(migrated.visitorId, 'legacy-visitor');
    expect(migrated.totalXP, 1500);
    expect(migrated.currentStreak, 5);
    expect(migrated.longestStreak, 12);
    expect(migrated.earnedBadges, ['first_steps', 'loop_master']);
    expect(migrated.lessonsProgress.keys, unorderedEquals(completedLessonIds));
    for (final lessonId in completedLessonIds) {
      final lesson = migrated.lessonsProgress[lessonId]!;
      expect(lesson.status, LessonStatus.completed);
      expect(lesson.savedCode, 'print("saved $lessonId")');
      expect(lesson.attempts, 12);
      expect(lesson.hintsUsed, 2);
    }
    expect(migrated.xpTransactions, isEmpty);
  });
}
