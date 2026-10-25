import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/async_state.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/gamification_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../../logic/services/badge_evaluator.dart';
import '../../../logic/services/badge_progress_calculator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/gamification/badge_card.dart';

enum BadgeFilterCategory { all, unlocked, inProgress, locked }

class DesktopBadgesShowcaseScreen extends StatefulWidget {
  const DesktopBadgesShowcaseScreen({super.key});

  @override
  State<DesktopBadgesShowcaseScreen> createState() =>
      _DesktopBadgesShowcaseScreenState();
}

class _DesktopBadgesShowcaseScreenState
    extends State<DesktopBadgesShowcaseScreen> {
  BadgeFilterCategory _currentFilter = BadgeFilterCategory.all;
  String? _selectedBadgeId = BadgeEvaluator.catalog.isEmpty
      ? null
      : BadgeEvaluator.catalog.first.id;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadInitialData());
    });
  }

  Future<void> _loadInitialData() async {
    final progressProvider = context.read<ProgressProvider>();
    final curriculumProvider = context.read<CurriculumProvider>();
    final loads = <Future<void>>[];

    if (progressProvider.state.status == LoadStatus.initial) {
      loads.add(progressProvider.load(AppConstants.visitorId));
    }
    if (curriculumProvider.state.status == LoadStatus.initial) {
      loads.add(curriculumProvider.load());
    }
    await _waitForLoads(loads);
  }

  Future<void> _reloadData() async {
    final loads = <Future<void>>[
      context.read<ProgressProvider>().load(AppConstants.visitorId),
      context.read<CurriculumProvider>().load(),
    ];
    await _waitForLoads(loads);
  }

  Future<void> _waitForLoads(List<Future<void>> loads) async {
    if (loads.isEmpty) return;
    try {
      await Future.wait(loads);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.badgesLoadError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.badgesTitle)),
      body: Consumer2<ProgressProvider, CurriculumProvider>(
        builder: (context, progressProvider, curriculumProvider, _) {
          final progressState = progressProvider.state;
          final curriculumState = curriculumProvider.state;

          if (progressState.status == LoadStatus.error ||
              curriculumState.status == LoadStatus.error) {
            return EmptyState(
              icon: Icons.error_outline,
              message: l10n.badgesLoadError,
              action: FilledButton(
                onPressed: _reloadData,
                child: Text(l10n.retry),
              ),
            );
          }

          if (progressState.status == LoadStatus.initial ||
              progressState.status == LoadStatus.loading ||
              curriculumState.status == LoadStatus.initial ||
              curriculumState.status == LoadStatus.loading) {
            return const _BadgesLoadingSkeleton();
          }

          final progress = progressProvider.progress;
          final curriculum = curriculumState.value;
          if (curriculum == null) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              message: l10n.badgesLoadError,
              action: FilledButton(
                onPressed: _reloadData,
                child: Text(l10n.retry),
              ),
            );
          }

          final badges = BadgeEvaluator.catalog;
          if (badges.isEmpty) {
            return EmptyState(
              icon: Icons.emoji_events_outlined,
              message: l10n.badgeCatalogEmpty,
            );
          }

          final earnedIds = progress?.earnedBadges.toSet() ?? const <String>{};
          final unlockedCount = badges
              .where((badge) => earnedIds.contains(badge.id))
              .length;
          final filteredBadges = _filterBadges(
            badges,
            earnedIds,
            progress,
            curriculum,
          );
          final selectedBadge = _selectedBadge(badges);
          final wide = MediaQuery.sizeOf(context).width >= 1000;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: _BadgesHeaderBanner(
                  unlocked: unlockedCount,
                  total: badges.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _BadgesFilterChipsBar(
                  activeFilter: _currentFilter,
                  counts: _filterCounts(
                    badges,
                    earnedIds,
                    progress,
                    curriculum,
                  ),
                  onSelectFilter: (filter) {
                    setState(() {
                      _currentFilter = filter;
                      final selected = _selectedBadge(badges);
                      if (selected != null &&
                          !_matchesFilter(
                            selected,
                            filter,
                            earnedIds,
                            progress,
                            curriculum,
                          )) {
                        _selectedBadgeId = null;
                      }
                    });
                  },
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: wide
                    ? Row(
                        children: [
                          Expanded(
                            child: _BadgesGrid(
                              badges: filteredBadges,
                              earnedIds: earnedIds,
                              progress: progress,
                              curriculum: curriculum,
                              selectedBadgeId: _selectedBadgeId,
                              onSelectBadge: (badge) {
                                setState(() => _selectedBadgeId = badge.id);
                              },
                            ),
                          ),
                          if (selectedBadge != null) ...[
                            const VerticalDivider(width: 1),
                            SizedBox(
                              width: 340,
                              child: _BadgeDetailInspector(
                                badge: selectedBadge,
                                isUnlocked: earnedIds.contains(
                                  selectedBadge.id,
                                ),
                                progress: BadgeProgressCalculator.calculate(
                                  badge: selectedBadge,
                                  progress: progress,
                                  curriculum: curriculum,
                                ),
                                earnedAt: progress
                                    ?.earnedBadgeDates[selectedBadge.id],
                              ),
                            ),
                          ],
                        ],
                      )
                    : _BadgesGrid(
                        badges: filteredBadges,
                        earnedIds: earnedIds,
                        progress: progress,
                        curriculum: curriculum,
                        selectedBadgeId: _selectedBadgeId,
                        onSelectBadge: _showBadgeDetails,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  BadgeDefinition? _selectedBadge(List<BadgeDefinition> badges) {
    for (final badge in badges) {
      if (badge.id == _selectedBadgeId) return badge;
    }
    return null;
  }

  List<BadgeDefinition> _filterBadges(
    List<BadgeDefinition> badges,
    Set<String> earnedIds,
    UserProgress? progress,
    Curriculum curriculum,
  ) {
    return badges
        .where((badge) {
          return _matchesFilter(
            badge,
            _currentFilter,
            earnedIds,
            progress,
            curriculum,
          );
        })
        .toList(growable: false);
  }

  Map<BadgeFilterCategory, int> _filterCounts(
    List<BadgeDefinition> badges,
    Set<String> earnedIds,
    UserProgress? progress,
    Curriculum curriculum,
  ) {
    return {
      for (final filter in BadgeFilterCategory.values)
        filter: badges
            .where(
              (badge) => _matchesFilter(
                badge,
                filter,
                earnedIds,
                progress,
                curriculum,
              ),
            )
            .length,
    };
  }

  bool _matchesFilter(
    BadgeDefinition badge,
    BadgeFilterCategory filter,
    Set<String> earnedIds,
    UserProgress? progress,
    Curriculum curriculum,
  ) {
    final earned = earnedIds.contains(badge.id);
    final badgeProgress = BadgeProgressCalculator.calculate(
      badge: badge,
      progress: progress,
      curriculum: curriculum,
    );
    return switch (filter) {
      BadgeFilterCategory.all => true,
      BadgeFilterCategory.unlocked => earned,
      BadgeFilterCategory.inProgress => !earned && badgeProgress.current > 0,
      BadgeFilterCategory.locked => !earned && badgeProgress.current == 0,
    };
  }

  void _showBadgeDetails(BadgeDefinition badge) {
    setState(() => _selectedBadgeId = badge.id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final progress = context.read<ProgressProvider>().progress;
        final curriculum = context.read<CurriculumProvider>().state.value;
        final earned = progress?.earnedBadges.contains(badge.id) ?? false;
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: _BadgeDetailInspector(
              badge: badge,
              isUnlocked: earned,
              progress: BadgeProgressCalculator.calculate(
                badge: badge,
                progress: progress,
                curriculum: curriculum,
              ),
              earnedAt: progress?.earnedBadgeDates[badge.id],
            ),
          ),
        );
      },
    );
  }
}

class _BadgesHeaderBanner extends StatelessWidget {
  const _BadgesHeaderBanner({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = total == 0 ? 0.0 : unlocked / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 520;
            final summary = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.badgesCompletionSummary(unlocked, total),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: colors.surfaceContainerHighest,
                    color: colors.primary,
                  ),
                ),
              ],
            );
            final emblem = Icon(
              Icons.workspace_premium_rounded,
              size: 38,
              color: colors.primary,
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      emblem,
                      const SizedBox(width: 12),
                      Expanded(child: summary),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                emblem,
                const SizedBox(width: 16),
                Expanded(child: summary),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BadgesFilterChipsBar extends StatelessWidget {
  const _BadgesFilterChipsBar({
    required this.activeFilter,
    required this.counts,
    required this.onSelectFilter,
  });

  final BadgeFilterCategory activeFilter;
  final Map<BadgeFilterCategory, int> counts;
  final ValueChanged<BadgeFilterCategory> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      BadgeFilterCategory.all: l10n.badgeFilterAll(
        counts[BadgeFilterCategory.all]!,
      ),
      BadgeFilterCategory.unlocked: l10n.badgeFilterEarned(
        counts[BadgeFilterCategory.unlocked]!,
      ),
      BadgeFilterCategory.inProgress: l10n.badgeFilterInProgress(
        counts[BadgeFilterCategory.inProgress]!,
      ),
      BadgeFilterCategory.locked: l10n.badgeFilterLocked(
        counts[BadgeFilterCategory.locked]!,
      ),
    };

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final filter in BadgeFilterCategory.values)
            FilterChip(
              label: Text(labels[filter]!),
              selected: activeFilter == filter,
              onSelected: (_) => onSelectFilter(filter),
            ),
        ],
      ),
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({
    required this.badges,
    required this.earnedIds,
    required this.progress,
    required this.curriculum,
    required this.selectedBadgeId,
    required this.onSelectBadge,
  });

  final List<BadgeDefinition> badges;
  final Set<String> earnedIds;
  final UserProgress? progress;
  final Curriculum curriculum;
  final String? selectedBadgeId;
  final ValueChanged<BadgeDefinition> onSelectBadge;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return EmptyState(
        icon: Icons.filter_list_off,
        message: context.l10n.badgeFilterEmpty,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 170).floor().clamp(1, 3);
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final badgeProgress = BadgeProgressCalculator.calculate(
              badge: badge,
              progress: progress,
              curriculum: curriculum,
            );
            final earned = earnedIds.contains(badge.id);
            return BadgeCard(
              badge: badge,
              isUnlocked: earned,
              isSelected: badge.id == selectedBadgeId,
              earnedAt: progress?.earnedBadgeDates[badge.id],
              progress: badgeProgress.current,
              progressTarget: badgeProgress.target,
              showProgressWhenUnlocked: true,
              onTap: () => onSelectBadge(badge),
            );
          },
        );
      },
    );
  }
}

class _BadgeDetailInspector extends StatelessWidget {
  const _BadgeDetailInspector({
    required this.badge,
    required this.isUnlocked,
    required this.progress,
    required this.earnedAt,
  });

  final BadgeDefinition badge;
  final bool isUnlocked;
  final BadgeProgress progress;
  final DateTime? earnedAt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final fraction = progress.target <= 0
        ? 0.0
        : (progress.current / progress.target).clamp(0.0, 1.0);
    final status = isUnlocked
        ? earnedAt == null
              ? context.l10n.badgeEarnedStatus
              : context.l10n.earnedOn(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(earnedAt!.toLocal()),
                )
        : progress.current > 0
        ? context.l10n.badgeInProgressStatus
        : context.l10n.badgeLocked;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              context.l10n.badgeDetailsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                badgeIconForName(badge.iconName),
                size: 42,
                color: isUnlocked ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            badge.title.resolve(locale),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            badge.description.resolve(locale),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(status, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            context.l10n.badgeProgress(
              progress.current.clamp(0, progress.target),
              progress.target,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: isUnlocked ? 1 : fraction,
            backgroundColor: colors.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}

class _BadgesLoadingSkeleton extends StatelessWidget {
  const _BadgesLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = colors.surfaceContainerHighest;
    final highlight = colors.surface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              children: [
                for (var index = 0; index < 4; index++)
                  Container(
                    width: 108,
                    height: 34,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 230,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: 8,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
