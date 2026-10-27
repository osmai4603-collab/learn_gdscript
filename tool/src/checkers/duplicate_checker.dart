import '../audit_context.dart';
import '../audit_models.dart';
import '../config/validation_rules.dart';

void checkDuplicates(AuditContext context) {
  final hintOwners = <String, List<String>>{};
  final lessonOwners = <String, List<String>>{};
  for (final record in context.lessons) {
    final lesson = record.lesson;
    for (final exercise in lesson.exercises) {
      if (exercise.hints.length < minimumExerciseHints) {
        context.report.add(
          IssueSeverity.warning,
          'hint-count',
          '"${exercise.id}" has ${exercise.hints.length} hint(s); at least '
          '$minimumExerciseHints are required.',
          path: context.pathFor(record.file),
        );
      }
      final prompts = {'ar': exercise.prompt.ar, 'en': exercise.prompt.en};
      for (final entry in prompts.entries) {
        final key = '${entry.key}:${_normalize(entry.value)}';
        lessonOwners
            .putIfAbsent(key, () => [])
            .add('${lesson.id}/${exercise.id}');
        for (final phrase in prohibitedQuestionPhrases) {
          if (_normalize(entry.value).contains(_normalize(phrase))) {
            context.report.add(
              IssueSeverity.warning,
              'template-question',
              'Question matches a prohibited template phrase: "$phrase".',
              path: context.pathFor(record.file),
            );
            break;
          }
        }
      }
      for (final hint in exercise.hints) {
        for (final entry in {'ar': hint.ar, 'en': hint.en}.entries) {
          final normalized = '${entry.key}:${_normalize(entry.value)}';
          hintOwners
              .putIfAbsent(normalized, () => [])
              .add('${lesson.id}/${exercise.id}');
        }
      }
    }
  }
  for (final entry in hintOwners.entries.where((entry) => entry.value.length > 1)) {
    context.report.add(
      IssueSeverity.warning,
      'duplicate-hints',
      'Repeated hint text appears in ${entry.value.length} exercises: '
      '${entry.value.take(5).join(', ')}${entry.value.length > 5 ? ', …' : ''}.',
    );
  }
  for (final entry in lessonOwners.entries.where((entry) => entry.value.length > 1)) {
    context.report.add(
      IssueSeverity.info,
      'duplicate-prompts',
      'Identical prompt text appears in ${entry.value.length} exercises: '
      '${entry.value.take(5).join(', ')}${entry.value.length > 5 ? ', …' : ''}.',
    );
  }
}

String _normalize(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'[.,!?;:؟،ـ*_`#()\-]+'), '');
