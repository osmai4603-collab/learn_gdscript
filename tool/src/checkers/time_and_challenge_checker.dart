import 'dart:math' as math;

import '../audit_context.dart';
import '../audit_models.dart';
import '../config/validation_rules.dart';

void checkTimeAndChallenge(AuditContext context) {

  int wordCount(String text) =>
      text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  for (final record in context.lessons) {
    final lesson = record.lesson;
    final arabicWords = wordCount(lesson.contentMarkdown.ar);
    final englishWords = wordCount(lesson.contentMarkdown.en);
    final readingMinutes = (math.max(arabicWords, englishWords) + 99) ~/ 100;
    final practiceMinutes = (lesson.exercises.length * 3 + 3) ~/ 4;
    final expectedMinutes = math.max(
      minimumLessonMinutes,
      readingMinutes + practiceMinutes,
    );
    final minimum = math.max(
      minimumLessonMinutes,
      (expectedMinutes * 0.5).ceil(),
    );
    final maximum = math.min(
      maximumLessonMinutes,
      (expectedMinutes * 2).ceil(),
    );
    if (lesson.estimatedMinutes < minimum ||
        lesson.estimatedMinutes > maximum) {
      context.report.add(
        IssueSeverity.warning,
        'estimated-time',
        'estimatedMinutes is ${lesson.estimatedMinutes}; expected $minimum–'
            '$maximum based on lesson length and exercise count '
            '(absolute range $minimumLessonMinutes–$maximumLessonMinutes).',
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
    final challenge = finalLesson.exercises.any((exercise) {
      final prompt = '${exercise.prompt.ar} ${exercise.prompt.en}'
          .toLowerCase();
      return exercise.type == 'guidedTask' ||
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
