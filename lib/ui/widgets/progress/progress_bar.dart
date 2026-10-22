import 'package:flutter/material.dart';

class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    super.key,
    required this.completed,
    required this.total,
    this.height = 8,
    this.showLabel = true,
  });

  final int completed;
  final int total;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total <= 0
        ? 0.0
        : (completed / total).clamp(0.0, 1.0).toDouble();
    final color = Color.lerp(
      theme.colorScheme.error,
      theme.colorScheme.tertiary,
      ratio,
    )!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: ratio),
            duration: const Duration(milliseconds: 350),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: height,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            '$completed/$total',
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ],
    );
  }
}
