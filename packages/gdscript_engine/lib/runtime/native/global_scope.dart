import 'dart:math' as math;

import '../../objects/gd_callable.dart';
import '../value.dart';
import 'builtin_functions.dart';

/// Provides constants and native registrations for GDScript's @GlobalScope and @GDScript environments.
class GlobalScope {
  /// Godot 4 Variant.Type enum integer values.
  static const int typeNil = 0;
  static const int typeBool = 1;
  static const int typeInt = 2;
  static const int typeFloat = 3;
  static const int typeString = 4;
  static const int typeVector2 = 5;
  static const int typeVector2i = 6;
  static const int typeRect2 = 7;
  static const int typeRect2i = 8;
  static const int typeVector3 = 9;
  static const int typeVector3i = 10;
  static const int typeTransform2d = 11;
  static const int typeVector4 = 12;
  static const int typeVector4i = 13;
  static const int typePlane = 14;
  static const int typeQuaternion = 15;
  static const int typeAabb = 16;
  static const int typeBasis = 17;
  static const int typeTransform3d = 18;
  static const int typeProjection = 19;
  static const int typeColor = 20;
  static const int typeStringName = 21;
  static const int typeNodePath = 22;
  static const int typeRid = 23;
  static const int typeObject = 24;
  static const int typeCallable = 25;
  static const int typeSignal = 26;
  static const int typeDictionary = 27;
  static const int typeArray = 28;

  /// Returns global constants map.
  static Map<String, GDValue> getConstants() {
    return {
      // Mathematical constants
      'PI': GDFloat(math.pi),
      'TAU': GDFloat(2 * math.pi),
      'E': const GDFloat(2.718281828459045),
      'INF': const GDFloat(double.infinity),
      'NAN': const GDFloat(double.nan),

      // Boolean and null literals as constants
      'null': GDNull.instance,
      'true': GDBool.trueValue,
      'false': GDBool.falseValue,

      // Variant Type constants
      'TYPE_NIL': const GDInt(typeNil),
      'TYPE_BOOL': const GDInt(typeBool),
      'TYPE_INT': const GDInt(typeInt),
      'TYPE_FLOAT': const GDInt(typeFloat),
      'TYPE_STRING': const GDInt(typeString),
      'TYPE_VECTOR2': const GDInt(typeVector2),
      'TYPE_VECTOR2I': const GDInt(typeVector2i),
      'TYPE_RECT2': const GDInt(typeRect2),
      'TYPE_RECT2I': const GDInt(typeRect2i),
      'TYPE_VECTOR3': const GDInt(typeVector3),
      'TYPE_VECTOR3I': const GDInt(typeVector3i),
      'TYPE_TRANSFORM2D': const GDInt(typeTransform2d),
      'TYPE_VECTOR4': const GDInt(typeVector4),
      'TYPE_VECTOR4I': const GDInt(typeVector4i),
      'TYPE_PLANE': const GDInt(typePlane),
      'TYPE_QUATERNION': const GDInt(typeQuaternion),
      'TYPE_AABB': const GDInt(typeAabb),
      'TYPE_BASIS': const GDInt(typeBasis),
      'TYPE_TRANSFORM3D': const GDInt(typeTransform3d),
      'TYPE_PROJECTION': const GDInt(typeProjection),
      'TYPE_COLOR': const GDInt(typeColor),
      'TYPE_STRING_NAME': const GDInt(typeStringName),
      'TYPE_NODE_PATH': const GDInt(typeNodePath),
      'TYPE_RID': const GDInt(typeRid),
      'TYPE_OBJECT': const GDInt(typeObject),
      'TYPE_CALLABLE': const GDInt(typeCallable),
      'TYPE_SIGNAL': const GDInt(typeSignal),
      'TYPE_DICTIONARY': const GDInt(typeDictionary),
      'TYPE_ARRAY': const GDInt(typeArray),
    };
  }

  /// Registers all global constants and built-in functions into target collections.
  static void registerAll({
    required Map<String, GDValue> globals,
    required Map<String, GDNativeCallable> nativeFunctions,
    void Function(String text)? onPrint,
    List<String>? stdoutHistory,
    void Function(String warning)? onWarning,
    void Function(String error)? onError,
  }) {
    // 1. Populate constants
    globals.addAll(getConstants());

    // 2. Populate built-in functions
    final definitions = BuiltinFunctions.getDefinitions(
      onPrint: onPrint,
      stdoutHistory: stdoutHistory,
      onWarning: onWarning,
      onError: onError,
    );

    for (final def in definitions) {
      nativeFunctions[def.name] = def.toCallable();
    }
  }
}
