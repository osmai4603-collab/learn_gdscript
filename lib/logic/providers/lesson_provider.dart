import 'package:flutter/foundation.dart';

import '../../data/models/lesson_models.dart';

class LessonProvider extends ChangeNotifier {
  Lesson? _selectedLesson;

  Lesson? get selectedLesson => _selectedLesson;

  void select(Lesson lesson) {
    _selectedLesson = lesson;
    notifyListeners();
  }

  void clear() {
    _selectedLesson = null;
    notifyListeners();
  }
}
