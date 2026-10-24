import 'package:flutter/foundation.dart';

import 'curriculum_models.dart';
import 'lesson_models.dart';
import 'progress_models.dart';

@immutable
class LearningPathData {
  LearningPathData({
    required this.curriculum,
    required this.lessons,
    required this.progress,
  }) : lessons = Map.unmodifiable(lessons);

  final Curriculum curriculum;
  final Map<String, Lesson> lessons;
  final UserProgress? progress;

  int get totalLessons =>
      curriculum.units.fold(0, (sum, unit) => sum + unit.lessonIds.length);

  int get completedLessons => curriculum.units.fold(
    0,
    (sum, unit) =>
        sum +
        unit.lessonIds.where(
          (id) => progress?.lessonsProgress[id]?.status == LessonStatus.completed,
        ).length,
  );

  int get completedUnits => curriculum.units.where((unit) {
    return unit.lessonIds.isNotEmpty &&
        unit.lessonIds.every(
          (id) => progress?.lessonsProgress[id]?.status == LessonStatus.completed,
        );
  }).length;

  double get progressRatio =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;

  int get activeUnitIndex {
    final currentUnitIndex = curriculum.units.indexWhere(
      (unit) => unit.id == progress?.currentUnitId,
    );
    if (currentUnitIndex >= 0 &&
        curriculum.units[currentUnitIndex].lessonIds.any(
          (id) => progress?.lessonsProgress[id]?.status != LessonStatus.completed,
        )) {
      return currentUnitIndex;
    }
    final firstIncompleteIndex = curriculum.units.indexWhere(
      (unit) => unit.lessonIds.any(
        (id) => progress?.lessonsProgress[id]?.status != LessonStatus.completed,
      ),
    );
    return firstIncompleteIndex < 0 ? 0 : firstIncompleteIndex;
  }

  String? get activeLessonId {
    final currentLessonId = progress?.currentLessonId;
    if (currentLessonId != null &&
        curriculum.units.any((unit) => unit.lessonIds.contains(currentLessonId)) &&
        progress?.lessonsProgress[currentLessonId]?.status !=
            LessonStatus.completed) {
      return currentLessonId;
    }
    for (final unit in curriculum.units) {
      for (final lessonId in unit.lessonIds) {
        if (progress?.lessonsProgress[lessonId]?.status !=
            LessonStatus.completed) {
          return lessonId;
        }
      }
    }
    return null;
  }

  bool isUnitLocked(int index) =>
      index > activeUnitIndex &&
      index > 0 &&
      !isUnitCompleted(curriculum.units[index - 1]);

  bool isUnitCompleted(Unit unit) =>
      unit.lessonIds.isNotEmpty &&
      unit.lessonIds.every(
        (id) => progress?.lessonsProgress[id]?.status == LessonStatus.completed,
      );

  int completedLessonsIn(Unit unit) => unit.lessonIds
      .where(
        (id) => progress?.lessonsProgress[id]?.status == LessonStatus.completed,
      )
      .length;
}
