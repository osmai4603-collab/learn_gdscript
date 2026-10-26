import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/editor_theme_extension.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../widgets/code_editor/code_editor_widget.dart';
import '../../widgets/code_editor/code_editor_run_overlay.dart';
import '../../widgets/output_panel/output_panel.dart';

class LessonExampleSection extends StatelessWidget {
  const LessonExampleSection({
    super.key,
    required this.code,
    required this.running,
    required this.output,
    required this.error,
    required this.outputState,
    required this.onCodeChanged,
    required this.onRun,
  });

  final String code;
  final bool running;
  final String? output;
  final String? error;
  final OutputState outputState;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.exampleLabel,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        CodeEditorRunOverlay(
          isRunning: running,
          onRun: onRun,
          tooltip: context.l10n.runExample,
          editor: CodeEditorWidget(
              initialCode: code,
              readOnly: false,
              backgroundColor: CodeEditorTheme.of(context).background,
              fontSize: context
                  .watch<AppSettingsProvider>()
                  .editorFontSize
                  .toDouble(),
              showActionBar: false,
              onChanged: onCodeChanged,
              onSyntaxHighlightsRequested: context
                  .read<CodeRunnerService>()
                  .getSyntaxHighlights,
              onDiagnosticsRequested: context
                  .read<CodeRunnerService>()
                  .getDiagnostics,
            ),
        ),
        const SizedBox(height: 8),
        OutputPanel(state: outputState, output: output, errorMessage: error),
      ],
    );
  }
}
