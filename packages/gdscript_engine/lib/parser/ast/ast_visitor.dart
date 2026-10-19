import 'declarations.dart';
import 'expressions.dart';
import 'statements.dart';

/// Visitor pattern interface for traversing the GDScript AST.
abstract class AstVisitor<R> {
  // === Expressions ===
  R visitLiteralExpr(LiteralExpr node);
  R visitIdentifierExpr(IdentifierExpr node);
  R visitBinaryExpr(BinaryExpr node);
  R visitUnaryExpr(UnaryExpr node);
  R visitGroupingExpr(GroupingExpr node);
  R visitAssignExpr(AssignExpr node);
  R visitCallExpr(CallExpr node);
  R visitGetExpr(GetExpr node);
  R visitSetExpr(SetExpr node);
  R visitIndexExpr(IndexExpr node);
  R visitArrayExpr(ArrayExpr node);
  R visitDictionaryExpr(DictionaryExpr node);
  R visitTernaryExpr(TernaryExpr node);
  R visitLambdaExpr(LambdaExpr node);
  R visitIsExpr(IsExpr node);
  R visitAsExpr(AsExpr node);
  R visitAwaitExpr(AwaitExpr node);
  R visitPreloadExpr(PreloadExpr node);
  R visitSelfExpr(SelfExpr node);
  R visitSuperExpr(SuperExpr node);
  R visitNodePathShortcut(NodePathShortcut node);
  R visitInExpr(InExpr node);
  R visitErrorExpr(ErrorExpr node);

  // === Statements ===
  R visitExpressionStmt(ExpressionStmt node);
  R visitVarStmt(VarStmt node);
  R visitIfStmt(IfStmt node);
  R visitForStmt(ForStmt node);
  R visitWhileStmt(WhileStmt node);
  R visitMatchStmt(MatchStmt node);
  R visitReturnStmt(ReturnStmt node);
  R visitBreakStmt(BreakStmt node);
  R visitContinueStmt(ContinueStmt node);
  R visitPassStmt(PassStmt node);
  R visitAssertStmt(AssertStmt node);
  R visitBreakpointStmt(BreakpointStmt node);
  R visitBlockStmt(BlockStmt node);
  R visitErrorStmt(ErrorStmt node);

  // === Declarations ===
  R visitScriptDecl(ScriptDecl node);
  R visitClassNameDecl(ClassNameDecl node);
  R visitExtendsDecl(ExtendsDecl node);
  R visitFuncDecl(FuncDecl node);
  R visitClassDecl(ClassDecl node);
  R visitEnumDecl(EnumDecl node);
  R visitSignalDecl(SignalDecl node);
  R visitAnnotationDecl(AnnotationDecl node);
}
