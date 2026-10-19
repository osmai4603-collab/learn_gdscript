import '../core/diagnostic.dart';
import '../core/error_reporter.dart';
import '../lexer/token_type.dart';
import '../parser/ast/ast_module.dart';
import 'resolver.dart';
import 'type_system.dart';

/// Semantic type checking pass.
///
/// Computes expression types, verifies assignment and operator compatibility,
/// checks function argument types against signatures, and validates return values.
class TypeChecker implements AstVisitor<GDScriptType> {
  final ErrorReporter reporter;
  final Resolver resolver;

  /// Map associating each expression node to its inferred [GDScriptType].
  final Map<Expr, GDScriptType> expressionTypes = {};

  GDScriptType _expectedReturnType = VariantType.instance;

  TypeChecker({required this.reporter, required this.resolver});

  /// Runs type checking over the script AST.
  void checkScript(ScriptDecl script) {
    for (final decl in script.declarations) {
      decl.accept(this);
    }
  }

  // ===========================================================================
  // Declarations
  // ===========================================================================

  @override
  GDScriptType visitScriptDecl(ScriptDecl node) {
    for (final decl in node.declarations) {
      decl.accept(this);
    }
    return VoidType.instance;
  }

  @override
  GDScriptType visitClassNameDecl(ClassNameDecl node) => VoidType.instance;

  @override
  GDScriptType visitExtendsDecl(ExtendsDecl node) => VoidType.instance;

  @override
  GDScriptType visitFuncDecl(FuncDecl node) {
    final declaredRetType = GDScriptType.fromString(node.returnType);
    final prevRet = _expectedReturnType;
    _expectedReturnType = declaredRetType;

    for (final param in node.parameters) {
      if (param.defaultValue != null) {
        final defType = param.defaultValue!.accept(this);
        if (param.typeAnnotation != null) {
          final declaredParamType = GDScriptType.fromString(
            param.typeAnnotation,
          );
          if (!defType.isAssignableTo(declaredParamType)) {
            reporter.report(
              Diagnostic.error(
                'Default value of type "$defType" cannot be assigned to parameter of type "$declaredParamType".',
                param.location,
                code: 'GD3201',
              ),
            );
          }
        }
      }
    }

    node.body.accept(this);
    _expectedReturnType = prevRet;
    return VoidType.instance;
  }

  @override
  GDScriptType visitClassDecl(ClassDecl node) {
    for (final member in node.members) {
      member.accept(this);
    }
    return VoidType.instance;
  }

  @override
  GDScriptType visitEnumDecl(EnumDecl node) {
    for (final val in node.entries.values) {
      if (val != null) {
        val.accept(this);
      }
    }
    return VoidType.instance;
  }

  @override
  GDScriptType visitSignalDecl(SignalDecl node) => VoidType.instance;

  @override
  GDScriptType visitAnnotationDecl(AnnotationDecl node) {
    for (final arg in node.arguments) {
      arg.accept(this);
    }
    return VoidType.instance;
  }

  // ===========================================================================
  // Statements
  // ===========================================================================

  @override
  GDScriptType visitExpressionStmt(ExpressionStmt node) {
    node.expression.accept(this);
    return VoidType.instance;
  }

  @override
  GDScriptType visitVarStmt(VarStmt node) {
    GDScriptType? declaredType;
    if (node.typeAnnotation != null) {
      declaredType = GDScriptType.fromString(node.typeAnnotation);
    }

    if (node.initializer != null) {
      final initType = node.initializer!.accept(this);

      if (node.isInferred && declaredType == null) {
        // Automatic type inference :=
        declaredType = initType is ErrorType ? VariantType.instance : initType;
        final sym =
            resolver.resolutions[node] ??
            resolver.symbolTable.resolve(node.name);
        if (sym != null) {
          sym.type = declaredType;
        }
      } else if (declaredType != null && declaredType != VariantType.instance) {
        if (!initType.isAssignableTo(declaredType)) {
          reporter.report(
            Diagnostic.error(
              'Cannot assign value of type "$initType" to variable "${node.name}" of type "$declaredType".',
              node.location,
              code: 'GD3202',
            ),
          );
        }
      }
    }

    return VoidType.instance;
  }

  @override
  GDScriptType visitIfStmt(IfStmt node) {
    node.condition.accept(this);
    node.thenBranch.accept(this);

    for (final elif in node.elifBranches) {
      elif.condition.accept(this);
      elif.body.accept(this);
    }

    if (node.elseBranch != null) {
      node.elseBranch!.accept(this);
    }

    return VoidType.instance;
  }

  @override
  GDScriptType visitForStmt(ForStmt node) {
    node.iterable.accept(this);
    node.body.accept(this);
    return VoidType.instance;
  }

  @override
  GDScriptType visitWhileStmt(WhileStmt node) {
    node.condition.accept(this);
    node.body.accept(this);
    return VoidType.instance;
  }

  @override
  GDScriptType visitMatchStmt(MatchStmt node) {
    node.subject.accept(this);
    for (final branch in node.branches) {
      for (final p in branch.patterns) {
        p.accept(this);
      }
      if (branch.guard != null) {
        branch.guard!.accept(this);
      }
      branch.body.accept(this);
    }
    return VoidType.instance;
  }

  @override
  GDScriptType visitReturnStmt(ReturnStmt node) {
    final retType = node.value != null
        ? node.value!.accept(this)
        : VoidType.instance;

    if (_expectedReturnType != VariantType.instance) {
      if (!retType.isAssignableTo(_expectedReturnType)) {
        reporter.report(
          Diagnostic.error(
            'Cannot return value of type "$retType" from function expecting "$_expectedReturnType".',
            node.location,
            code: 'GD3203',
          ),
        );
      }
    }

    return retType;
  }

  @override
  GDScriptType visitBreakStmt(BreakStmt node) => VoidType.instance;

  @override
  GDScriptType visitContinueStmt(ContinueStmt node) => VoidType.instance;

  @override
  GDScriptType visitPassStmt(PassStmt node) => VoidType.instance;

  @override
  GDScriptType visitAssertStmt(AssertStmt node) {
    node.condition.accept(this);
    if (node.message != null) node.message!.accept(this);
    return VoidType.instance;
  }

  @override
  GDScriptType visitBreakpointStmt(BreakpointStmt node) => VoidType.instance;

  @override
  GDScriptType visitBlockStmt(BlockStmt node) {
    for (final stmt in node.statements) {
      stmt.accept(this);
    }
    return VoidType.instance;
  }

  @override
  GDScriptType visitErrorStmt(ErrorStmt node) => ErrorType.instance;

  // ===========================================================================
  // Expressions
  // ===========================================================================

  @override
  GDScriptType visitLiteralExpr(LiteralExpr node) {
    GDScriptType type;
    switch (node.tokenType) {
      case TokenType.integerLiteral:
        type = PrimitiveType.intType;
        break;
      case TokenType.floatLiteral:
        type = PrimitiveType.floatType;
        break;
      case TokenType.stringLiteral:
      case TokenType.multilineString:
        type = PrimitiveType.stringType;
        break;
      case TokenType.stringNameLiteral:
        type = PrimitiveType.stringNameType;
        break;
      case TokenType.nodePathLiteral:
        type = PrimitiveType.nodePathType;
        break;
      case TokenType.kwTrue:
      case TokenType.kwFalse:
        type = PrimitiveType.boolType;
        break;
      case TokenType.kwNull:
        type = PrimitiveType.nullType;
        break;
      default:
        type = VariantType.instance;
        break;
    }
    expressionTypes[node] = type;
    return type;
  }

  @override
  GDScriptType visitIdentifierExpr(IdentifierExpr node) {
    final sym = resolver.resolutions[node];
    final type = sym?.type ?? VariantType.instance;
    expressionTypes[node] = type;
    return type;
  }

  @override
  GDScriptType visitBinaryExpr(BinaryExpr node) {
    final left = node.left.accept(this);
    final right = node.right.accept(this);
    final op = node.operator.type;

    GDScriptType resultType = VariantType.instance;

    // Fast-path if either operand has ErrorType
    if (left is ErrorType || right is ErrorType) {
      expressionTypes[node] = ErrorType.instance;
      return ErrorType.instance;
    }

    switch (op) {
      // Comparison
      case TokenType.equalEqual:
      case TokenType.bangEqual:
      case TokenType.less:
      case TokenType.greater:
      case TokenType.lessEqual:
      case TokenType.greaterEqual:
        resultType = PrimitiveType.boolType;
        break;

      // Logical
      case TokenType.kwAnd:
      case TokenType.kwOr:
        resultType = PrimitiveType.boolType;
        break;

      // Arithmetic
      case TokenType.plus:
        if (left == PrimitiveType.stringType ||
            right == PrimitiveType.stringType) {
          if (left == PrimitiveType.stringType &&
              right == PrimitiveType.stringType) {
            resultType = PrimitiveType.stringType;
          } else if (left is VariantType || right is VariantType) {
            resultType = PrimitiveType.stringType;
          } else {
            reporter.report(
              Diagnostic.error(
                'Invalid operands for "+": cannot concatenate "$left" and "$right".',
                node.location,
                code: 'GD3204',
                hint: 'Convert non-string operand using "str(...)".',
              ),
            );
            resultType = ErrorType.instance;
          }
        } else if (left.isNumeric && right.isNumeric) {
          resultType =
              (left == PrimitiveType.floatType ||
                  right == PrimitiveType.floatType)
              ? PrimitiveType.floatType
              : PrimitiveType.intType;
        } else if (left is ArrayType && right is ArrayType) {
          resultType = left;
        }
        break;

      case TokenType.minus:
      case TokenType.star:
      case TokenType.slash:
      case TokenType.percent:
      case TokenType.starStar:
        if (left.isNumeric && right.isNumeric) {
          // In GDScript, `/` is integer division when both operands are ints;
          // it produces a float only when at least one operand is a float.
          resultType =
              (left == PrimitiveType.floatType ||
                  right == PrimitiveType.floatType)
              ? PrimitiveType.floatType
              : PrimitiveType.intType;
        } else if (left is! VariantType && right is! VariantType) {
          reporter.report(
            Diagnostic.error(
              'Operator "${node.operator.lexeme}" cannot be applied to operands of type "$left" and "$right".',
              node.location,
              code: 'GD3204',
            ),
          );
          resultType = ErrorType.instance;
        }
        break;

      // Bitwise
      case TokenType.ampersand:
      case TokenType.pipe:
      case TokenType.caret:
      case TokenType.shiftLeft:
      case TokenType.shiftRight:
        resultType = PrimitiveType.intType;
        break;

      default:
        resultType = VariantType.instance;
        break;
    }

    expressionTypes[node] = resultType;
    return resultType;
  }

  @override
  GDScriptType visitUnaryExpr(UnaryExpr node) {
    final operandType = node.operand.accept(this);
    final op = node.operator.type;

    GDScriptType resultType = operandType;

    if (op == TokenType.kwNot) {
      resultType = PrimitiveType.boolType;
    } else if (op == TokenType.tilde) {
      resultType = PrimitiveType.intType;
    } else if (op == TokenType.minus || op == TokenType.plus) {
      if (!operandType.isNumeric && operandType is! VariantType) {
        reporter.report(
          Diagnostic.error(
            'Unary operator "${node.operator.lexeme}" cannot be applied to type "$operandType".',
            node.location,
            code: 'GD3204',
          ),
        );
        resultType = ErrorType.instance;
      }
    }

    expressionTypes[node] = resultType;
    return resultType;
  }

  @override
  GDScriptType visitGroupingExpr(GroupingExpr node) {
    final type = node.expression.accept(this);
    expressionTypes[node] = type;
    return type;
  }

  @override
  GDScriptType visitAssignExpr(AssignExpr node) {
    final targetType = node.target.accept(this);
    final valueType = node.value.accept(this);

    if (targetType != VariantType.instance && targetType is! ErrorType) {
      if (!valueType.isAssignableTo(targetType)) {
        reporter.report(
          Diagnostic.error(
            'Cannot assign value of type "$valueType" to target of type "$targetType".',
            node.location,
            code: 'GD3202',
          ),
        );
      }
    }

    expressionTypes[node] = targetType;
    return targetType;
  }

  @override
  GDScriptType visitCallExpr(CallExpr node) {
    final calleeType = node.callee.accept(this);

    // Evaluate arguments
    final argTypes = <GDScriptType>[];
    for (final arg in node.arguments) {
      argTypes.add(arg.accept(this));
    }

    GDScriptType resultType = VariantType.instance;

    if (calleeType is CallableType) {
      resultType = calleeType.returnType;

      // Validate argument count if known
      if (calleeType.parameterTypes.isNotEmpty &&
          argTypes.length != calleeType.parameterTypes.length) {
        reporter.report(
          Diagnostic.error(
            'Expected ${calleeType.parameterTypes.length} arguments but got ${argTypes.length}.',
            node.location,
            code: 'GD3205',
          ),
        );
      }
    }

    expressionTypes[node] = resultType;
    return resultType;
  }

  @override
  GDScriptType visitGetExpr(GetExpr node) {
    node.object.accept(this);
    expressionTypes[node] = VariantType.instance;
    return VariantType.instance;
  }

  @override
  GDScriptType visitSetExpr(SetExpr node) {
    node.object.accept(this);
    final valType = node.value.accept(this);
    expressionTypes[node] = valType;
    return valType;
  }

  @override
  GDScriptType visitIndexExpr(IndexExpr node) {
    final targetType = node.target.accept(this);
    node.index.accept(this);

    GDScriptType resultType = VariantType.instance;
    if (targetType is ArrayType) {
      resultType = targetType.elementType;
    } else if (targetType is DictionaryType) {
      resultType = targetType.valueType;
    } else if (targetType == PrimitiveType.stringType) {
      resultType = PrimitiveType.stringType;
    }

    expressionTypes[node] = resultType;
    return resultType;
  }

  @override
  GDScriptType visitArrayExpr(ArrayExpr node) {
    GDScriptType? commonType;

    for (final elem in node.elements) {
      final elemType = elem.accept(this);
      if (commonType == null) {
        commonType = elemType;
      } else if (commonType != elemType) {
        commonType = VariantType.instance;
      }
    }

    final arrayType = ArrayType(commonType ?? VariantType.instance);
    expressionTypes[node] = arrayType;
    return arrayType;
  }

  @override
  GDScriptType visitDictionaryExpr(DictionaryExpr node) {
    GDScriptType? commonKeyType;
    GDScriptType? commonValueType;

    for (final entry in node.entries) {
      final keyType = entry.key.accept(this);
      final valueType = entry.value.accept(this);

      commonKeyType = commonKeyType == null
          ? keyType
          : (commonKeyType == keyType ? commonKeyType : VariantType.instance);
      commonValueType = commonValueType == null
          ? valueType
          : (commonValueType == valueType
                ? commonValueType
                : VariantType.instance);
    }

    final dictType = DictionaryType(
      commonKeyType ?? VariantType.instance,
      commonValueType ?? VariantType.instance,
    );
    expressionTypes[node] = dictType;
    return dictType;
  }

  @override
  GDScriptType visitTernaryExpr(TernaryExpr node) {
    node.condition.accept(this);
    final trueType = node.trueExpr.accept(this);
    final falseType = node.falseExpr.accept(this);

    final resType = (trueType == falseType) ? trueType : VariantType.instance;
    expressionTypes[node] = resType;
    return resType;
  }

  @override
  GDScriptType visitLambdaExpr(LambdaExpr node) {
    final paramTypes = node.parameters
        .map((p) => GDScriptType.fromString(p.typeAnnotation))
        .toList();
    final retType = GDScriptType.fromString(node.returnType);

    final callableType = CallableType(
      parameterTypes: paramTypes,
      returnType: retType,
    );
    node.body.accept(this);

    expressionTypes[node] = callableType;
    return callableType;
  }

  @override
  GDScriptType visitIsExpr(IsExpr node) {
    node.expression.accept(this);
    expressionTypes[node] = PrimitiveType.boolType;
    return PrimitiveType.boolType;
  }

  @override
  GDScriptType visitAsExpr(AsExpr node) {
    node.expression.accept(this);
    final targetType = GDScriptType.fromString(node.targetType);
    expressionTypes[node] = targetType;
    return targetType;
  }

  @override
  GDScriptType visitAwaitExpr(AwaitExpr node) {
    node.expression.accept(this);
    expressionTypes[node] = VariantType.instance;
    return VariantType.instance;
  }

  @override
  GDScriptType visitPreloadExpr(PreloadExpr node) {
    expressionTypes[node] = VariantType.instance;
    return VariantType.instance;
  }

  @override
  GDScriptType visitSelfExpr(SelfExpr node) {
    expressionTypes[node] = VariantType.instance;
    return VariantType.instance;
  }

  @override
  GDScriptType visitSuperExpr(SuperExpr node) {
    for (final arg in node.arguments) {
      arg.accept(this);
    }
    expressionTypes[node] = VariantType.instance;
    return VariantType.instance;
  }

  @override
  GDScriptType visitNodePathShortcut(NodePathShortcut node) {
    expressionTypes[node] = PrimitiveType.nodePathType;
    return PrimitiveType.nodePathType;
  }

  @override
  GDScriptType visitInExpr(InExpr node) {
    node.element.accept(this);
    node.collection.accept(this);
    expressionTypes[node] = PrimitiveType.boolType;
    return PrimitiveType.boolType;
  }

  @override
  GDScriptType visitErrorExpr(ErrorExpr node) => ErrorType.instance;
}
