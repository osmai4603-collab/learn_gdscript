import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/exercise_models.dart';
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
    this.fontSize = 14,
    this.onCodeChanged,
    this.onProgressChanged,
    this.onCompleted,
    this.onCompletionRequested,
    this.onFormatRequested,
  });

  final Exercise exercise;
  final int exerciseIndex;
  final int exerciseCount;
  final String? initialCode;
  final double fontSize;
  final ValueChanged<String>? onCodeChanged;
  final void Function(int attempts, int hintsUsed)? onProgressChanged;
  final VoidCallback? onCompleted;
  final Future<List<String>> Function(String code, int cursorOffset)?
  onCompletionRequested;
  final Future<String?> Function(String code)? onFormatRequested;

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
  String? _selectedPrediction;
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
      _showSolution = false;
      _attempts = 0;
      _hintsUsed = 0;
      _predictionCorrect = null;
      _selectedPrediction = null;
    }
  }

  Future<void> _runTests() async {
    setState(() {
      _running = true;
      _runError = null;
      _attempts++;
    });
    widget.onProgressChanged?.call(_attempts, _hintsUsed);
    try {
      final result = await context.read<TestRunnerService>().runTests(
        userCode: _code,
        testCases: widget.exercise.testCases,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _running = false;
      });
      if (result.allPassed) widget.onCompleted?.call();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _runError = error;
        _running = false;
      });
    }
  }

  void _choosePrediction(String choice) {
    final exercise = widget.exercise;
    if (exercise.testCases.isEmpty) return;
    final expected = exercise.testCases.first.expectedOutput;
    final passed = choice == expected;
    setState(() {
      _attempts++;
      _selectedPrediction = choice;
      _predictionCorrect = passed;
    });
    widget.onProgressChanged?.call(_attempts, _hintsUsed);
    if (passed) widget.onCompleted?.call();
  }

  void _reorderLines(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
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
      _selectedPrediction = null;
    });
    widget.onCodeChanged?.call(_code);
  }

  void _revealSolution() {
    setState(() {
      _code = widget.exercise.solutionCode;
      _orderedLines = _code.split('\n');
      _showSolution = true;
      _result = null;
    });
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
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              exercise.prompt.resolve(locale),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (isReorder)
              _ReorderSteps(lines: _orderedLines, onReorder: _reorderLines)
            else
              CodeEditorWidget(
                key: ValueKey(exercise.id),
                initialCode: _code,
                readOnly: isPrediction,
                fontSize: widget.fontSize,
                showActionBar: true,
                onCompletionRequested: widget.onCompletionRequested,
                onFormatRequested: widget.onFormatRequested,
                onChanged: (code) {
                  _code = code;
                  widget.onCodeChanged?.call(code);
                },
              ),
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
                      style: const TextStyle(fontFamily: 'monospace'),
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
    onReorder: onReorder,
    itemBuilder: (context, index) => Card(
      key: ValueKey('$index:${lines[index]}'),
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(
          lines[index],
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    ),
  );
}
