import '../compiler/chunk.dart';
import '../core/gdscript_error.dart';
import '../runtime/value.dart';
import 'gd_instance.dart';

/// Parameter specification for a [GDFunction].
class GDParameter {
  final String name;
  final String? typeAnnotation;
  final GDValue? defaultValue;

  const GDParameter({
    required this.name,
    this.typeAnnotation,
    this.defaultValue,
  });

  bool get hasDefault => defaultValue != null;
}

/// Implementation handler for executing a function.
typedef FunctionExecutor =
    GDValue Function(GDInstance? instance, List<GDValue> args);

/// Represents a defined GDScript function or method.
class GDFunction {
  final String name;
  final List<GDParameter> parameters;
  final String? returnType;
  final bool isStatic;
  final FunctionExecutor? executor;
  final Chunk? chunk;
  final int localCount;

  const GDFunction({
    required this.name,
    this.parameters = const [],
    this.returnType,
    this.isStatic = false,
    this.executor,
    this.chunk,
    this.localCount = 0,
  });

  /// Total parameter count.
  int get arity => parameters.length;

  /// Minimum number of required arguments (excluding parameters with default values).
  int get requiredArity => parameters.where((p) => !p.hasDefault).length;

  /// Invokes the function on [instance] with given [args].
  GDValue invoke(GDInstance? instance, List<GDValue> args) {
    if (args.length < requiredArity) {
      throw GDRuntimeError(
        'Function "$name" requires at least $requiredArity arguments, but got ${args.length}.',
      );
    }
    if (args.length > arity) {
      throw GDRuntimeError(
        'Function "$name" accepts at most $arity arguments, but got ${args.length}.',
      );
    }

    // Fill in default values if fewer arguments provided
    final resolvedArgs = <GDValue>[...args];
    for (var i = args.length; i < parameters.length; i++) {
      resolvedArgs.add(parameters[i].defaultValue ?? GDNull.instance);
    }

    if (executor != null) {
      return executor!(instance, resolvedArgs);
    }

    return GDNull.instance;
  }

  @override
  String toString() => 'GDFunction($name, arity: $arity)';
}
