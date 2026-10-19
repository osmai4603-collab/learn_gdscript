import '../core/error_reporter.dart';
import '../core/source.dart';
import '../lexer/token.dart';
import '../lexer/token_type.dart';
import 'ast/ast_module.dart';
import 'parse_error.dart';
import 'precedence.dart';

/// Recursive Descent and Pratt parser for GDScript 4.
class Parser {
  final Source source;
  final List<Token> tokens;
  final ErrorReporter reporter;
  final ParseErrorHandler _errorHandler;

  int _current = 0;

  Parser({required this.source, required this.tokens, required this.reporter})
    : _errorHandler = ParseErrorHandler(reporter);

  bool get _isAtEnd => _peek().type == TokenType.eof;

  /// Whether a function/block body is empty (no executable statements).
  ///
  /// A body is empty when it has no statements or when every statement failed
  /// to parse (error recovery), so that a real syntax error is reported only
  /// once for the body.
  bool _bodyIsEmpty(Stmt body) {
    if (body is! BlockStmt) return false;
    return body.statements.isEmpty ||
        body.statements.every((s) => s is ErrorStmt);
  }

  /// Whether the cursor sits on a `:` that is not followed by a body block.
  ///
  /// After a `:` the body is either an inline statement on the same line or an
  /// indented block on the following lines. This returns true only when
  /// neither is present (i.e. the next significant token is not an inline
  /// statement or an `indent`), which indicates a missing function body.
  bool _bodyBlockMissing() {
    if (_check(TokenType.newline) || _isAtEnd) {
      var i = _current;
      while (i < tokens.length &&
          (tokens[i].type == TokenType.newline ||
              tokens[i].type == TokenType.comment ||
              tokens[i].type == TokenType.docComment)) {
        i++;
      }
      // No indented block follows the newline.
      return i >= tokens.length || tokens[i].type != TokenType.indent;
    }
    // An inline statement follows on the same line.
    return false;
  }

  /// Number of real tokens emitted on the current logical line before the
  /// cursor (used to distinguish an inline body from a missing one).
  int _tokensSinceNewline() {
    var count = 0;
    for (var i = _current - 1; i >= 0; i--) {
      final type = tokens[i].type;
      if (type == TokenType.newline || type == TokenType.indent) break;
      if (type == TokenType.comment ||
          type == TokenType.docComment ||
          type == TokenType.dedent) {
        continue;
      }
      count++;
    }
    return count;
  }

  // ===========================================================================
  // Top-level Parsing
  // ===========================================================================

  /// Parses the entire token stream into a [ScriptDecl] root AST.
  ScriptDecl parseScript() {
    _skipNewlines();
    final startLoc = _peek().location;

    ClassNameDecl? className;
    ExtendsDecl? extendsDecl;
    final declarations = <Stmt>[];

    // Optional class_name
    if (_match(TokenType.kwClassName)) {
      final nameTok = _consume(
        TokenType.identifier,
        'Expected class identifier after "class_name".',
      );
      className = ClassNameDecl(nameTok.lexeme, nameTok.location);
      _consumeStatementEnd();
    }

    _skipNewlines();

    // Optional extends
    if (_match(TokenType.kwExtends)) {
      final nameTok = _consume(
        TokenType.identifier,
        'Expected parent class name after "extends".',
      );
      extendsDecl = ExtendsDecl(nameTok.lexeme, nameTok.location);
      _consumeStatementEnd();
    }

    // Top-level declarations
    while (!_isAtEnd) {
      _skipNewlines();
      if (_isAtEnd) break;

      try {
        final decl = _declaration();
        if (decl != null) {
          declarations.add(decl);
        }
      } on ParseException {
        _synchronize();
      }
    }

    final endLoc = _previous().location;
    final scriptLoc = declarations.isNotEmpty
        ? startLoc.merge(declarations.last.location)
        : startLoc.merge(endLoc);

    return ScriptDecl(
      className: className,
      extendsDecl: extendsDecl,
      declarations: declarations,
      location: scriptLoc,
    );
  }

  // ===========================================================================
  // Declarations
  // ===========================================================================

  Stmt? _declaration() {
    final annotations = _parseAnnotations();

    if (_match(TokenType.kwStatic)) {
      if (_match(TokenType.kwVar)) {
        return _varDeclaration(isStatic: true, annotations: annotations);
      }
      if (_match(TokenType.kwFunc)) {
        return _funcDeclaration(isStatic: true, annotations: annotations);
      }
      _errorHandler.error(
        _previous(),
        'Expected "var" or "func" after "static".',
      );
    }

    if (_match(TokenType.kwVar)) {
      return _varDeclaration(isStatic: false, annotations: annotations);
    }
    if (_match(TokenType.kwConst)) {
      return _varDeclaration(
        isStatic: false,
        isConst: true,
        annotations: annotations,
      );
    }
    if (_match(TokenType.kwFunc)) {
      return _funcDeclaration(isStatic: false, annotations: annotations);
    }
    if (_match(TokenType.kwClass)) {
      return _classDeclaration();
    }
    if (_match(TokenType.kwEnum)) {
      return _enumDeclaration();
    }
    if (_match(TokenType.kwSignal)) {
      return _signalDeclaration();
    }

    // Top-level statements (e.g. executed at script load time)
    return _statement();
  }

  List<AnnotationDecl> _parseAnnotations() {
    final annotations = <AnnotationDecl>[];
    while (_match(TokenType.annotation)) {
      final annotTok = _previous();
      final annotName =
          annotTok.literal as String? ?? annotTok.lexeme.replaceFirst('@', '');
      var args = <Expr>[];

      if (_match(TokenType.lparen)) {
        if (!_check(TokenType.rparen)) {
          args = _argumentList();
        }
        _consume(TokenType.rparen, 'Expected ")" after annotation arguments.');
      }
      _skipNewlines();
      annotations.add(
        AnnotationDecl(
          name: annotName,
          arguments: args,
          location: annotTok.location,
        ),
      );
    }
    return annotations;
  }

  VarStmt _varDeclaration({
    bool isStatic = false,
    bool isConst = false,
    List<AnnotationDecl> annotations = const [],
  }) {
    final startTok = _previous();
    final nameTok = _consume(
      TokenType.identifier,
      'Expected variable name after "${isConst ? 'const' : 'var'}".',
    );

    String? typeAnnotation;
    var isInferred = false;

    if (_match(TokenType.colonEqual)) {
      // var x := value
      isInferred = true;
    } else if (_match(TokenType.colon)) {
      // var x: int
      typeAnnotation = _parseTypeSignature();
      if (_match(TokenType.equal)) {
        // var x: int = value
      }
    } else if (_match(TokenType.equal)) {
      // var x = value
    }

    Expr? initializer;
    if (isInferred ||
        typeAnnotation != null && _previous().type == TokenType.equal ||
        _previous().type == TokenType.equal) {
      initializer = _expression();
    }

    if (isConst && initializer == null) {
      _errorHandler.error(
        nameTok,
        'Constants must be initialized with a value.',
        hint: 'Add "= <value>" after the constant declaration.',
      );
    }

    if (initializer is! LambdaExpr) {
      _consumeStatementEnd();
    } else {
      if (_match(TokenType.semicolon) || _match(TokenType.newline)) {
        _skipNewlines();
      }
    }

    final loc = initializer != null
        ? startTok.location.merge(initializer.location)
        : startTok.location.merge(nameTok.location);

    return VarStmt(
      name: nameTok.lexeme,
      typeAnnotation: typeAnnotation,
      initializer: initializer,
      isConst: isConst,
      isStatic: isStatic,
      isInferred: isInferred,
      annotations: annotations,
      location: loc,
    );
  }

  FuncDecl _funcDeclaration({
    bool isStatic = false,
    List<AnnotationDecl> annotations = const [],
  }) {
    final startTok = _previous();
    final nameTok = _consume(
      TokenType.identifier,
      'Expected function name after "func".',
    );

    _consume(TokenType.lparen, 'Expected "(" after function name.');
    final parameters = <ParameterDecl>[];

    if (!_check(TokenType.rparen)) {
      do {
        _skipNewlines();
        final paramTok = _consume(
          TokenType.identifier,
          'Expected parameter name.',
        );

        String? paramType;
        if (_match(TokenType.colon)) {
          paramType = _parseTypeSignature();
        }

        Expr? defaultVal;
        if (_match(TokenType.equal)) {
          defaultVal = _expression();
        }

        parameters.add(
          ParameterDecl(
            name: paramTok.lexeme,
            typeAnnotation: paramType,
            defaultValue: defaultVal,
            location: defaultVal != null
                ? paramTok.location.merge(defaultVal.location)
                : paramTok.location,
          ),
        );
      } while (_match(TokenType.comma));
    }

    _consume(TokenType.rparen, 'Expected ")" after function parameters.');

    String? returnType;
    if (_match(TokenType.arrow)) {
      returnType = _parseTypeSignature();
    }

    _consume(TokenType.colon, 'Expected ":" before function body.');

    // A `func` declaration with no body is followed directly by a newline
    // instead of an inline statement. Detect this before `_block()` so that
    // the following `func`/`class` is parsed as its own declaration rather
    // than being swallowed as an (invalid) lambda body.
    final missingBody = _bodyBlockMissing();

    final body = missingBody ? BlockStmt(const [], _peek().location) : _block();

    // A function must declare a body containing at least one statement. An
    // indented body whose only content is comments/blank lines is empty and
    // therefore a syntax error; use `pass` for a no-op body.
    if (missingBody || _bodyIsEmpty(body)) {
      _errorHandler.reportError(
        nameTok.location,
        'Expected an indented block after function definition. '
        'Add a statement or use "pass" for an empty body.',
        hint: 'Function "${nameTok.lexeme}" must have a body.',
        code: 'GD2010',
      );
    }

    final funcLoc = startTok.location.merge(body.location);
    return FuncDecl(
      name: nameTok.lexeme,
      parameters: parameters,
      returnType: returnType,
      body: body,
      isStatic: isStatic,
      annotations: annotations,
      location: funcLoc,
    );
  }

  ClassDecl _classDeclaration() {
    final startTok = _previous();
    final nameTok = _consume(
      TokenType.identifier,
      'Expected class name after "class".',
    );

    String? extendsName;
    if (_match(TokenType.kwExtends)) {
      final extTok = _consume(
        TokenType.identifier,
        'Expected superclass name after "extends".',
      );
      extendsName = extTok.lexeme;
    }

    _consume(TokenType.colon, 'Expected ":" before class body.');

    final members = <Decl>[];
    _skipNewlines();

    if (_match(TokenType.indent)) {
      while (!_check(TokenType.dedent) && !_isAtEnd) {
        _skipNewlines();
        if (_check(TokenType.dedent) || _isAtEnd) break;
        try {
          final member = _declaration();
          if (member is Decl) members.add(member);
        } on ParseException {
          _synchronize();
        }
      }
      _consume(TokenType.dedent, 'Expected dedent after class body.');
    } else {
      // Single-line or empty class
      if (_match(TokenType.kwPass)) {
        _consumeStatementEnd();
      }
    }

    return ClassDecl(
      name: nameTok.lexeme,
      extendsName: extendsName,
      members: members,
      location: members.isNotEmpty
          ? startTok.location.merge(members.last.location)
          : startTok.location.merge(nameTok.location),
    );
  }

  EnumDecl _enumDeclaration() {
    final startTok = _previous();
    String? enumName;
    if (_check(TokenType.identifier)) {
      enumName = _advance().lexeme;
    }

    _consume(TokenType.lbrace, 'Expected "{" after enum declaration.');
    final entries = <String, Expr?>{};

    if (!_check(TokenType.rbrace)) {
      do {
        _skipNewlines();
        if (_check(TokenType.rbrace)) break;

        final itemTok = _consume(
          TokenType.identifier,
          'Expected enum member name.',
        );

        Expr? value;
        if (_match(TokenType.equal)) {
          value = _expression();
        }
        entries[itemTok.lexeme] = value;
      } while (_match(TokenType.comma));
    }

    _skipNewlines();
    final endTok = _consume(
      TokenType.rbrace,
      'Expected "}" after enum members.',
    );
    _consumeStatementEnd();

    return EnumDecl(
      name: enumName,
      entries: entries,
      location: startTok.location.merge(endTok.location),
    );
  }

  SignalDecl _signalDeclaration() {
    final startTok = _previous();
    final nameTok = _consume(
      TokenType.identifier,
      'Expected signal name after "signal".',
    );

    final parameters = <ParameterDecl>[];
    if (_match(TokenType.lparen)) {
      if (!_check(TokenType.rparen)) {
        do {
          _skipNewlines();
          final paramTok = _consume(
            TokenType.identifier,
            'Expected signal parameter name.',
          );
          String? paramType;
          if (_match(TokenType.colon)) {
            paramType = _parseTypeSignature();
          }
          parameters.add(
            ParameterDecl(
              name: paramTok.lexeme,
              typeAnnotation: paramType,
              location: paramTok.location,
            ),
          );
        } while (_match(TokenType.comma));
      }
      _consume(TokenType.rparen, 'Expected ")" after signal parameters.');
    }

    _consumeStatementEnd();

    return SignalDecl(
      name: nameTok.lexeme,
      parameters: parameters,
      location: startTok.location.merge(nameTok.location),
    );
  }

  // ===========================================================================
  // Statements
  // ===========================================================================

  Stmt _statement() {
    if (_match(TokenType.kwIf)) return _ifStatement();
    if (_match(TokenType.kwFor)) return _forStatement();
    if (_match(TokenType.kwWhile)) return _whileStatement();
    if (_match(TokenType.kwMatch)) return _matchStatement();
    if (_match(TokenType.kwReturn)) return _returnStatement();
    if (_match(TokenType.kwBreak)) return _breakStatement();
    if (_match(TokenType.kwContinue)) return _continueStatement();
    if (_match(TokenType.kwPass)) return _passStatement();
    if (_match(TokenType.kwAssert)) return _assertStatement();
    if (_match(TokenType.kwBreakpoint)) return _breakpointStatement();

    return _expressionStatement();
  }

  Stmt _block() {
    final startLoc = _peek().location;
    _skipNewlines();

    if (_match(TokenType.indent)) {
      final statements = <Stmt>[];
      while (!_check(TokenType.dedent) && !_isAtEnd) {
        _skipNewlines();
        if (_check(TokenType.dedent) || _isAtEnd) break;
        try {
          final stmt = _declaration();
          if (stmt != null) statements.add(stmt);
        } on ParseException {
          _synchronize();
        }
      }
      _consume(TokenType.dedent, 'Expected dedent to close block.');
      return BlockStmt(
        statements,
        statements.isNotEmpty
            ? startLoc.merge(statements.last.location)
            : startLoc,
      );
    }

    // Inline single-statement body (e.g. `if condition: return 10`)
    final stmt = _statement();
    return BlockStmt([stmt], stmt.location);
  }

  IfStmt _ifStatement() {
    final startTok = _previous();
    final condition = _expression();
    _consume(TokenType.colon, 'Expected ":" after "if" condition.');
    final thenBranch = _block();

    final elifBranches = <ElifBranch>[];
    while (_match(TokenType.kwElif)) {
      final elifCond = _expression();
      _consume(TokenType.colon, 'Expected ":" after "elif" condition.');
      final elifBody = _block();
      elifBranches.add(ElifBranch(elifCond, elifBody));
    }

    Stmt? elseBranch;
    if (_match(TokenType.kwElse)) {
      _consume(TokenType.colon, 'Expected ":" after "else".');
      elseBranch = _block();
    }

    final endLoc =
        elseBranch?.location ??
        (elifBranches.isNotEmpty
            ? elifBranches.last.body.location
            : thenBranch.location);

    return IfStmt(
      condition: condition,
      thenBranch: thenBranch,
      elifBranches: elifBranches,
      elseBranch: elseBranch,
      location: startTok.location.merge(endLoc),
    );
  }

  ForStmt _forStatement() {
    final startTok = _previous();
    final varTok = _consume(
      TokenType.identifier,
      'Expected loop variable name after "for".',
    );

    String? typeAnn;
    if (_match(TokenType.colon)) {
      typeAnn = _parseTypeSignature();
    }

    _consume(TokenType.kwIn, 'Expected "in" after loop variable.');
    final iterable = _expression();
    _consume(TokenType.colon, 'Expected ":" after "for" statement.');
    final body = _block();

    return ForStmt(
      variable: varTok.lexeme,
      typeAnnotation: typeAnn,
      iterable: iterable,
      body: body,
      location: startTok.location.merge(body.location),
    );
  }

  WhileStmt _whileStatement() {
    final startTok = _previous();
    final condition = _expression();
    _consume(TokenType.colon, 'Expected ":" after "while" condition.');
    final body = _block();

    return WhileStmt(
      condition: condition,
      body: body,
      location: startTok.location.merge(body.location),
    );
  }

  MatchStmt _matchStatement() {
    final startTok = _previous();
    final subject = _expression();
    _consume(TokenType.colon, 'Expected ":" after "match" expression.');
    _skipNewlines();
    _consume(TokenType.indent, 'Expected indented block after "match:".');

    final branches = <MatchBranch>[];

    while (!_check(TokenType.dedent) && !_isAtEnd) {
      _skipNewlines();
      if (_check(TokenType.dedent) || _isAtEnd) break;

      final patterns = <Expr>[];
      do {
        patterns.add(_expression());
      } while (_match(TokenType.comma));

      Expr? guard;
      if (_match(TokenType.kwWhen)) {
        guard = _expression();
      }

      _consume(TokenType.colon, 'Expected ":" after match pattern.');
      final body = _block();

      branches.add(MatchBranch(patterns: patterns, guard: guard, body: body));
    }

    final dedentTok = _consume(
      TokenType.dedent,
      'Expected dedent after match branches.',
    );

    return MatchStmt(
      subject: subject,
      branches: branches,
      location: startTok.location.merge(dedentTok.location),
    );
  }

  ReturnStmt _returnStatement() {
    final startTok = _previous();
    Expr? value;

    if (!_check(TokenType.newline) &&
        !_check(TokenType.semicolon) &&
        !_check(TokenType.dedent) &&
        !_isAtEnd) {
      value = _expression();
    }

    _consumeStatementEnd();

    return ReturnStmt(
      value,
      value != null
          ? startTok.location.merge(value.location)
          : startTok.location,
    );
  }

  BreakStmt _breakStatement() {
    final tok = _previous();
    _consumeStatementEnd();
    return BreakStmt(tok.location);
  }

  ContinueStmt _continueStatement() {
    final tok = _previous();
    _consumeStatementEnd();
    return ContinueStmt(tok.location);
  }

  PassStmt _passStatement() {
    final tok = _previous();
    _consumeStatementEnd();
    return PassStmt(tok.location);
  }

  AssertStmt _assertStatement() {
    final startTok = _previous();
    _consume(TokenType.lparen, 'Expected "(" after "assert".');
    final condition = _expression();
    Expr? message;
    if (_match(TokenType.comma)) {
      message = _expression();
    }
    final endTok = _consume(
      TokenType.rparen,
      'Expected ")" after assert condition.',
    );
    _consumeStatementEnd();

    return AssertStmt(
      condition,
      message,
      startTok.location.merge(endTok.location),
    );
  }

  BreakpointStmt _breakpointStatement() {
    final tok = _previous();
    _consumeStatementEnd();
    return BreakpointStmt(tok.location);
  }

  Stmt _expressionStatement() {
    final expr = _expression();
    if (expr is! LambdaExpr) {
      _consumeStatementEnd();
    }
    return ExpressionStmt(expr, expr.location);
  }

  // ===========================================================================
  // Expressions (Pratt Parsing)
  // ===========================================================================

  Expr _expression() => _parsePrecedence(Precedence.assignment);

  Expr _parsePrecedence(Precedence precedence) {
    if (_isAtEnd) {
      _errorHandler.error(_peek(), 'Unexpected end of input.');
    }

    final token = _advance();
    var left = _prefixParse(token);

    while (!_isAtEnd &&
        precedence.index <= PrecedenceTable.getPrecedence(_peek().type).index) {
      final op = _advance();
      left = _infixParse(left, op);
    }

    return left;
  }

  Expr _prefixParse(Token token) {
    switch (token.type) {
      // Literals
      case TokenType.integerLiteral:
      case TokenType.floatLiteral:
      case TokenType.stringLiteral:
      case TokenType.stringNameLiteral:
      case TokenType.nodePathLiteral:
      case TokenType.multilineString:
      case TokenType.kwTrue:
      case TokenType.kwFalse:
      case TokenType.kwNull:
        return LiteralExpr(token.literal, token.type, token.location);

      // Identifier
      case TokenType.identifier:
        return IdentifierExpr(token.lexeme, token.location);

      // Parentheses / Grouping
      case TokenType.lparen:
        final expr = _expression();
        final closeParen = _consume(
          TokenType.rparen,
          'Expected ")" after expression.',
        );
        return GroupingExpr(expr, token.location.merge(closeParen.location));

      // Arrays: [a, b, c]
      case TokenType.lbracket:
        final elements = <Expr>[];
        if (!_check(TokenType.rbracket)) {
          do {
            _skipNewlines();
            if (_check(TokenType.rbracket)) break;
            elements.add(_expression());
          } while (_match(TokenType.comma));
        }
        _skipNewlines();
        final closeBracket = _consume(
          TokenType.rbracket,
          'Expected "]" after array elements.',
        );
        return ArrayExpr(elements, token.location.merge(closeBracket.location));

      // Dictionaries: {k: v, ...}
      case TokenType.lbrace:
        final entries = <DictEntry>[];
        if (!_check(TokenType.rbrace)) {
          do {
            _skipNewlines();
            if (_check(TokenType.rbrace)) break;
            final key = _expression();
            _consume(TokenType.colon, 'Expected ":" after dictionary key.');
            final value = _expression();
            entries.add(DictEntry(key, value));
          } while (_match(TokenType.comma));
        }
        _skipNewlines();
        final closeBrace = _consume(
          TokenType.rbrace,
          'Expected "}" after dictionary entries.',
        );
        return DictionaryExpr(
          entries,
          token.location.merge(closeBrace.location),
        );

      // Unary operators
      case TokenType.minus:
      case TokenType.plus:
      case TokenType.tilde:
      case TokenType.kwNot:
        final operand = _parsePrecedence(Precedence.unary);
        return UnaryExpr(
          token,
          operand,
          token.location.merge(operand.location),
        );

      // Lambda function: func(x): return x
      case TokenType.kwFunc:
        // A `func` at the start of a line is a declaration, not a lambda
        // expression. This happens when a function declaration is missing its
        // body, e.g.:
        //   func foo():
        //   func bar():
        //       pass
        // Report the missing body and stop parsing the expression so the next
        // `func` can be parsed as a proper declaration.
        if (_tokensSinceNewline() == 0) {
          _errorHandler.reportError(
            token.location,
            'Expected an indented block after function definition. '
            'Add a statement or use "pass" for an empty body.',
            code: 'GD2010',
          );
          return LiteralExpr(null, TokenType.kwNull, token.location);
        }
        _consume(TokenType.lparen, 'Expected "(" after "func" in lambda.');
        final params = <ParameterDecl>[];
        if (!_check(TokenType.rparen)) {
          do {
            final paramTok = _consume(
              TokenType.identifier,
              'Expected parameter name.',
            );
            String? paramType;
            if (_match(TokenType.colon)) {
              paramType = _parseTypeSignature();
            }
            params.add(
              ParameterDecl(
                name: paramTok.lexeme,
                typeAnnotation: paramType,
                location: paramTok.location,
              ),
            );
          } while (_match(TokenType.comma));
        }
        _consume(TokenType.rparen, 'Expected ")" after lambda parameters.');
        String? retType;
        if (_match(TokenType.arrow)) {
          retType = _parseTypeSignature();
        }
        _consume(TokenType.colon, 'Expected ":" before lambda body.');
        final body = _block();
        return LambdaExpr(
          params,
          retType,
          body,
          token.location.merge(body.location),
        );

      // Await
      case TokenType.kwAwait:
        final expr = _parsePrecedence(Precedence.call);
        return AwaitExpr(expr, token.location.merge(expr.location));

      // Preload
      case TokenType.kwPreload:
        _consume(TokenType.lparen, 'Expected "(" after "preload".');
        final pathTok = _consume(
          TokenType.stringLiteral,
          'Expected string literal path for "preload".',
        );
        final closeTok = _consume(
          TokenType.rparen,
          'Expected ")" after preload path.',
        );
        return PreloadExpr(
          pathTok.literal as String,
          token.location.merge(closeTok.location),
        );

      // Self
      case TokenType.kwSelf:
        return SelfExpr(token.location);

      // Super
      case TokenType.kwSuper:
        String? method;
        if (_match(TokenType.dot)) {
          final methodTok = _consume(
            TokenType.identifier,
            'Expected superclass method name.',
          );
          method = methodTok.lexeme;
        }
        _consume(TokenType.lparen, 'Expected "(" after "super".');
        final args = _check(TokenType.rparen) ? <Expr>[] : _argumentList();
        final closeParen = _consume(
          TokenType.rparen,
          'Expected ")" after super arguments.',
        );
        return SuperExpr(
          method,
          args,
          token.location.merge(closeParen.location),
        );

      // Node shortcuts: $Node, %UniqueNode
      case TokenType.dollar:
        final pathTok = _consume(
          TokenType.identifier,
          'Expected node path after "\$".',
        );
        return NodePathShortcut(
          pathTok.lexeme,
          token.location.merge(pathTok.location),
        );

      default:
        _errorHandler.error(
          token,
          'Expected expression, found "${token.lexeme}".',
          code: 'GD2002',
        );
    }
  }

  Expr _infixParse(Expr left, Token operator) {
    final prec = PrecedenceTable.getPrecedence(operator.type);

    switch (operator.type) {
      // Assignment operators
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
        final right = _parsePrecedence(Precedence.assignment);
        if (left is GetExpr) {
          return SetExpr(
            left.object,
            left.name,
            right,
            operator,
            left.location.merge(right.location),
          );
        }
        return AssignExpr(
          left,
          operator,
          right,
          left.location.merge(right.location),
        );

      // Ternary: left if condition else falseExpr
      case TokenType.kwIf:
        final condition = _expression();
        _consume(TokenType.kwElse, 'Expected "else" in ternary expression.');
        final falseExpr = _parsePrecedence(Precedence.ternary);
        return TernaryExpr(
          left,
          condition,
          falseExpr,
          left.location.merge(falseExpr.location),
        );

      // Method / Function Call: callee(args...)
      case TokenType.lparen:
        final args = _check(TokenType.rparen) ? <Expr>[] : _argumentList();
        final closeParen = _consume(
          TokenType.rparen,
          'Expected ")" after arguments.',
        );
        return CallExpr(left, args, left.location.merge(closeParen.location));

      // Property Access: target.name
      case TokenType.dot:
        final nameTok = _consume(
          TokenType.identifier,
          'Expected property name after ".".',
        );
        return GetExpr(
          left,
          nameTok.lexeme,
          left.location.merge(nameTok.location),
        );

      // Subscript / Indexing: target[index]
      case TokenType.lbracket:
        final index = _expression();
        final closeBracket = _consume(
          TokenType.rbracket,
          'Expected "]" after index.',
        );
        return IndexExpr(
          left,
          index,
          left.location.merge(closeBracket.location),
        );

      // Type checks: expr is Type
      case TokenType.kwIs:
        final typeSig = _parseTypeSignature();
        return IsExpr(left, typeSig, left.location);

      // Type casting: expr as Type
      case TokenType.kwAs:
        final typeSig = _parseTypeSignature();
        return AsExpr(left, typeSig, left.location);

      // Membership: item in collection
      case TokenType.kwIn:
        final collection = _parsePrecedence(prec.higher);
        return InExpr(
          left,
          collection,
          left.location.merge(collection.location),
        );

      // Binary operators
      default:
        // Right-associative exponentiation '**'
        final nextPrec = (operator.type == TokenType.starStar)
            ? prec
            : prec.higher;
        final right = _parsePrecedence(nextPrec);
        return BinaryExpr(
          left,
          operator,
          right,
          left.location.merge(right.location),
        );
    }
  }

  List<Expr> _argumentList() {
    final args = <Expr>[];
    do {
      _skipNewlines();
      args.add(_expression());
    } while (_match(TokenType.comma));
    return args;
  }

  String _parseTypeSignature() {
    Token typeTok;
    if (_match(TokenType.kwVoid)) {
      typeTok = _previous();
    } else {
      typeTok = _consume(TokenType.identifier, 'Expected type name.');
    }
    var typeName = typeTok.lexeme;

    // Generic types: Array[int], Dictionary[String, int], Array[Array[int]]
    if (_match(TokenType.lbracket)) {
      final args = <String>[_parseTypeSignature()];
      while (_match(TokenType.comma)) {
        _skipNewlines();
        args.add(_parseTypeSignature());
      }
      _consume(TokenType.rbracket, 'Expected "]" to close generic type.');
      typeName = '$typeName[${args.join(', ')}]';
    }

    return typeName;
  }

  // ===========================================================================
  // Helpers and Synchronization
  // ===========================================================================

  void _skipNewlines() {
    while (_match(TokenType.newline) ||
        _match(TokenType.comment) ||
        _match(TokenType.docComment)) {
      // consume
    }
  }

  void _consumeStatementEnd() {
    while (_match(TokenType.comment) || _match(TokenType.docComment)) {
      // consume inline comment before newline
    }
    if (_match(TokenType.semicolon) ||
        _match(TokenType.newline) ||
        _isAtEnd ||
        _check(TokenType.dedent)) {
      _skipNewlines();
      return;
    }
    // Allow statement at end of block, file, or closing delimiters of enclosing expressions
    if (_check(TokenType.dedent) ||
        _check(TokenType.eof) ||
        _check(TokenType.rparen) ||
        _check(TokenType.comma) ||
        _check(TokenType.rbracket) ||
        _check(TokenType.rbrace)) {
      return;
    }
    _errorHandler.error(_peek(), 'Expected end of statement (newline or ";").');
  }

  Token _advance() {
    if (!_isAtEnd) _current++;
    return _previous();
  }

  bool _check(TokenType type) {
    if (_isAtEnd) return type == TokenType.eof;
    return _peek().type == type;
  }

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    _errorHandler.error(_peek(), message);
  }

  Token _peek() => tokens[_current];

  Token _previous() => tokens[_current - 1];

  /// Synchronizes token stream after a parse error to resume parsing at the next statement boundary.
  void _synchronize() {
    while (!_isAtEnd) {
      if (ParseErrorHandler.isSynchronizationBoundary(_peek())) {
        return;
      }
      _advance();
      if (_previous().type == TokenType.newline ||
          _previous().type == TokenType.semicolon ||
          _previous().type == TokenType.dedent) {
        return;
      }
    }
  }
}
