import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/concept_map_models.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/concept_map_repository.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('concept map covers the curriculum with unique acyclic concepts', () async {
    final curriculumRepository = CurriculumRepository(assetBundle: rootBundle);
    final curriculum = await curriculumRepository.loadCurriculum();
    final repository = ConceptMapRepository(assetBundle: rootBundle);

    final content = await repository.load(curriculum);
    final curriculumLessonIds = curriculum.units
        .expand((unit) => unit.lessonIds)
        .toSet();
    final concepts = content.manifest.concepts;
    final conceptIds = content.manifest.concepts
        .map((concept) => concept.id)
        .toSet();
    final positions = concepts
        .map((concept) => (concept.x, concept.y))
        .toSet();
    final yLevels = concepts.map((concept) => concept.y).toSet().toList()
      ..sort();

    expect(concepts, hasLength(51));
    expect(conceptIds, hasLength(51));
    expect(
      concepts.map((concept) => concept.lessonId).toSet(),
      curriculumLessonIds,
    );
    expect(content.lessons.keys.toSet(), curriculumLessonIds);
    expect(positions, hasLength(51));
    expect(yLevels, hasLength(7));
    for (var index = 1; index < yLevels.length; index++) {
      expect(yLevels[index] - yLevels[index - 1], inInclusiveRange(180, 220));
    }
    for (final y in yLevels) {
      final xPositions = concepts
          .where((concept) => concept.y == y)
          .map((concept) => concept.x)
          .toList()
        ..sort();
      for (var index = 1; index < xPositions.length; index++) {
        expect(
          xPositions[index] - xPositions[index - 1],
          inInclusiveRange(200, 240),
        );
      }
    }
    for (final concept in concepts) {
      expect(concept.prerequisiteIds.every(conceptIds.contains), isTrue);
      expect(content.lessons[concept.lessonId]?.unitId, isNotNull);
    }
  });

  test('concept map creates one populated review card per exercise', () async {
    final curriculum = await CurriculumRepository(
      assetBundle: rootBundle,
    ).loadCurriculum();
    final content = await ConceptMapRepository(
      assetBundle: rootBundle,
    ).load(curriculum);
    final snapshot = ConceptMapSnapshot(
      content: content,
      progress: UserProgress(
        visitorId: 'concept-map-cards-test',
        currentUnitId: curriculum.units.first.id,
        currentLessonId: curriculum.units.first.lessonIds.first,
        totalXP: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: DateTime.utc(2026, 10, 27),
        lessonsProgress: const {},
        earnedBadges: const [],
      ),
      schedules: const {},
      dueCards: const [],
      loadedAt: DateTime.utc(2026, 10, 27),
    );
    final cards = snapshot.allCards;
    final expectedCardCount = content.lessons.values.fold<int>(
      0,
      (count, lesson) => count + lesson.exercises.length,
    );

    expect(expectedCardCount, 510);
    expect(cards, hasLength(expectedCardCount));
    expect(cards.map((card) => card.id).toSet(), hasLength(expectedCardCount));
    for (final card in cards) {
      final lesson = content.lessons[card.lessonId]!;
      final exercise = lesson.exercises.singleWhere(
        (exercise) => exercise.id == card.id,
      );
      expect(card.conceptId, content.manifest.concepts
          .singleWhere((concept) => concept.lessonId == lesson.id)
          .id);
      expect(card.prompt.ar, exercise.prompt.ar);
      expect(card.prompt.en, exercise.prompt.en);
      expect(card.codeContext, exercise.starterCode);
      expect(card.answerCode, exercise.solutionCode);
      expect(card.answerExplanation.ar, lesson.objective.ar);
      expect(card.answerExplanation.en, lesson.objective.en);
    }
  });
}
