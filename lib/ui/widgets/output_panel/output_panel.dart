import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../code_directionality.dart';
import '../../../core/theme/editor_theme_extension.dart';
import 'error_display.dart';

enum OutputState { empty, running, success, error }

class OutputPanel extends StatelessWidget {
  const OutputPanel({
    super.key,
    required this.state,
    this.output,
    this.errorMessage,
    this.errorLine,
  });

  final OutputState state;
  final String? output;
  final String? errorMessage;
  final int? errorLine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: state == OutputState.running,
      child: CodeDirectionality(
        child: Card(
          color: switch (state) {
            OutputState.success => colorScheme.tertiaryContainer,
            OutputState.error => colorScheme.errorContainer,
            _ => colorScheme.surfaceContainerHighest,
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: switch (state) {
              OutputState.empty => Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Icon(Icons.terminal),
                  Text(context.l10n.outputEmpty),
                ],
              ),
              OutputState.running => Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  Text(context.l10n.outputRunning),
                ],
              ),
              OutputState.success => _OutputText(output ?? ''),
              OutputState.error => ErrorDisplay(
                message: errorMessage ?? '',
                lineNumber: errorLine,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _OutputText extends StatelessWidget {
  const _OutputText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 240),
    child: SingleChildScrollView(
      child: SelectableText(
        text,
        style: TextStyle(fontFamily: CodeEditorTheme.codeFontFamily),
      ),
    ),
  );
}
