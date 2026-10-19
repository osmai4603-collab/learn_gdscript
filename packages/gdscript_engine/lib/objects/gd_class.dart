import '../runtime/value.dart';
import 'gd_enum.dart';
import 'gd_function.dart';
import 'gd_instance.dart';
import 'gd_signal.dart';

/// Represents a GDScript class definition template at runtime.
///
/// Contains member variables, functions, constants, signals, and inner classes.
/// Can instantiate new [GDInstance] objects.
class GDClass {
  /// Name of the class.
  final String name;

  /// Inherited parent class, or null for base classes.
  GDClass? superclass;

  /// Default values for instance variables.
  final Map<String, GDValue> fields;

  /// Declared instance and static methods.
  final Map<String, GDFunction> methods;

  /// Declared signals.
  final Map<String, GDSignal> signals;

  /// Declared enums.
  final Map<String, GDEnum> enums;

  /// Class constants.
  final Map<String, GDValue> constants;

  /// Static member variables.
  final Map<String, GDValue> staticFields;

  /// Inner nested classes.
  final Map<String, GDClass> innerClasses;

  GDClass({
    required this.name,
    this.superclass,
    Map<String, GDValue>? fields,
    Map<String, GDFunction>? methods,
    Map<String, GDSignal>? signals,
    Map<String, GDEnum>? enums,
    Map<String, GDValue>? constants,
    Map<String, GDValue>? staticFields,
    Map<String, GDClass>? innerClasses,
  }) : fields = fields ?? {},
       methods = methods ?? {},
       signals = signals ?? {},
       enums = enums ?? {},
       constants = constants ?? {},
       staticFields = staticFields ?? {},
       innerClasses = innerClasses ?? {};

  /// Creates a live [GDInstance] and executes constructor `_init` if present.
  GDInstance instantiate([List<GDValue> args = const []]) {
    final instance = GDInstance(gdClass: this);

    final initMethod = findMethod('_init');
    if (initMethod != null) {
      initMethod.invoke(instance, args);
    }

    return instance;
  }

  /// Looks up a method by [name] in this class or any of its superclasses.
  GDFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name];
    }
    return superclass?.findMethod(name);
  }

  /// Checks whether method [name] exists in this class hierarchy.
  bool hasMethod(String name) => findMethod(name) != null;

  /// Looks up a constant by [name] in this class or superclasses.
  GDValue? findConstant(String name) {
    if (constants.containsKey(name)) {
      return constants[name];
    }
    return superclass?.findConstant(name);
  }

  /// Checks whether this class is or extends [className].
  bool isSubclassOf(String className) {
    if (name == className) return true;
    return superclass?.isSubclassOf(className) ?? false;
  }

  @override
  String toString() => '<Class:$name>';
}
