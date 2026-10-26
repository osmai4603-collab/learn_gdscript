import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/repositories/workspace_repository.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/output_panel/error_display.dart';

class WorkspaceSearchScreen extends StatefulWidget {
  const WorkspaceSearchScreen({
    super.key,
    required this.repository,
  });

  final WorkspaceRepository repository;

  @override
  State<WorkspaceSearchScreen> createState() => _WorkspaceSearchScreenState();
}

class _WorkspaceSearchScreenState extends State<WorkspaceSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
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
      final matches = await widget.repository.searchText(query);
      if (!mounted) return;
      setState(() {
        _result = [
          for (final match in matches)
            {
              'file': match.relativePath,
              'line': match.line,
              'column': match.column,
              'preview': match.preview,
            },
        ];
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
    final matches = _result is List
        ? _result! as List<Map<String, Object?>>
        : const <Map<String, Object?>>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workspaceSearchTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
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
            onPressed: _searching || _queryController.text.trim().isEmpty
              ? null
              : _search,
            icon: const Icon(Icons.search),
            label: Text(l10n.workspaceSearchTitle),
            iconAlignment: .end,
          ),
          if (_searching) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            ErrorDisplay(message: '${l10n.lessonUnavailable} $_error'),
          ],
          if (_result != null && matches.isEmpty) ...[
            const SizedBox(height: 16),
            EmptyState(
              icon: Icons.search_off,
              message: l10n.workspaceSearchEmpty,
            ),
          ],
          if (_result != null && matches.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final match in matches)
              ListTile(
                title: Text(
                  '${match['file']}:${match['line']}:${match['column']}',
                  textDirection: TextDirection.ltr,
                ),
                subtitle: SelectableText(
                  match['preview']! as String,
                  textDirection: TextDirection.ltr,
                  style: CodeTextTheme.of(context).bodySmall.copyWith(
                    fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                    height: Theme.of(context).textTheme.bodySmall!.height,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
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
