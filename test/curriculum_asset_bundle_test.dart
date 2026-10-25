import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled curriculum includes every referenced lesson asset', () async {
    final repository = CurriculumRepository(assetBundle: rootBundle);
    final curriculum = await repository.loadCurriculum();

    for (final unit in curriculum.units) {
      for (final lessonId in unit.lessonIds) {
        final lesson = await repository.loadLesson(curriculum, lessonId);
        expect(lesson.id, lessonId);
        expect(lesson.unitId, unit.id);
      }
    }
  });
}
