import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/providers/progress_provider.dart';

class StreakBadgeWidget extends StatelessWidget {
  const StreakBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final visible = context.watch<AppSettingsProvider>().showStreakInUi;
    final streak = context.watch<ProgressProvider>().progress?.currentStreak ?? 0;
    if (!visible || streak == 0) return const SizedBox.shrink();
    return ActionChip(
      avatar: Icon(
        Icons.local_fire_department,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      label: Text(context.l10n.streakDays(streak)),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.local_fire_department),
          title: Text(context.l10n.streakDays(streak)),
          content: Text(context.l10n.streakInfo),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.great),
            ),
          ],
        ),
      ),
    );
  }
}
