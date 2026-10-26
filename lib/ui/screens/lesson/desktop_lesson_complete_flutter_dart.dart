import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/color_schemes.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/context_extensions.dart';

@immutable
class LessonCompleteBadgeModel {
  const LessonCompleteBadgeModel({required this.title});

  final String title;
}

@immutable
class LessonCompleteRewardModel {
  LessonCompleteRewardModel({
    required this.lessonTitle,
    required this.earnedXp,
    required this.exercisesCompleted,
    required this.hintsUsedCount,
    required this.timeSpentMinutes,
    required List<LessonCompleteBadgeModel> badges,
    this.leveledUp = false,
    this.currentStreak,
    this.currentLevel,
    this.levelProgress,
  }) : badges = List.unmodifiable(badges);

  final String lessonTitle;
  final int earnedXp;
  final int exercisesCompleted;
  final int hintsUsedCount;
  final int timeSpentMinutes;
  final bool leveledUp;
  final int? currentStreak;
  final int? currentLevel;
  final double? levelProgress;
  final List<LessonCompleteBadgeModel> badges;
}

class DesktopLessonCompleteScreen extends StatefulWidget {
  const DesktopLessonCompleteScreen({
    super.key,
    required this.data,
    required this.onBackToCurriculum,
    this.onContinueNextLesson,
    this.detailsError,
  });

  final LessonCompleteRewardModel data;
  final VoidCallback onBackToCurriculum;
  final VoidCallback? onContinueNextLesson;
  final String? detailsError;

  @override
  State<DesktopLessonCompleteScreen> createState() =>
      _DesktopLessonCompleteScreenState();
}

class _DesktopLessonCompleteScreenState
    extends State<DesktopLessonCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  bool? _animationsDisabled;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled == disabled) return;
    _animationsDisabled = disabled;
    if (disabled) {
      _entryController
        ..stop()
        ..value = 1;
      _pulseController
        ..stop()
        ..value = 1;
    } else {
      _entryController.forward(from: 0);
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.35),
                  radius: 1.15,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.12),
                    theme.colorScheme.surface,
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 600;
                return SingleChildScrollView(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    compact ? 16 : 32,
                    compact ? 20 : 28,
                    compact ? 16 : 32,
                    compact ? 24 : 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 880),
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: IconButton(
                              onPressed: widget.onBackToCurriculum,
                              tooltip: l10n.backToPath,
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _CelebrationBadge(
                            scaleAnimation: _scaleAnimation,
                            glowAnimation: _glowAnimation,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.lessonComplete,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.completedLesson(widget.data.lessonTitle),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _MetricsGrid(data: widget.data),
                          if (widget.data.leveledUp) ...[
                            const SizedBox(height: 20),
                            _LevelUpCard(data: widget.data),
                          ],
                          if (widget.data.badges.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            for (final badge in widget.data.badges) ...[
                              _UnlockedBadgeBanner(title: badge.title),
                              if (badge != widget.data.badges.last)
                                const SizedBox(height: 12),
                            ],
                          ],
                          if (widget.detailsError != null) ...[
                            const SizedBox(height: 16),
                            _DetailsError(message: widget.detailsError!),
                          ],
                          const SizedBox(height: 28),
                          _ActionButtonsBar(
                            onContinue: widget.onContinueNextLesson,
                            onCurriculum: widget.onBackToCurriculum,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LessonCompleteLoadingSkeleton extends StatelessWidget {
  const LessonCompleteLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final blocks = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: _SkeletonBlock(width: 104, height: 104, radius: 52),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) => _SkeletonBlock(
            width: constraints.maxWidth * 0.6,
            height: 28,
            radius: 8,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) => _SkeletonBlock(
            width: constraints.maxWidth * 0.8,
            height: 18,
            radius: 8,
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 4 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var index = 0; index < 4; index++)
                  _SkeletonBlock(width: width, height: 112, radius: 12),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        const _SkeletonBlock(height: 52, radius: 10),
      ],
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Shimmer.fromColors(
              baseColor: scheme.surfaceContainerHigh,
              highlightColor: scheme.surfaceContainerHighest,
              enabled: !MediaQuery.disableAnimationsOf(context),
              child: blocks,
            ),
          ),
        ),
      ),
    );
  }
}

class _CelebrationBadge extends StatelessWidget {
  const _CelebrationBadge({
    required this.scaleAnimation,
    required this.glowAnimation,
  });

  final Animation<double> scaleAnimation;
  final Animation<double> glowAnimation;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: AnimatedBuilder(
        animation: glowAnimation,
        builder: (context, _) => Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context).colorScheme.onSecondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withValues(
                  alpha: 0.4 * glowAnimation.value,
                ),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
            border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 3),
          ),
          child: Icon(
            Icons.military_tech_rounded,
            size: 54,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.data});

  final LessonCompleteRewardModel data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metrics = <_RewardMetric>[
      _RewardMetric(
        icon: Icons.diamond_rounded,
        color: Theme.of(context).colorScheme.achievement,
        label: l10n.xpAwarded(data.earnedXp),
      ),
      _RewardMetric(
        icon: Icons.check_circle_rounded,
        color: Theme.of(context).colorScheme.tertiary,
        label: l10n.exercisesSolved(data.exercisesCompleted),
      ),
      _RewardMetric(
        icon: Icons.lightbulb_outline_rounded,
        color: Theme.of(context).colorScheme.secondary,
        label: l10n.hintsUsed(data.hintsUsedCount),
      ),
      _RewardMetric(
        icon: Icons.timer_outlined,
        color: Theme.of(context).colorScheme.primary,
        label: l10n.timeSpent(data.timeSpentMinutes),
      ),
      if (data.currentStreak != null)
        _RewardMetric(
          icon: Icons.local_fire_department_rounded,
          color: Theme.of(context).colorScheme.secondary,
          label: l10n.currentStreakDays(data.currentStreak!),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700
            ? 4
            : constraints.maxWidth >= 420
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: _RewardMetricCard(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _RewardMetric {
  const _RewardMetric({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;
}

class _RewardMetricCard extends StatelessWidget {
  const _RewardMetricCard({required this.metric});

  final _RewardMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(metric.icon, color: metric.color, size: 28),
          const SizedBox(height: 10),
          Text(
            metric.label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelUpCard extends StatelessWidget {
  const _LevelUpCard({required this.data});

  final LessonCompleteRewardModel data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final level = data.currentLevel!;
    final progress = data.levelProgress!.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 500;
          final levelProgress = Column(
            crossAxisAlignment: narrow
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.end,
            children: [
              Text(l10n.levelProgress((progress * 100).round())),
              const SizedBox(height: 8),
              SizedBox(
                width: narrow ? null : 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: theme.colorScheme.surface,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          );
          return Flex(
            direction: narrow ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: narrow
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 14, height: 12),
              if (narrow)
                Text(
                  l10n.levelUpTo(level),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Expanded(
                  child: Text(
                    l10n.levelUpTo(level),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (!narrow) const SizedBox(width: 20),
              if (narrow) const SizedBox(height: 16),
              SizedBox(
                width: narrow ? double.infinity : null,
                child: levelProgress,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UnlockedBadgeBanner extends StatelessWidget {
  const _UnlockedBadgeBanner({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
           Icon(
            Icons.workspace_premium_rounded,
            color: Theme.of(context).colorScheme.secondary,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.badgeUnlocked,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
    );
  }
}

class _ActionButtonsBar extends StatelessWidget {
  const _ActionButtonsBar({
    required this.onContinue,
    required this.onCurriculum,
  });

  final VoidCallback? onContinue;
  final VoidCallback onCurriculum;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        final continueButton = FilledButton.icon(
          onPressed: onContinue,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(l10n.nextLesson),
        );
        final pathButton = OutlinedButton(
          onPressed: onCurriculum,
          child: Text(l10n.backToPath),
        );
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onContinue != null) continueButton,
              if (onContinue != null) const SizedBox(height: 12),
              pathButton,
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onContinue != null) ...[
              continueButton,
              const SizedBox(width: 12),
            ],
            pathButton,
          ],
        );
      },
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    this.width,
    required this.height,
    required this.radius,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
