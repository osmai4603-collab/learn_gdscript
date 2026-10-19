import '../core/source.dart';
import '../core/source_location.dart';
import 'scope.dart';
import 'type_system.dart';

/// Categories of symbols stored in symbol tables.
enum SymbolKind {
  variable,
  constant,
  function,
  parameter,
  classSymbol,
  enumSymbol,
  signalSymbol,
}

/// Represents a declared symbol (variable, function, class, etc.).
class Symbol {
  /// Name of the symbol.
  final String name;

  /// Inferred or explicitly annotated type.
  GDScriptType type;

  /// Kind of entity this symbol represents.
  final SymbolKind kind;

  /// Source location of the declaration.
  final SourceLocation location;

  /// Whether this symbol is an immutable constant.
  final bool isConst;

  /// Whether this symbol is a static member.
  final bool isStatic;

  /// Whether this variable has been assigned an initial value.
  bool isInitialized;

  /// Whether this symbol was referenced / read.
  bool isUsed;

  /// Stack slot index if this is a local variable in a function.
  int? localSlot;

  /// Scope nesting depth where this symbol was declared.
  int scopeDepth;

  /// Creates a new [Symbol].
  Symbol({
    required this.name,
    required this.type,
    required this.kind,
    required this.location,
    this.isConst = false,
    this.isStatic = false,
    this.isInitialized = false,
    this.isUsed = false,
    this.localSlot,
    this.scopeDepth = 0,
  });

  @override
  String toString() =>
      'Symbol($name: $type, $kind, depth: $scopeDepth, slot: $localSlot)';
}

/// Manages lexical scope transitions and symbol resolutions across a script.
class SymbolTable {
  late Scope _currentScope;
  final List<Scope> _allScopes = [];

  SymbolTable() {
    _currentScope = Scope(kind: ScopeKind.global, depth: 0);
    _allScopes.add(_currentScope);
    _registerBuiltinSymbols();
  }

  /// The active lexical scope.
  Scope get currentScope => _currentScope;

  /// All created scopes.
  List<Scope> get allScopes => List.unmodifiable(_allScopes);

  /// Enters a new nested scope of kind [kind].
  void enterScope(ScopeKind kind) {
    _currentScope = Scope(
      kind: kind,
      enclosing: _currentScope,
      depth: _currentScope.depth + 1,
    );
    _allScopes.add(_currentScope);
  }

  /// Exits the current scope and restores its parent scope.
  Scope exitScope() {
    final previous = _currentScope;
    if (_currentScope.enclosing != null) {
      _currentScope = _currentScope.enclosing!;
    }
    return previous;
  }

  /// Defines [symbol] in the current scope.
  bool define(Symbol symbol) {
    symbol.scopeDepth = _currentScope.depth;
    if (_currentScope.isInsideFunction &&
        (symbol.kind == SymbolKind.variable ||
            symbol.kind == SymbolKind.parameter)) {
      symbol.localSlot = _currentScope.allocateLocalSlot();
    }
    return _currentScope.define(symbol);
  }

  /// Looks up a symbol by [name] from current scope up through enclosing scopes.
  Symbol? resolve(String name) {
    final sym = _currentScope.lookup(name);
    if (sym != null) {
      sym.isUsed = true;
    }
    return sym;
  }

  /// Looks up a symbol strictly in the current immediate scope.
  Symbol? resolveLocal(String name) => _currentScope.lookupLocal(name);

  void _registerBuiltinSymbols() {
    final syntheticSource = SourceLocation.synthetic(
      Source.memory('', '<builtins>'),
    );

    // Common GDScript built-in functions
    final builtins = [
      ('print', VoidType.instance),
      ('prints', VoidType.instance),
      ('print_debug', VoidType.instance),
      ('range', ArrayType(PrimitiveType.intType)),
      ('len', PrimitiveType.intType),
      ('str', PrimitiveType.stringType),
      ('int', PrimitiveType.intType),
      ('float', PrimitiveType.floatType),
      ('bool', PrimitiveType.boolType),
      ('abs', PrimitiveType.floatType),
      ('min', VariantType.instance),
      ('max', VariantType.instance),
      ('clamp', VariantType.instance),
      ('sin', PrimitiveType.floatType),
      ('cos', PrimitiveType.floatType),
      ('tan', PrimitiveType.floatType),
      ('sqrt', PrimitiveType.floatType),
      ('pow', PrimitiveType.floatType),
      ('randi', PrimitiveType.intType),
      ('randf', PrimitiveType.floatType),
      ('randf_range', PrimitiveType.floatType),
      ('randi_range', PrimitiveType.intType),
      ('is_instance_valid', PrimitiveType.boolType),
    ];

    for (final (name, retType) in builtins) {
      define(
        Symbol(
          name: name,
          type: CallableType(parameterTypes: const [], returnType: retType),
          kind: SymbolKind.function,
          location: syntheticSource,
          isInitialized: true,
          isUsed: true,
        ),
      );
    }

    // Global built-in constants (e.g. `PI`, `TAU`, `INF`, `NAN`).
    final globalConstants = <String, GDScriptType>{
      'PI': PrimitiveType.floatType,
      'TAU': PrimitiveType.floatType,
      'E': PrimitiveType.floatType,
      'INF': PrimitiveType.floatType,
      'NAN': PrimitiveType.floatType,
      'TYPE_NIL': PrimitiveType.intType,
      'TYPE_BOOL': PrimitiveType.intType,
      'TYPE_INT': PrimitiveType.intType,
      'TYPE_FLOAT': PrimitiveType.intType,
      'TYPE_STRING': PrimitiveType.intType,
      'TYPE_VECTOR2': PrimitiveType.intType,
      'TYPE_VECTOR2I': PrimitiveType.intType,
      'TYPE_VECTOR3': PrimitiveType.intType,
      'TYPE_VECTOR3I': PrimitiveType.intType,
    };

    for (final entry in globalConstants.entries) {
      define(
        Symbol(
          name: entry.key,
          type: entry.value,
          kind: SymbolKind.constant,
          location: syntheticSource,
          isConst: true,
          isInitialized: true,
          isUsed: true,
        ),
      );
    }

    // Built-in engine value types usable as constructors (e.g. `Vector2i(1, 2)`).
    const builtInTypes = [
      'bool',
      'int',
      'float',
      'String',
      'StringName',
      'NodePath',
      'Vector2',
      'Vector2i',
      'Vector3',
      'Vector3i',
      'Vector4',
      'Vector4i',
      'Color',
      'Rect2',
      'Rect2i',
      'Transform2D',
      'Transform3D',
      'Basis',
      'Quaternion',
      'Plane',
      'AABB',
      'Projection',
      'PackedByteArray',
      'PackedInt32Array',
      'PackedInt64Array',
      'PackedFloat32Array',
      'PackedFloat64Array',
      'PackedStringArray',
      'PackedVector2Array',
      'PackedVector3Array',
      'PackedVector4Array',
      'PackedColorArray',
      'Array',
      'Dictionary',
      'Callable',
      'Signal',
      'RID',
      'Object',
      'RefCounted',
      'Resource',
      'Node',
      'Node2D',
      'Node3D',
      'CanvasItem',
      'CanvasLayer',
      'Control',
      'Window',
      'SceneTree',
    ];

    for (final name in builtInTypes) {
      define(
        Symbol(
          name: name,
          type: ClassType(name),
          kind: SymbolKind.classSymbol,
          location: syntheticSource,
          isInitialized: true,
          isUsed: true,
        ),
      );
    }
  }
}
