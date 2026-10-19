import 'dart:async';

import '../analyzer/resolver.dart';
import '../analyzer/symbol_table.dart';
import '../analyzer/type_checker.dart';
import '../compiler/compiler.dart';
import '../core/diagnostic.dart';
import '../core/error_reporter.dart';
import '../core/source.dart';
import '../lexer/lexer.dart';
import '../lexer/token.dart';
import '../parser/ast/declarations.dart';
import '../parser/parser.dart';
import '../runtime/value.dart';
import '../runtime/vm.dart';
import 'editor_api.dart';
import 'engine_config.dart';
import 'execution_result.dart';

/// The primary public entry point and facade for the GDScript 4 Engine.
///
/// Combines Lexer, Parser, Semantic Analyzer, Compiler, and Virtual Machine
/// into a unified interface suitable for running scripts, embedding in Flutter
/// applications, and providing IDE-like editing capabilities.
class GDScriptEngine {
  /// Configuration for this engine instance.
  final EngineConfig config;

  /// Dedicated Editor API for editor integration (highlighting, completion, diagnostics).
  final EditorAPI editorApi = EditorAPI();

  /// Active virtual machine instance.
  late VM vm;

  final StreamController<ExecutionState> _stateController =
      StreamController<ExecutionState>.broadcast();
  final StreamController<String> _outputController =
      StreamController<String>.broadcast();
  final StreamController<Diagnostic> _diagnosticController =
      StreamController<Diagnostic>.broadcast();

  GDScriptEngine({this.config = const EngineConfig()}) {
    _initVM();
  }

  void _initVM() {
    vm = VM(
      initialStackCapacity: config.initialStackCapacity,
      maxInstructions: config.maxInstructions,
      maxFrames: config.maxFrames,
      globals: config.customGlobals,
      nativeFunctions: config.customNativeFunctions,
      onPrint: (text) {
        _outputController.add(text);
      },
    );
  }

  /// Stream of state transitions (ready, running, paused, completed, error).
  Stream<ExecutionState> get onStateChanged => _stateController.stream;

  /// Stream of live print output emitted by the running script.
  Stream<String> get onOutput => _outputController.stream;

  /// Stream of diagnostics produced during execution or analysis.
  Stream<Diagnostic> get onDiagnostic => _diagnosticController.stream;

  /// Current execution state of the engine's virtual machine.
  ExecutionState get state => vm.state;

  /// Executes [sourceCode] asynchronously and returns an [ExecutionResult].
  Future<ExecutionResult> execute(String sourceCode, {String? fileName}) async {
    return executeSync(sourceCode, fileName: fileName);
  }

  /// Executes [sourceCode] synchronously and returns an [ExecutionResult].
  ExecutionResult executeSync(String sourceCode, {String? fileName}) {
    final stopwatch = Stopwatch()..start();
    final source = Source(content: sourceCode, uri: fileName ?? '<script>');
    final reporter = ErrorReporter();

    try {
      // 1. Lexical Analysis
      final lexer = Lexer(source: source, reporter: reporter);
      final tokens = lexer.scanTokens();
      if (reporter.hasErrors) {
        _emitDiagnostics(reporter.diagnostics);
        return ExecutionResult.failure(
          errorMessage: 'Lexer errors:\n${reporter.formatAll()}',
          diagnostics: reporter.diagnostics,
          executionTime: stopwatch.elapsed,
        );
      }

      // 2. Syntactic Analysis (Parsing)
      final parser = Parser(source: source, tokens: tokens, reporter: reporter);
      final script = parser.parseScript();
      if (reporter.hasErrors) {
        _emitDiagnostics(reporter.diagnostics);
        return ExecutionResult.failure(
          errorMessage: 'Parser errors:\n${reporter.formatAll()}',
          diagnostics: reporter.diagnostics,
          executionTime: stopwatch.elapsed,
        );
      }

      // 3. Semantic Analysis (Resolving & Type Checking)
      final resolver = Resolver(reporter: reporter);
      resolver.resolveScript(script);

      final typeChecker = TypeChecker(reporter: reporter, resolver: resolver);
      typeChecker.checkScript(script);

      if (reporter.hasErrors) {
        _emitDiagnostics(reporter.diagnostics);
        return ExecutionResult.failure(
          errorMessage: 'Semantic errors:\n${reporter.formatAll()}',
          diagnostics: reporter.diagnostics,
          executionTime: stopwatch.elapsed,
        );
      }

      // 4. Bytecode Compilation
      final compiler = Compiler(errorReporter: reporter);
      final compilerResult = compiler.compileScript(script);

      // 5. Bytecode VM Execution
      _stateController.add(ExecutionState.running);
      final initialStdoutCount = vm.stdoutHistory.length;
      final val = vm.executeScript(compilerResult);
      _stateController.add(vm.state);

      final outputLines = vm.stdoutHistory.sublist(initialStdoutCount);
      stopwatch.stop();

      return ExecutionResult.success(
        value: val,
        output: outputLines,
        diagnostics: reporter.diagnostics,
        executionTime: stopwatch.elapsed,
        instructionsExecuted: vm.instructionCount,
      );
    } catch (e) {
      stopwatch.stop();
      _stateController.add(ExecutionState.error);
      return ExecutionResult.failure(
        errorMessage: e.toString(),
        diagnostics: reporter.diagnostics,
        executionTime: stopwatch.elapsed,
        instructionsExecuted: vm.instructionCount,
      );
    }
  }

  void _emitDiagnostics(List<Diagnostic> diagnostics) {
    for (final d in diagnostics) {
      _diagnosticController.add(d);
    }
  }

  /// Tokenizes [sourceCode] into a token list.
  List<Token> tokenize(String sourceCode, {String? fileName}) {
    final source = Source(content: sourceCode, uri: fileName ?? '<script>');
    final reporter = ErrorReporter();
    return Lexer(source: source, reporter: reporter).scanTokens();
  }

  /// Parses [sourceCode] into an AST [ScriptDecl].
  ScriptDecl parse(String sourceCode, {String? fileName, ErrorReporter? reporter}) {
    final source = Source(content: sourceCode, uri: fileName ?? '<script>');
    final rep = reporter ?? ErrorReporter();
    final tokens = Lexer(source: source, reporter: rep).scanTokens();
    return Parser(source: source, tokens: tokens, reporter: rep).parseScript();
  }

  /// Analyzes [sourceCode] and returns the populated [SymbolTable].
  SymbolTable analyze(String sourceCode, {String? fileName, ErrorReporter? reporter}) {
    final rep = reporter ?? ErrorReporter();
    final ast = parse(sourceCode, fileName: fileName, reporter: rep);
    final resolver = Resolver(reporter: rep);
    resolver.resolveScript(ast);
    final typeChecker = TypeChecker(reporter: rep, resolver: resolver);
    typeChecker.checkScript(ast);
    return resolver.symbolTable;
  }

  /// Resets the engine, instantiating a fresh Virtual Machine.
  void reset() {
    _initVM();
    _stateController.add(ExecutionState.ready);
  }

  /// Adds a breakpoint on [line].
  void addBreakpoint(int line) => vm.addBreakpoint(line);

  /// Removes a breakpoint on [line].
  void removeBreakpoint(int line) => vm.removeBreakpoint(line);

  /// Checks if a breakpoint is set on [line].
  bool hasBreakpoint(int line) => vm.hasBreakpoint(line);

  /// Clears all active breakpoints.
  void clearBreakpoints() => vm.clearBreakpoints();

  /// Executes a single bytecode instruction in step-into mode.
  void stepInto() => vm.stepInto();

  /// Resumes VM execution from paused state.
  GDValue resume() => vm.resume();

  /// Pauses the running execution.
  void pause() {
    vm.state = ExecutionState.paused;
    _stateController.add(ExecutionState.paused);
  }

  /// Disposes stream controllers.
  void dispose() {
    _stateController.close();
    _outputController.close();
    _diagnosticController.close();
  }
}
