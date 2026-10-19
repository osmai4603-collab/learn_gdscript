import 'source_location.dart';

/// Base class for all GDScript engine exceptions.
abstract class GDScriptError implements Exception {
  /// Description of the error.
  final String message;

  /// Optional source location where the error occurred.
  final SourceLocation? location;

  /// Human-readable category of the error (e.g. 'LexerError', 'RuntimeError').
  final String errorType;

  /// Optional underlying cause.
  final Object? cause;

  /// Optional native stack trace.
  final StackTrace? stackTrace;

  /// Const-compatible constructor for base error.
  const GDScriptError(
    this.message, {
    this.location,
    this.errorType = 'GDScriptError',
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final locStr = location != null
        ? ' at ${location!.toCoordinateString()}'
        : '';
    final causeStr = cause != null ? ' (Caused by: $cause)' : '';
    return '$errorType$locStr: $message$causeStr';
  }
}

/// Error thrown during lexical analysis (scanning tokens).
class LexerError extends GDScriptError {
  LexerError(super.message, {super.location, super.cause, super.stackTrace})
    : super(errorType: 'LexerError');
}

/// Error thrown during parsing / syntactic analysis.
class ParseError extends GDScriptError {
  ParseError(super.message, {super.location, super.cause, super.stackTrace})
    : super(errorType: 'ParseError');
}

/// Error thrown during semantic analysis or static type checking.
class TypeError extends GDScriptError {
  TypeError(super.message, {super.location, super.cause, super.stackTrace})
    : super(errorType: 'TypeError');
}

/// Error thrown when an identifier or symbol cannot be resolved.
class ResolutionError extends GDScriptError {
  ResolutionError(
    super.message, {
    super.location,
    super.cause,
    super.stackTrace,
  }) : super(errorType: 'ResolutionError');
}

/// Error thrown during bytecode compilation.
class CompileError extends GDScriptError {
  CompileError(super.message, {super.location, super.cause, super.stackTrace})
    : super(errorType: 'CompileError');
}

/// Error thrown during virtual machine execution.
class RuntimeError extends GDScriptError {
  /// GDScript call stack entries at the time of error.
  final List<String> scriptStackTrace;

  RuntimeError(
    super.message, {
    super.location,
    this.scriptStackTrace = const [],
    super.cause,
    super.stackTrace,
  }) : super(errorType: 'RuntimeError');

  @override
  String toString() {
    final base = super.toString();
    if (scriptStackTrace.isEmpty) return base;

    final buffer = StringBuffer(base);
    buffer.writeln();
    buffer.writeln('GDScript Stack Trace:');
    for (final frame in scriptStackTrace) {
      buffer.writeln('  $frame');
    }
    return buffer.toString().trimRight();
  }
}

/// Convenience alias for [RuntimeError].
typedef GDRuntimeError = RuntimeError;

