import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/repositories/syntax_reference_repository.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/progress_provider.dart';

class SyntaxReferenceScreen extends StatefulWidget {
  const SyntaxReferenceScreen({super.key, required this.repository});

  final SyntaxReferenceRepository repository;

  @override
  State<SyntaxReferenceScreen> createState() => _SyntaxReferenceScreenState();
}

class _SyntaxReferenceScreenState extends State<SyntaxReferenceScreen> {
  final _queryController = TextEditingController();
  Future<List<SyntaxReference>>? _results;
  Object? _error;

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _error = null;
      _results = null;
    });
    try {
      final curriculum = context.read<CurriculumProvider>().state.value;
      final progressProvider = context.read<ProgressProvider>();
      final results = await widget.repository.search(query);
      if (!mounted) return;
      if (curriculum == null) {
        throw StateError('Curriculum is not available.');
      }
      await progressProvider.recordSyntaxExplorerUse(curriculum: curriculum);
      if (mounted) setState(() => _results = Future.value(results));
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.syntaxExplorerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _queryController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: context.l10n.syntaxExplorerPlaceholder,
              suffixIcon: IconButton(
                tooltip: context.l10n.searchWorkspaceText,
                onPressed: _search,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_error case final error?)
            Text(
              '${context.l10n.lessonUnavailable} $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_results case final results?)
            FutureBuilder<List<SyntaxReference>>(
              future: results,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('${context.l10n.lessonUnavailable} ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isEmpty) {
                  return Text(context.l10n.workspaceSearchEmpty);
                }
                return Column(
                  children: [
                    for (final item in snapshot.data!)
                      Card(
                        child: ExpansionTile(
                          title: Text(item.title.resolve(locale)),
                          subtitle: Text(item.syntax),
                          childrenPadding: const EdgeInsets.all(16),
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(item.description.resolve(locale)),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: SelectableText(item.example),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
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
