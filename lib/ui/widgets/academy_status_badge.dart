import 'package:flutter/material.dart';

enum AcademyStatusKind { success, warning, error, info, neutral }

class AcademyStatusBadge extends StatelessWidget {
  const AcademyStatusBadge({
    super.key,
    required this.label,
    this.kind = AcademyStatusKind.neutral,
    this.icon,
  });

  final String label;
  final AcademyStatusKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (kind) {
      AcademyStatusKind.success => Color(0xFF2ECC71),
      AcademyStatusKind.warning => Color(0xFFF39C12),
      AcademyStatusKind.error => colors.error,
      AcademyStatusKind.info => colors.primary,
      AcademyStatusKind.neutral => colors.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
