import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/curriculum_models.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/logic/services/badge_evaluator.dart';

void main() {
  const evaluator = BadgeEvaluator();

  test('the catalog contains ten localized achievement definitions', () {
    expect(BadgeEvaluator.catalog, hasLength(10));
    expect(
      BadgeEvaluator.catalog.every(
        (badge) =>
            badge.title.ar.isNotEmpty &&
            badge.title.en.isNotEmpty &&
            badge.description.ar.isNotEmpty &&
            badge.description.en.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('evaluates all achievement conditions and never returns earned badges', () {
    final units = [
      for (var index = 0; index < 5; index++)
        Unit(
          id: 'unit_$index',
          title: const LocalizedText(ar: 'عنوان', en: 'Title'),
          description: const LocalizedText(ar: 'وصف', en: 'Description'),
          iconName: 'star',
          order: index,
          lessonIds: ['lesson_$index'],
        ),
    ];
    final progress = UserProgress(
      visitorId: 'visitor',
      currentUnitId: units.first.id,
      currentLessonId: units.first.lessonIds.first,
      totalXP: 0,
      currentStreak: 7,
      longestStreak: 7,
      lastActiveDate: DateTime(2026, 10, 22),
      lessonsProgress: {
        for (var index = 0; index < 5; index++)
          'lesson_$index': LessonProgress(
            lessonId: 'lesson_$index',
            status: LessonStatus.completed,
          ),
      },
      earnedBadges: const [],
      firstTrySolvedCount: 5,
      syntaxExplorerUses: 10,
      hasExecutedPrint: true,
    );
    final curriculum = Curriculum(
      version: '1',
      targetGDScriptVersion: '4.x',
      units: units,
    );

    final earned = evaluator.evaluateNewBadges(
      progress: progress,
      curriculum: curriculum,
    );
    expect(earned, hasLength(10));
    expect(
      evaluator
          .evaluateNewBadges(
            progress: UserProgress(
              visitorId: progress.visitorId,
              currentUnitId: progress.currentUnitId,
              currentLessonId: progress.currentLessonId,
              totalXP: progress.totalXP,
              currentStreak: progress.currentStreak,
              longestStreak: progress.longestStreak,
              lastActiveDate: progress.lastActiveDate,
              lessonsProgress: progress.lessonsProgress,
              earnedBadges: earned.map((badge) => badge.id).toList(),
              firstTrySolvedCount: progress.firstTrySolvedCount,
              syntaxExplorerUses: progress.syntaxExplorerUses,
              hasExecutedPrint: progress.hasExecutedPrint,
            ),
            curriculum: curriculum,
          ),
      isEmpty,
    );
  });
}
