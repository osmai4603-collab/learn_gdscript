import '../core/source_location.dart';
import 'token_type.dart';

/// Represents a single lexical token scanned from GDScript source code.
class Token {
  /// The category of this token.
  final TokenType type;

  /// The raw source text representing this token.
  final String lexeme;

  /// The parsed runtime literal value (e.g. [int], [double], [String], [bool], `null`),
  /// or null if this token does not represent a literal.
  final Object? literal;

  /// Exact source location span of this token.
  final SourceLocation location;

  /// Creates a new [Token].
  const Token({
    required this.type,
    required this.lexeme,
    required this.location,
    this.literal,
  });

  /// Length in characters of this token.
  int get length => location.length;

  /// Starting 1-indexed line of this token.
  int get line => location.line;

  /// Starting 1-indexed column of this token.
  int get column => location.column;

  /// Starting 0-based character offset of this token.
  int get offset => location.offset;

  /// Whether this token is any keyword.
  bool get isKeyword =>
      type.index >= TokenType.kwIf.index &&
      type.index <= TokenType.kwYield.index;

  /// Whether this token is a literal value.
  bool get isLiteral =>
      type == TokenType.integerLiteral ||
      type == TokenType.floatLiteral ||
      type == TokenType.stringLiteral ||
      type == TokenType.stringNameLiteral ||
      type == TokenType.nodePathLiteral ||
      type == TokenType.multilineString ||
      type == TokenType.kwTrue ||
      type == TokenType.kwFalse ||
      type == TokenType.kwNull;

  /// Whether this token is an assignment operator.
  bool get isAssignmentOperator =>
      type == TokenType.equal ||
      type == TokenType.colonEqual ||
      type == TokenType.plusEqual ||
      type == TokenType.minusEqual ||
      type == TokenType.starEqual ||
      type == TokenType.slashEqual ||
      type == TokenType.percentEqual ||
      type == TokenType.starStarEqual ||
      type == TokenType.ampersandEqual ||
      type == TokenType.pipeEqual ||
      type == TokenType.caretEqual ||
      type == TokenType.shiftLeftEqual ||
      type == TokenType.shiftRightEqual;

  /// Whether this token is a binary operator.
  bool get isBinaryOperator =>
      type == TokenType.plus ||
      type == TokenType.minus ||
      type == TokenType.star ||
      type == TokenType.slash ||
      type == TokenType.percent ||
      type == TokenType.starStar ||
      type == TokenType.equalEqual ||
      type == TokenType.bangEqual ||
      type == TokenType.less ||
      type == TokenType.greater ||
      type == TokenType.lessEqual ||
      type == TokenType.greaterEqual ||
      type == TokenType.kwAnd ||
      type == TokenType.kwOr ||
      type == TokenType.kwIn ||
      type == TokenType.kwIs ||
      type == TokenType.kwAs ||
      type == TokenType.ampersand ||
      type == TokenType.pipe ||
      type == TokenType.caret ||
      type == TokenType.shiftLeft ||
      type == TokenType.shiftRight;

  @override
  String toString() {
    final lit = literal != null ? ' ($literal)' : '';
    return 'Token($type, "$lexeme"$lit at ${location.line}:${location.column})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          lexeme == other.lexeme &&
          literal == other.literal &&
          location == other.location;

  @override
  int get hashCode => Object.hash(type, lexeme, literal, location);
}
