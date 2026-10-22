import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/providers/lesson_provider.dart';
import '../../../logic/providers/progress_provider.dart';

class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final lesson = context.watch<LessonProvider>().selectedLesson;
    final completed = context
        .watch<ProgressProvider>()
        .progress
        ?.lessonsProgress[lessonId];
    final title = lesson?.title.resolve(Localizations.localeOf(context)) ??
        lessonId;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.lessonComplete)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.lessonComplete,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(context.l10n.completedLesson(title)),
              const SizedBox(height: 8),
              Text(
                context.l10n.exercisesSolved(
                  completed?.exercisesCompleted ?? lesson?.exercises.length ?? 0,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/path',
                  (route) => route.isFirst,
                ),
                child: Text(context.l10n.backToPath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
