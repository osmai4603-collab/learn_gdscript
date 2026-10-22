import '../../data/models/curriculum_models.dart';
import '../../data/models/gamification_models.dart';
import '../../data/models/localized_text.dart';
import '../../data/models/progress_models.dart';

class BadgeEvaluator {
  const BadgeEvaluator();

  static const List<BadgeDefinition> catalog = [
    BadgeDefinition(
      id: 'badge_first_line',
      title: LocalizedText(ar: 'أول سطر', en: 'First Line'),
      description: LocalizedText(
        ar: 'أكملت أول أمر طباعة بنجاح',
        en: 'Successfully completed your first print statement',
      ),
      iconName: 'eco',
      category: BadgeCategory.milestone,
      order: 1,
      conditionType: 'first_print',
      targetValue: 1,
    ),
    BadgeDefinition(
      id: 'badge_unit_01',
      title: LocalizedText(ar: 'مبرمج مبتدئ', en: 'Novice Coder'),
      description: LocalizedText(
        ar: 'أكملت وحدة أول برنامج بنجاح',
        en: 'Completed the First Program unit',
      ),
      iconName: 'star',
      category: BadgeCategory.milestone,
      order: 2,
      conditionType: 'unit_completed',
      targetValue: 1,
    ),
    BadgeDefinition(
      id: 'badge_unit_02',
      title: LocalizedText(ar: 'سيد المتغيرات', en: 'Variable Master'),
      description: LocalizedText(
        ar: 'أكملت وحدة المتغيرات والأنواع',
        en: 'Completed the Variables and Types unit',
      ),
      iconName: 'inventory_2',
      category: BadgeCategory.milestone,
      order: 3,
      conditionType: 'unit_completed',
      targetValue: 2,
    ),
    BadgeDefinition(
      id: 'badge_unit_03',
      title: LocalizedText(ar: 'صانع القرارات', en: 'Decision Maker'),
      description: LocalizedText(
        ar: 'أكملت وحدة الشروط والقرارات',
        en: 'Completed the Conditions and Decisions unit',
      ),
      iconName: 'alt_route',
      category: BadgeCategory.milestone,
      order: 4,
      conditionType: 'unit_completed',
      targetValue: 3,
    ),
    BadgeDefinition(
      id: 'badge_unit_04',
      title: LocalizedText(ar: 'عدّاد لا يتعب', en: 'Relentless Counter'),
      description: LocalizedText(
        ar: 'أكملت وحدة الحلقات والتكرار',
        en: 'Completed the Loops and Repetition unit',
      ),
      iconName: 'loop',
      category: BadgeCategory.milestone,
      order: 5,
      conditionType: 'unit_completed',
      targetValue: 4,
    ),
    BadgeDefinition(
      id: 'badge_unit_05',
      title: LocalizedText(ar: 'منظّم الكود', en: 'Code Organizer'),
      description: LocalizedText(
        ar: 'أكملت وحدة الدوال وإعادة الاستخدام',
        en: 'Completed the Functions and Reuse unit',
      ),
      iconName: 'extension',
      category: BadgeCategory.milestone,
      order: 6,
      conditionType: 'unit_completed',
      targetValue: 5,
    ),
    BadgeDefinition(
      id: 'badge_fast_solver',
      title: LocalizedText(ar: 'حلّال سريع', en: 'Fast Solver'),
      description: LocalizedText(
        ar: 'حللت خمسة تمارين من المحاولة الأولى',
        en: 'Solved five exercises on the first try',
      ),
      iconName: 'bolt',
      category: BadgeCategory.skill,
      order: 7,
      conditionType: 'first_try_count',
      targetValue: 5,
    ),
    BadgeDefinition(
      id: 'badge_perseverant',
      title: LocalizedText(ar: 'مثابر', en: 'Perseverant'),
      description: LocalizedText(
        ar: 'حافظت على سلسلة تعلم لسبعة أيام',
        en: 'Maintained a learning streak for seven days',
      ),
      iconName: 'local_fire_department',
      category: BadgeCategory.streak,
      order: 8,
      conditionType: 'streak_days',
      targetValue: 7,
    ),
    BadgeDefinition(
      id: 'badge_researcher',
      title: LocalizedText(ar: 'باحث', en: 'Researcher'),
      description: LocalizedText(
        ar: 'استخدمت مستكشف الصياغة عشر مرات',
        en: 'Used the syntax explorer ten times',
      ),
      iconName: 'search',
      category: BadgeCategory.explorer,
      order: 9,
      conditionType: 'syntax_explorer_uses',
      targetValue: 10,
    ),
    BadgeDefinition(
      id: 'badge_graduate',
      title: LocalizedText(ar: 'خريج المسار', en: 'Path Graduate'),
      description: LocalizedText(
        ar: 'أكملت جميع الوحدات التعليمية',
        en: 'Completed every learning unit',
      ),
      iconName: 'school',
      category: BadgeCategory.milestone,
      order: 10,
      conditionType: 'all_units_completed',
      targetValue: 1,
    ),
  ];

  List<BadgeDefinition> evaluateNewBadges({
    required UserProgress progress,
    required Curriculum curriculum,
    Map<String, Object?> metrics = const {},
  }) {
    final earnedIds = progress.earnedBadges.toSet();
    return [
      for (final badge in catalog)
        if (!earnedIds.contains(badge.id) &&
            _isConditionMet(badge, progress, curriculum, metrics))
          badge,
    ];
  }

  bool _isConditionMet(
    BadgeDefinition badge,
    UserProgress progress,
    Curriculum curriculum,
    Map<String, Object?> metrics,
  ) {
    return switch (badge.conditionType) {
      'first_print' =>
        progress.hasExecutedPrint || metrics['hasExecutedPrint'] == true,
      'unit_completed' =>
        _checkUnitCompleted(progress, curriculum, badge.targetValue),
      'streak_days' => progress.currentStreak >= badge.targetValue,
      'first_try_count' => progress.firstTrySolvedCount >= badge.targetValue,
      'syntax_explorer_uses' =>
        progress.syntaxExplorerUses >= badge.targetValue,
      'all_units_completed' => _checkAllUnitsCompleted(progress, curriculum),
      _ => false,
    };
  }

  bool _checkUnitCompleted(
    UserProgress progress,
    Curriculum curriculum,
    int unitOrder,
  ) {
    final unit = unitOrder > 0 && unitOrder <= curriculum.units.length
        ? curriculum.units[unitOrder - 1]
        : null;
    return unit != null &&
        unit.lessonIds.isNotEmpty &&
        unit.lessonIds.every(
          (lessonId) =>
              progress.lessonsProgress[lessonId]?.status ==
              LessonStatus.completed,
        );
  }

  bool _checkAllUnitsCompleted(
    UserProgress progress,
    Curriculum curriculum,
  ) =>
      curriculum.units.isNotEmpty &&
      curriculum.units.every(
        (unit) =>
            unit.lessonIds.isNotEmpty &&
            unit.lessonIds.every(
              (lessonId) =>
                  progress.lessonsProgress[lessonId]?.status ==
                  LessonStatus.completed,
            ),
      );
}
