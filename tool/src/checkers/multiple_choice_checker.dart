import '../audit_context.dart';
import '../audit_models.dart';

void checkMultipleChoice(AuditContext context) {
  for (final record in context.lessons) {
    final exercises = record.lesson.exercises
        .where((exercise) => exercise.type == 'multipleChoice')
        .toList();
    if (exercises.isEmpty) continue;
    final firstOptionCorrect = exercises
        .where((exercise) => exercise.correctOptionIndex == 0)
        .length;
    if (firstOptionCorrect / exercises.length > 0.4) {
      context.report.add(
        IssueSeverity.warning,
        'answer-distribution',
        '$firstOptionCorrect of ${exercises.length} multiple-choice answers '
        'are at index 0 (maximum 40%).',
        path: context.pathFor(record.file),
      );
    }
    for (final exercise in exercises) {
      if (exercise.options.length < 3) {
        context.report.add(
          IssueSeverity.warning,
          'answer-quality',
          'Multiple-choice exercise "${exercise.id}" has fewer than three options.',
          path: context.pathFor(record.file),
        );
      }
    }
  }
}
