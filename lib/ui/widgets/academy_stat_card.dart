import 'package:flutter/material.dart';
import 'academy_surface.dart';

class AcademyStatCard extends StatelessWidget {
  const AcademyStatCard({
    super.key,
    required this.title,
    required this.value,
    this.description,
    this.icon,
    this.accentColor,
  });

  final String title;
  final String value;
  final String? description;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = accentColor ?? Theme.of(context).colorScheme.primary;

    return AcademySurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(description!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
