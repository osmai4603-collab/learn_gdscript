import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/app_settings.dart';
import 'package:learn_gdscript/data/models/curriculum_models.dart';
import 'package:learn_gdscript/data/models/exercise_models.dart';
import 'package:learn_gdscript/data/models/lesson_models.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';

void main() {
  test('localized text chooses exact language and falls back to Arabic', () {
    const text = LocalizedText(ar: 'مرحبا', en: 'Hello');
    expect(text.resolve(const Locale('en')), 'Hello');
    expect(text.resolve(const Locale('ar')), 'مرحبا');
    expect(text.resolve(const Locale('fr')), 'مرحبا');
    expect(LocalizedText.fromJson(text.toJson()), text);
  });

  test('curriculum, lessons, and exercises round-trip as typed JSON', () {
    final input = <String, Object?>{
      'version': '1',
      'targetGDScriptVersion': '4',
      'units': [
        {
          'id': 'basics',
          'title': {'ar': 'الأساسيات', 'en': 'Basics'},
          'description': {'ar': 'وصف', 'en': 'Description'},
          'iconName': 'code',
          'order': 0,
          'lessonIds': ['first'],
        },
      ],
    };
    final curriculum = Curriculum.fromJson(input);
    expect(curriculum.toJson(), input);
    expect(() => curriculum.units.clear(), throwsUnsupportedError);

    final lessonInput = <String, Object?>{
      'id': 'first',
      'unitId': 'basics',
      'title': {'ar': 'الدرس الأول', 'en': 'First lesson'},
      'objective': {'ar': 'هدف', 'en': 'Objective'},
      'estimatedMinutes': 5,
      'order': 0,
      'contentMarkdown': {'ar': 'شرح', 'en': 'Explanation'},
      'exampleCode': 'print("hi")',
      'exercises': [
        {
          'id': 'print',
          'lessonId': 'first',
          'type': 'writeCode',
          'prompt': {'ar': 'اطبع', 'en': 'Print'},
          'starterCode': '',
          'solutionCode': 'print("hi")',
          'testCases': [
            {
              'description': {'ar': 'مخرج', 'en': 'Output'},
              'setupCode': null,
              'expectedOutput': 'hi',
              'ignoreWhitespace': false,
              'ignoreCase': false,
            },
          ],
          'hints': [
            {'ar': 'استخدم print', 'en': 'Use print'},
          ],
          'order': 0,
        },
      ],
    };
    final lesson = Lesson.fromJson(lessonInput);
    expect(lesson.toJson(), lessonInput);
    expect(lesson.exercises.single.type, ExerciseType.writeCode);
  });

  test('progress and settings round-trip optional fields and defaults', () {
    final input = <String, Object?>{
      'visitorId': 'visitor-1',
      'currentUnitId': 'basics',
      'currentLessonId': 'first',
      'totalXP': 20,
      'currentStreak': 2,
      'longestStreak': 3,
      'lastActiveDate': '2026-10-21T12:00:00.000',
      'lessonsProgress': {
        'first': {
          'lessonId': 'first',
          'status': 'inProgress',
          'exercisesCompleted': 1,
          'exercisesTotal': 2,
          'attempts': 3,
          'hintsUsed': 1,
          'startedAt': null,
          'completedAt': null,
          'savedCode': null,
          'exercisesWithSolutionViewed': <String>[],
          'exerciseAttempts': <String, int>{},
          'exerciseHints': <String, int>{},
        },
      },
      'earnedBadges': ['starter'],
      'earnedBadgeDates': <String, Object?>{},
      'xpTransactions': <Object?>[],
      'firstTrySolvedCount': 0,
      'syntaxExplorerUses': 0,
      'hasExecutedPrint': false,
    };
    final progress = UserProgress.fromJson(input);
    expect(progress.toJson(), input);

    final defaults = LessonProgress.fromJson({'lessonId': 'later'});
    expect(defaults.status, LessonStatus.notStarted);
    expect(defaults.exercisesCompleted, 0);
    expect(defaults.savedCode, isNull);
    expect(AppSettings().toJson(), {
      'language': 'ar',
      'themeMode': 'system',
      'themeVariant': 'academy',
      'hasCompletedOnboarding': false,
      'editorFontSize': 14,
      'showStreakInUi': true,
    });
    expect(
      AppSettings.fromJson({'language': 'en', 'themeMode': 'dark'}).themeMode,
      ThemeMode.dark,
    );
    expect(
      AppSettings.fromJson({
        'language': 'en',
        'themeMode': 'dark',
        'themeVariant': 'arabicIde',
      }).themeVariant,
      AppThemeVariant.arabicIde,
    );
  });

  test(
    'rejects missing fields, invalid types, enums, and inconsistent progress',
    () {
      expect(
        () => Unit.fromJson({
          'id': 'unit',
          'title': {'ar': 'عنوان', 'en': 'Title'},
          'description': {'ar': 'وصف', 'en': 'Description'},
          'iconName': 'code',
          'order': 'first',
          'lessonIds': [],
        }),
        throwsFormatException,
      );
      expect(
        () => Exercise.fromJson({
          'id': 'exercise',
          'lessonId': 'lesson',
          'type': 'unknown',
          'prompt': {'ar': 'سؤال', 'en': 'Prompt'},
          'starterCode': '',
          'solutionCode': '',
          'order': 0,
        }),
        throwsFormatException,
      );
      expect(
        () => AppSettings.fromJson({'language': 'fr', 'themeMode': 'dark'}),
        throwsFormatException,
      );
      expect(
        () => UserProgress(
          visitorId: 'visitor',
          currentUnitId: 'unit',
          currentLessonId: 'lesson',
          totalXP: 0,
          currentStreak: 3,
          longestStreak: 2,
          lastActiveDate: DateTime.utc(2026),
          lessonsProgress: const {},
          earnedBadges: const [],
        ),
        throwsArgumentError,
      );
    },
  );
}
