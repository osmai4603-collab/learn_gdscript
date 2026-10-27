import 'dart:io';

import 'audit_context.dart';
import 'audit_models.dart';
import 'checkers/concept_map_checker.dart';
import 'checkers/directives_checker.dart';
import 'checkers/duplicate_checker.dart';
import 'checkers/links_checker.dart';
import 'checkers/multiple_choice_checker.dart';
import 'checkers/schema_checker.dart';
import 'checkers/test_case_checker.dart';
import 'checkers/time_and_challenge_checker.dart';

class CurriculumAuditor {
  CurriculumAuditor(this.root);

  final Directory root;

  Future<AuditReport> run({
    String? unitFilter,
    bool checkLinks = false,
  }) async {
    final report = AuditReport();
    final context = AuditContext(root, report);
    await context.load(unitFilter: unitFilter);
    checkSchema(context);
    checkDuplicates(context);
    checkMultipleChoice(context);
    checkTestCases(context);
    checkDirectives(context);
    checkConceptMap(context);
    checkTimeAndChallenge(context);
    await checkDocumentationLinks(context, checkNetwork: checkLinks);
    return report;
  }
}
