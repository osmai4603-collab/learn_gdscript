import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/logic/services/language_server_client.dart';
import 'package:learn_gdscript/logic/services/lsp_transport.dart';

import 'helpers/fake_lsp_transport.dart';

void main() {
  test('decodes split UTF-8 frames and multiple frames in one chunk', () {
    final decoder = LspFrameDecoder();
    final first = _frame({'method': 'message', 'params': {'text': 'مرحبا'}});
    final second = _frame({'method': 'ready'});
    final split = first.length ~/ 2;

    expect(decoder.add(first.sublist(0, split)), isEmpty);
    final messages = decoder.add([...first.sublist(split), ...second]);
    expect(messages, hasLength(2));
    expect(messages.first['params'], {'text': 'مرحبا'});
    expect(messages.last['method'], 'ready');
  });

  test('matches concurrent responses by id and reports JSON-RPC errors', () async {
    final transport = FakeLspTransport(
      serverCapabilities: {'completionProvider': true},
    );
    final client = LanguageServerClient(transport);
    addTearDown(client.dispose);
    await client.initialize();
    transport.autoRespond = false;

    final first = client.requestCancelable('first', const {});
    final second = client.requestCancelable('second', const {});
    final requests = transport.messages
        .where((message) => message['id'] is int)
        .toList();
    final firstId = requests[1]['id'] as int;
    final secondId = requests[2]['id'] as int;
    transport.respond(secondId, result: 'second-result');
    transport.respond(firstId, result: 'first-result');
    expect(await first.result, 'first-result');
    expect(await second.result, 'second-result');

    transport.autoRespond = true;
    transport.errorMethod = 'fails';
    await expectLater(
      client.request('fails', const {}),
      throwsA(isA<LspRpcException>()),
    );
  });

  test('cancels requests and rejects features absent from capabilities', () async {
    final transport = FakeLspTransport(
      serverCapabilities: {'completionProvider': true},
    );
    final client = LanguageServerClient(transport);
    addTearDown(client.dispose);
    await client.initialize();

    expect(
      () => client.hover(Uri.parse('file:///main.gd'), 0, 0),
      throwsUnsupportedError,
    );
    final request = client.requestCancelable('longTask', const {});
    await request.cancel();
    expect(
      transport.messages.last['method'],
      r'$/cancelRequest',
    );
    transport.respond(request.id, result: null);
    expect(await request.result, isNull);
  });

  test('shutdown sends request then exit and closes transport', () async {
    final transport = FakeLspTransport();
    final client = LanguageServerClient(transport);
    await client.initialize();
    await client.shutdown();

    expect(
      transport.messages.map((message) => message['method']),
      containsAllInOrder(['initialize', 'initialized', 'shutdown', 'exit']),
    );
    expect(transport.inputClosed, isTrue);
  });

  test('fails pending requests when stdout closes unexpectedly', () async {
    final transport = FakeLspTransport();
    final client = LanguageServerClient(transport);
    await client.initialize();
    transport.autoRespond = false;
    final request = client.requestCancelable('wait', const {});
    await transport.closeOutputUnexpectedly();
    await expectLater(request.result, throwsStateError);
    await client.dispose();
  });
}

List<int> _frame(Map<String, Object?> message) {
  final body = utf8.encode(jsonEncode(message));
  return [...ascii.encode('Content-Length: ${body.length}\r\n\r\n'), ...body];
}
