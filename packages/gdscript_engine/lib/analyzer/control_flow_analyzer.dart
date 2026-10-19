import '../core/diagnostic.dart';
import '../core/error_reporter.dart';
import '../parser/ast/ast_module.dart';
import 'type_system.dart';

/// Analyzes statement control flow, loop contexts, and return paths.
///
/// Verifies that:
/// - `break` and `continue` statements are strictly within loops.
/// - Functions with explicit non-void return types return on all code paths.
/// - Dead / unreachable code after unconditional jumps is flagged.
class ControlFlowAnalyzer implements AstVisitor<bool> {
  final ErrorReporter reporter;

  int _loopDepth = 0;
  GDScriptType? _currentFunctionReturnType;

  ControlFlowAnalyzer({required this.reporter});

  /// Runs control flow analysis over the script AST.
  void analyzeScript(ScriptDecl script) {
    for (final decl in script.declarations) {
      decl.accept(this);
    }
  }

  // ===========================================================================
  // Declarations
  // ===========================================================================

  @override
  bool visitScriptDecl(ScriptDecl node) {
    for (final d in node.declarations) {
      d.accept(this);
    }
    return false;
  }

  @override
  bool visitClassNameDecl(ClassNameDecl node) => false;

  @override
  bool visitExtendsDecl(ExtendsDecl node) => false;

  @override
  bool visitFuncDecl(FuncDecl node) {
    final retType = GDScriptType.fromString(node.returnType);
    final prevRet = _currentFunctionReturnType;
    _currentFunctionReturnType = retType;

    final returnsAlways = node.body.accept(this);

    // If function specifies a non-void return type, verify all paths return
    if (retType != VoidType.instance &&
        retType != VariantType.instance &&
        !returnsAlways) {
      reporter.report(
        Diagnostic.error(
          'Function "${node.name}" declares return type "$retType" but does not return a value on all code paths.',
          node.location,
          code: 'GD3101',
          hint: 'Add a "return <value>" statement at the end of the function.',
        ),
      );
    }

    _currentFunctionReturnType = prevRet;
    return false;
  }

  @override
  bool visitClassDecl(ClassDecl node) {
    for (final member in node.members) {
      member.accept(this);
    }
    return false;
  }

  @override
  bool visitEnumDecl(EnumDecl node) => false;

  @override
  bool visitSignalDecl(SignalDecl node) => false;

  @override
  bool visitAnnotationDecl(AnnotationDecl node) => false;

  // ===========================================================================
  // Statements (returns true if execution unconditionally terminates / returns)
  // ===========================================================================

  @override
  bool visitExpressionStmt(ExpressionStmt node) => false;

  @override
  bool visitVarStmt(VarStmt node) => false;

  @override
  bool visitIfStmt(IfStmt node) {
    final thenReturns = node.thenBranch.accept(this);

    var allElifsReturn = true;
    for (final elif in node.elifBranches) {
      if (!elif.body.accept(this)) {
        allElifsReturn = false;
      }
    }

    final elseReturns =
        node.elseBranch != null && node.elseBranch!.accept(this);

    // Only guaranteed to return if there is an else branch and ALL branches return
    return thenReturns && allElifsReturn && elseReturns;
  }

  @override
  bool visitForStmt(ForStmt node) {
    _loopDepth++;
    node.body.accept(this);
    _loopDepth--;
    return false; // loop might execute 0 times
  }

  @override
  bool visitWhileStmt(WhileStmt node) {
    _loopDepth++;
    node.body.accept(this);
    _loopDepth--;
    return false; // while condition could be false initially
  }

  @override
  bool visitMatchStmt(MatchStmt node) {
    var allBranchesReturn = node.branches.isNotEmpty;
    for (final branch in node.branches) {
      if (!branch.body.accept(this)) {
        allBranchesReturn = false;
      }
    }
    return allBranchesReturn;
  }

  @override
  bool visitReturnStmt(ReturnStmt node) => true;

  @override
  bool visitBreakStmt(BreakStmt node) {
    if (_loopDepth == 0) {
      reporter.report(
        Diagnostic.error(
          'Cannot use "break" outside of a loop.',
          node.location,
          code: 'GD3102',
        ),
      );
    }
    return true;
  }

  @override
  bool visitContinueStmt(ContinueStmt node) {
    if (_loopDepth == 0) {
      reporter.report(
        Diagnostic.error(
          'Cannot use "continue" outside of a loop.',
          node.location,
          code: 'GD3103',
        ),
      );
    }
    return true;
  }

  @override
  bool visitPassStmt(PassStmt node) => false;

  @override
  bool visitAssertStmt(AssertStmt node) => false;

  @override
  bool visitBreakpointStmt(BreakpointStmt node) => false;

  @override
  bool visitBlockStmt(BlockStmt node) {
    var hasTerminated = false;

    for (var i = 0; i < node.statements.length; i++) {
      final stmt = node.statements[i];

      if (hasTerminated) {
        reporter.report(
          Diagnostic.warning(
            'Unreachable code detected.',
            stmt.location,
            code: 'GD3104',
          ),
        );
        break;
      }

      final terminates = stmt.accept(this);
      if (terminates) {
        hasTerminated = true;
      }
    }

    return hasTerminated;
  }

  @override
  bool visitErrorStmt(ErrorStmt node) => false;

  // ===========================================================================
  // Expressions
  // ===========================================================================

  @override
  bool visitLiteralExpr(LiteralExpr node) => false;

  @override
  bool visitIdentifierExpr(IdentifierExpr node) => false;

  @override
  bool visitBinaryExpr(BinaryExpr node) => false;

  @override
  bool visitUnaryExpr(UnaryExpr node) => false;

  @override
  bool visitGroupingExpr(GroupingExpr node) => false;

  @override
  bool visitAssignExpr(AssignExpr node) => false;

  @override
  bool visitCallExpr(CallExpr node) => false;

  @override
  bool visitGetExpr(GetExpr node) => false;

  @override
  bool visitSetExpr(SetExpr node) => false;

  @override
  bool visitIndexExpr(IndexExpr node) => false;

  @override
  bool visitArrayExpr(ArrayExpr node) => false;

  @override
  bool visitDictionaryExpr(DictionaryExpr node) => false;

  @override
  bool visitTernaryExpr(TernaryExpr node) => false;

  @override
  bool visitLambdaExpr(LambdaExpr node) {
    node.body.accept(this);
    return false;
  }

  @override
  bool visitIsExpr(IsExpr node) => false;

  @override
  bool visitAsExpr(AsExpr node) => false;

  @override
  bool visitAwaitExpr(AwaitExpr node) => false;

  @override
  bool visitPreloadExpr(PreloadExpr node) => false;

  @override
  bool visitSelfExpr(SelfExpr node) => false;

  @override
  bool visitSuperExpr(SuperExpr node) => false;

  @override
  bool visitNodePathShortcut(NodePathShortcut node) => false;

  @override
  bool visitInExpr(InExpr node) => false;

  @override
  bool visitErrorExpr(ErrorExpr node) => false;
}
