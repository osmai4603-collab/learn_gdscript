/// Enumeration of all token types recognized by the GDScript lexer.
enum TokenType {
  // === Literals ===
  integerLiteral,
  floatLiteral,
  stringLiteral,
  stringNameLiteral, // &"string_name"
  nodePathLiteral, // ^"node/path"
  multilineString, // """...""" or '''...'''
  // === Identifiers ===
  identifier,

  // === Keywords: Flow Control ===
  kwIf,
  kwElif,
  kwElse,
  kwFor,
  kwWhile,
  kwMatch,
  kwWhen,
  kwBreak,
  kwContinue,
  kwPass,
  kwReturn,

  // === Keywords: Declarations ===
  kwVar,
  kwConst,
  kwFunc,
  kwClass,
  kwClassName, // class_name
  kwExtends,
  kwEnum,
  kwSignal,
  kwStatic,

  // === Keywords: OOP / Type Casting / Checks ===
  kwSelf,
  kwSuper,
  kwIs,
  kwAs,
  kwVoid,

  // === Keywords: Logical & Membership ===
  kwAnd,
  kwOr,
  kwNot,
  kwIn,

  // === Keywords: Special Values ===
  kwTrue,
  kwFalse,
  kwNull,

  // === Keywords: Async & Resources ===
  kwAwait,
  kwPreload,
  kwLoad,
  kwBreakpoint,
  kwAssert,

  // === Keywords: Reserved for Future ===
  kwTrait,
  kwNamespace,
  kwYield,

  // === Operators: Arithmetic ===
  plus, // +
  minus, // -
  star, // *
  slash, // /
  percent, // %
  starStar, // **
  // === Operators: Comparison ===
  equalEqual, // ==
  bangEqual, // !=
  less, // <
  greater, // >
  lessEqual, // <=
  greaterEqual, // >=
  // === Operators: Assignment ===
  equal, // =
  colonEqual, // := (type-inferred assignment)
  plusEqual, // +=
  minusEqual, // -=
  starEqual, // *=
  slashEqual, // /=
  percentEqual, // %=
  starStarEqual, // **=
  ampersandEqual, // &=
  pipeEqual, // |=
  caretEqual, // ^=
  shiftLeftEqual, // <<=
  shiftRightEqual, // >>=
  // === Operators: Bitwise ===
  ampersand, // &
  pipe, // |
  caret, // ^
  tilde, // ~
  shiftLeft, // <<
  shiftRight, // >>
  // === Punctuation & Delimiters ===
  lparen, // (
  rparen, // )
  lbracket, // [
  rbracket, // ]
  lbrace, // {
  rbrace, // }
  dot, // .
  dotDot, // ..
  comma, // ,
  colon, // :
  semicolon, // ;
  arrow, // ->
  question, // ?
  dollar, // $ (get_node shorthand)
  dollarPercent, // % (unique node shorthand)
  backslash, // \ (line continuation)
  // === Indentation & Logical Layout ===
  indent, // Increased indentation block
  dedent, // Decreased indentation block
  newline, // Logical end of statement/line
  // === Comments & Annotations ===
  comment, // # regular comment
  docComment, // ## documentation comment
  annotation, // @export, @onready, @tool, etc.
  // === Engine & Special ===
  eof, // End of file
  error, // Unrecognized or malformed token
}
