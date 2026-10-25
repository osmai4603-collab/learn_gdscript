import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/async_state.dart';
import 'package:learn_gdscript/data/models/curriculum_models.dart';
import 'package:learn_gdscript/data/models/learning_path_models.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/logic/providers/curriculum_provider.dart';
import 'package:learn_gdscript/logic/providers/learning_path_provider.dart';
import 'package:learn_gdscript/logic/providers/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads real lesson data and derives learning progress', () async {
    final database = DatabaseHelper(inMemory: true);
    final curriculumRepository = CurriculumRepository(
      assetBundle: _LearningPathBundle(),
    );
    final curriculumProvider = CurriculumProvider(curriculumRepository);
    final progressProvider = ProgressProvider(ProgressRepository(database));
    await curriculumProvider.load();
    await progressProvider.load('visitor');
    await progressProvider.initialize(
      visitorId: 'visitor',
      unitId: 'unit_01_intro',
      lessonId: 'lesson_01_intro',
    );
    final learningPathProvider = LearningPathProvider(
      curriculumRepository: curriculumRepository,
      curriculumProvider: curriculumProvider,
      progressProvider: progressProvider,
    );
    addTearDown(learningPathProvider.dispose);
    addTearDown(curriculumProvider.dispose);
    addTearDown(progressProvider.dispose);
    addTearDown(database.close);

    await learningPathProvider.load();

    expect(learningPathProvider.state.status, LoadStatus.data);
    var data = learningPathProvider.state.value!;
    expect(data.totalLessons, 2);
    expect(data.completedLessons, 0);
    expect(data.activeUnitIndex, 0);
    expect(data.activeLessonId, 'lesson_01_intro');
    expect(data.lessons['lesson_01_intro']!.title.ar, 'المقدمة');
    expect(data.lessons['lesson_01_intro']!.estimatedMinutes, 5);
    expect(data.isUnitLocked(1), isTrue);

    await progressProvider.updateLesson(
      unitId: 'unit_01_intro',
      lessonId: 'lesson_01_intro',
      lessonProgress: LessonProgress(
        lessonId: 'lesson_01_intro',
        status: LessonStatus.completed,
      ),
    );
    await learningPathProvider.refresh();

    data = learningPathProvider.state.value!;
    expect(data.completedLessons, 1);
    expect(data.activeUnitIndex, 1);
    expect(data.activeLessonId, 'lesson_02_next');
    expect(data.isUnitLocked(1), isFalse);
    expect(data.progressRatio, 0.5);

    final currentProgress = progressProvider.progress!;
    final staleProgress = UserProgress(
      visitorId: currentProgress.visitorId,
      currentUnitId: 'removed_unit',
      currentLessonId: 'removed_lesson',
      totalXP: currentProgress.totalXP,
      currentStreak: currentProgress.currentStreak,
      longestStreak: currentProgress.longestStreak,
      lastActiveDate: currentProgress.lastActiveDate,
      lessonsProgress: currentProgress.lessonsProgress,
      earnedBadges: currentProgress.earnedBadges,
    );
    final staleData = LearningPathData(
      curriculum: data.curriculum,
      lessons: data.lessons,
      progress: staleProgress,
    );
    expect(staleData.activeUnitIndex, 1);
    expect(staleData.activeLessonId, 'lesson_02_next');
  });

  test('uses safe zero progress for an empty curriculum', () {
    final data = LearningPathData(
      curriculum: Curriculum(
        version: '1',
        targetGDScriptVersion: '4',
        units: [],
      ),
      lessons: const {},
      progress: null,
    );
    expect(data.totalLessons, 0);
    expect(data.completedLessons, 0);
    expect(data.progressRatio, 0);
  });
}

class _LearningPathBundle extends CachingAssetBundle {
  _LearningPathBundle({String? manifest}) : manifest = manifest ?? _manifest;

  final String manifest;

  static const _manifest = '''
    {
      "version": "1",
      "targetGDScriptVersion": "4",
      "units": [
        {
          "id": "unit_01_intro",
          "title": {"ar": "المقدمة", "en": "Introduction"},
          "description": {"ar": "الوحدة الأولى", "en": "First unit"},
          "iconName": "school",
          "order": 0,
          "lessonIds": ["lesson_01_intro"]
        },
        {
          "id": "unit_02_next",
          "title": {"ar": "الوحدة التالية", "en": "Next unit"},
          "description": {"ar": "الوحدة الثانية", "en": "Second unit"},
          "iconName": "code",
          "order": 1,
          "lessonIds": ["lesson_02_next"]
        }
      ]
    }
  ''';

  @override
  Future<ByteData> load(String key) async {
    final source = switch (key) {
      'assets/curriculum/manifest.json' => manifest,
      _ when key.endsWith('lesson_01_intro.json') => _lesson(
        id: 'lesson_01_intro',
        unitId: 'unit_01_intro',
        title: 'المقدمة',
      ),
      _ when key.endsWith('lesson_02_next.json') => _lesson(
        id: 'lesson_02_next',
        unitId: 'unit_02_next',
        title: 'الدرس التالي',
      ),
      _ => throw StateError('Unexpected curriculum asset: $key'),
    };
    final bytes = Uint8List.fromList(utf8.encode(source));
    return ByteData.sublistView(bytes);
  }

  static String _lesson({
    required String id,
    required String unitId,
    required String title,
  }) => jsonEncode({
    'id': id,
    'unitId': unitId,
    'title': {'ar': title, 'en': title},
    'objective': {'ar': 'تعلم الأساسيات', 'en': 'Learn the basics'},
    'estimatedMinutes': 5,
    'order': 0,
    'contentMarkdown': {'ar': 'محتوى الدرس', 'en': 'Lesson content'},
    'exercises': [],
  });
}
