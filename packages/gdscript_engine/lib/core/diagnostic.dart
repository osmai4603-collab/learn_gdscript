import 'dart:math' as math;
import 'source_location.dart';

/// Severity level of a compiler diagnostic.
enum DiagnosticSeverity {
  /// Fatal compilation or runtime error preventing further processing.
  error,

  /// Warning about suspicious code or deprecated patterns.
  warning,

  /// Informational message.
  info,

  /// Code improvement suggestion or hint.
  hint,
}

/// Represents a compiler or runtime diagnostic message with location information.
class Diagnostic implements Comparable<Diagnostic> {
  /// Severity of this diagnostic.
  final DiagnosticSeverity severity;

  /// Human-readable diagnostic description.
  final String message;

  /// Exact location where this diagnostic was triggered.
  final SourceLocation location;

  /// Optional actionable hint or recommendation for fixing the issue.
  final String? hint;

  /// Optional diagnostic code identifier (e.g. 'GD1001').
  final String? code;

  /// Creates a new [Diagnostic].
  const Diagnostic({
    required this.severity,
    required this.message,
    required this.location,
    this.hint,
    this.code,
  });

  /// Creates an error diagnostic.
  factory Diagnostic.error(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) => Diagnostic(
    severity: DiagnosticSeverity.error,
    message: message,
    location: location,
    hint: hint,
    code: code,
  );

  /// Creates a warning diagnostic.
  factory Diagnostic.warning(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) => Diagnostic(
    severity: DiagnosticSeverity.warning,
    message: message,
    location: location,
    hint: hint,
    code: code,
  );

  /// Creates an info diagnostic.
  factory Diagnostic.info(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) => Diagnostic(
    severity: DiagnosticSeverity.info,
    message: message,
    location: location,
    hint: hint,
    code: code,
  );

  /// Creates a hint diagnostic.
  factory Diagnostic.hint(
    String message,
    SourceLocation location, {
    String? hint,
    String? code,
  }) => Diagnostic(
    severity: DiagnosticSeverity.hint,
    message: message,
    location: location,
    hint: hint,
    code: code,
  );

  /// Formats the diagnostic into a developer-friendly terminal/console output,
  /// including the offending source line and a caret marker.
  String format({bool includeSource = true}) {
    final buffer = StringBuffer();
    final codeTag = code != null ? ' [$code]' : '';
    final severityName = severity.name.toUpperCase();

    buffer.writeln(
      '${location.source.uri}:${location.line}:${location.column}: $severityName$codeTag: $message',
    );

    if (includeSource) {
      final lineText = location.source.getLine(location.line);
      if (lineText.isNotEmpty) {
        final lineNumStr = '${location.line}'.padLeft(4);
        buffer.writeln('$lineNumStr | $lineText');

        // Render pointer caret
        final spaces = ' ' * (math.max(0, location.column - 1));
        final prefixSpaces = '     | $spaces';
        final caretLen = math.max(1, location.length);
        final trail = caretLen > 1 ? '~' * (caretLen - 1) : '';
        final carets = '^$trail';
        buffer.writeln('$prefixSpaces$carets');
      }
    }

    if (hint != null && hint!.isNotEmpty) {
      buffer.writeln('  Hint: $hint');
    }

    return buffer.toString().trimRight();
  }

  @override
  int compareTo(Diagnostic other) {
    if (location.line != other.location.line) {
      return location.line.compareTo(other.location.line);
    }
    if (location.column != other.location.column) {
      return location.column.compareTo(other.location.column);
    }
    return location.offset.compareTo(other.location.offset);
  }

  @override
  String toString() => format(includeSource: false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Diagnostic &&
          runtimeType == other.runtimeType &&
          severity == other.severity &&
          message == other.message &&
          location == other.location &&
          hint == other.hint &&
          code == other.code;

  @override
  int get hashCode => Object.hash(severity, message, location, hint, code);
}
