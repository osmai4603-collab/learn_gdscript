import 'dart:io';

import '../audit_models.dart';

void printConsoleReport(AuditReport report, {required bool strict}) {
  final failures = report.count(IssueSeverity.error) +
      (strict ? report.count(IssueSeverity.warning) : 0);
  final warnings = report.count(IssueSeverity.warning);
  stdout.writeln(
    'Curriculum audit: ${report.count(IssueSeverity.error)} error(s), '
    '$warnings warning(s), ${report.count(IssueSeverity.info)} info.',
  );
  for (final issue in report.issues) {
    final severity = issue.severity.name.toUpperCase();
    final location = issue.path == null ? '' : ' (${issue.path})';
    stdout.writeln('[$severity] ${issue.rule}: ${issue.message}$location');
  }
  stdout.writeln(
    failures == 0
        ? (warnings == 0
              ? 'Validation passed.'
              : 'Validation passed with warnings.')
        : 'Validation failed${strict && warnings > 0 ? ' in strict mode' : ''}.',
  );
}
