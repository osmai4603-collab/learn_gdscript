import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class LessonProgressStatus extends StatelessWidget {
  const LessonProgressStatus({
    super.key,
    required this.saving,
    required this.saveError,
    required this.savedProgressSequence,
    required this.savedCode,
  });

  final bool saving;
  final String? saveError;
  final int savedProgressSequence;
  final String? savedCode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (saving) const LinearProgressIndicator(minHeight: 2),
      if (saveError case final error?)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            context.l10n.dashboardSaveError(error),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        )
      else if (!saving && savedProgressSequence > 0 && savedCode != null)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Text(context.l10n.dashboardDraftAutoSaved),
            ],
          ),
        ),
      const SizedBox(height: 16),
    ],
  );
}
