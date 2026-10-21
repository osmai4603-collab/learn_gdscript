import 'package:flutter/widgets.dart';

abstract final class Responsive {
  static const double wideBreakpoint = 840;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;
}
