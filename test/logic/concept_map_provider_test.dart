import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/models/review_schedule.dart';
import 'package:learn_gdscript/data/repositories/concept_map_repository.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/repositories/review_schedule_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/logic/providers/concept_map_provider.dart';
import 'package:learn_gdscript/logic/providers/curriculum_provider.dart';
import 'package:learn_gdscript/logic/providers/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads due cards from completed lessons and persists a rating',
    () async {
      final database = DatabaseHelper(inMemory: true);
      addTearDown(database.close);
      const visitorId = 'concept-map-visitor';
      final progressRepository = ProgressRepository(database);
      await progressRepository.save(
        UserProgress(
          visitorId: visitorId,
          currentUnitId: 'unit_01_first_program',
          currentLessonId: 'lesson_01_hello',
          totalXP: 0,
          currentStreak: 0,
          longestStreak: 0,
          lastActiveDate: DateTime.utc(2026, 10, 25),
          lessonsProgress: {
            'lesson_01_hello': LessonProgress(
              lessonId: 'lesson_01_hello',
              status: LessonStatus.completed,
            ),
          },
          earnedBadges: const [],
        ),
      );

      final curriculumProvider = CurriculumProvider(
        CurriculumRepository(assetBundle: rootBundle),
      );
      await curriculumProvider.load();
      final progressProvider = ProgressProvider(progressRepository);
      await progressProvider.load(visitorId);
      final scheduleRepository = ReviewScheduleRepository(database);
      final provider = ConceptMapProvider(
        conceptMapRepository: ConceptMapRepository(assetBundle: rootBundle),
        reviewScheduleRepository: scheduleRepository,
        curriculumProvider: curriculumProvider,
        progressProvider: progressProvider,
        visitorId: visitorId,
        clock: () => DateTime.utc(2026, 10, 25, 9),
      );
      addTearDown(provider.dispose);
      addTearDown(curriculumProvider.dispose);
      addTearDown(progressProvider.dispose);

      await provider.load();
      final loaded = provider.state.value!;
      expect(loaded.dueCards, isNotEmpty);
      expect(
        loaded.dueCards.every((card) => card.lessonId == 'lesson_01_hello'),
        isTrue,
      );
      final card = loaded.dueCards.first;

      await provider.rateCard(cardId: card.id, rating: Sm2Rating.good);

      final updated = provider.state.value!;
      expect(updated.schedules[card.id]?.repetitionCount, 1);
      expect(updated.dueCards.any((dueCard) => dueCard.id == card.id), isFalse);
      expect(
        (await scheduleRepository.loadSchedules(
          visitorId,
        ))[card.id]?.lastRating,
        Sm2Rating.good,
      );
    },
  );
}
