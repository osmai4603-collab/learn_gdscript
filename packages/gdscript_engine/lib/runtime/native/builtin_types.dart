import 'dart:math' as math;

import '../../core/gdscript_error.dart';
import '../../objects/gd_callable.dart';
import '../../objects/gd_string_helpers.dart';
import '../value.dart';

/// Implements methods for GDScript built-in types (String, Array, Dictionary, Int, Float).
class BuiltinTypes {
  static final math.Random _random = math.Random();

  /// Resolves and returns a method callable for property [prop] on [target],
  /// or returns null if [prop] is not a recognized built-in method.
  static GDCallableValue? resolveMethod(GDValue target, String prop) {
    if (target is GDString) {
      final method = _resolveStringMethod(target, prop);
      if (method != null) return GDCallableValue(method);
    } else if (target is GDArray) {
      final method = _resolveArrayMethod(target, prop);
      if (method != null) return GDCallableValue(method);
    } else if (target is GDDictionary) {
      final method = _resolveDictionaryMethod(target, prop);
      if (method != null) return GDCallableValue(method);
    } else if (target is GDFloat || target is GDInt) {
      final method = _resolveNumericMethod(target, prop);
      if (method != null) return GDCallableValue(method);
    }
    return null;
  }

  // ===========================================================================
  // String Methods
  // ===========================================================================

  static GDNativeCallable? _resolveStringMethod(GDString target, String prop) {
    final str = target.value;
    switch (prop) {
      case 'length':
      case 'size':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDInt(str.length),
        );
      case 'is_empty':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(str.isEmpty),
        );
      case 'substr':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            if (args.isEmpty) {
              throw GDRuntimeError('substr() requires at least 1 argument.');
            }
            final start = args[0].toInt();
            final len = args.length > 1 ? args[1].toInt() : null;
            return GDString(GDStringHelpers.substr(str, start, len));
          },
        );
      case 'find':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            if (args.isEmpty) {
              throw GDRuntimeError('find() requires at least 1 argument.');
            }
            final what = args[0].toGDString();
            final from = args.length > 1 ? args[1].toInt() : 0;
            return GDInt(GDStringHelpers.find(str, what, from));
          },
        );
      case 'rfind':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            if (args.isEmpty) {
              throw GDRuntimeError('rfind() requires at least 1 argument.');
            }
            final what = args[0].toGDString();
            final from = args.length > 1 ? args[1].toInt() : null;
            return GDInt(GDStringHelpers.rfind(str, what, from));
          },
        );
      case 'replace':
        return GDNativeCallable(
          name: prop,
          arity: 2,
          callback: (args) => GDString(
            GDStringHelpers.replace(
              str,
              args[0].toGDString(),
              args[1].toGDString(),
            ),
          ),
        );
      case 'split':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final delimiter = args.isNotEmpty ? args[0].toGDString() : '';
            final allowEmpty = args.length > 1 ? args[1].isTruthy : true;
            final maxsplit = args.length > 2 ? args[2].toInt() : 0;
            final parts = GDStringHelpers.split(str, delimiter, allowEmpty);
            if (maxsplit > 0 && parts.length > maxsplit + 1) {
              final limited = parts.sublist(0, maxsplit);
              limited.add(parts.sublist(maxsplit).join(delimiter));
              return GDArray(limited.map((s) => GDString(s)).toList());
            }
            return GDArray(parts.map((s) => GDString(s)).toList());
          },
        );
      case 'rsplit':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final delimiter = args.isNotEmpty ? args[0].toGDString() : '';
            final allowEmpty = args.length > 1 ? args[1].isTruthy : true;
            final parts = GDStringHelpers.split(str, delimiter, allowEmpty);
            return GDArray(parts.map((s) => GDString(s)).toList());
          },
        );
      case 'join':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            if (args[0] is! GDArray) {
              throw GDRuntimeError('join() argument must be an Array.');
            }
            final arr = (args[0] as GDArray).elements;
            return GDString(arr.map((e) => e.toGDString()).join(str));
          },
        );
      case 'to_upper':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDString(GDStringHelpers.toUpper(str)),
        );
      case 'to_lower':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDString(GDStringHelpers.toLower(str)),
        );
      case 'strip_edges':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final left = args.isNotEmpty ? args[0].isTruthy : true;
            final right = args.length > 1 ? args[1].isTruthy : true;
            var res = str;
            if (left) res = GDStringHelpers.stripStart(res);
            if (right) res = GDStringHelpers.stripEnd(res);
            return GDString(res);
          },
        );
      case 'strip_escapes':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDString(
            str.replaceAll(RegExp(r'[\r\n\t]'), ''),
          ),
        );
      case 'begins_with':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDBool(
            GDStringHelpers.beginsWith(str, args[0].toGDString()),
          ),
        );
      case 'ends_with':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDBool(
            GDStringHelpers.endsWith(str, args[0].toGDString()),
          ),
        );
      case 'contains':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDBool(
            GDStringHelpers.contains(str, args[0].toGDString()),
          ),
        );
      case 'repeat':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDString(
            GDStringHelpers.repeat(str, args[0].toInt()),
          ),
        );
      case 'pad_zeros':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDString(
            GDStringHelpers.padZeros(str, args[0].toInt()),
          ),
        );
      case 'lpad':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final len = args[0].toInt();
            final char = args.length > 1 ? args[1].toGDString() : ' ';
            return GDString(GDStringHelpers.lpad(str, len, char));
          },
        );
      case 'rpad':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final len = args[0].toInt();
            final char = args.length > 1 ? args[1].toGDString() : ' ';
            return GDString(GDStringHelpers.rpad(str, len, char));
          },
        );
      case 'count':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final what = args[0].toGDString();
            if (what.isEmpty) return const GDInt(0);
            int count = 0;
            int pos = 0;
            while ((pos = str.indexOf(what, pos)) != -1) {
              count++;
              pos += what.length;
            }
            return GDInt(count);
          },
        );
      case 'countn':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final what = args[0].toGDString().toLowerCase();
            final lower = str.toLowerCase();
            if (what.isEmpty) return const GDInt(0);
            int count = 0;
            int pos = 0;
            while ((pos = lower.indexOf(what, pos)) != -1) {
              count++;
              pos += what.length;
            }
            return GDInt(count);
          },
        );
      case 'capitalize':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDString(GDStringHelpers.capitalize(str)),
        );
      case 'to_pascal_case':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            final parts = str.split(RegExp(r'[_\s]+'));
            return GDString(parts.map((p) => GDStringHelpers.capitalize(p.toLowerCase())).join());
          },
        );
      case 'to_camel_case':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            final parts = str.split(RegExp(r'[_\s]+'));
            if (parts.isEmpty) return const GDString('');
            final first = parts[0].toLowerCase();
            final rest = parts.skip(1).map((p) => GDStringHelpers.capitalize(p.toLowerCase())).join();
            return GDString('$first$rest');
          },
        );
      case 'to_snake_case':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            final converted = str.replaceAllMapped(
              RegExp(r'([a-z0-9])([A-Z])'),
              (m) => '${m[1]}_${m[2]}',
            );
            return GDString(converted.toLowerCase().replaceAll(RegExp(r'[-\s]+'), '_'));
          },
        );
      case 'hash':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDInt(str.hashCode),
        );
      case 'is_valid_int':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(int.tryParse(str) != null),
        );
      case 'is_valid_float':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(double.tryParse(str) != null),
        );
      case 'to_int':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDInt(int.tryParse(str) ?? 0),
        );
      case 'to_float':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDFloat(double.tryParse(str) ?? 0.0),
        );
      case 'format':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            var formatted = str;
            final arg = args[0];
            if (arg is GDDictionary) {
              for (final entry in arg.elements.entries) {
                final key = entry.key.toGDString();
                final val = entry.value.toGDString();
                formatted = formatted.replaceAll('{$key}', val);
              }
            } else if (arg is GDArray) {
              for (var i = 0; i < arg.elements.length; i++) {
                formatted = formatted.replaceAll('{$i}', arg.elements[i].toGDString());
              }
            }
            return GDString(formatted);
          },
        );
      default:
        return null;
    }
  }

  // ===========================================================================
  // Array Methods
  // ===========================================================================

  static GDNativeCallable? _resolveArrayMethod(GDArray target, String prop) {
    final list = target.elements;
    switch (prop) {
      case 'size':
      case 'length':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDInt(list.length),
        );
      case 'is_empty':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(list.isEmpty),
        );
      case 'clear':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            list.clear();
            return GDNull.instance;
          },
        );
      case 'hash':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDInt(target.hashCode),
        );
      case 'duplicate':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final deep = args.isNotEmpty && args[0].isTruthy;
            if (!deep) return GDArray([...list]);
            GDValue clone(GDValue val) {
              if (val is GDArray) {
                return GDArray(val.elements.map(clone).toList());
              }
              if (val is GDDictionary) {
                return GDDictionary(
                  val.elements.map((k, v) => MapEntry(k, clone(v))),
                );
              }
              return val;
            }
            return GDArray(list.map(clone).toList());
          },
        );
      case 'slice':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            if (args.isEmpty) return GDArray([...list]);
            final len = list.length;
            var begin = args[0].toInt();
            if (begin < 0) begin += len;
            begin = begin.clamp(0, len);

            var end = args.length > 1 ? args[1].toInt() : len;
            if (end < 0) end += len;
            end = end.clamp(0, len);

            final step = args.length > 2 ? args[2].toInt() : 1;
            if (step == 0) throw GDRuntimeError('slice() step cannot be zero.');

            final result = <GDValue>[];
            if (step > 0) {
              for (var i = begin; i < end; i += step) {
                result.add(list[i]);
              }
            } else {
              for (var i = begin; i > end; i += step) {
                result.add(list[i]);
              }
            }
            return GDArray(result);
          },
        );
      case 'append':
      case 'push_back':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            list.add(args[0]);
            return GDNull.instance;
          },
        );
      case 'push_front':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            list.insert(0, args[0]);
            return GDNull.instance;
          },
        );
      case 'pop_back':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => list.isEmpty ? GDNull.instance : list.removeLast(),
        );
      case 'pop_front':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => list.isEmpty ? GDNull.instance : list.removeAt(0),
        );
      case 'pop_at':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            var pos = args[0].toInt();
            if (pos < 0) pos += list.length;
            if (pos < 0 || pos >= list.length) return GDNull.instance;
            return list.removeAt(pos);
          },
        );
      case 'insert':
        return GDNativeCallable(
          name: prop,
          arity: 2,
          callback: (args) {
            var pos = args[0].toInt();
            if (pos < 0) pos += list.length;
            pos = pos.clamp(0, list.length);
            list.insert(pos, args[1]);
            return GDNull.instance;
          },
        );
      case 'erase':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            list.remove(args[0]);
            return GDNull.instance;
          },
        );
      case 'remove_at':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            var pos = args[0].toInt();
            if (pos < 0) pos += list.length;
            if (pos < 0 || pos >= list.length) {
              throw GDRuntimeError('Array index $pos out of bounds (size ${list.length}).');
            }
            list.removeAt(pos);
            return GDNull.instance;
          },
        );
      case 'has':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDBool(list.contains(args[0])),
        );
      case 'count':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            final target = args[0];
            return GDInt(list.where((e) => e == target).length);
          },
        );
      case 'find':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final what = args[0];
            final from = args.length > 1 ? args[1].toInt() : 0;
            return GDInt(list.indexOf(what, from < 0 ? 0 : from));
          },
        );
      case 'rfind':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final what = args[0];
            final start = args.length > 1 ? args[1].toInt() : (list.length - 1);
            return GDInt(list.lastIndexOf(what, start < 0 ? null : start));
          },
        );
      case 'reverse':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            final reversed = list.reversed.toList();
            list.clear();
            list.addAll(reversed);
            return GDNull.instance;
          },
        );
      case 'sort':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            list.sort((a, b) {
              if (a is GDInt && b is GDInt) return a.value.compareTo(b.value);
              if (a is GDFloat && b is GDFloat) return a.value.compareTo(b.value);
              if (a is GDString && b is GDString) return a.value.compareTo(b.value);
              return a.toFloat().compareTo(b.toFloat());
            });
            return GDNull.instance;
          },
        );
      case 'sort_custom':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            if (args[0] is! GDCallableValue) {
              throw GDRuntimeError('sort_custom expects a Callable.');
            }
            final callable = (args[0] as GDCallableValue).callable;
            list.sort((a, b) {
              final res = callable.call([a, b]);
              return res.isTruthy ? -1 : 1;
            });
            return GDNull.instance;
          },
        );
      case 'shuffle':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            list.shuffle(_random);
            return GDNull.instance;
          },
        );
      case 'bsearch':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final value = args[0];
            final before = args.length > 1 ? args[1].isTruthy : true;
            var low = 0;
            var high = list.length;
            while (low < high) {
              final mid = (low + high) ~/ 2;
              final midVal = list[mid];
              final cmp = midVal.toFloat().compareTo(value.toFloat());
              if (cmp < 0 || (!before && cmp == 0)) {
                low = mid + 1;
              } else {
                high = mid;
              }
            }
            return GDInt(low);
          },
        );
      case 'fill':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            for (var i = 0; i < list.length; i++) {
              list[i] = args[0];
            }
            return GDNull.instance;
          },
        );
      case 'max':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            if (list.isEmpty) throw GDRuntimeError('Cannot call max() on empty Array.');
            var mx = list[0];
            for (var i = 1; i < list.length; i++) {
              if (list[i].toFloat() > mx.toFloat()) mx = list[i];
            }
            return mx;
          },
        );
      case 'min':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            if (list.isEmpty) throw GDRuntimeError('Cannot call min() on empty Array.');
            var mn = list[0];
            for (var i = 1; i < list.length; i++) {
              if (list[i].toFloat() < mn.toFloat()) mn = list[i];
            }
            return mn;
          },
        );
      case 'front':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => list.isEmpty ? GDNull.instance : list.first,
        );
      case 'back':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => list.isEmpty ? GDNull.instance : list.last,
        );
      case 'pick_random':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            if (list.isEmpty) throw GDRuntimeError('Cannot pick_random() from empty Array.');
            return list[_random.nextInt(list.length)];
          },
        );
      case 'filter':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            if (args[0] is! GDCallableValue) {
              throw GDRuntimeError('filter() expects a Callable.');
            }
            final callable = (args[0] as GDCallableValue).callable;
            final filtered = list.where((item) => callable.call([item]).isTruthy).toList();
            return GDArray(filtered);
          },
        );
      case 'map':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            if (args[0] is! GDCallableValue) {
              throw GDRuntimeError('map() expects a Callable.');
            }
            final callable = (args[0] as GDCallableValue).callable;
            final mapped = list.map((item) => callable.call([item])).toList();
            return GDArray(mapped);
          },
        );
      case 'reduce':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            if (args.isEmpty || args[0] is! GDCallableValue) {
              throw GDRuntimeError('reduce() expects at least a Callable.');
            }
            if (list.isEmpty && args.length < 2) {
              throw GDRuntimeError('Cannot reduce empty array without initial accumulator.');
            }
            final callable = (args[0] as GDCallableValue).callable;
            var accum = args.length > 1 ? args[1] : list[0];
            final startIdx = args.length > 1 ? 0 : 1;
            for (var i = startIdx; i < list.length; i++) {
              accum = callable.call([accum, list[i]]);
            }
            return accum;
          },
        );
      case 'any':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            if (args[0] is! GDCallableValue) {
              throw GDRuntimeError('any() expects a Callable.');
            }
            final callable = (args[0] as GDCallableValue).callable;
            for (final item in list) {
              if (callable.call([item]).isTruthy) return GDBool.trueValue;
            }
            return GDBool.falseValue;
          },
        );
      case 'all':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            if (args[0] is! GDCallableValue) {
              throw GDRuntimeError('all() expects a Callable.');
            }
            final callable = (args[0] as GDCallableValue).callable;
            for (final item in list) {
              if (!callable.call([item]).isTruthy) return GDBool.falseValue;
            }
            return GDBool.trueValue;
          },
        );
      default:
        return null;
    }
  }

  // ===========================================================================
  // Dictionary Methods
  // ===========================================================================

  static GDNativeCallable? _resolveDictionaryMethod(GDDictionary target, String prop) {
    final map = target.elements;
    switch (prop) {
      case 'size':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDInt(map.length),
        );
      case 'is_empty':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(map.isEmpty),
        );
      case 'clear':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) {
            map.clear();
            return GDNull.instance;
          },
        );
      case 'hash':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDInt(target.hashCode),
        );
      case 'duplicate':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (_) => GDDictionary(Map.of(map)),
        );
      case 'keys':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDArray(map.keys.toList()),
        );
      case 'values':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDArray(map.values.toList()),
        );
      case 'has':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDBool(map.containsKey(args[0])),
        );
      case 'has_all':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            if (args[0] is! GDArray) {
              throw GDRuntimeError('has_all() expects an Array.');
            }
            final keys = (args[0] as GDArray).elements;
            for (final k in keys) {
              if (!map.containsKey(k)) return GDBool.falseValue;
            }
            return GDBool.trueValue;
          },
        );
      case 'get':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            final key = args[0];
            final defaultVal = args.length > 1 ? args[1] : GDNull.instance;
            return map[key] ?? defaultVal;
          },
        );
      case 'erase':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) => GDBool(map.remove(args[0]) != null),
        );
      case 'find_key':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            final val = args[0];
            for (final entry in map.entries) {
              if (entry.value == val) return entry.key;
            }
            return GDNull.instance;
          },
        );
      case 'merge':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            if (args.isEmpty || args[0] is! GDDictionary) {
              throw GDRuntimeError('merge() expects a Dictionary.');
            }
            final other = (args[0] as GDDictionary).elements;
            final overwrite = args.length > 1 && args[1].isTruthy;
            for (final entry in other.entries) {
              if (overwrite || !map.containsKey(entry.key)) {
                map[entry.key] = entry.value;
              }
            }
            return GDNull.instance;
          },
        );
      case 'merged':
        return GDNativeCallable(
          name: prop,
          arity: -1,
          callback: (args) {
            if (args.isEmpty || args[0] is! GDDictionary) {
              throw GDRuntimeError('merged() expects a Dictionary.');
            }
            final result = Map<GDValue, GDValue>.of(map);
            final other = (args[0] as GDDictionary).elements;
            final overwrite = args.length > 1 && args[1].isTruthy;
            for (final entry in other.entries) {
              if (overwrite || !result.containsKey(entry.key)) {
                result[entry.key] = entry.value;
              }
            }
            return GDDictionary(result);
          },
        );
      default:
        return null;
    }
  }

  // ===========================================================================
  // Numeric Methods (Int & Float)
  // ===========================================================================

  static GDNativeCallable? _resolveNumericMethod(GDValue target, String prop) {
    final val = target.toFloat();
    switch (prop) {
      case 'is_nan':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(val.isNaN),
        );
      case 'is_inf':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(val.isInfinite),
        );
      case 'is_zero_approx':
        return GDNativeCallable(
          name: prop,
          arity: 0,
          callback: (_) => GDBool(val.abs() <= 0.00001),
        );
      case 'is_equal_approx':
        return GDNativeCallable(
          name: prop,
          arity: 1,
          callback: (args) {
            final b = args[0].toFloat();
            if (val == b) return GDBool.trueValue;
            final diff = (val - b).abs();
            final tolerance = 0.00001 * math.max(1.0, math.max(val.abs(), b.abs()));
            return GDBool(diff <= tolerance);
          },
        );
      default:
        return null;
    }
  }
}
