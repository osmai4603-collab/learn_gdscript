import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/logic/services/gamification_service.dart';

void main() {
  const service = GamificationService();

  group('exercise XP', () {
    test('rewards first attempts and retries with hint deductions', () {
      expect(
        service.calculateExerciseXP(
          isFirstTry: true,
          usedSolution: false,
          hintsCount: 0,
        ),
        15,
      );
      expect(
        service.calculateExerciseXP(
          isFirstTry: false,
          usedSolution: false,
          hintsCount: 1,
        ),
        8,
      );
      expect(
        service.calculateExerciseXP(
          isFirstTry: true,
          usedSolution: false,
          hintsCount: 20,
        ),
        0,
      );
      expect(
        service.calculateExerciseXP(
          isFirstTry: true,
          usedSolution: true,
          hintsCount: 0,
        ),
        0,
      );
    });

    test('rejects negative hint counts', () {
      expect(
        () => service.calculateExerciseXP(
          isFirstTry: true,
          usedSolution: false,
          hintsCount: -1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('daily streak calendar updates', () {
    final yesterday = DateTime(2026, 10, 21, 23, 45);

    test('same calendar day does not add another day or bonus', () {
      final update = service.calculateStreakUpdate(
        lastActiveDate: yesterday,
        currentStreak: 4,
        longestStreak: 7,
        now: DateTime(2026, 10, 21, 1),
      );
      expect(update.currentStreak, 4);
      expect(update.longestStreak, 7);
      expect(update.isNewDay, isFalse);
      expect(update.earnedBonusXP, 0);
    });

    test('next calendar day increases the streak and grants bonus XP', () {
      final update = service.calculateStreakUpdate(
        lastActiveDate: yesterday,
        currentStreak: 4,
        longestStreak: 4,
        now: DateTime(2026, 10, 22, 0, 1),
      );
      expect(update.currentStreak, 5);
      expect(update.longestStreak, 5);
      expect(update.isNewDay, isTrue);
      expect(update.earnedBonusXP, 5);
    });

    test('a missed day resets current streak but preserves the longest', () {
      final update = service.calculateStreakUpdate(
        lastActiveDate: yesterday,
        currentStreak: 4,
        longestStreak: 8,
        now: DateTime(2026, 10, 23),
      );
      expect(update.currentStreak, 1);
      expect(update.longestStreak, 8);
      expect(update.earnedBonusXP, 0);
    });
  });
}
