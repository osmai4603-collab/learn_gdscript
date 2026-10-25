import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/repositories/syntax_reference_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads, searches, and filters bilingual syntax references', () async {
    final repository = AssetSyntaxReferenceRepository(assetBundle: rootBundle);

    final allEntries = await repository.search('');
    expect(allEntries, hasLength(37));
    expect(
      (await repository.search('متغير')).map((entry) => entry.id),
      contains('var'),
    );
    expect(
      (await repository.search('variable')).map((entry) => entry.id),
      contains('var'),
    );

    final loopEntries = await repository.search('', category: 'loops');
    expect(loopEntries.map((entry) => entry.id), [
      'for',
      'in',
      'while',
      'break',
      'continue',
    ]);
    final printEntry = await repository.search('print', category: 'output');
    expect(printEntry.single.title.en, 'Print');
    expect(printEntry.single.title.ar, 'طباعة');
  });

  test('retries loading assets after a failed initial load', () async {
    final repository = AssetSyntaxReferenceRepository(
      assetBundle: _FailOnceAssetBundle(),
    );

    await expectLater(repository.search(''), throwsStateError);
    expect(await repository.search(''), hasLength(37));
  });
}

class _FailOnceAssetBundle extends CachingAssetBundle {
  bool _shouldFail = true;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_shouldFail) {
      _shouldFail = false;
      throw StateError('Temporary asset load failure.');
    }
    return rootBundle.loadString(key);
  }

  @override
  Future<ByteData> load(String key) => rootBundle.load(key);
}
