import 'package:flutter/foundation.dart';

import '../../data/models/async_state.dart';
import '../../data/models/curriculum_models.dart';
import '../../data/models/gamification_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/repositories/progress_repository.dart';
import '../services/badge_evaluator.dart';
import '../services/gamification_service.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(
    this._repository, {
    this._gamificationService = const GamificationService(),
    this._badgeEvaluator = const BadgeEvaluator(),
  });

  final ProgressRepository _repository;
  final GamificationService _gamificationService;
  final BadgeEvaluator _badgeEvaluator;
  AsyncState<UserProgress?> state = const AsyncState.initial();
  int _transactionSequence = 0;

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
    final current = _requireProgress();
    final lessons = Map<String, LessonProgress>.from(current.lessonsProgress)
      ..[lessonId] = lessonProgress;
    await save(
      _copy(
        current,
        currentUnitId: unitId,
        currentLessonId: lessonId,
        lessonsProgress: lessons,
      ),
    );
  }

  Future<GamificationEventResult> recordExerciseResult({
    required Curriculum curriculum,
    required String lessonId,
    required int attempts,
    required int hintsCount,
    required bool usedSolution,
    required String code,
    DateTime? now,
  }) async {
    if (attempts < 1) throw ArgumentError.value(attempts, 'attempts');
    final current = _requireProgress();
    final timestamp = now ?? DateTime.now();
    final award = _gamificationService.calculateExerciseXP(
      isFirstTry: attempts == 1,
      usedSolution: usedSolution,
      hintsCount: hintsCount,
    );
    final streak = _updatedStreak(current, timestamp);
    final transactions = [...current.xpTransactions];
    if (usedSolution) {
      transactions.add(
        _transaction(
          amount: 0,
          reason: XpReason.solutionViewed,
          timestamp: timestamp,
          entityId: lessonId,
        ),
      );
    } else if (award > 0) {
      transactions.add(
        _transaction(
          amount: award,
          reason: attempts == 1
              ? XpReason.exerciseFirstTry
              : XpReason.exerciseRetry,
          timestamp: timestamp,
          entityId: lessonId,
        ),
      );
    }
    if (streak.result.earnedBonusXP > 0) {
      transactions.add(
        _transaction(
          amount: streak.result.earnedBonusXP,
          reason: XpReason.dailyStreakBonus,
          timestamp: timestamp,
        ),
      );
    }
    final withActivity = _copy(
      current,
      totalXP:
          current.totalXP + award + streak.result.earnedBonusXP,
      currentStreak: streak.result.currentStreak,
      longestStreak: streak.result.longestStreak,
      lastActiveDate: timestamp,
      firstTrySolvedCount:
          current.firstTrySolvedCount + (attempts == 1 && !usedSolution ? 1 : 0),
      hasExecutedPrint:
          current.hasExecutedPrint ||
          (code.contains(RegExp(r'\bprint\s*\(')) && !usedSolution),
      xpTransactions: transactions,
    );
    final updated = await _unlockEligibleBadges(withActivity, curriculum);
    await save(updated);
    return GamificationEventResult(
      earnedXP: award + streak.result.earnedBonusXP,
      newlyUnlockedBadges: _newBadges(current, updated),
    );
  }

  Future<GamificationEventResult> recordLessonCompletion({
    required Curriculum curriculum,
    required String unitId,
    required String lessonId,
    DateTime? now,
  }) async {
    final current = _requireProgress();
    final timestamp = now ?? DateTime.now();
    final lessons = current.lessonsProgress;
    if (lessons[lessonId]?.status != LessonStatus.completed) {
      throw StateError('A lesson must be completed before it earns XP.');
    }
    final transactions = [...current.xpTransactions];
    var award = 0;
    if (!_hasTransaction(current, XpReason.lessonCompleted, lessonId)) {
      award += GamificationService.lessonCompletionXp;
      transactions.add(
        _transaction(
          amount: GamificationService.lessonCompletionXp,
          reason: XpReason.lessonCompleted,
          timestamp: timestamp,
          entityId: lessonId,
        ),
      );
    }
    final unit = curriculum.units.where((item) => item.id == unitId);
    if (unit.isNotEmpty &&
        unit.first.lessonIds.isNotEmpty &&
        unit.first.lessonIds.every(
          (id) => lessons[id]?.status == LessonStatus.completed,
        ) &&
        !_hasTransaction(current, XpReason.unitCompleted, unitId)) {
      award += GamificationService.unitCompletionXp;
      transactions.add(
        _transaction(
          amount: GamificationService.unitCompletionXp,
          reason: XpReason.unitCompleted,
          timestamp: timestamp,
          entityId: unitId,
        ),
      );
    }
    final updated = await _unlockEligibleBadges(
      _copy(
        current,
        totalXP: current.totalXP + award,
        xpTransactions: transactions,
        lastActiveDate: timestamp,
      ),
      curriculum,
    );
    await save(updated);
    return GamificationEventResult(
      earnedXP: award,
      newlyUnlockedBadges: _newBadges(current, updated),
    );
  }

  Future<GamificationEventResult> recordExampleExecuted({
    required Curriculum curriculum,
    required String lessonId,
    required bool successful,
    DateTime? now,
  }) async {
    if (!successful) return const GamificationEventResult();
    final current = _requireProgress();
    final timestamp = now ?? DateTime.now();
    final streak = _updatedStreak(current, timestamp);
    final transactions = [
      ...current.xpTransactions,
      _transaction(
        amount: GamificationService.exampleExecutionXp,
        reason: XpReason.exampleExecuted,
        timestamp: timestamp,
        entityId: lessonId,
      ),
      if (streak.result.earnedBonusXP > 0)
        _transaction(
          amount: streak.result.earnedBonusXP,
          reason: XpReason.dailyStreakBonus,
          timestamp: timestamp,
        ),
    ];
    final updated = await _unlockEligibleBadges(
      _copy(
        current,
        totalXP:
            current.totalXP +
            GamificationService.exampleExecutionXp +
            streak.result.earnedBonusXP,
        currentStreak: streak.result.currentStreak,
        longestStreak: streak.result.longestStreak,
        lastActiveDate: timestamp,
        xpTransactions: transactions,
      ),
      curriculum,
    );
    await save(updated);
    return GamificationEventResult(
      earnedXP:
          GamificationService.exampleExecutionXp +
          streak.result.earnedBonusXP,
      newlyUnlockedBadges: _newBadges(current, updated),
    );
  }

  Future<GamificationEventResult> recordSyntaxExplorerUse({
    required Curriculum curriculum,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    await checkAndUpdateDailyStreak(now: timestamp);
    final current = _requireProgress();
    final updated = await _unlockEligibleBadges(
      _copy(
        current,
        syntaxExplorerUses: current.syntaxExplorerUses + 1,
        lastActiveDate: timestamp,
      ),
      curriculum,
    );
    await save(updated);
    return GamificationEventResult(
      newlyUnlockedBadges: _newBadges(current, updated),
    );
  }

  Future<void> checkAndUpdateDailyStreak({DateTime? now}) async {
    final current = _requireProgress();
    final timestamp = now ?? DateTime.now();
    final streak = _updatedStreak(current, timestamp);
    if (!streak.result.isNewDay && current.currentStreak > 0) return;
    final transactions = [...current.xpTransactions];
    if (streak.result.earnedBonusXP > 0) {
      transactions.add(
        _transaction(
          amount: streak.result.earnedBonusXP,
          reason: XpReason.dailyStreakBonus,
          timestamp: timestamp,
        ),
      );
    }
    await save(
      _copy(
        current,
      totalXP: current.totalXP + streak.result.earnedBonusXP,
        currentStreak: streak.result.currentStreak,
        longestStreak: streak.result.longestStreak,
        lastActiveDate: timestamp,
        xpTransactions: transactions,
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
    final current = _requireProgress();
    await save(
      _copy(
        current,
        currentUnitId: unitId,
        currentLessonId: lessonId,
      ),
    );
  }

  UserProgress _requireProgress() {
    final current = progress;
    if (current == null) {
      throw StateError('Progress must be initialized before it is updated.');
    }
    return current;
  }

  ({StreakUpdateResult result}) _updatedStreak(
  UserProgress current,
  DateTime timestamp,
  ) => (
  result: _gamificationService.calculateStreakUpdate(
    lastActiveDate: current.lastActiveDate,
    currentStreak: current.currentStreak,
    longestStreak: current.longestStreak,
    now: timestamp,
  ),
  );

  Future<UserProgress> _unlockEligibleBadges(
    UserProgress current,
    Curriculum curriculum,
  ) async {
    final earned = _badgeEvaluator.evaluateNewBadges(
      progress: current,
      curriculum: curriculum,
    );
    if (earned.isEmpty) return current;
    final dates = Map<String, DateTime>.from(current.earnedBadgeDates);
    final earnedIds = [...current.earnedBadges];
    for (final badge in earned) {
      earnedIds.add(badge.id);
      dates[badge.id] = DateTime.now();
    }
    return _copy(current, earnedBadges: earnedIds, earnedBadgeDates: dates);
  }

  List<BadgeDefinition> _newBadges(UserProgress before, UserProgress after) {
    final oldIds = before.earnedBadges.toSet();
    return [
      for (final id in after.earnedBadges)
        if (!oldIds.contains(id))
          BadgeEvaluator.catalog.firstWhere((badge) => badge.id == id),
    ];
  }

  bool _hasTransaction(UserProgress progress, XpReason reason, String entityId) =>
      progress.xpTransactions.any(
        (item) => item.reason == reason && item.relatedEntityId == entityId,
      );

  XpTransaction _transaction({
    required int amount,
    required XpReason reason,
    required DateTime timestamp,
    String? entityId,
  }) => XpTransaction(
    id: '${timestamp.microsecondsSinceEpoch}-${_transactionSequence++}',
    amount: amount,
    reason: reason,
    timestamp: timestamp,
    relatedEntityId: entityId,
  );

  UserProgress _copy(
    UserProgress source, {
    String? currentUnitId,
    String? currentLessonId,
    int? totalXP,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    Map<String, LessonProgress>? lessonsProgress,
    List<String>? earnedBadges,
    Map<String, DateTime>? earnedBadgeDates,
    List<XpTransaction>? xpTransactions,
    int? firstTrySolvedCount,
    int? syntaxExplorerUses,
    bool? hasExecutedPrint,
  }) => UserProgress(
    visitorId: source.visitorId,
    currentUnitId: currentUnitId ?? source.currentUnitId,
    currentLessonId: currentLessonId ?? source.currentLessonId,
    totalXP: totalXP ?? source.totalXP,
    currentStreak: currentStreak ?? source.currentStreak,
    longestStreak: longestStreak ?? source.longestStreak,
    lastActiveDate: lastActiveDate ?? source.lastActiveDate,
    lessonsProgress: lessonsProgress ?? source.lessonsProgress,
    earnedBadges: earnedBadges ?? source.earnedBadges,
    earnedBadgeDates: earnedBadgeDates ?? source.earnedBadgeDates,
    xpTransactions: xpTransactions ?? source.xpTransactions,
    firstTrySolvedCount:
        firstTrySolvedCount ?? source.firstTrySolvedCount,
    syntaxExplorerUses: syntaxExplorerUses ?? source.syntaxExplorerUses,
    hasExecutedPrint: hasExecutedPrint ?? source.hasExecutedPrint,
  );
}

@immutable
class GamificationEventResult {
  const GamificationEventResult({
    this.earnedXP = 0,
    this.newlyUnlockedBadges = const [],
  });

  final int earnedXP;
  final List<BadgeDefinition> newlyUnlockedBadges;
}
