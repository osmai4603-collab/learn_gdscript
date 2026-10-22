class GamificationService {
  const GamificationService();

  static const lessonCompletionXp = 20;
  static const firstTryExerciseXp = 15;
  static const retryExerciseXp = 10;
  static const exampleExecutionXp = 2;
  static const hintPenaltyXp = 2;
  static const unitCompletionXp = 50;
  static const dailyStreakBonusXp = 5;

  int calculateExerciseXP({
    required bool isFirstTry,
    required bool usedSolution,
    required int hintsCount,
  }) {
    if (hintsCount < 0) {
      throw ArgumentError.value(hintsCount, 'hintsCount');
    }
    if (usedSolution) return 0;
    final baseXP = isFirstTry ? firstTryExerciseXp : retryExerciseXp;
    return (baseXP - hintsCount * hintPenaltyXp).clamp(0, baseXP).toInt();
  }

  StreakUpdateResult calculateStreakUpdate({
    required DateTime lastActiveDate,
    required int currentStreak,
    required int longestStreak,
    DateTime? now,
  }) {
    if (currentStreak < 0 || longestStreak < currentStreak) {
      throw ArgumentError('Streak values must be non-negative and consistent.');
    }
    final today = now ?? DateTime.now();
    final lastDay = DateTime.utc(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );
    final currentDay = DateTime.utc(today.year, today.month, today.day);
    final difference = currentDay.difference(lastDay).inDays;

    if (difference == 0) {
      final streak = currentStreak == 0 ? 1 : currentStreak;
      return StreakUpdateResult(
        currentStreak: streak,
        longestStreak: streak > longestStreak ? streak : longestStreak,
        isNewDay: false,
        earnedBonusXP: 0,
      );
    }
    if (difference == 1) {
      final streak = currentStreak + 1;
      return StreakUpdateResult(
        currentStreak: streak,
        longestStreak: streak > longestStreak ? streak : longestStreak,
        isNewDay: true,
        earnedBonusXP: dailyStreakBonusXp,
      );
    }
    return StreakUpdateResult(
      currentStreak: 1,
      longestStreak: longestStreak,
      isNewDay: true,
      earnedBonusXP: 0,
    );
  }
}

class StreakUpdateResult {
  const StreakUpdateResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.isNewDay,
    required this.earnedBonusXP,
  });

  final int currentStreak;
  final int longestStreak;
  final bool isNewDay;
  final int earnedBonusXP;
}
