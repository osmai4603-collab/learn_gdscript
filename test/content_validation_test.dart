import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/curriculum_models.dart';
import 'package:learn_gdscript/data/models/lesson_models.dart';
import 'package:learn_gdscript/data/repositories/syntax_reference_repository.dart';

void main() {
  test('curriculum and syntax reference content is complete and linked', () {
    final curriculumJson = _readObject('assets/curriculum/manifest.json');
    final curriculum = Curriculum.fromJson(curriculumJson);
    final unitIds = curriculum.units.map((unit) => unit.id).toSet();
    expect(curriculum.units, hasLength(5));
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
      hasLength(5),
    );
    expect(
      Directory('assets/curriculum/units')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.json') && file.path.contains('/lesson_'),
          ),
      hasLength(14),
    );

    final lessonsById = <String, Lesson>{};
    final exercisesById = <String, String>{};
    final exerciseTypes = <String, int>{};
    for (final unit in curriculum.units) {
      final unitJson = _readObject(
        'assets/curriculum/units/${_unitDirectory(unit.order)}/unit.json',
      );
      expect(Unit.fromJson(unitJson).toJson(), unit.toJson());
      expect(unit.lessonIds, isNotEmpty);

      final unitLessons = <Lesson>[];
      for (final lessonId in unit.lessonIds) {
        final lessonPath =
            'assets/curriculum/units/${_unitDirectory(unit.order)}/'
            '${_lessonFileName(lessonId)}.json';
        final lesson = Lesson.fromJson(_readObject(lessonPath));
        expect(lesson.id, lessonId);
        expect(lesson.unitId, unit.id);
        expect(lessonsById.containsKey(lesson.id), isFalse);
        lessonsById[lesson.id] = lesson;
        unitLessons.add(lesson);

        for (final exercise in lesson.exercises) {
          expect(exercise.lessonId, lesson.id);
          expect(exercisesById.containsKey(exercise.id), isFalse);
          exercisesById[exercise.id] = lesson.id;
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
          expect(exercise.testCases, isNotEmpty, reason: exercise.id);
        }
      }
      expect(
        unitLessons.map((lesson) => lesson.order).toList(),
        List.generate(unitLessons.length, (index) => index),
      );
    }

    expect(lessonsById, hasLength(14));
    expect(exercisesById, hasLength(40));
    for (final lesson in lessonsById.values) {
      expect(
        lesson.exercises.map((exercise) => exercise.order).toList(),
        List.generate(lesson.exercises.length, (index) => index),
      );
    }

    expect(exerciseTypes['writeCode'] ?? 0, greaterThanOrEqualTo(15));
    expect(exerciseTypes['predictOutput'] ?? 0, greaterThanOrEqualTo(6));
    expect(exerciseTypes['fillBlank'] ?? 0, greaterThanOrEqualTo(3));
    expect(exerciseTypes['fixBug'] ?? 0, greaterThanOrEqualTo(3));
    expect(exerciseTypes['reorderSteps'] ?? 0, greaterThanOrEqualTo(2));

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

String _unitDirectory(int order) =>
    '${(order + 1).toString().padLeft(2, '0')}_'
    '${const ['first_program', 'variables', 'conditions', 'loops', 'functions'][order]}';

String _lessonFileName(String lessonId) {
  const fileNames = {
    'lesson_01_hello': 'lesson_01_hello',
    'lesson_02_comments': 'lesson_02_comments',
    'lesson_03_variables': 'lesson_03_variables',
    'lesson_04_types': 'lesson_04_types',
    'lesson_05_operations': 'lesson_05_operations',
    'lesson_06_if_else': 'lesson_06_if_else',
    'lesson_07_elif': 'lesson_07_elif',
    'lesson_08_match': 'lesson_08_match',
    'lesson_09_for': 'lesson_09_for',
    'lesson_10_while': 'lesson_10_while',
    'lesson_11_break_continue': 'lesson_11_break_continue',
    'lesson_12_func_basics': 'lesson_12_func_basics',
    'lesson_13_parameters': 'lesson_13_parameters',
    'lesson_14_return': 'lesson_14_return',
  };
  final fileName = fileNames[lessonId];
  if (fileName == null) fail('Unknown lesson "$lessonId".');
  return fileName;
}

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
