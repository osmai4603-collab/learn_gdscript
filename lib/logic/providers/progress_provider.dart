import 'package:flutter/foundation.dart';
import '../../data/models/async_state.dart';
import '../../data/models/progress_models.dart';
import '../../data/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._repository);

  final ProgressRepository _repository;
  AsyncState<UserProgress?> state = const AsyncState.initial();
  UserProgress? get progress => state.value;

  Future<void> load(String visitorId) async {
    state = const AsyncState.loading();
    notifyListeners();
    try {
      state = AsyncState.data(await _repository.load(visitorId));
      notifyListeners();
    } on Object catch (error) {
      state = AsyncState.error(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> save(UserProgress progress) async {
    await _repository.save(progress);
    state = AsyncState.data(progress);
    notifyListeners();
  }

  Future<void> initialize({
    required String visitorId,
    required String unitId,
    required String lessonId,
  }) async {
    if (progress != null) return;
    await save(
      UserProgress(
        visitorId: visitorId,
        currentUnitId: unitId,
        currentLessonId: lessonId,
        totalXP: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: DateTime.now(),
        lessonsProgress: const {},
        earnedBadges: const [],
      ),
    );
  }

  Future<void> updateLesson({
    required String unitId,
    required String lessonId,
    required LessonProgress lessonProgress,
  }) async {
    final current = progress;
    if (current == null) {
      throw StateError('Progress must be initialized before it is updated.');
    }
    final previous = current.lessonsProgress[lessonId];
    final lessons = Map<String, LessonProgress>.from(current.lessonsProgress)
      ..[lessonId] = lessonProgress;
    final gainedCompletion =
        lessonProgress.status == LessonStatus.completed &&
        previous?.status != LessonStatus.completed;
    await save(
      UserProgress(
        visitorId: current.visitorId,
        currentUnitId: unitId,
        currentLessonId: lessonId,
        totalXP: current.totalXP + (gainedCompletion ? 10 : 0),
        currentStreak: current.currentStreak,
        longestStreak: current.longestStreak,
        lastActiveDate: DateTime.now(),
        lessonsProgress: lessons,
        earnedBadges: current.earnedBadges,
      ),
    );
  }

  Future<void> clear(String visitorId) async {
    await _repository.clear(visitorId);
    state = const AsyncState.data(null);
    notifyListeners();
  }

  Future<void> setStartingPoint({
    required String unitId,
    required String lessonId,
  }) async {
    final current = progress;
    if (current == null) {
      throw StateError('Progress must be initialized before it is updated.');
    }
    await save(
      UserProgress(
        visitorId: current.visitorId,
        currentUnitId: unitId,
        currentLessonId: lessonId,
        totalXP: current.totalXP,
        currentStreak: current.currentStreak,
        longestStreak: current.longestStreak,
        lastActiveDate: current.lastActiveDate,
        lessonsProgress: current.lessonsProgress,
        earnedBadges: current.earnedBadges,
      ),
    );
  }
}
