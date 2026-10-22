import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/repositories/workspace_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads the empty curriculum manifest through its asset abstraction',
    () async {
      final repository = CurriculumRepository(
        assetBundle: _TestAssetBundle(
          '{"version":"1","targetGDScriptVersion":"4","units":[]}',
        ),
      );
      final curriculum = await repository.loadCurriculum();
      expect(curriculum.version, '1');
      expect(curriculum.targetGDScriptVersion, '4');
      expect(curriculum.units, isEmpty);
    },
  );

  test('surfaces malformed curriculum JSON and schema errors', () async {
    final repository = CurriculumRepository(
      assetBundle: _TestAssetBundle('{"version":'),
      manifestAsset: 'test.json',
    );
    await expectLater(repository.loadCurriculum(), throwsFormatException);
    final wrongSchema = CurriculumRepository(
      assetBundle: _TestAssetBundle('{"version":"1","units":[]}'),
      manifestAsset: 'test.json',
    );
    await expectLater(wrongSchema.loadCurriculum(), throwsFormatException);
  });

  test('workspace repository replaces complete snapshots atomically', () async {
    final helper = DatabaseHelper(inMemory: true);
    final repository = WorkspaceRepository(helper);
    await repository.setWorkspace('/project', const [
      WorkspaceFileSnapshot(
        uri: 'file:///project/main.gd',
        relativePath: 'main.gd',
        content: 'var value = 1',
        modifiedMillis: 1,
      ),
    ]);
    expect(await repository.getRootPath(), '/project');
    expect((await repository.loadFiles()).single.content, 'var value = 1');

    await repository.replaceFiles(const [
      WorkspaceFileSnapshot(
        uri: 'file:///project/helper.gd',
        relativePath: 'helper.gd',
        content: 'class_name Helper',
        modifiedMillis: 2,
      ),
    ]);
    expect((await repository.loadFiles()).map((file) => file.relativePath), [
      'helper.gd',
    ]);
    expect(await repository.getRootPath(), '/project');
    await helper.close();
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  _TestAssetBundle(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(content.codeUnits);
    return ByteData.view(bytes.buffer);
  }
}
