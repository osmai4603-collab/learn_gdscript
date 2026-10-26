import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/arabic_ide_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/exercise_models.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../../logic/services/test_runner_service.dart';
import '../code_editor/code_actions_bar.dart';
import '../code_editor/code_editor_widget.dart';
import '../output_panel/error_display.dart';
import 'hint_widget.dart';
import 'test_results_widget.dart';

class ExerciseWidget extends StatefulWidget {
  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.exerciseCount,
    this.initialCode,
    this.initialSolutionViewed = false,
    this.initialAttempts = 0,
    this.initialHintsUsed = 0,
    this.fontSize = 14,
    this.onCodeChanged,
    this.onProgressChanged,
    this.onCompleted,
    this.onExerciseCompleted,
    this.onSolutionViewed,
    this.onCompletionRequested,
  });

  final Exercise exercise;
  final int exerciseIndex;
  final int exerciseCount;
  final String? initialCode;
  final bool initialSolutionViewed;
  final int initialAttempts;
  final int initialHintsUsed;
  final double fontSize;
  final ValueChanged<String>? onCodeChanged;
  final void Function(int attempts, int hintsUsed)? onProgressChanged;
  final VoidCallback? onCompleted;
  final Future<void> Function(
    int attempts,
    int hintsUsed,
    bool usedSolution,
    String code,
  )?
  onExerciseCompleted;
  final VoidCallback? onSolutionViewed;
  final Future<List<String>> Function(String code, int cursorOffset)?
  onCompletionRequested;

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  late String _code;
  ExerciseResult? _result;
  Object? _runError;
  bool _running = false;
  bool _showSolution = false;
  bool? _predictionCorrect;
  int? _selectedOptionIndex;
  bool _guidedTaskCompleted = false;
  int _attempts = 0;
  int _hintsUsed = 0;
  late List<String> _orderedLines;

  @override
  void initState() {
    super.initState();
    _code =
        widget.initialCode ??
        (widget.exercise.type == ExerciseType.predictOutput
            ? widget.exercise.solutionCode
            : widget.exercise.starterCode);
    _orderedLines = _code.split('\n');
    _showSolution = widget.initialSolutionViewed;
    _attempts = widget.initialAttempts;
    _hintsUsed = widget.initialHintsUsed;
  }

  @override
  void didUpdateWidget(covariant ExerciseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _code =
          widget.initialCode ??
          (widget.exercise.type == ExerciseType.predictOutput
              ? widget.exercise.solutionCode
              : widget.exercise.starterCode);
      _orderedLines = _code.split('\n');
      _result = null;
      _runError = null;
      _running = false;
      _showSolution = widget.initialSolutionViewed;
      _attempts = widget.initialAttempts;
      _hintsUsed = widget.initialHintsUsed;
      _predictionCorrect = null;
      _selectedOptionIndex = null;
      _guidedTaskCompleted = false;
    }
  }

  Future<void> _runTests() async {
    setState(() {
      _running = true;
      _runError = null;
      _attempts++;
    });
    widget.onProgressChanged?.call(_attempts, _hintsUsed);
    final ExerciseResult result;
    try {
      result = await context.read<TestRunnerService>().runTests(
        userCode: _code,
        testCases: widget.exercise.testCases,
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _runError = error;
        _running = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _result = result;
      _running = false;
    });
    if (result.allPassed) {
      await widget.onExerciseCompleted?.call(
        _attempts,
        _hintsUsed,
        _showSolution,
        _code,
      );
      if (mounted) widget.onCompleted?.call();
    }
  }

  Future<void> _choosePrediction(String choice) async {
    final exercise = widget.exercise;
    if (exercise.testCases.isEmpty) return;
    final expected = exercise.testCases.first.expectedOutput;
    final passed = choice == expected;
    setState(() {
      _attempts++;
      _predictionCorrect = passed;
    });
    widget.onProgressChanged?.call(_attempts, _hintsUsed);
    if (passed) {
      await widget.onExerciseCompleted?.call(
        _attempts,
        _hintsUsed,
        _showSolution,
        _code,
      );
      if (mounted) widget.onCompleted?.call();
    }
  }

  Future<void> _submitChoice() async {
    final exercise = widget.exercise;
    final selected = _selectedOptionIndex;
    if (selected == null || exercise.correctOptionIndex == null) return;
    final passed = selected == exercise.correctOptionIndex;
    setState(() {
      _attempts++;
      _predictionCorrect = passed;
    });
    widget.onProgressChanged?.call(_attempts, _hintsUsed);
    if (passed) {
      await widget.onExerciseCompleted?.call(
        _attempts,
        _hintsUsed,
        false,
        '',
      );
      if (mounted) widget.onCompleted?.call();
    }
  }

  Future<void> _completeGuidedTask() async {
    if (_guidedTaskCompleted) return;
    setState(() {
      _attempts++;
      _guidedTaskCompleted = true;
    });
    widget.onProgressChanged?.call(_attempts, _hintsUsed);
    await widget.onExerciseCompleted?.call(
      _attempts,
      _hintsUsed,
      false,
      '',
    );
    if (mounted) widget.onCompleted?.call();
  }

  void _reorderLines(int oldIndex, int newIndex) {
    setState(() {
      final line = _orderedLines.removeAt(oldIndex);
      _orderedLines.insert(newIndex, line);
      _code = _orderedLines.join('\n');
    });
    widget.onCodeChanged?.call(_code);
  }

  Future<void> _reset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(context.l10n.resetCodeConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.resetCode),
          ),
        ],
      ),
    );
    if (shouldReset != true || !mounted) return;
    setState(() {
      _code = widget.exercise.starterCode;
      _orderedLines = _code.split('\n');
      _result = null;
      _runError = null;
      _showSolution = false;
      _predictionCorrect = null;
    });
    widget.onCodeChanged?.call(_code);
  }

  void _revealSolution() {
    final wasAlreadyViewed = _showSolution;
    setState(() {
      _code = widget.exercise.solutionCode;
      _orderedLines = _code.split('\n');
      _showSolution = true;
      _result = null;
    });
    if (!wasAlreadyViewed) widget.onSolutionViewed?.call();
    widget.onCodeChanged?.call(_code);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final locale = Localizations.localeOf(context);
    final canShowSolution =
        _attempts >= 3 || _hintsUsed >= exercise.hints.length;
    final isPrediction = exercise.type == ExerciseType.predictOutput;
    final isReorder = exercise.type == ExerciseType.reorderSteps;
    final isMultipleChoice = exercise.type == ExerciseType.multipleChoice;
    final isGuidedTask = exercise.type == ExerciseType.guidedTask;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.exerciseProgress(
                widget.exerciseIndex + 1,
                widget.exerciseCount,
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              exercise.prompt.resolve(locale),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            if (isReorder)
              _ReorderSteps(lines: _orderedLines, onReorder: _reorderLines)
            else if (!isMultipleChoice && !isGuidedTask)
              CodeEditorWidget(
                key: ValueKey(exercise.id),
                initialCode: _code,
                readOnly: isPrediction,
                fontSize: widget.fontSize,
                showActionBar: true,
                onCompletionRequested:
                    widget.onCompletionRequested ??
                    (code, offset) async => context
                        .read<CodeRunnerService>()
                        .getCompletions(code, offset),
                onSyntaxHighlightsRequested: context
                    .read<CodeRunnerService>()
                    .getSyntaxHighlights,
                onDiagnosticsRequested: context
                    .read<CodeRunnerService>()
                    .getDiagnostics,
                onChanged: (code) {
                  _code = code;
                  widget.onCodeChanged?.call(code);
                },
              ),
            if (isGuidedTask) ...[
              for (var index = 0; index < exercise.steps.length; index++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(exercise.steps[index].resolve(locale)),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _guidedTaskCompleted ? null : _completeGuidedTask,
                icon: const Icon(Icons.check),
                label: Text(
                  locale.languageCode == 'en'
                      ? 'Mark task complete'
                      : 'تأكيد إكمال المهمة',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  locale.languageCode == 'en'
                      ? 'Completion is self-reported and is not checked by the code runner.'
                      : 'إكمال هذه المهمة ذاتيّ التأكيد ولا يفحصه مشغّل الكود.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            if (isMultipleChoice) ...[
              RadioGroup(
                groupValue: _selectedOptionIndex,
                onChanged: (value) {
                        if (_predictionCorrect == true) return;
                        setState(() => _selectedOptionIndex = value);
                      },
                child: Column(
                  children: [
                    for (var index = 0; index < exercise.options.length; index++)
                RadioListTile<int>(
                  value: index,
                  title: Text(exercise.options[index].resolve(locale)),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _predictionCorrect == true || _selectedOptionIndex == null
                    ? null
                    : _submitChoice,
                child: Text(
                  locale.languageCode == 'en' ? 'Check answer' : 'تحقق من الإجابة',
                ),
              ),
              if (_predictionCorrect != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _predictionCorrect!
                        ? context.l10n.testPassed
                        : context.l10n.testFailed,
                    style: TextStyle(
                      color: _predictionCorrect!
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
            if (isPrediction) ...[
              const SizedBox(height: 12),
              for (final option in _predictionOptions(
                exercise.testCases.isEmpty
                    ? ''
                    : exercise.testCases.first.expectedOutput,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: _predictionCorrect == true
                        ? null
                        : () => _choosePrediction(option),
                    child: Text(
                      option.isEmpty ? '""' : option,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: ArabicIdeTheme.codeFontFamily(context),
                      ),
                    ),
                  ),
                ),
              if (_predictionCorrect != null)
                Text(
                  _predictionCorrect!
                      ? context.l10n.testPassed
                      : context.l10n.testFailed,
                  style: TextStyle(
                    color: _predictionCorrect!
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            if (!isMultipleChoice && !isGuidedTask)
              CodeActionsBar(
                onReset: isPrediction ? null : _reset,
                onRun: isPrediction || _running ? null : _runTests,
                canShowSolution: !isPrediction && canShowSolution,
                onSolution: isPrediction ? null : _revealSolution,
              ),
            if (_showSolution) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.showSolution,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
            const SizedBox(height: 12),
            HintWidget(
              key: ValueKey('${exercise.id}-hints'),
              hints: exercise.hints,
              initialVisibleHints: _hintsUsed,
              onHintRevealed: (count) {
                _hintsUsed = count;
                widget.onProgressChanged?.call(_attempts, _hintsUsed);
                setState(() {});
              },
            ),
            if (_running) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
            if (_runError != null) ...[
              const SizedBox(height: 8),
              ErrorDisplay(
                message: '${context.l10n.executionFailed} $_runError',
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 8),
              TestResultsWidget(
                results: _result!.testResults,
                allPassed: _result!.allPassed,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static List<String> _predictionOptions(String expected) {
    final reversedLines = expected.split('\n').reversed.join('\n');
    final candidates = <String>[
      expected,
      reversedLines == expected ? '$expected!' : reversedLines,
      '$expected!',
      'null',
      '0',
      'true',
      'false',
      'String',
      'int',
      'float',
    ];
    final choices = <String>[];
    for (final candidate in candidates) {
      if (!choices.contains(candidate)) choices.add(candidate);
      if (choices.length == 4) break;
    }
    return choices;
  }
}

class _ReorderSteps extends StatelessWidget {
  const _ReorderSteps({required this.lines, required this.onReorder});

  final List<String> lines;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) => ReorderableListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: lines.length,
    onReorderItem: onReorder,
    itemBuilder: (context, index) => Card(
      key: ValueKey('$index:${lines[index]}'),
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(
          lines[index],
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: ArabicIdeTheme.codeFontFamily(context),
          ),
        ),
      ),
    ),
  );
}
