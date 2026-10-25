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

  List<Diagnostic> getDiagnostics(String code) {
    _ensureActive();
    return List.unmodifiable(_engine.editorApi.getDiagnostics(code));
  }

  List<String> getCompletions(String code, int cursorOffset) {
    return List.unmodifiable([
      for (final item in getCompletionItems(code, cursorOffset))
        item.insertText ?? item.label,
    ]);
  }

  List<CompletionItem> getCompletionItems(String code, int cursorOffset) {
    _ensureActive();
    return List.unmodifiable(
      _engine.editorApi.getCompletions(code, cursorOffset),
    );
  }

  List<SyntaxHighlight> getSyntaxHighlights(String code) {
    _ensureActive();
    return List.unmodifiable(_engine.editorApi.getSyntaxHighlights(code));
  }

  List<SemanticHighlight> getSemanticHighlights(String code) {
    _ensureActive();
    return List.unmodifiable(_engine.editorApi.getSemanticHighlights(code));
  }

  SignatureHelp? getSignatureHelp(String code, int cursorOffset) {
    _ensureActive();
    return _engine.editorApi.getSignatureHelp(code, cursorOffset);
  }

  HoverInfo? getHoverInfo(String code, int cursorOffset) {
    _ensureActive();
    return _engine.editorApi.getHoverInfo(code, cursorOffset);
  }

  GoToDefinition? findDefinition(String code, int cursorOffset) {
    _ensureActive();
    return _engine.editorApi.findDefinition(code, cursorOffset);
  }

  List<FoldingRange> getFoldingRanges(String code) {
    _ensureActive();
    return List.unmodifiable(_engine.editorApi.getFoldingRanges(code));
  }

  (int, int)? findMatchingBracket(String code, int cursorOffset) {
    _ensureActive();
    return _engine.editorApi.findMatchingBracket(code, cursorOffset);
  }

  void _ensureActive() {
    if (_disposed) throw StateError('CodeRunnerService has been disposed.');
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _engine.dispose();
  }
}
