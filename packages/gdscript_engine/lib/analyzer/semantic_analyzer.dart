import '../core/error_reporter.dart';
import '../parser/ast/ast_module.dart';
import 'control_flow_analyzer.dart';
import 'resolver.dart';
import 'symbol_table.dart';
import 'type_checker.dart';
import 'type_system.dart';

/// Aggregated result of semantic analysis.
class AnalysisResult {
  /// Analyzed AST root node.
  final ScriptDecl script;

  /// Complete populated symbol table and scopes hierarchy.
  final SymbolTable symbolTable;

  /// AST nodes mapped to their corresponding resolved symbols.
  final Map<AstNode, Symbol> resolutions;

  /// Expressions mapped to their inferred static types.
  final Map<Expr, GDScriptType> expressionTypes;

  /// Whether any fatal semantic errors were detected.
  final bool hasErrors;

  const AnalysisResult({
    required this.script,
    required this.symbolTable,
    required this.resolutions,
    required this.expressionTypes,
    required this.hasErrors,
  });
}

/// Orchestrates all semantic analysis passes: resolution, control flow, and typing.
class SemanticAnalyzer {
  final ErrorReporter reporter;

  SemanticAnalyzer({required this.reporter});

  /// Performs full semantic analysis on [script].
  AnalysisResult analyze(ScriptDecl script) {
    // 1. Symbol and scope resolution pass
    final resolver = Resolver(reporter: reporter);
    resolver.resolveScript(script);

    // 2. Control flow and dead-code analysis
    final controlFlow = ControlFlowAnalyzer(reporter: reporter);
    controlFlow.analyzeScript(script);

    // 3. Static type checking and inference pass
    final typeChecker = TypeChecker(reporter: reporter, resolver: resolver);
    typeChecker.checkScript(script);

    return AnalysisResult(
      script: script,
      symbolTable: resolver.symbolTable,
      resolutions: resolver.resolutions,
      expressionTypes: typeChecker.expressionTypes,
      hasErrors: reporter.hasErrors,
    );
  }
}
