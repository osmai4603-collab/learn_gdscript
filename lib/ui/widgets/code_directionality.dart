import 'package:flutter/widgets.dart';

class CodeDirectionality extends StatelessWidget {
  const CodeDirectionality({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Directionality(textDirection: TextDirection.ltr, child: child);
}
