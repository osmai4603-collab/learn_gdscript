import '../core/diagnostic.dart';
import '../core/error_reporter.dart';
import '../core/gdscript_error.dart';
import '../core/source_location.dart';
import '../lexer/token.dart';
import '../lexer/token_type.dart';

/// Exception thrown internally by the parser when an unrecoverable syntax error occurs,
/// triggering synchronization to the next statement or declaration boundary.
class ParseException extends ParseError {
  final Token token;

  ParseException({
    required String message,
    required this.token,
    super.cause,
    super.stackTrace,
  }) : super(message, location: token.location);
}

/// Helper for recording parsing diagnostics and synchronizing tokens.
class ParseErrorHandler {
  final ErrorReporter reporter;

  const ParseErrorHandler(this.reporter);

  /// Reports a syntax error at [token] and throws [ParseException].
  Never error(Token token, String message, {String? hint, String? code}) {
    reporter.report(
      Diagnostic.error(
        message,
        token.location,
        hint: hint,
        code: code ?? 'GD2001',
      ),
    );
    throw ParseException(message: message, token: token);
  }

  /// Reports a syntax error without throwing (for recoverable inline issues).
  void reportError(
    SourceLocation location,
    String message, {
    String? hint,
    String? code,
  }) {
    reporter.report(
      Diagnostic.error(message, location, hint: hint, code: code ?? 'GD2001'),
    );
  }

  /// Checks if [token] represents a statement synchronization boundary.
  static bool isSynchronizationBoundary(Token token) {
    if (token.type == TokenType.newline ||
        token.type == TokenType.dedent ||
        token.type == TokenType.semicolon ||
        token.type == TokenType.eof) {
      return true;
    }

    switch (token.type) {
      case TokenType.kwVar:
      case TokenType.kwConst:
      case TokenType.kwFunc:
      case TokenType.kwClass:
      case TokenType.kwClassName:
      case TokenType.kwExtends:
      case TokenType.kwIf:
      case TokenType.kwFor:
      case TokenType.kwWhile:
      case TokenType.kwMatch:
      case TokenType.kwReturn:
      case TokenType.kwBreak:
      case TokenType.kwContinue:
      case TokenType.kwPass:
      case TokenType.kwSignal:
      case TokenType.kwEnum:
      case TokenType.kwStatic:
      case TokenType.annotation:
        return true;
      default:
        return false;
    }
  }
}
