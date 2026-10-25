import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/async_state.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/learning_path_models.dart';
import '../../../data/models/lesson_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/learning_path_provider.dart';
import '../../../logic/services/badge_evaluator.dart';
import '../../../logic/services/gamification_service.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/navigation_bar.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LearningPathProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: _PathColors.background,
      body: Consumer<LearningPathProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          if (state.status == LoadStatus.initial ||
              state.status == LoadStatus.loading) {
            return const _LearningPathLoadingSkeleton();
          }
          if (state.status == LoadStatus.error) {
            return EmptyState(
              icon: Icons.error_outline,
              message: l10n.lessonUnavailable,
              action: FilledButton(
                onPressed: provider.refresh,
                child: Text(l10n.retry),
              ),
            );
          }
          final data = state.value;
          if (data == null || data.curriculum.units.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              message: l10n.learningPathEmpty,
            );
          }
          return _LearningPathContent(data: data);
        },
      ),
      bottomNavigationBar: wide
          ? null
          : AppNavigationBar(
              selectedRoute: AppRoutes.learningPath,
              onSelected: context.go,
            ),
    );
  }
}

class _LearningPathContent extends StatefulWidget {
  const _LearningPathContent({required this.data});

  final LearningPathData data;

  @override
  State<_LearningPathContent> createState() => _LearningPathContentState();
}

class _LearningPathContentState extends State<_LearningPathContent> {
  String? _expandedUnitId;

  @override
  void initState() {
    super.initState();
    _expandedUnitId = widget.data.curriculum.units
        .elementAt(widget.data.activeUnitIndex)
        .id;
  }

  @override
  void didUpdateWidget(covariant _LearningPathContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.data.curriculum.units.any(
      (unit) => unit.id == _expandedUnitId,
    )) {
      _expandedUnitId = widget.data.curriculum.units
          .elementAt(widget.data.activeUnitIndex)
          .id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final units = data.curriculum.units;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1050;
        final horizontalPadding = constraints.maxWidth >= 1200
            ? 36.0
            : constraints.maxWidth >= 700
            ? 24.0
            : 16.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            28,
            horizontalPadding,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageHeader(data: data),
                  const SizedBox(height: 24),
                  _ProgressStrip(data: data),
                  const SizedBox(height: 24),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 8, child: _buildCurriculum(data, units)),
                        const SizedBox(width: 20),
                        Expanded(flex: 4, child: _LearningInsights(data: data)),
                      ],
                    )
                  else ...[
                    _buildCurriculum(data, units),
                    const SizedBox(height: 20),
                    _LearningInsights(data: data),
                  ],
                  if (data.totalLessons > 0 &&
                      data.completedLessons == data.totalLessons) ...[
                    const SizedBox(height: 16),
                    _FinalProjectCard(
                      onOpen: () => context.go(AppRoutes.capstone),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurriculum(LearningPathData data, List<Unit> units) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < units.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ModuleCard(
              data: data,
              unit: units[index],
              index: index,
              isExpanded: _expandedUnitId == units[index].id,
              onToggle: () => setState(
                () => _expandedUnitId = _expandedUnitId == units[index].id
                    ? null
                    : units[index].id,
              ),
            ),
          ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.data});

  final LearningPathData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final completedUnits = data.completedUnits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(l10n.appTitle, style: _PathText.breadcrumb),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              size: 16,
              color: _PathColors.subtle,
            ),
            Text(
              l10n.curriculumVersion(data.curriculum.targetGDScriptVersion),
              style: _PathText.monoMuted,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 16,
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.learningPathHeading,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: MediaQuery.sizeOf(context).width < 700
                          ? 26
                          : 34,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: _PathColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StatusPill(
                        icon: Icons.verified_rounded,
                        label:
                            'GDScript ${data.curriculum.targetGDScriptVersion}',
                        color: _PathColors.green,
                      ),
                      _StatusPill(
                        icon: Icons.check_circle_rounded,
                        label: l10n.completedUnitsSummary(
                          completedUnits,
                          data.curriculum.units.length,
                        ),
                        color: _PathColors.muted,
                      ),
                      _StatusPill(
                        icon: Icons.menu_book_rounded,
                        label: l10n.completedLessonsSummary(
                          data.completedLessons,
                          data.totalLessons,
                        ),
                        color: _PathColors.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderAction(
                  icon: Icons.account_tree_rounded,
                  label: l10n.learningPathTitle,
                  selected: true,
                  onPressed: () => context.go(AppRoutes.learningPath),
                ),
                _HeaderAction(
                  icon: Icons.hub_rounded,
                  label: l10n.conceptMapAction,
                  onPressed: () => context.go(AppRoutes.conceptMap),
                ),
                _HeaderAction(
                  icon: Icons.psychology_alt_rounded,
                  label: l10n.smartReviewAction,
                  accent: _PathColors.orange,
                  onPressed: () => context.go(AppRoutes.review),
                ),
              ],
            ),
          ],
        ),
        if (data.totalLessons == 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.learningPathEmpty,
              style: const TextStyle(color: _PathColors.orange),
            ),
          ),
      ],
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.data});

  final LearningPathData data;

  @override
  Widget build(BuildContext context) {
    final units = data.curriculum.units;
    final activeIndex = data.activeUnitIndex;
    final start = activeIndex.clamp(0, units.length - 1).toInt();
    final firstIndex = start == 0 ? 0 : start - 1;
    final lastIndex = units.length - 1;
    final indices = <int>{firstIndex, start};
    if (start < lastIndex) indices.add(start + 1);
    if (indices.length < 3 && lastIndex != start) indices.add(lastIndex);
    final milestones = indices.toList()..sort();
    final xp = data.progress?.totalXP ?? 0;
    final streak = data.progress?.currentStreak ?? 0;
    final streakLabel = Localizations.localeOf(context).languageCode == 'ar'
        ? '$streak أيام متتالية'
        : '$streak day streak';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _PathColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _PathColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final items = [
                for (final index in milestones)
                  _ProgressMilestone(
                    title: units[index].title.resolve(
                      Localizations.localeOf(context),
                    ),
                    subtitle: index < activeIndex
                        ? context.l10n.milestoneCompleted
                        : index == activeIndex
                        ? context.l10n.milestoneCurrent
                        : context.l10n.milestoneUpcoming,
                    state: data.isUnitCompleted(units[index])
                        ? _MilestoneState.completed
                        : index == activeIndex
                        ? _MilestoneState.active
                        : _MilestoneState.locked,
                  ),
              ];
              if (constraints.maxWidth < 600) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: item,
                      ),
                  ],
                );
              }
              return Row(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) const _MilestoneConnector(),
                    Expanded(child: items[index]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: data.progressRatio,
              minHeight: 8,
              backgroundColor: _PathColors.surfaceHigh,
              valueColor: const AlwaysStoppedAnimation(_PathColors.green),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              Text(context.l10n.totalXp(xp), style: _PathText.monoSubtle),
              Text(
                context.l10n.completedLessonsSummary(
                  data.completedLessons,
                  data.totalLessons,
                ),
                style: _PathText.monoMuted,
              ),
              Text(streakLabel, style: _PathText.monoSubtle),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: data.progress?.levelProgressRatio ?? 0,
              minHeight: 3,
              backgroundColor: _PathColors.surfaceHigh,
              valueColor: const AlwaysStoppedAnimation(_PathColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MilestoneState { completed, active, locked }

class _ProgressMilestone extends StatelessWidget {
  const _ProgressMilestone({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final _MilestoneState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _MilestoneState.completed => _PathColors.green,
      _MilestoneState.active => _PathColors.primary,
      _MilestoneState.locked => _PathColors.subtle,
    };
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            state == _MilestoneState.completed
                ? Icons.check_circle_rounded
                : state == _MilestoneState.active
                ? Icons.bolt_rounded
                : Icons.lock_rounded,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _PathText.monoSubtle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneConnector extends StatelessWidget {
  const _MilestoneConnector();

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: _PathColors.border,
  );
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.data,
    required this.unit,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  final LearningPathData data;
  final Unit unit;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final locked = data.isUnitLocked(index);
    final completed = data.isUnitCompleted(unit);
    final active = index == data.activeUnitIndex && !completed;
    final accent = completed
        ? _PathColors.green
        : active
        ? _PathColors.primary
        : _PathColors.subtle;
    final lessonCount = unit.lessonIds.length;
    final completedCount = data.completedLessonsIn(unit);
    final minutes = unit.lessonIds.fold<int>(
      0,
      (sum, id) => sum + (data.lessons[id]?.estimatedMinutes ?? 0),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: active
            ? _PathColors.surfaceRaised
            : locked
            ? const Color(0xFF11161D)
            : _PathColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.75)
              : _PathColors.border.withValues(alpha: 0.4),
          width: active ? 1.3 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.06),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: completed
                        ? Icon(Icons.check_rounded, color: accent, size: 25)
                        : locked
                        ? Icon(Icons.lock_outline_rounded, color: accent)
                        : Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: locked ? null : onToggle,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                l10n.moduleNumber(unit.order + 1),
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              _ModuleStatusLabel(
                                label: locked
                                    ? l10n.lessonStatusLocked
                                    : completed
                                    ? l10n.unitCompleted
                                    : active
                                    ? l10n.unitInProgress
                                    : l10n.lessonStatusAvailable,
                                color: accent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            unit.title.resolve(locale),
                            key: ValueKey(
                              'learning_path_module_title_${unit.id}',
                            ),
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 17,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                              color: locked
                                  ? _PathColors.muted
                                  : _PathColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unit.description.resolve(locale),
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              height: 1.6,
                              color: _PathColors.subtle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${lessonCount == 0 ? 0 : (completedCount * 100 / lessonCount).round()}%',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 72,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: lessonCount == 0
                              ? 0
                              : completedCount / lessonCount,
                          minHeight: 5,
                          backgroundColor: _PathColors.surfaceHigh,
                          valueColor: AlwaysStoppedAnimation(accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.moduleLessonCount(lessonCount),
                      style: _PathText.monoSubtle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetadataChip(
                          icon: Icons.schedule_rounded,
                          label: l10n.moduleDurationHours(minutes),
                        ),
                        _MetadataChip(
                          icon: Icons.bolt_rounded,
                          label:
                              '${lessonCount * GamificationService.lessonCompletionXp} XP',
                        ),
                        if (locked)
                          _MetadataChip(
                            icon: Icons.lock_outline_rounded,
                            label: l10n.lessonStatusLocked,
                          ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: locked ? null : onToggle,
                      icon: Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isExpanded ? l10n.hideLessons : l10n.showLessons,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _PathColors.primary,
                        textStyle: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded && !locked) ...[
            Divider(
              height: 1,
              color: _PathColors.border.withValues(alpha: 0.45),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 650
                      ? 3
                      : constraints.maxWidth >= 400
                      ? 2
                      : 1;
                  final tileWidth =
                      (constraints.maxWidth - (columns - 1) * 10) / columns;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final id in unit.lessonIds)
                        SizedBox(
                          width: tileWidth,
                          child: _LessonCard(
                            lesson: data.lessons[id],
                            lessonId: id,
                            status: data.progress?.lessonsProgress[id]?.status,
                            isActive: data.activeLessonId == id,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.lessonId,
    required this.status,
    required this.isActive,
  });

  final Lesson? lesson;
  final String lessonId;
  final LessonStatus? status;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final completed = status == LessonStatus.completed;
    final accent = completed
        ? _PathColors.green
        : isActive
        ? _PathColors.primary
        : _PathColors.subtle;
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;
    return Material(
      color: isActive ? _PathColors.surfaceHigh : _PathColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('learning_path_lesson_$lessonId'),
        onTap: () => context.push(AppRoutes.lessonPath(lessonId)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? accent.withValues(alpha: 0.6)
                  : _PathColors.border.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (isActive)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.55),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    )
                  else
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.play_circle_outline_rounded,
                      size: 16,
                      color: accent,
                    ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      completed
                          ? l10n.lessonStatusCompleted
                          : isActive
                          ? l10n.lessonStatusCurrent
                          : l10n.lessonStatusAvailable,
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '#${(lesson?.order ?? 0) + 1}',
                    style: _PathText.monoSubtle,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lesson?.title.resolve(locale) ?? _readableLessonId(lessonId),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w700,
                  color: _PathColors.text,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                lesson?.objective.resolve(locale) ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  height: 1.65,
                  color: _PathColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 6,
                runSpacing: 5,
                children: [
                  _MetadataChip(
                    icon: Icons.schedule_rounded,
                    label: locale.languageCode == 'ar'
                        ? '${lesson?.estimatedMinutes ?? 0} د'
                        : '${lesson?.estimatedMinutes ?? 0} min',
                  ),
                  _MetadataChip(
                    icon: Icons.bolt_rounded,
                    label: '+${GamificationService.lessonCompletionXp} XP',
                    color: _PathColors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _readableLessonId(String id) =>
      id.replaceFirst(RegExp(r'^lesson_[0-9]+_'), '').replaceAll('_', ' ');
}

class _LearningInsights extends StatelessWidget {
  const _LearningInsights({required this.data});

  final LearningPathData data;

  @override
  Widget build(BuildContext context) {
    final progress = data.progress;
    final earnedBadges = BadgeEvaluator.catalog
        .where((badge) => progress?.earnedBadges.contains(badge.id) ?? false)
        .take(4)
        .toList();
    final activeLessonId = data.activeLessonId;
    final activeLesson = activeLessonId == null
        ? null
        : data.lessons[activeLessonId];
    final completedUnits = data.completedUnits;
    final totalUnits = data.curriculum.units.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InsightPanel(
          title: context.l10n.masteryStatistics,
          icon: Icons.insights_rounded,
          trailing: _StatusPill(
            icon: Icons.circle,
            label: context.l10n.completedLessonsSummary(
              data.completedLessons,
              data.totalLessons,
            ),
            color: _PathColors.green,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      value: '${progress?.totalXP ?? 0}',
                      label: context.l10n.xpTotalLabel,
                      icon: Icons.diamond_rounded,
                      color: _PathColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      value: '${progress?.currentStreak ?? 0}',
                      label: context.l10n.streakLabel,
                      icon: Icons.local_fire_department_rounded,
                      color: _PathColors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      value: '$completedUnits/$totalUnits',
                      label: context.l10n.completedModulesCount(completedUnits),
                      icon: Icons.check_circle_rounded,
                      color: _PathColors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _UnitProgressPanel(data: data),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InsightPanel(
          title: context.l10n.smartReviewAction,
          icon: Icons.psychology_alt_rounded,
          trailing: _ModuleStatusLabel(
            label: context.l10n.reviewTitle,
            color: _PathColors.orange,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _PathColors.background.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.reviewNextStep,
                      style: _PathText.monoSubtle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeLesson?.title.resolve(
                            Localizations.localeOf(context),
                          ) ??
                          context.l10n.learningPathEmpty,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: _PathColors.text,
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.review),
                icon: const Icon(Icons.quiz_rounded, size: 18),
                iconAlignment: .end,
                label: Text(context.l10n.openReview),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDB7619),
                  foregroundColor: const Color(0xFF301400),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InsightPanel(
          title: context.l10n.achievementsTitle,
          icon: Icons.workspace_premium_rounded,
          trailing: Text(
            context.l10n.earnedBadgesSummary(
              progress?.earnedBadges.length ?? 0,
            ),
            style: _PathText.monoSubtle,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (earnedBadges.isEmpty)
                _AchievementTile(
                  icon: Icons.emoji_events_rounded,
                  title: context.l10n.badgesTitle,
                  subtitle: context.l10n.badgeLocked,
                  color: _PathColors.subtle,
                  unlocked: false,
                )
              else
                for (final badge in earnedBadges)
                  _AchievementTile(
                    icon: _badgeIcon(badge.iconName),
                    title: badge.title.resolve(Localizations.localeOf(context)),
                    subtitle: context.l10n.badgeUnlocked,
                    color: _PathColors.green,
                    unlocked: true,
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InsightPanel(
          title: context.l10n.workspaceStatus,
          icon: Icons.code_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: _PathColors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.workspaceReady,
                      style: const TextStyle(
                        color: _PathColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'GDScript ${data.curriculum.targetGDScriptVersion}',
                    style: _PathText.monoMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.workspace),
                icon: const Icon(Icons.terminal_rounded, size: 17),
                label: Text(context.l10n.openWorkspace),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _PathColors.text,
                  side: BorderSide(
                    color: _PathColors.border.withValues(alpha: 0.7),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static IconData _badgeIcon(String name) => switch (name) {
    'eco' => Icons.eco_rounded,
    'star' => Icons.star_rounded,
    'inventory_2' => Icons.inventory_2_rounded,
    'alt_route' => Icons.alt_route_rounded,
    'loop' => Icons.loop_rounded,
    'extension' => Icons.extension_rounded,
    'bolt' => Icons.bolt_rounded,
    'local_fire_department' => Icons.local_fire_department_rounded,
    'search' => Icons.search_rounded,
    'school' => Icons.school_rounded,
    _ => Icons.emoji_events_rounded,
  };
}

class _UnitProgressPanel extends StatelessWidget {
  const _UnitProgressPanel({required this.data});

  final LearningPathData data;

  @override
  Widget build(BuildContext context) {
    final units = data.curriculum.units;
    final values = [
      for (final unit in units)
        unit.lessonIds.isEmpty
            ? 0.0
            : data.completedLessonsIn(unit) / unit.lessonIds.length,
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _PathColors.background.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _PathColors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.progressByUnit, style: _PathText.monoSubtle),
          const SizedBox(height: 8),
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(painter: _MasteryRadarPainter(values)),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < units.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      units[index].title.resolve(
                        Localizations.localeOf(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _PathText.monoSubtle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: values[index],
                        minHeight: 5,
                        backgroundColor: _PathColors.surfaceHigh,
                        valueColor: AlwaysStoppedAnimation(
                          values[index] >= 1
                              ? _PathColors.green
                              : _PathColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(values[index] * 100).round()}%',
                    style: _PathText.monoSubtle,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: data.progressRatio,
                    minHeight: 7,
                    backgroundColor: _PathColors.surfaceHigh,
                    valueColor: const AlwaysStoppedAnimation(
                      _PathColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(data.progressRatio * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: _PathColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            context.l10n.completedLessonsSummary(
              data.completedLessons,
              data.totalLessons,
            ),
            style: _PathText.monoSubtle,
          ),
        ],
      ),
    );
  }
}

class _MasteryRadarPainter extends CustomPainter {
  const _MasteryRadarPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.37;
    final count = values.length.clamp(3, 8).toInt();
    final gridPaint = Paint()
      ..color = _PathColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final scale in [0.35, 0.65, 1.0]) {
      canvas.drawPath(_polygon(center, radius * scale, count), gridPaint);
    }
    for (var index = 0; index < count; index++) {
      final point = _point(center, radius, index, count);
      canvas.drawLine(center, point, gridPaint);
    }
    final path = Path();
    for (var index = 0; index < count; index++) {
      final value = index < values.length
          ? values[index].clamp(0.08, 1.0)
          : 0.08;
      final point = _point(center, radius * value, index, count);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = _PathColors.primary.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _PathColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Path _polygon(Offset center, double radius, int count) {
    final path = Path();
    for (var index = 0; index < count; index++) {
      final point = _point(center, radius, index, count);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Offset _point(Offset center, double radius, int index, int count) {
    final angle = -math.pi / 2 + 2 * math.pi * index / count;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  @override
  bool shouldRepaint(covariant _MasteryRadarPainter oldDelegate) =>
      !listEquals(values, oldDelegate.values);
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _PathColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _PathColors.border.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: _PathColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: _PathColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 92),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
    decoration: BoxDecoration(
      color: _PathColors.surfaceRaised,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 9,
            color: _PathColors.muted,
          ),
        ),
      ],
    ),
  );
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: MediaQuery.sizeOf(context).width < 700 ? 160 : 142,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _PathColors.surfaceRaised,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _PathColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 9,
                    color: unlocked ? color : _PathColors.subtle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FinalProjectCard extends StatelessWidget {
  const _FinalProjectCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF252A32), Color(0xFF1B2027), Color(0xFF252A32)],
        begin: AlignmentGeometry.centerStart,
        end: AlignmentGeometry.centerEnd,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _PathColors.border.withValues(alpha: 0.55)),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 14,
      spacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 490),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _PathColors.orange.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: _PathColors.orange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.capstoneTitle,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: _PathColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.capstoneDescription,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: _PathColors.text,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.rocket_launch_rounded, size: 17),
          iconAlignment: .end,
          label: Text(context.l10n.startLearning),
          style: FilledButton.styleFrom(
            backgroundColor: _PathColors.primary,
            foregroundColor: const Color(0xFF003350),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ],
    ),
  );
}

class _ModuleStatusLabel extends StatelessWidget {
  const _ModuleStatusLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? _PathColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: _PathColors.surfaceHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _PathColors.primary : accent ?? _PathColors.muted;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: selected
            ? _PathColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        side: BorderSide(
          color: selected
              ? color.withValues(alpha: 0.4)
              : _PathColors.border.withValues(alpha: 0.65),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        textStyle: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LearningPathLoadingSkeleton extends StatelessWidget {
  const _LearningPathLoadingSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: _PathColors.surface,
    highlightColor: _PathColors.surfaceHigh,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 700 ? 16.0 : 28.0;
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SkeletonBlock(width: 220, height: 14),
                    const SizedBox(height: 18),
                    const _SkeletonBlock(width: 500, height: 36),
                    const SizedBox(height: 12),
                    const _SkeletonBlock(width: 380, height: 24),
                    const SizedBox(height: 24),
                    Container(
                      height: 134,
                      decoration: BoxDecoration(
                        color: _PathColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 1050) {
                          return const Column(
                            children: [
                              _SkeletonModuleCard(),
                              SizedBox(height: 16),
                              _SkeletonModuleCard(),
                              SizedBox(height: 20),
                              _SkeletonInsightCard(),
                            ],
                          );
                        }
                        return const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Column(
                                children: [
                                  _SkeletonModuleCard(),
                                  SizedBox(height: 16),
                                  _SkeletonModuleCard(),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(flex: 4, child: _SkeletonInsightCard()),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _SkeletonModuleCard extends StatelessWidget {
  const _SkeletonModuleCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 228,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _PathColors.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _SkeletonBlock(width: 48, height: 48),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: 100, height: 12),
                  SizedBox(height: 10),
                  _SkeletonBlock(width: 210, height: 16),
                ],
              ),
            ),
            _SkeletonBlock(width: 72, height: 30),
          ],
        ),
        SizedBox(height: 22),
        _SkeletonBlock(width: double.infinity, height: 11),
        SizedBox(height: 12),
        Row(
          children: [
            _SkeletonBlock(width: 90, height: 28),
            SizedBox(width: 8),
            _SkeletonBlock(width: 78, height: 28),
          ],
        ),
        Spacer(),
        _SkeletonBlock(width: double.infinity, height: 1),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _SkeletonBlock(width: double.infinity, height: 48)),
            SizedBox(width: 10),
            Expanded(child: _SkeletonBlock(width: double.infinity, height: 48)),
          ],
        ),
      ],
    ),
  );
}

class _SkeletonInsightCard extends StatelessWidget {
  const _SkeletonInsightCard();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 330,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _PathColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SkeletonBlock(width: 170, height: 16),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SkeletonBlock(width: double.infinity, height: 90),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _SkeletonBlock(width: double.infinity, height: 90),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _SkeletonBlock(width: double.infinity, height: 90),
                ),
              ],
            ),
            SizedBox(height: 18),
            Expanded(
              child: _SkeletonBlock(width: double.infinity, height: 120),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        height: 170,
        decoration: BoxDecoration(
          color: _PathColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ],
  );
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: _PathColors.surfaceHigh,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

class _PathColors {
  static const background = Color(0xFF0F141B);
  static const surface = Color(0xFF171C23);
  static const surfaceRaised = Color(0xFF1B2027);
  static const surfaceHigh = Color(0xFF252A32);
  static const border = Color(0xFF40484F);
  static const text = Color(0xFFDEE2EC);
  static const muted = Color(0xFFC0C7D0);
  static const subtle = Color(0xFF8A919A);
  static const primary = Color(0xFF91CDFF);
  static const green = Color(0xFF4AE183);
  static const orange = Color(0xFFFFB783);
  static const purple = Color(0xFFCAA7FF);
}

class _PathText {
  static const breadcrumb = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 11,
    color: _PathColors.subtle,
  );
  static const monoMuted = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 10,
    color: _PathColors.muted,
  );
  static const monoSubtle = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 9,
    color: _PathColors.subtle,
  );
}
