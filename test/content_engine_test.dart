import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/lesson_models.dart';
import 'package:learn_gdscript/logic/services/code_runner_service.dart';
import 'package:learn_gdscript/logic/services/test_runner_service.dart';

void main() {
  test('curriculum lessons and solutions run in the GDScript engine', () async {
    final runner = CodeRunnerService();
    addTearDown(runner.dispose);
    final testRunner = TestRunnerService(runner);
    final files =
        Directory('assets/curriculum/units')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (file) =>
                  file.path.endsWith('.json') &&
                  !file.path.endsWith('unit.json'),
            )
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    for (final file in files) {
      final json = jsonDecode(await file.readAsString()) as Map;
      final lesson = Lesson.fromJson(Map<String, Object?>.from(json));
      if (lesson.exampleCode case final example?) {
        final result = await runner.runCode(example);
        expect(
          result.isSuccess,
          isTrue,
          reason: '${file.path}: ${result.errorMessage}',
        );
      }
      for (final exercise in lesson.exercises) {
        final result = await testRunner.runTests(
          userCode: exercise.solutionCode,
          testCases: exercise.testCases,
        );
        expect(
          result.allPassed,
          isTrue,
          reason:
              '${exercise.id}: ${result.testResults.map((test) => test.error ?? test.actualOutput).join('; ')}',
        );
      }
    }

    final manifest =
        jsonDecode(
              await File(
                'assets/syntax_reference/manifest.json',
              ).readAsString(),
            )
            as Map;
    final referenceFiles = (manifest['entries'] as List).cast<Map>().map(
      (entry) => 'assets/syntax_reference/${entry['file'] as String}',
    );
    for (final path in referenceFiles) {
      final entries = jsonDecode(await File(path).readAsString()) as List;
      for (final entry in entries.cast<Map>()) {
        final reference = Map<String, Object?>.from(entry);
        final result = await runner.runCode(reference['example'] as String);
        expect(
          result.isSuccess,
          isTrue,
          reason: '${reference['keyword']}: ${result.errorMessage}',
        );
      }
    }
  });
}
