import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/progress_provider.dart';

class XpLevelHeader extends StatelessWidget {
  const XpLevelHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>().progress;
    if (progress == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  context.l10n.levelLabel(progress.level),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(context.l10n.totalXp(progress.totalXP)),
              ],
            ),
            const SizedBox(height: 10),
            Semantics(
              label: context.l10n.levelLabel(progress.level),
              value: context.l10n.badgeProgress(
                progress.xpInCurrentLevel,
                progress.xpToNextLevel,
              ),
              child: LinearProgressIndicator(
                value: progress.levelProgressRatio,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.badgeProgress(
                progress.xpInCurrentLevel,
                progress.xpToNextLevel,
              ),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
