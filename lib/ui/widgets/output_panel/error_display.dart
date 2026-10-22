import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../code_directionality.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.message,
    this.lineNumber,
    this.suggestion,
    this.onLineTap,
  });

  final String message;
  final int? lineNumber;
  final String? suggestion;
  final VoidCallback? onLineTap;

  @override
  Widget build(BuildContext context) => CodeDirectionality(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lineNumber != null)
                  InkWell(
                    onTap: onLineTap,
                    child: Text(
                      context.l10n.errorLine(lineNumber!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SelectableText(message),
                if (suggestion != null) ...[
                  const SizedBox(height: 4),
                  Text(suggestion!),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
