import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/localized_text.dart';

class HintWidget extends StatefulWidget {
  const HintWidget({
    super.key,
    required this.hints,
    this.initialVisibleHints = 0,
    this.onHintRevealed,
  });

  final List<LocalizedText> hints;
  final int initialVisibleHints;
  final ValueChanged<int>? onHintRevealed;

  @override
  State<HintWidget> createState() => _HintWidgetState();
}

class _HintWidgetState extends State<HintWidget> {
  late int _visibleHints;

  @override
  void initState() {
    super.initState();
    _visibleHints = widget.initialVisibleHints
        .clamp(0, widget.hints.length)
        .toInt();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _visibleHints; index++)
          Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(widget.hints[index].resolve(locale)),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _visibleHints < widget.hints.length
              ? () {
                  setState(() => _visibleHints++);
                  widget.onHintRevealed?.call(_visibleHints);
                }
              : null,
          icon: const Icon(Icons.lightbulb_outline),
          label: Text(
            _visibleHints < widget.hints.length
                ? l10n.showHint
                : l10n.hintUnavailable,
          ),
        ),
      ],
    );
  }
}
