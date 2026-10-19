import 'ast_node.dart';
import 'ast_visitor.dart';
import 'declarations.dart';
import 'expressions.dart';
import 'statements.dart';

/// Formats an AST node hierarchy into a readable structured text tree.
class AstPrinter implements AstVisitor<String> {
  int _indent = 0;

  String _pad() => '  ' * _indent;

  /// Pretty-prints an AST [node].
  String print(AstNode node) => node.accept(this);

  @override
  String visitLiteralExpr(LiteralExpr node) => '${node.value}';

  @override
  String visitIdentifierExpr(IdentifierExpr node) => node.name;

  @override
  String visitBinaryExpr(BinaryExpr node) =>
      '(${node.operator.lexeme} ${node.left.accept(this)} ${node.right.accept(this)})';

  @override
  String visitUnaryExpr(UnaryExpr node) =>
      '(${node.operator.lexeme} ${node.operand.accept(this)})';

  @override
  String visitGroupingExpr(GroupingExpr node) =>
      '(group ${node.expression.accept(this)})';

  @override
  String visitAssignExpr(AssignExpr node) =>
      '(${node.operator.lexeme} ${node.target.accept(this)} ${node.value.accept(this)})';

  @override
  String visitCallExpr(CallExpr node) {
    final args = node.arguments.map((a) => a.accept(this)).join(', ');
    return '${node.callee.accept(this)}($args)';
  }

  @override
  String visitGetExpr(GetExpr node) =>
      '${node.object.accept(this)}.${node.name}';

  @override
  String visitSetExpr(SetExpr node) =>
      '(${node.operator.lexeme} ${node.object.accept(this)}.${node.name} ${node.value.accept(this)})';

  @override
  String visitIndexExpr(IndexExpr node) =>
      '${node.target.accept(this)}[${node.index.accept(this)}]';

  @override
  String visitArrayExpr(ArrayExpr node) {
    final elems = node.elements.map((e) => e.accept(this)).join(', ');
    return '[$elems]';
  }

  @override
  String visitDictionaryExpr(DictionaryExpr node) {
    final entries = node.entries
        .map((e) => '${e.key.accept(this)}: ${e.value.accept(this)}')
        .join(', ');
    return '{$entries}';
  }

  @override
  String visitTernaryExpr(TernaryExpr node) =>
      '(${node.trueExpr.accept(this)} if ${node.condition.accept(this)} else ${node.falseExpr.accept(this)})';

  @override
  String visitLambdaExpr(LambdaExpr node) {
    final params = node.parameters.map((p) => p.name).join(', ');
    return '(lambda ($params) ${node.body.accept(this)})';
  }

  @override
  String visitIsExpr(IsExpr node) =>
      '(${node.expression.accept(this)} is ${node.targetType})';

  @override
  String visitAsExpr(AsExpr node) =>
      '(${node.expression.accept(this)} as ${node.targetType})';

  @override
  String visitAwaitExpr(AwaitExpr node) =>
      '(await ${node.expression.accept(this)})';

  @override
  String visitPreloadExpr(PreloadExpr node) => 'preload("${node.path}")';

  @override
  String visitSelfExpr(SelfExpr node) => 'self';

  @override
  String visitSuperExpr(SuperExpr node) {
    final args = node.arguments.map((a) => a.accept(this)).join(', ');
    final method = node.method != null ? '.${node.method}' : '';
    return 'super$method($args)';
  }

  @override
  String visitNodePathShortcut(NodePathShortcut node) =>
      node.isUnique ? '%${node.path}' : '\$${node.path}';

  @override
  String visitInExpr(InExpr node) {
    final op = node.isNegated ? 'not in' : 'in';
    return '(${node.element.accept(this)} $op ${node.collection.accept(this)})';
  }

  @override
  String visitErrorExpr(ErrorExpr node) => '<ERROR: ${node.message}>';

  @override
  String visitExpressionStmt(ExpressionStmt node) =>
      '${_pad()}${node.expression.accept(this)}';

  @override
  String visitVarStmt(VarStmt node) {
    final kw = node.isConst ? 'const' : 'var';
    final type = node.typeAnnotation != null ? ': ${node.typeAnnotation}' : '';
    final init = node.initializer != null
        ? ' = ${node.initializer!.accept(this)}'
        : '';
    return '${_pad()}$kw ${node.name}$type$init';
  }

  @override
  String visitIfStmt(IfStmt node) {
    final buffer = StringBuffer();
    buffer.writeln('${_pad()}if ${node.condition.accept(this)}:');
    _indent++;
    buffer.writeln(node.thenBranch.accept(this));
    _indent--;

    for (final elif in node.elifBranches) {
      buffer.writeln('${_pad()}elif ${elif.condition.accept(this)}:');
      _indent++;
      buffer.writeln(elif.body.accept(this));
      _indent--;
    }

    if (node.elseBranch != null) {
      buffer.writeln('${_pad()}else:');
      _indent++;
      buffer.writeln(node.elseBranch!.accept(this));
      _indent--;
    }

    return buffer.toString().trimRight();
  }

  @override
  String visitForStmt(ForStmt node) {
    final buffer = StringBuffer();
    buffer.writeln(
      '${_pad()}for ${node.variable} in ${node.iterable.accept(this)}:',
    );
    _indent++;
    buffer.writeln(node.body.accept(this));
    _indent--;
    return buffer.toString().trimRight();
  }

  @override
  String visitWhileStmt(WhileStmt node) {
    final buffer = StringBuffer();
    buffer.writeln('${_pad()}while ${node.condition.accept(this)}:');
    _indent++;
    buffer.writeln(node.body.accept(this));
    _indent--;
    return buffer.toString().trimRight();
  }

  @override
  String visitMatchStmt(MatchStmt node) {
    final buffer = StringBuffer();
    buffer.writeln('${_pad()}match ${node.subject.accept(this)}:');
    _indent++;
    for (final branch in node.branches) {
      final patterns = branch.patterns.map((p) => p.accept(this)).join(', ');
      final guard = branch.guard != null
          ? ' when ${branch.guard!.accept(this)}'
          : '';
      buffer.writeln('${_pad()}$patterns$guard:');
      _indent++;
      buffer.writeln(branch.body.accept(this));
      _indent--;
    }
    _indent--;
    return buffer.toString().trimRight();
  }

  @override
  String visitReturnStmt(ReturnStmt node) {
    final val = node.value != null ? ' ${node.value!.accept(this)}' : '';
    return '${_pad()}return$val';
  }

  @override
  String visitBreakStmt(BreakStmt node) => '${_pad()}break';

  @override
  String visitContinueStmt(ContinueStmt node) => '${_pad()}continue';

  @override
  String visitPassStmt(PassStmt node) => '${_pad()}pass';

  @override
  String visitAssertStmt(AssertStmt node) {
    final msg = node.message != null ? ', ${node.message!.accept(this)}' : '';
    return '${_pad()}assert(${node.condition.accept(this)}$msg)';
  }

  @override
  String visitBreakpointStmt(BreakpointStmt node) => '${_pad()}breakpoint';

  @override
  String visitBlockStmt(BlockStmt node) {
    final lines = node.statements.map((s) => s.accept(this)).join('\n');
    return lines;
  }

  @override
  String visitErrorStmt(ErrorStmt node) => '${_pad()}<ERROR: ${node.message}>';

  @override
  String visitScriptDecl(ScriptDecl node) {
    final buffer = StringBuffer();
    if (node.className != null) {
      buffer.writeln(node.className!.accept(this));
    }
    if (node.extendsDecl != null) {
      buffer.writeln(node.extendsDecl!.accept(this));
    }
    for (final decl in node.declarations) {
      buffer.writeln(decl.accept(this));
    }
    return buffer.toString().trimRight();
  }

  @override
  String visitClassNameDecl(ClassNameDecl node) => 'class_name ${node.name}';

  @override
  String visitExtendsDecl(ExtendsDecl node) => 'extends ${node.parentName}';

  @override
  String visitFuncDecl(FuncDecl node) {
    final buffer = StringBuffer();
    final staticKw = node.isStatic ? 'static ' : '';
    final params = node.parameters
        .map((p) {
          final type = p.typeAnnotation != null ? ': ${p.typeAnnotation}' : '';
          final defVal = p.defaultValue != null
              ? ' = ${p.defaultValue!.accept(this)}'
              : '';
          return '${p.name}$type$defVal';
        })
        .join(', ');
    final ret = node.returnType != null ? ' -> ${node.returnType}' : '';

    buffer.writeln('${_pad()}${staticKw}func ${node.name}($params)$ret:');
    _indent++;
    buffer.writeln(node.body.accept(this));
    _indent--;
    return buffer.toString().trimRight();
  }

  @override
  String visitClassDecl(ClassDecl node) {
    final buffer = StringBuffer();
    final ext = node.extendsName != null ? ' extends ${node.extendsName}' : '';
    buffer.writeln('${_pad()}class ${node.name}$ext:');
    _indent++;
    for (final member in node.members) {
      buffer.writeln(member.accept(this));
    }
    _indent--;
    return buffer.toString().trimRight();
  }

  @override
  String visitEnumDecl(EnumDecl node) {
    final name = node.name != null ? ' ${node.name}' : '';
    final entries = node.entries.entries
        .map((e) {
          final val = e.value != null ? ' = ${e.value!.accept(this)}' : '';
          return '${e.key}$val';
        })
        .join(', ');
    return '${_pad()}enum$name { $entries }';
  }

  @override
  String visitSignalDecl(SignalDecl node) {
    final params = node.parameters.map((p) => p.name).join(', ');
    final pStr = params.isNotEmpty ? '($params)' : '';
    return '${_pad()}signal ${node.name}$pStr';
  }

  @override
  String visitAnnotationDecl(AnnotationDecl node) {
    final args = node.arguments.map((a) => a.accept(this)).join(', ');
    final aStr = args.isNotEmpty ? '($args)' : '';
    return '@${node.name}$aStr';
  }
}
