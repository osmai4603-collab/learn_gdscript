import '../../lexer/token.dart';
import '../../lexer/token_type.dart';
import 'ast_node.dart';
import 'ast_visitor.dart';
import 'declarations.dart';

/// Literal expression (integer, float, string, bool, null, StringName, NodePath).
class LiteralExpr extends Expr {
  final Object? value;
  final TokenType tokenType;

  const LiteralExpr(this.value, this.tokenType, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitLiteralExpr(this);
}

/// Variable or function identifier reference.
class IdentifierExpr extends Expr {
  final String name;

  const IdentifierExpr(this.name, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitIdentifierExpr(this);
}

/// Binary operation (e.g. `a + b`, `x == y`, `a and b`).
class BinaryExpr extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;

  const BinaryExpr(this.left, this.operator, this.right, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBinaryExpr(this);
}

/// Unary operation (e.g. `-x`, `not flag`, `~mask`).
class UnaryExpr extends Expr {
  final Token operator;
  final Expr operand;
  final bool isPrefix;

  const UnaryExpr(
    this.operator,
    this.operand,
    super.location, {
    this.isPrefix = true,
  });

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitUnaryExpr(this);
}

/// Grouping expression enclosed in parentheses: `(expr)`.
class GroupingExpr extends Expr {
  final Expr expression;

  const GroupingExpr(this.expression, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitGroupingExpr(this);
}

/// Assignment expression: `target = value`, `target += 10`.
class AssignExpr extends Expr {
  final Expr target;
  final Token operator;
  final Expr value;

  const AssignExpr(this.target, this.operator, this.value, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAssignExpr(this);
}

/// Function or method invocation: `callee(arg1, arg2)`.
class CallExpr extends Expr {
  final Expr callee;
  final List<Expr> arguments;

  const CallExpr(this.callee, this.arguments, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitCallExpr(this);
}

/// Member property access: `object.name`.
class GetExpr extends Expr {
  final Expr object;
  final String name;

  const GetExpr(this.object, this.name, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitGetExpr(this);
}

/// Member property assignment: `object.name = value`.
class SetExpr extends Expr {
  final Expr object;
  final String name;
  final Expr value;
  final Token operator;

  const SetExpr(
    this.object,
    this.name,
    this.value,
    this.operator,
    super.location,
  );

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSetExpr(this);
}

/// Index or subscript access: `target[index]`.
class IndexExpr extends Expr {
  final Expr target;
  final Expr index;

  const IndexExpr(this.target, this.index, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitIndexExpr(this);
}

/// Array literal creation: `[elem1, elem2, ...]`.
class ArrayExpr extends Expr {
  final List<Expr> elements;

  const ArrayExpr(this.elements, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitArrayExpr(this);
}

/// Key-value pair in a dictionary literal.
class DictEntry {
  final Expr key;
  final Expr value;

  const DictEntry(this.key, this.value);
}

/// Dictionary literal creation: `{key: value, ...}`.
class DictionaryExpr extends Expr {
  final List<DictEntry> entries;

  const DictionaryExpr(this.entries, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitDictionaryExpr(this);
}

/// Ternary conditional expression: `trueExpr if condition else falseExpr`.
class TernaryExpr extends Expr {
  final Expr trueExpr;
  final Expr condition;
  final Expr falseExpr;

  const TernaryExpr(
    this.trueExpr,
    this.condition,
    this.falseExpr,
    super.location,
  );

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitTernaryExpr(this);
}

/// Anonymous lambda expression: `func(x): return x * 2`.
class LambdaExpr extends Expr {
  final List<ParameterDecl> parameters;
  final String? returnType;
  final Stmt body;

  const LambdaExpr(this.parameters, this.returnType, this.body, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitLambdaExpr(this);
}

/// Type checking expression: `node is Sprite2D`.
class IsExpr extends Expr {
  final Expr expression;
  final String targetType;

  const IsExpr(this.expression, this.targetType, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitIsExpr(this);
}

/// Type casting expression: `node as Sprite2D`.
class AsExpr extends Expr {
  final Expr expression;
  final String targetType;

  const AsExpr(this.expression, this.targetType, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAsExpr(this);
}

/// Await coroutine expression: `await signal_or_promise`.
class AwaitExpr extends Expr {
  final Expr expression;

  const AwaitExpr(this.expression, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAwaitExpr(this);
}

/// Preload resource expression: `preload("res://...")`.
class PreloadExpr extends Expr {
  final String path;

  const PreloadExpr(this.path, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitPreloadExpr(this);
}

/// Self reference: `self`.
class SelfExpr extends Expr {
  const SelfExpr(super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSelfExpr(this);
}

/// Super parent class reference: `super.method(args)`.
class SuperExpr extends Expr {
  final String? method;
  final List<Expr> arguments;

  const SuperExpr(this.method, this.arguments, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSuperExpr(this);
}

/// Node path shorthand: `$Path/To/Node` or unique node `%UniqueName`.
class NodePathShortcut extends Expr {
  final String path;
  final bool isUnique;

  const NodePathShortcut(this.path, super.location, {this.isUnique = false});

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitNodePathShortcut(this);
}

/// Membership test: `element in collection` or `element not in collection`.
class InExpr extends Expr {
  final Expr element;
  final Expr collection;
  final bool isNegated;

  const InExpr(
    this.element,
    this.collection,
    super.location, {
    this.isNegated = false,
  });

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitInExpr(this);
}

/// Placeholder error node for syntactic recovery.
class ErrorExpr extends Expr {
  final String message;

  const ErrorExpr(this.message, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitErrorExpr(this);
}
