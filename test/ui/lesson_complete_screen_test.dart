import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/exercise_models.dart';
import 'package:learn_gdscript/data/models/lesson_models.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/logic/providers/curriculum_provider.dart';
import 'package:learn_gdscript/logic/providers/lesson_provider.dart';
import 'package:learn_gdscript/logic/providers/progress_provider.dart';
import 'package:learn_gdscript/ui/screens/lesson/lesson_complete_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the lesson reward summary and returns to the path', (
    tester,
  ) async {
    final helper = DatabaseHelper(inMemory: true);
    final repository = ProgressRepository(helper);
    final progressProvider = ProgressProvider(repository);
    final curriculumRepository = CurriculumRepository(assetBundle: rootBundle);
    final curriculumProvider = CurriculumProvider(curriculumRepository);
    final lessonProvider = LessonProvider(curriculumRepository);
    final lesson = Lesson(
      id: 'lesson_01',
      unitId: 'unit_01',
      title: const LocalizedText(ar: 'الدرس الأول', en: 'First lesson'),
      objective: const LocalizedText(ar: 'هدف', en: 'Objective'),
      estimatedMinutes: 5,
      order: 0,
      contentMarkdown: const LocalizedText(ar: '', en: ''),
      exercises: const <Exercise>[],
    );
    lessonProvider.select(lesson);
    await progressProvider.initialize(
      visitorId: 'visitor',
      unitId: 'unit_01',
      lessonId: lesson.id,
    );
    await progressProvider.updateLesson(
      unitId: 'unit_01',
      lessonId: lesson.id,
      lessonProgress: LessonProgress(
        lessonId: lesson.id,
        status: LessonStatus.completed,
        exercisesCompleted: 2,
        exercisesTotal: 2,
        hintsUsed: 1,
      ),
    );
    await helper.close();
    addTearDown(() async {
      lessonProvider.dispose();
      progressProvider.dispose();
      curriculumProvider.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LessonProvider>.value(value: lessonProvider),
          ChangeNotifierProvider<ProgressProvider>.value(
            value: progressProvider,
          ),
          ChangeNotifierProvider<CurriculumProvider>.value(
            value: curriculumProvider,
          ),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const LessonCompleteScreen(
            lessonId: 'lesson_01',
            earnedXP: 35,
            hintsUsedCount: 1,
            timeSpentMinutes: 5,
          ),
          routes: {'/path': (_) => const Scaffold(body: Text('Learning path'))},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Completed lesson "First lesson"'), findsOneWidget);
    expect(find.text('+35 XP earned'), findsOneWidget);
    expect(find.text('2 exercises solved'), findsOneWidget);
    expect(find.text('1 hints used'), findsOneWidget);
    expect(find.text('5 minutes'), findsOneWidget);

    await tester.ensureVisible(find.text('Back to Path'));
    await tester.tap(find.text('Back to Path'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Learning path'), findsOneWidget);
  });
}
