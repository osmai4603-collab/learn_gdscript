import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/gamification_models.dart';
import 'badge_card.dart';

class BadgeUnlockedDialog extends StatelessWidget {
  const BadgeUnlockedDialog({super.key, required this.badge});

  final BadgeDefinition badge;

  static Future<void> show(
    BuildContext context,
    BadgeDefinition badge,
  ) => showDialog<void>(
    context: context,
    builder: (_) => BadgeUnlockedDialog(badge: badge),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.celebration, size: 48),
    title: Text(context.l10n.badgeUnlocked),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BadgeCard(badge: badge, isUnlocked: true),
        const SizedBox(height: 8),
        Text(badge.description.resolve(Localizations.localeOf(context))),
      ],
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.great),
      ),
    ],
  );
}
