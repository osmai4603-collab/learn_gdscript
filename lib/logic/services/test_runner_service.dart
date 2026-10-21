import '../../data/models/exercise_models.dart';
import 'code_runner_service.dart';

class TestCaseResult {
  const TestCaseResult({
    required this.testCase,
    required this.passed,
    required this.actualOutput,
    required this.error,
  });

  final ExerciseTestCase testCase;
  final bool passed;
  final String actualOutput;
  final String? error;
}

class ExerciseResult {
  ExerciseResult({required List<TestCaseResult> testResults})
    : testResults = List.unmodifiable(testResults);

  final List<TestCaseResult> testResults;
  int get passedCount => testResults.where((result) => result.passed).length;
  int get totalCount => testResults.length;
  bool get allPassed => testResults.isNotEmpty && passedCount == totalCount;
}

class TestRunnerService {
  const TestRunnerService(this._codeRunner);

  final CodeRunnerService _codeRunner;

  Future<ExerciseResult> runTests({
    required String userCode,
    required List<ExerciseTestCase> testCases,
  }) async {
    final results = <TestCaseResult>[];
    for (final testCase in testCases) {
      final code = testCase.setupCode == null
          ? userCode
          : '${testCase.setupCode}\n$userCode';
      final runResult = await _codeRunner.runCode(code);
      final actual = runResult.output.join('\n');
      final expected = testCase.expectedOutput;
      final passed =
          runResult.isSuccess &&
          _normalize(actual, testCase) == _normalize(expected, testCase);
      results.add(
        TestCaseResult(
          testCase: testCase,
          passed: passed,
          actualOutput: actual,
          error: runResult.errorMessage,
        ),
      );
    }
    return ExerciseResult(testResults: results);
  }

  static String _normalize(String value, ExerciseTestCase testCase) {
    var normalized = value;
    if (testCase.ignoreWhitespace) {
      normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    if (testCase.ignoreCase) normalized = normalized.toLowerCase();
    return normalized;
  }
}
