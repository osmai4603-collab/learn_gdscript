import '../../core/source_location.dart';
import 'ast_node.dart';
import 'ast_visitor.dart';

/// Parameter specification in a function or signal declaration.
class ParameterDecl {
  final String name;
  final String? typeAnnotation;
  final Expr? defaultValue;
  final SourceLocation location;

  const ParameterDecl({
    required this.name,
    required this.location,
    this.typeAnnotation,
    this.defaultValue,
  });
}

/// Script root node representing a complete GDScript file.
class ScriptDecl extends Decl {
  final ClassNameDecl? className;
  final ExtendsDecl? extendsDecl;
  final List<Stmt> declarations;

  const ScriptDecl({
    required this.declarations,
    required SourceLocation location,
    this.className,
    this.extendsDecl,
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitScriptDecl(this);
}

/// Script or class global naming: `class_name Player`.
class ClassNameDecl extends Decl {
  final String name;

  const ClassNameDecl(this.name, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitClassNameDecl(this);
}

/// Class inheritance declaration: `extends Node2D`.
class ExtendsDecl extends Decl {
  final String parentName;

  const ExtendsDecl(this.parentName, super.location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitExtendsDecl(this);
}

/// Function or method declaration: `func calculate(x: int) -> int:`.
class FuncDecl extends Decl {
  final String name;
  final List<ParameterDecl> parameters;
  final String? returnType;
  final Stmt body;
  final bool isStatic;
  final List<AnnotationDecl> annotations;

  const FuncDecl({
    required this.name,
    required this.parameters,
    required this.body,
    required SourceLocation location,
    this.returnType,
    this.isStatic = false,
    this.annotations = const [],
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitFuncDecl(this);
}

/// Inner class declaration: `class InnerState extends RefCounted:`.
class ClassDecl extends Decl {
  final String name;
  final String? extendsName;
  final List<Decl> members;

  const ClassDecl({
    required this.name,
    required this.members,
    required SourceLocation location,
    this.extendsName,
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitClassDecl(this);
}

/// Enumeration declaration: `enum State { IDLE, RUN, JUMP = 10 }`.
class EnumDecl extends Decl {
  final String? name;
  final Map<String, Expr?> entries;

  const EnumDecl({
    required this.entries,
    required SourceLocation location,
    this.name,
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitEnumDecl(this);
}

/// Signal declaration: `signal health_changed(new_health: int)`.
class SignalDecl extends Decl {
  final String name;
  final List<ParameterDecl> parameters;

  const SignalDecl({
    required this.name,
    required SourceLocation location,
    this.parameters = const [],
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitSignalDecl(this);
}

/// Annotation applied to declarations: `@export`, `@onready`, `@tool`, `@rpc(...)`.
class AnnotationDecl extends Decl {
  final String name;
  final List<Expr> arguments;

  const AnnotationDecl({
    required this.name,
    required SourceLocation location,
    this.arguments = const [],
  }) : super(location);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAnnotationDecl(this);
}
