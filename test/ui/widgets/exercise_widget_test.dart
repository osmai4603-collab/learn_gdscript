import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/exercise_models.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/logic/services/code_runner_service.dart';
import 'package:learn_gdscript/logic/services/test_runner_service.dart';
import 'package:learn_gdscript/ui/widgets/exercise/exercise_widget.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('multiple-choice exercises verify the selected answer', (
    tester,
  ) async {
    final runner = CodeRunnerService();
    addTearDown(runner.dispose);
    var completed = false;
    final exercise = Exercise(
      id: 'choice',
      lessonId: 'lesson',
      type: ExerciseType.multipleChoice,
      prompt: const LocalizedText(ar: 'اختر', en: 'Choose'),
      options: const [
        LocalizedText(ar: 'خطأ', en: 'Incorrect'),
        LocalizedText(ar: 'صحيح', en: 'Correct'),
      ],
      correctOptionIndex: 1,
      testCases: const [],
      hints: const [],
      order: 0,
    );

    await tester.pumpWidget(
      _localizedApp(
        ExerciseWidget(
          exercise: exercise,
          exerciseIndex: 0,
          exerciseCount: 1,
          onCompleted: () => completed = true,
        ),
        runner,
      ),
    );

    await tester.tap(find.text('Correct'));
    await tester.pump();
    await tester.tap(find.text('Check answer'));
    await tester.pumpAndSettle();

    expect(find.text('Passed'), findsOneWidget);
    expect(completed, isTrue);
  });

  testWidgets('guided tasks clearly identify self-reported completion', (
    tester,
  ) async {
    final runner = CodeRunnerService();
    addTearDown(runner.dispose);
    var completed = 0;
    final exercise = Exercise(
      id: 'guided',
      lessonId: 'lesson',
      type: ExerciseType.guidedTask,
      prompt: const LocalizedText(ar: 'أنشئ مشهداً', en: 'Create a scene'),
      steps: const [LocalizedText(ar: 'أضف عقدة جذر', en: 'Add a root node')],
      testCases: const [],
      hints: const [],
      order: 0,
    );

    await tester.pumpWidget(
      _localizedApp(
        ExerciseWidget(
          exercise: exercise,
          exerciseIndex: 0,
          exerciseCount: 1,
          onCompleted: () => completed++,
        ),
        runner,
      ),
    );

    expect(
      find.text(
        'Completion is self-reported and is not checked by the code runner.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Mark task complete'));
    await tester.pumpAndSettle();

    expect(completed, 1);
  });

  testWidgets('predict-output exercises show code and allow retrying', (
    tester,
  ) async {
    final runner = CodeRunnerService();
    addTearDown(runner.dispose);
    var completed = false;
    final exercise = _exercise(
      type: ExerciseType.predictOutput,
      starterCode: '',
      solutionCode: 'print(2)',
      expectedOutput: '2',
    );

    await tester.pumpWidget(
      _localizedApp(
        ExerciseWidget(
          exercise: exercise,
          exerciseIndex: 0,
          exerciseCount: 1,
          fontSize: 16,
          onCompleted: () => completed = true,
        ),
        runner,
      ),
    );

    final codeField = tester.widget<TextField>(find.byType(TextField));
    expect(codeField.readOnly, isTrue);
    expect(codeField.controller!.text, 'print(2)');
    expect(codeField.style!.fontSize, 16);

    await tester.tap(find.text('2!'));
    await tester.pump();
    expect(find.text('Failed'), findsOneWidget);
    expect(completed, isFalse);

    await tester.tap(find.text('2'));
    await tester.pump();
    expect(find.text('Passed'), findsOneWidget);
    expect(completed, isTrue);
  });

  testWidgets('reorder exercises expose draggable lines and run actions', (
    tester,
  ) async {
    final runner = CodeRunnerService();
    addTearDown(runner.dispose);
    var changedCode = '';
    var completed = false;
    final exercise = _exercise(
      type: ExerciseType.reorderSteps,
      starterCode:
          'print(message)\nvar number = 7\nprint(number)\nvar message = "Ready"',
      solutionCode:
          'var number = 7\nvar message = "Ready"\nprint(number)\nprint(message)',
      expectedOutput: '7\nReady',
    );

    await tester.pumpWidget(
      _localizedApp(
        Provider<TestRunnerService>(
          create: (_) => TestRunnerService(runner),
          child: ExerciseWidget(
            exercise: exercise,
            exerciseIndex: 0,
            exerciseCount: 1,
            onCodeChanged: (code) => changedCode = code,
            onCompleted: () => completed = true,
          ),
        ),
        runner,
      ),
    );

    expect(find.byType(ReorderableListView), findsOneWidget);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('print(message)')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(tester.getCenter(find.text('var message = "Ready"')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(changedCode, startsWith('var number = 7'));
    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });
}

Widget _localizedApp(Widget child, CodeRunnerService runner) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: Scaffold(
    body: Provider<CodeRunnerService>.value(
      value: runner,
      child: SingleChildScrollView(child: child),
    ),
  ),
);

Exercise _exercise({
  required ExerciseType type,
  required String starterCode,
  required String solutionCode,
  required String expectedOutput,
}) => Exercise(
  id: 'exercise',
  lessonId: 'lesson',
  type: type,
  prompt: const LocalizedText(ar: 'تمرين', en: 'Exercise'),
  starterCode: starterCode,
  solutionCode: solutionCode,
  testCases: [
    ExerciseTestCase(
      description: const LocalizedText(ar: 'الناتج', en: 'Output'),
      expectedOutput: expectedOutput,
    ),
  ],
  hints: const [],
  order: 0,
);
