import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/arabic_ide_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/exercise_models.dart';
import '../../../data/models/gamification_models.dart';
import '../../../data/models/lesson_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/lesson_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../routers/app_routes.dart';
import '../../layouts/adaptive_layout.dart';
import '../../layouts/lesson_layout_mobile.dart';
import 'desktop_lesson_ide_flutter_dart.dart';
import '../../widgets/code_directionality.dart';
import '../../widgets/code_editor/code_editor_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/exercise/exercise_widget.dart';
import '../../widgets/output_panel/output_panel.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Future<Lesson>? _lessonFuture;
  bool _loadScheduled = false;
  Lesson? _lesson;
  int _exerciseIndex = 0;
  final Set<String> _completedExercises = {};
  String? _savedCode;
  String? _exampleOutput;
  String? _exampleError;
  OutputState _exampleState = OutputState.empty;
  bool _exampleRunning = false;
  final List<BadgeDefinition> _newlyUnlockedBadges = [];
  final Set<String> _solutionViewedExerciseIds = {};
  final Set<String> _selfReportedExerciseIds = {};
  final Map<String, int> _exerciseAttempts = {};
  final Map<String, int> _exerciseHints = {};
  int _earnedXpForLesson = 0;
  DateTime? _lessonStartedAt;
  int _progressSaveSequence = 0;
  int _savedProgressSequence = 0;
  bool _progressSaving = false;
  String? _progressSaveError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadScheduled) return;
    _loadScheduled = true;
    _lessonFuture = Future<Lesson>.microtask(_loadLesson);
  }

  void _retryLoad() {
    setState(() {
      _lessonFuture = Future<Lesson>.microtask(_loadLesson);
    });
  }

  Future<Lesson> _loadLesson() async {
    final curriculum = context.read<CurriculumProvider>().state.value;
    if (curriculum == null) throw StateError('Curriculum is not available.');
    final lesson = await context.read<LessonProvider>().loadLesson(
      curriculum,
      widget.lessonId,
    );
    if (!mounted) return lesson;
    _lesson = lesson;
    final existing = context
        .read<ProgressProvider>()
        .progress
        ?.lessonsProgress[lesson.id];
    _savedCode = existing?.savedCode;
    _solutionViewedExerciseIds.addAll(
      existing?.exercisesWithSolutionViewed ?? const [],
    );
    _selfReportedExerciseIds.addAll(
      existing?.selfReportedExercises ?? const [],
    );
    _exerciseAttempts.addAll(existing?.exerciseAttempts ?? const {});
    _exerciseHints.addAll(existing?.exerciseHints ?? const {});
    _lessonStartedAt = existing?.startedAt ?? DateTime.now();
    _exerciseIndex = (existing?.exercisesCompleted ?? 0)
        .clamp(0, lesson.exercises.length)
        .toInt();
    if (_exerciseIndex < lesson.exercises.length &&
        _exerciseAttempts.isEmpty &&
        _exerciseHints.isEmpty) {
      final currentExerciseId = lesson.exercises[_exerciseIndex].id;
      if ((existing?.attempts ?? 0) > 0) {
        _exerciseAttempts[currentExerciseId] = existing!.attempts;
      }
      if ((existing?.hintsUsed ?? 0) > 0) {
        _exerciseHints[currentExerciseId] = existing!.hintsUsed;
      }
    }
    _completedExercises.addAll(
      lesson.exercises.take(_exerciseIndex).map((exercise) => exercise.id),
    );
    if (existing == null || existing.status == LessonStatus.notStarted) {
      await _persistLessonProgress(lesson, status: LessonStatus.inProgress);
    }
    return lesson;
  }

  Future<void> _persistLessonProgress(
    Lesson lesson, {
    String? savedCode,
    int? attempts,
    int? hintsUsed,
    int? exercisesCompleted,
    List<String>? exercisesWithSolutionViewed,
    List<String>? selfReportedExercises,
    Map<String, int>? exerciseAttempts,
    Map<String, int>? exerciseHints,
    LessonStatus? status,
    bool clearSavedCode = false,
  }) async {
    final provider = context.read<ProgressProvider>();
    final previous = provider.progress?.lessonsProgress[lesson.id];
    final saveSequence = ++_progressSaveSequence;
    if (mounted) {
      setState(() {
        _progressSaving = true;
        _progressSaveError = null;
      });
    }
    try {
      await provider.updateLesson(
        unitId: lesson.unitId,
        lessonId: lesson.id,
        lessonProgress: LessonProgress(
          lessonId: lesson.id,
          status: status ?? previous?.status ?? LessonStatus.inProgress,
          exercisesCompleted:
              exercisesCompleted ?? previous?.exercisesCompleted ?? 0,
          exercisesTotal: lesson.exercises.length,
          attempts: attempts ?? previous?.attempts ?? 0,
          hintsUsed: hintsUsed ?? previous?.hintsUsed ?? 0,
          startedAt: previous?.startedAt ?? DateTime.now(),
          completedAt: status == LessonStatus.completed
              ? DateTime.now()
              : previous?.completedAt,
          savedCode: clearSavedCode ? null : savedCode ?? previous?.savedCode,
          exercisesWithSolutionViewed:
              exercisesWithSolutionViewed ??
              previous?.exercisesWithSolutionViewed ??
              const [],
          selfReportedExercises:
              selfReportedExercises ??
              previous?.selfReportedExercises ??
              const [],
          exerciseAttempts:
              exerciseAttempts ?? previous?.exerciseAttempts ?? const {},
          exerciseHints: exerciseHints ?? previous?.exerciseHints ?? const {},
        ),
      );
      if (mounted && saveSequence == _progressSaveSequence) {
        setState(() {
          _progressSaving = false;
          _savedProgressSequence = saveSequence;
        });
      }
    } on Object catch (error) {
      if (mounted && saveSequence == _progressSaveSequence) {
        setState(() {
          _progressSaving = false;
          _progressSaveError = error.toString();
        });
      }
      rethrow;
    }
  }

  void _persistLessonProgressInBackground(
    Lesson lesson, {
    String? savedCode,
    int? attempts,
    int? hintsUsed,
    List<String>? exercisesWithSolutionViewed,
    Map<String, int>? exerciseAttempts,
    Map<String, int>? exerciseHints,
  }) {
    unawaited(
      _persistLessonProgress(
        lesson,
        savedCode: savedCode,
        attempts: attempts,
        hintsUsed: hintsUsed,
        exercisesWithSolutionViewed: exercisesWithSolutionViewed,
        exerciseAttempts: exerciseAttempts,
        exerciseHints: exerciseHints,
      ).catchError((Object _) {}),
    );
  }

  Future<void> _runExample() async {
    final lesson = _lesson;
    if (lesson == null) return;
    final codeRunner = context.read<CodeRunnerService>();
    final curriculum = context.read<CurriculumProvider>().state.value;
    final progressProvider = context.read<ProgressProvider>();
    setState(() {
      _exampleRunning = true;
      _exampleState = OutputState.running;
      _exampleError = null;
    });
    try {
      final result = await codeRunner.runCode(
        _exampleCode ?? lesson.exampleCode ?? '',
      );
      if (!mounted) return;
      setState(() {
        _exampleRunning = false;
        _exampleOutput = result.output.join('\n');
        _exampleError = result.errorMessage;
        _exampleState = result.isSuccess
            ? OutputState.success
            : OutputState.error;
      });
      if (result.isSuccess && mounted) {
        if (curriculum != null) {
          final reward = await progressProvider.recordExampleExecuted(
            curriculum: curriculum,
            lessonId: lesson.id,
            successful: true,
          );
          _earnedXpForLesson += reward.earnedXP;
          _newlyUnlockedBadges.addAll(reward.newlyUnlockedBadges);
        }
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _exampleRunning = false;
        _exampleError = '${context.l10n.executionFailed} $error';
        _exampleState = OutputState.error;
      });
    }
  }

  String? _exampleCode;

  Future<void> _onExerciseCompleted(
    Exercise exercise,
    Lesson lesson,
    int attempts,
    int hintsUsed,
    bool usedSolution,
    String code,
  ) async {
    if (!_completedExercises.add(exercise.id)) return;
    if (exercise.type == ExerciseType.guidedTask) {
      _selfReportedExerciseIds.add(exercise.id);
    }
    final completedCount = _completedExercises.length;
    final allCompleted = completedCount >= lesson.exercises.length;
    _savedCode = allCompleted
        ? null
        : lesson.exercises[completedCount].type == ExerciseType.predictOutput
        ? lesson.exercises[completedCount].solutionCode
        : lesson.exercises[completedCount].starterCode;
    final curriculum = context.read<CurriculumProvider>().state.value;
    final progressProvider = context.read<ProgressProvider>();
    if (curriculum == null) {
      throw StateError('Curriculum is not available.');
    }
    await _persistLessonProgress(
      lesson,
      savedCode: _savedCode,
      attempts: _totalCount(_exerciseAttempts, exercise.id, attempts),
      hintsUsed: _totalCount(_exerciseHints, exercise.id, hintsUsed),
      exerciseAttempts: {..._exerciseAttempts, exercise.id: attempts},
      exerciseHints: {..._exerciseHints, exercise.id: hintsUsed},
      selfReportedExercises: [..._selfReportedExerciseIds],
      exercisesCompleted: completedCount,
      status: allCompleted ? LessonStatus.completed : LessonStatus.inProgress,
      clearSavedCode: allCompleted,
    );
    final exerciseReward = await progressProvider.recordExerciseResult(
      curriculum: curriculum,
      lessonId: lesson.id,
      attempts: attempts,
      hintsCount: hintsUsed,
      usedSolution: usedSolution,
      code: code,
      verified: exercise.type != ExerciseType.guidedTask,
    );
    _earnedXpForLesson += exerciseReward.earnedXP;
    _newlyUnlockedBadges.addAll(exerciseReward.newlyUnlockedBadges);
    if (allCompleted) {
      final lessonReward = await progressProvider.recordLessonCompletion(
        curriculum: curriculum,
        unitId: lesson.unitId,
        lessonId: lesson.id,
      );
      _earnedXpForLesson += lessonReward.earnedXP;
      _newlyUnlockedBadges.addAll(lessonReward.newlyUnlockedBadges);
    }
    if (!mounted) return;
    if (allCompleted) {
      context.pushReplacement(
        AppRoutes.lessonCompletePath(lesson.id),
        extra: {
          'earnedXP': _earnedXpForLesson,
          'newlyUnlockedBadges': [
            for (final badge in _newlyUnlockedBadges) badge.id,
          ],
          'hintsUsedCount':
              progressProvider
                  .progress
                  ?.lessonsProgress[lesson.id]
                  ?.hintsUsed ??
              0,
          'timeSpentMinutes': DateTime.now()
              .difference(_lessonStartedAt ?? DateTime.now())
              .inMinutes,
        },
      );
    } else {
      setState(() => _exerciseIndex++);
    }
  }

  Widget _explanation(Lesson lesson) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          lesson.title.resolve(locale),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          lesson.objective.resolve(locale),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        _MarkdownContent(markdown: lesson.contentMarkdown.resolve(locale)),
        if (lesson.documentation case final documentation?) ...[
          const SizedBox(height: 16),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(
                locale.languageCode == 'en'
                    ? 'Lesson documentation'
                    : 'توثيق الدرس',
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _MarkdownContent(markdown: documentation.resolve(locale)),
                if (lesson.documentationSources.isNotEmpty) ...[
                  const Divider(height: 24),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      locale.languageCode == 'en' ? 'Sources' : 'المصادر',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  for (final source in lesson.documentationSources)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(source.title.resolve(locale)),
                      subtitle: SelectableText(
                        source.url,
                        textDirection: TextDirection.ltr,
                      ),
                      dense: true,
                    ),
                  Text(
                    locale.languageCode == 'en'
                        ? 'Based on Godot Engine Documentation, licensed under CC BY 3.0. This educational text is an independent adaptation and is not endorsed by Godot.'
                        : 'يستند هذا المحتوى إلى توثيق Godot Engine المرخّص بموجب CC BY 3.0. هذا إعداد تعليمي مستقل وليس معتمداً من Godot.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  const SelectableText(
                    'https://creativecommons.org/licenses/by/3.0/',
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (lesson.exampleCode != null) ...[
          const SizedBox(height: 20),
          Text(
            context.l10n.exampleLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          CodeEditorWidget(
            initialCode: _exampleCode ?? lesson.exampleCode!,
            readOnly: false,
            fontSize: context
                .watch<AppSettingsProvider>()
                .editorFontSize
                .toDouble(),
            showActionBar: false,
            onChanged: (code) => _exampleCode = code,
            onSyntaxHighlightsRequested: context
                .read<CodeRunnerService>()
                .getSyntaxHighlights,
            onDiagnosticsRequested: context
                .read<CodeRunnerService>()
                .getDiagnostics,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _exampleRunning ? null : _runExample,
              icon: const Icon(Icons.play_arrow),
              iconAlignment: .end,
              label: Text(context.l10n.runExample),
            ),
          ),
          OutputPanel(
            state: _exampleState,
            output: _exampleOutput,
            errorMessage: _exampleError,
          ),
        ],
      ],
    );
  }

  Widget _exercise(Lesson lesson) {
    if (lesson.exercises.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        message: context.l10n.noLessons,
      );
    }
    final index = _exerciseIndex.clamp(0, lesson.exercises.length - 1).toInt();
    final exercise = lesson.exercises[index];
    return ExerciseWidget(
      key: ValueKey(exercise.id),
      exercise: exercise,
      exerciseIndex: index,
      exerciseCount: lesson.exercises.length,
      initialCode: _savedCode,
      initialSolutionViewed: _solutionViewedExerciseIds.contains(exercise.id),
      initialAttempts: _exerciseAttempts[exercise.id] ?? 0,
      initialHintsUsed: _exerciseHints[exercise.id] ?? 0,
      onCodeChanged: (code) {
        _savedCode = code;
        _persistLessonProgressInBackground(lesson, savedCode: code);
      },
      onProgressChanged: (attempts, hintsUsed) {
        _exerciseAttempts[exercise.id] = attempts;
        _exerciseHints[exercise.id] = hintsUsed;
        _persistLessonProgressInBackground(
          lesson,
          attempts: _exerciseAttempts.values.fold<int>(
            0,
            (sum, item) => sum + item,
          ),
          hintsUsed: _exerciseHints.values.fold<int>(
            0,
            (sum, item) => sum + item,
          ),
          exerciseAttempts: _exerciseAttempts,
          exerciseHints: _exerciseHints,
        );
      },
      onExerciseCompleted: (attempts, hintsUsed, usedSolution, code) =>
          _onExerciseCompleted(
            exercise,
            lesson,
            attempts,
            hintsUsed,
            usedSolution,
            code,
          ),
      onSolutionViewed: () {
        _solutionViewedExerciseIds.add(exercise.id);
        _persistLessonProgressInBackground(
          lesson,
          exercisesWithSolutionViewed: [..._solutionViewedExerciseIds],
        );
      },
      fontSize: context.watch<AppSettingsProvider>().editorFontSize.toDouble(),
    );
  }

  static int _totalCount(
    Map<String, int> values,
    String exerciseId,
    int currentValue,
  ) => values.entries
      .where((entry) => entry.key != exerciseId)
      .fold(currentValue, (sum, entry) => sum + entry.value);

  Widget _body(Lesson lesson) {
    final title = lesson.title.resolve(Localizations.localeOf(context));
    final curriculum = context.watch<CurriculumProvider>().state.value!;
    final unit = curriculum.units.firstWhere(
      (unit) => unit.id == lesson.unitId,
    );
    final statusSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_progressSaving) const LinearProgressIndicator(minHeight: 2),
        if (_progressSaveError case final error?)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              context.l10n.dashboardSaveError(error),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          )
        else if (!_progressSaving &&
            _savedProgressSequence > 0 &&
            _savedCode != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_done_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 6),
                Text(context.l10n.dashboardDraftAutoSaved),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: context.l10n.backToPath,
          onPressed: () => context.go(AppRoutes.learningPath),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: AdaptiveLayout(
        breakpoint: 840,
        mobileBuilder: (context) => LessonLayoutMobile(
          explanationSection: _explanation(lesson),
          editorSection: _exercise(lesson),
          actionsSection: statusSection,
          outputSection: const SizedBox.shrink(),
        ),
        desktopBuilder: (context) => DesktopLessonIdeLayout(
          unitTitle: unit.title.resolve(Localizations.localeOf(context)),
          estimatedMinutes: lesson.estimatedMinutes,
          isEngineReady: true,
          explanationSection: _explanation(lesson),
          editorSection: _exercise(lesson),
          statusSection: statusSection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Lesson>(
    future: _lessonFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.lessonTitle)),
          body: const LessonLoadingSkeleton(),
        );
      }
      if (snapshot.hasError || snapshot.data == null) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.lessonTitle)),
          body: EmptyState(
            icon: Icons.error_outline,
            message: context.l10n.lessonUnavailable,
            action: FilledButton(
              onPressed: _retryLoad,
              child: Text(context.l10n.retry),
            ),
          ),
        );
      }
      return _body(snapshot.data!);
    },
  );

  @override
  void dispose() {
    super.dispose();
  }
}

class _MarkdownContent extends StatelessWidget {
  const _MarkdownContent({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];
    var inCodeBlock = false;
    final codeLines = <String>[];
    for (final line in lines) {
      if (line.trimLeft().startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(_CodeBlock(code: codeLines.join('\n')));
          codeLines.clear();
        }
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        codeLines.add(line);
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        );
      } else if (line.trim().isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: SelectableText.rich(_inlineCodeSpans(context, line)),
          ),
        );
      }
    }
    if (codeLines.isNotEmpty) {
      widgets.add(_CodeBlock(code: codeLines.join('\n')));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  static TextSpan _inlineCodeSpans(BuildContext context, String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'`([^`]+)`');
    var offset = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: text.substring(offset, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontFamily: ArabicIdeTheme.codeFontFamily(context),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
      offset = match.end;
    }
    if (offset < text.length) spans.add(TextSpan(text: text.substring(offset)));
    return TextSpan(
      style: Theme.of(context).textTheme.bodyLarge,
      children: spans,
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) => CodeDirectionality(
    child: Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                code,
                style: TextStyle(
                  fontFamily: ArabicIdeTheme.codeFontFamily(context),
                ),
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).copyButtonLabel,
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
      ),
    ),
  );
}
