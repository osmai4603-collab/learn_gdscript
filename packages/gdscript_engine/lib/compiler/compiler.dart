import '../core/diagnostic.dart';
import '../core/error_reporter.dart';
import '../core/source_location.dart';
import '../lexer/token_type.dart';
import '../objects/gd_callable.dart';
import '../objects/gd_class.dart';
import '../objects/gd_enum.dart';
import '../objects/gd_function.dart';
import '../objects/gd_signal.dart';
import '../parser/ast/ast_node.dart';
import '../parser/ast/ast_visitor.dart';
import '../parser/ast/declarations.dart';
import '../parser/ast/expressions.dart';
import '../parser/ast/statements.dart';
import '../runtime/value.dart';
import 'chunk.dart';
import 'opcode.dart';

/// Information about a local variable in the active function frame.
class CompilerLocal {
  final String name;
  final int depth;
  bool isCaptured;

  CompilerLocal({
    required this.name,
    required this.depth,
    this.isCaptured = false,
  });
}

/// Information about an upvalue captured from an enclosing scope.
class CompilerUpvalue {
  final int index;
  final bool isLocal;

  CompilerUpvalue({
    required this.index,
    required this.isLocal,
  });
}

/// Loop compilation state for handling break and continue jumps.
class LoopContext {
  final int loopStart;
  final int scopeDepth;
  final List<int> breakJumps = [];
  final List<int> continueJumps = [];

  LoopContext({
    required this.loopStart,
    required this.scopeDepth,
  });
}

/// Compilation context for a single function or script level.
enum FunctionType {
  script,
  function,
  method,
  lambda,
}

/// Frame holding state for compiling a specific function or script.
class FunctionCompiler {
  final FunctionCompiler? enclosing;
  final String name;
  final FunctionType type;
  final Chunk chunk;
  final List<CompilerLocal> locals = [];
  final List<CompilerUpvalue> upvalues = [];
  final List<LoopContext> loops = [];
  int scopeDepth = 0;
  int maxLocals = 0;

  FunctionCompiler({
    this.enclosing,
    required this.name,
    required this.type,
  }) : chunk = Chunk(name: name);

  bool get isMethod => type == FunctionType.method;
}

/// The result of compiling a GDScript script AST.
class CompilerResult {
  final GDClass scriptClass;
  final Chunk mainChunk;
  final List<Diagnostic> diagnostics;

  CompilerResult({
    required this.scriptClass,
    required this.mainChunk,
    this.diagnostics = const [],
  });

  bool get hasErrors =>
      diagnostics.any((d) => d.severity == DiagnosticSeverity.error);
}

/// Compiles GDScript AST nodes into bytecode [Chunk]s and [GDClass] objects.
class Compiler implements AstVisitor<void> {
  final ErrorReporter errorReporter;

  FunctionCompiler? _currentFn;
  GDClass? _currentClass;

  Compiler({ErrorReporter? errorReporter})
      : errorReporter = errorReporter ?? ErrorReporter();

  FunctionCompiler get _fn => _currentFn!;
  Chunk get _chunk => _currentFn!.chunk;

  // ===========================================================================
  // Public Compilation API
  // ===========================================================================

  /// Compiles a complete script declaration into a [CompilerResult].
  CompilerResult compileScript(ScriptDecl script) {
    final scriptName = script.className?.name ?? 'Script';
    final parentName = script.extendsDecl?.parentName;

    final scriptClass = GDClass(
      name: scriptName,
      superclass: parentName != null ? GDClass(name: parentName) : null,
    );
    _currentClass = scriptClass;

    // Pre-collect top-level declarations so methods can identify member symbols
    for (final decl in script.declarations) {
      if (decl is VarStmt) {
        final defVal = _evalStaticLiteral(decl.initializer);
        if (decl.isConst) {
          scriptClass.constants[decl.name] = defVal;
        } else if (decl.isStatic) {
          scriptClass.staticFields[decl.name] = defVal;
        } else {
          scriptClass.fields[decl.name] = defVal;
        }
      } else if (decl is FuncDecl) {
        scriptClass.methods[decl.name] = GDFunction(name: decl.name);
      } else if (decl is SignalDecl) {
        scriptClass.signals[decl.name] = GDSignal(name: decl.name);
      } else if (decl is EnumDecl && decl.name != null) {
        scriptClass.enums[decl.name!] = GDEnum(
          name: decl.name!,
          entries: decl.entries.map(
            (k, v) => MapEntry(
              k,
              v != null && _evalStaticLiteral(v) is GDInt
                  ? (_evalStaticLiteral(v) as GDInt).value
                  : 0,
            ),
          ),
        );
      }
    }

    // Set up top-level script function compiler
    final scriptFn = FunctionCompiler(
      name: '${scriptName}_main',
      type: FunctionType.script,
    );
    // Reserve slot 0 for 'self'
    scriptFn.locals.add(CompilerLocal(name: 'self', depth: 0));
    _currentFn = scriptFn;

    // Compile declarations
    for (final decl in script.declarations) {
      decl.accept(this);
    }

    // End main script chunk with null return
    _emitOp(OpCode.opNull, script.location.line);
    _emitOp(OpCode.opReturn, script.location.line);

    final mainChunk = _currentFn!.chunk;
    _currentFn = null;
    _currentClass = null;

    return CompilerResult(
      scriptClass: scriptClass,
      mainChunk: mainChunk,
      diagnostics: errorReporter.diagnostics,
    );
  }

  /// Compiles a single expression AST into a standalone [Chunk].
  Chunk compileExpression(Expr expr) {
    final fn = FunctionCompiler(
      name: 'expr_eval',
      type: FunctionType.script,
    );
    fn.locals.add(CompilerLocal(name: 'self', depth: 0));
    _currentFn = fn;

    expr.accept(this);
    _emitOp(OpCode.opReturn, expr.location.line);

    final chunk = _currentFn!.chunk;
    _currentFn = null;
    return chunk;
  }

  /// Compiles a single statement AST into a standalone [Chunk].
  Chunk compileStatement(Stmt stmt) {
    final fn = FunctionCompiler(
      name: 'stmt_eval',
      type: FunctionType.script,
    );
    fn.locals.add(CompilerLocal(name: 'self', depth: 0));
    _currentFn = fn;

    stmt.accept(this);
    _emitOp(OpCode.opNull, stmt.location.line);
    _emitOp(OpCode.opReturn, stmt.location.line);

    final chunk = _currentFn!.chunk;
    _currentFn = null;
    return chunk;
  }

  /// Compiles a function declaration into a [GDFunction].
  GDFunction compileFunction(FuncDecl funcDecl, {bool isMethod = true}) {
    final parentFn = _currentFn;
    final fn = FunctionCompiler(
      enclosing: parentFn,
      name: funcDecl.name,
      type: isMethod ? FunctionType.method : FunctionType.function,
    );
    _currentFn = fn;

    // Slot 0 is reserved for 'self' in methods, or callee function
    _addLocal(isMethod ? 'self' : '');

    // Add function parameters as locals
    final params = <GDParameter>[];
    for (final param in funcDecl.parameters) {
      _addLocal(param.name);
      final defVal = param.defaultValue != null
          ? _evalStaticLiteral(param.defaultValue)
          : null;
      params.add(GDParameter(
        name: param.name,
        typeAnnotation: param.typeAnnotation,
        defaultValue: defVal,
      ));
    }

    // Compile body
    funcDecl.body.accept(this);

    // Ensure function ends with a return instruction
    if (_chunk.code.isEmpty || _chunk.code.last != OpCode.opReturn.index) {
      _emitOp(OpCode.opNull, funcDecl.location.line);
      _emitOp(OpCode.opReturn, funcDecl.location.line);
    }

    final compiledChunk = _fn.chunk;
    final maxLocals = _fn.maxLocals;
    _currentFn = parentFn;

    return GDFunction(
      name: funcDecl.name,
      parameters: params,
      returnType: funcDecl.returnType,
      isStatic: funcDecl.isStatic,
      chunk: compiledChunk,
      localCount: maxLocals,
    );
  }

  /// Compiles an inner class declaration into a [GDClass].
  GDClass compileClass(ClassDecl classDecl) {
    final parentClass = _currentClass;
    GDClass? superclass;
    if (classDecl.extendsName != null) {
      final ext = classDecl.extendsName!;
      var searchClass = parentClass;
      while (searchClass != null) {
        if (searchClass.innerClasses.containsKey(ext)) {
          superclass = searchClass.innerClasses[ext];
          break;
        }
        searchClass = searchClass.superclass;
      }
      superclass ??= GDClass(name: ext);
    }

    final gdClass = GDClass(
      name: classDecl.name,
      superclass: superclass,
    );
    _currentClass = gdClass;

    for (final member in classDecl.members) {
      if (member is VarStmt) {
        final defVal = member.initializer != null
            ? _evalStaticLiteral(member.initializer)
            : GDNull.instance;
        if (member.isConst) {
          gdClass.constants[member.name] = defVal;
        } else if (member.isStatic) {
          gdClass.staticFields[member.name] = defVal;
        } else {
          gdClass.fields[member.name] = defVal;
        }
      } else if (member is FuncDecl) {
        gdClass.methods[member.name] = GDFunction(name: member.name);
      } else if (member is SignalDecl) {
        gdClass.signals[member.name] = GDSignal(name: member.name);
      } else if (member is EnumDecl && member.name != null) {
        gdClass.enums[member.name!] = GDEnum(
          name: member.name!,
          entries: member.entries.map(
            (k, v) => MapEntry(
              k,
              v != null && _evalStaticLiteral(v) is GDInt
                  ? (_evalStaticLiteral(v) as GDInt).value
                  : 0,
            ),
          ),
        );
      }
    }

    for (final member in classDecl.members) {
      member.accept(this);
    }

    _currentClass = parentClass;
    return gdClass;
  }

  // ===========================================================================
  // Expression Visitors
  // ===========================================================================

  @override
  void visitLiteralExpr(LiteralExpr node) {
    final line = node.location.line;
    switch (node.tokenType) {
      case TokenType.kwNull:
        _emitOp(OpCode.opNull, line);
      case TokenType.kwTrue:
        _emitOp(OpCode.opTrue, line);
      case TokenType.kwFalse:
        _emitOp(OpCode.opFalse, line);
      case TokenType.integerLiteral:
        final intVal = (node.value as num?)?.toInt() ?? 0;
        _chunk.writeConstant(GDInt(intVal), line);
      case TokenType.floatLiteral:
        final floatVal = (node.value as num?)?.toDouble() ?? 0.0;
        _chunk.writeConstant(GDFloat(floatVal), line);
      case TokenType.stringLiteral:
      case TokenType.multilineString:
      case TokenType.stringNameLiteral:
      case TokenType.nodePathLiteral:
        final strVal = node.value?.toString() ?? '';
        _chunk.writeConstant(GDString(strVal), line);
      default:
        if (node.value == null) {
          _emitOp(OpCode.opNull, line);
        } else if (node.value is bool) {
          _emitOp(
            node.value == true ? OpCode.opTrue : OpCode.opFalse,
            line,
          );
        } else if (node.value is int) {
          _chunk.writeConstant(GDInt(node.value as int), line);
        } else if (node.value is double) {
          _chunk.writeConstant(GDFloat(node.value as double), line);
        } else {
          _chunk.writeConstant(GDString(node.value.toString()), line);
        }
    }
  }

  @override
  void visitIdentifierExpr(IdentifierExpr node) {
    final line = node.location.line;
    final name = node.name;

    // 1. Local variable
    final local = _resolveLocal(_fn, name);
    if (local != -1) {
      _emitOp(OpCode.opGetLocal, line);
      _emitByte(local, line);
      return;
    }

    // 2. Upvalue from enclosing function
    final upvalue = _resolveUpvalue(_fn, name);
    if (upvalue != -1) {
      _emitOp(OpCode.opGetUpvalue, line);
      _emitByte(upvalue, line);
      return;
    }

    // 3. Class property on self
    if (_fn.isMethod && _currentClass != null && _isClassProperty(name)) {
      _emitOp(OpCode.opGetLocal, line);
      _emitByte(0, line); // push self
      final propIdx = _addNameConstant(name);
      _emitOp(OpCode.opGetProperty, line);
      _emitShort(propIdx, line);
      return;
    }

    // 4. Global or built-in
    final globalIdx = _addNameConstant(name);
    _emitOp(OpCode.opGetGlobal, line);
    _emitShort(globalIdx, line);
  }

  @override
  void visitBinaryExpr(BinaryExpr node) {
    final line = node.location.line;

    // Short-circuiting logical AND
    if (node.operator.type == TokenType.kwAnd) {
      node.left.accept(this);
      final falseJump = _emitJump(OpCode.opJumpIfFalse, line);
      _emitOp(OpCode.opPop, line);
      node.right.accept(this);
      _patchJump(falseJump);
      return;
    }

    // Short-circuiting logical OR
    if (node.operator.type == TokenType.kwOr) {
      node.left.accept(this);
      final trueJump = _emitJump(OpCode.opJumpIfTrue, line);
      _emitOp(OpCode.opPop, line);
      node.right.accept(this);
      _patchJump(trueJump);
      return;
    }

    // Standard binary operators
    node.left.accept(this);
    node.right.accept(this);

    switch (node.operator.type) {
      case TokenType.plus:
        _emitOp(OpCode.opAdd, line);
      case TokenType.minus:
        _emitOp(OpCode.opSubtract, line);
      case TokenType.star:
        _emitOp(OpCode.opMultiply, line);
      case TokenType.slash:
        _emitOp(OpCode.opDivide, line);
      case TokenType.percent:
        _emitOp(OpCode.opModulo, line);
      case TokenType.starStar:
        _emitOp(OpCode.opPower, line);
      case TokenType.equalEqual:
        _emitOp(OpCode.opEqual, line);
      case TokenType.bangEqual:
        _emitOp(OpCode.opNotEqual, line);
      case TokenType.less:
        _emitOp(OpCode.opLess, line);
      case TokenType.greater:
        _emitOp(OpCode.opGreater, line);
      case TokenType.lessEqual:
        _emitOp(OpCode.opLessEqual, line);
      case TokenType.greaterEqual:
        _emitOp(OpCode.opGreaterEqual, line);
      case TokenType.ampersand:
        _emitOp(OpCode.opBitwiseAnd, line);
      case TokenType.pipe:
        _emitOp(OpCode.opBitwiseOr, line);
      case TokenType.caret:
        _emitOp(OpCode.opBitwiseXor, line);
      case TokenType.shiftLeft:
        _emitOp(OpCode.opShiftLeft, line);
      case TokenType.shiftRight:
        _emitOp(OpCode.opShiftRight, line);
      case TokenType.kwIn:
        _emitOp(OpCode.opIn, line);
      default:
        _error(node.location, 'Unsupported binary operator: ${node.operator.lexeme}');
    }
  }

  @override
  void visitUnaryExpr(UnaryExpr node) {
    final line = node.location.line;
    node.operand.accept(this);

    switch (node.operator.type) {
      case TokenType.minus:
        _emitOp(OpCode.opNegate, line);
      case TokenType.kwNot:
        _emitOp(OpCode.opNot, line);
      case TokenType.tilde:
        _emitOp(OpCode.opBitwiseNot, line);
      case TokenType.plus:
        // Unary plus is a no-op
        break;
      default:
        _error(node.location, 'Unsupported unary operator: ${node.operator.lexeme}');
    }
  }

  @override
  void visitGroupingExpr(GroupingExpr node) {
    node.expression.accept(this);
  }

  @override
  void visitAssignExpr(AssignExpr node) {
    final line = node.location.line;
    final op = node.operator.type;

    if (node.target is IdentifierExpr) {
      final id = node.target as IdentifierExpr;
      _compileAssignIdentifier(id.name, node.value, op, line);
    } else if (node.target is GetExpr) {
      final getExpr = node.target as GetExpr;
      _compileAssignProperty(getExpr.object, getExpr.name, node.value, op, line);
    } else if (node.target is IndexExpr) {
      final indexExpr = node.target as IndexExpr;
      _compileAssignIndex(indexExpr.target, indexExpr.index, node.value, op, line);
    } else {
      _error(node.location, 'Invalid assignment target.');
    }
  }

  @override
  void visitCallExpr(CallExpr node) {
    final line = node.location.line;

    // Check for built-in print optimization
    if (node.callee is IdentifierExpr &&
        (node.callee as IdentifierExpr).name == 'print') {
      for (final arg in node.arguments) {
        arg.accept(this);
      }
      _emitOp(OpCode.opPrint, line);
      _emitByte(node.arguments.length, line);
      _emitOp(OpCode.opNull, line);
      return;
    }

    // Check for built-in assert optimization
    if (node.callee is IdentifierExpr &&
        (node.callee as IdentifierExpr).name == 'assert') {
      if (node.arguments.isNotEmpty) {
        node.arguments[0].accept(this);
      }
      if (node.arguments.length > 1) {
        node.arguments[1].accept(this);
      } else {
        _emitOp(OpCode.opNull, line);
      }
      _emitOp(OpCode.opAssert, line);
      _emitOp(OpCode.opNull, line);
      return;
    }

    // General function or method call: push callee, push arguments, opCall
    node.callee.accept(this);
    for (final arg in node.arguments) {
      arg.accept(this);
    }
    _emitOp(OpCode.opCall, line);
    _emitByte(node.arguments.length, line);
  }

  @override
  void visitGetExpr(GetExpr node) {
    final line = node.location.line;
    node.object.accept(this);
    final propIdx = _addNameConstant(node.name);
    _emitOp(OpCode.opGetProperty, line);
    _emitShort(propIdx, line);
  }

  @override
  void visitSetExpr(SetExpr node) {
    _compileAssignProperty(
      node.object,
      node.name,
      node.value,
      node.operator.type,
      node.location.line,
    );
  }

  @override
  void visitIndexExpr(IndexExpr node) {
    final line = node.location.line;
    node.target.accept(this);
    node.index.accept(this);
    _emitOp(OpCode.opGetIndex, line);
  }

  @override
  void visitArrayExpr(ArrayExpr node) {
    final line = node.location.line;
    for (final elem in node.elements) {
      elem.accept(this);
    }
    _emitOp(OpCode.opMakeArray, line);
    _emitShort(node.elements.length, line);
  }

  @override
  void visitDictionaryExpr(DictionaryExpr node) {
    final line = node.location.line;
    for (final entry in node.entries) {
      entry.key.accept(this);
      entry.value.accept(this);
    }
    _emitOp(OpCode.opMakeDictionary, line);
    _emitShort(node.entries.length, line);
  }

  @override
  void visitTernaryExpr(TernaryExpr node) {
    final line = node.location.line;

    // In GDScript: trueExpr if condition else falseExpr
    node.condition.accept(this);
    final falseJump = _emitJump(OpCode.opJumpIfFalse, line);
    _emitOp(OpCode.opPop, line); // pop condition when true

    node.trueExpr.accept(this);
    final endJump = _emitJump(OpCode.opJump, line);

    _patchJump(falseJump);
    _emitOp(OpCode.opPop, line); // pop condition when false
    node.falseExpr.accept(this);

    _patchJump(endJump);
  }

  @override
  void visitLambdaExpr(LambdaExpr node) {
    final line = node.location.line;
    final parentFn = _currentFn;
    final lambdaFn = FunctionCompiler(
      enclosing: parentFn,
      name: 'lambda_$line',
      type: FunctionType.lambda,
    );
    _currentFn = lambdaFn;

    // Slot 0 is reserved for lambda function object
    _addLocal('');

    final params = <GDParameter>[];
    for (final param in node.parameters) {
      _addLocal(param.name);
      params.add(GDParameter(
        name: param.name,
        typeAnnotation: param.typeAnnotation,
      ));
    }

    node.body.accept(this);

    if (_chunk.code.isEmpty || _chunk.code.last != OpCode.opReturn.index) {
      _emitOp(OpCode.opNull, line);
      _emitOp(OpCode.opReturn, line);
    }

    final lambdaChunk = _fn.chunk;
    final upvalues = _fn.upvalues;
    final maxLocals = _fn.maxLocals;
    _currentFn = parentFn;

    final gdFunction = GDFunction(
      name: lambdaFn.name,
      parameters: params,
      returnType: node.returnType,
      chunk: lambdaChunk,
      localCount: maxLocals,
    );

    // Add function constant to parent constant pool
    final fnIdx = _chunk.addConstant(
      GDCallableValue(GDUserFunctionCallable(function: gdFunction)),
    );

    _emitOp(OpCode.opClosure, line);
    _emitShort(fnIdx, line);
    _emitByte(upvalues.length, line);
    for (final u in upvalues) {
      _emitByte(u.isLocal ? 1 : 0, line);
      _emitByte(u.index, line);
    }
  }

  @override
  void visitIsExpr(IsExpr node) {
    final line = node.location.line;
    node.expression.accept(this);
    final typeIdx = _addNameConstant(node.targetType);
    _emitOp(OpCode.opIs, line);
    _emitShort(typeIdx, line);
  }

  @override
  void visitAsExpr(AsExpr node) {
    // Dynamic cast passes the value through
    node.expression.accept(this);
  }

  @override
  void visitAwaitExpr(AwaitExpr node) {
    node.expression.accept(this);
  }

  @override
  void visitPreloadExpr(PreloadExpr node) {
    final line = node.location.line;
    _chunk.writeConstant(GDString(node.path), line);
  }

  @override
  void visitSelfExpr(SelfExpr node) {
    final line = node.location.line;
    _emitOp(OpCode.opGetLocal, line);
    _emitByte(0, line);
  }

  @override
  void visitSuperExpr(SuperExpr node) {
    final line = node.location.line;
    _emitOp(OpCode.opGetLocal, line);
    _emitByte(0, line); // push self

    final methodName = node.method ?? '_init';
    final nameIdx = _addNameConstant(methodName);
    _emitOp(OpCode.opGetSuper, line);
    _emitShort(nameIdx, line);

    for (final arg in node.arguments) {
      arg.accept(this);
    }
    _emitOp(OpCode.opCall, line);
    _emitByte(node.arguments.length, line);
  }

  @override
  void visitNodePathShortcut(NodePathShortcut node) {
    final line = node.location.line;
    _chunk.writeConstant(GDString(node.path), line);
  }

  @override
  void visitInExpr(InExpr node) {
    final line = node.location.line;
    node.element.accept(this);
    node.collection.accept(this);
    _emitOp(OpCode.opIn, line);
    if (node.isNegated) {
      _emitOp(OpCode.opNot, line);
    }
  }

  @override
  void visitErrorExpr(ErrorExpr node) {
    _emitOp(OpCode.opNull, node.location.line);
  }

  // ===========================================================================
  // Statement Visitors
  // ===========================================================================

  @override
  void visitExpressionStmt(ExpressionStmt node) {
    node.expression.accept(this);
    _emitOp(OpCode.opPop, node.location.line);
  }

  @override
  void visitVarStmt(VarStmt node) {
    final line = node.location.line;

    if (_fn.scopeDepth > 0) {
      // Local variable declaration
      if (node.initializer != null) {
        node.initializer!.accept(this);
      } else {
        _emitOp(OpCode.opNull, line);
      }
      _addLocal(node.name);
    } else {
      // Script or class level variable
      if (node.initializer != null) {
        node.initializer!.accept(this);
      } else {
        _emitOp(OpCode.opNull, line);
      }
      final nameIdx = _addNameConstant(node.name);
      _emitOp(OpCode.opDefineGlobal, line);
      _emitShort(nameIdx, line);
    }
  }

  @override
  void visitIfStmt(IfStmt node) {
    final line = node.location.line;
    final endJumps = <int>[];

    // Main condition
    node.condition.accept(this);
    final falseJump = _emitJump(OpCode.opJumpIfFalse, line);
    _emitOp(OpCode.opPop, line); // pop condition when true

    node.thenBranch.accept(this);
    endJumps.add(_emitJump(OpCode.opJump, line));

    _patchJump(falseJump);
    _emitOp(OpCode.opPop, line); // pop condition when false

    // Elif branches
    for (final elif in node.elifBranches) {
      elif.condition.accept(this);
      final elifFalseJump = _emitJump(OpCode.opJumpIfFalse, line);
      _emitOp(OpCode.opPop, line);

      elif.body.accept(this);
      endJumps.add(_emitJump(OpCode.opJump, line));

      _patchJump(elifFalseJump);
      _emitOp(OpCode.opPop, line);
    }

    // Else branch
    if (node.elseBranch != null) {
      node.elseBranch!.accept(this);
    }

    // Patch all end jumps to skip the rest of if-elif-else
    for (final jump in endJumps) {
      _patchJump(jump);
    }
  }

  @override
  void visitWhileStmt(WhileStmt node) {
    final line = node.location.line;
    final loopStart = _chunk.code.length;

    node.condition.accept(this);
    final exitJump = _emitJump(OpCode.opJumpIfFalse, line);
    _emitOp(OpCode.opPop, line); // pop condition when true

    _enterLoop(loopStart: loopStart);
    node.body.accept(this);

    _patchContinues(loopStart);
    _emitLoop(loopStart, line);

    _patchJump(exitJump);
    _emitOp(OpCode.opPop, line); // pop condition when false

    _patchBreaks();
    _exitLoop();
  }

  @override
  void visitForStmt(ForStmt node) {
    final line = node.location.line;

    // 1. Evaluate iterable collection
    node.iterable.accept(this);
    _emitOp(OpCode.opIterInit, line);
    _addLocal(''); // reserve slot for iterator

    _beginScope();

    // 2. Reserve local slot for loop variable
    _emitOp(OpCode.opNull, line);
    final varSlot = _addLocal(node.variable);

    // 3. Loop iteration start
    final loopStart = _chunk.code.length;
    final exitJump = _emitJump(OpCode.opIterNext, line);

    // Assign next element to loop variable
    _emitOp(OpCode.opSetLocal, line);
    _emitByte(varSlot, line);
    _emitOp(OpCode.opPop, line);

    _enterLoop(loopStart: loopStart);
    node.body.accept(this);

    _patchContinues(loopStart);
    _emitLoop(loopStart, line);

    _patchJump(exitJump);
    _patchBreaks();
    _exitLoop();

    _endScope(line);
    // Pop the iterator from stack
    _emitOp(OpCode.opPop, line);
    _fn.locals.removeLast();
  }

  @override
  void visitMatchStmt(MatchStmt node) {
    final line = node.location.line;
    final endJumps = <int>[];

    node.subject.accept(this);

    for (final branch in node.branches) {
      final bodyJumps = <int>[];

      for (final pattern in branch.patterns) {
        if (pattern is IdentifierExpr && pattern.name == '_') {
          // Wildcard pattern always matches
          _emitOp(OpCode.opTrue, line);
          final matchJump = _emitJump(OpCode.opJumpIfTrue, line);
          bodyJumps.add(matchJump);
          _emitOp(OpCode.opPop, line);
          continue;
        }

        _emitOp(OpCode.opDuplicate, line);
        pattern.accept(this);
        _emitOp(OpCode.opEqual, line);

        final matchJump = _emitJump(OpCode.opJumpIfTrue, line);
        bodyJumps.add(matchJump);
        _emitOp(OpCode.opPop, line); // pop equality boolean
      }

      final skipBranchJump = _emitJump(OpCode.opJump, line);

      // Body target
      for (final bj in bodyJumps) {
        _patchJump(bj);
        _emitOp(OpCode.opPop, line); // pop equality boolean
      }

      branch.body.accept(this);
      endJumps.add(_emitJump(OpCode.opJump, line));

      _patchJump(skipBranchJump);
    }

    // Pop the subject from stack
    _emitOp(OpCode.opPop, line);

    for (final ej in endJumps) {
      _patchJump(ej);
    }
  }

  @override
  void visitReturnStmt(ReturnStmt node) {
    final line = node.location.line;
    if (node.value != null) {
      node.value!.accept(this);
    } else {
      _emitOp(OpCode.opNull, line);
    }
    _emitOp(OpCode.opReturn, line);
  }

  @override
  void visitBreakStmt(BreakStmt node) {
    if (_fn.loops.isEmpty) {
      _error(node.location, 'Cannot use "break" outside of a loop.');
      return;
    }
    final loop = _fn.loops.last;
    _discardLocals(loop.scopeDepth, node.location.line);
    final jump = _emitJump(OpCode.opJump, node.location.line);
    loop.breakJumps.add(jump);
  }

  @override
  void visitContinueStmt(ContinueStmt node) {
    if (_fn.loops.isEmpty) {
      _error(node.location, 'Cannot use "continue" outside of a loop.');
      return;
    }
    final loop = _fn.loops.last;
    _discardLocals(loop.scopeDepth, node.location.line);
    final jump = _emitJump(OpCode.opJump, node.location.line);
    loop.continueJumps.add(jump);
  }

  @override
  void visitPassStmt(PassStmt node) {
    // Null statement; no bytecode required
  }

  @override
  void visitAssertStmt(AssertStmt node) {
    final line = node.location.line;
    node.condition.accept(this);
    if (node.message != null) {
      node.message!.accept(this);
    } else {
      _emitOp(OpCode.opNull, line);
    }
    _emitOp(OpCode.opAssert, line);
  }

  @override
  void visitBreakpointStmt(BreakpointStmt node) {
    _emitOp(OpCode.opBreakpoint, node.location.line);
  }

  @override
  void visitBlockStmt(BlockStmt node) {
    _beginScope();
    for (final stmt in node.statements) {
      stmt.accept(this);
    }
    _endScope(node.location.line);
  }

  @override
  void visitErrorStmt(ErrorStmt node) {
    // Error recovery node; no bytecode required
  }

  // ===========================================================================
  // Declaration Visitors
  // ===========================================================================

  @override
  void visitScriptDecl(ScriptDecl node) {
    for (final decl in node.declarations) {
      decl.accept(this);
    }
  }

  @override
  void visitClassNameDecl(ClassNameDecl node) {
    // Handled in compileScript
  }

  @override
  void visitExtendsDecl(ExtendsDecl node) {
    // Handled in compileScript
  }

  @override
  void visitFuncDecl(FuncDecl node) {
    final gdFunc = compileFunction(node, isMethod: _currentClass != null);
    if (_currentClass != null) {
      _currentClass!.methods[node.name] = gdFunc;
    } else {
      final nameIdx = _addNameConstant(node.name);
      _chunk.writeConstant(
        GDCallableValue(GDUserFunctionCallable(function: gdFunc)),
        node.location.line,
      );
      _emitOp(OpCode.opDefineGlobal, node.location.line);
      _emitShort(nameIdx, node.location.line);
    }
  }

  @override
  void visitClassDecl(ClassDecl node) {
    final innerClass = compileClass(node);
    if (_currentClass != null) {
      _currentClass!.innerClasses[node.name] = innerClass;
    }
  }

  @override
  void visitEnumDecl(EnumDecl node) {
    final values = <String, int>{};
    var currentVal = 0;

    for (final entry in node.entries.entries) {
      if (entry.value != null) {
        final evaluated = _evalStaticLiteral(entry.value);
        if (evaluated is GDInt) {
          currentVal = evaluated.value;
        }
      }
      values[entry.key] = currentVal;
      currentVal++;
    }

    final gdEnum = GDEnum(name: node.name ?? 'Enum', entries: values);
    if (_currentClass != null && node.name != null) {
      _currentClass!.enums[node.name!] = gdEnum;
    }
  }

  @override
  void visitSignalDecl(SignalDecl node) {
    final gdSignal = GDSignal(name: node.name);
    if (_currentClass != null) {
      _currentClass!.signals[node.name] = gdSignal;
    }
  }

  @override
  void visitAnnotationDecl(AnnotationDecl node) {
    // Annotations processed by semantic analyzer
  }

  // ===========================================================================
  // Assignment Compilers
  // ===========================================================================

  void _compileAssignIdentifier(
    String name,
    Expr value,
    TokenType op,
    int line,
  ) {
    final local = _resolveLocal(_fn, name);
    final upvalue = local == -1 ? _resolveUpvalue(_fn, name) : -1;
    final isProp =
        local == -1 && upvalue == -1 && _fn.isMethod && _isClassProperty(name);

    if (op == TokenType.equal || op == TokenType.colonEqual) {
      // Simple assignment
      if (isProp) {
        _emitOp(OpCode.opGetLocal, line);
        _emitByte(0, line); // self
        value.accept(this);
        final propIdx = _addNameConstant(name);
        _emitOp(OpCode.opSetProperty, line);
        _emitShort(propIdx, line);
      } else if (local != -1) {
        value.accept(this);
        _emitOp(OpCode.opSetLocal, line);
        _emitByte(local, line);
      } else if (upvalue != -1) {
        value.accept(this);
        _emitOp(OpCode.opSetUpvalue, line);
        _emitByte(upvalue, line);
      } else {
        value.accept(this);
        final globalIdx = _addNameConstant(name);
        _emitOp(OpCode.opSetGlobal, line);
        _emitShort(globalIdx, line);
      }
    } else {
      // Compound assignment (e.g. +=, -=)
      if (isProp) {
        _emitOp(OpCode.opGetLocal, line);
        _emitByte(0, line); // push self
        _emitOp(OpCode.opDuplicate, line); // duplicate self
        final propIdx = _addNameConstant(name);
        _emitOp(OpCode.opGetProperty, line);
        _emitShort(propIdx, line);
        value.accept(this);
        _emitCompoundOp(op, line);
        _emitOp(OpCode.opSetProperty, line);
        _emitShort(propIdx, line);
      } else if (local != -1) {
        _emitOp(OpCode.opGetLocal, line);
        _emitByte(local, line);
        value.accept(this);
        _emitCompoundOp(op, line);
        _emitOp(OpCode.opSetLocal, line);
        _emitByte(local, line);
      } else if (upvalue != -1) {
        _emitOp(OpCode.opGetUpvalue, line);
        _emitByte(upvalue, line);
        value.accept(this);
        _emitCompoundOp(op, line);
        _emitOp(OpCode.opSetUpvalue, line);
        _emitByte(upvalue, line);
      } else {
        final globalIdx = _addNameConstant(name);
        _emitOp(OpCode.opGetGlobal, line);
        _emitShort(globalIdx, line);
        value.accept(this);
        _emitCompoundOp(op, line);
        _emitOp(OpCode.opSetGlobal, line);
        _emitShort(globalIdx, line);
      }
    }
  }

  void _compileAssignProperty(
    Expr object,
    String name,
    Expr value,
    TokenType op,
    int line,
  ) {
    final propIdx = _addNameConstant(name);

    if (op == TokenType.equal || op == TokenType.colonEqual) {
      object.accept(this);
      value.accept(this);
      _emitOp(OpCode.opSetProperty, line);
      _emitShort(propIdx, line);
    } else {
      object.accept(this);
      _emitOp(OpCode.opDuplicate, line);
      _emitOp(OpCode.opGetProperty, line);
      _emitShort(propIdx, line);
      value.accept(this);
      _emitCompoundOp(op, line);
      _emitOp(OpCode.opSetProperty, line);
      _emitShort(propIdx, line);
    }
  }

  void _compileAssignIndex(
    Expr target,
    Expr index,
    Expr value,
    TokenType op,
    int line,
  ) {
    if (op == TokenType.equal || op == TokenType.colonEqual) {
      target.accept(this);
      index.accept(this);
      value.accept(this);
      _emitOp(OpCode.opSetIndex, line);
    } else {
      // Evaluate target and index to get old value, then compute new value and set
      target.accept(this);
      index.accept(this);
      target.accept(this);
      index.accept(this);
      _emitOp(OpCode.opGetIndex, line);
      value.accept(this);
      _emitCompoundOp(op, line);
      _emitOp(OpCode.opSetIndex, line);
    }
  }

  void _emitCompoundOp(TokenType op, int line) {
    switch (op) {
      case TokenType.plusEqual:
        _emitOp(OpCode.opAdd, line);
      case TokenType.minusEqual:
        _emitOp(OpCode.opSubtract, line);
      case TokenType.starEqual:
        _emitOp(OpCode.opMultiply, line);
      case TokenType.slashEqual:
        _emitOp(OpCode.opDivide, line);
      case TokenType.percentEqual:
        _emitOp(OpCode.opModulo, line);
      case TokenType.starStarEqual:
        _emitOp(OpCode.opPower, line);
      case TokenType.ampersandEqual:
        _emitOp(OpCode.opBitwiseAnd, line);
      case TokenType.pipeEqual:
        _emitOp(OpCode.opBitwiseOr, line);
      case TokenType.caretEqual:
        _emitOp(OpCode.opBitwiseXor, line);
      case TokenType.shiftLeftEqual:
        _emitOp(OpCode.opShiftLeft, line);
      case TokenType.shiftRightEqual:
        _emitOp(OpCode.opShiftRight, line);
      default:
        _error(SourceLocation.at(line), 'Unsupported assignment operator.');
    }
  }

  // ===========================================================================
  // Scope and Variable Management
  // ===========================================================================

  void _beginScope() {
    _fn.scopeDepth++;
  }

  void _endScope(int line) {
    _fn.scopeDepth--;
    while (_fn.locals.isNotEmpty && _fn.locals.last.depth > _fn.scopeDepth) {
      if (_fn.locals.last.isCaptured) {
        _emitOp(OpCode.opCloseUpvalue, line);
      } else {
        _emitOp(OpCode.opPop, line);
      }
      _fn.locals.removeLast();
    }
  }

  void _discardLocals(int targetDepth, int line) {
    for (var i = _fn.locals.length - 1; i >= 0; i--) {
      if (_fn.locals[i].depth > targetDepth) {
        if (_fn.locals[i].isCaptured) {
          _emitOp(OpCode.opCloseUpvalue, line);
        } else {
          _emitOp(OpCode.opPop, line);
        }
      }
    }
  }

  int _addLocal(String name) {
    _fn.locals.add(CompilerLocal(
      name: name,
      depth: _fn.scopeDepth,
    ));
    if (_fn.locals.length > _fn.maxLocals) {
      _fn.maxLocals = _fn.locals.length;
    }
    return _fn.locals.length - 1;
  }

  int _resolveLocal(FunctionCompiler fn, String name) {
    for (var i = fn.locals.length - 1; i >= 0; i--) {
      if (fn.locals[i].name == name) {
        return i;
      }
    }
    return -1;
  }

  int _resolveUpvalue(FunctionCompiler fn, String name) {
    if (fn.enclosing == null) return -1;

    // Look in enclosing function's locals
    final local = _resolveLocal(fn.enclosing!, name);
    if (local != -1) {
      fn.enclosing!.locals[local].isCaptured = true;
      return _addUpvalue(fn, local, isLocal: true);
    }

    // Look recursively in enclosing function's upvalues
    final upvalue = _resolveUpvalue(fn.enclosing!, name);
    if (upvalue != -1) {
      return _addUpvalue(fn, upvalue, isLocal: false);
    }

    return -1;
  }

  int _addUpvalue(FunctionCompiler fn, int index, {required bool isLocal}) {
    for (var i = 0; i < fn.upvalues.length; i++) {
      final u = fn.upvalues[i];
      if (u.index == index && u.isLocal == isLocal) {
        return i;
      }
    }
    fn.upvalues.add(CompilerUpvalue(index: index, isLocal: isLocal));
    return fn.upvalues.length - 1;
  }

  bool _isClassProperty(String name) {
    if (_currentClass == null) return false;
    GDClass? curr = _currentClass;
    while (curr != null) {
      if (curr.fields.containsKey(name) ||
          curr.staticFields.containsKey(name) ||
          curr.methods.containsKey(name) ||
          curr.signals.containsKey(name) ||
          curr.constants.containsKey(name)) {
        return true;
      }
      curr = curr.superclass;
    }
    return false;
  }

  // ===========================================================================
  // Loop Management
  // ===========================================================================

  void _enterLoop({required int loopStart}) {
    _fn.loops.add(LoopContext(
      loopStart: loopStart,
      scopeDepth: _fn.scopeDepth,
    ));
  }

  void _exitLoop() {
    _fn.loops.removeLast();
  }

  void _patchBreaks() {
    final loop = _fn.loops.last;
    for (final jump in loop.breakJumps) {
      _patchJump(jump);
    }
  }

  void _patchContinues(int continueTarget) {
    final loop = _fn.loops.last;
    for (final jump in loop.continueJumps) {
      _patchJump(jump);
    }
  }

  // ===========================================================================
  // Instruction Emitters
  // ===========================================================================

  void _emitOp(OpCode op, int line) {
    _chunk.writeOp(op, line);
  }

  void _emitByte(int byte, int line) {
    _chunk.write(byte, line);
  }

  void _emitShort(int value, int line) {
    _chunk.writeShort(value, line);
  }

  int _emitJump(OpCode op, int line) {
    _emitOp(op, line);
    _emitByte(0xFF, line);
    _emitByte(0xFF, line);
    return _chunk.code.length - 2;
  }

  void _patchJump(int offset) {
    final jump = _chunk.code.length - offset - 2;
    if (jump > 65535) {
      _error(SourceLocation.at(_chunk.lines[offset]), 'Jump offset too large.');
    }
    _chunk.patchShort(offset, jump);
  }

  void _emitLoop(int loopStart, int line) {
    _emitOp(OpCode.opLoop, line);
    final offset = _chunk.code.length - loopStart + 2;
    if (offset > 65535) {
      _error(SourceLocation.at(line), 'Loop body too large.');
    }
    _emitShort(offset, line);
  }

  int _addNameConstant(String name) {
    return _chunk.addConstant(GDString(name));
  }

  // ===========================================================================
  // Static Literal Evaluator
  // ===========================================================================

  GDValue _evalStaticLiteral(Expr? expr) {
    if (expr == null) return GDNull.instance;
    if (expr is LiteralExpr) {
      switch (expr.tokenType) {
        case TokenType.kwNull:
          return GDNull.instance;
        case TokenType.kwTrue:
          return GDBool(true);
        case TokenType.kwFalse:
          return GDBool(false);
        case TokenType.integerLiteral:
          return GDInt((expr.value as num?)?.toInt() ?? 0);
        case TokenType.floatLiteral:
          return GDFloat((expr.value as num?)?.toDouble() ?? 0.0);
        case TokenType.stringLiteral:
        case TokenType.multilineString:
        case TokenType.stringNameLiteral:
        case TokenType.nodePathLiteral:
          return GDString(expr.value?.toString() ?? '');
        default:
          break;
      }
      if (expr.value is int) return GDInt(expr.value as int);
      if (expr.value is double) return GDFloat(expr.value as double);
      if (expr.value is bool) return GDBool(expr.value as bool);
      if (expr.value is String) return GDString(expr.value as String);
    }
    if (expr is ArrayExpr) {
      final elements = expr.elements.map(_evalStaticLiteral).toList();
      return GDArray(elements);
    }
    if (expr is DictionaryExpr) {
      final map = <GDValue, GDValue>{};
      for (final entry in expr.entries) {
        final k = _evalStaticLiteral(entry.key);
        final v = _evalStaticLiteral(entry.value);
        map[k] = v;
      }
      return GDDictionary(map);
    }
    if (expr is UnaryExpr) {
      final val = _evalStaticLiteral(expr.operand);
      if (expr.operator.type == TokenType.minus) {
        return val.negate();
      } else if (expr.operator.type == TokenType.plus) {
        return val;
      } else if (expr.operator.type == TokenType.kwNot) {
        return GDBool(!val.isTruthy);
      }
    }
    if (expr is BinaryExpr) {
      final left = _evalStaticLiteral(expr.left);
      final right = _evalStaticLiteral(expr.right);
      switch (expr.operator.type) {
        case TokenType.plus:
          return left + right;
        case TokenType.minus:
          return left - right;
        case TokenType.star:
          return left * right;
        case TokenType.slash:
          return left / right;
        default:
          break;
      }
    }
    if (expr is GroupingExpr) {
      return _evalStaticLiteral(expr.expression);
    }
    return GDNull.instance;
  }

  void _error(SourceLocation location, String message) {
    errorReporter.report(Diagnostic(
      code: 'GD4001',
      message: message,
      severity: DiagnosticSeverity.error,
      location: location,
    ));
  }
}
