import '../core/gdscript_error.dart';
import '../runtime/upvalue.dart';
import '../runtime/value.dart';
import 'gd_function.dart';
import 'gd_instance.dart';

/// Function signature for native Dart callbacks callable from GDScript.
typedef NativeCallback = GDValue Function(List<GDValue> args);

/// Unified callable object abstraction in GDScript 4.
///
/// Can represent:
/// - A method on a specific instance ([GDUserFunctionCallable])
/// - A native Dart function / standard library builtin ([GDNativeCallable])
/// - A lambda / closure ([GDLambdaCallable])
abstract class GDCallable {
  final List<GDValue> boundArguments;

  /// Global runner callback for executing bytecode chunks on callable instances.
  static GDValue Function(GDCallable callable, List<GDValue> args)? runner;

  const GDCallable({this.boundArguments = const []});

  /// Name of the function or method.
  String get name;

  /// Target instance if bound to an object, or null.
  GDInstance? get target => null;

  /// Number of expected arguments (excluding bound arguments).
  int get arity;

  /// Invokes the callable with [args], prepending any [boundArguments].
  GDValue call(List<GDValue> args);

  /// Invokes the callable with arguments supplied as a [GDArray].
  GDValue callv(GDArray args) => call(args.elements);

  /// Returns a new [GDCallable] with [extraArgs] bound (appended to arguments).
  GDCallable bind(List<GDValue> extraArgs);

  /// Returns a new [GDCallable] that drops the last [count] arguments before calling.
  GDCallable unbind(int count);

  @override
  String toString() => '<Callable:$name>';
}

/// Represents a script function bound to an optional [target] instance.
class GDUserFunctionCallable extends GDCallable {
  final GDFunction function;
  @override
  final GDInstance? target;
  final int unbindCount;

  const GDUserFunctionCallable({
    required this.function,
    this.target,
    super.boundArguments = const [],
    this.unbindCount = 0,
  });

  @override
  String get name => function.name;

  @override
  int get arity => function.arity - boundArguments.length;

  @override
  GDValue call(List<GDValue> args) {
    var effectiveArgs = [...args];
    if (unbindCount > 0 && effectiveArgs.length >= unbindCount) {
      effectiveArgs = effectiveArgs.sublist(
        0,
        effectiveArgs.length - unbindCount,
      );
    }
    effectiveArgs.addAll(boundArguments);

    if (function.chunk != null && GDCallable.runner != null) {
      return GDCallable.runner!(this, effectiveArgs);
    }

    return function.invoke(target, effectiveArgs);
  }

  @override
  GDCallable bind(List<GDValue> extraArgs) {
    return GDUserFunctionCallable(
      function: function,
      target: target,
      boundArguments: [...boundArguments, ...extraArgs],
      unbindCount: unbindCount,
    );
  }

  @override
  GDCallable unbind(int count) {
    return GDUserFunctionCallable(
      function: function,
      target: target,
      boundArguments: boundArguments,
      unbindCount: unbindCount + count,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GDUserFunctionCallable &&
          function == other.function &&
          target == other.target &&
          unbindCount == other.unbindCount);

  @override
  int get hashCode => Object.hash(function, target, unbindCount);
}

/// Represents a closure function with captured [upvalues] in the virtual machine.
class GDClosureCallable extends GDUserFunctionCallable {
  final List<VMUpvalue> upvalues;

  const GDClosureCallable({
    required super.function,
    super.target,
    this.upvalues = const [],
    super.boundArguments = const [],
    super.unbindCount = 0,
  });

  @override
  GDCallable bind(List<GDValue> extraArgs) {
    return GDClosureCallable(
      function: function,
      target: target,
      upvalues: upvalues,
      boundArguments: [...boundArguments, ...extraArgs],
      unbindCount: unbindCount,
    );
  }

  @override
  GDCallable unbind(int count) {
    return GDClosureCallable(
      function: function,
      target: target,
      upvalues: upvalues,
      boundArguments: boundArguments,
      unbindCount: unbindCount + count,
    );
  }
}

/// Represents a native Dart callback wrapped as a GDScript callable.
class GDNativeCallable extends GDCallable {
  @override
  final String name;
  final NativeCallback callback;
  @override
  final int arity;
  final int unbindCount;

  const GDNativeCallable({
    required this.name,
    required this.callback,
    this.arity = -1, // -1 means variadic
    super.boundArguments = const [],
    this.unbindCount = 0,
  });

  @override
  GDValue call(List<GDValue> args) {
    var effectiveArgs = [...args];
    if (unbindCount > 0 && effectiveArgs.length >= unbindCount) {
      effectiveArgs = effectiveArgs.sublist(
        0,
        effectiveArgs.length - unbindCount,
      );
    }
    effectiveArgs.addAll(boundArguments);

    if (arity >= 0 && effectiveArgs.length < arity) {
      throw GDRuntimeError(
        'Callable "$name" expects at least $arity arguments, but received ${effectiveArgs.length}.',
      );
    }

    return callback(effectiveArgs);
  }

  @override
  GDCallable bind(List<GDValue> extraArgs) {
    return GDNativeCallable(
      name: name,
      callback: callback,
      arity: arity,
      boundArguments: [...boundArguments, ...extraArgs],
      unbindCount: unbindCount,
    );
  }

  @override
  GDCallable unbind(int count) {
    return GDNativeCallable(
      name: name,
      callback: callback,
      arity: arity,
      boundArguments: boundArguments,
      unbindCount: unbindCount + count,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GDNativeCallable &&
          name == other.name &&
          callback == other.callback &&
          unbindCount == other.unbindCount);

  @override
  int get hashCode => Object.hash(name, callback, unbindCount);
}
