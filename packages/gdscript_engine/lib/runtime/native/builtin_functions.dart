import 'dart:math' as math;

import '../../core/gdscript_error.dart';
import '../value.dart';
import 'native_function.dart';

/// Implements standard built-in functions available in GDScript 4 (@GDScript and @GlobalScope).
class BuiltinFunctions {
  static math.Random _random = math.Random();

  /// Sets seed for the global pseudo-random number generator.
  static void setSeed(int seed) {
    _random = math.Random(seed);
  }

  /// Randomizes the global seed using current timestamp.
  static void randomize() {
    _random = math.Random(DateTime.now().microsecondsSinceEpoch);
  }

  /// Returns all built-in function descriptors.
  static List<NativeFunction> getDefinitions({
    void Function(String text)? onPrint,
    List<String>? stdoutHistory,
    void Function(String warning)? onWarning,
    void Function(String error)? onError,
  }) {
    return [
      // =======================================================================
      // I/O & Diagnostics
      // =======================================================================
      NativeFunction(
        name: 'print',
        minArity: 0,
        maxArity: -1,
        callback: (args) {
          final text = args.map((a) => a.toGDString()).join(' ');
          stdoutHistory?.add(text);
          onPrint?.call(text);
          return GDNull.instance;
        },
      ),
      NativeFunction(
        name: 'prints',
        minArity: 0,
        maxArity: -1,
        callback: (args) {
          final text = args.map((a) => a.toGDString()).join(' ');
          stdoutHistory?.add(text);
          onPrint?.call(text);
          return GDNull.instance;
        },
      ),
      NativeFunction(
        name: 'printt',
        minArity: 0,
        maxArity: -1,
        callback: (args) {
          final text = args.map((a) => a.toGDString()).join('\t');
          stdoutHistory?.add(text);
          onPrint?.call(text);
          return GDNull.instance;
        },
      ),
      NativeFunction(
        name: 'printraw',
        minArity: 0,
        maxArity: -1,
        callback: (args) {
          final text = args.map((a) => a.toGDString()).join();
          stdoutHistory?.add(text);
          onPrint?.call(text);
          return GDNull.instance;
        },
      ),
      NativeFunction(
        name: 'printerr',
        minArity: 0,
        maxArity: -1,
        callback: (args) {
          final text = args.map((a) => a.toGDString()).join(' ');
          stdoutHistory?.add('ERROR: $text');
          onError?.call(text);
          return GDNull.instance;
        },
      ),
      NativeFunction(
        name: 'print_rich',
        minArity: 0,
        maxArity: -1,
        callback: (args) {
          final text = args.map((a) => a.toGDString()).join(' ');
          stdoutHistory?.add(text);
          onPrint?.call(text);
          return GDNull.instance;
        },
      ),
      NativeFunction(
        name: 'print_debug',
        minArity: 0,
        maxArity: -1,
        callback: (args) {
          final text = args.map((a) => a.toGDString()).join(' ');
          stdoutHistory?.add('DEBUG: $text');
          onPrint?.call('DEBUG: $text');
          return GDNull.instance;
        },
      ),
      NativeFunction.fixed(
        name: 'push_warning',
        arity: 1,
        callback: (args) {
          final msg = args[0].toGDString();
          stdoutHistory?.add('WARNING: $msg');
          onWarning?.call(msg);
          return GDNull.instance;
        },
      ),
      NativeFunction.fixed(
        name: 'push_error',
        arity: 1,
        callback: (args) {
          final msg = args[0].toGDString();
          stdoutHistory?.add('ERROR: $msg');
          onError?.call(msg);
          return GDNull.instance;
        },
      ),

      // =======================================================================
      // Type Conversions & Checks
      // =======================================================================
      NativeFunction.fixed(
        name: 'str',
        arity: 1,
        callback: (args) => GDString(args[0].toGDString()),
      ),
      NativeFunction.fixed(
        name: 'int',
        arity: 1,
        callback: (args) => GDInt(args[0].toInt()),
      ),
      NativeFunction.fixed(
        name: 'float',
        arity: 1,
        callback: (args) => GDFloat(args[0].toFloat()),
      ),
      NativeFunction.fixed(
        name: 'bool',
        arity: 1,
        callback: (args) => GDBool(args[0].isTruthy),
      ),
      NativeFunction.fixed(
        name: 'typeof',
        arity: 1,
        callback: (args) => GDString(args[0].typeName),
      ),
      NativeFunction.fixed(
        name: 'type_string',
        arity: 1,
        callback: (args) => GDString(args[0].typeName),
      ),
      NativeFunction.fixed(
        name: 'char',
        arity: 1,
        callback: (args) => GDString(String.fromCharCode(args[0].toInt())),
      ),
      NativeFunction.fixed(
        name: 'len',
        arity: 1,
        callback: (args) {
          final val = args[0];
          if (val is GDArray) return GDInt(val.elements.length);
          if (val is GDDictionary) return GDInt(val.elements.length);
          if (val is GDString) return GDInt(val.value.length);
          throw GDRuntimeError(
            'len() expects Array, Dictionary, or String, but got "${val.typeName}".',
          );
        },
      ),
      NativeFunction(
        name: 'range',
        minArity: 1,
        maxArity: 3,
        callback: (args) {
          int start = 0;
          int end = 0;
          int step = 1;

          if (args.length == 1) {
            end = args[0].toInt();
          } else if (args.length == 2) {
            start = args[0].toInt();
            end = args[1].toInt();
          } else {
            start = args[0].toInt();
            end = args[1].toInt();
            step = args[2].toInt();
          }

          if (step == 0) {
            throw GDRuntimeError('range() step cannot be zero.');
          }

          final items = <GDValue>[];
          if (step > 0) {
            for (var i = start; i < end; i += step) {
              items.add(GDInt(i));
            }
          } else {
            for (var i = start; i > end; i += step) {
              items.add(GDInt(i));
            }
          }
          return GDArray(items);
        },
      ),
      NativeFunction.fixed(
        name: 'hash',
        arity: 1,
        callback: (args) => GDInt(args[0].hashCode),
      ),

      // =======================================================================
      // Math: Basic & Arithmetic
      // =======================================================================
      NativeFunction.fixed(
        name: 'abs',
        arity: 1,
        callback: (args) {
          final v = args[0];
          if (v is GDInt) return GDInt(v.value.abs());
          if (v is GDFloat) return GDFloat(v.value.abs());
          throw GDRuntimeError('abs() requires int or float.');
        },
      ),
      NativeFunction.fixed(
        name: 'sign',
        arity: 1,
        callback: (args) {
          final n = args[0].toFloat();
          if (n > 0) return const GDInt(1);
          if (n < 0) return const GDInt(-1);
          return const GDInt(0);
        },
      ),
      NativeFunction.fixed(
        name: 'signi',
        arity: 1,
        callback: (args) {
          final n = args[0].toInt();
          if (n > 0) return const GDInt(1);
          if (n < 0) return const GDInt(-1);
          return const GDInt(0);
        },
      ),
      NativeFunction.fixed(
        name: 'signf',
        arity: 1,
        callback: (args) {
          final n = args[0].toFloat();
          if (n > 0) return const GDFloat(1.0);
          if (n < 0) return const GDFloat(-1.0);
          return const GDFloat(0.0);
        },
      ),
      NativeFunction(
        name: 'min',
        minArity: 1,
        maxArity: -1,
        callback: (args) {
          if (args.length == 1 && args[0] is GDArray) {
            final arr = (args[0] as GDArray).elements;
            if (arr.isEmpty) throw GDRuntimeError('Cannot find min of empty array.');
            var lowest = arr[0];
            for (var i = 1; i < arr.length; i++) {
              if (arr[i].toFloat() < lowest.toFloat()) lowest = arr[i];
            }
            return lowest;
          }
          if (args.length == 1) return args[0];
          var lowest = args[0];
          for (var i = 1; i < args.length; i++) {
            if (args[i].toFloat() < lowest.toFloat()) lowest = args[i];
          }
          return lowest;
        },
      ),
      NativeFunction.fixed(
        name: 'mini',
        arity: 2,
        callback: (args) => GDInt(math.min(args[0].toInt(), args[1].toInt())),
      ),
      NativeFunction.fixed(
        name: 'minf',
        arity: 2,
        callback: (args) => GDFloat(math.min(args[0].toFloat(), args[1].toFloat())),
      ),
      NativeFunction(
        name: 'max',
        minArity: 1,
        maxArity: -1,
        callback: (args) {
          if (args.length == 1 && args[0] is GDArray) {
            final arr = (args[0] as GDArray).elements;
            if (arr.isEmpty) throw GDRuntimeError('Cannot find max of empty array.');
            var highest = arr[0];
            for (var i = 1; i < arr.length; i++) {
              if (arr[i].toFloat() > highest.toFloat()) highest = arr[i];
            }
            return highest;
          }
          if (args.length == 1) return args[0];
          var highest = args[0];
          for (var i = 1; i < args.length; i++) {
            if (args[i].toFloat() > highest.toFloat()) highest = args[i];
          }
          return highest;
        },
      ),
      NativeFunction.fixed(
        name: 'maxi',
        arity: 2,
        callback: (args) => GDInt(math.max(args[0].toInt(), args[1].toInt())),
      ),
      NativeFunction.fixed(
        name: 'maxf',
        arity: 2,
        callback: (args) => GDFloat(math.max(args[0].toFloat(), args[1].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'clamp',
        arity: 3,
        callback: (args) {
          final v = args[0].toFloat();
          final mn = args[1].toFloat();
          final mx = args[2].toFloat();
          return GDFloat(v.clamp(mn, mx));
        },
      ),
      NativeFunction.fixed(
        name: 'clampi',
        arity: 3,
        callback: (args) {
          final v = args[0].toInt();
          final mn = args[1].toInt();
          final mx = args[2].toInt();
          return GDInt(v.clamp(mn, mx));
        },
      ),
      NativeFunction.fixed(
        name: 'clampf',
        arity: 3,
        callback: (args) {
          final v = args[0].toFloat();
          final mn = args[1].toFloat();
          final mx = args[2].toFloat();
          return GDFloat(v.clamp(mn, mx));
        },
      ),
      NativeFunction.fixed(
        name: 'round',
        arity: 1,
        callback: (args) => GDFloat(args[0].toFloat().roundToDouble()),
      ),
      NativeFunction.fixed(
        name: 'roundi',
        arity: 1,
        callback: (args) => GDInt(args[0].toFloat().round()),
      ),
      NativeFunction.fixed(
        name: 'floor',
        arity: 1,
        callback: (args) => GDFloat(args[0].toFloat().floorToDouble()),
      ),
      NativeFunction.fixed(
        name: 'floori',
        arity: 1,
        callback: (args) => GDInt(args[0].toFloat().floor()),
      ),
      NativeFunction.fixed(
        name: 'ceil',
        arity: 1,
        callback: (args) => GDFloat(args[0].toFloat().ceilToDouble()),
      ),
      NativeFunction.fixed(
        name: 'ceili',
        arity: 1,
        callback: (args) => GDInt(args[0].toFloat().ceil()),
      ),
      NativeFunction.fixed(
        name: 'sqrt',
        arity: 1,
        callback: (args) {
          final v = args[0].toFloat();
          if (v < 0) return const GDFloat(double.nan);
          return GDFloat(math.sqrt(v));
        },
      ),
      NativeFunction.fixed(
        name: 'pow',
        arity: 2,
        callback: (args) => GDFloat(math.pow(args[0].toFloat(), args[1].toFloat()).toDouble()),
      ),
      NativeFunction.fixed(
        name: 'exp',
        arity: 1,
        callback: (args) => GDFloat(math.exp(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'log',
        arity: 1,
        callback: (args) => GDFloat(math.log(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'snapped',
        arity: 2,
        callback: (args) {
          final v = args[0].toFloat();
          final step = args[1].toFloat();
          if (step == 0) return GDFloat(v);
          return GDFloat((v / step).round() * step);
        },
      ),
      NativeFunction.fixed(
        name: 'snappedf',
        arity: 2,
        callback: (args) {
          final v = args[0].toFloat();
          final step = args[1].toFloat();
          if (step == 0) return GDFloat(v);
          return GDFloat((v / step).round() * step);
        },
      ),
      NativeFunction.fixed(
        name: 'snappedi',
        arity: 2,
        callback: (args) {
          final v = args[0].toInt();
          final step = args[1].toInt();
          if (step == 0) return GDInt(v);
          return GDInt(((v / step).round()) * step);
        },
      ),
      NativeFunction.fixed(
        name: 'posmod',
        arity: 2,
        callback: (args) {
          final x = args[0].toInt();
          final y = args[1].toInt();
          if (y == 0) throw GDRuntimeError('Division by zero in posmod.');
          final res = ((x % y) + y) % y;
          return GDInt(res);
        },
      ),
      NativeFunction.fixed(
        name: 'fposmod',
        arity: 2,
        callback: (args) {
          final x = args[0].toFloat();
          final y = args[1].toFloat();
          if (y == 0) throw GDRuntimeError('Division by zero in fposmod.');
          final res = ((x % y) + y) % y;
          return GDFloat(res);
        },
      ),
      NativeFunction.fixed(
        name: 'wrap',
        arity: 3,
        callback: (args) {
          final val = args[0].toFloat();
          final min = args[1].toFloat();
          final max = args[2].toFloat();
          final range = max - min;
          if (range == 0) return GDFloat(min);
          final res = val - (range * ((val - min) / range).floor());
          return GDFloat(res);
        },
      ),
      NativeFunction.fixed(
        name: 'wrapf',
        arity: 3,
        callback: (args) {
          final val = args[0].toFloat();
          final min = args[1].toFloat();
          final max = args[2].toFloat();
          final range = max - min;
          if (range == 0) return GDFloat(min);
          final res = val - (range * ((val - min) / range).floor());
          return GDFloat(res);
        },
      ),
      NativeFunction.fixed(
        name: 'wrapi',
        arity: 3,
        callback: (args) {
          final val = args[0].toInt();
          final min = args[1].toInt();
          final max = args[2].toInt();
          final range = max - min;
          if (range == 0) return GDInt(min);
          final res = val - (range * ((val - min) / range).floor());
          return GDInt(res);
        },
      ),
      NativeFunction.fixed(
        name: 'pingpong',
        arity: 2,
        callback: (args) {
          final val = args[0].toFloat();
          final length = args[1].toFloat();
          if (length == 0.0) return const GDFloat(0.0);
          var v = val % (2 * length);
          if (v < 0) v += 2 * length;
          final res = length - (v - length).abs();
          return GDFloat(res);
        },
      ),
      NativeFunction.fixed(
        name: 'nearest_po2',
        arity: 1,
        callback: (args) {
          final val = args[0].toInt();
          if (val <= 0) return const GDInt(0);
          var v = val - 1;
          v |= v >> 1;
          v |= v >> 2;
          v |= v >> 4;
          v |= v >> 8;
          v |= v >> 16;
          v |= v >> 32;
          return GDInt(v + 1);
        },
      ),
      NativeFunction.fixed(
        name: 'is_nan',
        arity: 1,
        callback: (args) => GDBool(args[0].toFloat().isNaN),
      ),
      NativeFunction.fixed(
        name: 'is_inf',
        arity: 1,
        callback: (args) => GDBool(args[0].toFloat().isInfinite),
      ),
      NativeFunction.fixed(
        name: 'is_zero_approx',
        arity: 1,
        callback: (args) => GDBool(args[0].toFloat().abs() <= 0.00001),
      ),
      NativeFunction.fixed(
        name: 'is_equal_approx',
        arity: 2,
        callback: (args) {
          final a = args[0].toFloat();
          final b = args[1].toFloat();
          if (a == b) return GDBool.trueValue;
          final diff = (a - b).abs();
          final tolerance = 0.00001 * math.max(1.0, math.max(a.abs(), b.abs()));
          return GDBool(diff <= tolerance);
        },
      ),

      // =======================================================================
      // Trigonometry & Angles
      // =======================================================================
      NativeFunction.fixed(
        name: 'sin',
        arity: 1,
        callback: (args) => GDFloat(math.sin(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'cos',
        arity: 1,
        callback: (args) => GDFloat(math.cos(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'tan',
        arity: 1,
        callback: (args) => GDFloat(math.tan(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'asin',
        arity: 1,
        callback: (args) => GDFloat(math.asin(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'acos',
        arity: 1,
        callback: (args) => GDFloat(math.acos(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'atan',
        arity: 1,
        callback: (args) => GDFloat(math.atan(args[0].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'atan2',
        arity: 2,
        callback: (args) => GDFloat(math.atan2(args[0].toFloat(), args[1].toFloat())),
      ),
      NativeFunction.fixed(
        name: 'sinh',
        arity: 1,
        callback: (args) {
          final x = args[0].toFloat();
          return GDFloat((math.exp(x) - math.exp(-x)) / 2.0);
        },
      ),
      NativeFunction.fixed(
        name: 'cosh',
        arity: 1,
        callback: (args) {
          final x = args[0].toFloat();
          return GDFloat((math.exp(x) + math.exp(-x)) / 2.0);
        },
      ),
      NativeFunction.fixed(
        name: 'tanh',
        arity: 1,
        callback: (args) {
          final x = args[0].toFloat();
          final e1 = math.exp(x);
          final e2 = math.exp(-x);
          return GDFloat((e1 - e2) / (e1 + e2));
        },
      ),
      NativeFunction.fixed(
        name: 'deg_to_rad',
        arity: 1,
        callback: (args) => GDFloat(args[0].toFloat() * (math.pi / 180.0)),
      ),
      NativeFunction.fixed(
        name: 'rad_to_deg',
        arity: 1,
        callback: (args) => GDFloat(args[0].toFloat() * (180.0 / math.pi)),
      ),

      // =======================================================================
      // Interpolation & Curves
      // =======================================================================
      NativeFunction.fixed(
        name: 'lerp',
        arity: 3,
        callback: (args) {
          final from = args[0].toFloat();
          final to = args[1].toFloat();
          final weight = args[2].toFloat();
          return GDFloat(from + (to - from) * weight);
        },
      ),
      NativeFunction.fixed(
        name: 'lerpf',
        arity: 3,
        callback: (args) {
          final from = args[0].toFloat();
          final to = args[1].toFloat();
          final weight = args[2].toFloat();
          return GDFloat(from + (to - from) * weight);
        },
      ),
      NativeFunction.fixed(
        name: 'lerp_angle',
        arity: 3,
        callback: (args) {
          final from = args[0].toFloat();
          final to = args[1].toFloat();
          final weight = args[2].toFloat();
          var diff = (to - from) % (2 * math.pi);
          diff = (2 * diff) % (2 * math.pi) - diff;
          return GDFloat(from + diff * weight);
        },
      ),
      NativeFunction.fixed(
        name: 'inverse_lerp',
        arity: 3,
        callback: (args) {
          final from = args[0].toFloat();
          final to = args[1].toFloat();
          final value = args[2].toFloat();
          if (to == from) return const GDFloat(0.0);
          return GDFloat((value - from) / (to - from));
        },
      ),
      NativeFunction.fixed(
        name: 'remap',
        arity: 5,
        callback: (args) {
          final val = args[0].toFloat();
          final istart = args[1].toFloat();
          final istop = args[2].toFloat();
          final ostart = args[3].toFloat();
          final ostop = args[4].toFloat();
          if (istop == istart) return GDFloat(ostart);
          final t = (val - istart) / (istop - istart);
          return GDFloat(ostart + (ostop - ostart) * t);
        },
      ),
      NativeFunction.fixed(
        name: 'smoothstep',
        arity: 3,
        callback: (args) {
          final from = args[0].toFloat();
          final to = args[1].toFloat();
          final x = args[2].toFloat();
          if (to == from) return const GDFloat(0.0);
          final t = ((x - from) / (to - from)).clamp(0.0, 1.0);
          return GDFloat(t * t * (3.0 - 2.0 * t));
        },
      ),
      NativeFunction.fixed(
        name: 'move_toward',
        arity: 3,
        callback: (args) {
          final from = args[0].toFloat();
          final to = args[1].toFloat();
          final delta = args[2].toFloat();
          if ((to - from).abs() <= delta) return GDFloat(to);
          return GDFloat(from + (to > from ? delta : -delta));
        },
      ),
      NativeFunction.fixed(
        name: 'ease',
        arity: 2,
        callback: (args) {
          var s = args[0].toFloat().clamp(0.0, 1.0);
          final curve = args[1].toFloat();
          if (s < 0) s = 0.0;
          if (s > 1.0) s = 1.0;
          if (curve > 0) {
            if (curve < 1.0) {
              return GDFloat(1.0 - math.pow(1.0 - s, 1.0 / curve).toDouble());
            } else {
              return GDFloat(math.pow(s, curve).toDouble());
            }
          } else if (curve < 0) {
            if (s < 0.5) {
              return GDFloat(math.pow(s * 2.0, -curve).toDouble() * 0.5);
            } else {
              return GDFloat((1.0 - math.pow(1.0 - (s - 0.5) * 2.0, -curve).toDouble()) * 0.5 + 0.5);
            }
          } else {
            return const GDFloat(0.0);
          }
        },
      ),

      // =======================================================================
      // Random Generation
      // =======================================================================
      NativeFunction.fixed(
        name: 'randomize',
        arity: 0,
        callback: (_) {
          randomize();
          return GDNull.instance;
        },
      ),
      NativeFunction.fixed(
        name: 'seed',
        arity: 1,
        callback: (args) {
          setSeed(args[0].toInt());
          return GDNull.instance;
        },
      ),
      NativeFunction.fixed(
        name: 'randi',
        arity: 0,
        callback: (_) => GDInt(_random.nextInt(0x7FFFFFFF)),
      ),
      NativeFunction.fixed(
        name: 'randf',
        arity: 0,
        callback: (_) => GDFloat(_random.nextDouble()),
      ),
      NativeFunction.fixed(
        name: 'randi_range',
        arity: 2,
        callback: (args) {
          final from = args[0].toInt();
          final to = args[1].toInt();
          final mn = math.min(from, to);
          final mx = math.max(from, to);
          final diff = mx - mn + 1;
          return GDInt(mn + (diff > 0 ? _random.nextInt(diff) : 0));
        },
      ),
      NativeFunction.fixed(
        name: 'randf_range',
        arity: 2,
        callback: (args) {
          final from = args[0].toFloat();
          final to = args[1].toFloat();
          return GDFloat(from + (to - from) * _random.nextDouble());
        },
      ),
      NativeFunction.fixed(
        name: 'randfn',
        arity: 2,
        callback: (args) {
          final mean = args[0].toFloat();
          final deviation = args[1].toFloat();
          final u1 = 1.0 - _random.nextDouble();
          final u2 = 1.0 - _random.nextDouble();
          final randStdNormal = math.sqrt(-2.0 * math.log(u1)) * math.sin(2.0 * math.pi * u2);
          return GDFloat(mean + deviation * randStdNormal);
        },
      ),
    ];
  }
}
