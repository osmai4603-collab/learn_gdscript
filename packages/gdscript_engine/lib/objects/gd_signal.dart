import '../core/gdscript_error.dart';
import '../runtime/value.dart';
import 'gd_callable.dart';
import 'gd_instance.dart';

/// Connection flags for signals in GDScript.
class SignalFlags {
  static const int normal = 0;
  static const int oneShot = 1;
}

/// Record of a signal connection.
class SignalConnection {
  final GDCallable callable;
  final int flags;

  const SignalConnection({required this.callable, this.flags = 0});

  bool get isOneShot => (flags & SignalFlags.oneShot) != 0;
}

/// Represents an event signal in GDScript.
///
/// Supports registering listeners (`connect`), unregistering (`disconnect`),
/// querying connection state (`isConnected`), and dispatching events (`emit`).
class GDSignal {
  final String name;
  final GDInstance? owner;
  final List<SignalConnection> _connections = [];

  GDSignal({required this.name, this.owner});

  /// Connects [callable] to this signal.
  ///
  /// Throws [GDRuntimeError] if [callable] is already connected to this signal.
  void connect(GDCallable callable, [int flags = SignalFlags.normal]) {
    if (isConnected(callable)) {
      throw GDRuntimeError(
        'Signal "$name" is already connected to "${callable.name}".',
      );
    }
    _connections.add(SignalConnection(callable: callable, flags: flags));
  }

  /// Disconnects [callable] from this signal.
  ///
  /// Throws [GDRuntimeError] if [callable] was not connected.
  void disconnect(GDCallable callable) {
    final index = _connections.indexWhere((c) => c.callable == callable);
    if (index < 0) {
      throw GDRuntimeError(
        'Signal "$name" is not connected to "${callable.name}".',
      );
    }
    _connections.removeAt(index);
  }

  /// Checks whether [callable] is actively connected.
  bool isConnected(GDCallable callable) =>
      _connections.any((c) => c.callable == callable);

  /// Number of active connections.
  int get connectionCount => _connections.length;

  /// Emits the signal, synchronously notifying all connected listeners.
  void emit([List<GDValue> args = const []]) {
    final copy = List<SignalConnection>.of(_connections);
    final oneShots = <SignalConnection>[];

    for (final conn in copy) {
      conn.callable.call(args);
      if (conn.isOneShot) {
        oneShots.add(conn);
      }
    }

    // Clean up one-shot listeners
    for (final oneShot in oneShots) {
      _connections.remove(oneShot);
    }
  }

  /// Returns an array of connected [GDCallable]s.
  GDArray getConnections() {
    return GDArray(
      _connections.map((c) => GDCallableValue(c.callable)).toList(),
    );
  }

  @override
  String toString() => '<Signal:$name on ${owner ?? "global"}>';
}
