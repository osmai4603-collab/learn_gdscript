import '../lexer/token_type.dart';

/// Precedence levels for Pratt parsing of expressions.
enum Precedence {
  none,
  assignment, // = += -= *= /= %= **= &= |= ^= <<= >>=
  ternary, // expr if cond else expr
  logicalOr, // or
  logicalAnd, // and
  logicalNot, // not
  inOp, // in, not in
  comparison, // == != < > <= >= is as
  bitwiseOr, // |
  bitwiseXor, // ^
  bitwiseAnd, // &
  shift, // << >>
  term, // + -
  factor, // * / %
  power, // **
  unary, // - + ~ not
  call, // . () []
  primary,
}

extension PrecedenceExtension on Precedence {
  /// Next higher precedence level.
  Precedence get higher {
    final nextIndex = index + 1;
    if (nextIndex < Precedence.values.length) {
      return Precedence.values[nextIndex];
    }
    return this;
  }
}

/// Helper for looking up precedence of infix operator tokens.
class PrecedenceTable {
  static Precedence getPrecedence(TokenType type) {
    switch (type) {
      // Assignment
      case TokenType.equal:
      case TokenType.colonEqual:
      case TokenType.plusEqual:
      case TokenType.minusEqual:
      case TokenType.starEqual:
      case TokenType.slashEqual:
      case TokenType.percentEqual:
      case TokenType.starStarEqual:
      case TokenType.ampersandEqual:
      case TokenType.pipeEqual:
      case TokenType.caretEqual:
      case TokenType.shiftLeftEqual:
      case TokenType.shiftRightEqual:
        return Precedence.assignment;

      // Ternary
      case TokenType.kwIf:
        return Precedence.ternary;

      // Logical
      case TokenType.kwOr:
        return Precedence.logicalOr;
      case TokenType.kwAnd:
        return Precedence.logicalAnd;

      // Membership & Type Checks
      case TokenType.kwIn:
        return Precedence.inOp;
      case TokenType.kwIs:
      case TokenType.kwAs:
        return Precedence.comparison;

      // Comparison
      case TokenType.equalEqual:
      case TokenType.bangEqual:
      case TokenType.less:
      case TokenType.greater:
      case TokenType.lessEqual:
      case TokenType.greaterEqual:
        return Precedence.comparison;

      // Bitwise
      case TokenType.pipe:
        return Precedence.bitwiseOr;
      case TokenType.caret:
        return Precedence.bitwiseXor;
      case TokenType.ampersand:
        return Precedence.bitwiseAnd;
      case TokenType.shiftLeft:
      case TokenType.shiftRight:
        return Precedence.shift;

      // Arithmetic
      case TokenType.plus:
      case TokenType.minus:
        return Precedence.term;
      case TokenType.star:
      case TokenType.slash:
      case TokenType.percent:
        return Precedence.factor;
      case TokenType.starStar:
        return Precedence.power;

      // Calls, properties, subscripts
      case TokenType.dot:
      case TokenType.lparen:
      case TokenType.lbracket:
        return Precedence.call;

      default:
        return Precedence.none;
    }
  }
}
