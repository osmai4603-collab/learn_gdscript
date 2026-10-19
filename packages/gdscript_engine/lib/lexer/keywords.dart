import 'token_type.dart';

/// Lookup map and helpers for GDScript 4 keywords.
class Keywords {
  static const Map<String, TokenType> _keywords = {
    // Flow control
    'if': TokenType.kwIf,
    'elif': TokenType.kwElif,
    'else': TokenType.kwElse,
    'for': TokenType.kwFor,
    'while': TokenType.kwWhile,
    'match': TokenType.kwMatch,
    'when': TokenType.kwWhen,
    'break': TokenType.kwBreak,
    'continue': TokenType.kwContinue,
    'pass': TokenType.kwPass,
    'return': TokenType.kwReturn,

    // Declarations
    'var': TokenType.kwVar,
    'const': TokenType.kwConst,
    'func': TokenType.kwFunc,
    'class': TokenType.kwClass,
    'class_name': TokenType.kwClassName,
    'extends': TokenType.kwExtends,
    'enum': TokenType.kwEnum,
    'signal': TokenType.kwSignal,
    'static': TokenType.kwStatic,

    // OOP / Casting / Types
    'self': TokenType.kwSelf,
    'super': TokenType.kwSuper,
    'is': TokenType.kwIs,
    'as': TokenType.kwAs,
    'void': TokenType.kwVoid,

    // Logical & Membership
    'and': TokenType.kwAnd,
    'or': TokenType.kwOr,
    'not': TokenType.kwNot,
    'in': TokenType.kwIn,

    // Literals
    'true': TokenType.kwTrue,
    'false': TokenType.kwFalse,
    'null': TokenType.kwNull,

    // Async / Resources / Debug
    'await': TokenType.kwAwait,
    'preload': TokenType.kwPreload,
    'load': TokenType.kwLoad,
    'breakpoint': TokenType.kwBreakpoint,
    'assert': TokenType.kwAssert,

    // Reserved for Future
    'trait': TokenType.kwTrait,
    'namespace': TokenType.kwNamespace,
    'yield': TokenType.kwYield,
  };

  /// Returns corresponding [TokenType] if [identifier] is a reserved keyword, or null.
  static TokenType? lookup(String identifier) => _keywords[identifier];

  /// Whether [identifier] is a reserved GDScript keyword.
  static bool isKeyword(String identifier) => _keywords.containsKey(identifier);

  /// All registered keywords.
  static Iterable<String> get all => _keywords.keys;
}
