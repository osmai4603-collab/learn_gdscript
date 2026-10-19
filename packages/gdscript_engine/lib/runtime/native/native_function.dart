import '../../core/gdscript_error.dart';
import '../../objects/gd_callable.dart';

/// Descriptor and builder for native Dart functions exposed to GDScript.
class NativeFunction {
  final String name;
  final int minArity;
  final int maxArity; // -1 for unbounded
  final NativeCallback callback;
  final String? documentation;

  const NativeFunction({
    required this.name,
    required this.callback,
    this.minArity = 0,
    this.maxArity = -1,
    this.documentation,
  });

  /// Creates a [NativeFunction] with fixed arity [arity].
  factory NativeFunction.fixed({
    required String name,
    required int arity,
    required NativeCallback callback,
    String? documentation,
  }) {
    return NativeFunction(
      name: name,
      minArity: arity,
      maxArity: arity,
      callback: callback,
      documentation: documentation,
    );
  }

  /// Converts this descriptor into a callable [GDNativeCallable] with argument validation.
  GDNativeCallable toCallable() {
    return GDNativeCallable(
      name: name,
      arity: minArity == maxArity ? minArity : -1,
      callback: (args) {
        if (args.length < minArity) {
          throw GDRuntimeError(
            'Function "$name()" expects at least $minArity arguments, got ${args.length}.',
          );
        }
        if (maxArity != -1 && args.length > maxArity) {
          throw GDRuntimeError(
            'Function "$name()" expects at most $maxArity arguments, got ${args.length}.',
          );
        }
        return callback(args);
      },
    );
  }
}
