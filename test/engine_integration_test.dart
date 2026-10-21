import 'package:flutter_test/flutter_test.dart';
import 'package:gdscript_engine/gdscript_engine.dart';

void main() {
  test('executes a simple script and captures print output', () async {
    final engine = GDScriptEngine();
    addTearDown(engine.dispose);

    final result = await engine.execute('print("hello")');

    expect(result.isSuccess, isTrue, reason: result.errorMessage);
    expect(result.output, ['hello']);
  });
}
