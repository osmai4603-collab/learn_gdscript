import '../core/gdscript_error.dart';
import '../runtime/value.dart';
import 'gd_callable.dart';
import 'gd_class.dart';
import 'gd_signal.dart';

/// Represents a live, instantiated object of a [GDClass] at runtime.
class GDInstance {
  /// The class this object is an instance of.
  final GDClass gdClass;

  /// Instance fields / properties.
  final Map<String, GDValue> fields = {};

  /// Bound signals attached to this instance.
  final Map<String, GDSignal> signals = {};

  GDInstance({required this.gdClass}) {
    _initializeInstance();
  }

  void _initializeInstance() {
    // 1. Inherit and initialize fields from superclass down to this class
    final hierarchy = <GDClass>[];
    GDClass? curr = gdClass;
    while (curr != null) {
      hierarchy.insert(0, curr);
      curr = curr.superclass;
    }

    for (final cls in hierarchy) {
      for (final entry in cls.fields.entries) {
        // Deep copy container types to avoid sharing state across instances
        final val = entry.value;
        if (val is GDArray) {
          fields[entry.key] = val.duplicate();
        } else if (val is GDDictionary) {
          fields[entry.key] = val.duplicate();
        } else {
          fields[entry.key] = val;
        }
      }

      for (final sigEntry in cls.signals.entries) {
        signals[sigEntry.key] = GDSignal(name: sigEntry.key, owner: this);
      }
    }
  }

  /// Retrieves property, signal, method, or constant [name].
  GDValue get(String name) {
    if (fields.containsKey(name)) {
      return fields[name]!;
    }

    if (signals.containsKey(name)) {
      return GDSignalValue(signals[name]!);
    }

    final method = gdClass.findMethod(name);
    if (method != null) {
      return GDCallableValue(
        GDUserFunctionCallable(function: method, target: this),
      );
    }

    final constant = gdClass.findConstant(name);
    if (constant != null) {
      return constant;
    }

    throw GDRuntimeError(
      'Invalid get: member "$name" not found in "${gdClass.name}".',
    );
  }

  /// Sets property [name] to [value].
  void set(String name, GDValue value) {
    fields[name] = value;
  }

  /// Checks whether property, method, or signal [name] exists on this instance.
  bool has(String name) {
    if (fields.containsKey(name)) return true;
    if (signals.containsKey(name)) return true;
    if (gdClass.hasMethod(name)) return true;
    if (gdClass.findConstant(name) != null) return true;
    return false;
  }

  /// Invokes method [methodName] on this instance with [args].
  GDValue call(String methodName, [List<GDValue> args = const []]) {
    final method = gdClass.findMethod(methodName);
    if (method == null) {
      throw GDRuntimeError(
        'Method "$methodName" not found on instance of "${gdClass.name}".',
      );
    }
    return method.invoke(this, args);
  }

  /// Reference count for memory management.
  int refCount = 1;

  /// Whether this instance has been disposed.
  bool isDisposed = false;

  /// Increments the reference count.
  void retain() {
    if (isDisposed) {
      throw GDRuntimeError('Cannot retain a disposed instance of "${gdClass.name}".');
    }
    refCount++;
  }

  /// Decrements reference count, disposing the instance if count drops to zero.
  void release() {
    if (isDisposed) return;
    refCount--;
    if (refCount <= 0) {
      dispose();
    }
  }

  /// Disposes this instance, clearing its fields and signals.
  void dispose() {
    isDisposed = true;
    fields.clear();
    signals.clear();
  }

  /// Retrieves bound [GDSignal] by [name], or null.
  GDSignal? getSignal(String name) => signals[name];

  @override
  String toString() => '<${gdClass.name}#${hashCode.toRadixString(16)}>';
}
