import '../audit_context.dart';
import '../audit_models.dart';
import '../config/validation_rules.dart';

void checkSchema(AuditContext context) {
  final lessonIds = <String>{};
  final globalExerciseIds = <String>{};
  for (final record in context.lessons) {
    final lesson = record.lesson;
    if (!lessonIds.add(lesson.id)) {
      context.report.add(
        IssueSeverity.error,
        'identifiers',
        'Duplicate lesson ID "${lesson.id}".',
        path: context.pathFor(record.file),
      );
    }
    if (lesson.id != record.file.uri.pathSegments.last.replaceFirst('.json', '')) {
      context.report.add(
        IssueSeverity.error,
        'identifiers',
        'Lesson ID "${lesson.id}" does not match its filename.',
        path: context.pathFor(record.file),
      );
    }
    if (lesson.unitId != record.unit.id) {
      context.report.add(
        IssueSeverity.error,
        'identifiers',
        'Lesson unitId "${lesson.unitId}" does not match "${record.unit.id}".',
        path: context.pathFor(record.file),
      );
    }
    if (lesson.documentationSources.isEmpty) {
      context.report.add(
        IssueSeverity.warning,
        'documentation-links',
        'Lesson has no documentation sources.',
        path: context.pathFor(record.file),
      );
    }
    final lessonExerciseIds = <String>{};
    for (final exercise in lesson.exercises) {
      if (exercise.lessonId != lesson.id) {
        context.report.add(
          IssueSeverity.error,
          'identifiers',
          'Exercise "${exercise.id}" refers to lesson "${exercise.lessonId}".',
          path: context.pathFor(record.file),
        );
      }
      if (!lessonExerciseIds.add(exercise.id)) {
        context.report.add(
          IssueSeverity.error,
          'identifiers',
          'Duplicate exercise ID "${exercise.id}" in lesson "${lesson.id}".',
          path: context.pathFor(record.file),
        );
        continue;
      }
      if (!globalExerciseIds.add(exercise.id)) {
        context.report.add(
          IssueSeverity.error,
          'identifiers',
          'Exercise ID "${exercise.id}" is not unique across the curriculum.',
          path: context.pathFor(record.file),
        );
      }
    }
    final orders = lesson.exercises.map((exercise) => exercise.order).toList();
    if (orders.toSet().length != orders.length) {
      context.report.add(
        IssueSeverity.error,
        'schema',
        'Exercise order values must be unique.',
        path: context.pathFor(record.file),
      );
    }
    _checkLessonSections(context, record);
  }
}

void _checkLessonSections(AuditContext context, LessonRecord record) {
  final arabic = record.lesson.contentMarkdown.ar;
  final missing = <String>[];
  for (final entry in requiredArabicSectionPatterns.entries) {
    if (!entry.value.any(arabic.contains)) missing.add(entry.key);
  }
  if (missing.isNotEmpty) {
    context.report.add(
      IssueSeverity.warning,
      'five-sections',
      'Missing or unrecognized required Arabic sections: ${missing.join(', ')}.',
      path: context.pathFor(record.file),
    );
  }
}
