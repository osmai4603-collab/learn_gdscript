# GDScript 4 Engine for Dart & Flutter

A comprehensive, production-grade GDScript 4 compiler, interpreter, and editor support engine written purely in Dart.

This engine powers the in-app GDScript code editor and script runner in Flutter, providing fast lexing, AST parsing, static type-checking and semantic analysis, bytecode compilation, a high-performance stack-based virtual machine, a complete GDScript standard library, and specialized editor integration services (syntax highlighting, semantic highlighting, intelligent auto-completion, real-time diagnostics, bracket matching, and code folding).

---

## 🏛 Architecture Overview

The engine is engineered as a clean 9-layer pipeline:

```text
Source Code
    │
    ▼
[ 1. Lexer & IndentTracker ] ──────────► [ Lexical Syntax Highlighting ]
    │
    ▼
[ 2. Parser & AST ] ───────────────────► [ Code Folding & Diagnostics ]
    │
    ▼
[ 3. Semantic Resolver & TypeChecker ] ─► [ Semantic Highlighting & Autocomplete ]
    │
    ▼
[ 4. Bytecode Compiler ]
    │ (OpCode Chunk + Constant Pool + Classes/Functions)
    ▼
[ 5. Bytecode Virtual Machine ]
    │ (CallFrames, Value Stack, Upvalues, Builtins)
    ▼
[ 6. GDScript Standard Library ]
    │ (@GDScript, @GlobalScope, String, Array, Dictionary)
    ▼
Execution Result & Live Streams (stdout, state, diagnostics)
```

---

## 📂 Module Organization

| Directory | Module | Description |
| :--- | :--- | :--- |
| `core/` | **Core Foundations** | Source tracking, accurate line/column locations, unified `Diagnostic` system and `ErrorReporter`. |
| `lexer/` | **Lexical Scanner** | GDScript 4 tokenizer, keyword tables, literal parsers, and indentation tracking (`INDENT`/`DEDENT`). |
| `parser/` | **Syntactic Parser** | Recursive descent parser with operator precedence Pratt-style parsing, full GDScript 4 grammar, and error recovery. |
| `analyzer/` | **Semantic Analysis** | Scopes, symbol tables, identifier resolution, type inference, function signatures, and GDScript type validation. |
| `objects/` | **Object Model** | First-class GDScript OOP runtime: `GDClass`, `GDInstance`, `GDFunction`, `GDCallable`, `GDSignal`, and `GDEnum`. |
| `compiler/` | **Bytecode Generator** | Emits compact bytecode `Chunk`s, 40+ `OpCode` instructions, constant pools, local variable slots, and closures. |
| `runtime/` | **Virtual Machine** | Stack-based execution engine with call stack frames, upvalue capturing, cycle protection, and instruction limits. |
| `runtime/native/` | **Built-in Library** | 55+ `@GDScript` and `@GlobalScope` functions, 30+ `GDString` and `GDArray` methods, dictionary operations, and constants. |
| `api/` | **Editor Integration** | The primary public API: `GDScriptEngine`, `EditorAPI`, `EngineConfig`, and `ExecutionResult`. |

---

## 🚀 Quick Start Guide

### 1. Initializing and Executing Code

```dart
import 'package:gdscript_engine/gdscript_engine.dart';

void main() async {
  // Create an engine instance
  final engine = GDScriptEngine();

  const script = '''
var x = 10
var y = 25
print("Result: " + str(x + y))

func calculate_power(val: int) -> int:
    return val * val

print("Power of 6: " + str(calculate_power(6)))
''';

  // Execute asynchronously
  final result = await engine.execute(script);

  if (result.isSuccess) {
    print('Execution completed in ${result.executionTime.inMilliseconds}ms');
    print('Instructions executed: ${result.instructionsExecuted}');
    print('Outputs:');
    for (final line in result.output) {
      print('  > $line');
    }
  } else {
    print('Execution failed: ${result.errorMessage}');
  }
}
```

---

### 2. Live Streams for UI Integration

Connect reactive Flutter widgets to VM state, stdout history, and real-time diagnostics:

```dart
// Listen to printed output from print(), prints(), etc.
engine.onOutput.listen((line) {
  outputConsole.append(line);
});

// Listen to execution state transitions (ready, running, paused, completed, error)
engine.onStateChanged.listen((state) {
  print('Engine state: $state');
});

// Listen to diagnostics produced during compilation or runtime
engine.onDiagnostic.listen((diagnostic) {
  editorWidget.showDiagnostic(diagnostic);
});
```

---

### 3. Editor Services (`EditorAPI`)

The `EditorAPI` class provides high-speed services for Flutter code editor widgets:

#### A. Lexical Syntax Highlighting (Ultra-fast `O(N)`)

```dart
final editorApi = EditorAPI();
final highlights = editorApi.getSyntaxHighlights(sourceCode);

for (final h in highlights) {
  // Apply TextStyle based on h.kind (keyword, string, number, comment, operator, etc.)
  final color = getColorForKind(h.kind);
  textSpans.add(TextSpan(text: ..., style: TextStyle(color: color)));
}
```

#### B. Intelligent Auto-Completion

```dart
// Request completion proposals at cursor offset
final completions = editorApi.getCompletions(sourceCode, cursorOffset);

for (final item in completions) {
  print('${item.label} (${item.kind}) - ${item.detail}');
}
```

#### C. Real-Time Diagnostics

```dart
final diagnostics = editorApi.getDiagnostics(sourceCode);
for (final d in diagnostics) {
  print('[${d.severity}] Line ${d.location.line}: ${d.message}');
}
```

#### D. Bracket Matching & Code Folding

```dart
// Matching bracket pair: (startOffset, endOffset)
final match = editorApi.findMatchingBracket(sourceCode, cursorOffset);

// Foldable ranges for classes and multi-line functions
final foldRanges = editorApi.getFoldingRanges(sourceCode);
```

---

### 4. Interactive Debugging & Stepping

The engine includes built-in debugging primitives:

```dart
// Add and clear breakpoints on specific source lines
engine.addBreakpoint(12);
engine.removeBreakpoint(12);

// Single instruction stepping and resume controls
engine.pause();
engine.stepInto();
engine.resume();
```

---

## 🧪 Validation

Run the following from this package directory:

```bash
dart pub get
dart analyze
```

The Flutter application in the repository root consumes this package through a
local path dependency declared in its `pubspec.yaml`.
