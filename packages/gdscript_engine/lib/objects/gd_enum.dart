import '../core/gdscript_error.dart';
import '../runtime/value.dart';

/// Represents a GDScript enum type and its constituent key-value mappings.
class GDEnum {
  final String name;
  final Map<String, int> entries;

  const GDEnum({required this.name, required this.entries});

  /// Total number of enum constants.
  int get size => entries.length;

  /// Returns list of enum key names.
  List<String> keys() => entries.keys.toList();

  /// Returns list of integer enum values.
  List<int> values() => entries.values.toList();

  /// Checks if [key] is defined in this enum.
  bool has(String key) => entries.containsKey(key);

  /// Retrieves the integer value associated with [key].
  int get(String key) {
    final val = entries[key];
    if (val == null) {
      throw GDRuntimeError('Enum "$name" does not contain key "$key".');
    }
    return val;
  }

  /// Finds the key name corresponding to an integer [value], or null.
  String? findKey(int value) {
    for (final entry in entries.entries) {
      if (entry.value == value) return entry.key;
    }
    return null;
  }

  /// Converts this enum into a [GDDictionary].
  GDDictionary toDictionary() {
    final dict = GDDictionary();
    for (final entry in entries.entries) {
      dict.set(GDString(entry.key), GDInt(entry.value));
    }
    return dict;
  }

  @override
  String toString() => '<Enum:$name ${entries.keys.join(", ")}>';
}
