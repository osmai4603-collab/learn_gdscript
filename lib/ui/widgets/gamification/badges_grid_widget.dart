import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/gamification_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../../logic/services/badge_evaluator.dart';
import 'badge_card.dart';

class BadgesGridWidget extends StatelessWidget {
  const BadgesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>().progress;
    final curriculum = context.watch<CurriculumProvider>().state.value;
    final earnedIds = progress?.earnedBadges.toSet() ?? const <String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.badgesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = (constraints.maxWidth / 150).floor().clamp(2, 5);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BadgeEvaluator.catalog.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final badge = BadgeEvaluator.catalog[index];
                final earned = earnedIds.contains(badge.id);
                final (current, target) = _badgeProgress(
                  badge,
                  progress,
                  curriculum,
                );
                return BadgeCard(
                  badge: badge,
                  isUnlocked: earned,
                  earnedAt: progress?.earnedBadgeDates[badge.id],
                  progress: current,
                  progressTarget: target,
                  onTap: () => _showDetails(context, badge, earned, progress),
                );
              },
            );
          },
        ),
      ],
    );
  }

  static (int, int) _badgeProgress(
    BadgeDefinition badge,
    UserProgress? progress,
    Curriculum? curriculum,
  ) {
    if (progress == null) return (0, badge.targetValue);
    return switch (badge.conditionType) {
      'first_print' => (progress.hasExecutedPrint ? 1 : 0, 1),
      'unit_completed' => _unitProgress(
        badge.targetValue,
        progress,
        curriculum,
      ),
      'streak_days' => (progress.currentStreak, badge.targetValue),
      'first_try_count' => (progress.firstTrySolvedCount, badge.targetValue),
      'syntax_explorer_uses' => (progress.syntaxExplorerUses, badge.targetValue),
      'all_units_completed' => (
        curriculum?.units
                .where(
                  (unit) =>
                      unit.lessonIds.isNotEmpty &&
                      unit.lessonIds.every(
                        (id) =>
                            progress.lessonsProgress[id]?.status ==
                            LessonStatus.completed,
                      ),
                )
                .length ??
            0,
        curriculum?.units.length ?? 1,
      ),
      _ => (0, badge.targetValue),
    };
  }

  static (int, int) _unitProgress(
    int order,
    UserProgress progress,
    Curriculum? curriculum,
  ) {
    if (curriculum == null) return (0, 1);
    if (order < 1 || order > curriculum.units.length) return (0, 1);
    final lessonIds = curriculum.units[order - 1].lessonIds;
    final completed = lessonIds
        .where(
          (id) =>
              progress.lessonsProgress[id]?.status == LessonStatus.completed,
        )
        .length;
    return (completed, lessonIds.length);
  }

  static void _showDetails(
    BuildContext context,
    BadgeDefinition badge,
    bool earned,
    UserProgress? progress,
  ) {
    final date = progress?.earnedBadgeDates[badge.id];
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 48),
              const SizedBox(height: 12),
              Text(
                badge.title.resolve(Localizations.localeOf(context)),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(badge.description.resolve(Localizations.localeOf(context))),
              const SizedBox(height: 8),
              Text(
                earned
                    ? date == null
                          ? context.l10n.badgeUnlocked
                          : context.l10n.earnedOn(
                              date.toLocal().toIso8601String().split('T').first,
                            )
                    : context.l10n.badgeLocked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
