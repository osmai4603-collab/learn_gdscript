import 'package:flutter/foundation.dart';

import 'curriculum_models.dart';
import 'lesson_models.dart';
import 'progress_models.dart';

@immutable
class HomeDashboardData {
  const HomeDashboardData({
    required this.curriculum,
    required this.progress,
    required this.currentUnit,
    required this.currentLesson,
    required this.playgroundCode,
  });

  final Curriculum curriculum;
  final UserProgress? progress;
  final Unit? currentUnit;
  final Lesson? currentLesson;
  final String playgroundCode;

  HomeDashboardData copyWith({
    Curriculum? curriculum,
    UserProgress? progress,
    Unit? currentUnit,
    Lesson? currentLesson,
    String? playgroundCode,
  }) => HomeDashboardData(
    curriculum: curriculum ?? this.curriculum,
    progress: progress ?? this.progress,
    currentUnit: currentUnit ?? this.currentUnit,
    currentLesson: currentLesson ?? this.currentLesson,
    playgroundCode: playgroundCode ?? this.playgroundCode,
  );
}
