import 'package:flutter/material.dart';

class AcademySectionHeader extends StatelessWidget {
  const AcademySectionHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.spacing = 4,
  });

  final String title;
  final String? description;
  final Widget? action;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textTheme.titleLarge),
        if (description != null) ...[
          SizedBox(height: spacing),
          Text(description!, style: textTheme.bodyMedium),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (action == null) return titleContent;
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleContent, SizedBox(height: spacing + 4), action!],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleContent),
            const SizedBox(width: 16),
            action!,
          ],
        );
      },
    );
  }
}
