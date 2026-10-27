import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/exercise_models.dart';
import 'package:learn_gdscript/data/models/lesson_models.dart';

void main() {
  test('authoring template matches the lesson model and quality criteria', () {
    final decoded = jsonDecode(
      File('docs/templates/lesson_template.json').readAsStringSync(),
    );
    expect(decoded, isA<Map>());
    final lesson = Lesson.fromJson(Map<String, Object?>.from(decoded as Map));

    expect(lesson.exercises, hasLength(10));
    expect(
      lesson.exercises.map((exercise) => exercise.type).toSet(),
      hasLength(6),
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.writeCode),
      hasLength(4),
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.multipleChoice),
      hasLength(2),
    );
    expect(
      lesson.exercises.where((exercise) => exercise.type == ExerciseType.fixBug),
      hasLength(1),
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.predictOutput),
      hasLength(1),
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.fillBlank),
      hasLength(1),
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.reorderSteps),
      hasLength(1),
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.fixBug)
          .every((exercise) => exercise.testCases.length >= 2),
      isTrue,
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.writeCode)
          .every((exercise) => exercise.testCases.length >= 2),
      isTrue,
    );
    expect(
      lesson.exercises.every((exercise) => exercise.hints.length == 3),
      isTrue,
    );
    expect(
      lesson.exercises
          .where((exercise) => exercise.type == ExerciseType.multipleChoice)
          .every((exercise) => exercise.correctOptionIndex != 0),
      isTrue,
    );
    expect(lesson.documentationSources.single.url, contains('/en/4.3/'));
    for (final section in [
      'المفهوم',
      'الصياغة',
      'مثال عملي',
      'أخطاء شائعة',
      'قاعدة ذهبية',
    ]) {
      expect(lesson.contentMarkdown.ar, contains(section));
    }
    for (final section in [
      'Concept and goal',
      'Syntax and rules',
      'Explained practical example',
      'Common errors and warnings',
      'Golden rule and summary',
      '[!WARNING]',
      '[!NOTE]',
      '[!TIP]',
    ]) {
      expect(lesson.contentMarkdown.en, contains(section));
    }
    for (final directive in ['[!WARNING]', '[!NOTE]', '[!TIP]']) {
      expect(lesson.contentMarkdown.ar, contains(directive));
    }
  });
}
