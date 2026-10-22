import 'package:flutter/foundation.dart';

import 'gamification_models.dart';
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
  final List<String> exercisesWithSolutionViewed;
  final Map<String, int> exerciseAttempts;
  final Map<String, int> exerciseHints;

  LessonProgress({
    required this.lessonId,
    this.status = LessonStatus.notStarted,
    this.exercisesCompleted = 0,
    this.exercisesTotal = 0,
    this.attempts = 0,
    this.hintsUsed = 0,
    this.startedAt,
    this.completedAt,
    this.savedCode,
    List<String> exercisesWithSolutionViewed = const [],
    Map<String, int> exerciseAttempts = const {},
    Map<String, int> exerciseHints = const {},
  }) : assert(exercisesCompleted >= 0),
       assert(exercisesTotal >= 0),
       assert(attempts >= 0),
       assert(hintsUsed >= 0),
       exercisesWithSolutionViewed = List.unmodifiable(
         exercisesWithSolutionViewed,
       ),
       exerciseAttempts = Map.unmodifiable(exerciseAttempts),
       exerciseHints = Map.unmodifiable(exerciseHints) {
    if (this.exerciseAttempts.values.any((count) => count < 0) ||
        this.exerciseHints.values.any((count) => count < 0)) {
      throw ArgumentError('Per-exercise counts must be non-negative.');
    }
  }

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
    exercisesWithSolutionViewed: json.containsKey(
      'exercisesWithSolutionViewed',
    )
        ? stringList(json, 'exercisesWithSolutionViewed')
        : const [],
    exerciseAttempts: _countMap(json, 'exerciseAttempts'),
    exerciseHints: _countMap(json, 'exerciseHints'),
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
    'exercisesWithSolutionViewed': exercisesWithSolutionViewed,
    'exerciseAttempts': exerciseAttempts,
    'exerciseHints': exerciseHints,
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

  static Map<String, int> _countMap(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return const {};
    if (value is! Map) {
      throw FormatException('Field "$key" must be an object.');
    }
    final counts = <String, int>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! int || entry.value < 0) {
        throw FormatException(
          'Field "$key" must map exercise IDs to non-negative integers.',
        );
      }
      counts[entry.key as String] = entry.value as int;
    }
    return counts;
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
  final Map<String, DateTime> earnedBadgeDates;
  final List<XpTransaction> xpTransactions;
  final int firstTrySolvedCount;
  final int syntaxExplorerUses;
  final bool hasExecutedPrint;

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
    Map<String, DateTime> earnedBadgeDates = const {},
    List<XpTransaction> xpTransactions = const [],
    this.firstTrySolvedCount = 0,
    this.syntaxExplorerUses = 0,
    this.hasExecutedPrint = false,
  }) : lessonsProgress = Map.unmodifiable(lessonsProgress),
       earnedBadges = List.unmodifiable(earnedBadges),
       earnedBadgeDates = Map.unmodifiable(earnedBadgeDates),
       xpTransactions = List.unmodifiable(xpTransactions) {
    if (visitorId.trim().isEmpty) {
      throw ArgumentError.value(visitorId, 'visitorId');
    }
    if (totalXP < 0 ||
        currentStreak < 0 ||
        longestStreak < currentStreak ||
        firstTrySolvedCount < 0 ||
        syntaxExplorerUses < 0) {
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
      earnedBadgeDates: _earnedBadgeDates(json),
      xpTransactions: [
        for (final transaction
            in json['xpTransactions'] == null
                ? const <Object?>[]
                : requiredList(json, 'xpTransactions'))
          XpTransaction.fromJson(_object(transaction, 'xpTransactions')),
      ],
      firstTrySolvedCount: json.containsKey('firstTrySolvedCount')
          ? requiredInt(json, 'firstTrySolvedCount', minimum: 0)
          : 0,
      syntaxExplorerUses: json.containsKey('syntaxExplorerUses')
          ? requiredInt(json, 'syntaxExplorerUses', minimum: 0)
          : 0,
      hasExecutedPrint: json.containsKey('hasExecutedPrint')
          ? requiredBool(json, 'hasExecutedPrint')
          : false,
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
    'earnedBadgeDates': {
      for (final entry in earnedBadgeDates.entries)
        entry.key: entry.value.toIso8601String(),
    },
    'xpTransactions': xpTransactions
        .map((transaction) => transaction.toJson())
        .toList(growable: false),
    'firstTrySolvedCount': firstTrySolvedCount,
    'syntaxExplorerUses': syntaxExplorerUses,
    'hasExecutedPrint': hasExecutedPrint,
  };

  static DateTime _requiredDate(JsonObject json, String key) {
    final value = requiredString(json, key);
    try {
      return DateTime.parse(value);
    } on FormatException {
      throw FormatException('Field "$key" must be an ISO-8601 date.');
    }
  }

  static Map<String, DateTime> _earnedBadgeDates(JsonObject json) {
    final value = json['earnedBadgeDates'];
    if (value == null) return const {};
    if (value is! Map) {
      throw const FormatException('Field "earnedBadgeDates" must be an object.');
    }
    final dates = <String, DateTime>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! String) {
        throw const FormatException(
          'Earned badge dates must map badge IDs to ISO-8601 dates.',
        );
      }
      try {
        dates[entry.key as String] = DateTime.parse(entry.value as String);
      } on FormatException {
        throw const FormatException(
          'Earned badge dates must be valid ISO-8601 dates.',
        );
      }
    }
    return dates;
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

extension UserLevelExtension on UserProgress {
  int get level => (totalXP ~/ 100) + 1;
  int get xpInCurrentLevel => totalXP % 100;
  int get xpToNextLevel => 100;
  double get levelProgressRatio => xpInCurrentLevel / 100;
}
