/// Bytecode operation codes for the GDScript Virtual Machine.
enum OpCode {
  // ===========================================================================
  // Constants & Literals
  // ===========================================================================
  opConstant, // 1-byte constant index operand
  opConstantLong, // 2-byte constant index operand
  opNull, // push GDNull
  opTrue, // push GDBool(true)
  opFalse, // push GDBool(false)

  // ===========================================================================
  // Arithmetic Operations (pops right, pops left, pushes result)
  // ===========================================================================
  opAdd, // left + right
  opSubtract, // left - right
  opMultiply, // left * right
  opDivide, // left / right
  opModulo, // left % right
  opPower, // left ** right
  opNegate, // -value

  // ===========================================================================
  // Comparison Operations
  // ===========================================================================
  opEqual, // left == right
  opNotEqual, // left != right
  opLess, // left < right
  opGreater, // left > right
  opLessEqual, // left <= right
  opGreaterEqual, // left >= right

  // ===========================================================================
  // Logical & Bitwise Operations
  // ===========================================================================
  opNot, // not value / !value
  opBitwiseAnd, // left & right
  opBitwiseOr, // left | right
  opBitwiseXor, // left ^ right
  opBitwiseNot, // ~value
  opShiftLeft, // left << right
  opShiftRight, // left >> right

  // ===========================================================================
  // Variables & Scope Storage
  // ===========================================================================
  opGetLocal, // 1-byte local slot operand: push stack[slot]
  opSetLocal, // 1-byte local slot operand: stack[slot] = peek
  opGetGlobal, // 2-byte constant name index: push globals[name]
  opSetGlobal, // 2-byte constant name index: globals[name] = peek
  opDefineGlobal, // 2-byte constant name index: globals[name] = pop
  opGetProperty, // 2-byte constant name index: pop object, push object.prop
  opSetProperty, // 2-byte constant name index: pop val, pop obj, obj.prop = val

  // ===========================================================================
  // Collections (Arrays & Dictionaries)
  // ===========================================================================
  opMakeArray, // 2-byte count operand: pops N items, pushes GDArray
  opMakeDictionary, // 2-byte count operand: pops N pairs, pushes GDDictionary
  opGetIndex, // pops index, pops collection, pushes collection[index]
  opSetIndex, // pops value, pops index, pops collection, collection[index] = val

  // ===========================================================================
  // Control Flow & Branching
  // ===========================================================================
  opJump, // 2-byte unsigned relative offset: jump forward unconditionally
  opJumpIfFalse, // 2-byte unsigned offset: jump forward if top is falsy
  opJumpIfTrue, // 2-byte unsigned offset: jump forward if top is truthy
  opLoop, // 2-byte unsigned relative offset: jump backward to loop start

  // ===========================================================================
  // Functions & Execution
  // ===========================================================================
  opCall, // 1-byte argument count operand
  opReturn, // returns from current call frame

  // ===========================================================================
  // Classes, OOP & Closures
  // ===========================================================================
  opClass, // 2-byte constant class name index
  opGetSuper, // 2-byte constant method name index
  opInherit, // pops superclass, binds inheritance to class below
  opNewInstance, // 1-byte argument count operand: instantiates class with args
  opClosure, // 2-byte constant function index + upvalues info
  opGetUpvalue, // 1-byte upvalue index
  opSetUpvalue, // 1-byte upvalue index
  opCloseUpvalue, // closes upvalue on stack

  // ===========================================================================
  // Miscellaneous & Debugging
  // ===========================================================================
  opPrint, // 1-byte argument count operand: prints to stdout
  opPop, // drops value from top of stack
  opDuplicate, // duplicates top of stack
  opIs, // 2-byte constant type name index: type check
  opIn, // membership check: item in collection
  opIterInit, // initializes iterator for loop
  opIterNext, // steps iterator and pushes next item
  opIterHasNext, // checks if iterator has more items
  opAssert, // verifies condition
  opBreakpoint, // triggers debug pause
  ;

  /// Returns the human-readable opcode name for disassembly.
  String get mnemonic {
    return switch (this) {
      OpCode.opConstant => 'OP_CONSTANT',
      OpCode.opConstantLong => 'OP_CONSTANT_LONG',
      OpCode.opNull => 'OP_NULL',
      OpCode.opTrue => 'OP_TRUE',
      OpCode.opFalse => 'OP_FALSE',
      OpCode.opAdd => 'OP_ADD',
      OpCode.opSubtract => 'OP_SUBTRACT',
      OpCode.opMultiply => 'OP_MULTIPLY',
      OpCode.opDivide => 'OP_DIVIDE',
      OpCode.opModulo => 'OP_MODULO',
      OpCode.opPower => 'OP_POWER',
      OpCode.opNegate => 'OP_NEGATE',
      OpCode.opEqual => 'OP_EQUAL',
      OpCode.opNotEqual => 'OP_NOT_EQUAL',
      OpCode.opLess => 'OP_LESS',
      OpCode.opGreater => 'OP_GREATER',
      OpCode.opLessEqual => 'OP_LESS_EQUAL',
      OpCode.opGreaterEqual => 'OP_GREATER_EQUAL',
      OpCode.opNot => 'OP_NOT',
      OpCode.opBitwiseAnd => 'OP_BITWISE_AND',
      OpCode.opBitwiseOr => 'OP_BITWISE_OR',
      OpCode.opBitwiseXor => 'OP_BITWISE_XOR',
      OpCode.opBitwiseNot => 'OP_BITWISE_NOT',
      OpCode.opShiftLeft => 'OP_SHIFT_LEFT',
      OpCode.opShiftRight => 'OP_SHIFT_RIGHT',
      OpCode.opGetLocal => 'OP_GET_LOCAL',
      OpCode.opSetLocal => 'OP_SET_LOCAL',
      OpCode.opGetGlobal => 'OP_GET_GLOBAL',
      OpCode.opSetGlobal => 'OP_SET_GLOBAL',
      OpCode.opDefineGlobal => 'OP_DEFINE_GLOBAL',
      OpCode.opGetProperty => 'OP_GET_PROPERTY',
      OpCode.opSetProperty => 'OP_SET_PROPERTY',
      OpCode.opMakeArray => 'OP_MAKE_ARRAY',
      OpCode.opMakeDictionary => 'OP_MAKE_DICTIONARY',
      OpCode.opGetIndex => 'OP_GET_INDEX',
      OpCode.opSetIndex => 'OP_SET_INDEX',
      OpCode.opJump => 'OP_JUMP',
      OpCode.opJumpIfFalse => 'OP_JUMP_IF_FALSE',
      OpCode.opJumpIfTrue => 'OP_JUMP_IF_TRUE',
      OpCode.opLoop => 'OP_LOOP',
      OpCode.opCall => 'OP_CALL',
      OpCode.opReturn => 'OP_RETURN',
      OpCode.opClass => 'OP_CLASS',
      OpCode.opGetSuper => 'OP_GET_SUPER',
      OpCode.opInherit => 'OP_INHERIT',
      OpCode.opNewInstance => 'OP_NEW_INSTANCE',
      OpCode.opClosure => 'OP_CLOSURE',
      OpCode.opGetUpvalue => 'OP_GET_UPVALUE',
      OpCode.opSetUpvalue => 'OP_SET_UPVALUE',
      OpCode.opCloseUpvalue => 'OP_CLOSE_UPVALUE',
      OpCode.opPrint => 'OP_PRINT',
      OpCode.opPop => 'OP_POP',
      OpCode.opDuplicate => 'OP_DUPLICATE',
      OpCode.opIs => 'OP_IS',
      OpCode.opIn => 'OP_IN',
      OpCode.opIterInit => 'OP_ITER_INIT',
      OpCode.opIterNext => 'OP_ITER_NEXT',
      OpCode.opIterHasNext => 'OP_ITER_HAS_NEXT',
      OpCode.opAssert => 'OP_ASSERT',
      OpCode.opBreakpoint => 'OP_BREAKPOINT',
    };
  }
}
