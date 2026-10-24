import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/providers/language_server_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/output_panel/error_display.dart';

enum _WorkspaceSearchMode { text, symbols }

class WorkspaceSearchScreen extends StatefulWidget {
  const WorkspaceSearchScreen({super.key});

  @override
  State<WorkspaceSearchScreen> createState() => _WorkspaceSearchScreenState();
}

class _WorkspaceSearchScreenState extends State<WorkspaceSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  _WorkspaceSearchMode _mode = _WorkspaceSearchMode.text;
  Object? _result;
  Object? _error;
  bool _searching = false;

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
      _result = null;
    });
    try {
      final server = context.read<LanguageServerProvider>();
      final result = _mode == _WorkspaceSearchMode.text
          ? await server.searchWorkspace(query)
          : await server.workspaceSymbols(query);
      if (!mounted) return;
      setState(() {
        _result = result;
        _searching = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final server = context.watch<LanguageServerProvider>();
    final hasResults = _result is! List || (_result! as List).isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workspaceSearchTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SegmentedButton<_WorkspaceSearchMode>(
            segments: [
              ButtonSegment(
                value: _WorkspaceSearchMode.text,
                label: Text(l10n.searchWorkspaceText),
              ),
              ButtonSegment(
                value: _WorkspaceSearchMode.symbols,
                label: Text(l10n.searchWorkspaceSymbols),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) =>
                setState(() => _mode = selection.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _queryController,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: l10n.workspaceSearchPlaceholder,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed:
                !server.isConnected ||
                    _searching ||
                    _queryController.text.trim().isEmpty
                ? null
                : _search,
            icon: const Icon(Icons.search),
            label: Text(l10n.workspaceSearchTitle),
          ),
          if (!server.isConnected) ...[
            const SizedBox(height: 16),
            EmptyState(icon: Icons.link_off, message: l10n.lspDisconnected),
          ],
          if (_searching) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            ErrorDisplay(message: '${l10n.lspFeatureError} $_error'),
          ],
          if (_result != null && !hasResults) ...[
            const SizedBox(height: 16),
            EmptyState(
              icon: Icons.search_off,
              message: l10n.workspaceSearchEmpty,
            ),
          ],
          if (_result != null && hasResults) ...[
            const SizedBox(height: 16),
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(_result),
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontFamily: 'JetBrains Mono'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
