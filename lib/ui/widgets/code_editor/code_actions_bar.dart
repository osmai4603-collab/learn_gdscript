import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class CodeActionsBar extends StatelessWidget {
  const CodeActionsBar({
    super.key,
    this.onHint,
    this.onReset,
    this.onSolution,
    this.onRun,
    this.onCompletion,
    this.onFormat,
    this.canShowSolution = false,
  });

  final VoidCallback? onHint;
  final VoidCallback? onReset;
  final VoidCallback? onSolution;
  final VoidCallback? onRun;
  final VoidCallback? onCompletion;
  final VoidCallback? onFormat;
  final bool canShowSolution;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (onHint != null)
          OutlinedButton.icon(
            onPressed: onHint,
            icon: const Icon(Icons.lightbulb_outline),
            label: Text(l10n.showHint),
          ),
        if (onReset != null)
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.resetCode),
          ),
        if (onSolution != null && canShowSolution)
          TextButton.icon(
            onPressed: onSolution,
            icon: const Icon(Icons.visibility_outlined),
            label: Text(l10n.showSolution),
          ),
        if (onRun != null)
          FilledButton.icon(
            onPressed: onRun,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.runCode),
          ),
        if (onCompletion != null)
          OutlinedButton.icon(
            onPressed: onCompletion,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.completeCode),
          ),
        if (onFormat != null)
          OutlinedButton.icon(
            onPressed: onFormat,
            icon: const Icon(Icons.format_align_left),
            label: Text(l10n.formatCode),
          ),
      ],
    );
  }
}
