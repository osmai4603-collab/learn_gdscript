import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../data/repositories/curriculum_repository.dart';

class LessonErrorWidget extends StatelessWidget {
  const LessonErrorWidget({
    super.key,
    this.error,
    this.onRetry,
    this.onBackToPath,
  });

  final Object? error;
  final VoidCallback? onRetry;
  final VoidCallback? onBackToPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String message;
    if (error is LessonNotFoundException) {
      message = context.l10n.lessonMissing;
    } else if (error is LessonParseException) {
      message = context.l10n.lessonUnavailable;
    } else if (error is CurriculumException) {
      message = (error as CurriculumException).message;
    } else if (error != null) {
      message = error.toString();
    } else {
      message = context.l10n.lessonUnavailable;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 32,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.lessonUnavailable,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  if (onRetry != null)
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(context.l10n.retry),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (onBackToPath != null)
                    FilledButton.icon(
                      onPressed: onBackToPath,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(context.l10n.backToPath),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
