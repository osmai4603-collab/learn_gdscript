import '../analyzer/resolver.dart';
import '../analyzer/type_checker.dart';
import '../core/diagnostic.dart';
import '../core/error_reporter.dart';
import '../core/source.dart';
import '../core/source_location.dart';
import '../lexer/keywords.dart';
import '../lexer/lexer.dart';
import '../lexer/token.dart';
import '../lexer/token_type.dart';
import '../parser/ast/ast_node.dart';
import '../parser/ast/declarations.dart';
import '../parser/ast/expressions.dart';
import '../parser/ast/statements.dart';
import '../parser/parser.dart';
import '../runtime/native/builtin_functions.dart';
import '../runtime/native/global_scope.dart';

/// Classification kind for syntax highlighting.
enum HighlightKind {
  keyword,
  controlFlow,
  type,
  identifier,
  function,
  builtinFunction,
  classKind,
  variable,
  property,
  constant,
  signal,
  annotation,
  nodePath,
  number,
  string,
  comment,
  operator,
  punctuation,
}

/// A lexical syntax highlight span for high-speed editor rendering.
class SyntaxHighlight {
  final int offset;
  final int length;
  final TokenType tokenType;
  final HighlightKind kind;

  const SyntaxHighlight({
    required this.offset,
    required this.length,
    required this.tokenType,
    required this.kind,
  });
}

/// A semantic highlight span computed from AST symbol resolution.
class SemanticHighlight {
  final int offset;
  final int length;
  final String kind;
  final List<String> modifiers;

  const SemanticHighlight({
    required this.offset,
    required this.length,
    required this.kind,
    this.modifiers = const [],
  });
}

/// Category of an auto-completion proposal.
enum CompletionKind {
  keyword,
  function,
  variable,
  property,
  classType,
  constant,
  signal,
  enumType,
  method,
  annotation,
  nodePath,
  filePath,
  snippet,
  enumValue,
}

/// Parameter specification descriptor for signature help and autocompletion.
class ParameterInfo {
  final String name;
  final String? type;
  final String? defaultValue;

  const ParameterInfo({required this.name, this.type, this.defaultValue});

  @override
  String toString() {
    final buffer = StringBuffer(name);
    if (type != null && type!.isNotEmpty) {
      buffer.write(': $type');
    }
    if (defaultValue != null && defaultValue!.isNotEmpty) {
      buffer.write(' = $defaultValue');
    }
    return buffer.toString();
  }
}

/// Signature information for parameter hints when typing inside function calls.
class SignatureHelp {
  final String functionName;
  final String signature;
  final List<ParameterInfo> parameters;
  final int activeParameter;
  final String? documentation;
  final String? returnType;

  const SignatureHelp({
    required this.functionName,
    required this.signature,
    required this.parameters,
    required this.activeParameter,
    this.documentation,
    this.returnType,
  });
}

/// A code completion suggestion item with contextual ranking and metadata.
class CompletionItem {
  final String label;
  final CompletionKind kind;
  final String? detail;
  final String? documentation;
  final String? insertText;
  final String? returnType;
  final List<ParameterInfo>? parameters;
  final double sortPriority;
  final double score;
  final bool isLocal;
  final bool isClassMember;

  const CompletionItem({
    required this.label,
    required this.kind,
    this.detail,
    this.documentation,
    this.insertText,
    this.returnType,
    this.parameters,
    this.sortPriority = 0.0,
    this.score = 0.0,
    this.isLocal = false,
    this.isClassMember = false,
  });

  CompletionItem copyWith({
    String? label,
    CompletionKind? kind,
    String? detail,
    String? documentation,
    String? insertText,
    String? returnType,
    List<ParameterInfo>? parameters,
    double? sortPriority,
    double? score,
    bool? isLocal,
    bool? isClassMember,
  }) {
    return CompletionItem(
      label: label ?? this.label,
      kind: kind ?? this.kind,
      detail: detail ?? this.detail,
      documentation: documentation ?? this.documentation,
      insertText: insertText ?? this.insertText,
      returnType: returnType ?? this.returnType,
      parameters: parameters ?? this.parameters,
      sortPriority: sortPriority ?? this.sortPriority,
      score: score ?? this.score,
      isLocal: isLocal ?? this.isLocal,
      isClassMember: isClassMember ?? this.isClassMember,
    );
  }

  @override
  String toString() => '$label ($kind)';
}

/// Hover information for a symbol or token in the editor.
class HoverInfo {
  final int startOffset;
  final int endOffset;
  final String signature;
  final String? documentation;
  final String? type;

  const HoverInfo({
    required this.startOffset,
    required this.endOffset,
    required this.signature,
    this.documentation,
    this.type,
  });
}

/// The location of a symbol's declaration, used for "go to definition".
class GoToDefinition {
  /// Offset of the declaration's identifier within the source.
  final int offset;

  /// Length of the declaration's identifier.
  final int length;

  /// 1-indexed source line of the declaration.
  final int line;

  const GoToDefinition({
    required this.offset,
    required this.length,
    required this.line,
  });
}

/// A foldable code range in the editor (e.g. function body or class).
class FoldingRange {
  final int startLine;
  final int endLine;
  final String kind;

  const FoldingRange({
    required this.startLine,
    required this.endLine,
    required this.kind,
  });
}

/// High-level Editor Support API providing syntax highlighting, semantic analysis,
/// diagnostics, code completion, code folding, hover tooltips, and bracket matching.
class EditorAPI {
  /// Computes lexical syntax highlighting tokens very quickly.
  ///
  /// Applies light context-aware classification on top of raw token kinds so
  /// that built-in type names (e.g. `int`, `String`, `Vector2`) and member
  /// accesses following a dot (`obj.method`, `obj.property`) receive their
  /// dedicated highlight colors.
  List<SyntaxHighlight> getSyntaxHighlights(String sourceCode) {
    final source = Source.memory(sourceCode);
    final reporter = ErrorReporter();
    final lexer = Lexer(source: source, reporter: reporter);
    final tokens = lexer.scanTokens();
    final highlights = <SyntaxHighlight>[];

    for (var i = 0; i < tokens.length; i++) {
      final tok = tokens[i];
      if (tok.type == TokenType.eof ||
          tok.type == TokenType.indent ||
          tok.type == TokenType.dedent ||
          tok.type == TokenType.newline) {
        continue;
      }

      var kind = _mapTokenTypeToHighlightKind(tok.type);

      if (tok.type == TokenType.identifier) {
        kind = _classifyIdentifier(tokens, i);
      } else if (tok.type == TokenType.stringLiteral ||
          tok.type == TokenType.stringNameLiteral ||
          tok.type == TokenType.multilineString) {
        kind = _classifyStringLiteral(tokens, i);
      }

      highlights.add(
        SyntaxHighlight(
          offset: tok.location.offset,
          length: tok.length,
          tokenType: tok.type,
          kind: kind,
        ),
      );
    }

    return highlights;
  }

  /// Refines the highlight kind of an [identifier] token using surrounding
  /// token context (member access after a dot, built-in type names, etc.).
  HighlightKind _classifyIdentifier(List<Token> tokens, int index) {
    // Member access: `object.member`
    final prevIndex = _prevSignificantIndex(tokens, index);
    final prevType = prevIndex >= 0 ? tokens[prevIndex].type : null;

    if (prevType == TokenType.dot) {
      final isCall =
          _nextSignificantToken(tokens, index)?.type == TokenType.lparen;
      return isCall ? HighlightKind.function : HighlightKind.property;
    }

    final lexeme = tokens[index].lexeme;

    // Node path segments: `$Player`, `$UI/Button`, `%HUD`, `%/Root`.
    if (_isPartOfNodePath(tokens, index)) {
      return HighlightKind.nodePath;
    }

    // Class-name contexts: `extends Node2D`, `class_name Player`, `class Foo`.
    if (prevType == TokenType.kwExtends ||
        prevType == TokenType.kwClassName ||
        prevType == TokenType.kwClass) {
      return HighlightKind.classKind;
    }

    // Type contexts: `x: MyType`, `-> MyType`, `x as MyType`, `x is MyType`.
    if (prevType == TokenType.arrow ||
        prevType == TokenType.kwAs ||
        prevType == TokenType.kwIs) {
      return HighlightKind.type;
    }
    if (prevType == TokenType.colon && _looksLikeTypeName(lexeme)) {
      return HighlightKind.type;
    }

    // Generic type arguments: `Array[int]`, `Dictionary[String, MyClass]`.
    final genericBase = _enclosingGenericBaseName(tokens, index);
    if (genericBase != null && _looksLikeTypeName(genericBase)) {
      return HighlightKind.type;
    }

    // Signal declaration name: `signal health_changed(...)`.
    if (prevType == TokenType.kwSignal) {
      return HighlightKind.signal;
    }

    // Built-in type names and known engine classes.
    if (_builtInTypeNames.contains(lexeme)) {
      return HighlightKind.type;
    }

    // Global built-in functions (e.g. `print`, `range`, `lerp`).
    if (_builtInFunctionNames.contains(lexeme) &&
        _nextSignificantToken(tokens, index)?.type == TokenType.lparen) {
      return HighlightKind.builtinFunction;
    }

    // Global built-in constants (e.g. `PI`, `TAU`, `INF`, `NAN`).
    if (_globalConstantNames.contains(lexeme)) {
      return HighlightKind.constant;
    }

    return HighlightKind.identifier;
  }

  /// Classifies string literals used as signal names (`emit_signal("died")`)
  /// or as node path shorthands (`$"Player/Hitbox"`).
  HighlightKind _classifyStringLiteral(List<Token> tokens, int index) {
    final prevIndex = _prevSignificantIndex(tokens, index);
    if (prevIndex >= 0) {
      final prev = tokens[prevIndex];
      if (prev.type == TokenType.dollar ||
          prev.type == TokenType.dollarPercent ||
          prev.type == TokenType.caret) {
        return HighlightKind.nodePath;
      }
      if (prev.type == TokenType.percent &&
          _isPercentShorthand(tokens, prevIndex)) {
        return HighlightKind.nodePath;
      }
      // Signal name argument: `emit_signal("...")`, `connect("...")`, ...
      if (prev.type == TokenType.lparen) {
        final calleeIndex = _prevSignificantIndex(tokens, prevIndex);
        if (calleeIndex >= 0 &&
            tokens[calleeIndex].type == TokenType.identifier &&
            _signalCallNames.contains(tokens[calleeIndex].lexeme)) {
          return HighlightKind.signal;
        }
      }
    }
    return HighlightKind.string;
  }

  /// Whether the identifier at [index] belongs to a `$Path/To/Node` or
  /// `%UniqueName` shorthand (walking back over adjacent path segments).
  bool _isPartOfNodePath(List<Token> tokens, int index) {
    if (index <= 0) return false;
    var i = index;
    while (i > 0) {
      final prev = tokens[i - 1];
      final current = tokens[i];
      if (!_isAdjacent(prev, current)) return false;
      if (prev.type == TokenType.identifier ||
          prev.type == TokenType.slash ||
          prev.type == TokenType.dot) {
        i--;
        continue;
      }
      if (prev.type == TokenType.dollar ||
          prev.type == TokenType.dollarPercent) {
        return true;
      }
      if (prev.type == TokenType.percent) {
        return _isPercentShorthand(tokens, i - 1);
      }
      return false;
    }
    return false;
  }

  /// Whether `%` at [index] is a unique-node shorthand rather than the modulo
  /// operator (a prefix `%` has no value to its left).
  bool _isPercentShorthand(List<Token> tokens, int index) {
    final prevIndex = _prevSignificantIndex(tokens, index);
    if (prevIndex < 0) return true;
    final prevType = tokens[prevIndex].type;
    return !(prevType == TokenType.identifier ||
        prevType == TokenType.integerLiteral ||
        prevType == TokenType.floatLiteral ||
        prevType == TokenType.stringLiteral ||
        prevType == TokenType.stringNameLiteral ||
        prevType == TokenType.rparen ||
        prevType == TokenType.rbracket ||
        prevType == TokenType.kwSelf ||
        prevType == TokenType.kwTrue ||
        prevType == TokenType.kwFalse ||
        prevType == TokenType.kwNull);
  }

  /// Whether two tokens are directly adjacent in the source (no gap).
  bool _isAdjacent(Token before, Token after) =>
      before.location.offset + before.length == after.location.offset;

  /// Index of the previous non-trivia token before [index], or `-1`.
  int _prevSignificantIndex(List<Token> tokens, int index) {
    var i = index - 1;
    while (i >= 0 && _isTriviaToken(tokens[i].type)) {
      i--;
    }
    return i;
  }

  /// Heuristic: an identifier used after `:` is a type annotation when it looks
  /// like a class/type name (`int`, `String`, `MyClass`) rather than a value.
  bool _looksLikeTypeName(String lexeme) {
    if (_builtInTypeNames.contains(lexeme)) return true;
    if (lexeme.isEmpty) return false;
    final code = lexeme.codeUnitAt(0);
    return code >= 65 && code <= 90; // starts with an uppercase letter
  }

  /// Name of the generic base type whose `[...]` argument list encloses the
  /// identifier at [index], or `null` when the token is not inside one.
  ///
  /// e.g. returns `Array` for `int` in `Array[int]` and `Dictionary` for `int`
  /// in `Dictionary[String, int]`.
  String? _enclosingGenericBaseName(List<Token> tokens, int index) {
    var depth = 0;
    for (var i = index - 1; i >= 0; i--) {
      final type = tokens[i].type;
      if (_isTriviaToken(type)) continue;
      if (type == TokenType.rbracket) {
        depth++;
        continue;
      }
      if (type == TokenType.lbracket) {
        if (depth > 0) {
          depth--;
          continue;
        }
        final baseIndex = _prevSignificantIndex(tokens, i);
        if (baseIndex >= 0 && tokens[baseIndex].type == TokenType.identifier) {
          return tokens[baseIndex].lexeme;
        }
        return null;
      }
      // Only identifiers and commas may separate a type argument from its
      // enclosing bracket; anything else means this is not a type list.
      if (depth == 0 &&
          type != TokenType.identifier &&
          type != TokenType.comma) {
        return null;
      }
    }
    return null;
  }

  /// Returns the next non-trivia token after [index], if any.
  Token? _nextSignificantToken(List<Token> tokens, int index) {
    for (var i = index + 1; i < tokens.length; i++) {
      if (!_isTriviaToken(tokens[i].type)) return tokens[i];
    }
    return null;
  }

  /// Whether [type] is layout/trivia that should be ignored when inspecting
  /// neighboring tokens for contextual classification.
  bool _isTriviaToken(TokenType type) =>
      type == TokenType.indent ||
      type == TokenType.dedent ||
      type == TokenType.newline ||
      type == TokenType.comment ||
      type == TokenType.docComment;

  /// Built-in GDScript data types and core engine classes that should be
  /// rendered with the dedicated type color when used as identifiers.
  static const Set<String> _builtInTypeNames = {
    // Primitive & core value types
    'void', 'bool', 'int', 'float', 'String', 'StringName', 'NodePath',
    'Variant', 'Array', 'Dictionary', 'Callable', 'Signal', 'RID',
    // Math types
    'Vector2', 'Vector2i', 'Vector3', 'Vector3i', 'Vector4', 'Vector4i',
    'Color', 'Rect2', 'Rect2i', 'Transform2D', 'Transform3D', 'Basis',
    'Quaternion', 'Plane', 'AABB', 'Projection',
    // Packed arrays
    'PackedByteArray', 'PackedInt32Array', 'PackedInt64Array',
    'PackedFloat32Array', 'PackedFloat64Array', 'PackedStringArray',
    'PackedVector2Array', 'PackedVector3Array', 'PackedVector4Array',
    'PackedColorArray',
    // Core object hierarchy
    'Object', 'RefCounted', 'Resource', 'Node', 'Node2D', 'Node3D',
    'CanvasItem', 'CanvasLayer', 'Control', 'Window', 'SceneTree',
    'Engine', 'Input', 'InputEvent', 'Time', 'OS', 'ClassDB',
  };

  /// Global built-in GDScript functions that should be rendered with the
  /// dedicated function color when invoked (e.g. `print`, `range`, `lerp`).
  static const Set<String> _builtInFunctionNames = {
    // I/O & diagnostics
    'print', 'prints', 'printt', 'printraw', 'printerr', 'print_rich',
    'print_debug', 'push_warning', 'push_error',
    // Type conversion & inspection
    'str', 'int', 'float', 'bool', 'typeof', 'type_string', 'char',
    // Containers & iteration
    'len', 'range', 'hash',
    // Math: general
    'abs', 'sign', 'signi', 'signf', 'min', 'mini', 'minf', 'max', 'maxi',
    'maxf', 'clamp', 'clampi', 'clampf', 'round', 'roundi', 'floor', 'floori',
    'ceil', 'ceili', 'sqrt', 'pow', 'exp', 'log', 'snapped', 'snappedf',
    'snappedi', 'posmod', 'fposmod', 'wrap', 'wrapf', 'wrapi', 'pingpong',
    'nearest_po2',
    // Math: checks
    'is_nan', 'is_inf', 'is_zero_approx', 'is_equal_approx',
    // Math: trigonometry
    'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'atan2', 'sinh', 'cosh',
    'tanh', 'deg_to_rad', 'rad_to_deg',
    // Math: interpolation
    'lerp', 'lerpf', 'lerp_angle', 'inverse_lerp', 'remap', 'smoothstep',
    'move_toward', 'ease',
    // Random
    'randomize', 'seed', 'randi', 'randf', 'randi_range', 'randf_range',
    'randfn',
  };

  /// Global built-in GDScript constants rendered with the dedicated constant
  /// color (e.g. `PI`, `TAU`, `INF`, `NAN`). Derived from the runtime's global
  /// scope so it stays in sync with the engine.
  static final Set<String> _globalConstantNames = GlobalScope.getConstants()
      .keys
      .toSet();

  /// Computes deep semantic symbol highlighting using AST traversal.
  List<SemanticHighlight> getSemanticHighlights(String sourceCode) {
    final source = Source.memory(sourceCode);
    final reporter = ErrorReporter();
    final tokens = Lexer(source: source, reporter: reporter).scanTokens();
    final ast = Parser(
      source: source,
      tokens: tokens,
      reporter: reporter,
    ).parseScript();
    final highlights = <SemanticHighlight>[];

    void visitNode(dynamic node) {
      if (node is ClassDecl) {
        highlights.add(
          SemanticHighlight(
            offset: node.location.offset,
            length: node.name.length,
            kind: 'class',
          ),
        );
        for (final m in node.members) {
          visitNode(m);
        }
      } else if (node is FuncDecl) {
        highlights.add(
          SemanticHighlight(
            offset: node.location.offset,
            length: node.name.length,
            kind: 'function',
            modifiers: [if (node.isStatic) 'static'],
          ),
        );
        for (final p in node.parameters) {
          highlights.add(
            SemanticHighlight(
              offset: p.location.offset,
              length: p.name.length,
              kind: 'parameter',
            ),
          );
        }
      } else if (node is VarStmt) {
        highlights.add(
          SemanticHighlight(
            offset: node.location.offset,
            length: node.name.length,
            kind: node.isConst ? 'constant' : 'variable',
            modifiers: [if (node.isStatic) 'static'],
          ),
        );
      } else if (node is SignalDecl) {
        highlights.add(
          SemanticHighlight(
            offset: node.location.offset,
            length: node.name.length,
            kind: 'signal',
          ),
        );
      }
    }

    for (final decl in ast.declarations) {
      visitNode(decl);
    }

    return highlights;
  }

  /// Returns all compile-time errors and warnings with accurate source locations.
  List<Diagnostic> getDiagnostics(String sourceCode) {
    final source = Source.memory(sourceCode);
    final reporter = ErrorReporter();

    // 1. Lexing
    final lexer = Lexer(source: source, reporter: reporter);
    final tokens = lexer.scanTokens();

    // 2. Parsing
    final parser = Parser(source: source, tokens: tokens, reporter: reporter);
    final ast = parser.parseScript();

    // 3. Resolving & Type Checking (if no fatal parser errors)
    if (!reporter.hasErrors) {
      final resolver = Resolver(reporter: reporter);
      resolver.resolveScript(ast);

      final typeChecker = TypeChecker(reporter: reporter, resolver: resolver);
      typeChecker.checkScript(ast);
    }

    return reporter.diagnostics;
  }

  /// Additional project files (e.g. `res://scenes/main.tscn`) surfaced by
  /// `preload("` / `load("` file-path completion. Populated by the host app.
  final List<String> projectFilePaths = [];

  /// Replaces the project file list used for path completion.
  void setProjectFilePaths(Iterable<String> paths) {
    projectFilePaths
      ..clear()
      ..addAll(paths);
  }

  /// File-path candidates: the built-in samples blended with any project files
  /// registered via [setProjectFilePaths].
  List<CompletionItem> get _filePathCandidates {
    if (projectFilePaths.isEmpty) return _filePathCompletions;
    final results = <CompletionItem>[..._filePathCompletions];
    for (final path in projectFilePaths) {
      if (_filePathCompletions.any((c) => c.label == path)) continue;
      results.add(
        CompletionItem(
          label: path,
          kind: CompletionKind.filePath,
          detail: 'file',
          documentation: 'Project file: $path',
          insertText: path,
        ),
      );
    }
    return results;
  }

  /// Suggests intelligent context-aware auto-completions at [offset] in [sourceCode].
  List<CompletionItem> getCompletions(
    String sourceCode,
    int offset, {
    bool manualTrigger = true,
  }) {
    final clampedOffset = offset.clamp(0, sourceCode.length);
    final textBefore = sourceCode.substring(0, clampedOffset);
    final lineStart = textBefore.lastIndexOf('\n') + 1;
    final lineBeforeCursor = textBefore.substring(lineStart);

    // 1. Context suppression check: comments and active strings
    var inSingleQuote = false;
    var inDoubleQuote = false;
    var inComment = false;

    for (var i = 0; i < lineBeforeCursor.length; i++) {
      final char = lineBeforeCursor[i];
      if (char == '\\' && (inSingleQuote || inDoubleQuote)) {
        i++; // skip escaped char
        continue;
      }
      if (char == '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
      } else if (char == "'" && !inDoubleQuote) {
        inSingleQuote = !inSingleQuote;
      } else if (char == '#' && !inSingleQuote && !inDoubleQuote) {
        inComment = true;
        break;
      }
    }

    if (inComment) {
      return const [];
    }

    // Check special in-string contexts: filePath (load/preload) or nodePath ($"...")
    if (inSingleQuote || inDoubleQuote) {
      final beforeQuote = lineBeforeCursor.substring(
        0,
        lineBeforeCursor.lastIndexOf(inDoubleQuote ? '"' : "'"),
      );
      if (RegExp(r'\b(preload|load)\s*\(\s*$').hasMatch(beforeQuote)) {
        // File path context
        final quoteChar = inDoubleQuote ? '"' : "'";
        final quoteIndex = lineBeforeCursor.lastIndexOf(quoteChar);
        final pathPrefix = lineBeforeCursor.substring(quoteIndex + 1);
        return _rankAndFilter(
          _filePathCandidates,
          pathPrefix,
          isContextExpected: true,
        );
      } else if (beforeQuote.endsWith(r'$') ||
          RegExp(r'\bget_node\s*\(\s*$').hasMatch(beforeQuote)) {
        // Node path context inside string
        final quoteChar = inDoubleQuote ? '"' : "'";
        final quoteIndex = lineBeforeCursor.lastIndexOf(quoteChar);
        final nodePrefix = lineBeforeCursor.substring(quoteIndex + 1);
        return _rankAndFilter(
          _nodePathCompletions,
          nodePrefix,
          isContextExpected: true,
        );
      } else if (RegExp(
        r'\b(emit_signal|has_signal|connect)\s*\(\s*$',
      ).hasMatch(beforeQuote)) {
        // Signal context inside string
        final quoteChar = inDoubleQuote ? '"' : "'";
        final quoteIndex = lineBeforeCursor.lastIndexOf(quoteChar);
        final sigPrefix = lineBeforeCursor.substring(quoteIndex + 1);
        final scriptSignals = _extractScriptSignals(sourceCode);
        return _rankAndFilter(
          [...scriptSignals, ..._commonNodeSignals],
          sigPrefix,
          isContextExpected: true,
        );
      }
      return const [];
    }

    // 2. Identify prefix and trigger characters
    final prefix = _extractIdentifierPrefix(sourceCode, clampedOffset);
    final charBeforePrefix = clampedOffset > prefix.length
        ? sourceCode[clampedOffset - prefix.length - 1]
        : '';
    final isAfterDot = charBeforePrefix == '.';
    final isAfterAnnotation = charBeforePrefix == '@';
    final isAfterDollar = charBeforePrefix == r'$';

    // Unique-node shorthand (`%HUD`): a prefix `%` not used as modulo.
    final isAfterUnique = _isUniqueNodePrefix(lineBeforeCursor);

    // Function-declaration parameter list (`func _process(`).
    final funcDeclName = _enclosingFuncDeclarationName(
      sourceCode,
      clampedOffset,
    );
    final isAfterFuncDeclParen =
        funcDeclName != null && charBeforePrefix == '(';

    // In continuous typing (non-manual), require either an explicit trigger char
    // ('.', '@', '$', '%', `(`) or a typed identifier prefix.
    if (!manualTrigger &&
        !isAfterDot &&
        !isAfterAnnotation &&
        !isAfterDollar &&
        !isAfterUnique &&
        !isAfterFuncDeclParen &&
        prefix.isEmpty) {
      return const [];
    }

    // 3. Context 1: Annotation context (@export, @onready, etc.)
    if (isAfterAnnotation ||
        RegExp(r'@[a-zA-Z0-9_]*$').hasMatch(lineBeforeCursor)) {
      return _rankAndFilter(
        _annotationCompletions,
        prefix,
        isContextExpected: true,
      );
    }

    // 4. Context 2: Node path context ($Sprite2D, $UI/Button, etc.)
    if (isAfterDollar ||
        RegExp(r'\$[a-zA-Z0-9_/]*$').hasMatch(lineBeforeCursor)) {
      return _rankAndFilter(
        _nodePathCompletions,
        prefix,
        isContextExpected: true,
      );
    }

    // 4b. Context 2b: Unique node name shorthand (%HUD, %/Root/HUD).
    if (isAfterUnique) {
      return _rankAndFilter(
        _uniqueNodeCompletions,
        prefix,
        isContextExpected: true,
      );
    }

    // 5. Context 3: Inheritance context (extends ...)
    final trimmedBefore = lineBeforeCursor
        .substring(0, lineBeforeCursor.length - prefix.length)
        .trimRight();
    if (trimmedBefore.endsWith('extends') ||
        RegExp(r'\bextends$').hasMatch(trimmedBefore)) {
      final scriptClasses = _extractScriptClasses(sourceCode);
      return _rankAndFilter(
        [...scriptClasses, ..._godotClassesCompletions],
        prefix,
        isContextExpected: true,
      );
    }

    // 6. Context 4: Type hint context (var x: ... or -> ... or func(x: ...))
    if (RegExp(r':\s*$').hasMatch(trimmedBefore) ||
        RegExp(r'->\s*$').hasMatch(trimmedBefore)) {
      final scriptClasses = _extractScriptClasses(sourceCode);
      return _rankAndFilter(
        [
          ..._godotTypeCompletions,
          ...scriptClasses,
          ..._godotClassesCompletions,
        ],
        prefix,
        isContextExpected: true,
      );
    }

    // 6a. Context 4a: Generic type argument context (`Array[`, `Dictionary[K, `).
    final genericMatch = RegExp(
      r'([A-Za-z_][A-Za-z0-9_]*)\s*\[[^\[\]]*$',
    ).firstMatch(trimmedBefore);
    if (genericMatch != null && _looksLikeTypeName(genericMatch.group(1)!)) {
      final scriptClasses = _extractScriptClasses(sourceCode);
      return _rankAndFilter(
        [
          ..._godotTypeCompletions,
          ...scriptClasses,
          ..._godotClassesCompletions,
        ],
        prefix,
        isContextExpected: true,
      );
    }

    // 6b. Context 4b: Function declaration parameter list (`func _process(`).
    // Suggests the parameter names/types of the virtual method being overridden.
    if (funcDeclName != null) {
      final params = _virtualMethodParameters[funcDeclName];
      if (params != null) {
        return _rankAndFilter(
          [
            for (final p in params)
              CompletionItem(
                label: p.name,
                kind: CompletionKind.variable,
                detail: p.type != null ? '${p.name}: ${p.type}' : p.name,
                documentation: 'Parameter of `$funcDeclName`.',
                insertText: p.type != null ? '${p.name}: ${p.type}' : p.name,
                sortPriority: 10.0,
              ),
          ],
          prefix,
          isContextExpected: true,
        );
      }
      return const [];
    }

    // 7. Context 5: Member access / Dot context (object.method).
    if (isAfterDot) {
      // Index of the dot within the current line (not the whole document).
      final dotIndexInLine = lineBeforeCursor.length - prefix.length - 1;
      return _rankAndFilter(
        _dotMemberCandidates(sourceCode, lineBeforeCursor, dotIndexInLine),
        prefix,
        isContextExpected: true,
      );
    }

    // 8. Context 6: Virtual method override (func _...)
    if (RegExp(r'\bfunc\s+_[a-zA-Z0-9_]*$').hasMatch(lineBeforeCursor)) {
      return _rankAndFilter(
        _virtualMethodCompletions,
        prefix,
        isContextExpected: true,
      );
    }

    // Determine whether the cursor sits at the start of a line, and whether
    // that line lives inside a function body (in which case a bare identifier
    // is an expression, not a declaration).
    final leadingWhitespace =
        RegExp(r'^[ \t]*').firstMatch(lineBeforeCursor)?.group(0) ?? '';
    final isLineStart = lineBeforeCursor.trimLeft() == prefix;
    final isInsideFunction =
        isLineStart &&
        leadingWhitespace.isNotEmpty &&
        _isInsideFunction(sourceCode, clampedOffset);

    // 8b. Context 6b: `match` pattern position.
    if (isLineStart && _isInsideMatchPattern(sourceCode, clampedOffset)) {
      return _rankAndFilter(
        [
          ..._matchPatternCompletions,
          ..._expressionCandidates(sourceCode, clampedOffset),
        ],
        prefix,
        isContextExpected: true,
      );
    }

    // 8c. Line start inside a function body: statement keywords + expressions.
    if (isLineStart && isInsideFunction) {
      return _rankAndFilter(
        [
          ..._statementKeywordCompletions,
          ..._codeSnippets,
          ..._expressionCandidates(sourceCode, clampedOffset),
        ],
        prefix,
        isContextExpected: true,
      );
    }

    // Virtual method override at the start of a top-level / class-body line.
    if (isLineStart && !isInsideFunction && prefix.startsWith('_')) {
      return _rankAndFilter(
        _virtualMethodCompletions,
        prefix,
        isContextExpected: true,
      );
    }

    // 9. Context 7: Line start declarations and keywords.
    // Only applies at top level or inside a class body — never inside a
    // function body, where declaration keywords such as `static` are invalid.
    if (isLineStart && !isInsideFunction) {
      final declarationCandidates = <CompletionItem>[
        ..._declarationKeywordCompletions,
        ..._codeSnippets,
        ..._virtualMethodCompletions,
      ];

      // When nothing is typed yet, prefer declarations/snippets only.
      if (prefix.isEmpty) {
        return _rankAndFilter(
          declarationCandidates,
          prefix,
          isContextExpected: true,
        );
      }

      // With a typed prefix, blend declarations with expressions so that
      // built-in functions (e.g. `print`) remain discoverable.
      return _rankAndFilter(
        [
          ...declarationCandidates,
          ..._expressionCandidates(sourceCode, clampedOffset),
        ],
        prefix,
        isContextExpected: true,
      );
    }

    // 10. General expression context:
    // Local symbols, script members, built-in functions, constants, keywords.
    return _rankAndFilter(
      _expressionCandidates(sourceCode, clampedOffset),
      prefix,
    );
  }

  /// Builds the general expression completion candidates for [offset]:
  /// local symbols, script members, built-in functions, constants and
  /// expression keywords.
  List<CompletionItem> _expressionCandidates(String sourceCode, int offset) {
    return <CompletionItem>[
      // Local symbols (variables & parameters from active function)
      ..._extractLocalSymbols(sourceCode, offset),
      // Script-level members (functions, variables, constants, signals)
      ..._extractScriptMembers(sourceCode),
      // Global built-in functions
      ..._builtInFunctionCompletions,
      // Global constants
      ..._globalConstantCompletions,
      // Expression keywords (and, or, not, true, false, null, self, super)
      ..._expressionKeywordCompletions,
    ];
  }

  /// Provides parameter hints (signature help) when inside a function call.
  /// Whether [offset] sits inside the parameter list of a function/method call
  /// or definition (i.e. between an unmatched `(` and its closing `)`).
  bool isInsideParameters(String sourceCode, int offset) {
    if (offset <= 0 || offset > sourceCode.length) return false;
    return _findOpenParenIndex(sourceCode, offset) != -1;
  }

  /// Scans backward from [offset] to find the index of the unmatched opening
  /// parenthesis `(` enclosing the caret, or `-1` when not inside one.
  int _findOpenParenIndex(String sourceCode, int offset) {
    var depth = 0;
    for (var i = offset - 1; i >= 0; i--) {
      final char = sourceCode[i];
      if (char == ')') {
        depth++;
      } else if (char == '(') {
        if (depth > 0) {
          depth--;
        } else {
          return i;
        }
      } else if (char == '\n' && depth == 0) {
        // If we hit a newline outside parentheses, check if preceding line has
        // a continuation that keeps us inside the call.
        final lineBefore = sourceCode.substring(0, i).trimRight();
        if (!lineBefore.endsWith(',') &&
            !lineBefore.endsWith('\\') &&
            !lineBefore.endsWith('(')) {
          return -1;
        }
      }
    }
    return -1;
  }

  SignatureHelp? getSignatureHelp(String sourceCode, int offset) {
    if (offset <= 0 || offset > sourceCode.length) return null;

    // Scan backward to find the unclosed opening parenthesis '('
    var depth = 0;
    var commaCount = 0;
    final openParenIndex = _findOpenParenIndex(sourceCode, offset);

    // Recount commas between the open paren and the caret for the active index.
    for (var i = openParenIndex + 1; i < offset; i++) {
      final char = sourceCode[i];
      if (char == ')') {
        depth++;
      } else if (char == '(') {
        depth--;
      } else if (char == ',' && depth == 0) {
        commaCount++;
      }
    }

    if (openParenIndex == -1) return null;

    // Extract the callee identifier before the opening parenthesis
    var calleeEnd = openParenIndex - 1;
    while (calleeEnd >= 0 && sourceCode[calleeEnd].trim().isEmpty) {
      calleeEnd--;
    }
    if (calleeEnd < 0) return null;

    var calleeStart = calleeEnd;
    while (calleeStart >= 0 && _isIdentifierChar(sourceCode[calleeStart])) {
      calleeStart--;
    }
    calleeStart++;

    if (calleeStart > calleeEnd) return null;
    final functionName = sourceCode.substring(calleeStart, calleeEnd + 1);
    if (functionName.isEmpty) return null;

    // 0. Function *declaration* parameter list (`func _process(`): show the
    // signature of the virtual method being overridden, if known.
    final beforeParen = sourceCode.substring(0, openParenIndex).trimRight();
    final declMatch = RegExp(
      r'\bfunc\s+([A-Za-z_][A-Za-z0-9_]*)$',
    ).firstMatch(beforeParen);
    if (declMatch != null) {
      final name = declMatch.group(1)!;
      final params = _virtualMethodParameters[name];
      if (params != null) {
        return SignatureHelp(
          functionName: name,
          signature:
              'func $name(${params.map((p) => p.toString()).join(', ')})',
          parameters: params,
          activeParameter: params.isEmpty
              ? 0
              : commaCount.clamp(0, params.length - 1),
          documentation: 'Virtual method override signature.',
        );
      }
      return null;
    }

    // 1. Check in-script defined functions from AST
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      for (final decl in ast.declarations) {
        if (decl is FuncDecl && decl.name == functionName) {
          final params = decl.parameters.map((p) {
            return ParameterInfo(
              name: p.name,
              type: p.typeAnnotation,
              defaultValue: p.defaultValue != null ? '...' : null,
            );
          }).toList();

          final retType = decl.returnType ?? 'void';
          final paramListStr = params.map((p) => p.toString()).join(', ');
          final sig = 'func $functionName($paramListStr) -> $retType';
          final activeParam = params.isEmpty
              ? 0
              : commaCount.clamp(0, params.length - 1);

          return SignatureHelp(
            functionName: functionName,
            signature: sig,
            parameters: params,
            activeParameter: activeParam,
            documentation: 'User function defined in script',
            returnType: retType,
          );
        }
      }
    } catch (_) {
      // Ignore AST parse error while typing
    }

    // 2. Check built-in signatures registry
    if (_signatureRegistry.containsKey(functionName)) {
      final desc = _signatureRegistry[functionName]!;
      final activeParam = desc.parameters.isEmpty
          ? 0
          : (desc.isVararg && commaCount >= desc.parameters.length)
          ? desc.parameters.length - 1
          : commaCount.clamp(0, desc.parameters.length - 1);

      return SignatureHelp(
        functionName: functionName,
        signature: desc.signature,
        parameters: desc.parameters,
        activeParameter: activeParam,
        documentation: desc.documentation,
        returnType: desc.returnType,
      );
    }

    // 3. Fallback generic signature help
    return SignatureHelp(
      functionName: functionName,
      signature: '$functionName(...)',
      parameters: [ParameterInfo(name: 'arg${commaCount + 1}')],
      activeParameter: 0,
      documentation: 'Callable: $functionName',
    );
  }

  // ===========================================================================
  // Completion Registries and Helper Tables
  // ===========================================================================

  static final List<CompletionItem> _annotationCompletions = [
    const CompletionItem(
      label: '@export',
      kind: CompletionKind.annotation,
      detail: '@export',
      documentation:
          'Exports the following variable property to the Godot Inspector dock.',
      insertText: '@export',
      sortPriority: 10.0,
    ),
    const CompletionItem(
      label: '@export_range',
      kind: CompletionKind.annotation,
      detail: '@export_range(min, max, step)',
      documentation:
          'Exports an integer or float with a slider in the Inspector dock.',
      insertText: '@export_range',
      sortPriority: 9.0,
    ),
    const CompletionItem(
      label: '@export_enum',
      kind: CompletionKind.annotation,
      detail: '@export_enum(name1, name2, ...)',
      documentation: 'Exports an enumeration dropdown in the Inspector dock.',
      insertText: '@export_enum',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: '@export_file',
      kind: CompletionKind.annotation,
      detail: '@export_file(filter)',
      documentation: 'Exports a file path picker in the Inspector dock.',
      insertText: '@export_file',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: '@export_dir',
      kind: CompletionKind.annotation,
      detail: '@export_dir',
      documentation: 'Exports a directory path picker in the Inspector dock.',
      insertText: '@export_dir',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: '@export_multiline',
      kind: CompletionKind.annotation,
      detail: '@export_multiline',
      documentation: 'Exports a multiline text editor in the Inspector dock.',
      insertText: '@export_multiline',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: '@export_color_no_alpha',
      kind: CompletionKind.annotation,
      detail: '@export_color_no_alpha',
      documentation: 'Exports a Color property picker without an alpha slider.',
      insertText: '@export_color_no_alpha',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: '@export_node_path',
      kind: CompletionKind.annotation,
      detail: '@export_node_path',
      documentation: 'Exports a NodePath picker in the Inspector dock.',
      insertText: '@export_node_path',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: '@onready',
      kind: CompletionKind.annotation,
      detail: '@onready',
      documentation:
          'Initializes the variable when the node enters the scene tree (_ready).',
      insertText: '@onready',
      sortPriority: 10.0,
    ),
    const CompletionItem(
      label: '@tool',
      kind: CompletionKind.annotation,
      detail: '@tool',
      documentation:
          'Executes the script directly within the Godot Editor viewport.',
      insertText: '@tool',
      sortPriority: 9.0,
    ),
    const CompletionItem(
      label: '@icon',
      kind: CompletionKind.annotation,
      detail: '@icon(path)',
      documentation:
          'Sets custom icon path for this class in the Scene and Create dialogs.',
      insertText: '@icon',
      sortPriority: 5.0,
    ),
    const CompletionItem(
      label: '@rpc',
      kind: CompletionKind.annotation,
      detail: '@rpc(mode, sync)',
      documentation:
          'Configures remote procedure call network synchronization for this function.',
      insertText: '@rpc',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: '@warning_ignore',
      kind: CompletionKind.annotation,
      detail: '@warning_ignore(warning)',
      documentation:
          'Suppresses a specific static analysis warning in the following code.',
      insertText: '@warning_ignore',
      sortPriority: 5.0,
    ),
    const CompletionItem(
      label: '@static_unload',
      kind: CompletionKind.annotation,
      detail: '@static_unload',
      documentation: 'Forces static data to unload when no instances remain.',
      insertText: '@static_unload',
      sortPriority: 4.0,
    ),
  ];

  static final List<CompletionItem> _nodePathCompletions = [
    const CompletionItem(
      label: 'Sprite2D',
      kind: CompletionKind.nodePath,
      detail: r'$Sprite2D',
      documentation: '2D Sprite node in the scene tree.',
      insertText: 'Sprite2D',
      sortPriority: 10.0,
    ),
    const CompletionItem(
      label: 'CollisionShape2D',
      kind: CompletionKind.nodePath,
      detail: r'$CollisionShape2D',
      documentation: '2D collision shape node.',
      insertText: 'CollisionShape2D',
      sortPriority: 9.0,
    ),
    const CompletionItem(
      label: 'AnimationPlayer',
      kind: CompletionKind.nodePath,
      detail: r'$AnimationPlayer',
      documentation: 'Animation playback and sequencing player node.',
      insertText: 'AnimationPlayer',
      sortPriority: 9.0,
    ),
    const CompletionItem(
      label: 'Camera2D',
      kind: CompletionKind.nodePath,
      detail: r'$Camera2D',
      documentation: '2D Camera node.',
      insertText: 'Camera2D',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: 'Area2D',
      kind: CompletionKind.nodePath,
      detail: r'$Area2D',
      documentation: '2D Area trigger and physics detector.',
      insertText: 'Area2D',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'AudioStreamPlayer',
      kind: CompletionKind.nodePath,
      detail: r'$AudioStreamPlayer',
      documentation: 'Non-positional audio playback stream player.',
      insertText: 'AudioStreamPlayer',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'Timer',
      kind: CompletionKind.nodePath,
      detail: r'$Timer',
      documentation: 'Countdown timer node emitting timeout signal.',
      insertText: 'Timer',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: 'UI/Label',
      kind: CompletionKind.nodePath,
      detail: r'$UI/Label',
      documentation: 'Text label node under UI hierarchy.',
      insertText: 'UI/Label',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'UI/Button',
      kind: CompletionKind.nodePath,
      detail: r'$UI/Button',
      documentation: 'Clickable button control under UI hierarchy.',
      insertText: 'UI/Button',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'Marker2D',
      kind: CompletionKind.nodePath,
      detail: r'$Marker2D',
      documentation: '2D positional reference marker point.',
      insertText: 'Marker2D',
      sortPriority: 5.0,
    ),
    const CompletionItem(
      label: 'RayCast2D',
      kind: CompletionKind.nodePath,
      detail: r'$RayCast2D',
      documentation: '2D physics raycast detector.',
      insertText: 'RayCast2D',
      sortPriority: 5.0,
    ),
  ];

  static final List<CompletionItem> _uniqueNodeCompletions =
      ['HUD', 'Player', 'MainCamera', 'UI', 'Music', 'PauseMenu']
          .map(
            (name) => CompletionItem(
              label: name,
              kind: CompletionKind.nodePath,
              detail: '%$name',
              documentation: 'Unique scene node (access with %$name).',
              insertText: name,
              sortPriority: 8.0,
            ),
          )
          .toList();

  static final List<CompletionItem> _filePathCompletions = [
    const CompletionItem(
      label: 'res://scenes/main.tscn',
      kind: CompletionKind.filePath,
      detail: 'PackedScene',
      documentation: 'Main application scene file.',
      insertText: 'res://scenes/main.tscn',
    ),
    const CompletionItem(
      label: 'res://scripts/player.gd',
      kind: CompletionKind.filePath,
      detail: 'GDScript',
      documentation: 'Player controller script file.',
      insertText: 'res://scripts/player.gd',
    ),
    const CompletionItem(
      label: 'res://assets/icon.svg',
      kind: CompletionKind.filePath,
      detail: 'Texture2D',
      documentation: 'Godot vector icon asset.',
      insertText: 'res://assets/icon.svg',
    ),
  ];

  static final List<CompletionItem> _godotClassesCompletions =
      [
            'Node',
            'Node2D',
            'Node3D',
            'Control',
            'CharacterBody2D',
            'CharacterBody3D',
            'RigidBody2D',
            'RigidBody3D',
            'StaticBody2D',
            'StaticBody3D',
            'Area2D',
            'Area3D',
            'Camera2D',
            'Camera3D',
            'Sprite2D',
            'Sprite3D',
            'AnimatedSprite2D',
            'AnimatedSprite3D',
            'CollisionShape2D',
            'CollisionShape3D',
            'CollisionPolygon2D',
            'CollisionPolygon3D',
            'RayCast2D',
            'RayCast3D',
            'Marker2D',
            'Marker3D',
            'Path2D',
            'Path3D',
            'PathFollow2D',
            'PathFollow3D',
            'TileMap',
            'TileMapLayer',
            'ParallaxBackground',
            'Parallax2D',
            'CanvasItem',
            'CanvasLayer',
            'ColorRect',
            'TextureRect',
            'Label',
            'Button',
            'Panel',
            'MarginContainer',
            'VBoxContainer',
            'HBoxContainer',
            'GridContainer',
            'ScrollContainer',
            'AnimationPlayer',
            'AnimationTree',
            'AudioStreamPlayer',
            'AudioStreamPlayer2D',
            'AudioStreamPlayer3D',
            'Timer',
            'Resource',
            'RefCounted',
            'Object',
            'HTTPRequest',
          ]
          .map(
            (c) => CompletionItem(
              label: c,
              kind: CompletionKind.classType,
              detail: 'class $c',
              documentation: 'Godot Engine core built-in class $c.',
            ),
          )
          .toList();

  static final List<CompletionItem> _godotTypeCompletions =
      [
            'void',
            'int',
            'float',
            'String',
            'bool',
            'Array',
            'Dictionary',
            'Vector2',
            'Vector2i',
            'Vector3',
            'Vector3i',
            'Vector4',
            'Vector4i',
            'Color',
            'Rect2',
            'Rect2i',
            'Transform2D',
            'Transform3D',
            'Basis',
            'Quaternion',
            'Plane',
            'AABB',
            'Projection',
            'Callable',
            'Signal',
            'RID',
            'NodePath',
            'StringName',
            'PackedByteArray',
            'PackedInt32Array',
            'PackedInt64Array',
            'PackedFloat32Array',
            'PackedFloat64Array',
            'PackedStringArray',
            'PackedVector2Array',
            'PackedVector3Array',
            'PackedVector4Array',
            'PackedColorArray',
          ]
          .map(
            (t) => CompletionItem(
              label: t,
              kind: CompletionKind.classType,
              detail: 'type $t',
              documentation: 'Built-in GDScript data type: $t',
              sortPriority: 8.0,
            ),
          )
          .toList();

  static final List<CompletionItem> _builtInMemberMethods =
      [
            'size',
            'length',
            'is_empty',
            'clear',
            'duplicate',
            'append',
            'push_back',
            'push_front',
            'pop_back',
            'pop_front',
            'has',
            'count',
            'find',
            'rfind',
            'reverse',
            'sort',
            'shuffle',
            'filter',
            'map',
            'reduce',
            'any',
            'all',
            'slice',
            'keys',
            'values',
            'get',
            'erase',
            'merge',
            'substr',
            'replace',
            'split',
            'join',
            'to_upper',
            'to_lower',
            'strip_edges',
            'begins_with',
            'ends_with',
            'contains',
            'repeat',
            'format',
            'pad_zeros',
            'to_int',
            'to_float',
          ]
          .map(
            (m) => CompletionItem(
              label: m,
              kind: CompletionKind.method,
              detail: '$m()',
              documentation: 'Built-in collection or string method: $m()',
            ),
          )
          .toList();

  static final List<CompletionItem> _commonNodeMethods = [
    const CompletionItem(
      label: 'queue_free',
      kind: CompletionKind.method,
      detail: 'queue_free() -> void',
      documentation:
          'Queues this node to be safely deleted at the end of the current frame.',
      insertText: 'queue_free()',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: 'get_node',
      kind: CompletionKind.method,
      detail: 'get_node(path: NodePath) -> Node',
      documentation: 'Fetches a node by relative or absolute NodePath.',
      insertText: 'get_node()',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'get_parent',
      kind: CompletionKind.method,
      detail: 'get_parent() -> Node',
      documentation: 'Returns the parent node in the scene tree.',
      insertText: 'get_parent()',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'get_children',
      kind: CompletionKind.method,
      detail: 'get_children() -> Array[Node]',
      documentation: 'Returns an array of child nodes.',
      insertText: 'get_children()',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'add_child',
      kind: CompletionKind.method,
      detail: 'add_child(node: Node) -> void',
      documentation: 'Adds a child node to this node in the hierarchy.',
      insertText: 'add_child()',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'remove_child',
      kind: CompletionKind.method,
      detail: 'remove_child(node: Node) -> void',
      documentation: 'Removes a child node from this node.',
      insertText: 'remove_child()',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'connect',
      kind: CompletionKind.method,
      detail: 'connect(signal: StringName, callable: Callable) -> int',
      documentation: 'Connects a signal to a callable receiver callback.',
      insertText: 'connect()',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'emit_signal',
      kind: CompletionKind.method,
      detail: 'emit_signal(signal: StringName, ...args) -> int',
      documentation: 'Emits the specified signal with optional arguments.',
      insertText: 'emit_signal()',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'is_in_group',
      kind: CompletionKind.method,
      detail: 'is_in_group(group: StringName) -> bool',
      documentation:
          'Returns true if this node is a member of the given group.',
      insertText: 'is_in_group()',
      sortPriority: 5.0,
    ),
    const CompletionItem(
      label: 'show',
      kind: CompletionKind.method,
      detail: 'show() -> void',
      documentation: 'Makes this canvas item or control visible.',
      insertText: 'show()',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'hide',
      kind: CompletionKind.method,
      detail: 'hide() -> void',
      documentation: 'Hides this canvas item or control.',
      insertText: 'hide()',
      sortPriority: 6.0,
    ),
  ];

  static final List<CompletionItem> _commonNodeProperties =
      [
            'position',
            'global_position',
            'rotation',
            'rotation_degrees',
            'scale',
            'visible',
            'modulate',
            'self_modulate',
            'name',
            'owner',
            'process_mode',
            'z_index',
            'velocity',
          ]
          .map(
            (p) => CompletionItem(
              label: p,
              kind: CompletionKind.property,
              detail: 'property $p',
              documentation: 'Common node member property: $p',
            ),
          )
          .toList();

  static final List<CompletionItem> _commonNodeSignals =
      [
            'ready',
            'tree_entered',
            'tree_exited',
            'child_entered_tree',
            'child_exiting_tree',
            'visibility_changed',
            'pressed',
            'timeout',
            'finished',
          ]
          .map(
            (s) => CompletionItem(
              label: s,
              kind: CompletionKind.signal,
              detail: 'signal $s',
              documentation: 'Built-in node signal: $s',
            ),
          )
          .toList();

  /// Builds member completion items for an engine class.
  static List<CompletionItem> _members({
    Map<String, String> methods = const {},
    List<String> properties = const [],
    Map<String, String> signals = const {},
    List<String> constants = const [],
  }) {
    return [
      for (final entry in methods.entries)
        CompletionItem(
          label: entry.key,
          kind: CompletionKind.method,
          detail: entry.value,
          insertText: '${entry.key}()',
          isClassMember: true,
          sortPriority: 4.0,
        ),
      for (final name in properties)
        CompletionItem(
          label: name,
          kind: CompletionKind.property,
          detail: 'property $name',
          isClassMember: true,
          sortPriority: 3.0,
        ),
      for (final entry in signals.entries)
        CompletionItem(
          label: entry.key,
          kind: CompletionKind.signal,
          detail: entry.value,
          isClassMember: true,
          sortPriority: 3.0,
        ),
      for (final name in constants)
        CompletionItem(
          label: name,
          kind: CompletionKind.constant,
          detail: 'constant $name',
          isClassMember: true,
          sortPriority: 2.0,
        ),
    ];
  }

  /// Members exposed by the most common Godot engine classes, used for
  /// type-aware member access completion (`enemy.` where `enemy: Enemy`).
  static final Map<String, List<CompletionItem>> _godotClassMembers = {
    'Object': _members(
      methods: const {
        'get': 'get(property: StringName) -> Variant',
        'set': 'set(property: StringName, value: Variant) -> void',
        'call': 'call(method: StringName, ...args) -> Variant',
        'is_class': 'is_class(class: String) -> bool',
        'get_class': 'get_class() -> String',
        'duplicate': 'duplicate(deep: bool = false) -> Resource',
        'free': 'free() -> void',
        'connect': 'connect(signal: StringName, callable: Callable) -> int',
        'emit_signal': 'emit_signal(signal: StringName, ...args) -> int',
      },
      properties: const ['script'],
    ),
    'RefCounted': _members(
      methods: const {'get_reference_count': 'get_reference_count() -> int'},
    ),
    'Node': _members(
      methods: const {
        'get_node': 'get_node(path: NodePath) -> Node',
        'get_node_or_null': 'get_node_or_null(path: NodePath) -> Node',
        'get_parent': 'get_parent() -> Node',
        'get_children':
            'get_children(include_internal: bool = false) -> Array[Node]',
        'add_child': 'add_child(node: Node) -> void',
        'remove_child': 'remove_child(node: Node) -> void',
        'queue_free': 'queue_free() -> void',
        'is_inside_tree': 'is_inside_tree() -> bool',
        'get_tree': 'get_tree() -> SceneTree',
        'find_child':
            'find_child(pattern: String, recursive: bool = true) -> Node',
        'is_in_group': 'is_in_group(group: StringName) -> bool',
        'add_to_group': 'add_to_group(group: StringName) -> void',
        'connect': 'connect(signal: StringName, callable: Callable) -> int',
        'emit_signal': 'emit_signal(signal: StringName, ...args) -> int',
      },
      properties: const ['name', 'owner', 'process_mode', 'scene_file_path'],
    ),
    'Node2D': _members(
      methods: const {
        'move_local_x':
            'move_local_x(delta: float, scaled: bool = false) -> void',
        'move_local_y':
            'move_local_y(delta: float, scaled: bool = false) -> void',
        'look_at': 'look_at(point: Vector2) -> void',
        'to_local': 'to_local(global_point: Vector2) -> Vector2',
        'to_global': 'to_global(local_point: Vector2) -> Vector2',
      },
      properties: const [
        'position',
        'global_position',
        'rotation',
        'rotation_degrees',
        'scale',
        'global_scale',
        'skew',
        'z_index',
        'visible',
      ],
    ),
    'Node3D': _members(
      methods: const {
        'look_at':
            'look_at(target: Vector3, up: Vector3 = Vector3(0, 1, 0)) -> void',
        'translate': 'translate(offset: Vector3) -> void',
        'rotate_y': 'rotate_y(angle: float) -> void',
      },
      properties: const [
        'position',
        'global_position',
        'rotation',
        'scale',
        'visible',
      ],
    ),
    'CanvasItem': _members(
      methods: const {
        'show': 'show() -> void',
        'hide': 'hide() -> void',
        'queue_redraw': 'queue_redraw() -> void',
      },
      properties: const ['visible', 'modulate', 'self_modulate', 'material'],
    ),
    'Sprite2D': _members(
      methods: const {'get_rect': 'get_rect() -> Rect2'},
      properties: const [
        'texture',
        'flip_h',
        'flip_v',
        'hframes',
        'vframes',
        'frame',
        'centered',
        'offset',
        'region_enabled',
      ],
    ),
    'AnimatedSprite2D': _members(
      methods: const {
        'play':
            'play(name: StringName = "", custom_speed: float = 1.0) -> void',
        'stop': 'stop() -> void',
        'pause': 'pause() -> void',
      },
      properties: const [
        'animation',
        'sprite_frames',
        'playing',
        'frame',
        'speed_scale',
      ],
      signals: const {
        'animation_changed': 'signal animation_changed',
        'animation_finished': 'signal animation_finished',
        'frame_changed': 'signal frame_changed',
      },
    ),
    'CharacterBody2D': _members(
      methods: const {
        'move_and_slide': 'move_and_slide() -> bool',
        'is_on_floor': 'is_on_floor() -> bool',
        'is_on_wall': 'is_on_wall() -> bool',
        'is_on_ceiling': 'is_on_ceiling() -> bool',
        'apply_floor_snap': 'apply_floor_snap() -> void',
      },
      properties: const [
        'velocity',
        'motion_mode',
        'up_direction',
        'floor_max_angle',
      ],
    ),
    'RigidBody2D': _members(
      methods: const {
        'apply_impulse':
            'apply_impulse(impulse: Vector2, position: Vector2 = Vector2(0, 0)) -> void',
        'apply_force':
            'apply_force(force: Vector2, position: Vector2 = Vector2(0, 0)) -> void',
      },
      properties: const [
        'linear_velocity',
        'angular_velocity',
        'gravity_scale',
        'mass',
        'freeze',
      ],
    ),
    'Area2D': _members(
      methods: const {
        'get_overlapping_bodies': 'get_overlapping_bodies() -> Array[Node2D]',
        'get_overlapping_areas': 'get_overlapping_areas() -> Array[Area2D]',
      },
      properties: const ['monitoring', 'monitorable', 'gravity_space_override'],
      signals: const {
        'body_entered': 'signal body_entered(body: Node2D)',
        'body_exited': 'signal body_exited(body: Node2D)',
        'area_entered': 'signal area_entered(area: Area2D)',
        'area_exited': 'signal area_exited(area: Area2D)',
      },
    ),
    'CollisionShape2D': _members(
      properties: const ['shape', 'disabled', 'one_way_collision'],
    ),
    'Camera2D': _members(
      methods: const {
        'make_current': 'make_current() -> void',
        'reset_smoothing': 'reset_smoothing() -> void',
      },
      properties: const [
        'zoom',
        'offset',
        'position_smoothing_enabled',
        'current',
      ],
    ),
    'Label': _members(
      methods: const {'get_line_count': 'get_line_count() -> int'},
      properties: const [
        'text',
        'horizontal_alignment',
        'vertical_alignment',
        'autowrap_mode',
        'label_settings',
        'visible_ratio',
      ],
    ),
    'Button': _members(
      properties: const [
        'text',
        'disabled',
        'icon',
        'toggle_mode',
        'button_pressed',
      ],
      signals: const {
        'pressed': 'signal pressed',
        'button_down': 'signal button_down',
        'button_up': 'signal button_up',
        'toggled': 'signal toggled(toggled_on: bool)',
      },
    ),
    'Control': _members(
      methods: const {
        'get_rect': 'get_rect() -> Rect2',
        'set_anchors_preset': 'set_anchors_preset(preset: int) -> void',
        'grab_focus': 'grab_focus() -> void',
      },
      properties: const [
        'size',
        'position',
        'custom_minimum_size',
        'mouse_filter',
        'focus_mode',
      ],
    ),
    'Timer': _members(
      methods: const {
        'start': 'start(time_sec: float = -1) -> void',
        'stop': 'stop() -> void',
        'is_stopped': 'is_stopped() -> bool',
      },
      properties: const [
        'wait_time',
        'one_shot',
        'autostart',
        'time_left',
        'paused',
      ],
      signals: const {'timeout': 'signal timeout'},
    ),
    'AnimationPlayer': _members(
      methods: const {
        'play':
            'play(name: StringName = "", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) -> void',
        'stop': 'stop(keep_state: bool = false) -> void',
        'pause': 'pause() -> void',
        'seek': 'seek(seconds: float, update: bool = false) -> void',
      },
      properties: const [
        'current_animation',
        'speed_scale',
        'autoplay',
        'assigned_animation',
      ],
      signals: const {
        'animation_finished':
            'signal animation_finished(anim_name: StringName)',
        'animation_started': 'signal animation_started(anim_name: StringName)',
      },
    ),
    'AudioStreamPlayer': _members(
      methods: const {
        'play': 'play(from_position: float = 0.0) -> void',
        'stop': 'stop() -> void',
      },
      properties: const [
        'stream',
        'volume_db',
        'pitch_scale',
        'autoplay',
        'playing',
      ],
      signals: const {'finished': 'signal finished'},
    ),
    'ColorRect': _members(properties: const ['color']),
    'TextureRect': _members(
      properties: const ['texture', 'expand_mode', 'stretch_mode'],
    ),
    'Resource': _members(
      methods: const {
        'duplicate': 'duplicate(subresources: bool = false) -> Resource',
      },
      properties: const ['resource_path', 'resource_name'],
    ),
    'HTTPRequest': _members(
      methods: const {
        'request': 'request(url: String, ...) -> int',
        'cancel_request': 'cancel_request() -> void',
      },
      signals: const {
        'request_completed':
            'signal request_completed(result: int, response_code: int, headers, body)',
      },
    ),
  };

  /// Members of built-in GDScript value types (vectors, strings, containers).
  static final Map<String, List<CompletionItem>> _builtInTypeMembers = {
    'Vector2': _members(
      methods: const {
        'length': 'length() -> float',
        'length_squared': 'length_squared() -> float',
        'normalized': 'normalized() -> Vector2',
        'distance_to': 'distance_to(to: Vector2) -> float',
        'angle_to': 'angle_to(to: Vector2) -> float',
        'direction_to': 'direction_to(to: Vector2) -> Vector2',
        'dot': 'dot(with: Vector2) -> float',
        'cross': 'cross(with: Vector2) -> float',
        'lerp': 'lerp(to: Vector2, weight: float) -> Vector2',
        'rotated': 'rotated(angle: float) -> Vector2',
        'move_toward': 'move_toward(to: Vector2, delta: float) -> Vector2',
        'clamp': 'clamp(min: Vector2, max: Vector2) -> Vector2',
        'is_zero_approx': 'is_zero_approx() -> bool',
      },
      properties: const ['x', 'y'],
    ),
    'Vector2i': _members(
      methods: const {
        'distance_to': 'distance_to(to: Vector2i) -> float',
        'clamp': 'clamp(min: Vector2i, max: Vector2i) -> Vector2i',
      },
      properties: const ['x', 'y'],
    ),
    'Vector3': _members(
      methods: const {
        'length': 'length() -> float',
        'normalized': 'normalized() -> Vector3',
        'distance_to': 'distance_to(to: Vector3) -> float',
        'dot': 'dot(with: Vector3) -> float',
        'cross': 'cross(with: Vector3) -> Vector3',
        'lerp': 'lerp(to: Vector3, weight: float) -> Vector3',
        'rotated': 'rotated(axis: Vector3, angle: float) -> Vector3',
        'move_toward': 'move_toward(to: Vector3, delta: float) -> Vector3',
      },
      properties: const ['x', 'y', 'z'],
    ),
    'Vector3i': _members(properties: const ['x', 'y', 'z']),
    'Color': _members(
      methods: const {
        'lerp': 'lerp(to: Color, weight: float) -> Color',
        'darkened': 'darkened(amount: float) -> Color',
        'lightened': 'lightened(amount: float) -> Color',
        'to_html': 'to_html(with_alpha: bool = true) -> String',
        'blend': 'blend(over: Color) -> Color',
      },
      properties: const ['r', 'g', 'b', 'a'],
      constants: const [
        'BLACK',
        'WHITE',
        'RED',
        'GREEN',
        'BLUE',
        'TRANSPARENT',
      ],
    ),
    'String': _members(
      methods: const {
        'length': 'length() -> int',
        'to_upper': 'to_upper() -> String',
        'to_lower': 'to_lower() -> String',
        'capitalize': 'capitalize() -> String',
        'split':
            'split(delimiter: String, allow_empty: bool = true) -> PackedStringArray',
        'join': 'join(parts: PackedStringArray) -> String',
        'substr': 'substr(from: int, len: int = -1) -> String',
        'find': 'find(what: String, from: int = 0) -> int',
        'rfind': 'rfind(what: String, from: int = -1) -> int',
        'replace': 'replace(what: String, with: String) -> String',
        'begins_with': 'begins_with(text: String) -> bool',
        'ends_with': 'ends_with(text: String) -> bool',
        'contains': 'contains(what: String) -> bool',
        'strip_edges':
            'strip_edges(left: bool = true, right: bool = true) -> String',
        'format': 'format(values: Variant) -> String',
        'to_int': 'to_int() -> int',
        'to_float': 'to_float() -> float',
        'is_empty': 'is_empty() -> bool',
        'pad_zeros': 'pad_zeros(digits: int) -> String',
        'sha256_text': 'sha256_text() -> String',
      },
    ),
    'StringName': _members(
      methods: const {
        'to_lower': 'to_lower() -> StringName',
        'to_upper': 'to_upper() -> StringName',
      },
    ),
    'NodePath': _members(
      methods: const {
        'get_name': 'get_name(idx: int) -> StringName',
        'get_name_count': 'get_name_count() -> int',
        'is_absolute': 'is_absolute() -> bool',
      },
    ),
    'Array': _members(
      methods: const {
        'size': 'size() -> int',
        'is_empty': 'is_empty() -> bool',
        'clear': 'clear() -> void',
        'append': 'append(value: Variant) -> void',
        'push_back': 'push_back(value: Variant) -> void',
        'push_front': 'push_front(value: Variant) -> void',
        'pop_back': 'pop_back() -> Variant',
        'pop_front': 'pop_front() -> Variant',
        'insert': 'insert(position: int, value: Variant) -> void',
        'remove_at': 'remove_at(position: int) -> void',
        'erase': 'erase(value: Variant) -> void',
        'has': 'has(value: Variant) -> bool',
        'find': 'find(value: Variant, from: int = 0) -> int',
        'reverse': 'reverse() -> void',
        'sort': 'sort() -> void',
        'shuffle': 'shuffle() -> void',
        'slice': 'slice(begin: int, end: int = 2147483647) -> Array',
        'duplicate': 'duplicate(deep: bool = false) -> Array',
        'map': 'map(method: Callable) -> Array',
        'filter': 'filter(method: Callable) -> Array',
        'reduce': 'reduce(method: Callable, accum: Variant = null) -> Variant',
        'any': 'any(method: Callable) -> bool',
        'all': 'all(method: Callable) -> bool',
        'min': 'min() -> Variant',
        'max': 'max() -> Variant',
      },
      properties: const ['front', 'back'],
    ),
    'Dictionary': _members(
      methods: const {
        'size': 'size() -> int',
        'is_empty': 'is_empty() -> bool',
        'clear': 'clear() -> void',
        'has': 'has(key: Variant) -> bool',
        'has_all': 'has_all(keys: Array) -> bool',
        'get': 'get(key: Variant, default: Variant = null) -> Variant',
        'set': 'set(key: Variant, value: Variant) -> void',
        'erase': 'erase(key: Variant) -> bool',
        'keys': 'keys() -> Array',
        'values': 'values() -> Array',
        'merge':
            'merge(dictionary: Dictionary, overwrite: bool = false) -> void',
        'duplicate': 'duplicate(deep: bool = false) -> Dictionary',
        'find_key': 'find_key(value: Variant) -> Variant',
      },
    ),
    'Callable': _members(
      methods: const {
        'call': 'call(...args: Variant) -> Variant',
        'is_valid': 'is_valid() -> bool',
        'bind': 'bind(...args: Variant) -> Callable',
      },
    ),
    'Signal': _members(
      methods: const {
        'emit': 'emit(...args: Variant) -> void',
        'connect': 'connect(callable: Callable) -> void',
        'disconnect': 'disconnect(callable: Callable) -> void',
        'is_connected': 'is_connected(callable: Callable) -> bool',
      },
    ),
  };

  /// Parameter lists for common virtual (lifecycle) methods, used to suggest
  /// parameter names while declaring `func _process(`.
  static final Map<String, List<ParameterInfo>> _virtualMethodParameters = {
    '_ready': const [],
    '_init': const [],
    '_process': const [ParameterInfo(name: 'delta', type: 'float')],
    '_physics_process': const [ParameterInfo(name: 'delta', type: 'float')],
    '_input': const [ParameterInfo(name: 'event', type: 'InputEvent')],
    '_unhandled_input': const [
      ParameterInfo(name: 'event', type: 'InputEvent'),
    ],
    '_unhandled_key_input': const [
      ParameterInfo(name: 'event', type: 'InputEvent'),
    ],
    '_shortcut_input': const [ParameterInfo(name: 'event', type: 'InputEvent')],
    '_gui_input': const [ParameterInfo(name: 'event', type: 'InputEvent')],
    '_enter_tree': const [],
    '_exit_tree': const [],
    '_draw': const [],
    '_notification': const [ParameterInfo(name: 'what', type: 'int')],
    '_to_string': const [],
  };

  /// Pattern proposals offered inside a `match` branch.
  static final List<CompletionItem> _matchPatternCompletions = [
    const CompletionItem(
      label: '_',
      kind: CompletionKind.snippet,
      detail: '_  (wildcard)',
      documentation: 'Matches any value.',
      insertText: '_',
      sortPriority: 10.0,
    ),
    const CompletionItem(
      label: 'var binding',
      kind: CompletionKind.snippet,
      detail: 'var name',
      documentation: 'Binds the matched value to a new local variable.',
      insertText: 'var ',
      sortPriority: 9.0,
    ),
    const CompletionItem(
      label: 'array pattern',
      kind: CompletionKind.snippet,
      detail: '[a, b, c]',
      documentation: 'Matches an array with the given element patterns.',
      insertText: '[a, b, c]',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: 'rest pattern',
      kind: CompletionKind.snippet,
      detail: '[first, .., last]',
      documentation: 'Matches an array, capturing the first and last elements.',
      insertText: '[first, .., last]',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'dictionary pattern',
      kind: CompletionKind.snippet,
      detail: '{key: value}',
      documentation: 'Matches a dictionary containing the given keys.',
      insertText: '{key: value}',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: 'guard',
      kind: CompletionKind.snippet,
      detail: 'pattern when condition:',
      documentation: 'Adds a `when` guard to the current match pattern.',
      insertText: ' when condition:',
      sortPriority: 4.0,
    ),
  ];

  /// Statement keywords valid at the start of a line inside a function body.
  static final List<CompletionItem> _statementKeywordCompletions =
      [
            'if',
            'elif',
            'else',
            'for',
            'while',
            'match',
            'return',
            'var',
            'const',
            'pass',
            'break',
            'continue',
            'await',
            'assert',
            'breakpoint',
          ]
          .map(
            (kw) => CompletionItem(
              label: kw,
              kind: CompletionKind.keyword,
              detail: 'keyword $kw',
              sortPriority: 5.0,
            ),
          )
          .toList();

  static final List<CompletionItem> _virtualMethodCompletions = [
    const CompletionItem(
      label: '_ready',
      kind: CompletionKind.method,
      detail: 'func _ready() -> void',
      documentation:
          'Called when the node enters the scene tree for the first time.',
      insertText: 'func _ready() -> void:\n\tpass',
      sortPriority: 10.0,
    ),
    const CompletionItem(
      label: '_process',
      kind: CompletionKind.method,
      detail: 'func _process(delta: float) -> void',
      documentation:
          'Called every frame during process step with elapsed delta time.',
      insertText: 'func _process(delta: float) -> void:\n\tpass',
      sortPriority: 9.0,
    ),
    const CompletionItem(
      label: '_physics_process',
      kind: CompletionKind.method,
      detail: 'func _physics_process(delta: float) -> void',
      documentation:
          'Called every fixed physics frame with fixed physics delta.',
      insertText: 'func _physics_process(delta: float) -> void:\n\tpass',
      sortPriority: 9.0,
    ),
    const CompletionItem(
      label: '_input',
      kind: CompletionKind.method,
      detail: 'func _input(event: InputEvent) -> void',
      documentation: 'Called when there is an input event before GUI handling.',
      insertText: 'func _input(event: InputEvent) -> void:\n\tpass',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: '_unhandled_input',
      kind: CompletionKind.method,
      detail: 'func _unhandled_input(event: InputEvent) -> void',
      documentation:
          'Called for input events that were not consumed by any GUI control.',
      insertText: 'func _unhandled_input(event: InputEvent) -> void:\n\tpass',
      sortPriority: 8.0,
    ),
    const CompletionItem(
      label: '_enter_tree',
      kind: CompletionKind.method,
      detail: 'func _enter_tree() -> void',
      documentation: 'Called when the node enters the SceneTree.',
      insertText: 'func _enter_tree() -> void:\n\tpass',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: '_exit_tree',
      kind: CompletionKind.method,
      detail: 'func _exit_tree() -> void',
      documentation: 'Called when the node leaves the SceneTree.',
      insertText: 'func _exit_tree() -> void:\n\tpass',
      sortPriority: 7.0,
    ),
    const CompletionItem(
      label: '_draw',
      kind: CompletionKind.method,
      detail: 'func _draw() -> void',
      documentation: 'Called when 2D canvas item needs custom painting.',
      insertText: 'func _draw() -> void:\n\tpass',
      sortPriority: 6.0,
    ),
  ];

  static final List<CompletionItem> _declarationKeywordCompletions =
      [
            'func',
            'var',
            'const',
            'signal',
            'class_name',
            'extends',
            'class',
            'enum',
            'static',
            'if',
            'elif',
            'else',
            'for',
            'while',
            'match',
            'return',
            'pass',
            'break',
            'continue',
            'breakpoint',
            'assert',
          ]
          .map(
            (kw) => CompletionItem(
              label: kw,
              kind: CompletionKind.keyword,
              detail: 'keyword $kw',
              sortPriority: 5.0,
            ),
          )
          .toList();

  static final List<CompletionItem> _codeSnippets = [
    const CompletionItem(
      label: 'func',
      kind: CompletionKind.snippet,
      detail: 'func name(args) -> void:',
      documentation: 'Function declaration snippet',
      insertText: 'func my_function() -> void:\n\tpass',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'for',
      kind: CompletionKind.snippet,
      detail: 'for i in range(10):',
      documentation: 'For loop iterator snippet',
      insertText: 'for item in collection:\n\tpass',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'if',
      kind: CompletionKind.snippet,
      detail: 'if condition:',
      documentation: 'If conditional statement snippet',
      insertText: 'if condition:\n\tpass',
      sortPriority: 6.0,
    ),
    const CompletionItem(
      label: 'while',
      kind: CompletionKind.snippet,
      detail: 'while condition:',
      documentation: 'While loop snippet',
      insertText: 'while condition:\n\tpass',
      sortPriority: 5.0,
    ),
    const CompletionItem(
      label: 'match',
      kind: CompletionKind.snippet,
      detail: 'match expression:',
      documentation: 'Pattern match statement snippet',
      insertText: 'match value:\n\tpattern:\n\t\tpass',
      sortPriority: 5.0,
    ),
  ];

  static final List<CompletionItem> _expressionKeywordCompletions =
      [
            'true',
            'false',
            'null',
            'self',
            'super',
            'not',
            'and',
            'or',
            'in',
            'is',
            'as',
          ]
          .map(
            (k) => CompletionItem(
              label: k,
              kind: CompletionKind.keyword,
              detail: 'keyword $k',
              sortPriority: 4.0,
            ),
          )
          .toList();

  static final List<CompletionItem> _globalConstantCompletions =
      GlobalScope.getConstants().entries
          .map(
            (e) => CompletionItem(
              label: e.key,
              kind: CompletionKind.constant,
              detail: e.value.typeName,
              documentation: 'Global constant: ${e.key} = ${e.value}',
            ),
          )
          .toList();

  static final List<CompletionItem> _builtInFunctionCompletions =
      BuiltinFunctions.getDefinitions()
          .map(
            (fn) => CompletionItem(
              label: fn.name,
              kind: CompletionKind.function,
              detail: '${fn.name}()',
              documentation:
                  fn.documentation ?? 'Built-in GDScript function: ${fn.name}',
              insertText: '${fn.name}()',
            ),
          )
          .toList();

  // Signature descriptors registry for built-ins and engine utilities
  static final Map<String, _SignatureDescriptor> _signatureRegistry = {
    'print': _SignatureDescriptor(
      signature: 'func print(...args: Variant) -> void',
      parameters: [const ParameterInfo(name: 'args', type: 'Variant')],
      documentation: 'Prints one or more values to standard output.',
      returnType: 'void',
      isVararg: true,
    ),
    'prints': _SignatureDescriptor(
      signature: 'func prints(...args: Variant) -> void',
      parameters: [const ParameterInfo(name: 'args', type: 'Variant')],
      documentation: 'Prints values separated by spaces with trailing newline.',
      returnType: 'void',
      isVararg: true,
    ),
    'printt': _SignatureDescriptor(
      signature: 'func printt(...args: Variant) -> void',
      parameters: [const ParameterInfo(name: 'args', type: 'Variant')],
      documentation: 'Prints values separated by tabs with trailing newline.',
      returnType: 'void',
      isVararg: true,
    ),
    'printerr': _SignatureDescriptor(
      signature: 'func printerr(...args: Variant) -> void',
      parameters: [const ParameterInfo(name: 'args', type: 'Variant')],
      documentation: 'Prints one or more values to the standard error output.',
      returnType: 'void',
      isVararg: true,
    ),
    'clamp': _SignatureDescriptor(
      signature: 'func clamp(value: float, min: float, max: float) -> float',
      parameters: [
        const ParameterInfo(name: 'value', type: 'float'),
        const ParameterInfo(name: 'min', type: 'float'),
        const ParameterInfo(name: 'max', type: 'float'),
      ],
      documentation: 'Clamps value to range between min and max bounds.',
      returnType: 'float',
    ),
    'min': _SignatureDescriptor(
      signature: 'func min(a: float, b: float) -> float',
      parameters: [
        const ParameterInfo(name: 'a', type: 'float'),
        const ParameterInfo(name: 'b', type: 'float'),
      ],
      documentation: 'Returns the minimum of two numerical values.',
      returnType: 'float',
    ),
    'max': _SignatureDescriptor(
      signature: 'func max(a: float, b: float) -> float',
      parameters: [
        const ParameterInfo(name: 'a', type: 'float'),
        const ParameterInfo(name: 'b', type: 'float'),
      ],
      documentation: 'Returns the maximum of two numerical values.',
      returnType: 'float',
    ),
    'lerp': _SignatureDescriptor(
      signature:
          'func lerp(from: Variant, to: Variant, weight: float) -> Variant',
      parameters: [
        const ParameterInfo(name: 'from', type: 'Variant'),
        const ParameterInfo(name: 'to', type: 'Variant'),
        const ParameterInfo(name: 'weight', type: 'float'),
      ],
      documentation:
          'Linearly interpolates between two values by weight [0..1].',
      returnType: 'Variant',
    ),
    'randf': _SignatureDescriptor(
      signature: 'func randf() -> float',
      parameters: [],
      documentation:
          'Returns a pseudo-random floating-point value between 0.0 and 1.0.',
      returnType: 'float',
    ),
    'randi': _SignatureDescriptor(
      signature: 'func randi() -> int',
      parameters: [],
      documentation: 'Returns a pseudo-random 32-bit integer.',
      returnType: 'int',
    ),
    'randf_range': _SignatureDescriptor(
      signature: 'func randf_range(from: float, to: float) -> float',
      parameters: [
        const ParameterInfo(name: 'from', type: 'float'),
        const ParameterInfo(name: 'to', type: 'float'),
      ],
      documentation: 'Returns a pseudo-random float between from and to.',
      returnType: 'float',
    ),
    'randi_range': _SignatureDescriptor(
      signature: 'func randi_range(from: int, to: int) -> int',
      parameters: [
        const ParameterInfo(name: 'from', type: 'int'),
        const ParameterInfo(name: 'to', type: 'int'),
      ],
      documentation:
          'Returns a pseudo-random integer between from and to (inclusive).',
      returnType: 'int',
    ),
    'deg_to_rad': _SignatureDescriptor(
      signature: 'func deg_to_rad(deg: float) -> float',
      parameters: [const ParameterInfo(name: 'deg', type: 'float')],
      documentation: 'Converts an angle from degrees to radians.',
      returnType: 'float',
    ),
    'rad_to_deg': _SignatureDescriptor(
      signature: 'func rad_to_deg(rad: float) -> float',
      parameters: [const ParameterInfo(name: 'rad', type: 'float')],
      documentation: 'Converts an angle from radians to degrees.',
      returnType: 'float',
    ),
    'sin': _SignatureDescriptor(
      signature: 'func sin(angle_rad: float) -> float',
      parameters: [const ParameterInfo(name: 'angle_rad', type: 'float')],
      documentation: 'Returns the sine of angle in radians.',
      returnType: 'float',
    ),
    'cos': _SignatureDescriptor(
      signature: 'func cos(angle_rad: float) -> float',
      parameters: [const ParameterInfo(name: 'angle_rad', type: 'float')],
      documentation: 'Returns the cosine of angle in radians.',
      returnType: 'float',
    ),
    'tan': _SignatureDescriptor(
      signature: 'func tan(angle_rad: float) -> float',
      parameters: [const ParameterInfo(name: 'angle_rad', type: 'float')],
      documentation: 'Returns the tangent of angle in radians.',
      returnType: 'float',
    ),
    'sqrt': _SignatureDescriptor(
      signature: 'func sqrt(s: float) -> float',
      parameters: [const ParameterInfo(name: 's', type: 'float')],
      documentation: 'Returns the square root of s.',
      returnType: 'float',
    ),
    'pow': _SignatureDescriptor(
      signature: 'func pow(base: float, exp: float) -> float',
      parameters: [
        const ParameterInfo(name: 'base', type: 'float'),
        const ParameterInfo(name: 'exp', type: 'float'),
      ],
      documentation: 'Returns base raised to the exp power.',
      returnType: 'float',
    ),
    'abs': _SignatureDescriptor(
      signature: 'func abs(s: float) -> float',
      parameters: [const ParameterInfo(name: 's', type: 'float')],
      documentation: 'Returns the absolute value of s.',
      returnType: 'float',
    ),
    'sign': _SignatureDescriptor(
      signature: 'func sign(s: float) -> float',
      parameters: [const ParameterInfo(name: 's', type: 'float')],
      documentation: 'Returns -1.0 if s < 0, 1.0 if s > 0, and 0.0 if s == 0.',
      returnType: 'float',
    ),
    'round': _SignatureDescriptor(
      signature: 'func round(s: float) -> float',
      parameters: [const ParameterInfo(name: 's', type: 'float')],
      documentation: 'Rounds s to the nearest whole integer.',
      returnType: 'float',
    ),
    'floor': _SignatureDescriptor(
      signature: 'func floor(s: float) -> float',
      parameters: [const ParameterInfo(name: 's', type: 'float')],
      documentation: 'Rounds s down to the largest integer <= s.',
      returnType: 'float',
    ),
    'ceil': _SignatureDescriptor(
      signature: 'func ceil(s: float) -> float',
      parameters: [const ParameterInfo(name: 's', type: 'float')],
      documentation: 'Rounds s up to the smallest integer >= s.',
      returnType: 'float',
    ),
    'is_instance_valid': _SignatureDescriptor(
      signature: 'func is_instance_valid(instance: Object) -> bool',
      parameters: [const ParameterInfo(name: 'instance', type: 'Object')],
      documentation: 'Returns true if instance is a valid, un-freed Object.',
      returnType: 'bool',
    ),
    'len': _SignatureDescriptor(
      signature: 'func len(s: Variant) -> int',
      parameters: [const ParameterInfo(name: 's', type: 'Variant')],
      documentation: 'Returns length of an Array, Dictionary, or String.',
      returnType: 'int',
    ),
    'str': _SignatureDescriptor(
      signature: 'func str(...args: Variant) -> String',
      parameters: [const ParameterInfo(name: 'args', type: 'Variant')],
      documentation: 'Converts arguments to their String representation.',
      returnType: 'String',
      isVararg: true,
    ),
    'get_node': _SignatureDescriptor(
      signature: 'func get_node(path: NodePath) -> Node',
      parameters: [const ParameterInfo(name: 'path', type: 'NodePath')],
      documentation: 'Fetches a node by relative or absolute NodePath.',
      returnType: 'Node',
    ),
    'add_child': _SignatureDescriptor(
      signature:
          'func add_child(node: Node, force_readable_name: bool = false) -> void',
      parameters: [
        const ParameterInfo(name: 'node', type: 'Node'),
        const ParameterInfo(
          name: 'force_readable_name',
          type: 'bool',
          defaultValue: 'false',
        ),
      ],
      documentation: 'Adds a child node to this node in the hierarchy.',
      returnType: 'void',
    ),
    'remove_child': _SignatureDescriptor(
      signature: 'func remove_child(node: Node) -> void',
      parameters: [const ParameterInfo(name: 'node', type: 'Node')],
      documentation: 'Removes a child node from this node.',
      returnType: 'void',
    ),
    'connect': _SignatureDescriptor(
      signature:
          'func connect(signal: StringName, callable: Callable, flags: int = 0) -> int',
      parameters: [
        const ParameterInfo(name: 'signal', type: 'StringName'),
        const ParameterInfo(name: 'callable', type: 'Callable'),
        const ParameterInfo(name: 'flags', type: 'int', defaultValue: '0'),
      ],
      documentation: 'Connects a signal to a callable receiver callback.',
      returnType: 'int',
    ),
    'emit_signal': _SignatureDescriptor(
      signature:
          'func emit_signal(signal: StringName, ...args: Variant) -> int',
      parameters: [
        const ParameterInfo(name: 'signal', type: 'StringName'),
        const ParameterInfo(name: 'args', type: 'Variant'),
      ],
      documentation: 'Emits the specified signal with optional arguments.',
      returnType: 'int',
      isVararg: true,
    ),
    'queue_free': _SignatureDescriptor(
      signature: 'func queue_free() -> void',
      parameters: [],
      documentation: 'Queues this node to be safely deleted at frame end.',
      returnType: 'void',
    ),
  };

  // ===========================================================================
  // Ranking and Scoring Engine
  // ===========================================================================

  static List<CompletionItem> _rankAndFilter(
    List<CompletionItem> candidates,
    String prefix, {
    bool isContextExpected = false,
  }) {
    final scoredItems = <CompletionItem>[];

    for (final item in candidates) {
      final score = _calculateScore(
        item,
        prefix,
        isContextExpected: isContextExpected,
      );
      if (score >= 0) {
        scoredItems.add(item.copyWith(score: score));
      }
    }

    scoredItems.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.label.compareTo(b.label);
    });

    return scoredItems;
  }

  static double _calculateScore(
    CompletionItem item,
    String prefix, {
    bool isContextExpected = false,
  }) {
    if (prefix.isEmpty) {
      return item.sortPriority +
          (item.isLocal ? 50.0 : 0.0) +
          (item.isClassMember ? 30.0 : 0.0) +
          (isContextExpected ? 40.0 : 0.0);
    }

    double score = 0.0;
    final label = item.label.startsWith('@')
        ? item.label.substring(1)
        : item.label;
    final lowerLabel = label.toLowerCase();
    final lowerPrefix = prefix.toLowerCase();

    if (label == prefix) {
      score += 150.0;
    } else if (lowerLabel == lowerPrefix) {
      score += 130.0;
    } else if (label.startsWith(prefix)) {
      score += 100.0;
    } else if (lowerLabel.startsWith(lowerPrefix)) {
      score += 80.0;
    } else if (label.contains(prefix)) {
      score += 50.0;
    } else if (lowerLabel.contains(lowerPrefix)) {
      score += 40.0;
    } else {
      final fuzzy = _computeFuzzyScore(label, prefix);
      if (fuzzy > 0) {
        score += fuzzy;
      } else {
        return -1.0;
      }
    }

    if (item.isLocal) score += 50.0;
    if (item.isClassMember) score += 30.0;
    if (isContextExpected) score += 40.0;
    score += item.sortPriority;

    return score;
  }

  static double _computeFuzzyScore(String label, String prefix) {
    final l = label.toLowerCase();
    final p = prefix.toLowerCase();
    var pIdx = 0;
    var lIdx = 0;
    var consecutive = 0;
    var score = 0.0;

    while (pIdx < p.length && lIdx < l.length) {
      if (p[pIdx] == l[lIdx]) {
        consecutive++;
        score += 10.0 + (consecutive * 5.0);
        pIdx++;
      } else {
        consecutive = 0;
      }
      lIdx++;
    }

    if (pIdx == p.length) {
      return score.clamp(10.0, 60.0);
    }
    return 0.0;
  }

  // ===========================================================================
  // AST Symbol Extraction Helpers
  // ===========================================================================

  /// Converts a list of declarations into member completion items.
  static List<CompletionItem> _membersFromDecls(List<Stmt> declarations) {
    final results = <CompletionItem>[];
    for (final decl in declarations) {
      if (decl is FuncDecl) {
        results.add(
          CompletionItem(
            label: decl.name,
            kind: CompletionKind.function,
            detail: 'func ${decl.name}()',
            insertText: '${decl.name}()',
            returnType: decl.returnType,
            isClassMember: true,
            sortPriority: 5.0,
          ),
        );
      } else if (decl is VarStmt) {
        results.add(
          CompletionItem(
            label: decl.name,
            kind: decl.isConst
                ? CompletionKind.constant
                : CompletionKind.variable,
            detail: decl.isConst ? 'const ${decl.name}' : 'var ${decl.name}',
            returnType: decl.typeAnnotation,
            isClassMember: true,
            sortPriority: 5.0,
          ),
        );
      } else if (decl is ClassDecl) {
        results.add(
          CompletionItem(
            label: decl.name,
            kind: CompletionKind.classType,
            detail: 'class ${decl.name}',
            isClassMember: true,
            sortPriority: 4.0,
          ),
        );
      } else if (decl is SignalDecl) {
        results.add(
          CompletionItem(
            label: decl.name,
            kind: CompletionKind.signal,
            detail: 'signal ${decl.name}',
            isClassMember: true,
            sortPriority: 4.0,
          ),
        );
      } else if (decl is EnumDecl && decl.name != null) {
        results.add(
          CompletionItem(
            label: decl.name!,
            kind: CompletionKind.enumType,
            detail: 'enum ${decl.name}',
            isClassMember: true,
            sortPriority: 4.0,
          ),
        );
      }
    }
    return results;
  }

  static List<CompletionItem> _extractScriptMembers(String sourceCode) {
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();
      return _membersFromDecls(ast.declarations);
    } catch (_) {}
    return const [];
  }

  /// Members declared by the script class named [typeName] — either the
  /// script's own `class_name` or an inner `class` declaration.
  static List<CompletionItem> _extractScriptClassMembers(
    String sourceCode,
    String typeName,
  ) {
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      if (ast.className?.name == typeName) {
        return _membersFromDecls(ast.declarations);
      }
      for (final decl in ast.declarations) {
        if (decl is ClassDecl && decl.name == typeName) {
          return _membersFromDecls(decl.members);
        }
      }
    } catch (_) {}
    return const [];
  }

  static List<CompletionItem> _extractLocalSymbols(
    String sourceCode,
    int offset,
  ) {
    final results = <CompletionItem>[];
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      for (final decl in ast.declarations) {
        if (decl is FuncDecl &&
            offset >= decl.location.offset &&
            offset <= (decl.body.location.offset + decl.body.location.length)) {
          // Parameters
          for (final p in decl.parameters) {
            results.add(
              CompletionItem(
                label: p.name,
                kind: CompletionKind.variable,
                detail: p.typeAnnotation != null
                    ? 'param ${p.name}: ${p.typeAnnotation}'
                    : 'param ${p.name}',
                returnType: p.typeAnnotation,
                isLocal: true,
                sortPriority: 10.0,
              ),
            );
          }
          // Local variables in body
          if (decl.body is BlockStmt) {
            final block = decl.body as BlockStmt;
            for (final s in block.statements) {
              if (s is VarStmt && s.location.offset < offset) {
                results.add(
                  CompletionItem(
                    label: s.name,
                    kind: s.isConst
                        ? CompletionKind.constant
                        : CompletionKind.variable,
                    detail: s.isConst ? 'const ${s.name}' : 'var ${s.name}',
                    returnType: s.typeAnnotation,
                    isLocal: true,
                    sortPriority: 10.0,
                  ),
                );
              }
            }
          }
          break;
        }
      }
    } catch (_) {}
    return results;
  }

  /// Whether [offset] lies inside the body of a function declaration,
  /// including functions nested within a `class` block.
  ///
  /// A trailing indented line that has no statement yet (an empty line the
  /// user is about to type on) is treated as part of the body by padding the
  /// truncated source with a placeholder statement at the same indentation.
  static bool _isInsideFunction(String sourceCode, int offset) {
    try {
      final clamped = offset.clamp(0, sourceCode.length);
      final cursorLineStart = sourceCode.lastIndexOf('\n', clamped - 1) + 1;
      final indent =
          RegExp(r'^[ \t]*')
              .firstMatch(sourceCode.substring(cursorLineStart, clamped))
              ?.group(0) ??
          '';
      final padded = '${sourceCode.substring(0, clamped)}\n${indent}pass';

      final source = Source.memory(padded);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      bool contains(FuncDecl fn) {
        final start = fn.body.location.offset;
        final end = start + fn.body.location.length;
        return clamped >= fn.location.offset && clamped <= end;
      }

      bool visit(List<Stmt> decls) {
        for (final decl in decls) {
          if (decl is FuncDecl && contains(decl)) return true;
          if (decl is ClassDecl && visit(decl.members)) return true;
        }
        return false;
      }

      return visit(ast.declarations);
    } catch (_) {}
    return false;
  }

  static List<CompletionItem> _extractScriptClasses(String sourceCode) {
    final results = <CompletionItem>[];
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      if (ast.className != null) {
        results.add(
          CompletionItem(
            label: ast.className!.name,
            kind: CompletionKind.classType,
            detail: 'class_name ${ast.className!.name}',
            sortPriority: 10.0,
          ),
        );
      }
      for (final decl in ast.declarations) {
        if (decl is ClassDecl) {
          results.add(
            CompletionItem(
              label: decl.name,
              kind: CompletionKind.classType,
              detail: 'class ${decl.name}',
              sortPriority: 8.0,
            ),
          );
        }
      }
    } catch (_) {}
    return results;
  }

  static List<CompletionItem> _extractScriptSignals(String sourceCode) {
    final results = <CompletionItem>[];
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      for (final decl in ast.declarations) {
        if (decl is SignalDecl) {
          results.add(
            CompletionItem(
              label: decl.name,
              kind: CompletionKind.signal,
              detail: 'signal ${decl.name}',
              sortPriority: 8.0,
            ),
          );
        }
      }
    } catch (_) {}
    return results;
  }

  static String _extractExpressionBeforeDot(String line, int dotOffsetInLine) {
    var i = dotOffsetInLine - 1;
    while (i >= 0 && line[i].trim().isEmpty) {
      i--;
    }
    final end = i + 1;
    while (i >= 0 && _isIdentifierChar(line[i])) {
      i--;
    }
    return line.substring(i + 1, end);
  }

  /// Member candidates for the expression immediately left of a dot.
  ///
  /// Resolves the declared/inferred type of a local variable, parameter or
  /// script member and returns that type's members; falls back to generic
  /// collection/node members when the type is unknown.
  static List<CompletionItem> _dotMemberCandidates(
    String sourceCode,
    String lineBeforeCursor,
    int dotIndexInLine,
  ) {
    final expr = _extractExpressionBeforeDot(lineBeforeCursor, dotIndexInLine);

    if (expr == 'self') {
      return [
        ..._extractScriptMembers(sourceCode),
        ..._commonNodeMethods,
        ..._commonNodeProperties,
      ];
    }
    if (expr == 'super') {
      return [..._extractScriptMembers(sourceCode), ..._commonNodeMethods];
    }

    final typeName = expr.isEmpty
        ? null
        : _resolveExpressionType(sourceCode, expr);
    if (typeName != null) {
      final scriptMembers = _extractScriptClassMembers(sourceCode, typeName);
      if (scriptMembers.isNotEmpty) {
        return [
          ...scriptMembers,
          ..._commonNodeMethods,
          ..._commonNodeProperties,
          ..._builtInMemberMethods,
        ];
      }
      final engineMembers = _godotClassMembers[typeName];
      if (engineMembers != null) {
        return [
          ...engineMembers,
          ..._commonNodeMethods,
          ..._commonNodeProperties,
          ..._builtInMemberMethods,
        ];
      }
      final builtInMembers = _builtInTypeMembers[typeName];
      if (builtInMembers != null) {
        return [...builtInMembers, ..._builtInMemberMethods];
      }
      // Unknown user type: offer the script's own members plus generics.
      return [
        ..._extractScriptMembers(sourceCode),
        ..._genericMemberCandidates,
      ];
    }

    return _genericMemberCandidates;
  }

  static final List<CompletionItem> _genericMemberCandidates = [
    ..._builtInMemberMethods,
    ..._commonNodeMethods,
    ..._commonNodeProperties,
  ];

  /// Resolves the declared or inferred type name of the identifier [name].
  static String? _resolveExpressionType(String sourceCode, String name) {
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      String? search(List<Stmt> decls) {
        for (final decl in decls) {
          if (decl is VarStmt && decl.name == name) {
            final type = _typeFromVar(decl);
            if (type != null) return type;
          } else if (decl is FuncDecl) {
            for (final p in decl.parameters) {
              if (p.name == name && p.typeAnnotation != null) {
                return _normalizeTypeName(p.typeAnnotation!);
              }
            }
            final nested = _searchBody(decl.body, name);
            if (nested != null) return nested;
          } else if (decl is ClassDecl) {
            final nested = search(decl.members);
            if (nested != null) return nested;
          } else if (decl is ForStmt && decl.variable == name) {
            if (decl.typeAnnotation != null) {
              return _normalizeTypeName(decl.typeAnnotation!);
            }
          } else {
            final nested = _searchBody(decl, name);
            if (nested != null) return nested;
          }
        }
        return null;
      }

      return search(ast.declarations);
    } catch (_) {}
    return null;
  }

  static String? _searchBody(Stmt stmt, String name) {
    if (stmt is BlockStmt) {
      for (final s in stmt.statements) {
        if (s is VarStmt && s.name == name) {
          final type = _typeFromVar(s);
          if (type != null) return type;
        }
        final nested = _searchBody(s, name);
        if (nested != null) return nested;
      }
    } else if (stmt is IfStmt) {
      final branches = <Stmt>[
        stmt.thenBranch,
        ...stmt.elifBranches.map((e) => e.body),
        if (stmt.elseBranch != null) stmt.elseBranch!,
      ];
      for (final branch in branches) {
        final nested = _searchBody(branch, name);
        if (nested != null) return nested;
      }
    } else if (stmt is ForStmt) {
      if (stmt.variable == name && stmt.typeAnnotation != null) {
        return _normalizeTypeName(stmt.typeAnnotation!);
      }
      return _searchBody(stmt.body, name);
    } else if (stmt is WhileStmt) {
      return _searchBody(stmt.body, name);
    } else if (stmt is MatchStmt) {
      for (final branch in stmt.branches) {
        final nested = _searchBody(branch.body, name);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  static String? _typeFromVar(VarStmt varStmt) {
    if (varStmt.typeAnnotation != null && varStmt.typeAnnotation!.isNotEmpty) {
      return _normalizeTypeName(varStmt.typeAnnotation!);
    }
    final init = varStmt.initializer;
    if (init is AsExpr) return _normalizeTypeName(init.targetType);
    if (init is CallExpr) return _callResultType(init);
    if (init is IdentifierExpr) return _normalizeTypeName(init.name);
    if (init is ArrayExpr) return 'Array';
    if (init is DictionaryExpr) return 'Dictionary';
    if (init is LiteralExpr) {
      switch (init.tokenType) {
        case TokenType.stringLiteral:
        case TokenType.multilineString:
          return 'String';
        case TokenType.stringNameLiteral:
          return 'StringName';
        case TokenType.nodePathLiteral:
          return 'NodePath';
        case TokenType.integerLiteral:
          return 'int';
        case TokenType.floatLiteral:
          return 'float';
        case TokenType.kwTrue:
        case TokenType.kwFalse:
          return 'bool';
        default:
          break;
      }
    }
    return null;
  }

  /// Best-effort return type of a constructor call: `Enemy.new()` -> `Enemy`,
  /// `Vector2(...)` -> `Vector2`.
  static String? _callResultType(CallExpr call) {
    final callee = call.callee;
    if (callee is IdentifierExpr) {
      final name = callee.name;
      if (_builtInTypeNames.contains(name) ||
          _godotClassMembers.containsKey(name)) {
        return name;
      }
      return null;
    }
    if (callee is GetExpr && callee.name == 'new') {
      final target = callee.object;
      if (target is IdentifierExpr) return target.name;
    }
    return null;
  }

  /// Strips generic parameters from a type annotation: `Array[Node]` -> `Array`.
  static String _normalizeTypeName(String typeName) {
    final bracket = typeName.indexOf('[');
    final base = bracket == -1 ? typeName : typeName.substring(0, bracket);
    return base.trim();
  }

  /// Detects whether [offset] sits at the pattern position of a `match` branch.
  static bool _isInsideMatchPattern(String sourceCode, int offset) {
    final clamped = offset.clamp(0, sourceCode.length);
    final lineStart = sourceCode.lastIndexOf('\n', clamped - 1) + 1;
    final currentLine = sourceCode.substring(lineStart, clamped);
    final currentIndent = _indentWidth(currentLine);

    final lines = sourceCode.substring(0, lineStart).split('\n');
    for (var i = lines.length - 1; i >= 0; i--) {
      final raw = lines[i];
      if (raw.trim().isEmpty) continue;
      final indent = _indentWidth(raw);
      if (indent >= currentIndent) continue;
      if (RegExp(r'^match\b.*:\s*$').hasMatch(raw.trimLeft())) {
        for (var j = i + 1; j < lines.length; j++) {
          final branch = lines[j];
          if (branch.trim().isEmpty) continue;
          return currentIndent == _indentWidth(branch);
        }
        // No branch line precedes the cursor: the cursor is the first branch.
        return true;
      }
      return false;
    }
    return false;
  }

  /// Leading whitespace width of [line], counting a tab as four columns.
  static int _indentWidth(String line) {
    var width = 0;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == ' ') {
        width++;
      } else if (char == '\t') {
        width += 4;
      } else {
        break;
      }
    }
    return width;
  }

  /// Name of the function being *declared* when [offset] sits inside its
  /// unclosed parameter list (`func _process(|`), otherwise `null`.
  String? _enclosingFuncDeclarationName(String sourceCode, int offset) {
    final openParen = _findOpenParenIndex(sourceCode, offset);
    if (openParen == -1) return null;
    final before = sourceCode.substring(0, openParen).trimRight();
    final match = RegExp(
      r'\bfunc\s+([A-Za-z_][A-Za-z0-9_]*)$',
    ).firstMatch(before);
    return match?.group(1);
  }

  /// Whether the trailing `%` in [line] is a unique-node shorthand prefix
  /// (`%HUD`) rather than the modulo operator (`a % b`).
  static bool _isUniqueNodePrefix(String line) {
    final percent = line.lastIndexOf('%');
    if (percent == -1) return false;
    final after = line.substring(percent + 1);
    if (!RegExp(r'^[A-Za-z0-9_/]*$').hasMatch(after)) return false;
    var i = percent - 1;
    while (i >= 0 && (line[i] == ' ' || line[i] == '\t')) {
      i--;
    }
    if (i < 0) return true;
    final before = line[i];
    if (before == ')' || before == ']' || before == '"' || before == "'") {
      return false;
    }
    return !RegExp(r'[A-Za-z0-9_]').hasMatch(before);
  }

  /// Finds matching open/close bracket pair `()`, `[]`, `{}` around [offset].
  (int, int)? findMatchingBracket(String source, int offset) {
    if (offset < 0 || offset >= source.length) return null;
    final char = source[offset];
    const pairs = {'(': ')', '[': ']', '{': '}'};
    const reversePairs = {')': '(', ']': '[', '}': '{'};

    if (pairs.containsKey(char)) {
      final target = pairs[char]!;
      var depth = 1;
      for (var i = offset + 1; i < source.length; i++) {
        if (source[i] == char) depth++;
        if (source[i] == target) {
          depth--;
          if (depth == 0) return (offset, i);
        }
      }
    } else if (reversePairs.containsKey(char)) {
      final target = reversePairs[char]!;
      var depth = 1;
      for (var i = offset - 1; i >= 0; i--) {
        if (source[i] == char) depth++;
        if (source[i] == target) {
          depth--;
          if (depth == 0) return (i, offset);
        }
      }
    }

    return null;
  }

  /// Identifies foldable code regions (multi-line functions, classes, blocks, #region).
  List<FoldingRange> getFoldingRanges(String sourceCode) {
    final ranges = <FoldingRange>[];

    // 1. Scan for custom #region ... #endregion comments
    final lines = sourceCode.split('\n');
    final regionStack = <int>[];
    for (var i = 0; i < lines.length; i++) {
      final lineNum = i + 1;
      final trimmed = lines[i].trim();
      if (trimmed.startsWith('#region')) {
        regionStack.add(lineNum);
      } else if (trimmed.startsWith('#endregion') && regionStack.isNotEmpty) {
        final startLine = regionStack.removeLast();
        ranges.add(
          FoldingRange(startLine: startLine, endLine: lineNum, kind: 'region'),
        );
      }
    }

    // 2. Scan AST for multi-line declarations (functions, classes, enums)
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      for (final decl in ast.declarations) {
        if (decl is FuncDecl && decl.location.endLine > decl.location.line) {
          ranges.add(
            FoldingRange(
              startLine: decl.location.line,
              endLine: decl.location.endLine,
              kind: 'function',
            ),
          );
        } else if (decl is ClassDecl &&
            decl.location.endLine > decl.location.line) {
          ranges.add(
            FoldingRange(
              startLine: decl.location.line,
              endLine: decl.location.endLine,
              kind: 'class',
            ),
          );
        } else if (decl is EnumDecl &&
            decl.location.endLine > decl.location.line) {
          ranges.add(
            FoldingRange(
              startLine: decl.location.line,
              endLine: decl.location.endLine,
              kind: 'enum',
            ),
          );
        }
      }
    } catch (_) {
      // Fallback: line indent based folding
    }
    return ranges;
  }

  /// Provides documentation or symbol signature when hovering over [offset].
  HoverInfo? getHoverInfo(String sourceCode, int offset) {
    if (offset < 0 || offset >= sourceCode.length) return null;
    final prefix = _extractIdentifierPrefix(sourceCode, offset);
    final suffix = _extractIdentifierSuffix(sourceCode, offset);
    final word = '$prefix$suffix';
    if (word.isEmpty) return null;

    final start = offset - prefix.length;
    final end = offset + suffix.length;

    // 1. Check in-script declarations from AST and extract ## doc comments
    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      for (final decl in ast.declarations) {
        if (decl is FuncDecl && decl.name == word) {
          final doc = _extractDocComments(sourceCode, decl.location.line);
          final paramsStr = decl.parameters
              .map(
                (p) => p.typeAnnotation != null
                    ? '${p.name}: ${p.typeAnnotation}'
                    : p.name,
              )
              .join(', ');
          final retStr = decl.returnType != null
              ? ' -> ${decl.returnType}'
              : '';
          return HoverInfo(
            startOffset: start,
            endOffset: end,
            signature: 'func $word($paramsStr)$retStr',
            documentation: doc ?? 'Script function: $word',
            type: 'Callable',
          );
        } else if (decl is VarStmt && decl.name == word) {
          final doc = _extractDocComments(sourceCode, decl.location.line);
          final typeStr = decl.typeAnnotation != null
              ? ': ${decl.typeAnnotation}'
              : '';
          final kindStr = decl.isConst ? 'const' : 'var';
          return HoverInfo(
            startOffset: start,
            endOffset: end,
            signature: '$kindStr $word$typeStr',
            documentation:
                doc ?? '${decl.isConst ? 'Constant' : 'Variable'}: $word',
            type: decl.typeAnnotation ?? 'Variant',
          );
        } else if (decl is SignalDecl && decl.name == word) {
          final doc = _extractDocComments(sourceCode, decl.location.line);
          final paramsStr = decl.parameters
              .map(
                (p) => p.typeAnnotation != null
                    ? '${p.name}: ${p.typeAnnotation}'
                    : p.name,
              )
              .join(', ');
          return HoverInfo(
            startOffset: start,
            endOffset: end,
            signature: 'signal $word($paramsStr)',
            documentation: doc ?? 'Signal: $word',
            type: 'Signal',
          );
        } else if (decl is ClassDecl && decl.name == word) {
          final doc = _extractDocComments(sourceCode, decl.location.line);
          return HoverInfo(
            startOffset: start,
            endOffset: end,
            signature: 'class_name $word',
            documentation: doc ?? 'Class: $word',
            type: 'Class',
          );
        }
      }
    } catch (_) {}

    // 2. Check built-in functions
    for (final fn in BuiltinFunctions.getDefinitions()) {
      if (fn.name == word) {
        return HoverInfo(
          startOffset: start,
          endOffset: end,
          signature: '${fn.name}(...)',
          documentation:
              fn.documentation ?? 'Built-in GDScript function: ${fn.name}',
          type: 'Callable',
        );
      }
    }

    // 3. Check global constants
    final constants = GlobalScope.getConstants();
    if (constants.containsKey(word)) {
      final val = constants[word]!;
      return HoverInfo(
        startOffset: start,
        endOffset: end,
        signature: 'const $word = $val',
        documentation: 'Global constant: $word',
        type: val.typeName,
      );
    }

    // 4. Check keywords
    if (Keywords.isKeyword(word)) {
      return HoverInfo(
        startOffset: start,
        endOffset: end,
        signature: 'keyword $word',
        documentation: 'GDScript language keyword',
      );
    }

    return null;
  }

  /// Resolves the declaration of the identifier at [offset], returning its
  /// location so the editor can jump to it (Ctrl+Click / "go to definition").
  ///
  /// Resolves in-script declarations (func, var/const, signal, enum, class and
  /// function parameters). Returns `null` when [offset] is not on a resolvable
  /// in-script symbol.
  ///
  /// Only *usages* (call/reference sites) resolve: hovering the declaration's
  /// own name returns `null`, since there is nowhere to navigate to.
  GoToDefinition? findDefinition(String sourceCode, int offset) {
    if (offset < 0 || offset >= sourceCode.length) return null;

    final prefix = _extractIdentifierPrefix(sourceCode, offset);
    final suffix = _extractIdentifierSuffix(sourceCode, offset);
    final word = '$prefix$suffix';
    if (word.isEmpty) return null;

    // The range of the identifier currently under the pointer.
    final hoverStart = offset - prefix.length;
    final hoverEnd = offset + suffix.length;

    // Member access (`object.member`) resolves against engine classes, which we
    // cannot locate in this file; skip so we never jump to the wrong place.
    var before = offset - prefix.length - 1;
    while (before >= 0 &&
        (sourceCode[before] == ' ' || sourceCode[before] == '\t')) {
      before--;
    }
    if (before >= 0 && sourceCode[before] == '.') return null;

    try {
      final source = Source.memory(sourceCode);
      final reporter = ErrorReporter();
      final tokens = Lexer(source: source, reporter: reporter).scanTokens();
      final ast = Parser(
        source: source,
        tokens: tokens,
        reporter: reporter,
      ).parseScript();

      // Declaration locations point to the start of the construct (e.g. the
      // `func` keyword). Locate the identifier itself from that offset.
      GoToDefinition atDecl(SourceLocation loc, String name) {
        final from = loc.offset.clamp(0, sourceCode.length);
        final idx = sourceCode.indexOf(name, from);
        final offset = (idx == -1 || idx > from + 16) ? from : idx;
        return GoToDefinition(
          offset: offset,
          length: name.length,
          line: loc.line,
        );
      }

      GoToDefinition? visit(Stmt decl) {
        if (decl is FuncDecl) {
          if (decl.name == word) {
            return atDecl(decl.location, decl.name);
          }
          for (final param in decl.parameters) {
            if (param.name == word) {
              return GoToDefinition(
                offset: param.location.offset,
                length: param.name.length,
                line: param.location.line,
              );
            }
          }
        } else if (decl is VarStmt) {
          if (decl.name == word) {
            return atDecl(decl.location, decl.name);
          }
        } else if (decl is SignalDecl) {
          if (decl.name == word) {
            return atDecl(decl.location, decl.name);
          }
        } else if (decl is ClassDecl) {
          if (decl.name == word) {
            return atDecl(decl.location, decl.name);
          }
          for (final member in decl.members) {
            final found = visit(member);
            if (found != null) return found;
          }
        } else if (decl is EnumDecl) {
          if (decl.name == word) {
            return atDecl(decl.location, word);
          }
        }
        return null;
      }

      for (final decl in ast.declarations) {
        final found = visit(decl);
        if (found == null) continue;
        // Hovering the declaration's own name is not a usage: nothing to jump
        // to. Only resolve when the pointer is on a separate reference.
        final overlapsHover =
            found.offset < hoverEnd && found.offset + found.length > hoverStart;
        return overlapsHover ? null : found;
      }
    } catch (_) {}

    return null;
  }

  static String? _extractDocComments(String sourceCode, int declLine) {
    if (declLine <= 1) return null;
    final lines = sourceCode.split('\n');
    final docLines = <String>[];
    var lineIdx = declLine - 2; // line numbers are 1-based

    while (lineIdx >= 0) {
      final trimmed = lines[lineIdx].trim();
      if (trimmed.startsWith('##')) {
        var docText = trimmed.substring(2);
        if (docText.startsWith(' ')) {
          docText = docText.substring(1);
        }
        docLines.insert(0, docText);
        lineIdx--;
      } else {
        break;
      }
    }

    return docLines.isNotEmpty ? docLines.join('\n') : null;
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  static String _extractIdentifierPrefix(String text, int offset) {
    var i = offset - 1;
    while (i >= 0 && _isIdentifierChar(text[i])) {
      i--;
    }
    return text.substring(i + 1, offset);
  }

  static String _extractIdentifierSuffix(String text, int offset) {
    var i = offset;
    while (i < text.length && _isIdentifierChar(text[i])) {
      i++;
    }
    return text.substring(offset, i);
  }

  static bool _isIdentifierChar(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 97 && code <= 122) || // a-z
        (code >= 65 && code <= 90) || // A-Z
        (code >= 48 && code <= 57) || // 0-9
        code == 95; // _
  }

  /// Control-flow keywords rendered with a distinct color.
  static const Set<TokenType> _controlFlowTokenTypes = {
    TokenType.kwIf,
    TokenType.kwElif,
    TokenType.kwElse,
    TokenType.kwFor,
    TokenType.kwWhile,
    TokenType.kwMatch,
    TokenType.kwWhen,
    TokenType.kwBreak,
    TokenType.kwContinue,
    TokenType.kwPass,
    TokenType.kwReturn,
    TokenType.kwAwait,
  };

  /// Callables whose string argument names a signal (`emit_signal("died")`).
  static const Set<String> _signalCallNames = {
    'emit_signal',
    'has_signal',
    'connect',
    'disconnect',
    'is_connected',
    'is_connected_to',
  };

  static HighlightKind _mapTokenTypeToHighlightKind(TokenType type) {
    if (_controlFlowTokenTypes.contains(type)) {
      return HighlightKind.controlFlow;
    }
    if (type.name.startsWith('kw')) {
      return HighlightKind.keyword;
    }
    switch (type) {
      case TokenType.identifier:
        return HighlightKind.identifier;
      case TokenType.annotation:
        return HighlightKind.annotation;
      case TokenType.dollar:
      case TokenType.dollarPercent:
      case TokenType.nodePathLiteral:
        return HighlightKind.nodePath;
      case TokenType.integerLiteral:
      case TokenType.floatLiteral:
        return HighlightKind.number;
      case TokenType.stringLiteral:
      case TokenType.stringNameLiteral:
      case TokenType.multilineString:
        return HighlightKind.string;
      case TokenType.comment:
      case TokenType.docComment:
        return HighlightKind.comment;
      case TokenType.plus:
      case TokenType.minus:
      case TokenType.star:
      case TokenType.slash:
      case TokenType.percent:
      case TokenType.starStar:
      case TokenType.equal:
      case TokenType.colonEqual:
      case TokenType.equalEqual:
      case TokenType.bangEqual:
      case TokenType.less:
      case TokenType.lessEqual:
      case TokenType.greater:
      case TokenType.greaterEqual:
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
      case TokenType.ampersand:
      case TokenType.pipe:
      case TokenType.caret:
      case TokenType.tilde:
      case TokenType.shiftLeft:
      case TokenType.shiftRight:
      case TokenType.arrow:
        return HighlightKind.operator;
      default:
        return HighlightKind.punctuation;
    }
  }
}

class _SignatureDescriptor {
  final String signature;
  final List<ParameterInfo> parameters;
  final String? documentation;
  final String? returnType;
  final bool isVararg;

  const _SignatureDescriptor({
    required this.signature,
    required this.parameters,
    this.documentation,
    this.returnType,
    this.isVararg = false,
  });
}
