import 'package:flutter/foundation.dart';

import 'model_json.dart';

enum LessonStatus { notStarted, inProgress, completed }

@immutable
class LessonProgress {
  final String lessonId;
  final LessonStatus status;
  final int exercisesCompleted;
  final int exercisesTotal;
  final int attempts;
  final int hintsUsed;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? savedCode;

  const LessonProgress({
    required this.lessonId,
    this.status = LessonStatus.notStarted,
    this.exercisesCompleted = 0,
    this.exercisesTotal = 0,
    this.attempts = 0,
    this.hintsUsed = 0,
    this.startedAt,
    this.completedAt,
    this.savedCode,
  }) : assert(exercisesCompleted >= 0),
       assert(exercisesTotal >= 0),
       assert(attempts >= 0),
       assert(hintsUsed >= 0);

  factory LessonProgress.fromJson(JsonObject json) => LessonProgress(
    lessonId: requiredString(json, 'lessonId'),
    status: _status(json),
    exercisesCompleted: json.containsKey('exercisesCompleted')
        ? requiredInt(json, 'exercisesCompleted', minimum: 0)
        : 0,
    exercisesTotal: json.containsKey('exercisesTotal')
        ? requiredInt(json, 'exercisesTotal', minimum: 0)
        : 0,
    attempts: json.containsKey('attempts')
        ? requiredInt(json, 'attempts', minimum: 0)
        : 0,
    hintsUsed: json.containsKey('hintsUsed')
        ? requiredInt(json, 'hintsUsed', minimum: 0)
        : 0,
    startedAt: _date(json, 'startedAt'),
    completedAt: _date(json, 'completedAt'),
    savedCode: optionalString(json, 'savedCode'),
  );

  JsonObject toJson() => {
    'lessonId': lessonId,
    'status': status.name,
    'exercisesCompleted': exercisesCompleted,
    'exercisesTotal': exercisesTotal,
    'attempts': attempts,
    'hintsUsed': hintsUsed,
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'savedCode': savedCode,
  };

  static DateTime? _date(JsonObject json, String key) {
    final value = optionalString(json, key);
    if (value == null) {
      return null;
    }
    try {
      return DateTime.parse(value);
    } on FormatException {
      throw FormatException('Field "$key" must be an ISO-8601 date.');
    }
  }

  static LessonStatus _status(JsonObject json) {
    final value = json.containsKey('status')
        ? requiredString(json, 'status')
        : 'notStarted';
    for (final status in LessonStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    throw FormatException('Unsupported lesson status "$value".');
  }
}

@immutable
class UserProgress {
  final String visitorId;
  final String currentUnitId;
  final String currentLessonId;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final Map<String, LessonProgress> lessonsProgress;
  final List<String> earnedBadges;

  UserProgress({
    required this.visitorId,
    required this.currentUnitId,
    required this.currentLessonId,
    required this.totalXP,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required Map<String, LessonProgress> lessonsProgress,
    required List<String> earnedBadges,
  }) : lessonsProgress = Map.unmodifiable(lessonsProgress),
       earnedBadges = List.unmodifiable(earnedBadges) {
    if (visitorId.trim().isEmpty) {
      throw ArgumentError.value(visitorId, 'visitorId');
    }
    if (totalXP < 0 || currentStreak < 0 || longestStreak < currentStreak) {
      throw ArgumentError(
        'Progress counts must be non-negative and streaks consistent.',
      );
    }
  }

  factory UserProgress.fromJson(JsonObject json) {
    final progressMap = requiredObject(json, 'lessonsProgress');
    final lessonProgress = <String, LessonProgress>{};
    for (final entry in progressMap.entries) {
      final value = LessonProgress.fromJson(_object(entry.value, entry.key));
      if (entry.key != value.lessonId) {
        throw FormatException(
          'Lesson progress map key "${entry.key}" does not match '
          'lessonId "${value.lessonId}".',
        );
      }
      lessonProgress[entry.key] = value;
    }
    return UserProgress(
      visitorId: requiredString(json, 'visitorId'),
      currentUnitId: requiredString(json, 'currentUnitId'),
      currentLessonId: requiredString(json, 'currentLessonId'),
      totalXP: requiredInt(json, 'totalXP', minimum: 0),
      currentStreak: requiredInt(json, 'currentStreak', minimum: 0),
      longestStreak: requiredInt(json, 'longestStreak', minimum: 0),
      lastActiveDate: _requiredDate(json, 'lastActiveDate'),
      lessonsProgress: lessonProgress,
      earnedBadges: stringList(json, 'earnedBadges'),
    );
  }

  JsonObject toJson() => {
    'visitorId': visitorId,
    'currentUnitId': currentUnitId,
    'currentLessonId': currentLessonId,
    'totalXP': totalXP,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastActiveDate': lastActiveDate.toIso8601String(),
    'lessonsProgress': {
      for (final entry in lessonsProgress.entries)
        entry.key: entry.value.toJson(),
    },
    'earnedBadges': earnedBadges,
  };

  static DateTime _requiredDate(JsonObject json, String key) {
    final value = requiredString(json, key);
    try {
      return DateTime.parse(value);
    } on FormatException {
      throw FormatException('Field "$key" must be an ISO-8601 date.');
    }
  }

  static JsonObject _object(Object? value, String key) {
    if (value is! Map) throw FormatException('"$key" must be an object.');
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw FormatException('"$key" must have string keys.');
    }
  }
}
