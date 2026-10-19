import '../compiler/chunk.dart';
import '../compiler/compiler.dart';
import '../compiler/opcode.dart';
import '../core/gdscript_error.dart';
import '../objects/gd_callable.dart';
import '../objects/gd_class.dart';
import '../objects/gd_function.dart';
import '../objects/gd_instance.dart';
import 'call_frame.dart';
import 'iterator.dart';
import 'native/builtin_types.dart';
import 'native/global_scope.dart';
import 'upvalue.dart';
import 'value.dart';

/// Execution state of the [VM].
enum ExecutionState { ready, running, paused, completed, error }

/// A high-performance, stack-based Virtual Machine for GDScript 4.
class VM {
  /// Maximum call frame recursion depth limit.
  static const int defaultMaxFrames = 256;

  /// Default instruction execution limit to prevent infinite loops.
  static const int defaultMaxInstructions = 1000000;

  /// Currently active VM instance for re-entrant or nested bytecode execution.
  static VM? currentVM;

  static void _ensureRunner() {
    GDCallable.runner = (callable, args) {
      final vm = VM.currentVM ?? VM();
      return vm.executeCallable(callable, args);
    };
  }

  /// Main value stack.
  final List<GDValue> stack;

  /// Current stack top pointer (number of elements on stack).
  int stackTop = 0;

  /// Call frames stack.
  final List<CallFrame> frames = [];

  /// Global variables environment.
  final Map<String, GDValue> globals = {};

  /// Registered native functions / standard library callables.
  final Map<String, GDNativeCallable> nativeFunctions = {};

  /// Head of the linked list of open upvalues.
  VMUpvalue? openUpvalues;

  /// Captured standard output lines.
  final List<String> stdoutHistory = [];

  /// Callback invoked when output is printed.
  void Function(String text)? onPrint;

  /// Total instruction counter for the current run.
  int instructionCount = 0;

  /// Maximum allowed instruction executions before throwing an error.
  int maxInstructions;

  /// Maximum allowed call stack depth.
  final int maxFrames;

  /// Current state of the VM.
  ExecutionState state = ExecutionState.ready;

  /// Active line breakpoints.
  final Set<int> breakpoints = {};
  int? _lastPausedLine;

  /// Adds a breakpoint on [line].
  void addBreakpoint(int line) => breakpoints.add(line);

  /// Removes a breakpoint on [line].
  void removeBreakpoint(int line) => breakpoints.remove(line);

  /// Checks if a breakpoint is active on [line].
  bool hasBreakpoint(int line) => breakpoints.contains(line);

  /// Clears all breakpoints.
  void clearBreakpoints() => breakpoints.clear();

  /// Most recent runtime error message, if any.
  String? lastErrorMessage;

  VM({
    int initialStackCapacity = 2048,
    this.maxInstructions = defaultMaxInstructions,
    this.maxFrames = defaultMaxFrames,
    this.onPrint,
    Map<String, GDValue>? globals,
    Map<String, GDNativeCallable>? nativeFunctions,
  }) : stack = List<GDValue>.filled(
         initialStackCapacity,
         GDNull.instance,
         growable: true,
       ) {
    if (globals != null) {
      this.globals.addAll(globals);
    }
    if (nativeFunctions != null) {
      this.nativeFunctions.addAll(nativeFunctions);
    }
    _registerBuiltins();
    _ensureRunner();
  }

  /// Executes a [callable] with [args], supporting re-entrant calls within the VM
  /// or fresh execution.
  GDValue executeCallable(GDCallable callable, List<GDValue> args) {
    if (callable is GDNativeCallable) {
      return callable.call(args);
    }

    final initialFrameCount = frames.length;
    final initialTop = stackTop;

    push(GDCallableValue(callable));
    for (final a in args) {
      push(a);
    }

    _callCallable(callable, args.length);
    final prev = VM.currentVM;
    VM.currentVM = this;
    try {
      final result = _run(initialFrameCount);
      stackTop = initialTop;
      return result;
    } finally {
      VM.currentVM = prev;
    }
  }

  // ===========================================================================
  // Standard Library & Built-in Registration
  // ===========================================================================

  void _registerBuiltins() {
    GlobalScope.registerAll(
      globals: globals,
      nativeFunctions: nativeFunctions,
      onPrint: (text) {
        onPrint?.call(text);
      },
      stdoutHistory: stdoutHistory,
    );
  }

  // ===========================================================================
  // Stack Management
  // ===========================================================================

  /// Pushes [value] onto the top of the stack.
  void push(GDValue value) {
    if (stackTop >= stack.length) {
      stack.addAll(List.filled(stack.length, GDNull.instance));
    }
    stack[stackTop++] = value;
  }

  /// Pops the topmost value from the stack.
  GDValue pop() {
    if (stackTop <= 0) {
      throw GDRuntimeError('Stack underflow.');
    }
    final val = stack[--stackTop];
    stack[stackTop] = GDNull.instance; // Clear reference for GC
    return val;
  }

  /// Inspects value at [distance] slots below the top of stack without popping.
  GDValue peek([int distance = 0]) {
    final idx = stackTop - 1 - distance;
    if (idx < 0 || idx >= stackTop) {
      throw GDRuntimeError('Stack underflow on peek (distance $distance).');
    }
    return stack[idx];
  }

  // ===========================================================================
  // Upvalue Management
  // ===========================================================================

  /// Captures an upvalue at the given [location] on the VM stack.
  ///
  /// Reuses existing open upvalues pointing to the same location, or creates a
  /// new one and inserts it in sorted descending order.
  VMUpvalue _captureUpvalue(int location) {
    VMUpvalue? prev;
    var curr = openUpvalues;

    while (curr != null && curr.location > location) {
      prev = curr;
      curr = curr.next;
    }

    if (curr != null && curr.location == location) {
      return curr;
    }

    final created = VMUpvalue(location);
    created.next = curr;
    if (prev == null) {
      openUpvalues = created;
    } else {
      prev.next = created;
    }
    return created;
  }

  /// Closes all open upvalues whose location is at or above [lastSlot].
  void _closeUpvalues(int lastSlot) {
    while (openUpvalues != null && openUpvalues!.location >= lastSlot) {
      final upvalue = openUpvalues!;
      upvalue.close(stack);
      openUpvalues = upvalue.next;
    }
  }

  // ===========================================================================
  // Function Call Handling
  // ===========================================================================

  /// Invokes a callee value with [argCount] arguments currently on the stack.
  bool _callValue(GDValue callee, int argCount) {
    if (callee is GDCallableValue) {
      return _callCallable(callee.callable, argCount);
    }

    if (callee is GDClassValue) {
      // Direct class instantiation syntax: ClassName(args)
      final instance = GDInstance(gdClass: callee.gdClass);
      final args = stack.sublist(stackTop - argCount, stackTop);
      stackTop -= argCount + 1; // pop args and callee class

      final initMethod = callee.gdClass.findMethod('_init');
      if (initMethod != null) {
        if (initMethod.chunk != null) {
          push(GDInstanceValue(instance));
          for (final a in args) {
            push(a);
          }
          _callCallable(
            GDUserFunctionCallable(function: initMethod, target: instance),
            args.length,
          );
          return true;
        } else {
          initMethod.invoke(instance, args);
        }
      }
      push(GDInstanceValue(instance));
      return true;
    }

    throw GDRuntimeError(
      'Cannot call non-callable value of type "${callee.typeName}".',
    );
  }

  /// Invokes a [GDCallable] with [argCount] arguments.
  bool _callCallable(GDCallable callable, int argCount) {
    if (callable is GDUserFunctionCallable) {
      final func = callable.function;
      if (frames.length >= maxFrames) {
        throw GDRuntimeError(
          'Stack overflow: maximum call depth of $maxFrames exceeded.',
        );
      }

      // Check arity
      if (argCount < func.requiredArity) {
        throw GDRuntimeError(
          'Function "${func.name}" requires at least ${func.requiredArity} arguments, but got $argCount.',
        );
      }
      if (argCount > func.arity) {
        throw GDRuntimeError(
          'Function "${func.name}" accepts at most ${func.arity} arguments, but got $argCount.',
        );
      }

      // Push default values for missing arguments
      for (var i = argCount; i < func.parameters.length; i++) {
        push(func.parameters[i].defaultValue ?? GDNull.instance);
      }
      final totalArgs = func.parameters.length;

      final slotsOffset = stackTop - totalArgs - 1;

      // Slot 0 is self / callee
      if (callable.target != null) {
        stack[slotsOffset] = GDInstanceValue(callable.target!);
      } else if (frames.isNotEmpty && frames.last.instance != null) {
        stack[slotsOffset] = GDInstanceValue(frames.last.instance!);
      }

      final chunk = func.chunk;
      if (chunk == null) {
        // Native executor fallback
        final args = stack.sublist(
          slotsOffset + 1,
          slotsOffset + 1 + totalArgs,
        );
        stackTop = slotsOffset;
        final res = func.invoke(callable.target, args);
        push(res);
        return true;
      }

      final upvalues = callable is GDClosureCallable
          ? callable.upvalues
          : const <VMUpvalue>[];

      frames.add(
        CallFrame(
          function: func,
          chunk: chunk,
          slotsOffset: slotsOffset,
          upvalues: upvalues,
          instance: callable.target,
        ),
      );
      return true;
    }

    if (callable is GDNativeCallable) {
      final args = stack.sublist(stackTop - argCount, stackTop);
      stackTop -= argCount + 1; // pop args and callee
      final res = callable.call(args);
      push(res);
      return true;
    }

    throw GDRuntimeError(
      'Unsupported callable type "${callable.runtimeType}".',
    );
  }

  // ===========================================================================
  // Property & Index Helpers
  // ===========================================================================

  GDValue _getProperty(GDValue target, String prop) {
    if (target is GDInstanceValue) {
      return target.instance.get(prop);
    }
    if (target is GDClassValue) {
      if (prop == 'new') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'new',
            callback: (args) {
              final instance = GDInstance(gdClass: target.gdClass);
              final initMethod = target.gdClass.findMethod('_init');
              if (initMethod != null) {
                if (initMethod.chunk != null) {
                  executeCallable(
                    GDUserFunctionCallable(
                      function: initMethod,
                      target: instance,
                    ),
                    args,
                  );
                } else {
                  initMethod.invoke(instance, args);
                }
              }
              return GDInstanceValue(instance);
            },
          ),
        );
      }
      final constant = target.gdClass.findConstant(prop);
      if (constant != null) return constant;
      final method = target.gdClass.findMethod(prop);
      if (method != null && method.isStatic) {
        return GDCallableValue(GDUserFunctionCallable(function: method));
      }
      throw GDRuntimeError(
        'Class "${target.gdClass.name}" has no member "$prop".',
      );
    }
    if (target is GDSignalValue) {
      if (prop == 'emit') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'emit',
            callback: (args) {
              target.signal.emit(args);
              return GDNull.instance;
            },
          ),
        );
      }
      if (prop == 'connect') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'connect',
            callback: (args) {
              if (args.isEmpty || args[0] is! GDCallableValue) {
                throw GDRuntimeError('connect requires a Callable.');
              }
              final flags = args.length > 1 && args[1] is GDInt
                  ? (args[1] as GDInt).value
                  : 0;
              target.signal.connect(
                (args[0] as GDCallableValue).callable,
                flags,
              );
              return GDNull.instance;
            },
          ),
        );
      }
      if (prop == 'disconnect') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'disconnect',
            callback: (args) {
              if (args.isEmpty || args[0] is! GDCallableValue) {
                throw GDRuntimeError('disconnect requires a Callable.');
              }
              target.signal.disconnect((args[0] as GDCallableValue).callable);
              return GDNull.instance;
            },
          ),
        );
      }
      if (prop == 'is_connected') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'is_connected',
            callback: (args) {
              if (args.isEmpty || args[0] is! GDCallableValue) {
                throw GDRuntimeError('is_connected requires a Callable.');
              }
              return GDBool(
                target.signal.isConnected(
                  (args[0] as GDCallableValue).callable,
                ),
              );
            },
          ),
        );
      }
    }
    if (target is GDCallableValue) {
      if (prop == 'call') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'call',
            callback: (args) => target.callable.call(args),
          ),
        );
      }
      if (prop == 'callv') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'callv',
            callback: (args) => target.callable.callv(args[0] as GDArray),
          ),
        );
      }
      if (prop == 'bind') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'bind',
            callback: (args) => GDCallableValue(target.callable.bind(args)),
          ),
        );
      }
      if (prop == 'unbind') {
        return GDCallableValue(
          GDNativeCallable(
            name: 'unbind',
            callback: (args) => GDCallableValue(
              target.callable.unbind((args[0] as GDInt).value),
            ),
          ),
        );
      }
    }
    if (target is GDDictionary) {
      final key = GDString(prop);
      if (target.map.containsKey(key)) {
        return target.map[key]!;
      }
    }
    final builtin = BuiltinTypes.resolveMethod(target, prop);
    if (builtin != null) {
      return builtin;
    }

    throw GDRuntimeError(
      'Cannot get property "$prop" on value of type "${target.typeName}".',
    );
  }

  void _setProperty(GDValue target, String prop, GDValue value) {
    if (target is GDInstanceValue) {
      target.instance.set(prop, value);
      return;
    }
    if (target is GDDictionary) {
      target.map[GDString(prop)] = value;
      return;
    }
    throw GDRuntimeError(
      'Cannot set property "$prop" on value of type "${target.typeName}".',
    );
  }

  bool _checkIs(GDValue val, String typeName) {
    if (typeName == 'Variant') return true;
    if (val is GDNull) return typeName == 'null';
    if (val is GDBool) return typeName == 'bool';
    if (val is GDInt) return typeName == 'int';
    if (val is GDFloat) return typeName == 'float';
    if (val is GDString) return typeName == 'String';
    if (val is GDArray) return typeName == 'Array';
    if (val is GDDictionary) return typeName == 'Dictionary';
    if (val is GDCallableValue) return typeName == 'Callable';
    if (val is GDSignalValue) return typeName == 'Signal';
    if (val is GDInstanceValue) {
      return val.instance.gdClass.isSubclassOf(typeName);
    }
    return false;
  }

  bool _checkIn(GDValue item, GDValue collection) {
    if (collection is GDArray) {
      return collection.elements.contains(item);
    }
    if (collection is GDDictionary) {
      return collection.elements.containsKey(item);
    }
    if (collection is GDString && item is GDString) {
      return collection.value.contains(item.value);
    }
    throw GDRuntimeError(
      'Operator "in" not supported for type "${collection.typeName}".',
    );
  }

  // ===========================================================================
  // Dispatch Loop
  // ===========================================================================

  /// Executes bytecode instructions in the current call frames until complete
  /// or paused or [stopFrameCount] is reached.
  GDValue _run([int stopFrameCount = 0]) {
    state = ExecutionState.running;

    while (frames.length > stopFrameCount) {
      if (instructionCount++ >= maxInstructions) {
        state = ExecutionState.error;
        throw GDRuntimeError(
          'Instruction limit of $maxInstructions instructions exceeded. Possible infinite loop detected.',
        );
      }

      if (state == ExecutionState.paused) {
        return stackTop > 0 ? peek() : GDNull.instance;
      }

      final frame = frames.last;
      if (breakpoints.isNotEmpty && breakpoints.contains(frame.currentLine)) {
        if (_lastPausedLine != frame.currentLine) {
          _lastPausedLine = frame.currentLine;
          state = ExecutionState.paused;
          return stackTop > 0 ? peek() : GDNull.instance;
        }
      } else {
        _lastPausedLine = null;
      }

      final rawOp = frame.readByte();
      if (rawOp < 0 || rawOp >= OpCode.values.length) {
        throw GDRuntimeError('Unknown opcode $rawOp at ip ${frame.ip - 1}.');
      }
      final op = OpCode.values[rawOp];

      switch (op) {
        case OpCode.opConstant:
          final idx = frame.readByte();
          push(frame.readConstant(idx));

        case OpCode.opConstantLong:
          final idx = frame.readShort();
          push(frame.readConstant(idx));

        case OpCode.opNull:
          push(GDNull.instance);

        case OpCode.opTrue:
          push(GDBool.trueValue);

        case OpCode.opFalse:
          push(GDBool.falseValue);

        case OpCode.opAdd:
          final b = pop();
          final a = pop();
          push(a + b);

        case OpCode.opSubtract:
          final b = pop();
          final a = pop();
          push(a - b);

        case OpCode.opMultiply:
          final b = pop();
          final a = pop();
          push(a * b);

        case OpCode.opDivide:
          final b = pop();
          final a = pop();
          push(a / b);

        case OpCode.opModulo:
          final b = pop();
          final a = pop();
          push(a % b);

        case OpCode.opPower:
          final b = pop();
          final a = pop();
          push(a.power(b));

        case OpCode.opNegate:
          final a = pop();
          push(a.negate());

        case OpCode.opEqual:
          final b = pop();
          final a = pop();
          push(GDBool(a == b));

        case OpCode.opNotEqual:
          final b = pop();
          final a = pop();
          push(GDBool(a != b));

        case OpCode.opLess:
          final b = pop();
          final a = pop();
          push(GDBool(a < b));

        case OpCode.opGreater:
          final b = pop();
          final a = pop();
          push(GDBool(a > b));

        case OpCode.opLessEqual:
          final b = pop();
          final a = pop();
          push(GDBool(a <= b));

        case OpCode.opGreaterEqual:
          final b = pop();
          final a = pop();
          push(GDBool(a >= b));

        case OpCode.opNot:
          final a = pop();
          push(GDBool(!a.isTruthy));

        case OpCode.opBitwiseAnd:
          final b = pop();
          final a = pop();
          push(a & b);

        case OpCode.opBitwiseOr:
          final b = pop();
          final a = pop();
          push(a | b);

        case OpCode.opBitwiseXor:
          final b = pop();
          final a = pop();
          push(a ^ b);

        case OpCode.opBitwiseNot:
          final a = pop();
          push(~a);

        case OpCode.opShiftLeft:
          final b = pop();
          final a = pop();
          push(a << b);

        case OpCode.opShiftRight:
          final b = pop();
          final a = pop();
          push(a >> b);

        case OpCode.opGetLocal:
          final slot = frame.readByte();
          push(stack[frame.slotsOffset + slot]);

        case OpCode.opSetLocal:
          final slot = frame.readByte();
          stack[frame.slotsOffset + slot] = peek();

        case OpCode.opGetGlobal:
          final idx = frame.readShort();
          final name = frame.readConstant(idx).toGDString();
          if (frame.instance != null && frame.instance!.fields.containsKey(name)) {
            push(frame.instance!.fields[name]!);
          } else if (globals.containsKey(name)) {
            push(globals[name]!);
          } else if (nativeFunctions.containsKey(name)) {
            push(GDCallableValue(nativeFunctions[name]!));
          } else {
            throw GDRuntimeError('Undefined variable or global "$name".');
          }

        case OpCode.opSetGlobal:
          final idx = frame.readShort();
          final name = frame.readConstant(idx).toGDString();
          final val = peek();
          globals[name] = val;
          if (frame.instance != null && frame.instance!.fields.containsKey(name)) {
            frame.instance!.fields[name] = val;
          }

        case OpCode.opDefineGlobal:
          final idx = frame.readShort();
          final name = frame.readConstant(idx).toGDString();
          final val = pop();
          globals[name] = val;
          if (frame.instance != null) {
            frame.instance!.fields[name] = val;
          }

        case OpCode.opGetProperty:
          final idx = frame.readShort();
          final prop = frame.readConstant(idx).toGDString();
          final target = pop();
          push(_getProperty(target, prop));

        case OpCode.opSetProperty:
          final idx = frame.readShort();
          final prop = frame.readConstant(idx).toGDString();
          final val = pop();
          final target = pop();
          _setProperty(target, prop, val);
          push(val);

        case OpCode.opMakeArray:
          final count = frame.readShort();
          final start = stackTop - count;
          final elems = stack.sublist(start, stackTop);
          stackTop = start;
          push(GDArray(elems));

        case OpCode.opMakeDictionary:
          final count = frame.readShort();
          final map = <GDValue, GDValue>{};
          final start = stackTop - count * 2;
          for (var i = start; i < stackTop; i += 2) {
            map[stack[i]] = stack[i + 1];
          }
          stackTop = start;
          push(GDDictionary(map));

        case OpCode.opGetIndex:
          final idx = pop();
          final coll = pop();
          push(coll[idx]);

        case OpCode.opSetIndex:
          final val = pop();
          final idx = pop();
          final coll = pop();
          coll[idx] = val;
          push(val);

        case OpCode.opJump:
          final offset = frame.readShort();
          frame.ip += offset;

        case OpCode.opJumpIfFalse:
          final offset = frame.readShort();
          if (!peek().isTruthy) {
            frame.ip += offset;
          }

        case OpCode.opJumpIfTrue:
          final offset = frame.readShort();
          if (peek().isTruthy) {
            frame.ip += offset;
          }

        case OpCode.opLoop:
          final offset = frame.readShort();
          frame.ip -= offset;

        case OpCode.opCall:
          final argCount = frame.readByte();
          final callee = peek(argCount);
          _callValue(callee, argCount);

        case OpCode.opReturn:
          final result = pop();
          _closeUpvalues(frame.slotsOffset);
          frames.removeLast();
          stackTop = frame.slotsOffset;
          if (frames.length <= stopFrameCount) {
            if (frames.isEmpty) {
              state = ExecutionState.completed;
            }
            return result;
          }
          push(result);

        case OpCode.opClass:
          final idx = frame.readShort();
          final name = frame.readConstant(idx).toGDString();
          final cls = GDClass(name: name);
          push(GDClassValue(cls));

        case OpCode.opGetSuper:
          final idx = frame.readShort();
          final methodName = frame.readConstant(idx).toGDString();
          final targetVal = pop();
          final targetInstance = targetVal is GDInstanceValue
              ? targetVal.instance
              : frame.instance;
          final superclass = targetInstance?.gdClass.superclass;
          if (superclass == null) {
            throw GDRuntimeError(
              'Cannot call super method "$methodName": class has no superclass.',
            );
          }
          final method = superclass.findMethod(methodName);
          if (method == null) {
            throw GDRuntimeError(
              'Super method "$methodName" not found in "${superclass.name}".',
            );
          }
          push(
            GDCallableValue(
              GDUserFunctionCallable(function: method, target: targetInstance),
            ),
          );

        case OpCode.opInherit:
          final superclassVal = pop();
          final subclassVal = peek();
          if (superclassVal is GDClassValue && subclassVal is GDClassValue) {
            subclassVal.gdClass.superclass = superclassVal.gdClass;
          } else {
            throw GDRuntimeError(
              'Invalid inheritance: superclass must be a GDClass.',
            );
          }

        case OpCode.opNewInstance:
          final argCount = frame.readByte();
          final args = stack.sublist(stackTop - argCount, stackTop);
          stackTop -= argCount;
          final classVal = pop();
          if (classVal is! GDClassValue) {
            throw GDRuntimeError(
              'Cannot instantiate non-class value of type "${classVal.typeName}".',
            );
          }
          final instance = GDInstance(gdClass: classVal.gdClass);
          final initMethod = classVal.gdClass.findMethod('_init');
          if (initMethod != null) {
            if (initMethod.chunk != null) {
              push(GDInstanceValue(instance));
              for (final a in args) {
                push(a);
              }
              _callCallable(
                GDUserFunctionCallable(function: initMethod, target: instance),
                args.length,
              );
              break;
            } else {
              initMethod.invoke(instance, args);
            }
          }
          push(GDInstanceValue(instance));

        case OpCode.opClosure:
          final fnIdx = frame.readShort();
          final fnVal = frame.readConstant(fnIdx);
          final func =
              (fnVal is GDCallableValue &&
                  fnVal.callable is GDUserFunctionCallable)
              ? (fnVal.callable as GDUserFunctionCallable).function
              : (throw GDRuntimeError('Invalid function in opClosure.'));
          final upvalueCount = frame.readByte();
          final upvals = <VMUpvalue>[];
          for (var i = 0; i < upvalueCount; i++) {
            final isLocal = frame.readByte() == 1;
            final index = frame.readByte();
            if (isLocal) {
              upvals.add(_captureUpvalue(frame.slotsOffset + index));
            } else {
              upvals.add(frame.upvalues[index]);
            }
          }
          push(
            GDCallableValue(
              GDClosureCallable(
                function: func,
                target: frame.instance,
                upvalues: upvals,
              ),
            ),
          );

        case OpCode.opGetUpvalue:
          final slot = frame.readByte();
          push(frame.upvalues[slot].get(stack));

        case OpCode.opSetUpvalue:
          final slot = frame.readByte();
          frame.upvalues[slot].set(stack, peek());

        case OpCode.opCloseUpvalue:
          _closeUpvalues(stackTop - 1);
          pop();

        case OpCode.opPrint:
          final argCount = frame.readByte();
          final start = stackTop - argCount;
          final args = stack.sublist(start, stackTop);
          stackTop = start;
          final text = args.map((a) => a.toGDString()).join(' ');
          stdoutHistory.add(text);
          onPrint?.call(text);

        case OpCode.opPop:
          pop();

        case OpCode.opDuplicate:
          push(peek());

        case OpCode.opIs:
          final idx = frame.readShort();
          final typeName = frame.readConstant(idx).toGDString();
          final val = pop();
          push(GDBool(_checkIs(val, typeName)));

        case OpCode.opIn:
          final collection = pop();
          final item = pop();
          push(GDBool(_checkIn(item, collection)));

        case OpCode.opIterInit:
          final coll = pop();
          final it = createGDIterator(coll);
          push(GDIteratorValue(it));

        case OpCode.opIterNext:
          final exitOffset = frame.readShort();
          GDIterator? it;
          if (stackTop >= 2 && stack[stackTop - 2] is GDIteratorValue) {
            it =
                (stack[stackTop - 2] as GDIteratorValue).iterator as GDIterator;
          } else if (stackTop >= 1 && stack[stackTop - 1] is GDIteratorValue) {
            it =
                (stack[stackTop - 1] as GDIteratorValue).iterator as GDIterator;
          }
          if (it == null) {
            throw GDRuntimeError(
              'opIterNext could not find iterator on stack.',
            );
          }
          if (it.moveNext()) {
            push(it.current);
          } else {
            frame.ip += exitOffset;
          }

        case OpCode.opIterHasNext:
          GDIterator? it;
          if (stackTop >= 1 && stack[stackTop - 1] is GDIteratorValue) {
            it =
                (stack[stackTop - 1] as GDIteratorValue).iterator as GDIterator;
          }
          push(GDBool(it != null));

        case OpCode.opAssert:
          final msg = pop();
          final cond = pop();
          if (!cond.isTruthy) {
            final m = msg is GDString ? msg.value : 'Assertion failed.';
            throw GDRuntimeError(m);
          }

        case OpCode.opBreakpoint:
          state = ExecutionState.paused;
          return stackTop > 0 ? peek() : GDNull.instance;
      }
    }

    state = ExecutionState.completed;
    return stackTop > 0 ? peek() : GDNull.instance;
  }

  // ===========================================================================
  // Public Execution APIs
  // ===========================================================================

  /// Executes bytecode in [chunk] and returns the resulting [GDValue].
  GDValue interpret(Chunk chunk, {GDInstance? instance}) {
    stackTop = 0;
    frames.clear();
    openUpvalues = null;
    instructionCount = 0;
    lastErrorMessage = null;

    final scriptFn = GDFunction(
      name: '<script>',
      chunk: chunk,
      localCount: 256,
    );

    // Reserve slot 0 for top-level script (self)
    if (instance != null) {
      push(GDInstanceValue(instance));
    } else {
      push(GDCallableValue(GDUserFunctionCallable(function: scriptFn)));
    }

    frames.add(
      CallFrame(
        function: scriptFn,
        chunk: chunk,
        slotsOffset: 0,
        instance: instance,
      ),
    );

    final prev = VM.currentVM;
    VM.currentVM = this;
    try {
      return _run();
    } catch (e) {
      state = ExecutionState.error;
      lastErrorMessage = e.toString();
      rethrow;
    } finally {
      VM.currentVM = prev;
    }
  }

  /// Executes a compiled script [result].
  GDValue executeScript(CompilerResult result) {
    // 1. Register script enums into globals
    for (final entry in result.scriptClass.enums.entries) {
      globals[entry.key] = entry.value.toDictionary();
    }

    // 2. Register inner classes into globals
    for (final entry in result.scriptClass.innerClasses.entries) {
      globals[entry.key] = GDClassValue(entry.value);
    }

    // 4. Create instance of the script class
    final instance = GDInstance(gdClass: result.scriptClass);

    // 3. Register global variables and methods
    for (final entry in result.scriptClass.methods.entries) {
      globals[entry.key] = GDCallableValue(
        GDUserFunctionCallable(function: entry.value, target: instance),
      );
    }

    // 5. If script has top-level chunk with code, execute it
    final chunk = result.mainChunk;
    GDValue topLevelResult = GDNull.instance;
    if (chunk.code.length > 2) {
      topLevelResult = interpret(chunk, instance: instance);
    }

    // 6. If there is a `main` or `_ready` or `run` or `_init` function, run it
    for (final candidate in ['main', '_ready', 'run', '_init']) {
      final fn = result.scriptClass.findMethod(candidate);
      if (fn != null && fn.chunk != null) {
        return callMethod(instance, candidate);
      }
    }

    return topLevelResult;
  }

  /// Invokes method [methodName] on [instance] with given [args] using the VM.
  GDValue callMethod(
    GDInstance instance,
    String methodName, [
    List<GDValue> args = const [],
  ]) {
    final method = instance.gdClass.findMethod(methodName);
    if (method == null) {
      throw GDRuntimeError(
        'Method "$methodName" not found on instance of "${instance.gdClass.name}".',
      );
    }

    if (method.chunk != null) {
      final prev = VM.currentVM;
      VM.currentVM = this;
      try {
        stackTop = 0;
        frames.clear();
        openUpvalues = null;
        instructionCount = 0;

        push(GDInstanceValue(instance));
        for (final a in args) {
          push(a);
        }

        _callCallable(
          GDUserFunctionCallable(function: method, target: instance),
          args.length,
        );
        return _run();
      } finally {
        VM.currentVM = prev;
      }
    }

    return method.invoke(instance, args);
  }

  /// Invokes [function] with [args] using the VM.
  GDValue callFunction(GDFunction function, [List<GDValue> args = const []]) {
    if (function.chunk != null) {
      final prev = VM.currentVM;
      VM.currentVM = this;
      try {
        stackTop = 0;
        frames.clear();
        openUpvalues = null;
        instructionCount = 0;

        push(GDCallableValue(GDUserFunctionCallable(function: function)));
        for (final a in args) {
          push(a);
        }

        _callCallable(GDUserFunctionCallable(function: function), args.length);
        return _run();
      } finally {
        VM.currentVM = prev;
      }
    }

    return function.invoke(null, args);
  }

  /// Formats a human-readable stack trace from current call frames.
  String formatStackTrace() {
    if (frames.isEmpty) return '  at <global> (line 1)';
    final buffer = StringBuffer();
    for (var i = frames.length - 1; i >= 0; i--) {
      final f = frames[i];
      final line = f.currentLine;
      final fnName = f.function.name;
      buffer.writeln('  at $fnName() (line $line)');
    }
    return buffer.toString().trimRight();
  }

  // ===========================================================================
  // Stepping (Debugger Support)
  // ===========================================================================

  /// Executes a single bytecode instruction.
  void stepInto() {
    if (state != ExecutionState.paused && state != ExecutionState.ready) return;
    state = ExecutionState.running;
    if (frames.isNotEmpty) {
      final frame = frames.last;
      final rawOp = frame.readByte();
      final op = OpCode.values[rawOp];
      // Execute single op
      _executeSingleOp(op, frame);
    }
    if (frames.isEmpty) {
      state = ExecutionState.completed;
    } else {
      state = ExecutionState.paused;
    }
  }

  void _executeSingleOp(OpCode op, CallFrame frame) {
    // Re-use dispatch logic for single step
    switch (op) {
      case OpCode.opConstant:
        push(frame.readConstant(frame.readByte()));
      case OpCode.opConstantLong:
        push(frame.readConstant(frame.readShort()));
      case OpCode.opNull:
        push(GDNull.instance);
      case OpCode.opTrue:
        push(GDBool.trueValue);
      case OpCode.opFalse:
        push(GDBool.falseValue);
      case OpCode.opAdd:
        final b = pop();
        final a = pop();
        push(a + b);
      case OpCode.opSubtract:
        final b = pop();
        final a = pop();
        push(a - b);
      case OpCode.opMultiply:
        final b = pop();
        final a = pop();
        push(a * b);
      case OpCode.opDivide:
        final b = pop();
        final a = pop();
        push(a / b);
      case OpCode.opReturn:
        final result = pop();
        _closeUpvalues(frame.slotsOffset);
        frames.removeLast();
        if (frames.isNotEmpty) {
          stackTop = frame.slotsOffset;
          push(result);
        }
      case OpCode.opPop:
        pop();
      default:
        // Handle other ops in standard execution
        frame.ip--; // Rewind and run with _run() with breakpoint set
        _run();
    }
  }

  /// Resumes execution after pause.
  GDValue resume() {
    if (state != ExecutionState.paused) {
      throw GDRuntimeError('Cannot resume VM that is not paused.');
    }
    final prev = VM.currentVM;
    VM.currentVM = this;
    try {
      return _run();
    } finally {
      VM.currentVM = prev;
    }
  }
}
