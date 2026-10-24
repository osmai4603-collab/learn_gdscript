import 'package:flutter/material.dart';

class AcademySurface extends StatelessWidget {
  const AcademySurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final BorderRadiusGeometry borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surfaceContainerLow,
        borderRadius: borderRadius,
        border: showBorder
            ? Border.all(color: borderColor ?? colors.outlineVariant)
            : null,
      ),
      child: child,
    );
  }
}
