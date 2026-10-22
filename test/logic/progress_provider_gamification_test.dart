import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/curriculum_models.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/logic/providers/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('records XP and newly earned badges durably and idempotently', () async {
    final helper = DatabaseHelper(inMemory: true);
    final repository = ProgressRepository(helper);
    final provider = ProgressProvider(repository);
    addTearDown(() async {
      provider.dispose();
      await helper.close();
    });
    final curriculum = Curriculum(
      version: '1',
      targetGDScriptVersion: '4.x',
      units: [
        Unit(
          id: 'unit_01',
          title: const LocalizedText(ar: 'الأولى', en: 'First'),
          description: const LocalizedText(ar: 'وصف', en: 'Description'),
          iconName: 'star',
          order: 0,
          lessonIds: const ['lesson_01'],
        ),
      ],
    );
    await provider.initialize(
      visitorId: 'visitor',
      unitId: 'unit_01',
      lessonId: 'lesson_01',
    );
    await provider.updateLesson(
      unitId: 'unit_01',
      lessonId: 'lesson_01',
      lessonProgress: LessonProgress(
        lessonId: 'lesson_01',
        status: LessonStatus.completed,
        exercisesCompleted: 1,
        exercisesTotal: 1,
      ),
    );

    final now = DateTime.now();
    final exercise = await provider.recordExerciseResult(
      curriculum: curriculum,
      lessonId: 'lesson_01',
      attempts: 1,
      hintsCount: 0,
      usedSolution: false,
      code: 'print("hello")',
      now: now,
    );
    expect(exercise.earnedXP, 15);
    expect(
      exercise.newlyUnlockedBadges.map((badge) => badge.id),
      containsAll(['badge_first_line', 'badge_unit_01', 'badge_graduate']),
    );

    final completion = await provider.recordLessonCompletion(
      curriculum: curriculum,
      unitId: 'unit_01',
      lessonId: 'lesson_01',
      now: now,
    );
    expect(completion.earnedXP, 70);
    expect(completion.newlyUnlockedBadges, isEmpty);
    expect(provider.progress?.totalXP, 85);

    final repeated = await provider.recordLessonCompletion(
      curriculum: curriculum,
      unitId: 'unit_01',
      lessonId: 'lesson_01',
      now: now,
    );
    expect(repeated.earnedXP, 0);
    expect(provider.progress?.totalXP, 85);

    final restored = await repository.load('visitor');
    expect(restored?.totalXP, 85);
    expect(restored?.xpTransactions, hasLength(3));
    expect(
      restored?.earnedBadges,
      containsAll(['badge_first_line', 'badge_unit_01', 'badge_graduate']),
    );
  });
}
