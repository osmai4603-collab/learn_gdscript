import 'dart:collection';
import 'dart:math' as math;

import '../core/gdscript_error.dart';
import '../objects/gd_callable.dart';
import '../objects/gd_class.dart';
import '../objects/gd_enum.dart';
import '../objects/gd_instance.dart';
import '../objects/gd_signal.dart';
import '../objects/gd_string_helpers.dart';

/// Base runtime value representation in the GDScript Virtual Machine.
///
/// Analogous to Godot's `Variant` type. A `GDValue` encapsulates dynamically
/// typed data, supports GDScript operator semantics, type conversions,
/// truthiness checks, and hashing for collection keys.
sealed class GDValue implements Comparable<GDValue> {
  const GDValue();

  /// GDScript type name (e.g. 'Nil', 'bool', 'int', 'float', 'String', etc.).
  String get typeName;

  /// GDScript truthiness evaluation.
  ///
  /// In GDScript:
  /// - `null`, `false`, `0`, `0.0`, `""`, empty `Array`, and empty `Dictionary` are false.
  /// - All other values are true.
  bool get isTruthy;

  /// Converts this value to a 64-bit integer, throwing [GDRuntimeError] if unsupported.
  int toInt();

  /// Converts this value to a 64-bit float, throwing [GDRuntimeError] if unsupported.
  double toFloat();

  /// Converts this value to a boolean.
  bool toBool() => isTruthy;

  /// String representation conforming to GDScript print formatting.
  String toGDString();

  // ===========================================================================
  // Arithmetic Operators
  // ===========================================================================

  GDValue operator +(GDValue other) {
    throw GDRuntimeError('Cannot add "$typeName" and "${other.typeName}".');
  }

  GDValue operator -(GDValue other) {
    throw GDRuntimeError(
      'Cannot subtract "${other.typeName}" from "$typeName".',
    );
  }

  GDValue operator *(GDValue other) {
    throw GDRuntimeError('Cannot multiply "$typeName" by "${other.typeName}".');
  }

  GDValue operator /(GDValue other) {
    throw GDRuntimeError('Cannot divide "$typeName" by "${other.typeName}".');
  }

  GDValue operator %(GDValue other) {
    throw GDRuntimeError('Cannot modulo "$typeName" by "${other.typeName}".');
  }

  /// Power operator (`**`).
  GDValue power(GDValue other) {
    throw GDRuntimeError(
      'Cannot raise "$typeName" to power "${other.typeName}".',
    );
  }

  /// Unary negate (`-x`).
  GDValue negate() {
    throw GDRuntimeError('Cannot negate "$typeName".');
  }

  // ===========================================================================
  // Bitwise Operators
  // ===========================================================================

  GDValue operator &(GDValue other) {
    throw GDRuntimeError(
      'Bitwise AND not supported for "$typeName" and "${other.typeName}".',
    );
  }

  GDValue operator |(GDValue other) {
    throw GDRuntimeError(
      'Bitwise OR not supported for "$typeName" and "${other.typeName}".',
    );
  }

  GDValue operator ^(GDValue other) {
    throw GDRuntimeError(
      'Bitwise XOR not supported for "$typeName" and "${other.typeName}".',
    );
  }

  GDValue operator ~() {
    throw GDRuntimeError('Bitwise NOT not supported for "$typeName".');
  }

  GDValue operator <<(GDValue other) {
    throw GDRuntimeError(
      'Bitwise shift left not supported for "$typeName" and "${other.typeName}".',
    );
  }

  GDValue operator >>(GDValue other) {
    throw GDRuntimeError(
      'Bitwise shift right not supported for "$typeName" and "${other.typeName}".',
    );
  }

  /// Subscript indexing read (`collection[index]`).
  GDValue operator [](GDValue index) {
    throw GDRuntimeError('Cannot index into value of type "$typeName".');
  }

  /// Subscript indexing assignment (`collection[index] = value`).
  void operator []=(GDValue index, GDValue value) {
    throw GDRuntimeError('Cannot set index on value of type "$typeName".');
  }

  // ===========================================================================
  // Comparison
  // ===========================================================================

  bool operator <(GDValue other) => compareTo(other) < 0;
  bool operator <=(GDValue other) => compareTo(other) <= 0;
  bool operator >(GDValue other) => compareTo(other) > 0;
  bool operator >=(GDValue other) => compareTo(other) >= 0;

  @override
  int compareTo(GDValue other) {
    throw GDRuntimeError(
      'Comparison not supported between "$typeName" and "${other.typeName}".',
    );
  }

  // ===========================================================================
  // Factories and Conversions from/to Dart
  // ===========================================================================

  /// Wraps a native Dart value into the appropriate [GDValue].
  static GDValue from(Object? value) {
    if (value == null) return GDNull.instance;
    if (value is GDValue) return value;
    if (value is bool) return value ? GDBool.trueValue : GDBool.falseValue;
    if (value is int) return GDInt(value);
    if (value is double) return GDFloat(value);
    if (value is String) return GDString(value);
    if (value is List) {
      return GDArray(value.map(GDValue.from).toList());
    }
    if (value is Map) {
      final dict = GDDictionary();
      for (final entry in value.entries) {
        dict.set(GDValue.from(entry.key), GDValue.from(entry.value));
      }
      return dict;
    }
    if (value is GDInstance) return GDObject(value);
    if (value is GDClass) return GDClassValue(value);
    if (value is GDCallable) return GDCallableValue(value);
    if (value is GDSignal) return GDSignalValue(value);
    if (value is GDEnum) return GDEnumValue(value.name, '', 0);

    throw GDRuntimeError('Unsupported Dart value type: ${value.runtimeType}');
  }

  /// Converts this [GDValue] back to a standard Dart value.
  Object? toDart();

  @override
  String toString() => toGDString();
}

// =============================================================================
// GDNull
// =============================================================================

/// Represents the `null` (Nil) value in GDScript.
final class GDNull extends GDValue {
  static const GDNull instance = GDNull._();

  const GDNull._();

  @override
  String get typeName => 'Nil';

  @override
  bool get isTruthy => false;

  @override
  int toInt() => 0;

  @override
  double toFloat() => 0.0;

  @override
  String toGDString() => '<null>';

  @override
  Object? toDart() => null;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GDNull;

  @override
  int get hashCode => 0;

  @override
  int compareTo(GDValue other) {
    if (other is GDNull) return 0;
    return -1;
  }
}

// =============================================================================
// GDBool
// =============================================================================

/// Represents boolean values (`true` and `false`) in GDScript.
final class GDBool extends GDValue {
  static const GDBool trueValue = GDBool._(true);
  static const GDBool falseValue = GDBool._(false);

  final bool value;

  const GDBool._(this.value);

  factory GDBool(bool value) => value ? trueValue : falseValue;

  @override
  String get typeName => 'bool';

  @override
  bool get isTruthy => value;

  @override
  int toInt() => value ? 1 : 0;

  @override
  double toFloat() => value ? 1.0 : 0.0;

  @override
  String toGDString() => value ? 'true' : 'false';

  @override
  Object? toDart() => value;

  @override
  GDValue operator &(GDValue other) {
    if (other is GDBool) return GDBool(value && other.value);
    return super & other;
  }

  @override
  GDValue operator |(GDValue other) {
    if (other is GDBool) return GDBool(value || other.value);
    return super | other;
  }

  @override
  GDValue operator ^(GDValue other) {
    if (other is GDBool) return GDBool(value ^ other.value);
    return super ^ other;
  }

  @override
  GDValue operator ~() => GDBool(!value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GDBool && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  int compareTo(GDValue other) {
    if (other is GDBool) {
      if (value == other.value) return 0;
      return value ? 1 : -1;
    }
    return super.compareTo(other);
  }
}

// =============================================================================
// GDInt
// =============================================================================

/// Represents 64-bit signed integers in GDScript.
final class GDInt extends GDValue {
  final int value;

  const GDInt(this.value);

  @override
  String get typeName => 'int';

  @override
  bool get isTruthy => value != 0;

  @override
  int toInt() => value;

  @override
  double toFloat() => value.toDouble();

  @override
  String toGDString() => value.toString();

  @override
  Object? toDart() => value;

  @override
  GDValue operator +(GDValue other) {
    if (other is GDInt) return GDInt(value + other.value);
    if (other is GDFloat) return GDFloat(value + other.value);
    if (other is GDEnumValue) return GDInt(value + other.value);
    return super + other;
  }

  @override
  GDValue operator -(GDValue other) {
    if (other is GDInt) return GDInt(value - other.value);
    if (other is GDFloat) return GDFloat(value - other.value);
    if (other is GDEnumValue) return GDInt(value - other.value);
    return super - other;
  }

  @override
  GDValue operator *(GDValue other) {
    if (other is GDInt) return GDInt(value * other.value);
    if (other is GDFloat) return GDFloat(value * other.value);
    if (other is GDString) {
      return GDString(other.value * math.max(0, value));
    }
    if (other is GDArray) {
      final repeated = <GDValue>[];
      for (var i = 0; i < math.max(0, value); i++) {
        repeated.addAll(other.elements);
      }
      return GDArray(repeated);
    }
    return super * other;
  }

  @override
  GDValue operator /(GDValue other) {
    if (other is GDInt) {
      if (other.value == 0) {
        throw GDRuntimeError('Division by zero.');
      }
      return GDFloat(value / other.value);
    }
    if (other is GDFloat) {
      if (other.value == 0.0) {
        throw GDRuntimeError('Division by zero.');
      }
      return GDFloat(value / other.value);
    }
    return super / other;
  }

  @override
  GDValue operator %(GDValue other) {
    if (other is GDInt) {
      if (other.value == 0) throw GDRuntimeError('Modulo by zero.');
      return GDInt(value % other.value);
    }
    if (other is GDFloat) {
      if (other.value == 0.0) throw GDRuntimeError('Modulo by zero.');
      return GDFloat(value % other.value);
    }
    return super % other;
  }

  @override
  GDValue power(GDValue other) {
    if (other is GDInt) {
      if (other.value >= 0) {
        return GDInt(math.pow(value, other.value).toInt());
      }
      return GDFloat(math.pow(value, other.value).toDouble());
    }
    if (other is GDFloat) {
      return GDFloat(math.pow(value, other.value).toDouble());
    }
    return super.power(other);
  }

  @override
  GDValue negate() => GDInt(-value);

  @override
  GDValue operator &(GDValue other) {
    if (other is GDInt) return GDInt(value & other.value);
    if (other is GDEnumValue) return GDInt(value & other.value);
    return super & other;
  }

  @override
  GDValue operator |(GDValue other) {
    if (other is GDInt) return GDInt(value | other.value);
    if (other is GDEnumValue) return GDInt(value | other.value);
    return super | other;
  }

  @override
  GDValue operator ^(GDValue other) {
    if (other is GDInt) return GDInt(value ^ other.value);
    if (other is GDEnumValue) return GDInt(value ^ other.value);
    return super ^ other;
  }

  @override
  GDValue operator ~() => GDInt(~value);

  @override
  GDValue operator <<(GDValue other) {
    if (other is GDInt) return GDInt(value << other.value);
    return super << other;
  }

  @override
  GDValue operator >>(GDValue other) {
    if (other is GDInt) return GDInt(value >> other.value);
    return super >> other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is GDInt) return value == other.value;
    if (other is GDFloat) return value == other.value;
    if (other is GDEnumValue) return value == other.value;
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  int compareTo(GDValue other) {
    if (other is GDInt) return value.compareTo(other.value);
    if (other is GDFloat) return value.toDouble().compareTo(other.value);
    if (other is GDEnumValue) return value.compareTo(other.value);
    return super.compareTo(other);
  }
}

// =============================================================================
// GDFloat
// =============================================================================

/// Represents 64-bit IEEE-754 floating point numbers in GDScript.
final class GDFloat extends GDValue {
  final double value;

  const GDFloat(this.value);

  @override
  String get typeName => 'float';

  @override
  bool get isTruthy => value != 0.0 && !value.isNaN;

  @override
  int toInt() => value.toInt();

  @override
  double toFloat() => value;

  @override
  String toGDString() {
    if (value.isInfinite) return value.isNegative ? '-inf' : 'inf';
    if (value.isNaN) return 'nan';
    final s = value.toString();
    return s.contains('.') ? s : '$s.0';
  }

  @override
  Object? toDart() => value;

  @override
  GDValue operator +(GDValue other) {
    if (other is GDFloat) return GDFloat(value + other.value);
    if (other is GDInt) return GDFloat(value + other.value);
    return super + other;
  }

  @override
  GDValue operator -(GDValue other) {
    if (other is GDFloat) return GDFloat(value - other.value);
    if (other is GDInt) return GDFloat(value - other.value);
    return super - other;
  }

  @override
  GDValue operator *(GDValue other) {
    if (other is GDFloat) return GDFloat(value * other.value);
    if (other is GDInt) return GDFloat(value * other.value);
    return super * other;
  }

  @override
  GDValue operator /(GDValue other) {
    if (other is GDFloat) {
      if (other.value == 0.0) throw GDRuntimeError('Division by zero.');
      return GDFloat(value / other.value);
    }
    if (other is GDInt) {
      if (other.value == 0) throw GDRuntimeError('Division by zero.');
      return GDFloat(value / other.value);
    }
    return super / other;
  }

  @override
  GDValue operator %(GDValue other) {
    if (other is GDFloat) {
      if (other.value == 0.0) throw GDRuntimeError('Modulo by zero.');
      return GDFloat(value % other.value);
    }
    if (other is GDInt) {
      if (other.value == 0) throw GDRuntimeError('Modulo by zero.');
      return GDFloat(value % other.value);
    }
    return super % other;
  }

  @override
  GDValue power(GDValue other) {
    if (other is GDFloat) {
      return GDFloat(math.pow(value, other.value).toDouble());
    }
    if (other is GDInt) {
      return GDFloat(math.pow(value, other.value).toDouble());
    }
    return super.power(other);
  }

  @override
  GDValue negate() => GDFloat(-value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is GDFloat) return value == other.value;
    if (other is GDInt) return value == other.value;
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  int compareTo(GDValue other) {
    if (other is GDFloat) return value.compareTo(other.value);
    if (other is GDInt) return value.compareTo(other.value.toDouble());
    return super.compareTo(other);
  }
}

// =============================================================================
// GDString
// =============================================================================

/// Represents UTF-8 string values in GDScript with rich builtin methods.
final class GDString extends GDValue {
  final String value;

  const GDString(this.value);

  @override
  String get typeName => 'String';

  @override
  bool get isTruthy => value.isNotEmpty;

  @override
  int toInt() => int.tryParse(value) ?? 0;

  @override
  double toFloat() => double.tryParse(value) ?? 0.0;

  @override
  String toGDString() => value;

  @override
  Object? toDart() => value;

  int get length => value.length;

  @override
  GDValue operator +(GDValue other) {
    if (other is GDString) return GDString(value + other.value);
    return super + other;
  }

  @override
  GDValue operator *(GDValue other) {
    if (other is GDInt) {
      return GDString(value * math.max(0, other.value));
    }
    return super * other;
  }

  /// Builtin string operations
  GDString substr(int start, [int? length]) =>
      GDString(GDStringHelpers.substr(value, start, length));

  GDInt find(String what, [int from = 0]) =>
      GDInt(GDStringHelpers.find(value, what, from));

  GDInt rfind(String what, [int? from]) =>
      GDInt(GDStringHelpers.rfind(value, what, from));

  GDString replace(String what, String forWhat) =>
      GDString(GDStringHelpers.replace(value, what, forWhat));

  GDArray split([String delimiter = '', bool allowEmpty = true]) => GDArray(
    GDStringHelpers.split(
      value,
      delimiter,
      allowEmpty,
    ).map(GDString.new).toList(),
  );

  GDString toUpper() => GDString(GDStringHelpers.toUpper(value));
  GDString toLower() => GDString(GDStringHelpers.toLower(value));
  GDString stripEdges() => GDString(GDStringHelpers.stripEdges(value));
  GDBool beginsWith(String prefix) =>
      GDBool(GDStringHelpers.beginsWith(value, prefix));
  GDBool endsWith(String suffix) =>
      GDBool(GDStringHelpers.endsWith(value, suffix));
  GDBool contains(String what) => GDBool(GDStringHelpers.contains(value, what));
  GDString repeat(int count) => GDString(GDStringHelpers.repeat(value, count));
  GDString padZeros(int digits) =>
      GDString(GDStringHelpers.padZeros(value, digits));
  GDString lpad(int minLength, [String character = ' ']) =>
      GDString(GDStringHelpers.lpad(value, minLength, character));
  GDString rpad(int minLength, [String character = ' ']) =>
      GDString(GDStringHelpers.rpad(value, minLength, character));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GDString && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  GDValue operator [](GDValue index) {
    var i = index.toInt();
    if (i < 0) i = value.length + i;
    if (i < 0 || i >= value.length) {
      throw GDRuntimeError(
        'String index $i out of bounds (length ${value.length}).',
      );
    }
    return GDString(value[i]);
  }

  @override
  int compareTo(GDValue other) {
    if (other is GDString) return value.compareTo(other.value);
    return super.compareTo(other);
  }
}

// =============================================================================
// GDArray
// =============================================================================

/// Represents a dynamically resizable array in GDScript.
final class GDArray extends GDValue {
  final List<GDValue> elements;

  GDArray([List<GDValue>? elements]) : elements = elements ?? [];

  @override
  String get typeName => 'Array';

  @override
  bool get isTruthy => elements.isNotEmpty;

  @override
  int toInt() => elements.length;

  @override
  double toFloat() => elements.length.toDouble();

  @override
  String toGDString() => '[${elements.map((e) => e.toGDString()).join(', ')}]';

  @override
  Object? toDart() => elements.map((e) => e.toDart()).toList();

  int get length => elements.length;
  bool get isEmpty => elements.isEmpty;
  bool get isNotEmpty => elements.isNotEmpty;

  void append(GDValue value) => elements.add(value);
  void pushFront(GDValue value) => elements.insert(0, value);
  GDValue popBack() =>
      elements.isNotEmpty ? elements.removeLast() : GDNull.instance;
  GDValue popFront() =>
      elements.isNotEmpty ? elements.removeAt(0) : GDNull.instance;

  GDValue get(int index) {
    final actual = index < 0 ? elements.length + index : index;
    if (actual < 0 || actual >= elements.length) {
      throw GDRuntimeError('Array index out of bounds: $index.');
    }
    return elements[actual];
  }

  void set(int index, GDValue value) {
    final actual = index < 0 ? elements.length + index : index;
    if (actual < 0 || actual >= elements.length) {
      throw GDRuntimeError('Array index out of bounds: $index.');
    }
    elements[actual] = value;
  }

  void clear() => elements.clear();

  void insert(int index, GDValue value) {
    final actual = index < 0 ? elements.length + index : index;
    if (actual < 0 || actual > elements.length) {
      throw GDRuntimeError('Array insert index out of bounds: $index.');
    }
    elements.insert(actual, value);
  }

  bool erase(GDValue value) => elements.remove(value);
  bool has(GDValue value) => elements.contains(value);
  int find(GDValue value, [int from = 0]) => elements.indexOf(value, from);
  int count(GDValue value) => elements.where((e) => e == value).length;

  void reverse() {
    final reversed = elements.reversed.toList();
    elements
      ..clear()
      ..addAll(reversed);
  }

  void sort() {
    elements.sort((a, b) => a.compareTo(b));
  }

  GDArray slice(int start, [int? end]) {
    final len = elements.length;
    var s = start < 0 ? len + start : start;
    var e = end == null ? len : (end < 0 ? len + end : end);
    s = s.clamp(0, len);
    e = e.clamp(s, len);
    return GDArray(elements.sublist(s, e));
  }

  GDArray duplicate() => GDArray(List.of(elements));

  @override
  GDValue operator [](GDValue index) {
    var i = index.toInt();
    if (i < 0) i = elements.length + i;
    if (i < 0 || i >= elements.length) {
      throw GDRuntimeError(
        'Array index $i out of bounds (size ${elements.length}).',
      );
    }
    return elements[i];
  }

  @override
  void operator []=(GDValue index, GDValue value) {
    var i = index.toInt();
    if (i < 0) i = elements.length + i;
    if (i < 0 || i >= elements.length) {
      throw GDRuntimeError(
        'Array index $i out of bounds (size ${elements.length}).',
      );
    }
    elements[i] = value;
  }

  @override
  GDValue operator +(GDValue other) {
    if (other is GDArray) {
      return GDArray([...elements, ...other.elements]);
    }
    return super + other;
  }

  @override
  GDValue operator *(GDValue other) {
    if (other is GDInt) {
      final repeated = <GDValue>[];
      for (var i = 0; i < math.max(0, other.value); i++) {
        repeated.addAll(elements);
      }
      return GDArray(repeated);
    }
    return super * other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GDArray || elements.length != other.elements.length) {
      return false;
    }
    for (var i = 0; i < elements.length; i++) {
      if (elements[i] != other.elements[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(elements);
}

// =============================================================================
// GDDictionary
// =============================================================================

/// Represents a key-value hash map in GDScript with insertion-order preservation.
final class GDDictionary extends GDValue {
  final LinkedHashMap<GDValue, GDValue> map;

  GDDictionary([Map<GDValue, GDValue>? initial])
    : map = LinkedHashMap<GDValue, GDValue>.from(initial ?? {});

  @override
  String get typeName => 'Dictionary';

  @override
  bool get isTruthy => map.isNotEmpty;

  @override
  int toInt() => map.length;

  @override
  double toFloat() => map.length.toDouble();

  @override
  String toGDString() {
    final entries = map.entries
        .map((e) => '${e.key.toGDString()}: ${e.value.toGDString()}')
        .join(', ');
    return '{$entries}';
  }

  @override
  Object? toDart() {
    final result = <Object?, Object?>{};
    for (final entry in map.entries) {
      result[entry.key.toDart()] = entry.value.toDart();
    }
    return result;
  }

  LinkedHashMap<GDValue, GDValue> get elements => map;

  int get length => map.length;
  bool get isEmpty => map.isEmpty;
  bool get isNotEmpty => map.isNotEmpty;

  @override
  GDValue operator [](GDValue index) {
    if (!map.containsKey(index)) {
      throw GDRuntimeError('Dictionary key "${index.toGDString()}" not found.');
    }
    return map[index]!;
  }

  @override
  void operator []=(GDValue index, GDValue value) {
    map[index] = value;
  }

  GDValue get(GDValue key, [GDValue defaultVal = GDNull.instance]) {
    return map[key] ?? defaultVal;
  }

  void set(GDValue key, GDValue value) {
    map[key] = value;
  }

  bool has(GDValue key) => map.containsKey(key);
  bool erase(GDValue key) => map.remove(key) != null;
  void clear() => map.clear();

  GDArray keys() => GDArray(map.keys.toList());
  GDArray values() => GDArray(map.values.toList());

  void merge(GDDictionary other, [bool overwrite = false]) {
    for (final entry in other.map.entries) {
      if (overwrite || !map.containsKey(entry.key)) {
        map[entry.key] = entry.value;
      }
    }
  }

  GDDictionary duplicate() => GDDictionary(LinkedHashMap.from(map));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GDDictionary || map.length != other.map.length) {
      return false;
    }
    for (final entry in map.entries) {
      if (other.map[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(map.entries);
}

// =============================================================================
// GDObject (Wrapper around GDInstance)
// =============================================================================

/// Wraps a living [GDInstance] into a [GDValue].
final class GDObject extends GDValue {
  final GDInstance instance;

  const GDObject(this.instance);

  @override
  String get typeName => instance.gdClass.name;

  @override
  bool get isTruthy => true;

  @override
  int toInt() => instance.hashCode;

  @override
  double toFloat() => instance.hashCode.toDouble();

  @override
  String toGDString() => '<${instance.gdClass.name}#${instance.hashCode}>';

  @override
  Object? toDart() => instance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GDObject && identical(instance, other.instance));

  @override
  int get hashCode => instance.hashCode;
}

// =============================================================================
// GDCallableValue
// =============================================================================

/// Wraps a [GDCallable] into a [GDValue].
final class GDCallableValue extends GDValue {
  final GDCallable callable;

  const GDCallableValue(this.callable);

  @override
  String get typeName => 'Callable';

  @override
  bool get isTruthy => true;

  @override
  int toInt() => callable.hashCode;

  @override
  double toFloat() => callable.hashCode.toDouble();

  @override
  String toGDString() => '<Callable:${callable.name}>';

  @override
  Object? toDart() => callable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GDCallableValue && callable == other.callable);

  @override
  int get hashCode => callable.hashCode;
}

// =============================================================================
// GDSignalValue
// =============================================================================

/// Wraps a [GDSignal] into a [GDValue].
final class GDSignalValue extends GDValue {
  final GDSignal signal;

  const GDSignalValue(this.signal);

  @override
  String get typeName => 'Signal';

  @override
  bool get isTruthy => true;

  @override
  int toInt() => signal.hashCode;

  @override
  double toFloat() => signal.hashCode.toDouble();

  @override
  String toGDString() => '<Signal:${signal.name}>';

  @override
  Object? toDart() => signal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GDSignalValue && signal == other.signal);

  @override
  int get hashCode => signal.hashCode;
}

// =============================================================================
// GDEnumValue
// =============================================================================

/// Represents a named enum item with an integer backing value.
final class GDEnumValue extends GDValue {
  final String enumName;
  final String key;
  final int value;

  const GDEnumValue(this.enumName, this.key, this.value);

  @override
  String get typeName => enumName.isNotEmpty ? enumName : 'int';

  @override
  bool get isTruthy => value != 0;

  @override
  int toInt() => value;

  @override
  double toFloat() => value.toDouble();

  @override
  String toGDString() =>
      key.isNotEmpty ? '$enumName.$key ($value)' : value.toString();

  @override
  Object? toDart() => value;

  @override
  GDValue operator +(GDValue other) {
    if (other is GDInt) return GDInt(value + other.value);
    if (other is GDEnumValue) return GDInt(value + other.value);
    return super + other;
  }

  @override
  GDValue operator -(GDValue other) {
    if (other is GDInt) return GDInt(value - other.value);
    if (other is GDEnumValue) return GDInt(value - other.value);
    return super - other;
  }

  @override
  GDValue operator &(GDValue other) {
    if (other is GDInt) return GDInt(value & other.value);
    if (other is GDEnumValue) return GDInt(value & other.value);
    return super & other;
  }

  @override
  GDValue operator |(GDValue other) {
    if (other is GDInt) return GDInt(value | other.value);
    if (other is GDEnumValue) return GDInt(value | other.value);
    return super | other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is GDEnumValue) {
      return value == other.value &&
          (enumName.isEmpty ||
              other.enumName.isEmpty ||
              enumName == other.enumName);
    }
    if (other is GDInt) return value == other.value;
    return false;
  }

  @override
  int get hashCode => Object.hash(enumName, value);

  @override
  int compareTo(GDValue other) {
    if (other is GDEnumValue) return value.compareTo(other.value);
    if (other is GDInt) return value.compareTo(other.value);
    return super.compareTo(other);
  }
}

// =============================================================================
// GDClassValue
// =============================================================================

/// Wraps a [GDClass] reference into a [GDValue].
final class GDClassValue extends GDValue {
  final GDClass gdClass;

  const GDClassValue(this.gdClass);

  @override
  String get typeName => 'GDScriptNativeClass';

  @override
  bool get isTruthy => true;

  @override
  int toInt() =>
      throw GDRuntimeError('Cannot convert class "${gdClass.name}" to int.');

  @override
  double toFloat() =>
      throw GDRuntimeError('Cannot convert class "${gdClass.name}" to float.');

  @override
  String toGDString() => '<Class:${gdClass.name}>';

  @override
  Object? toDart() => gdClass;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GDClassValue && gdClass == other.gdClass);

  @override
  int get hashCode => gdClass.hashCode;

  @override
  int compareTo(GDValue other) => 0;
}

// =============================================================================
// GDIteratorValue
// =============================================================================

/// Wraps a loop iterator into a [GDValue] for virtual machine loops.
final class GDIteratorValue extends GDValue {
  final Object iterator;

  const GDIteratorValue(this.iterator);

  @override
  String get typeName => 'Iterator';

  @override
  bool get isTruthy => true;

  @override
  int toInt() => 0;

  @override
  double toFloat() => 0.0;

  @override
  String toGDString() => '<Iterator>';

  @override
  Object? toDart() => iterator;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(iterator);

  @override
  int compareTo(GDValue other) => 0;
}

/// Type alias matching [GDObject] for VM instance values.
typedef GDInstanceValue = GDObject;

