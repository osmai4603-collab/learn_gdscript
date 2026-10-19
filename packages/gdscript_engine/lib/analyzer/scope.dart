import 'symbol_table.dart';

/// Categories of nested scopes within a GDScript program.
enum ScopeKind { global, classScope, functionScope, blockScope, lambdaScope }

/// Represents a lexical scope holding variable, function, and type symbols.
class Scope {
  /// Category of this scope.
  final ScopeKind kind;

  /// Immediate outer enclosing scope (null for the root global scope).
  final Scope? enclosing;

  /// Nesting depth from root (global = 0).
  final int depth;

  final Map<String, Symbol> _symbols = {};
  int _nextLocalSlot = 0;

  /// Creates a new [Scope].
  Scope({required this.kind, this.enclosing, this.depth = 0});

  /// All symbols directly defined in this scope.
  Map<String, Symbol> get symbols => Map.unmodifiable(_symbols);

  /// Defines a new symbol in this immediate scope.
  ///
  /// Returns false if a symbol with the same name already exists in this scope.
  bool define(Symbol symbol) {
    if (_symbols.containsKey(symbol.name)) {
      return false;
    }
    _symbols[symbol.name] = symbol;
    return true;
  }

  /// Looks up a symbol by [name] in this scope, walking up enclosing scopes if needed.
  Symbol? lookup(String name) {
    if (_symbols.containsKey(name)) {
      return _symbols[name];
    }
    return enclosing?.lookup(name);
  }

  /// Looks up a symbol strictly in this immediate scope.
  Symbol? lookupLocal(String name) => _symbols[name];

  /// Checks if [name] is declared in this immediate scope.
  bool isDefinedLocally(String name) => _symbols.containsKey(name);

  /// Allocates a local variable slot index within the nearest function/lambda scope.
  int allocateLocalSlot() {
    if (kind == ScopeKind.functionScope || kind == ScopeKind.lambdaScope) {
      return _nextLocalSlot++;
    }
    if (enclosing != null) {
      return enclosing!.allocateLocalSlot();
    }
    return _nextLocalSlot++;
  }

  /// Checks whether this scope is enclosed within a function or lambda.
  bool get isInsideFunction =>
      kind == ScopeKind.functionScope ||
      kind == ScopeKind.lambdaScope ||
      (enclosing?.isInsideFunction ?? false);

  /// Checks whether this scope is enclosed within a class.
  bool get isInsideClass =>
      kind == ScopeKind.classScope || (enclosing?.isInsideClass ?? false);

  @override
  String toString() => 'Scope($kind, depth: $depth, count: ${_symbols.length})';
}
