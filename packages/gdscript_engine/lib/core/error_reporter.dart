import 'diagnostic.dart';
import 'source_location.dart';

/// Central collector and manager for engine diagnostics (errors, warnings, hints).
class ErrorReporter {
  final List<Diagnostic> _diagnostics = [];

  /// Maximum allowed errors before aborting compilation (default 100).
  final int maxErrors;

  /// Creates a new [ErrorReporter] with optional [maxErrors] limit.
  ErrorReporter({this.maxErrors = 100});

  /// Read-only view of recorded diagnostics in insertion order.
  List<Diagnostic> get diagnostics => List.unmodifiable(_diagnostics);

  /// Returns diagnostics sorted by location (line, column, offset).
  List<Diagnostic> get sortedDiagnostics => List.of(_diagnostics)..sort();

  /// Whether any error-severity diagnostic has been reported.
  bool get hasErrors =>
      _diagnostics.any((d) => d.severity == DiagnosticSeverity.error);

  /// Whether any warning-severity diagnostic has been reported.
  bool get hasWarnings =>
      _diagnostics.any((d) => d.severity == DiagnosticSeverity.warning);

  /// Total count of error diagnostics.
  int get errorCount =>
      _diagnostics.where((d) => d.severity == DiagnosticSeverity.error).length;

  /// Total count of warning diagnostics.
  int get warningCount => _diagnostics
      .where((d) => d.severity == DiagnosticSeverity.warning)
      .length;

  /// Reports a single [diagnostic].
  void report(Diagnostic diagnostic) {
    if (errorCount >= maxErrors &&
        diagnostic.severity == DiagnosticSeverity.error) {
      return;
    }
    _diagnostics.add(diagnostic);
  }

  /// Adds a collection of [diagnostics].
  void addAll(Iterable<Diagnostic> items) {
    for (final item in items) {
      report(item);
    }
  }

  /// Convenience method to report an error diagnostic.
  void error(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) {
    report(Diagnostic.error(message, location, hint: hint, code: code));
  }

  /// Convenience method to report a warning diagnostic.
  void warning(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) {
    report(Diagnostic.warning(message, location, hint: hint, code: code));
  }

  /// Convenience method to report an informational diagnostic.
  void info(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) {
    report(Diagnostic.info(message, location, hint: hint, code: code));
  }

  /// Convenience method to report a hint diagnostic.
  void hint(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) {
    report(Diagnostic.hint(message, location, hint: hint, code: code));
  }

  /// Clears all recorded diagnostics.
  void clear() => _diagnostics.clear();

  /// Formats all diagnostics into a readable multi-line report.
  String formatAll({bool includeSource = true}) {
    if (_diagnostics.isEmpty) return 'No diagnostics reported.';

    final buffer = StringBuffer();
    final sorted = sortedDiagnostics;
    for (var i = 0; i < sorted.length; i++) {
      buffer.writeln(sorted[i].format(includeSource: includeSource));
      if (i < sorted.length - 1) {
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  @override
  String toString() =>
      'ErrorReporter(errors: $errorCount, warnings: $warningCount, total: ${_diagnostics.length})';
}
