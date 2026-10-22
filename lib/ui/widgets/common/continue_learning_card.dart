import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../progress/progress_bar.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.unitTitle,
    required this.lessonTitle,
    required this.completedLessons,
    required this.totalLessons,
    required this.onTap,
  });

  final String unitTitle;
  final String lessonTitle;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.continueLearning,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('$unitTitle · $lessonTitle'),
          const SizedBox(height: 12),
          LessonProgressBar(
            completed: completedLessons,
            total: totalLessons,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward),
              label: Text(context.l10n.continueLearning),
            ),
          ),
        ],
      ),
    ),
  );
}
