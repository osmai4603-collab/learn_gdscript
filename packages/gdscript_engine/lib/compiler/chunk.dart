import '../runtime/value.dart';
import 'opcode.dart';

/// Container for compiled bytecode instructions, constants pool, and source line maps.
class Chunk {
  /// Raw bytecode byte stream.
  final List<int> code = [];

  /// Constant pool storing static literal values.
  final List<GDValue> constants = [];

  /// Source line numbers mapped 1:1 to each byte in [code].
  final List<int> lines = [];

  /// Human-readable identifier for debugging (e.g. function or script name).
  final String name;

  Chunk({required this.name});

  /// Appends a raw [byte] to the chunk.
  void write(int byte, int line) {
    code.add(byte & 0xFF);
    lines.add(line);
  }

  /// Appends an [OpCode] byte.
  void writeOp(OpCode op, int line) {
    write(op.index, line);
  }

  /// Appends a 16-bit big-endian integer [value].
  void writeShort(int value, int line) {
    write((value >> 8) & 0xFF, line);
    write(value & 0xFF, line);
  }

  /// Patches a 16-bit big-endian integer at [offset].
  void patchShort(int offset, int value) {
    code[offset] = (value >> 8) & 0xFF;
    code[offset + 1] = value & 0xFF;
  }

  /// Adds [value] to the constant pool, returning its index.
  /// Deduplicates simple primitives (integers, floats, booleans, strings).
  int addConstant(GDValue value) {
    // Check if constant already exists in pool
    for (var i = 0; i < constants.length; i++) {
      if (constants[i] == value) {
        return i;
      }
    }
    constants.add(value);
    return constants.length - 1;
  }

  /// Writes an instruction to load [value] onto the stack.
  /// Uses [OpCode.opConstant] for indices < 256, or [OpCode.opConstantLong] otherwise.
  void writeConstant(GDValue value, int line) {
    final index = addConstant(value);
    if (index < 256) {
      writeOp(OpCode.opConstant, line);
      write(index, line);
    } else {
      writeOp(OpCode.opConstantLong, line);
      writeShort(index, line);
    }
  }

  /// Returns the line number for instruction at [ip].
  int getLine(int ip) {
    if (ip >= 0 && ip < lines.length) {
      return lines[ip];
    }
    return 1;
  }

  /// Disassembles the entire chunk into human-readable assembly format.
  String disassemble([String? customName]) {
    final buffer = StringBuffer();
    final header = '== ${customName ?? name} ==';
    buffer.writeln(header);

    var offset = 0;
    while (offset < code.length) {
      final (lineStr, nextOffset) = disassembleInstruction(offset);
      buffer.writeln(lineStr);
      offset = nextOffset;
    }

    return buffer.toString().trimRight();
  }

  /// Disassembles a single instruction at [offset].
  /// Returns a tuple containing the formatted string and the next byte offset.
  (String, int) disassembleInstruction(int offset) {
    final buffer = StringBuffer();
    final offsetStr = offset.toString().padLeft(4, '0');
    buffer.write('$offsetStr ');

    // Print line number or '|' if on the same line as previous byte
    if (offset > 0 && lines[offset] == lines[offset - 1]) {
      buffer.write('   | ');
    } else {
      buffer.write('${lines[offset].toString().padLeft(4, ' ')} ');
    }

    final byte = code[offset];
    if (byte >= OpCode.values.length) {
      buffer.write('UNKNOWN_OPCODE ($byte)');
      return (buffer.toString(), offset + 1);
    }

    final op = OpCode.values[byte];
    buffer.write('${op.mnemonic.padRight(18)} ');

    switch (op) {
      case OpCode.opConstant:
        final constIndex = code[offset + 1];
        final val = constants[constIndex];
        buffer.write('$constIndex ("${val.toGDString()}")');
        return (buffer.toString(), offset + 2);

      case OpCode.opConstantLong:
        final constIndex = (code[offset + 1] << 8) | code[offset + 2];
        final val = constants[constIndex];
        buffer.write('$constIndex ("${val.toGDString()}")');
        return (buffer.toString(), offset + 3);

      case OpCode.opGetLocal:
      case OpCode.opSetLocal:
      case OpCode.opCall:
      case OpCode.opPrint:
      case OpCode.opNewInstance:
      case OpCode.opGetUpvalue:
      case OpCode.opSetUpvalue:
        final slot = code[offset + 1];
        buffer.write('slot: $slot');
        return (buffer.toString(), offset + 2);

      case OpCode.opGetGlobal:
      case OpCode.opSetGlobal:
      case OpCode.opDefineGlobal:
      case OpCode.opGetProperty:
      case OpCode.opSetProperty:
      case OpCode.opClass:
      case OpCode.opGetSuper:
      case OpCode.opIs:
        final constIndex = (code[offset + 1] << 8) | code[offset + 2];
        final val = constants[constIndex];
        buffer.write('$constIndex ("${val.toGDString()}")');
        return (buffer.toString(), offset + 3);

      case OpCode.opMakeArray:
      case OpCode.opMakeDictionary:
        final count = (code[offset + 1] << 8) | code[offset + 2];
        buffer.write('count: $count');
        return (buffer.toString(), offset + 3);

      case OpCode.opJump:
      case OpCode.opJumpIfFalse:
      case OpCode.opJumpIfTrue:
      case OpCode.opIterNext:
        final jump = (code[offset + 1] << 8) | code[offset + 2];
        final dest = offset + 3 + jump;
        buffer.write('offset: $jump -> $dest');
        return (buffer.toString(), offset + 3);

      case OpCode.opLoop:
        final jump = (code[offset + 1] << 8) | code[offset + 2];
        final dest = offset + 3 - jump;
        buffer.write('offset: $jump -> $dest');
        return (buffer.toString(), offset + 3);

      default:
        return (buffer.toString().trimRight(), offset + 1);
    }
  }
}
