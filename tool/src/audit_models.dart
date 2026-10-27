enum IssueSeverity { error, warning, info }

class AuditIssue {
  const AuditIssue({
    required this.severity,
    required this.rule,
    required this.message,
    this.path,
  });

  final IssueSeverity severity;
  final String rule;
  final String message;
  final String? path;
}

class AuditReport {
  final issues = <AuditIssue>[];

  void add(
    IssueSeverity severity,
    String rule,
    String message, {
    String? path,
  }) {
    issues.add(
      AuditIssue(severity: severity, rule: rule, message: message, path: path),
    );
  }

  int count(IssueSeverity severity) =>
      issues.where((issue) => issue.severity == severity).length;

  bool get hasErrors => count(IssueSeverity.error) > 0;
}
