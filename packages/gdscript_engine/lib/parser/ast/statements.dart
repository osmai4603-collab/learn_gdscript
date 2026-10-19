import '../../core/source_location.dart';
import 'ast_node.dart';
import 'ast_visitor.dart';
import 'declarations.dart';

/// Single expression treated as a standalone statement.
class ExpressionStmt extends Stmt {
  final Expr expression;

  const ExpressionStmt(this.expression, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitExpressionStmt(this);
}

/// Variable or constant declaration statement: `var x: int = 10`, `const SPEED = 5`.
///
/// Implements [Decl] so it can be declared both at class/script level and inside functions.
class VarStmt extends Decl {
  final String name;
  final String? typeAnnotation;
  final Expr? initializer;
  final bool isConst;
  final bool isStatic;
  final bool isInferred;
  final List<AnnotationDecl> annotations;

  const VarStmt({
    required this.name,
    required SourceLocation location,
    this.typeAnnotation,
    this.initializer,
    this.isConst = false,
    this.isStatic = false,
    this.isInferred = false,
    this.annotations = const [],
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitVarStmt(this);
}

/// Elif branch helper holding condition and body.
class ElifBranch {
  final Expr condition;
  final Stmt body;

  const ElifBranch(this.condition, this.body);
}

/// Conditional branch statement: `if ... elif ... else ...`.
class IfStmt extends Stmt {
  final Expr condition;
  final Stmt thenBranch;
  final List<ElifBranch> elifBranches;
  final Stmt? elseBranch;

  const IfStmt({
    required this.condition,
    required this.thenBranch,
    required SourceLocation location,
    this.elifBranches = const [],
    this.elseBranch,
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitIfStmt(this);
}

/// Iteration loop statement: `for item in sequence:`.
class ForStmt extends Stmt {
  final String variable;
  final String? typeAnnotation;
  final Expr iterable;
  final Stmt body;

  const ForStmt({
    required this.variable,
    required this.iterable,
    required this.body,
    required SourceLocation location,
    this.typeAnnotation,
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitForStmt(this);
}

/// While loop statement: `while condition:`.
class WhileStmt extends Stmt {
  final Expr condition;
  final Stmt body;

  const WhileStmt({
    required this.condition,
    required this.body,
    required SourceLocation location,
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitWhileStmt(this);
}

/// Branch arm in a pattern matching statement: `pattern when guard: body`.
class MatchBranch {
  final List<Expr> patterns;
  final Expr? guard;
  final Stmt body;

  const MatchBranch({required this.patterns, required this.body, this.guard});
}

/// Pattern matching statement: `match subject: ...`.
class MatchStmt extends Stmt {
  final Expr subject;
  final List<MatchBranch> branches;

  const MatchStmt({
    required this.subject,
    required this.branches,
    required SourceLocation location,
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitMatchStmt(this);
}

/// Function return statement: `return value`.
class ReturnStmt extends Stmt {
  final Expr? value;

  const ReturnStmt(this.value, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitReturnStmt(this);
}

/// Loop break statement: `break`.
class BreakStmt extends Stmt {
  const BreakStmt(super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBreakStmt(this);
}

/// Loop continue statement: `continue`.
class ContinueStmt extends Stmt {
  const ContinueStmt(super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitContinueStmt(this);
}

/// Null-op statement: `pass`.
class PassStmt extends Stmt {
  const PassStmt(super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitPassStmt(this);
}

/// Assert condition statement: `assert(condition, message)`.
class AssertStmt extends Stmt {
  final Expr condition;
  final Expr? message;

  const AssertStmt(this.condition, this.message, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAssertStmt(this);
}

/// Debugger breakpoint statement: `breakpoint`.
class BreakpointStmt extends Stmt {
  const BreakpointStmt(super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBreakpointStmt(this);
}

/// Block of statements scoped under indentation: `INDENT ... DEDENT`.
class BlockStmt extends Stmt {
  final List<Stmt> statements;

  const BlockStmt(this.statements, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBlockStmt(this);
}

/// Placeholder error statement for error recovery during parsing.
class ErrorStmt extends Stmt {
  final String message;

  const ErrorStmt(this.message, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitErrorStmt(this);
}
