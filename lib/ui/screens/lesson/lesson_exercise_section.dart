import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/exercise_models.dart';
import '../../../data/models/lesson_models.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/exercise/exercise_widget.dart';

class LessonExerciseSection extends StatelessWidget {
  const LessonExerciseSection({
    super.key,
    required this.lesson,
    required this.exerciseIndex,
    required this.savedCode,
    required this.solutionViewedExerciseIds,
    required this.exerciseAttempts,
    required this.exerciseHints,
    required this.onCodeChanged,
    required this.onProgressChanged,
    required this.onExerciseCompleted,
    required this.onSolutionViewed,
  });

  final Lesson lesson;
  final int exerciseIndex;
  final String? savedCode;
  final Set<String> solutionViewedExerciseIds;
  final Map<String, int> exerciseAttempts;
  final Map<String, int> exerciseHints;
  final ValueChanged<String> onCodeChanged;
  final void Function(Exercise exercise, int attempts, int hintsUsed)
  onProgressChanged;
  final Future<void> Function(
    Exercise exercise,
    int attempts,
    int hintsUsed,
    bool usedSolution,
    String code,
  )
  onExerciseCompleted;
  final ValueChanged<String> onSolutionViewed;

  @override
  Widget build(BuildContext context) {
    if (lesson.exercises.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        message: context.l10n.noLessons,
      );
    }
    final index = exerciseIndex.clamp(0, lesson.exercises.length - 1).toInt();
    final exercise = lesson.exercises[index];
    return ExerciseWidget(
      key: ValueKey(exercise.id),
      exercise: exercise,
      exerciseIndex: index,
      exerciseCount: lesson.exercises.length,
      initialCode: savedCode,
      initialSolutionViewed: solutionViewedExerciseIds.contains(exercise.id),
      initialAttempts: exerciseAttempts[exercise.id] ?? 0,
      initialHintsUsed: exerciseHints[exercise.id] ?? 0,
      onCodeChanged: onCodeChanged,
      onProgressChanged: (attempts, hintsUsed) =>
          onProgressChanged(exercise, attempts, hintsUsed),
      onExerciseCompleted: (attempts, hintsUsed, usedSolution, code) =>
          onExerciseCompleted(
            exercise,
            attempts,
            hintsUsed,
            usedSolution,
            code,
          ),
      onSolutionViewed: () => onSolutionViewed(exercise.id),
      fontSize: context.watch<AppSettingsProvider>().editorFontSize.toDouble(),
    );
  }
}
