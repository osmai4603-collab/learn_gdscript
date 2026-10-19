/// GDScript parser module.
///
/// Implements recursive descent parsing with Pratt expression evaluation,
/// producing a complete Abstract Syntax Tree (AST) with error recovery.
library;

export 'ast/ast_module.dart';
export 'parse_error.dart';
export 'parser.dart';
export 'precedence.dart';
