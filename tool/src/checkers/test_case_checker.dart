import '../audit_context.dart';
import '../audit_models.dart';
import '../config/validation_rules.dart';

void checkTestCases(AuditContext context) {
  for (final record in context.lessons) {
    for (final exercise in record.lesson.exercises) {
      if (exercise.type != 'writeCode' && exercise.type != 'fixBug') {
        continue;
      }
      if (exercise.testCases.length < minimumCodeTestCases) {
        context.report.add(
          IssueSeverity.warning,
          'test-cases',
          '"${exercise.id}" has ${exercise.testCases.length} test case(s); '
          'at least $minimumCodeTestCases are required.',
          path: context.pathFor(record.file),
        );
      } else {
        final distinctExpected = exercise.testCases
            .map((test) => test.expectedOutput.trim())
            .toSet()
            .length;
        final distinctSetup = exercise.testCases
            .map((test) => test.setupCode?.trim() ?? '')
            .toSet()
            .length;
        if (distinctExpected == 1 && distinctSetup == 1) {
          context.report.add(
            IssueSeverity.warning,
            'test-case-diversity',
            '"${exercise.id}" test cases do not vary expected outputs or setup.',
            path: context.pathFor(record.file),
          );
        }
      }
    }
  }
}
