/// GDScript 4 Type System representation.
///
/// Models primitives, typed and untyped containers, classes with inheritance,
/// callables, signals, enums, Variant (dynamic), and Void/Error types.
abstract class GDScriptType {
  const GDScriptType();

  /// Canonical display name of this type.
  String get name;

  /// Whether a value of this type can be assigned to a variable of type [target].
  bool isAssignableTo(GDScriptType target);

  /// Whether this type represents numeric values (int or float).
  bool get isNumeric =>
      this == PrimitiveType.intType || this == PrimitiveType.floatType;

  /// Whether this type is a primitive value type.
  bool get isPrimitive => this is PrimitiveType;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GDScriptType &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  /// Resolves a type from its textual name (e.g. 'int', 'String', 'Array[float]').
  ///
  /// Supports nested and multi-argument generics such as
  /// `Dictionary[String, Array[int]]`.
  static GDScriptType fromString(String? typeName) {
    if (typeName == null || typeName.trim().isEmpty) {
      return VariantType.instance;
    }
    return _parse(typeName.trim());
  }

  static GDScriptType _parse(String text) {
    final bracket = text.indexOf('[');

    // Non-generic (or malformed) type name.
    if (bracket == -1 || !text.endsWith(']')) {
      switch (text) {
        case 'void':
          return VoidType.instance;
        case 'Variant':
          return VariantType.instance;
        case 'Array':
          return ArrayType(VariantType.instance);
        case 'Dictionary':
          return DictionaryType(VariantType.instance, VariantType.instance);
      }
      return PrimitiveType.resolve(text) ?? ClassType(text);
    }

    final base = text.substring(0, bracket).trim();
    final inner = text.substring(bracket + 1, text.length - 1);
    final args = _splitTopLevel(inner).map(_parse).toList();

    switch (base) {
      case 'Array':
        return ArrayType(
          args.isNotEmpty ? args.first : VariantType.instance,
        );
      case 'Dictionary':
        if (args.length >= 2) return DictionaryType(args[0], args[1]);
        return DictionaryType(VariantType.instance, VariantType.instance);
    }

    return ClassType(base);
  }

  /// Splits a generic argument list on top-level commas, ignoring commas that
  /// appear inside nested `[...]` groups.
  static List<String> _splitTopLevel(String text) {
    final parts = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '[') {
        depth++;
      } else if (char == ']') {
        depth--;
      } else if (char == ',' && depth == 0) {
        parts.add(text.substring(start, i).trim());
        start = i + 1;
      }
    }
    parts.add(text.substring(start).trim());
    return parts.where((p) => p.isNotEmpty).toList();
  }

  /// Names of built-in value types (non-`Object`) recognized by the analyzer.
  static const Set<String> builtinValueTypeNames = {
    'bool', 'int', 'float', 'String', 'StringName', 'NodePath',
    'Vector2', 'Vector2i', 'Vector3', 'Vector3i', 'Vector4', 'Vector4i',
    'Color', 'Rect2', 'Rect2i', 'Transform2D', 'Transform3D', 'Basis',
    'Quaternion', 'Plane', 'AABB', 'Projection', 'RID',
    'PackedByteArray', 'PackedInt32Array', 'PackedInt64Array',
    'PackedFloat32Array', 'PackedFloat64Array', 'PackedStringArray',
    'PackedVector2Array', 'PackedVector3Array', 'PackedVector4Array',
    'PackedColorArray',
  };

  /// Names of built-in container types.
  static const Set<String> builtinContainerTypeNames = {'Array', 'Dictionary'};

  /// Whether [name] is a built-in GDScript type name (value or container).
  static bool isBuiltinTypeName(String name) =>
      builtinValueTypeNames.contains(name) ||
      builtinContainerTypeNames.contains(name) ||
      name == 'void' ||
      name == 'Variant';
}

/// Primitive built-in types in GDScript.
class PrimitiveType extends GDScriptType {
  @override
  final String name;

  const PrimitiveType._(this.name);

  static const nullType = PrimitiveType._('null');
  static const boolType = PrimitiveType._('bool');
  static const intType = PrimitiveType._('int');
  static const floatType = PrimitiveType._('float');
  static const stringType = PrimitiveType._('String');
  static const stringNameType = PrimitiveType._('StringName');
  static const nodePathType = PrimitiveType._('NodePath');
  static const vector2Type = PrimitiveType._('Vector2');
  static const vector2iType = PrimitiveType._('Vector2i');
  static const vector3Type = PrimitiveType._('Vector3');
  static const vector3iType = PrimitiveType._('Vector3i');
  static const vector4Type = PrimitiveType._('Vector4');
  static const vector4iType = PrimitiveType._('Vector4i');
  static const colorType = PrimitiveType._('Color');
  static const rect2Type = PrimitiveType._('Rect2');
  static const rect2iType = PrimitiveType._('Rect2i');
  static const transform2DType = PrimitiveType._('Transform2D');
  static const transform3DType = PrimitiveType._('Transform3D');
  static const basisType = PrimitiveType._('Basis');
  static const quaternionType = PrimitiveType._('Quaternion');
  static const planeType = PrimitiveType._('Plane');
  static const aabbType = PrimitiveType._('AABB');
  static const projectionType = PrimitiveType._('Projection');
  static const ridType = PrimitiveType._('RID');
  static const packedByteArrayType = PrimitiveType._('PackedByteArray');
  static const packedInt32ArrayType = PrimitiveType._('PackedInt32Array');
  static const packedInt64ArrayType = PrimitiveType._('PackedInt64Array');
  static const packedFloat32ArrayType = PrimitiveType._('PackedFloat32Array');
  static const packedFloat64ArrayType = PrimitiveType._('PackedFloat64Array');
  static const packedStringArrayType = PrimitiveType._('PackedStringArray');
  static const packedVector2ArrayType = PrimitiveType._('PackedVector2Array');
  static const packedVector3ArrayType = PrimitiveType._('PackedVector3Array');
  static const packedVector4ArrayType = PrimitiveType._('PackedVector4Array');
  static const packedColorArrayType = PrimitiveType._('PackedColorArray');

  /// Looks up a built-in value type by [name], or `null` when [name] is not a
  /// known primitive/value type.
  static PrimitiveType? resolve(String name) => _byName[name];

  static const Map<String, PrimitiveType> _byName = {
    'null': nullType,
    'bool': boolType,
    'int': intType,
    'float': floatType,
    'String': stringType,
    'StringName': stringNameType,
    'NodePath': nodePathType,
    'Vector2': vector2Type,
    'Vector2i': vector2iType,
    'Vector3': vector3Type,
    'Vector3i': vector3iType,
    'Vector4': vector4Type,
    'Vector4i': vector4iType,
    'Color': colorType,
    'Rect2': rect2Type,
    'Rect2i': rect2iType,
    'Transform2D': transform2DType,
    'Transform3D': transform3DType,
    'Basis': basisType,
    'Quaternion': quaternionType,
    'Plane': planeType,
    'AABB': aabbType,
    'Projection': projectionType,
    'RID': ridType,
    'PackedByteArray': packedByteArrayType,
    'PackedInt32Array': packedInt32ArrayType,
    'PackedInt64Array': packedInt64ArrayType,
    'PackedFloat32Array': packedFloat32ArrayType,
    'PackedFloat64Array': packedFloat64ArrayType,
    'PackedStringArray': packedStringArrayType,
    'PackedVector2Array': packedVector2ArrayType,
    'PackedVector3Array': packedVector3ArrayType,
    'PackedVector4Array': packedVector4ArrayType,
    'PackedColorArray': packedColorArrayType,
  };

  @override
  bool isAssignableTo(GDScriptType target) {
    if (target is VariantType || target is ErrorType) return true;
    if (this == target) return true;

    // String and StringName interoperability in GDScript
    if (this == stringType && target == stringNameType) return true;
    if (this == stringNameType && target == stringType) return true;

    // Numeric conversion (int can be assigned to float)
    if (this == intType && target == floatType) return true;

    return false;
  }
}

/// Dynamic / Untyped Variant representation.
class VariantType extends GDScriptType {
  const VariantType._();

  static const instance = VariantType._();

  @override
  String get name => 'Variant';

  @override
  bool isAssignableTo(GDScriptType target) => true;
}

/// Void return type for procedures.
class VoidType extends GDScriptType {
  const VoidType._();

  static const instance = VoidType._();

  @override
  String get name => 'void';

  @override
  bool isAssignableTo(GDScriptType target) =>
      target is VoidType || target is VariantType;
}

/// Error sentinel type to suppress cascading error messages.
class ErrorType extends GDScriptType {
  const ErrorType._();

  static const instance = ErrorType._();

  @override
  String get name => '<ErrorType>';

  @override
  bool isAssignableTo(GDScriptType target) => true;
}

/// Typed or untyped array: `Array[T]`.
class ArrayType extends GDScriptType {
  final GDScriptType elementType;

  const ArrayType(this.elementType);

  @override
  String get name =>
      elementType is VariantType ? 'Array' : 'Array[$elementType]';

  @override
  bool isAssignableTo(GDScriptType target) {
    if (target is VariantType || target is ErrorType) return true;
    if (target is ArrayType) {
      if (target.elementType is VariantType) return true;
      return elementType.isAssignableTo(target.elementType);
    }
    return false;
  }
}

/// Typed or untyped dictionary: `Dictionary[K, V]`.
class DictionaryType extends GDScriptType {
  final GDScriptType keyType;
  final GDScriptType valueType;

  const DictionaryType(this.keyType, this.valueType);

  @override
  String get name {
    if (keyType is VariantType && valueType is VariantType) {
      return 'Dictionary';
    }
    return 'Dictionary[$keyType, $valueType]';
  }

  @override
  bool isAssignableTo(GDScriptType target) {
    if (target is VariantType || target is ErrorType) return true;
    if (target is DictionaryType) {
      if (target.keyType is VariantType && target.valueType is VariantType) {
        return true;
      }
      return keyType.isAssignableTo(target.keyType) &&
          valueType.isAssignableTo(target.valueType);
    }
    return false;
  }
}

/// User-defined or engine class type with inheritance hierarchy.
class ClassType extends GDScriptType {
  @override
  final String name;

  ClassType? superclass;
  final Map<String, GDScriptType> members = {};

  ClassType(this.name, [this.superclass]);

  @override
  bool isAssignableTo(GDScriptType target) {
    if (target is VariantType || target is ErrorType) return true;
    if (this == target) return true;

    // Check inheritance chain
    var current = superclass;
    while (current != null) {
      if (current == target || current.name == target.name) return true;
      current = current.superclass;
    }
    return false;
  }
}

/// Callable function or lambda signature.
class CallableType extends GDScriptType {
  final List<GDScriptType> parameterTypes;
  final GDScriptType returnType;

  const CallableType({required this.parameterTypes, required this.returnType});

  @override
  String get name {
    final params = parameterTypes.map((p) => p.name).join(', ');
    return 'Callable(($params) -> ${returnType.name})';
  }

  @override
  bool isAssignableTo(GDScriptType target) {
    if (target is VariantType || target is ErrorType) return true;
    if (target is CallableType) {
      if (parameterTypes.length != target.parameterTypes.length) return false;
      for (var i = 0; i < parameterTypes.length; i++) {
        if (!target.parameterTypes[i].isAssignableTo(parameterTypes[i])) {
          return false;
        }
      }
      return returnType.isAssignableTo(target.returnType);
    }
    return false;
  }
}

/// Signal type with emitted parameter types.
class SignalType extends GDScriptType {
  @override
  final String name;

  final List<GDScriptType> parameterTypes;

  const SignalType({required this.name, this.parameterTypes = const []});

  @override
  bool isAssignableTo(GDScriptType target) =>
      target is VariantType ||
      target is ErrorType ||
      (target is SignalType && name == target.name);
}

/// Enum type with named values.
class EnumType extends GDScriptType {
  @override
  final String name;

  final Map<String, int> values;

  const EnumType({required this.name, this.values = const {}});

  @override
  bool isAssignableTo(GDScriptType target) {
    if (target is VariantType || target is ErrorType) return true;
    if (target == PrimitiveType.intType) {
      return true; // Enums are integers in GDScript
    }
    return this == target;
  }
}
