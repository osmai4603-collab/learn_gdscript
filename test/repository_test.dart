import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/models/onboarding_draft.dart';
import 'package:learn_gdscript/data/repositories/onboarding_repository.dart';
import 'package:learn_gdscript/data/repositories/workspace_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/logic/providers/onboarding_provider.dart';

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
    await expectLater(
      repository.loadCurriculum(),
      throwsA(isA<ManifestParseException>()),
    );
    final wrongSchema = CurriculumRepository(
      assetBundle: _TestAssetBundle('{"version":"1","units":[]}'),
      manifestAsset: 'test.json',
    );
    await expectLater(
      wrongSchema.loadCurriculum(),
      throwsA(isA<ManifestParseException>()),
    );
  });

  test('surfaces lesson not found and malformed lesson errors', () async {
    final manifestContent = '''
    {
      "version": "1.0.0",
      "targetGDScriptVersion": "4.x",
      "units": [
        {
          "id": "unit_01_first",
          "title": {"ar": "عنوان", "en": "Title"},
          "description": {"ar": "وصف", "en": "Desc"},
          "iconName": "icon",
          "order": 0,
          "lessonIds": ["lesson_01_hello", "lesson_02_broken"]
        }
      ]
    }
    ''';
    final assetMap = <String, String>{
      'assets/curriculum/manifest.json': manifestContent,
      'assets/curriculum/units/01_first/lesson_01_hello.json': '{"invalid": json}',
      'assets/curriculum/units/01_first/lesson_02_broken.json': '',
    };
    final repository = CurriculumRepository(
      assetBundle: _MapAssetBundle(assetMap),
    );
    final curriculum = await repository.loadCurriculum();

    await expectLater(
      repository.loadLesson(curriculum, 'unknown_lesson'),
      throwsA(isA<LessonNotFoundException>()),
    );

    await expectLater(
      repository.loadLesson(curriculum, 'lesson_01_hello'),
      throwsA(isA<LessonParseException>()),
    );

    await expectLater(
      repository.loadLesson(curriculum, 'lesson_02_broken'),
      throwsA(isA<LessonParseException>()),
    );
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

  test(
    'workspace repository saves indexed GDScript to disk and snapshot',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workspace-save-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final script = File('${directory.path}/main.gd');
      await script.writeAsString('var value = 1');
      final helper = DatabaseHelper(inMemory: true);
      addTearDown(helper.close);
      final repository = WorkspaceRepository(helper);
      await repository.setWorkspace(directory.path, [
        WorkspaceFileSnapshot(
          uri: script.uri.toString(),
          relativePath: 'main.gd',
          content: 'var value = 1',
          modifiedMillis: 1,
        ),
      ]);

      await repository.saveGDScriptFile(script.uri.toString(), 'var value = 2');

      expect(await script.readAsString(), 'var value = 2');
      expect((await repository.loadFiles()).single.content, 'var value = 2');
    },
  );

  test(
    'workspace repository does not write files outside indexed snapshot',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workspace-save-unindexed-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final script = File('${directory.path}/unindexed.gd');
      await script.writeAsString('var value = 1');
      final helper = DatabaseHelper(inMemory: true);
      addTearDown(helper.close);
      final repository = WorkspaceRepository(helper);
      await repository.setWorkspace(directory.path, const []);

      await expectLater(
        repository.saveGDScriptFile(script.uri.toString(), 'var value = 2'),
        throwsStateError,
      );

      expect(await script.readAsString(), 'var value = 1');
    },
  );

  test(
    'workspace discovery excludes hidden, generated, and linked paths',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workspace-discovery-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final nested = Directory('${directory.path}/scripts');
      final hidden = Directory('${directory.path}/.hidden');
      final generated = Directory('${directory.path}/build');
      await nested.create();
      await hidden.create();
      await generated.create();
      await File('${directory.path}/main.gd').writeAsString('extends Node');
      await File('${nested.path}/helper.gd').writeAsString('class_name Helper');
      await File('${directory.path}/notes.txt').writeAsString('ignored');
      await File('${hidden.path}/secret.gd').writeAsString('var secret = true');
      await File(
        '${generated.path}/generated.gd',
      ).writeAsString('var generated = true');

      if (!Platform.isWindows) {
        await Link('${directory.path}/linked').create(nested.path);
      }

      final helper = DatabaseHelper(inMemory: true);
      addTearDown(helper.close);
      final repository = WorkspaceRepository(helper);
      final discovered = await repository.discoverAndSetWorkspace(
        directory.path,
      );

      expect(discovered.map((file) => file.relativePath), [
        'main.gd',
        'scripts/helper.gd',
      ]);
      expect((await repository.loadFiles()).map((file) => file.relativePath), [
        'main.gd',
        'scripts/helper.gd',
      ]);
    },
  );

  test(
    'workspace text search is case-insensitive and reports locations',
    () async {
      final helper = DatabaseHelper(inMemory: true);
      addTearDown(helper.close);
      final repository = WorkspaceRepository(helper);
      await repository.setWorkspace('/project', const [
        WorkspaceFileSnapshot(
          uri: 'file:///project/main.gd',
          relativePath: 'main.gd',
          content: 'var Player = "player"\nprint(PLAYER)',
          modifiedMillis: 1,
        ),
      ]);

      final matches = await repository.searchText('player');

      expect(
        matches.map((match) => (match.relativePath, match.line, match.column)),
        [('main.gd', 1, 5), ('main.gd', 1, 15), ('main.gd', 2, 7)],
      );
      expect(
        (await repository.searchText(
          'player',
          caseSensitive: true,
        )).map((match) => (match.line, match.column)),
        [(1, 15)],
      );
      await expectLater(repository.searchText('  '), throwsArgumentError);
    },
  );

  test(
    'onboarding draft persists and restores after reopening the database',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'onboarding-persistence-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final databasePath = '${directory.path}/learning.sqlite';
      final firstHelper = DatabaseHelper(
        databasePathProvider: () async => databasePath,
      );
      final repository = OnboardingRepository(firstHelper);
      final draft = OnboardingDraft(
        currentStep: 2,
        selectedTier: ExperienceTier.godotVeteran,
        currentQuestionIndex: 2,
        selectedAnswers: const [1, 0, 3],
      );
      await repository.save('visitor', draft);
      await firstHelper.close();

      final reopenedHelper = DatabaseHelper(
        databasePathProvider: () async => databasePath,
      );
      final reopenedRepository = OnboardingRepository(reopenedHelper);
      final restoredProvider = OnboardingProvider(reopenedRepository);
      await restoredProvider.load('visitor');
      expect(restoredProvider.draft?.currentStep, 2);
      expect(restoredProvider.draft?.selectedTier, ExperienceTier.godotVeteran);
      expect(restoredProvider.draft?.currentQuestionIndex, 2);
      expect(restoredProvider.draft?.questionIds, onboardingQuestionIds);
      expect(restoredProvider.draft?.selectedAnswers, [1, 0, 3]);

      await reopenedRepository.save(
        'visitor',
        draft.copyWith(
          currentStep: 3,
          recommendedUnitId: 'unit_03',
          recommendedLessonId: 'lesson_03',
          status: OnboardingStatus.completed,
        ),
      );
      final completedDraft = await reopenedRepository.load('visitor');
      expect(completedDraft?.currentStep, 3);
      expect(completedDraft?.recommendedUnitId, 'unit_03');
      expect(completedDraft?.recommendedLessonId, 'lesson_03');
      expect(completedDraft?.status, OnboardingStatus.completed);
      restoredProvider.dispose();
      await reopenedHelper.close();
    },
  );
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

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final content = assets[key];
    if (content == null) {
      throw FlutterError('Asset not found: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(content));
    return ByteData.view(bytes.buffer);
  }
}
