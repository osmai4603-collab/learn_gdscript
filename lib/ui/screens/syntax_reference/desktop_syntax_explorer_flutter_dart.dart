import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/navigation_bar.dart';

enum SyntaxCategory { all, keywords, builtins, types }

class SyntaxDocEntryModel {
  const SyntaxDocEntryModel({
    required this.id,
    required this.title,
    required this.signature,
    required this.category,
    required this.categoryLabel,
    required this.description,
    required this.codeExample,
    required this.relatedConcepts,
    this.relatedLesson,
  });

  final String id;
  final String title;
  final String signature;
  final SyntaxCategory category;
  final String categoryLabel;
  final String description;
  final String codeExample;
  final List<String> relatedConcepts;
  final String? relatedLesson;
}

class SyntaxExplorerDataModel {
  const SyntaxExplorerDataModel({
    required this.entries,
    required this.selectedEntryId,
  });

  final List<SyntaxDocEntryModel> entries;
  final String selectedEntryId;
}

class DesktopSyntaxExplorerScreen extends StatefulWidget {
  const DesktopSyntaxExplorerScreen({
    super.key,
    required this.data,
    this.onOpenInWorkspace,
    this.onNavigateRoute,
    this.onSearchSubmitted,
  });

  final SyntaxExplorerDataModel data;
  final ValueChanged<String>? onOpenInWorkspace;
  final ValueChanged<String>? onNavigateRoute;
  final Future<void> Function(String query)? onSearchSubmitted;

  @override
  State<DesktopSyntaxExplorerScreen> createState() =>
      _DesktopSyntaxExplorerScreenState();
}

class _DesktopSyntaxExplorerScreenState
    extends State<DesktopSyntaxExplorerScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  SyntaxCategory _category = SyntaxCategory.all;
  String _selectedId = '';
  int _visibleEntryLimit = 5;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.data.selectedEntryId;
  }

  @override
  void didUpdateWidget(covariant DesktopSyntaxExplorerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.data.entries.any((entry) => entry.id == _selectedId)) {
      _selectedId = widget.data.selectedEntryId;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<SyntaxDocEntryModel> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    final entries = widget.data.entries.where((entry) {
      if (_category != SyntaxCategory.all && entry.category != _category) {
        return false;
      }
      if (query.isEmpty) return true;
      final searchable = [
        entry.title,
        entry.categoryLabel,
        entry.signature,
        entry.description,
        entry.codeExample,
        ...entry.relatedConcepts,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
    entries.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return entries;
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _visibleEntryLimit = 5;
        _selectFirstVisibleEntry();
      });
    });
  }

  void _selectFirstVisibleEntry() {
    final matches = _filteredEntries;
    if (!matches.any((entry) => entry.id == _selectedId) &&
        matches.isNotEmpty) {
      _selectedId = matches.first.id;
    }
  }

  Future<void> _submitSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _filteredEntries.isEmpty) return;
    try {
      await widget.onSearchSubmitted?.call(query);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.syntaxExplorerProgressError,
          ),
        ),
      );
    }
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.syntaxExplorerCopied(label),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entries = _filteredEntries;
    final selected = entries
        .where((entry) => entry.id == _selectedId)
        .firstOrNull;
    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const _FocusSyntaxSearchIntent(),
      },
      child: Actions(
        actions: {
          _FocusSyntaxSearchIntent: CallbackAction<_FocusSyntaxSearchIntent>(
            onInvoke: (_) {
              _searchFocusNode.requestFocus();
              _searchController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _searchController.text.length,
              );
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            bottomNavigationBar: MediaQuery.sizeOf(context).width < 840
                ? AppNavigationBar(
                    selectedRoute: AppRoutes.syntaxReference,
                    onSelected: (route) => widget.onNavigateRoute?.call(route),
                  )
                : null,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PageHeading(entryCount: widget.data.entries.length),
                        const SizedBox(height: 20),
                        _SearchFilters(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          category: _category,
                          quickSearchTokens: widget.data.entries
                              .take(5)
                              .map((entry) => entry.title)
                              .toList(growable: false),
                          onSearchChanged: _onSearchChanged,
                          onSearchSubmitted: _submitSearch,
                          onClear: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          onCategoryChanged: (category) {
                            setState(() {
                              _category = category;
                              _visibleEntryLimit = 5;
                              _selectFirstVisibleEntry();
                            });
                          },
                          onQuickSearch: (query) {
                            _searchController.text = query;
                            _onSearchChanged(query);
                          },
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final catalog = _Catalog(
                              entries: entries
                                  .take(_visibleEntryLimit)
                                  .toList(),
                              totalCount: entries.length,
                              selectedId: _selectedId,
                              onSelect: (entry) {
                                setState(() => _selectedId = entry.id);
                              },
                              onLoadMore: () =>
                                  setState(() => _visibleEntryLimit += 5),
                            );
                            final details = selected == null
                                ? const _EmptyDetails()
                                : _Details(
                                    entry: selected,
                                    onCopyTitle: () => _copy(
                                      selected.title,
                                      l10n.syntaxExplorerCopyEntry,
                                    ),
                                    onCopyExample: () => _copy(
                                      selected.codeExample,
                                      l10n.syntaxExplorerCopyExample,
                                    ),
                                    onOpenLesson: selected.relatedLesson == null
                                        ? null
                                        : () => widget.onNavigateRoute?.call(
                                            AppRoutes.lessonPath(
                                              selected.relatedLesson!,
                                            ),
                                          ),
                                    onOpenWorkspace: () => widget
                                        .onOpenInWorkspace
                                        ?.call(selected.id),
                                  );
                            if (constraints.maxWidth >= 900) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: catalog),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 7, child: details),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                catalog,
                                const SizedBox(height: 20),
                                details,
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusSyntaxSearchIntent extends Intent {
  const _FocusSyntaxSearchIntent();
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.entryCount});

  final int entryCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.syntaxExplorerTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.syntaxExplorerPageDescription),
            ],
          ),
        ),
        Chip(
          avatar: const Icon(Icons.menu_book_outlined),
          label: Text(l10n.syntaxExplorerCount(entryCount)),
        ),
      ],
    );
  }
}

class _SearchFilters extends StatelessWidget {
  const _SearchFilters({
    required this.controller,
    required this.focusNode,
    required this.category,
    required this.quickSearchTokens,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClear,
    required this.onCategoryChanged,
    required this.onQuickSearch,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final SyntaxCategory category;
  final List<String> quickSearchTokens;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onClear;
  final ValueChanged<SyntaxCategory> onCategoryChanged;
  final ValueChanged<String> onQuickSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      (SyntaxCategory.all, l10n.syntaxCategoryAll),
      (SyntaxCategory.keywords, l10n.syntaxCategoryKeywords),
      (SyntaxCategory.builtins, l10n.syntaxCategoryBuiltins),
      (SyntaxCategory.types, l10n.syntaxCategoryTypes),
    ];
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.syntaxExplorerSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? const Tooltip(
                        message: 'Ctrl + K',
                        child: Icon(Icons.keyboard),
                      )
                    : IconButton(
                        tooltip: l10n.syntaxExplorerClearSearch,
                        onPressed: onClear,
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in categories)
                  ChoiceChip(
                    label: Text(item.$2),
                    selected: category == item.$1,
                    onSelected: (_) => onCategoryChanged(item.$1),
                  ),
                for (final token in quickSearchTokens)
                  ActionChip(
                    label: Text(token, textDirection: TextDirection.ltr),
                    onPressed: () => onQuickSearch(token),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Catalog extends StatelessWidget {
  const _Catalog({
    required this.entries,
    required this.totalCount,
    required this.selectedId,
    required this.onSelect,
    required this.onLoadMore,
  });

  final List<SyntaxDocEntryModel> entries;
  final int totalCount;
  final String selectedId;
  final ValueChanged<SyntaxDocEntryModel> onSelect;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.syntaxExplorerEntriesHeading,
                style: theme.textTheme.titleLarge,
              ),
            ),
            Chip(label: Text(l10n.syntaxExplorerCount(totalCount))),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.syntaxExplorerNoResults,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          for (final entry in entries)
            Card(
              color: entry.id == selectedId
                  ? theme.colorScheme.secondaryContainer
                  : null,
              child: ListTile(
                selected: entry.id == selectedId,
                title: Text(
                  entry.title,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(entry.categoryLabel),
                      ),
                      Text(
                        entry.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                onTap: () => onSelect(entry),
              ),
            ),
        if (entries.length < totalCount)
          Align(
            alignment: AlignmentDirectional.center,
            child: TextButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more),
              label: Text(l10n.syntaxExplorerLoadMore),
            ),
          ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.entry,
    required this.onCopyTitle,
    required this.onCopyExample,
    required this.onOpenLesson,
    required this.onOpenWorkspace,
  });

  final SyntaxDocEntryModel entry;
  final VoidCallback onCopyTitle;
  final VoidCallback onCopyExample;
  final VoidCallback? onOpenLesson;
  final VoidCallback onOpenWorkspace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    Text(
                      entry.title,
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.headlineSmall,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          tooltip: l10n.syntaxExplorerCopyEntry,
                          onPressed: onCopyTitle,
                          icon: const Icon(Icons.copy),
                        ),
                        if (onOpenLesson != null)
                          OutlinedButton.icon(
                            onPressed: onOpenLesson,
                            icon: const Icon(Icons.school_outlined),
                            label: Text(l10n.syntaxExplorerOpenLesson),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(entry.categoryLabel),
                ),
                const SizedBox(height: 8),
                Text(entry.description),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CodeCard(title: l10n.syntaxExplorerSignature, code: entry.signature),
        const SizedBox(height: 12),
        _CodeCard(
          title: l10n.syntaxExplorerExample,
          code: entry.codeExample,
          onCopy: onCopyExample,
          copyTooltip: l10n.syntaxExplorerCopyExample,
        ),
        if (entry.relatedConcepts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    '${l10n.syntaxExplorerRelatedConcepts}:',
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final concept in entry.relatedConcepts)
                    Chip(label: Text(concept)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: onOpenWorkspace,
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.syntaxExplorerOpenWorkspace),
          ),
        ),
      ],
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.title,
    required this.code,
    this.onCopy,
    this.copyTooltip,
  });

  final String title;
  final String code;
  final VoidCallback? onCopy;
  final String? copyTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                if (onCopy != null)
                  IconButton(
                    tooltip: copyTooltip,
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  code,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDetails extends StatelessWidget {
  const _EmptyDetails();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(AppLocalizations.of(context)!.syntaxExplorerSelectEntry),
      ),
    ),
  );
}
