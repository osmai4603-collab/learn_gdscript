import 'package:flutter/material.dart';

class AcademyTopBar extends StatelessWidget {
  const AcademyTopBar({
    super.key,
    this.leading,
    this.title,
    this.metrics = const [],
    this.actions = const [],
    this.backgroundColor,
    this.dividerColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.showBottomDivider = true,
  }) : assert(title != null || leading != null);

  final Widget? leading;
  final String? title;
  final List<Widget> metrics;
  final List<Widget> actions;
  final Color? backgroundColor;
  final Color? dividerColor;
  final EdgeInsetsGeometry padding;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final trailing = [
      for (final metric in metrics) metric,
      for (final action in actions) action,
    ];

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surfaceContainerLow,
        border: showBottomDivider
            ? Border(
                bottom: BorderSide(color: dividerColor ?? colors.outlineVariant),
              )
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      if (title != null) const SizedBox(width: 12),
                    ],
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                  ],
                ),
                if (trailing.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: trailing,
                  ),
                ],
              ],
            );
          }

          return Row(
            children: [
              if (leading != null) ...[
                leading!,
                if (title != null) const SizedBox(width: 12),
              ],
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              if (trailing.isNotEmpty) ...[
                const SizedBox(width: 16),
                Flexible(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: trailing,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
