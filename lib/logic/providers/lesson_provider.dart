import 'package:flutter/foundation.dart';

import '../../data/models/async_state.dart';
import '../../data/models/curriculum_models.dart';
import '../../data/models/lesson_models.dart';
import '../../data/repositories/curriculum_repository.dart';

class LessonProvider extends ChangeNotifier {
  LessonProvider(this._repository);

  final CurriculumRepository _repository;
  Lesson? _selectedLesson;
  AsyncState<Lesson> state = const AsyncState.initial();

  Lesson? get selectedLesson => _selectedLesson;

  Future<Lesson> loadLesson(Curriculum curriculum, String lessonId) async {
    state = const AsyncState.loading();
    notifyListeners();
    try {
      final lesson = await _repository.loadLesson(curriculum, lessonId);
      _selectedLesson = lesson;
      state = AsyncState.data(lesson);
      notifyListeners();
      return lesson;
    } on Object catch (error) {
      state = AsyncState.error(error);
      notifyListeners();
      rethrow;
    }
  }

  void select(Lesson lesson) {
    _selectedLesson = lesson;
    notifyListeners();
  }

  void clear() {
    _selectedLesson = null;
    state = const AsyncState.initial();
    notifyListeners();
  }
}
