import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/exercise_models.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';
import 'package:learn_gdscript/logic/services/code_runner_service.dart';
import 'package:learn_gdscript/logic/services/hint_service.dart';
import 'package:learn_gdscript/logic/services/test_runner_service.dart';

void main() {
  test('code runner preserves output and execution diagnostics', () async {
    final service = CodeRunnerService();
    addTearDown(service.dispose);

    final result = await service.runCode('print("hello")');
    expect(result.isSuccess, isTrue);
    expect(result.output, ['hello']);
    expect(result.executionTime, isA<Duration>());
    expect(result.instructionsExecuted, greaterThanOrEqualTo(0));

    final failure = await service.runCode('var value: =');
    expect(failure.isSuccess, isFalse);
    expect(failure.errorMessage, isNotNull);
    expect(failure.diagnostics, isNotEmpty);
  });

  test(
    'test runner applies whitespace and case options independently',
    () async {
      final runner = CodeRunnerService();
      addTearDown(runner.dispose);
      final service = TestRunnerService(runner);
      final whitespaceResult = await service.runTests(
        userCode: 'print(2)',
        testCases: const [
          ExerciseTestCase(
            description: LocalizedText(ar: 'مسافات', en: 'Whitespace'),
            setupCode: 'var number = 2',
            expectedOutput: '  2  ',
            ignoreWhitespace: true,
          ),
        ],
      );
      final caseResult = await service.runTests(
        userCode: 'print("hello")',
        testCases: const [
          ExerciseTestCase(
            description: LocalizedText(ar: 'حالة الحروف', en: 'Case'),
            expectedOutput: 'HELLO',
            ignoreCase: true,
          ),
          ExerciseTestCase(
            description: LocalizedText(ar: 'مقارنة دقيقة', en: 'Exact'),
            expectedOutput: 'hello ',
          ),
        ],
      );

      expect(whitespaceResult.testResults.single.passed, isTrue);
      expect(caseResult.totalCount, 2);
      expect(caseResult.passedCount, 1);
      expect(caseResult.allPassed, isFalse);
      expect(caseResult.testResults.map((item) => item.passed), [true, false]);
    },
  );

  test(
    'runner exposes empty tests as untested and returns ordered hints',
    () async {
      final runner = CodeRunnerService();
      addTearDown(runner.dispose);
      final testRunner = TestRunnerService(runner);
      expect(
        (await testRunner.runTests(
          userCode: '',
          testCases: const [],
        )).allPassed,
        isFalse,
      );

      final exercise = Exercise(
        id: 'exercise',
        lessonId: 'lesson',
        type: ExerciseType.writeCode,
        prompt: const LocalizedText(ar: 'اكتب', en: 'Write'),
        starterCode: '',
        solutionCode: 'print("answer")',
        testCases: const [],
        hints: const [
          LocalizedText(ar: 'الأول', en: 'First'),
          LocalizedText(ar: 'الثاني', en: 'Second'),
        ],
        order: 0,
      );
      const hints = HintService();
      expect(hints.nextHint(exercise, hintsAlreadyShown: 0)?.en, 'First');
      expect(hints.nextHint(exercise, hintsAlreadyShown: 1)?.en, 'Second');
      expect(hints.nextHint(exercise, hintsAlreadyShown: 2), isNull);
      expect(
        () => hints.nextHint(exercise, hintsAlreadyShown: -1),
        throwsArgumentError,
      );
    },
  );
}
