import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/repositories/concept_map_repository.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('concept map references valid curriculum lessons and prerequisites', () async {
    final curriculumRepository = CurriculumRepository(
      assetBundle: rootBundle,
    );
    final curriculum = await curriculumRepository.loadCurriculum();
    final repository = ConceptMapRepository(assetBundle: rootBundle);

    final content = await repository.load(curriculum);
    final conceptIds = content.manifest.concepts
        .map((concept) => concept.id)
        .toSet();

    expect(content.manifest.concepts, isNotEmpty);
    expect(content.lessons.keys.toSet(), {
      for (final concept in content.manifest.concepts) concept.lessonId,
    });
    for (final concept in content.manifest.concepts) {
      expect(concept.prerequisiteIds.every(conceptIds.contains), isTrue);
      expect(content.lessons[concept.lessonId]?.unitId, isNotNull);
    }
  });
}
