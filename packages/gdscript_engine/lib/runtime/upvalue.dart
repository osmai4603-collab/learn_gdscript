import 'value.dart';

/// Represents a variable captured by a closure in the GDScript Virtual Machine.
///
/// An upvalue is "open" while the captured local variable still lives on the VM
/// value stack. When the stack frame enclosing the variable returns, the upvalue
/// is "closed" and its value is copied to [closedValue] on the heap.
class VMUpvalue {
  /// Index in the VM value stack if open, or -1 if closed.
  int location;

  /// Holds the value once closed.
  GDValue? closedValue;

  /// Next open upvalue in the VM's open-upvalues linked list (ordered by stack location).
  VMUpvalue? next;

  VMUpvalue(this.location);

  /// Whether this upvalue is still open on the VM stack.
  bool get isOpen => location != -1;

  /// Reads the value from the VM stack (if open) or from [closedValue] (if closed).
  GDValue get(List<GDValue> stack) {
    if (isOpen) {
      return stack[location];
    }
    return closedValue ?? GDNull.instance;
  }

  /// Writes [value] to the VM stack (if open) or to [closedValue] (if closed).
  void set(List<GDValue> stack, GDValue value) {
    if (isOpen) {
      stack[location] = value;
    } else {
      closedValue = value;
    }
  }

  /// Closes this upvalue by copying the value from [stack] to [closedValue].
  void close(List<GDValue> stack) {
    if (isOpen) {
      closedValue = stack[location];
      location = -1;
    }
  }

  @override
  String toString() =>
      isOpen ? 'VMUpvalue(open: $location)' : 'VMUpvalue(closed: $closedValue)';
}
