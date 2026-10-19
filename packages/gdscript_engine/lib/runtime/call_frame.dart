import '../compiler/chunk.dart';
import '../objects/gd_function.dart';
import '../objects/gd_instance.dart';
import 'upvalue.dart';
import 'value.dart';

/// Represents a single active function call invocation on the VM call stack.
class CallFrame {
  /// The function or method currently being executed.
  final GDFunction function;

  /// Bytecode chunk for this function.
  final Chunk chunk;

  /// Instruction pointer index in [chunk.code].
  int ip;

  /// Starting index in the VM value stack for this frame's local variables.
  final int slotsOffset;

  /// Upvalues captured by this closure (empty for non-closure functions).
  final List<VMUpvalue> upvalues;

  /// The target instance (`self`) if this is an instance method invocation.
  final GDInstance? instance;

  CallFrame({
    required this.function,
    required this.chunk,
    this.ip = 0,
    required this.slotsOffset,
    this.upvalues = const [],
    this.instance,
  });

  /// Reads the next 8-bit byte from bytecode and advances [ip].
  int readByte() => chunk.code[ip++];

  /// Reads the next 16-bit big-endian integer from bytecode and advances [ip] by 2.
  int readShort() {
    final high = chunk.code[ip++];
    final low = chunk.code[ip++];
    return (high << 8) | low;
  }

  /// Retrieves constant from the chunk constant pool by [index].
  GDValue readConstant(int index) => chunk.constants[index];

  /// Returns the source code line corresponding to the current or last executed instruction.
  int get currentLine {
    if (chunk.code.isEmpty) return 1;
    final targetIp = ip > 0 ? ip - 1 : 0;
    if (targetIp < chunk.code.length) {
      return chunk.getLine(targetIp);
    }
    return 1;
  }

  @override
  String toString() =>
      'CallFrame(${function.name}, ip: $ip, slots: $slotsOffset)';
}
