import 'package:flutter/widgets.dart';

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobileBuilder,
    required this.desktopBuilder,
    this.breakpoint = 768,
  });

  final WidgetBuilder mobileBuilder;
  final WidgetBuilder desktopBuilder;
  final double breakpoint;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= breakpoint
        ? desktopBuilder(context)
        : mobileBuilder(context),
  );
}
