import '../../data/models/curriculum_models.dart';
import '../../data/models/gamification_models.dart';
import '../../data/models/progress_models.dart';

typedef BadgeProgress = ({int current, int target});

abstract final class BadgeProgressCalculator {
  static BadgeProgress calculate({
    required BadgeDefinition badge,
    required UserProgress? progress,
    required Curriculum? curriculum,
  }) {
    if (progress == null) {
      return (current: 0, target: badge.targetValue);
    }

    return switch (badge.conditionType) {
      'first_print' => (
        current: progress.hasExecutedPrint ? 1 : 0,
        target: 1,
      ),
      'unit_completed' => _unitProgress(
        badge.targetValue,
        progress,
        curriculum,
      ),
      'streak_days' => (
        current: progress.currentStreak,
        target: badge.targetValue,
      ),
      'first_try_count' => (
        current: progress.firstTrySolvedCount,
        target: badge.targetValue,
      ),
      'syntax_explorer_uses' => (
        current: progress.syntaxExplorerUses,
        target: badge.targetValue,
      ),
      'all_units_completed' => (
        current:
            curriculum?.units
                .where(
                  (unit) =>
                      unit.lessonIds.isNotEmpty &&
                      unit.lessonIds.every(
                        (id) =>
                            progress.lessonsProgress[id]?.status ==
                            LessonStatus.completed,
                      ),
                )
                .length ??
            0,
        target: curriculum?.units.length ?? 1,
      ),
      _ => (current: 0, target: badge.targetValue),
    };
  }

  static BadgeProgress _unitProgress(
    int order,
    UserProgress progress,
    Curriculum? curriculum,
  ) {
    if (curriculum == null) return (current: 0, target: 1);
    if (order < 1 || order > curriculum.units.length) {
      return (current: 0, target: 1);
    }

    final lessonIds = curriculum.units[order - 1].lessonIds;
    final completed = lessonIds
        .where(
          (id) =>
              progress.lessonsProgress[id]?.status == LessonStatus.completed,
        )
        .length;
    return (current: completed, target: lessonIds.length);
  }
}
