import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/gamification_models.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({
    super.key,
    required this.badge,
    required this.isUnlocked,
    this.earnedAt,
    this.progress = 0,
    this.progressTarget,
    this.onTap,
  });

  final BadgeDefinition badge;
  final bool isUnlocked;
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
                  Icon(_badgeIcon(badge.iconName), size: 36, color: foreground),
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
                          ? context.l10n.badgeUnlocked
                          : context.l10n.earnedOn(
                              earnedAt!
                                  .toLocal()
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                            )
                    : context.l10n.badgeProgress(
                        progress.clamp(0, progressTarget ?? badge.targetValue),
                        progressTarget ?? badge.targetValue,
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!isUnlocked) ...[
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progressTarget == null || progressTarget == 0
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

  static IconData _badgeIcon(String name) => switch (name) {
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
}
