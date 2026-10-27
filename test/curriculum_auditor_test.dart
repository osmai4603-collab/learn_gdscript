import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/audit_models.dart';
import '../tool/src/curriculum_auditor.dart';
import '../tool/src/reporters/markdown_reporter.dart';
import '../tool/validate_curriculum.dart';

void main() {
  test('curriculum audit reports baseline gaps without schema errors', () async {
    final report = await CurriculumAuditor(Directory.current).run();
    final markdown = buildMarkdownReport(report, strict: false);

    expect(report.hasErrors, isFalse);
    expect(
      report.issues.where((issue) => issue.rule == 'concept-coverage'),
      hasLength(37),
    );
    expect(report.count(IssueSeverity.warning), greaterThan(0));
    expect(
      report.issues.where((issue) => issue.path?.startsWith('/') ?? false),
      isEmpty,
    );
    expect(markdown, contains('| Errors | Warnings | Informational | Strict mode |'));
    expect(markdown, contains('PASS WITH WARNINGS'));
    expect(markdown, contains('concept-coverage'));
  });

  test('CLI validates arguments, unit scope, strict mode, and report output', () async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'curriculum-audit-test-',
    );
    addTearDown(() => temporaryDirectory.delete(recursive: true));

    expect(
      await runValidationCli(
        ['--unknown'],
        rootDirectory: Directory.current,
      ),
      2,
    );
    expect(
      await runValidationCli(
        ['--unit=missing'],
        rootDirectory: Directory.current,
      ),
      1,
    );
    expect(
      await runValidationCli(
        ['--unit=01', '--strict'],
        rootDirectory: Directory.current,
      ),
      1,
    );

    final reportPath = '${temporaryDirectory.path}/audit.md';
    expect(
      await runValidationCli(
        ['--unit=01', '--output=$reportPath'],
        rootDirectory: Directory.current,
      ),
      0,
    );
    expect(
      File(reportPath).readAsStringSync(),
      contains('# Curriculum audit report'),
    );
  });
}
