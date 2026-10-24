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
    required CurriculumRepository curriculumRepository,
    required CurriculumProvider curriculumProvider,
    required ProgressProvider progressProvider,
  }) : _curriculumRepository = curriculumRepository,
       _curriculumProvider = curriculumProvider,
       _progressProvider = progressProvider {
    _curriculumProvider.addListener(_refreshFromSources);
    _progressProvider.addListener(_refreshFromSources);
  }

  final CurriculumRepository _curriculumRepository;
  final CurriculumProvider _curriculumProvider;
  final ProgressProvider _progressProvider;
  final Map<String, Lesson> _lessonCache = {};
  AsyncState<LearningPathData> state = const AsyncState.initial();
  int _loadSequence = 0;

  Future<void> load() async {
    final sequence = ++_loadSequence;
    state = const AsyncState.loading();
    notifyListeners();
    await _loadData(sequence);
  }

  Future<void> refresh() => load();

  Future<void> _loadData(int sequence) async {
    try {
      final curriculum = _curriculumProvider.state.value;
      if (curriculum == null) {
        throw StateError('The curriculum must be loaded before the learning path.');
      }
      final lessonIds = curriculum.units
          .expand((unit) => unit.lessonIds)
          .toSet();
      final missingIds = lessonIds.where((id) => !_lessonCache.containsKey(id));
      final loaded = await Future.wait(
        missingIds.map((id) => _curriculumRepository.loadLesson(curriculum, id)),
      );
      if (sequence != _loadSequence) return;
      for (final lesson in loaded) {
        _lessonCache[lesson.id] = lesson;
      }
      _lessonCache.removeWhere((id, _) => !lessonIds.contains(id));
      state = AsyncState.data(
        LearningPathData(
          curriculum: curriculum,
          lessons: {
            for (final id in lessonIds)
              id: _lessonCache[id]!,
          },
          progress: _progressProvider.progress,
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
    _curriculumProvider.removeListener(_refreshFromSources);
    _progressProvider.removeListener(_refreshFromSources);
    super.dispose();
  }
}
