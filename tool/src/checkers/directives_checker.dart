import '../audit_context.dart';
import '../audit_models.dart';
import '../config/validation_rules.dart';

void checkDirectives(AuditContext context) {
  for (final record in context.lessons) {
    final content = record.lesson.contentMarkdown.ar;
    if (!RegExp(directivePattern).hasMatch(content)) {
      context.report.add(
        IssueSeverity.warning,
        'directives',
        'Lesson has no [!WARNING], [!NOTE], or [!TIP] directive.',
        path: context.pathFor(record.file),
      );
    }
  }
}
