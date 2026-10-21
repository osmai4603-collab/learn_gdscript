import 'package:flutter/foundation.dart';

import '../../data/models/exercise_models.dart';
import '../services/test_runner_service.dart';

class ExerciseProvider extends ChangeNotifier {
  Exercise? _selectedExercise;
  ExerciseResult? _lastResult;

  Exercise? get selectedExercise => _selectedExercise;
  ExerciseResult? get lastResult => _lastResult;

  void select(Exercise exercise) {
    _selectedExercise = exercise;
    _lastResult = null;
    notifyListeners();
  }

  void recordResult(ExerciseResult result) {
    _lastResult = result;
    notifyListeners();
  }
}
