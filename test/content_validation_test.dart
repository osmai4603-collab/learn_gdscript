import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/curriculum_models.dart';
import 'package:learn_gdscript/data/models/exercise_models.dart';
import 'package:learn_gdscript/data/models/lesson_models.dart';
import 'package:learn_gdscript/data/repositories/syntax_reference_repository.dart';

void main() {
  test('curriculum and syntax reference content is complete and linked', () {
    final curriculumJson = _readObject('assets/curriculum/manifest.json');
    final curriculum = Curriculum.fromJson(curriculumJson);
    final unitIds = curriculum.units.map((unit) => unit.id).toSet();
    expect(curriculum.units, hasLength(12));
    expect(unitIds, hasLength(curriculum.units.length));
    expect(
      curriculum.units.map((unit) => unit.order).toList(),
      List.generate(curriculum.units.length, (index) => index),
    );
    expect(
      Directory('assets/curriculum/units')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('/unit.json')),
      hasLength(12),
    );

    final lessonsById = <String, Lesson>{};
    final exercisesById = <String, String>{};
    final exerciseTypes = <String, int>{};
    for (final unit in curriculum.units) {
      final unitJson = _readObject(
        'assets/curriculum/units/${_unitDirectory(unit)}/unit.json',
      );
      expect(Unit.fromJson(unitJson).toJson(), unit.toJson());
      expect(unit.lessonIds, isNotEmpty);

      final unitLessons = <Lesson>[];
      for (final lessonId in unit.lessonIds) {
        final lessonPath =
            'assets/curriculum/units/${_unitDirectory(unit)}/$lessonId.json';
        final lesson = Lesson.fromJson(_readObject(lessonPath));
        expect(lesson.id, lessonId);
        expect(lesson.unitId, unit.id);
        expect(lesson.documentation, isNotNull, reason: lesson.id);
        expect(lesson.documentationSources, isNotEmpty, reason: lesson.id);
        for (final source in lesson.documentationSources) {
          expect(
            source.url,
            startsWith('https://docs.godotengine.org/'),
            reason: '${lesson.id}: ${source.url}',
          );
        }
        expect(
          lesson.exercises,
          hasLength(10),
          reason: '${lesson.id} must have ten exercises',
        );
        expect(lessonsById.containsKey(lesson.id), isFalse);
        lessonsById[lesson.id] = lesson;
        unitLessons.add(lesson);

        final lessonExerciseTypes = <ExerciseType>{};
        for (final exercise in lesson.exercises) {
          expect(exercise.lessonId, lesson.id);
          expect(exercisesById.containsKey(exercise.id), isFalse);
          exercisesById[exercise.id] = lesson.id;
          lessonExerciseTypes.add(exercise.type);
          exerciseTypes.update(
            exercise.type.name,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
          expect(
            exercise.hints.length,
            inInclusiveRange(2, 4),
            reason: exercise.id,
          );
          if (exercise.type == ExerciseType.multipleChoice) {
            expect(exercise.options.length, greaterThanOrEqualTo(2));
            expect(exercise.correctOptionIndex, isNotNull);
            expect(exercise.testCases, isEmpty, reason: exercise.id);
          } else if (exercise.type == ExerciseType.guidedTask) {
            expect(exercise.steps, isNotEmpty, reason: exercise.id);
            expect(exercise.testCases, isEmpty, reason: exercise.id);
          } else {
            expect(exercise.testCases, isNotEmpty, reason: exercise.id);
            if (unit.order >= 5) {
              expect(
                exercise.testCases.length,
                greaterThanOrEqualTo(3),
                reason: exercise.id,
              );
            }
          }
        }
        if (unit.order >= 5) {
          expect(
            lessonExerciseTypes,
            hasLength(7),
            reason: '${lesson.id} should use all supported exercise types',
          );
        }
      }
      expect(
        unitLessons.map((lesson) => lesson.order).toList(),
        List.generate(unitLessons.length, (index) => index),
      );
    }

    expect(lessonsById, hasLength(51));
    expect(exercisesById, hasLength(510));
    for (final lesson in lessonsById.values) {
      expect(
        lesson.exercises.map((exercise) => exercise.order).toList(),
        List.generate(lesson.exercises.length, (index) => index),
      );
    }
    final lessonFiles = Directory('assets/curriculum/units')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.json') && file.path.contains('/lesson_'),
        );
    expect(lessonFiles, hasLength(51));

    expect(exerciseTypes['writeCode'] ?? 0, greaterThanOrEqualTo(15));
    expect(exerciseTypes['predictOutput'] ?? 0, greaterThanOrEqualTo(6));
    expect(exerciseTypes['fillBlank'] ?? 0, greaterThanOrEqualTo(3));
    expect(exerciseTypes['fixBug'] ?? 0, greaterThanOrEqualTo(3));
    expect(exerciseTypes['reorderSteps'] ?? 0, greaterThanOrEqualTo(2));
    expect(exerciseTypes['multipleChoice'] ?? 0, greaterThan(0));
    expect(exerciseTypes['guidedTask'] ?? 0, greaterThan(0));

    final syntaxManifest = _readObject('assets/syntax_reference/manifest.json');
    final references = <SyntaxReference>[];
    for (final entry in syntaxManifest['entries'] as List) {
      final manifestEntry = Map<String, Object?>.from(entry as Map);
      final path = 'assets/syntax_reference/${manifestEntry['file'] as String}';
      final items = jsonDecode(File(path).readAsStringSync()) as List;
      expect(items, hasLength(manifestEntry['count'] as int), reason: path);
      references.addAll(
        items.map(
          (item) =>
              SyntaxReference.fromJson(Map<String, Object?>.from(item as Map)),
        ),
      );
    }
    expect(references, hasLength(37));
    for (final reference in references) {
      if (reference.relatedLesson != null) {
        expect(
          lessonsById.containsKey(reference.relatedLesson),
          isTrue,
          reason: reference.id,
        );
      }
    }

    final localizedJsonFiles = [
      ...Directory('assets/curriculum').listSync(recursive: true),
      ...Directory('assets/syntax_reference').listSync(recursive: true),
    ].whereType<File>().where((file) => file.path.endsWith('.json'));
    for (final file in localizedJsonFiles) {
      _checkLocalizedValues(jsonDecode(file.readAsStringSync()), file.path);
    }
  });
}

String _unitDirectory(Unit unit) => unit.id.substring('unit_'.length);

Map<String, Object?> _readObject(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is! Map) fail('Expected "$path" to contain a JSON object.');
  return Map<String, Object?>.from(decoded);
}

void _checkLocalizedValues(Object? value, String path) {
  if (value is Map) {
    if (value.containsKey('ar') || value.containsKey('en')) {
      expect(value.keys, containsAll(['ar', 'en']), reason: path);
      for (final language in ['ar', 'en']) {
        expect(value[language], isA<String>(), reason: '$path ($language)');
        expect(
          (value[language] as String).trim(),
          isNotEmpty,
          reason: '$path ($language)',
        );
      }
    }
    for (final nestedValue in value.values) {
      _checkLocalizedValues(nestedValue, path);
    }
  } else if (value is List) {
    for (final item in value) {
      _checkLocalizedValues(item, path);
    }
  }
}
