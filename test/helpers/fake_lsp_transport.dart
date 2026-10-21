import 'dart:async';
import 'dart:convert';

import 'package:learn_gdscript/logic/services/lsp_transport.dart';

class FakeLspTransport implements LspTransport {
  FakeLspTransport({this.serverCapabilities = const {}})
    : _stdout = StreamController<List<int>>(),
      _stderr = StreamController<List<int>>();

  final Map<String, Object?> serverCapabilities;
  final StreamController<List<int>> _stdout;
  final StreamController<List<int>> _stderr;
  final LspFrameDecoder _clientDecoder = LspFrameDecoder();
  final List<Map<String, Object?>> messages = [];
  final Completer<int> _exit = Completer<int>();
  bool autoRespond = true;
  bool inputClosed = false;
  bool killed = false;
  String? errorMethod;

  @override
  Stream<List<int>> get stdoutBytes => _stdout.stream;

  @override
  Stream<List<int>> get stderrBytes => _stderr.stream;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  Future<void> write(List<int> bytes) async {
    for (final message in _clientDecoder.add(bytes)) {
      messages.add(message);
      final method = message['method'];
      final id = message['id'];
      if (id is! int || method is! String) continue;
      if (method == 'initialize') {
        respond(id, result: {'capabilities': serverCapabilities});
      } else if (method == 'shutdown') {
        respond(id, result: null);
      } else if (autoRespond) {
        if (method == errorMethod) {
          respond(id, error: {'code': -32601, 'message': 'Not supported'});
        } else {
          respond(id, result: method);
        }
      }
    }
  }

  void respond(
    int id, {
    Object? result,
    Map<String, Object?>? error,
    List<int>? fragmentSizes,
  }) {
    sendMessage({
      'jsonrpc': '2.0',
      'id': id,
      if (error != null) 'error': error else 'result': result,
    }, fragmentSizes: fragmentSizes);
  }

  void sendMessage(
    Map<String, Object?> message, {
    List<int>? fragmentSizes,
  }) {
    final body = utf8.encode(jsonEncode(message));
    final packet = [
      ...ascii.encode('Content-Length: ${body.length}\r\n\r\n'),
      ...body,
    ];
    if (fragmentSizes == null) {
      _stdout.add(packet);
      return;
    }
    var offset = 0;
    for (final size in fragmentSizes) {
      if (offset >= packet.length) break;
      final end = (offset + size).clamp(0, packet.length);
      _stdout.add(packet.sublist(offset, end));
      offset = end;
    }
    if (offset < packet.length) _stdout.add(packet.sublist(offset));
  }

  @override
  Future<void> closeInput() async {
    inputClosed = true;
    await _stdout.close();
    await _stderr.close();
    if (!_exit.isCompleted) _exit.complete(0);
  }

  Future<void> closeOutputUnexpectedly() async {
    await _stdout.close();
  }

  @override
  Future<void> kill() async {
    killed = true;
    await closeInput();
  }
}
