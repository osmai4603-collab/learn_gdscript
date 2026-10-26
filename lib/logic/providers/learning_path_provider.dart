import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/async_state.dart';
import '../../data/models/learning_path_models.dart';
import '../../data/models/lesson_models.dart';
import '../../data/repositories/curriculum_repository.dart';
import 'curriculum_provider.dart';
import 'progress_provider.dart';

class LearningPathProvider extends ChangeNotifier {
  LearningPathProvider({
    required this.curriculumRepository,
    required this.curriculumProvider,
    required this.progressProvider,
  }) {
    curriculumProvider.addListener(_refreshFromSources);
    progressProvider.addListener(_refreshFromSources);
  }

  final CurriculumRepository curriculumRepository;
  final CurriculumProvider curriculumProvider;
  final ProgressProvider progressProvider;
  final Map<String, Lesson> _lessonCache = {};
  AsyncState<LearningPathData> state = const AsyncState.initial();
  int _loadSequence = 0;
  String? _cachedCurriculumVersion;

  Future<void> load() async {
    final sequence = ++_loadSequence;
    state = const AsyncState.loading();
    notifyListeners();
    await _loadData(sequence);
  }

  Future<void> refresh() async {
    if (curriculumProvider.state.value == null) {
      try {
        await curriculumProvider.load();
      } on Object catch (error) {
        state = AsyncState.error(error);
        notifyListeners();
        return;
      }
    }
    await load();
  }

  Future<void> _loadData(int sequence) async {
    try {
      final curriculum = curriculumProvider.state.value;
      if (curriculum == null) {
        throw StateError('The curriculum must be loaded before the learning path.');
      }
      final curriculumVersion =
          '${curriculum.version}:${curriculum.targetGDScriptVersion}';
      if (_cachedCurriculumVersion != curriculumVersion) {
        _lessonCache.clear();
        _cachedCurriculumVersion = curriculumVersion;
      }
      final lessonIds = curriculum.units
          .expand((unit) => unit.lessonIds)
          .toSet();
      final missingIds = lessonIds.where((id) => !_lessonCache.containsKey(id));
      for (final id in missingIds) {
        try {
          final lesson = await curriculumRepository.loadLesson(curriculum, id);
          _lessonCache[id] = lesson;
        } catch (e) {
          // Gracefully skip missing or corrupted individual lesson assets
        }
      }
      if (sequence != _loadSequence) return;
      _lessonCache.removeWhere((id, _) => !lessonIds.contains(id));
      state = AsyncState.data(
        LearningPathData(
          curriculum: curriculum,
          lessons: {
            for (final id in lessonIds)
              if (_lessonCache.containsKey(id)) id: _lessonCache[id]!,
          },
          progress: progressProvider.progress,
        ),
      );
      notifyListeners();
    } on Object catch (error) {
      if (sequence != _loadSequence) return;
      state = AsyncState.error(error);
      notifyListeners();
    }
  }

  void _refreshFromSources() {
    if (state.status == LoadStatus.initial ||
        state.status == LoadStatus.loading) {
      return;
    }
    final sequence = ++_loadSequence;
    unawaited(_loadData(sequence));
  }

  @override
  void dispose() {
    curriculumProvider.removeListener(_refreshFromSources);
    progressProvider.removeListener(_refreshFromSources);
    super.dispose();
  }
}
