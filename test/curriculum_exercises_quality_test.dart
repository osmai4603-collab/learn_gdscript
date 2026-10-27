import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/curriculum_models.dart';
import 'package:learn_gdscript/data/models/lesson_models.dart';
import 'package:learn_gdscript/logic/services/code_runner_service.dart';
import 'package:learn_gdscript/logic/services/test_runner_service.dart';

void main() {
  test('reference solutions pass every curriculum test case', () async {
    final codeRunner = CodeRunnerService();
    addTearDown(codeRunner.dispose);
    final testRunner = TestRunnerService(codeRunner);
    final manifest = Curriculum.fromJson(
      _readObject('assets/curriculum/manifest.json'),
    );
    final failures = <String>[];
    var testedCases = 0;

    for (final unit in manifest.units) {
      final unitDirectory = unit.id.substring('unit_'.length);
      for (final lessonId in unit.lessonIds) {
        final lesson = Lesson.fromJson(
          _readObject(
            'assets/curriculum/units/$unitDirectory/$lessonId.json',
          ),
        );
        for (final exercise in lesson.exercises) {
          if (exercise.testCases.isEmpty) continue;
          testedCases += exercise.testCases.length;
          final result = await testRunner.runTests(
            userCode: exercise.solutionCode,
            testCases: exercise.testCases,
          );
          for (final testResult in result.testResults.where(
            (testResult) => !testResult.passed,
          )) {
            failures.add(
              '${exercise.id}: ${testResult.testCase.description.en}; '
              'expected "${testResult.testCase.expectedOutput}", '
              'got "${testResult.actualOutput}"'
              '${testResult.error == null ? '' : ' (${testResult.error})'}',
            );
          }
        }
      }
    }

    expect(testedCases, greaterThan(0));
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}

Map<String, Object?> _readObject(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is! Map) fail('Expected "$path" to contain a JSON object.');
  return Map<String, Object?>.from(decoded);
}
