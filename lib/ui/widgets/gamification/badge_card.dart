import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/gamification_models.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({
    super.key,
    required this.badge,
    required this.isUnlocked,
    this.isSelected = false,
    this.showProgressWhenUnlocked = false,
    this.earnedAt,
    this.progress = 0,
    this.progressTarget,
    this.onTap,
  });

  final BadgeDefinition badge;
  final bool isUnlocked;
  final bool isSelected;
  final bool showProgressWhenUnlocked;
  final DateTime? earnedAt;
  final int progress;
  final int? progressTarget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isUnlocked
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 1.6 : 0.6,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    badgeIconForName(badge.iconName),
                    size: 36,
                    color: foreground,
                  ),
                  if (!isUnlocked)
                    Positioned(
                      bottom: -4,
                      right: -8,
                      child: Icon(
                        Icons.lock,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                badge.title.resolve(locale),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                isUnlocked
                    ? earnedAt == null
                          ? context.l10n.badgeEarnedStatus
                          : context.l10n.earnedOn(
                              MaterialLocalizations.of(
                                context,
                              ).formatMediumDate(earnedAt!.toLocal()),
                            )
                    : context.l10n.badgeProgress(
                        progress.clamp(0, progressTarget ?? badge.targetValue),
                        progressTarget ?? badge.targetValue,
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!isUnlocked || showProgressWhenUnlocked) ...[
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: isUnlocked
                      ? 1
                      : progressTarget == null || progressTarget == 0
                      ? 0
                      : (progress / progressTarget!).clamp(0.0, 1.0),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

IconData badgeIconForName(String name) => switch (name) {
  'eco' => Icons.eco,
  'star' => Icons.star,
  'inventory_2' => Icons.inventory_2,
  'alt_route' => Icons.alt_route,
  'loop' => Icons.loop,
  'extension' => Icons.extension,
  'bolt' => Icons.bolt,
  'local_fire_department' => Icons.local_fire_department,
  'search' => Icons.search,
  'school' => Icons.school,
  _ => Icons.emoji_events,
};
