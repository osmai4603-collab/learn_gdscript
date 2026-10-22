import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/gamification_models.dart';
import 'package:learn_gdscript/data/models/localized_text.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';

void main() {
  test('badge definitions and XP transactions round-trip through JSON', () {
    const badge = BadgeDefinition(
      id: 'badge_first_line',
      title: LocalizedText(ar: 'أول سطر', en: 'First Line'),
      description: LocalizedText(ar: 'وصف', en: 'Description'),
      iconName: 'eco',
      category: BadgeCategory.milestone,
      order: 1,
      conditionType: 'first_print',
      targetValue: 1,
    );
    expect(BadgeDefinition.fromJson(badge.toJson()).toJson(), badge.toJson());

    final transaction = XpTransaction(
      id: 'xp-1',
      amount: 15,
      reason: XpReason.exerciseFirstTry,
      timestamp: DateTime.utc(2026, 10, 22),
      relatedEntityId: 'exercise-1',
    );
    expect(
      XpTransaction.fromJson(transaction.toJson()).toJson(),
      transaction.toJson(),
    );
  });

  test('earned badges serialize dates and levels use 100 XP steps', () {
    final earned = EarnedBadge(
      badgeId: 'badge_first_line',
      earnedAt: DateTime.utc(2026, 10, 22),
    );
    expect(EarnedBadge.fromJson(earned.toJson()).toJson(), earned.toJson());
    final progress = UserProgress(
      visitorId: 'visitor',
      currentUnitId: 'unit',
      currentLessonId: 'lesson',
      totalXP: 245,
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: DateTime.utc(2026, 10, 22),
      lessonsProgress: const {},
      earnedBadges: const [],
    );
    expect(progress.level, 3);
    expect(progress.xpInCurrentLevel, 45);
    expect(progress.xpToNextLevel, 100);
    expect(progress.levelProgressRatio, 0.45);
    expect(const Locale('ar').languageCode, 'ar');
  });
}
