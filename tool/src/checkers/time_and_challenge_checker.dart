import '../audit_context.dart';
import '../audit_models.dart';
import '../config/validation_rules.dart';

void checkTimeAndChallenge(AuditContext context) {
  for (final record in context.lessons) {
    final lesson = record.lesson;
    if (lesson.estimatedMinutes < minimumLessonMinutes ||
        lesson.estimatedMinutes > maximumLessonMinutes) {
      context.report.add(
        IssueSeverity.error,
        'estimated-time-range',
        'estimatedMinutes must be between $minimumLessonMinutes and '
            '$maximumLessonMinutes; found ${lesson.estimatedMinutes}.',
        path: context.pathFor(record.file),
      );
    }
  }

  for (final unit in context.units) {
    final lessons =
        context.lessons.where((record) => record.unit.id == unit.id).toList()
          ..sort((a, b) => a.lesson.order.compareTo(b.lesson.order));
    if (lessons.isEmpty) continue;
    final finalLesson = lessons.last.lesson;
    if (unit.order < 11) {
      final capstones = finalLesson.exercises
          .where((exercise) => exercise.order == 9)
          .toList();
      if (capstones.length != 1 ||
          capstones.single.type != 'writeCode' ||
          capstones.single.testCases.length < 3) {
        context.report.add(
          IssueSeverity.error,
          'unit-capstone',
          'Final lesson "${finalLesson.id}" must have one order-9 coding '
              'capstone with at least three test cases.',
          path:
              'assets/curriculum/units/${lessons.last.unitDirectory}/unit.json',
        );
      }
    }
    final challenge = finalLesson.exercises.any((exercise) {
      final prompt = '${exercise.prompt.ar} ${exercise.prompt.en}'
          .toLowerCase();
      return (exercise.order == 9 &&
              exercise.type == 'writeCode' &&
              exercise.testCases.length >= 3) ||
          exercise.type == 'guidedTask' ||
          prompt.contains('مشروع') ||
          prompt.contains('تكاملي') ||
          prompt.contains('cumulative') ||
          prompt.contains('integrated') ||
          prompt.contains('capstone');
    });
    if (!challenge) {
      context.report.add(
        IssueSeverity.warning,
        'cumulative-challenge',
        'Final lesson "${finalLesson.id}" has no detectable cumulative challenge.',
        path: 'assets/curriculum/units/${lessons.last.unitDirectory}/unit.json',
      );
    }
  }
}
