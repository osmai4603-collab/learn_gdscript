import 'package:gdscript_engine/gdscript_engine.dart';

class CodeRunResult {
  CodeRunResult({
    required this.isSuccess,
    required List<String> output,
    required this.errorMessage,
    required List<Diagnostic> diagnostics,
    required this.executionTime,
    required this.instructionsExecuted,
  }) : output = List.unmodifiable(output),
       diagnostics = List.unmodifiable(diagnostics);

  final bool isSuccess;
  final List<String> output;
  final String? errorMessage;
  final List<Diagnostic> diagnostics;
  final Duration executionTime;
  final int instructionsExecuted;

  int get executionTimeMs => executionTime.inMilliseconds;
}

class CodeRunnerService {
  CodeRunnerService({GDScriptEngine? engine})
    : _engine = engine ?? GDScriptEngine();

  final GDScriptEngine _engine;
  bool _disposed = false;

  Future<CodeRunResult> runCode(String code) async {
    if (_disposed) throw StateError('CodeRunnerService has been disposed.');
    final result = await _engine.execute(code);
    return CodeRunResult(
      isSuccess: result.isSuccess,
      output: result.output,
      errorMessage: result.errorMessage,
      diagnostics: result.diagnostics,
      executionTime: result.executionTime,
      instructionsExecuted: result.instructionsExecuted,
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _engine.dispose();
  }
}
