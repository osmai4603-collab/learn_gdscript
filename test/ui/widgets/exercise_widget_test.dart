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
  testWidgets('predict-output exercises show code and allow retrying', (
    tester,
  ) async {
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
          onCompleted: () => completed = true,
        ),
      ),
    );

    final codeField = tester.widget<TextField>(find.byType(TextField));
    expect(codeField.readOnly, isTrue);
    expect(codeField.controller!.text, 'print(2)');

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

Widget _localizedApp(Widget child) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: Scaffold(body: SingleChildScrollView(child: child)),
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
