import '../core/diagnostic.dart';
import '../runtime/value.dart';

/// Represents the final outcome of executing a GDScript source or chunk.
class ExecutionResult {
  /// Whether the script completed successfully without unhandled errors.
  final bool success;

  /// The value returned by the entry function (`main` or top-level return), if any.
  final GDValue? value;

  /// Standard output lines captured during execution via `print`, `prints`, etc.
  final List<String> output;

  /// Diagnostics (errors, warnings, hints) produced during lexical, syntactic,
  /// semantic, compilation, or runtime phases.
  final List<Diagnostic> diagnostics;

  /// Total elapsed execution time.
  final Duration executionTime;

  /// Number of bytecode instructions executed by the VM.
  final int instructionsExecuted;

  /// Error message if execution failed, or null.
  final String? errorMessage;

  /// Whether the execution completed successfully.
  bool get isSuccess => success;

  /// Whether the execution failed.
  bool get isFailure => !success;

  /// Whether any error diagnostics or runtime failure occurred.
  bool get hasErrors =>
      !success || diagnostics.any((d) => d.severity == DiagnosticSeverity.error);

  const ExecutionResult({
    required this.success,
    this.value,
    this.output = const [],
    this.diagnostics = const [],
    this.executionTime = Duration.zero,
    this.instructionsExecuted = 0,
    this.errorMessage,
  });

  /// Factory for a successful execution result.
  factory ExecutionResult.success({
    GDValue? value,
    List<String> output = const [],
    List<Diagnostic> diagnostics = const [],
    Duration executionTime = Duration.zero,
    int instructionsExecuted = 0,
  }) {
    return ExecutionResult(
      success: true,
      value: value,
      output: List.unmodifiable(output),
      diagnostics: List.unmodifiable(diagnostics),
      executionTime: executionTime,
      instructionsExecuted: instructionsExecuted,
    );
  }

  /// Factory for a failed execution result.
  factory ExecutionResult.failure({
    required String errorMessage,
    List<String> output = const [],
    List<Diagnostic> diagnostics = const [],
    Duration executionTime = Duration.zero,
    int instructionsExecuted = 0,
  }) {
    return ExecutionResult(
      success: false,
      errorMessage: errorMessage,
      output: List.unmodifiable(output),
      diagnostics: List.unmodifiable(diagnostics),
      executionTime: executionTime,
      instructionsExecuted: instructionsExecuted,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'ExecutionResult.success(value: $value, outputLines: ${output.length}, time: ${executionTime.inMilliseconds}ms)';
    }
    return 'ExecutionResult.failure(error: "$errorMessage", diagnostics: ${diagnostics.length})';
  }
}
