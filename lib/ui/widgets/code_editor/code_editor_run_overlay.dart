import 'package:flutter/material.dart';

class CodeEditorRunOverlay extends StatelessWidget {
  const CodeEditorRunOverlay({
    super.key,
    required this.editor,
    required this.isRunning,
    required this.onRun,
    required this.tooltip,
  });

  final Widget editor;
  final bool isRunning;
  final VoidCallback onRun;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.bottomRight,
    children: [
      editor,
      Positioned(
        right: 4,
        bottom: 4,
        child: IconButton(
          tooltip: tooltip,
          onPressed: isRunning ? null : onRun,
          icon: Icon(
            isRunning ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
    ],
  );
}
