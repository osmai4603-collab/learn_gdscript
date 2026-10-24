import 'dart:io';

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
