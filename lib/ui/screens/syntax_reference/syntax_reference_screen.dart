import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/repositories/syntax_reference_repository.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/navigation_bar.dart';
import 'desktop_syntax_explorer_flutter_dart.dart';

class SyntaxReferenceScreen extends StatefulWidget {
  const SyntaxReferenceScreen({super.key, required this.repository});

  final SyntaxReferenceRepository repository;

  @override
  State<SyntaxReferenceScreen> createState() => _SyntaxReferenceScreenState();
}

class _SyntaxReferenceScreenState extends State<SyntaxReferenceScreen> {
  late Future<List<SyntaxReference>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = widget.repository.search('');
  }

  void _retryLoading() {
    setState(() => _entriesFuture = widget.repository.search(''));
  }

  Future<void> _recordSearch(String query) async {
    if (query.trim().isEmpty) return;
    final curriculum = context.read<CurriculumProvider>().state.value;
    if (curriculum == null) {
      throw StateError('Curriculum is not available.');
    }
    await context.read<ProgressProvider>().recordSyntaxExplorerUse(
      curriculum: curriculum,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    return FutureBuilder<List<SyntaxReference>>(
      future: _entriesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SyntaxReferenceError(
            error: snapshot.error!,
            onRetry: _retryLoading,
            showBottomNavigation: !wide,
          );
        }
        if (!snapshot.hasData) {
          return _SyntaxReferenceLoading(showBottomNavigation: !wide);
        }

        final entries = snapshot.data!;
        final locale = Localizations.localeOf(context);
        final l10n = context.l10n;
        final modelEntries = entries
            .map((entry) {
              final category = _syntaxCategory(entry.category);
              final categoryLabel = switch (category) {
                SyntaxCategory.keywords => l10n.syntaxCategoryKeywords,
                SyntaxCategory.builtins => l10n.syntaxCategoryBuiltins,
                SyntaxCategory.types => l10n.syntaxCategoryTypes,
                SyntaxCategory.all => entry.category,
              };
              return SyntaxDocEntryModel(
                id: '${entry.category}:${entry.id}',
                title: entry.title.resolve(locale),
                signature: entry.syntax,
                category: category,
                categoryLabel: categoryLabel,
                description: entry.description.resolve(locale),
                codeExample: entry.example,
                relatedConcepts: entry.seeAlso,
                relatedLesson: entry.relatedLesson,
              );
            })
            .toList(growable: false);

        return DesktopSyntaxExplorerScreen(
          data: SyntaxExplorerDataModel(
            entries: modelEntries,
            selectedEntryId: modelEntries.isEmpty ? '' : modelEntries.first.id,
          ),
          onSearchSubmitted: _recordSearch,
          onNavigateRoute: (route) => context.go(route),
          onOpenInWorkspace: (_) => context.go(AppRoutes.workspace),
        );
      },
    );
  }

  SyntaxCategory _syntaxCategory(String sourceCategory) {
    if (const {'primitive', 'collection', 'special'}.contains(sourceCategory)) {
      return SyntaxCategory.types;
    }
    if (const {
      'output',
      'iteration',
      'conversion',
      'collections',
      'math',
      'type',
    }.contains(sourceCategory)) {
      return SyntaxCategory.builtins;
    }
    return SyntaxCategory.keywords;
  }
}

class _SyntaxReferenceLoading extends StatelessWidget {
  const _SyntaxReferenceLoading({required this.showBottomNavigation});

  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final skeleton = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SkeletonBlock(width: 320, height: 38),
              const SizedBox(height: 20),
              _SkeletonBlock(height: 54),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: _SkeletonBlock(height: 112),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(flex: 6, child: _SkeletonBlock(height: 420)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: scheme.surfaceContainerHigh,
        highlightColor: scheme.surfaceContainerHighest,
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: skeleton,
      ),
      bottomNavigationBar: showBottomNavigation
          ? const _SyntaxReferenceBottomNavigation()
          : null,
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

class _SyntaxReferenceError extends StatelessWidget {
  const _SyntaxReferenceError({
    required this.error,
    required this.onRetry,
    required this.showBottomNavigation,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(l10n.syntaxExplorerLoadError),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.syntaxExplorerRetry),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showBottomNavigation
          ? const _SyntaxReferenceBottomNavigation()
          : null,
    );
  }
}

class _SyntaxReferenceBottomNavigation extends StatelessWidget {
  const _SyntaxReferenceBottomNavigation();

  @override
  Widget build(BuildContext context) => AppNavigationBar(
    selectedRoute: AppRoutes.syntaxReference,
    onSelected: context.go,
  );
}
