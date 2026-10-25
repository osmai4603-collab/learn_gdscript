import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/services/code_runner_service.dart';
import '../code_editor/code_editor_widget.dart';
import '../output_panel/output_panel.dart';

class QuickTryCard extends StatefulWidget {
  const QuickTryCard({super.key});

  @override
  State<QuickTryCard> createState() => _QuickTryCardState();
}

class _QuickTryCardState extends State<QuickTryCard> {
  late String _code;
  OutputState _state = OutputState.empty;
  String? _output;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _code = _codeOrDefault ?? context.l10n.quickTryCode;
  }

  String? _codeOrDefault;

  Future<void> _run() async {
    setState(() {
      _state = OutputState.running;
      _error = null;
    });
    try {
      final result = await context.read<CodeRunnerService>().runCode(_code);
      if (!mounted) return;
      setState(() {
        _state = result.isSuccess ? OutputState.success : OutputState.error;
        _output = result.output.join('\n');
        _error = result.errorMessage;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _state = OutputState.error;
        _error = '${context.l10n.executionFailed} $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.quickTry,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          CodeEditorWidget(
            initialCode: _code,
            fontSize: 14,
            showLineNumbers: false,
            showActionBar: false,
            onSyntaxHighlightsRequested: context
                .read<CodeRunnerService>()
                .getSyntaxHighlights,
            onDiagnosticsRequested: context
                .read<CodeRunnerService>()
                .getDiagnostics,
            onChanged: (code) => _codeOrDefault = _code = code,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _state == OutputState.running ? null : _run,
              icon: const Icon(Icons.play_arrow),
              iconAlignment: .end,
              label: Text(context.l10n.runCode),
            ),
          ),
          const SizedBox(height: 8),
          OutputPanel(state: _state, output: _output, errorMessage: _error),
        ],
      ),
    ),
  );
}
