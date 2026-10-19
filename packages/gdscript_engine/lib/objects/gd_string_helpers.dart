import 'dart:math' as math;

/// Utility class implementing GDScript 4 string functions.
class GDStringHelpers {
  /// Extracts a substring of [length] characters starting at [start].
  static String substr(String str, int start, [int? length]) {
    final len = str.length;
    var s = start < 0 ? len + start : start;
    s = s.clamp(0, len);
    if (length == null) {
      return str.substring(s);
    }
    final actualLen = length < 0 ? 0 : length;
    final end = math.min(len, s + actualLen);
    return str.substring(s, end);
  }

  /// Finds the first occurrence of [what] starting from index [from].
  static int find(String str, String what, [int from = 0]) {
    if (from < 0 || from > str.length) return -1;
    return str.indexOf(what, from);
  }

  /// Finds the last occurrence of [what] before or at index [from].
  static int rfind(String str, String what, [int? from]) {
    final start = from ?? (str.length - 1);
    if (start < 0) return -1;
    final actualFrom = math.min(str.length - 1, start);
    return str.lastIndexOf(what, actualFrom);
  }

  /// Replaces occurrences of [what] with [forWhat].
  static String replace(String str, String what, String forWhat) =>
      str.replaceAll(what, forWhat);

  /// Splits string by [delimiter].
  static List<String> split(
    String str, [
    String delimiter = '',
    bool allowEmpty = true,
  ]) {
    if (delimiter.isEmpty) {
      return str.split('');
    }
    final parts = str.split(delimiter);
    if (!allowEmpty) {
      return parts.where((p) => p.isNotEmpty).toList();
    }
    return parts;
  }

  /// Converts string to upper-case.
  static String toUpper(String str) => str.toUpperCase();

  /// Converts string to lower-case.
  static String toLower(String str) => str.toLowerCase();

  /// Strips leading and trailing whitespace.
  static String stripEdges(String str) => str.trim();

  /// Strips leading whitespace.
  static String stripStart(String str) => str.trimLeft();

  /// Strips trailing whitespace.
  static String stripEnd(String str) => str.trimRight();

  /// Checks if string begins with [prefix].
  static bool beginsWith(String str, String prefix) => str.startsWith(prefix);

  /// Checks if string ends with [suffix].
  static bool endsWith(String str, String suffix) => str.endsWith(suffix);

  /// Checks if string contains [what].
  static bool contains(String str, String what) => str.contains(what);

  /// Repeats string [count] times.
  static String repeat(String str, int count) =>
      count > 0 ? str * count : '';

  /// Pads numeric string with leading zeros up to [digits] length.
  static String padZeros(String str, int digits) {
    if (str.length >= digits) return str;
    final isNegative = str.startsWith('-');
    final digitsPart = isNegative ? str.substring(1) : str;
    final needed = digits - digitsPart.length;
    if (needed <= 0) return str;
    final padded = '${'0' * needed}$digitsPart';
    return isNegative ? '-$padded' : padded;
  }

  /// Pads string on the left with [character] up to [minLength].
  static String lpad(String str, int minLength, [String character = ' ']) {
    if (str.length >= minLength || character.isEmpty) return str;
    final diff = minLength - str.length;
    final padStr = character * ((diff / character.length).ceil());
    return '${padStr.substring(0, diff)}$str';
  }

  /// Pads string on the right with [character] up to [minLength].
  static String rpad(String str, int minLength, [String character = ' ']) {
    if (str.length >= minLength || character.isEmpty) return str;
    final diff = minLength - str.length;
    final padStr = character * ((diff / character.length).ceil());
    return '$str${padStr.substring(0, diff)}';
  }

  /// Capitalizes string (first letter upper, rest preserved/lowered).
  static String capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }
}
