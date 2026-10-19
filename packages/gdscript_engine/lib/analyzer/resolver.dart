import '../core/diagnostic.dart';
import '../core/error_reporter.dart';
import '../parser/ast/ast_module.dart';
import 'scope.dart';
import 'symbol_table.dart';
import 'type_system.dart';

/// Semantic identifier and symbol resolution pass.
///
/// Binds AST identifier nodes to their corresponding [Symbol] declarations,
/// ensures variables are not used before declaration, checks for redeclarations,
/// and verifies correct contextual usage of `self` and `super`.
class Resolver implements AstVisitor<void> {
  final ErrorReporter reporter;
  final SymbolTable symbolTable = SymbolTable();

  /// Map from AST nodes (e.g. [IdentifierExpr]) to their resolved [Symbol].
  final Map<AstNode, Symbol> resolutions = {};

  bool _hasSuperclass = false;
  bool _isInsideStaticFunction = false;

  Resolver({required this.reporter});

  /// Executes two-pass resolution over the given [script].
  void resolveScript(ScriptDecl script) {
    // Top-level class scope
    symbolTable.enterScope(ScopeKind.classScope);

    _hasSuperclass = script.extendsDecl != null;

    // First pass: register all top-level declarations
    for (final decl in script.declarations) {
      _declareTopLevel(decl);
    }

    // Second pass: resolve statement and expression bodies
    for (final decl in script.declarations) {
      decl.accept(this);
    }

    // Warn about unused local variables
    _checkUnusedSymbols();

    // Retain class scope open so subsequent type-checking and runtime lookups succeed.
  }

  void _declareTopLevel(Stmt stmt) {
    if (stmt is VarStmt) {
      final type = GDScriptType.fromString(stmt.typeAnnotation);
      final sym = Symbol(
        name: stmt.name,
        type: type,
        kind: stmt.isConst ? SymbolKind.constant : SymbolKind.variable,
        location: stmt.location,
        isConst: stmt.isConst,
        isStatic: stmt.isStatic,
        isInitialized: stmt.initializer != null,
      );
      final defined = symbolTable.define(sym);
      if (!defined) {
        reporter.report(
          Diagnostic.error(
            'Duplicate member "${stmt.name}" in class.',
            stmt.location,
            code: 'GD3001',
          ),
        );
      } else {
        resolutions[stmt] = sym;
      }
    } else if (stmt is FuncDecl) {
      final paramTypes = stmt.parameters
          .map((p) => GDScriptType.fromString(p.typeAnnotation))
          .toList();
      final retType = GDScriptType.fromString(stmt.returnType);

      final sym = Symbol(
        name: stmt.name,
        type: CallableType(parameterTypes: paramTypes, returnType: retType),
        kind: SymbolKind.function,
        location: stmt.location,
        isStatic: stmt.isStatic,
        isInitialized: true,
      );
      final defined = symbolTable.define(sym);
      if (!defined) {
        reporter.report(
          Diagnostic.error(
            'Duplicate function "${stmt.name}" in class.',
            stmt.location,
            code: 'GD3001',
          ),
        );
      } else {
        resolutions[stmt] = sym;
      }
    } else if (stmt is SignalDecl) {
      final paramTypes = stmt.parameters
          .map((p) => GDScriptType.fromString(p.typeAnnotation))
          .toList();
      final sym = Symbol(
        name: stmt.name,
        type: SignalType(name: stmt.name, parameterTypes: paramTypes),
        kind: SymbolKind.signalSymbol,
        location: stmt.location,
        isInitialized: true,
      );
      if (symbolTable.define(sym)) {
        resolutions[stmt] = sym;
      }
    } else if (stmt is EnumDecl) {
      final sym = Symbol(
        name: stmt.name ?? '<unnamed_enum>',
        type: EnumType(name: stmt.name ?? '<unnamed_enum>'),
        kind: SymbolKind.enumSymbol,
        location: stmt.location,
        isInitialized: true,
      );
      if (symbolTable.define(sym)) {
        resolutions[stmt] = sym;
      }
      // Register individual enum constants in scope
      for (final key in stmt.entries.keys) {
        symbolTable.define(
          Symbol(
            name: key,
            type: PrimitiveType.intType,
            kind: SymbolKind.constant,
            location: stmt.location,
            isConst: true,
            isInitialized: true,
          ),
        );
      }
    } else if (stmt is ClassDecl) {
      final sym = Symbol(
        name: stmt.name,
        type: ClassType(stmt.name),
        kind: SymbolKind.classSymbol,
        location: stmt.location,
        isInitialized: true,
      );
      if (symbolTable.define(sym)) {
        resolutions[stmt] = sym;
      }
    }
  }

  void _checkUnusedSymbols() {
    for (final scope in symbolTable.allScopes) {
      // Only check unused locals in function/block/lambda scopes
      if (scope.kind == ScopeKind.functionScope ||
          scope.kind == ScopeKind.blockScope ||
          scope.kind == ScopeKind.lambdaScope) {
        for (final sym in scope.symbols.values) {
          if (!sym.isUsed &&
              !sym.name.startsWith('_') &&
              sym.kind == SymbolKind.variable) {
            reporter.report(
              Diagnostic.warning(
                'Unused local variable "${sym.name}". Prefix with "_" to ignore.',
                sym.location,
                code: 'GD3004',
              ),
            );
          }
        }
      }
    }
  }

  // ===========================================================================
  // Declarations
  // ===========================================================================

  @override
  void visitScriptDecl(ScriptDecl node) {
    for (final d in node.declarations) {
      d.accept(this);
    }
  }

  @override
  void visitClassNameDecl(ClassNameDecl node) {}

  @override
  void visitExtendsDecl(ExtendsDecl node) {}

  @override
  void visitFuncDecl(FuncDecl node) {
    symbolTable.enterScope(ScopeKind.functionScope);
    final prevStatic = _isInsideStaticFunction;
    _isInsideStaticFunction = node.isStatic;

    // Register parameters
    for (final param in node.parameters) {
      final type = GDScriptType.fromString(param.typeAnnotation);
      final sym = Symbol(
        name: param.name,
        type: type,
        kind: SymbolKind.parameter,
        location: param.location,
        isInitialized: true,
      );
      final defined = symbolTable.define(sym);
      if (!defined) {
        reporter.report(
          Diagnostic.error(
            'Duplicate parameter name "${param.name}".',
            param.location,
            code: 'GD3001',
          ),
        );
      }
      if (param.defaultValue != null) {
        param.defaultValue!.accept(this);
      }
    }

    node.body.accept(this);
    _isInsideStaticFunction = prevStatic;
    symbolTable.exitScope();
  }

  @override
  void visitClassDecl(ClassDecl node) {
    final prevSuper = _hasSuperclass;
    _hasSuperclass = node.extendsName != null;

    symbolTable.enterScope(ScopeKind.classScope);

    // Register members
    for (final member in node.members) {
      _declareTopLevel(member);
    }
    for (final member in node.members) {
      member.accept(this);
    }

    symbolTable.exitScope();
    _hasSuperclass = prevSuper;
  }

  @override
  void visitEnumDecl(EnumDecl node) {
    for (final val in node.entries.values) {
      if (val != null) val.accept(this);
    }
  }

  @override
  void visitSignalDecl(SignalDecl node) {}

  @override
  void visitAnnotationDecl(AnnotationDecl node) {
    for (final arg in node.arguments) {
      arg.accept(this);
    }
  }

  // ===========================================================================
  // Statements
  // ===========================================================================

  @override
  void visitExpressionStmt(ExpressionStmt node) {
    node.expression.accept(this);
  }

  @override
  void visitVarStmt(VarStmt node) {
    // Inside function/block scopes, local variables are defined when encountered
    if (symbolTable.currentScope.kind != ScopeKind.classScope &&
        symbolTable.currentScope.kind != ScopeKind.global) {
      final type = GDScriptType.fromString(node.typeAnnotation);
      final sym = Symbol(
        name: node.name,
        type: type,
        kind: node.isConst ? SymbolKind.constant : SymbolKind.variable,
        location: node.location,
        isConst: node.isConst,
        isInitialized: false,
      );
      final defined = symbolTable.define(sym);
      if (!defined) {
        reporter.report(
          Diagnostic.error(
            'Variable "${node.name}" is already defined in this local scope.',
            node.location,
            code: 'GD3001',
          ),
        );
      } else {
        resolutions[node] = sym;
      }

      if (node.initializer != null) {
        node.initializer!.accept(this);
      }

      sym.isInitialized = true;
    } else {
      if (node.initializer != null) {
        node.initializer!.accept(this);
      }
    }
  }

  @override
  void visitIfStmt(IfStmt node) {
    node.condition.accept(this);

    symbolTable.enterScope(ScopeKind.blockScope);
    node.thenBranch.accept(this);
    symbolTable.exitScope();

    for (final elif in node.elifBranches) {
      elif.condition.accept(this);
      symbolTable.enterScope(ScopeKind.blockScope);
      elif.body.accept(this);
      symbolTable.exitScope();
    }

    if (node.elseBranch != null) {
      symbolTable.enterScope(ScopeKind.blockScope);
      node.elseBranch!.accept(this);
      symbolTable.exitScope();
    }
  }

  @override
  void visitForStmt(ForStmt node) {
    node.iterable.accept(this);

    symbolTable.enterScope(ScopeKind.blockScope);
    final loopVarType = GDScriptType.fromString(node.typeAnnotation);
    symbolTable.define(
      Symbol(
        name: node.variable,
        type: loopVarType,
        kind: SymbolKind.variable,
        location: node.location,
        isInitialized: true,
      ),
    );

    node.body.accept(this);
    symbolTable.exitScope();
  }

  @override
  void visitWhileStmt(WhileStmt node) {
    node.condition.accept(this);

    symbolTable.enterScope(ScopeKind.blockScope);
    node.body.accept(this);
    symbolTable.exitScope();
  }

  @override
  void visitMatchStmt(MatchStmt node) {
    node.subject.accept(this);

    for (final branch in node.branches) {
      symbolTable.enterScope(ScopeKind.blockScope);
      for (final p in branch.patterns) {
        p.accept(this);
      }
      if (branch.guard != null) {
        branch.guard!.accept(this);
      }
      branch.body.accept(this);
      symbolTable.exitScope();
    }
  }

  @override
  void visitReturnStmt(ReturnStmt node) {
    if (!symbolTable.currentScope.isInsideFunction) {
      reporter.report(
        Diagnostic.error(
          'Cannot "return" outside of a function body.',
          node.location,
          code: 'GD3008',
        ),
      );
    }
    if (node.value != null) {
      node.value!.accept(this);
    }
  }

  @override
  void visitBreakStmt(BreakStmt node) {}

  @override
  void visitContinueStmt(ContinueStmt node) {}

  @override
  void visitPassStmt(PassStmt node) {}

  @override
  void visitAssertStmt(AssertStmt node) {
    node.condition.accept(this);
    if (node.message != null) node.message!.accept(this);
  }

  @override
  void visitBreakpointStmt(BreakpointStmt node) {}

  @override
  void visitBlockStmt(BlockStmt node) {
    for (final stmt in node.statements) {
      stmt.accept(this);
    }
  }

  @override
  void visitErrorStmt(ErrorStmt node) {}

  // ===========================================================================
  // Expressions
  // ===========================================================================

  @override
  void visitLiteralExpr(LiteralExpr node) {}

  @override
  void visitIdentifierExpr(IdentifierExpr node) {
    if (node.name == '_') {
      return;
    }

    final sym = symbolTable.resolve(node.name);
    if (sym == null) {
      reporter.report(
        Diagnostic.error(
          'Identifier "${node.name}" not declared in current scope.',
          node.location,
          code: 'GD3003',
        ),
      );
    } else {
      if (!sym.isInitialized &&
          sym.scopeDepth == symbolTable.currentScope.depth) {
        reporter.report(
          Diagnostic.error(
            'Variable "${node.name}" cannot be used within its own initializer.',
            node.location,
            code: 'GD3002',
          ),
        );
      }
      resolutions[node] = sym;
    }
  }

  @override
  void visitBinaryExpr(BinaryExpr node) {
    node.left.accept(this);
    node.right.accept(this);
  }

  @override
  void visitUnaryExpr(UnaryExpr node) {
    node.operand.accept(this);
  }

  @override
  void visitGroupingExpr(GroupingExpr node) {
    node.expression.accept(this);
  }

  @override
  void visitAssignExpr(AssignExpr node) {
    node.target.accept(this);
    node.value.accept(this);

    if (node.target is IdentifierExpr) {
      final sym = resolutions[node.target];
      if (sym != null && sym.isConst) {
        reporter.report(
          Diagnostic.error(
            'Cannot assign to constant "${sym.name}".',
            node.location,
            code: 'GD3005',
          ),
        );
      }
    }
  }

  @override
  void visitCallExpr(CallExpr node) {
    node.callee.accept(this);
    for (final arg in node.arguments) {
      arg.accept(this);
    }
  }

  @override
  void visitGetExpr(GetExpr node) {
    node.object.accept(this);
  }

  @override
  void visitSetExpr(SetExpr node) {
    node.object.accept(this);
    node.value.accept(this);
  }

  @override
  void visitIndexExpr(IndexExpr node) {
    node.target.accept(this);
    node.index.accept(this);
  }

  @override
  void visitArrayExpr(ArrayExpr node) {
    for (final elem in node.elements) {
      elem.accept(this);
    }
  }

  @override
  void visitDictionaryExpr(DictionaryExpr node) {
    for (final entry in node.entries) {
      entry.key.accept(this);
      entry.value.accept(this);
    }
  }

  @override
  void visitTernaryExpr(TernaryExpr node) {
    node.condition.accept(this);
    node.trueExpr.accept(this);
    node.falseExpr.accept(this);
  }

  @override
  void visitLambdaExpr(LambdaExpr node) {
    symbolTable.enterScope(ScopeKind.lambdaScope);
    for (final param in node.parameters) {
      final type = GDScriptType.fromString(param.typeAnnotation);
      symbolTable.define(
        Symbol(
          name: param.name,
          type: type,
          kind: SymbolKind.parameter,
          location: param.location,
          isInitialized: true,
        ),
      );
      if (param.defaultValue != null) {
        param.defaultValue!.accept(this);
      }
    }
    node.body.accept(this);
    symbolTable.exitScope();
  }

  @override
  void visitIsExpr(IsExpr node) {
    node.expression.accept(this);
  }

  @override
  void visitAsExpr(AsExpr node) {
    node.expression.accept(this);
  }

  @override
  void visitAwaitExpr(AwaitExpr node) {
    node.expression.accept(this);
  }

  @override
  void visitPreloadExpr(PreloadExpr node) {}

  @override
  void visitSelfExpr(SelfExpr node) {
    if (!symbolTable.currentScope.isInsideClass) {
      reporter.report(
        Diagnostic.error(
          'Cannot use "self" outside of a class context.',
          node.location,
          code: 'GD3006',
        ),
      );
    } else if (_isInsideStaticFunction) {
      reporter.report(
        Diagnostic.error(
          'Cannot use "self" inside a static function.',
          node.location,
          code: 'GD3006',
        ),
      );
    }
  }

  @override
  void visitSuperExpr(SuperExpr node) {
    if (!_hasSuperclass) {
      reporter.report(
        Diagnostic.error(
          'Cannot use "super" in a class that does not extend another class.',
          node.location,
          code: 'GD3007',
        ),
      );
    }
    for (final arg in node.arguments) {
      arg.accept(this);
    }
  }

  @override
  void visitNodePathShortcut(NodePathShortcut node) {}

  @override
  void visitInExpr(InExpr node) {
    node.element.accept(this);
    node.collection.accept(this);
  }

  @override
  void visitErrorExpr(ErrorExpr node) {}
}
