import 'package:flutter/material.dart';

class LessonLayoutMobile extends StatelessWidget {
  const LessonLayoutMobile({
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      explanationSection,
      const SizedBox(height: 20),
      editorSection,
      actionsSection,
      outputSection,
    ],
  );
}
