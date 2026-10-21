import 'dart:async';
import 'dart:convert';

abstract interface class LspTransport {
  Stream<List<int>> get stdoutBytes;
  Stream<List<int>> get stderrBytes;
  Future<void> write(List<int> bytes);
  Future<void> closeInput();
  Future<int> get exitCode;
  Future<void> kill();
}

class LspRpcException implements Exception {
  const LspRpcException(this.code, this.message, {this.data});

  final int code;
  final String message;
  final Object? data;

  @override
  String toString() => 'LSP JSON-RPC error $code: $message';
}

class LspNotification {
  const LspNotification(this.method, this.params);

  final String method;
  final Map<String, Object?> params;
}

class LspFrameDecoder {
  LspFrameDecoder({this.maximumFrameBytes = 4 * 1024 * 1024});

  final int maximumFrameBytes;
  final List<int> _buffer = [];

  List<Map<String, Object?>> add(List<int> bytes) {
    _buffer.addAll(bytes);
    final messages = <Map<String, Object?>>[];
    while (true) {
      final headerEnd = _headerEnd();
      if (headerEnd == -1) {
        if (_buffer.length > 8192) {
          throw const FormatException('LSP header exceeds 8192 bytes.');
        }
        return messages;
      }
      final header = String.fromCharCodes(_buffer.sublist(0, headerEnd));
      final length = _contentLength(header);
      if (length > maximumFrameBytes) {
        throw FormatException('LSP frame exceeds $maximumFrameBytes bytes.');
      }
      final bodyStart = headerEnd + 4;
      if (_buffer.length - bodyStart < length) return messages;
      final body = utf8.decode(_buffer.sublist(bodyStart, bodyStart + length));
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('LSP JSON-RPC frame must be an object.');
      }
      try {
        messages.add(Map<String, Object?>.from(decoded));
      } on TypeError {
        throw const FormatException('LSP JSON-RPC frame keys must be strings.');
      }
      _buffer.removeRange(0, bodyStart + length);
    }
  }

  int _headerEnd() {
    for (var index = 0; index <= _buffer.length - 4; index++) {
      if (_buffer[index] == 13 &&
          _buffer[index + 1] == 10 &&
          _buffer[index + 2] == 13 &&
          _buffer[index + 3] == 10) {
        return index;
      }
    }
    return -1;
  }

  int _contentLength(String header) {
    for (final line in header.split('\r\n')) {
      final separator = line.indexOf(':');
      if (separator < 0 ||
          line.substring(0, separator).trim().toLowerCase() !=
              'content-length') {
        continue;
      }
      final parsed = int.tryParse(line.substring(separator + 1).trim());
      if (parsed == null || parsed < 0) {
        throw const FormatException('Invalid LSP Content-Length header.');
      }
      return parsed;
    }
    throw const FormatException('LSP frame is missing Content-Length.');
  }
}
