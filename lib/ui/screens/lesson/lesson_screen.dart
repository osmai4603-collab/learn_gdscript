import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/exercise_models.dart';
import '../../../data/models/lesson_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/language_server_provider.dart';
import '../../../logic/providers/lesson_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../layouts/adaptive_layout.dart';
import '../../layouts/lesson_layout_desktop.dart';
import '../../layouts/lesson_layout_mobile.dart';
import '../../widgets/code_directionality.dart';
import '../../widgets/code_editor/code_editor_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
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
  String? _lspWarning;
  bool _lessonDocumentOpen = false;
  bool _lessonDocumentOpening = false;
  LanguageServerProvider? _languageServer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageServer = context.watch<LanguageServerProvider>();
    _languageServer = languageServer;
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
    await _openLessonDocument(lesson);
    _exerciseIndex = (existing?.exercisesCompleted ?? 0)
        .clamp(0, lesson.exercises.length)
        .toInt();
    _completedExercises.addAll(
      lesson.exercises.take(_exerciseIndex).map((exercise) => exercise.id),
    );
    if (existing == null || existing.status == LessonStatus.notStarted) {
      await _persistLessonProgress(lesson, status: LessonStatus.inProgress);
    }
    return lesson;
  }

  Future<void> _openLessonDocument(Lesson lesson) async {
    final server = _languageServer;
    if (server == null || !server.isConnected) {
      _lessonDocumentOpen = false;
      return;
    }
    if (_lessonDocumentOpen || _lessonDocumentOpening) return;
    _lessonDocumentOpening = true;
    try {
      await server.openLessonDocument(
        lesson.id,
        _savedCode ??
            (lesson.exercises.isNotEmpty
                ? lesson.exercises.first.starterCode
                : lesson.exampleCode ?? ''),
      );
      _lessonDocumentOpen = true;
    } on Object {
      if (mounted) setState(() => _lspWarning = context.l10n.lspFeatureError);
    } finally {
      _lessonDocumentOpening = false;
    }
  }

  Future<void> _persistLessonProgress(
    Lesson lesson, {
    String? savedCode,
    int? attempts,
    int? hintsUsed,
    int? exercisesCompleted,
    LessonStatus? status,
  }) async {
    final provider = context.read<ProgressProvider>();
    final previous = provider.progress?.lessonsProgress[lesson.id];
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
        savedCode: savedCode ?? previous?.savedCode,
      ),
    );
  }

  Future<void> _runExample() async {
    final lesson = _lesson;
    if (lesson == null) return;
    setState(() {
      _exampleRunning = true;
      _exampleState = OutputState.running;
      _exampleError = null;
    });
    try {
      final result = await context.read<CodeRunnerService>().runCode(
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

  Future<void> _onExerciseCompleted(Exercise exercise, Lesson lesson) async {
    if (!_completedExercises.add(exercise.id)) return;
    final completedCount = _completedExercises.length;
    final allCompleted = completedCount >= lesson.exercises.length;
    _savedCode = allCompleted
        ? null
        : lesson.exercises[completedCount].type == ExerciseType.predictOutput
        ? lesson.exercises[completedCount].solutionCode
        : lesson.exercises[completedCount].starterCode;
    await _persistLessonProgress(
      lesson,
      savedCode: _savedCode,
      exercisesCompleted: completedCount,
      status: allCompleted ? LessonStatus.completed : LessonStatus.inProgress,
    );
    if (!mounted) return;
    if (allCompleted) {
      await Navigator.of(context).pushNamed('/lesson-complete/${lesson.id}');
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
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _exampleRunning ? null : _runExample,
              icon: const Icon(Icons.play_arrow),
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
      onCodeChanged: (code) {
        _savedCode = code;
        unawaited(_persistLessonProgress(lesson, savedCode: code));
        unawaited(_syncLessonDocument(lesson.id, code));
      },
      onProgressChanged: (attempts, hintsUsed) {
        unawaited(
          _persistLessonProgress(
            lesson,
            attempts: attempts,
            hintsUsed: hintsUsed,
          ),
        );
      },
      onCompleted: () => _onExerciseCompleted(exercise, lesson),
      onCompletionRequested:
          context.read<LanguageServerProvider>().isConnected
          ? (code, offset) => context
                .read<LanguageServerProvider>()
                .completeLessonDocument(lesson.id, code, offset)
          : null,
      onFormatRequested: context.read<LanguageServerProvider>().isConnected
          ? (code) => context
                .read<LanguageServerProvider>()
                .formatLessonDocument(lesson.id, code)
          : null,
      fontSize: context
          .watch<AppSettingsProvider>()
          .editorFontSize
          .toDouble(),
    );
  }

  Future<void> _syncLessonDocument(String lessonId, String code) async {
    final server = context.read<LanguageServerProvider>();
    if (!server.isConnected) return;
    try {
      await server.syncLessonDocument(lessonId, code);
    } on Object {
      if (mounted) setState(() => _lspWarning = context.l10n.lspFeatureError);
    }
  }

  Widget _body(Lesson lesson) {
    final title = lesson.title.resolve(Localizations.localeOf(context));
    final languageServer = context.watch<LanguageServerProvider>();
    unawaited(_openLessonDocument(lesson));
    final diagnostics = languageServer.diagnosticsForLesson(lesson.id);
    final statusSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_lspWarning != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _lspWarning!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (diagnostics.isNotEmpty)
          _LspDiagnostics(diagnostics: diagnostics),
        if (_lspWarning == null && diagnostics.isEmpty)
          const SizedBox(height: 16),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: context.l10n.backToPath,
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/path', (route) => route.isFirst),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: AdaptiveLayout(
        mobileBuilder: (context) => LessonLayoutMobile(
          explanationSection: _explanation(lesson),
          editorSection: _exercise(lesson),
          actionsSection: statusSection,
          outputSection: const SizedBox.shrink(),
        ),
        desktopBuilder: (context) => LessonLayoutDesktop(
          explanationSection: _explanation(lesson),
          editorSection: _exercise(lesson),
          actionsSection: statusSection,
          outputSection: const SizedBox.shrink(),
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
          body: const LoadingIndicator(),
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
    final lesson = _lesson;
    final server = _languageServer;
    if (lesson != null && _lessonDocumentOpen && server != null) {
      unawaited(server.closeLessonDocument(lesson.id));
    }
    super.dispose();
  }
}

class _LspDiagnostics extends StatelessWidget {
  const _LspDiagnostics({required this.diagnostics});

  final List<Map<String, Object?>> diagnostics;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final diagnostic in diagnostics)
          ListTile(
            dense: true,
            leading: Icon(
              Icons.warning_amber_outlined,
              color: diagnostic['severity'] == 1
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.tertiary,
            ),
            title: Text(
              diagnostic['message'] is String
                  ? diagnostic['message']! as String
                  : context.l10n.lspFeatureError,
            ),
            subtitle: _diagnosticLine(context, diagnostic),
          ),
      ],
    ),
  );

  static String? _diagnosticLine(
    BuildContext context,
    Map<String, Object?> diagnostic,
  ) {
    final range = diagnostic['range'];
    if (range is! Map || range['start'] is! Map) return null;
    final line = (range['start'] as Map)['line'];
    return line is int ? context.l10n.diagnosticLine(line + 1) : null;
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
            fontFamily: 'monospace',
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
                style: const TextStyle(fontFamily: 'monospace'),
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
