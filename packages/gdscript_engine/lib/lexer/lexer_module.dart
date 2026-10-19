/// GDScript lexer module.
///
/// Converts raw GDScript source text into tokens, handles Python-style
/// indentation/dedentation, and identifies language keywords and literals.
library;

export 'indent_tracker.dart';
export 'keywords.dart';
export 'lexer.dart';
export 'token.dart';
export 'token_type.dart';
