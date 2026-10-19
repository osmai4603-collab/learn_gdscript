import '../../core/source_location.dart';
import 'ast_visitor.dart';

/// Base class for all Abstract Syntax Tree (AST) nodes.
abstract class AstNode {
  /// Source code location span corresponding to this node.
  final SourceLocation location;

  /// Const-compatible constructor for base AST node.
  const AstNode(this.location);

  /// Dispatches to the appropriate visit method on [visitor].
  R accept<R>(AstVisitor<R> visitor);

  @override
  String toString() => '$runtimeType at ${location.line}:${location.column}';
}

/// Base class for all expression nodes.
abstract class Expr extends AstNode {
  const Expr(super.location);
}

/// Base class for all statement nodes.
abstract class Stmt extends AstNode {
  const Stmt(super.location);
}

/// Base class for top-level or class-level declaration statements.
abstract class Decl extends Stmt {
  const Decl(super.location);
}
