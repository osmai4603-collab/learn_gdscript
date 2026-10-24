import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/async_state.dart';
import '../../data/models/home_dashboard_models.dart';
import '../../data/models/curriculum_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/repositories/curriculum_repository.dart';
import '../../data/repositories/home_dashboard_repository.dart';
import 'curriculum_provider.dart';
import 'progress_provider.dart';

class HomeDashboardProvider extends ChangeNotifier {
  HomeDashboardProvider({
    required this._repository,
    required this._curriculumRepository,
    required this._curriculumProvider,
    required this._progressProvider,
    this.visitorId = AppConstants.visitorId,
  }) {
    _curriculumProvider.addListener(_refreshFromSources);
    _progressProvider.addListener(_refreshFromSources);
  }

  static const defaultPlaygroundCode =
      'var player_health = 75\n'
      'if player_health > 50:\n'
      '    print("اللاعب بصحة جيدة! ❤️")';

  Future<void> _codeWriteQueue = Future<void>.value();
  Timer? _draftSaveTimer;
  String? _pendingDraftCode;
  Completer<void>? _pendingDraftCompletion;
  bool _disposed = false;

  final HomeDashboardRepository _repository;
  final CurriculumRepository _curriculumRepository;
  final CurriculumProvider _curriculumProvider;
  final ProgressProvider _progressProvider;
  final String visitorId;
  AsyncState<HomeDashboardData> state = const AsyncState.initial();
  int _loadSequence = 0;

  Future<void> load() async {
    final sequence = ++_loadSequence;
    state = const AsyncState.loading();
    notifyListeners();
    try {
      final savedCode = await _repository.loadPlaygroundCode(visitorId);
      final data = await _dataForSources(savedCode ?? defaultPlaygroundCode);
      if (sequence != _loadSequence) return;
      state = AsyncState.data(data);
      notifyListeners();
    } on Object catch (error) {
      if (sequence != _loadSequence) return;
      state = AsyncState.error(error);
      notifyListeners();
    }
  }

  Future<void> savePlaygroundCode(String code) {
    _pendingDraftCode = code;
    final completion =
        _pendingDraftCompletion ??= Completer<void>();
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(
      const Duration(milliseconds: 400),
      () => unawaited(_flushPendingDraft()),
    );
    return completion.future;
  }

  Future<void> _flushPendingDraft() async {
    final code = _pendingDraftCode;
    final completion = _pendingDraftCompletion;
    _draftSaveTimer = null;
    _pendingDraftCode = null;
    _pendingDraftCompletion = null;
    if (code == null || completion == null) return;

    try {
      await _persistPlaygroundCode(code);
      completion.complete();
    } on Object catch (error, stackTrace) {
      completion.completeError(error, stackTrace);
    }
  }

  Future<void> _persistPlaygroundCode(String code) {
    final previousWrite = _codeWriteQueue;
    final completion = Completer<void>();
    _codeWriteQueue = completion.future;
    unawaited(_writePlaygroundCode(previousWrite, completion, code));
    return completion.future;
  }

  Future<void> _writePlaygroundCode(
    Future<void> previousWrite,
    Completer<void> completion,
    String code,
  ) async {
    try {
      try {
        await previousWrite;
      } on Object {
        // A failed draft write is surfaced by its own Future; later edits retry.
      }
      await _repository.savePlaygroundCode(
        visitorId: visitorId,
        code: code,
        updatedAt: DateTime.now(),
      );
      final current = state.value;
      if (current != null && !_disposed) {
        state = AsyncState.data(current.copyWith(playgroundCode: code));
        notifyListeners();
      }
      completion.complete();
    } on Object catch (error, stackTrace) {
      completion.completeError(error, stackTrace);
    }
  }

  Future<void> refresh() => load();

  Future<HomeDashboardData> _dataForSources(String playgroundCode) async {
    final curriculum = _curriculumProvider.state.value;
    if (curriculum == null) {
      throw StateError('The curriculum must be loaded before the dashboard.');
    }
    final progress = _progressProvider.progress;
    final selection = _selectNextLesson(curriculum, progress);
    final lesson = selection == null
        ? null
        : await _curriculumRepository.loadLesson(curriculum, selection.$2);
    return HomeDashboardData(
      curriculum: curriculum,
      progress: progress,
      currentUnit: selection?.$1,
      currentLesson: lesson,
      playgroundCode: playgroundCode,
    );
  }

  void _refreshFromSources() {
    final current = state.value;
    if (current == null) return;
    final sequence = ++_loadSequence;
    unawaited(_refreshData(current.playgroundCode, sequence));
  }

  Future<void> _refreshData(String playgroundCode, int sequence) async {
    try {
      final data = await _dataForSources(playgroundCode);
      if (sequence != _loadSequence) return;
      state = AsyncState.data(data);
      notifyListeners();
    } on Object catch (error) {
      if (sequence != _loadSequence) return;
      state = AsyncState.error(error);
      notifyListeners();
    }
  }

  static (Unit, String)? _selectNextLesson(
    Curriculum curriculum,
    UserProgress? progress,
  ) {
    final lessons = [
      for (final unit in curriculum.units)
        for (final lessonId in unit.lessonIds) (unit, lessonId),
    ];
    if (lessons.isEmpty) return null;
    var next = lessons.firstWhere(
      (entry) =>
          progress?.lessonsProgress[entry.$2]?.status != LessonStatus.completed,
      orElse: () => lessons.first,
    );
    for (final entry in lessons) {
      if (entry.$2 == progress?.currentLessonId &&
          progress?.lessonsProgress[entry.$2]?.status !=
              LessonStatus.completed) {
        next = entry;
        break;
      }
    }
    return next;
  }

  @override
  void dispose() {
    _disposed = true;
    _curriculumProvider.removeListener(_refreshFromSources);
    _progressProvider.removeListener(_refreshFromSources);
    _draftSaveTimer?.cancel();
    if (_pendingDraftCode != null) {
      unawaited(_flushPendingDraft());
    }
    super.dispose();
  }
}
