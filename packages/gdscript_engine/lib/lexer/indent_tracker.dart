import '../core/error_reporter.dart';
import '../core/source_location.dart';
import 'token.dart';
import 'token_type.dart';

/// Manages indentation level tracking and produces [TokenType.indent] and
/// [TokenType.dedent] tokens according to GDScript syntax rules.
///
/// Features:
/// - Maintains an indentation depth stack initialized to `[0]`.
/// - Tracks nesting depth of parentheses, brackets, and braces to suppress
///   indentation tokens within expressions.
/// - Validates that dedentation levels align with previously established block depths.
/// - Flushes remaining dedents at end-of-file.
class IndentTracker {
  /// Stack of indentation column depths.
  final List<int> _stack = [0];

  /// Active nesting level of parentheses, brackets, and braces.
  int _bracketDepth = 0;

  /// Width in spaces attributed to a tab character (standard GDScript/Godot is 4).
  final int tabWidth;

  /// Creates a new [IndentTracker].
  IndentTracker({this.tabWidth = 4});

  /// Current nesting depth of grouping brackets.
  int get bracketDepth => _bracketDepth;

  /// Whether scanning is currently within open brackets/parentheses.
  bool get isInsideBrackets => _bracketDepth > 0;

  /// Current indentation level (top of stack).
  int get currentIndentLevel => _stack.last;

  /// Increment bracket nesting depth upon encountering `(`, `[`, or `{`.
  void openBracket() => _bracketDepth++;

  /// Decrement bracket nesting depth upon encountering `)`, `]`, or `}`.
  void closeBracket() {
    if (_bracketDepth > 0) {
      _bracketDepth--;
    }
  }

  /// Evaluates the leading whitespace width of a new logical line.
  ///
  /// Returns a list of generated [Token]s ([TokenType.indent] or [TokenType.dedent]).
  List<Token> processIndentation({
    required int indentWidth,
    required SourceLocation location,
    required ErrorReporter reporter,
  }) {
    // Inside brackets, indentation is ignored (implicit line joining)
    if (isInsideBrackets) return const [];

    final tokens = <Token>[];
    final current = currentIndentLevel;

    if (indentWidth > current) {
      _stack.add(indentWidth);
      tokens.add(Token(type: TokenType.indent, lexeme: '', location: location));
    } else if (indentWidth < current) {
      var matched = false;
      while (_stack.length > 1 && _stack.last > indentWidth) {
        _stack.removeLast();
        tokens.add(
          Token(type: TokenType.dedent, lexeme: '', location: location),
        );
        if (_stack.last == indentWidth) {
          matched = true;
          break;
        }
      }

      if (!matched && _stack.last != indentWidth) {
        reporter.error(
          'IndentationError: Unaligned dedent level. Expected ${_stack.last} or an existing block depth, found $indentWidth.',
          location,
          hint: 'Ensure indentation uses consistent tabs or spaces.',
          code: 'GD1001',
        );
      }
    }

    return tokens;
  }

  /// Emits any remaining [TokenType.dedent] tokens at end of file.
  List<Token> flushAtEof(SourceLocation eofLocation) {
    final tokens = <Token>[];
    while (_stack.length > 1) {
      _stack.removeLast();
      tokens.add(
        Token(type: TokenType.dedent, lexeme: '', location: eofLocation),
      );
    }
    return tokens;
  }

  /// Resets indentation tracker to initial state.
  void reset() {
    _stack.clear();
    _stack.add(0);
    _bracketDepth = 0;
  }
}
