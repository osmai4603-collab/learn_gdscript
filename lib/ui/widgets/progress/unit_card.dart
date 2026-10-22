import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'progress_bar.dart';

class UnitCard extends StatelessWidget {
  const UnitCard({
    super.key,
    required this.title,
    required this.description,
    required this.completedLessons,
    required this.totalLessons,
    this.isLocked = false,
    this.onTap,
  });

  final String title;
  final String description;
  final int completedLessons;
  final int totalLessons;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = isLocked
        ? l10n.unitLocked
        : completedLessons == totalLessons && totalLessons > 0
        ? l10n.unitCompleted
        : l10n.unitInProgress;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isLocked
                        ? Icons.lock_outline
                        : completedLessons == totalLessons && totalLessons > 0
                        ? Icons.check_circle_outline
                        : Icons.play_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium),
                        Text(description),
                      ],
                    ),
                  ),
                  Text(status, style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
              if (!isLocked) ...[
                const SizedBox(height: 12),
                LessonProgressBar(
                  completed: completedLessons,
                  total: totalLessons,
                  showLabel: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
