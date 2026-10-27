import '../audit_models.dart';

String buildMarkdownReport(AuditReport report, {required bool strict}) {
  final errors = report.count(IssueSeverity.error);
  final warnings = report.count(IssueSeverity.warning);
  final infos = report.count(IssueSeverity.info);
  final passed = errors == 0 && (!strict || warnings == 0);
  final result = !passed
      ? 'FAIL'
      : warnings > 0
      ? 'PASS WITH WARNINGS'
      : 'PASS';
  final output = StringBuffer()
    ..writeln('# Curriculum audit report')
    ..writeln()
    ..writeln('**Result:** $result')
    ..writeln()
    ..writeln('| Errors | Warnings | Informational | Strict mode |')
    ..writeln('|---:|---:|---:|:---:|')
    ..writeln('| $errors | $warnings | $infos | ${strict ? 'Yes' : 'No'} |')
    ..writeln()
    ..writeln('## Findings by rule')
    ..writeln()
    ..writeln('| Rule | Findings |')
    ..writeln('|---|---:|');
  final countsByRule = <String, int>{};
  for (final issue in report.issues) {
    countsByRule.update(issue.rule, (count) => count + 1, ifAbsent: () => 1);
  }
  for (final entry in countsByRule.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key))) {
    output.writeln('| ${entry.key} | ${entry.value} |');
  }
  output
    ..writeln()
    ..writeln('## Findings')
    ..writeln();
  if (report.issues.isEmpty) {
    output.writeln('No findings.');
  } else {
    output
      ..writeln('| Severity | Rule | Location | Finding |')
      ..writeln('|---|---|---|---|');
    for (final issue in report.issues) {
      final path = (issue.path ?? '—').replaceAll('|', r'\|');
      final message = issue.message
          .replaceAll('|', r'\|')
          .replaceAll('\n', ' ');
      output.writeln(
        '| ${issue.severity.name} | ${issue.rule} | `$path` | $message |',
      );
    }
  }
  return output.toString();
}
