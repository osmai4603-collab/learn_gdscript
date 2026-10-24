import 'package:flutter/material.dart';

class AcademyAppLayout extends StatelessWidget {
  const AcademyAppLayout({
    super.key,
    this.topBar,
    this.navigation,
    this.navigationWidth = 250,
    this.navigationBackgroundColor,
    this.bottomBar,
    this.backgroundColor,
    this.dividerColor,
    this.showTopDivider = true,
    this.showPaneDividers = true,
    this.showBottomDivider = true,
    required this.body,
  }) : assert(navigationWidth > 0);

  final Widget? topBar;
  final Widget? navigation;
  final double navigationWidth;
  final Color? navigationBackgroundColor;
  final Widget? bottomBar;
  final Color? backgroundColor;
  final Color? dividerColor;
  final bool showTopDivider;
  final bool showPaneDividers;
  final bool showBottomDivider;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveDividerColor = dividerColor ?? colors.outlineVariant;

    return Material(
      color: backgroundColor ?? colors.surface,
      child: Row(
        children: [
          if (navigation != null) ...[
            SizedBox(
              width: navigationWidth,
              child: ColoredBox(
                color: navigationBackgroundColor ?? Colors.transparent,
                child: navigation!,
              ),
            ),
            if (showPaneDividers)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: effectiveDividerColor,
              ),
          ],
          Expanded(
            child: Column(
              children: [
                if (topBar != null) ...[
                  topBar!,
                  if (showTopDivider)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: effectiveDividerColor,
                    ),
                ],
                Expanded(child: body),
                if (bottomBar != null && showBottomDivider)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: effectiveDividerColor,
                  ),
                ?bottomBar,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
