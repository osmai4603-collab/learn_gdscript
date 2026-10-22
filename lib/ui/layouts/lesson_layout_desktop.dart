import 'package:flutter/material.dart';

class LessonLayoutDesktop extends StatefulWidget {
  const LessonLayoutDesktop({
    super.key,
    required this.explanationSection,
    required this.editorSection,
    required this.outputSection,
    required this.actionsSection,
  });

  final Widget explanationSection;
  final Widget editorSection;
  final Widget outputSection;
  final Widget actionsSection;

  @override
  State<LessonLayoutDesktop> createState() => _LessonLayoutDesktopState();
}

class _LessonLayoutDesktopState extends State<LessonLayoutDesktop> {
  double _leftRatio = 0.4;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final leftWidth = constraints.maxWidth * _leftRatio;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: widget.explanationSection,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _leftRatio =
                      (_leftRatio + details.delta.dx / constraints.maxWidth)
                          .clamp(0.25, 0.6);
                });
              },
              child: const SizedBox(
                width: 8,
                child: Center(child: VerticalDivider(width: 1)),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.editorSection,
                  widget.actionsSection,
                  widget.outputSection,
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
