import '../objects/gd_callable.dart';
import '../runtime/value.dart';
import '../runtime/vm.dart';

/// Configuration options for initializing and running the [GDScriptEngine].
class EngineConfig {
  /// Maximum number of bytecode instructions the VM is allowed to execute per invocation
  /// before terminating with a timeout error.
  final int maxInstructions;

  /// Maximum recursion depth allowed for call frames on the VM stack.
  final int maxFrames;

  /// Initial capacity of the VM stack.
  final int initialStackCapacity;

  /// Custom global variables to expose to the GDScript runtime.
  final Map<String, GDValue> customGlobals;

  /// Custom native Dart functions exposed as callables to GDScript.
  final Map<String, GDNativeCallable> customNativeFunctions;

  const EngineConfig({
    this.maxInstructions = VM.defaultMaxInstructions,
    this.maxFrames = VM.defaultMaxFrames,
    this.initialStackCapacity = 2048,
    this.customGlobals = const {},
    this.customNativeFunctions = const {},
  });

  /// Creates a copy of this configuration with optional overrides.
  EngineConfig copyWith({
    int? maxInstructions,
    int? maxFrames,
    int? initialStackCapacity,
    Map<String, GDValue>? customGlobals,
    Map<String, GDNativeCallable>? customNativeFunctions,
  }) {
    return EngineConfig(
      maxInstructions: maxInstructions ?? this.maxInstructions,
      maxFrames: maxFrames ?? this.maxFrames,
      initialStackCapacity: initialStackCapacity ?? this.initialStackCapacity,
      customGlobals: customGlobals ?? this.customGlobals,
      customNativeFunctions: customNativeFunctions ?? this.customNativeFunctions,
    );
  }
}
