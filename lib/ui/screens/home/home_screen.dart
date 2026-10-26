import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/async_state.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/home_dashboard_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/providers/home_dashboard_provider.dart';
import '../../../logic/services/badge_evaluator.dart';
import '../../../logic/services/gamification_service.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/navigation_bar.dart';
import 'desktop_home_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<HomeDashboardProvider>(
        builder: (context, dashboardProvider, _) {
          final state = dashboardProvider.state;
          if (state.status == LoadStatus.initial ||
              state.status == LoadStatus.loading) {
            return const _HomeDashboardLoadingSkeleton();
          }
          if (state.status == LoadStatus.error) {
            return EmptyState(
              icon: Icons.error_outline,
              message: "${l10n.lessonUnavailable} ${state.error}",
              action: FilledButton(
                onPressed: dashboardProvider.refresh,
                child: SelectableText(l10n.retry),
              ),
            );
          }

          final snapshot = state.value;
          if (snapshot == null || snapshot.curriculum.units.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              message: l10n.learningPathEmpty,
              action: FilledButton(
                onPressed: () => context.go(AppRoutes.learningPath),
                child: Text(l10n.learningPathTitle),
              ),
            );
          }

          final allLessons = [
            for (final unit in snapshot.curriculum.units)
              ...unit.lessonIds,
          ];
          if (allLessons.isEmpty || snapshot.currentUnit == null) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              message: l10n.noLessons,
            );
          }

          final locale = Localizations.localeOf(context);
          final data = _dashboardData(snapshot, locale, l10n);
          return DesktopHomeDashboardScreen(
            data: data,
            isEngineReady: true,
            playgroundCode: snapshot.playgroundCode,
            onPlaygroundCodeChanged: dashboardProvider.savePlaygroundCode,
            onNavigateRoute: context.go,
            onResumeLesson: () => context.push(
              AppRoutes.lessonPath(snapshot.currentLesson!.id),
            ),
          );
        },
      ),
      bottomNavigationBar: wide
          ? null
          : AppNavigationBar(selectedRoute: AppRoutes.root, onSelected: context.go),
    );
  }

  DashboardDataModel _dashboardData(
    HomeDashboardData snapshot,
    Locale locale,
    AppLocalizations l10n,
  ) {
    final progress = snapshot.progress;
    final currentUnit = snapshot.currentUnit!;
    final currentLesson = snapshot.currentLesson!;
    final allLessons = [
      for (final unit in snapshot.curriculum.units) ...unit.lessonIds,
    ];
    final completedLessons = allLessons
        .where(
          (id) =>
              progress?.lessonsProgress[id]?.status == LessonStatus.completed,
        )
        .length;
    final lessonProgress = progress?.lessonsProgress[currentLesson.id];
    final lessonProgressRatio = lessonProgress?.status == LessonStatus.completed
        ? 1.0
        : lessonProgress == null || lessonProgress.exercisesTotal == 0
        ? 0.0
        : lessonProgress.exercisesCompleted / lessonProgress.exercisesTotal;
    final earnedBadgeIds = progress?.earnedBadges.toSet() ?? const <String>{};
    final earnedBadges = BadgeEvaluator.catalog
        .where((badge) => earnedBadgeIds.contains(badge.id))
        .toList()
      ..sort((a, b) {
        final aDate =
            progress?.earnedBadgeDates[a.id] ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            progress?.earnedBadgeDates[b.id] ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final orderedUnits = snapshot.curriculum.units;

    return DashboardDataModel(
      userProgress: UserProgressModel(
        userName: locale.languageCode == 'ar' ? 'متعلّم' : 'Learner',
        userLevel: l10n.levelLabel(progress?.level ?? 1),
        levelProgress: progress?.levelProgressRatio ?? 0,
        currentXp: progress?.totalXP ?? 0,
        nextLevelXp:
            (progress?.xpToNextLevel ?? 100) -
            (progress?.xpInCurrentLevel ?? 0),
        dailyStreak: progress?.currentStreak ?? 0,
        longestStreak: progress?.longestStreak ?? 0,
        activeProject: '',
        currentUnitTitle: currentUnit.title.resolve(locale),
        completedLessons: completedLessons,
        totalLessons: allLessons.length,
        lastActiveDate: progress?.lastActiveDate,
        overallProgress: allLessons.isEmpty
            ? 0
            : completedLessons / allLessons.length,
      ),
      continueLesson: ContinueLearningModel(
        unitId: currentUnit.id,
        unitTitle: currentUnit.title.resolve(locale),
        lessonId: currentLesson.id,
        lessonTitle: currentLesson.title.resolve(locale),
        estimatedTime: locale.languageCode == 'ar'
            ? '${currentLesson.estimatedMinutes} دقيقة'
            : '${currentLesson.estimatedMinutes} min',
        progress: lessonProgressRatio.clamp(0.0, 1.0),
        xpReward:
            currentLesson.exercises.length *
                GamificationService.firstTryExerciseXp +
            GamificationService.lessonCompletionXp,
        codeSnippetPreview:
            snapshot.playgroundCode.isEmpty
                ? currentLesson.exampleCode ?? ''
                : snapshot.playgroundCode,
      ),
      units: [
        for (var index = 0; index < orderedUnits.length; index++)
          _unitSummary(
            unit: orderedUnits[index],
            index: index,
            units: orderedUnits,
            currentUnitId: currentUnit.id,
            progress: progress,
            locale: locale,
          ),
      ],
      dailyChallenge: const DailyChallengeModel(
        title: '',
        description: '',
        timeRemaining: '',
        xpBonus: 0,
        participantsCount: 0,
      ),
      reviewSummary: const SpacedRepetitionSummaryModel(
        dueCardsCount: 0,
        retentionRatePercent: 0,
        estimatedMinutes: 0,
      ),
      quickStats: QuickStatsModel(
        codeLinesWritten: _savedCodeLineCount(progress),
        completedChallenges: 0,
        earnedBadges: earnedBadges.length,
        totalBadges: BadgeEvaluator.catalog.length,
        recentBadges: [
          for (final badge in earnedBadges.take(2))
            DashboardBadgeModel(
              emoji: _badgeEmoji(badge.id),
              title: badge.title.resolve(locale),
              description: badge.description.resolve(locale),
            ),
        ],
      ),
    );
  }

  UnitSummaryModel _unitSummary({
    required Unit unit,
    required int index,
    required List<Unit> units,
    required String currentUnitId,
    required UserProgress? progress,
    required Locale locale,
  }) {
    final completed = unit.lessonIds
        .where(
          (id) =>
              progress?.lessonsProgress[id]?.status == LessonStatus.completed,
        )
        .length;
    final previous = index == 0 ? null : units[index - 1];
    final locked =
        unit.id != currentUnitId &&
        previous != null &&
        previous.lessonIds.any(
          (id) =>
              progress?.lessonsProgress[id]?.status != LessonStatus.completed,
        );
    return UnitSummaryModel(
      number: unit.order.toString().padLeft(2, '0'),
      title: unit.title.resolve(locale),
      description: unit.description.resolve(locale),
      completedLessons: completed,
      totalLessons: unit.lessonIds.length,
      isCompleted: unit.lessonIds.isNotEmpty && completed == unit.lessonIds.length,
      isActive: unit.id == currentUnitId,
      isLocked: locked,
    );
  }

  int _savedCodeLineCount(UserProgress? progress) =>
      progress?.lessonsProgress.values.fold<int>(
        0,
        (count, lesson) =>
            count +
            (lesson.savedCode?.split('\n').where((line) => line.trim().isNotEmpty).length ??
                0),
      ) ??
      0;

  String _badgeEmoji(String id) => switch (id) {
    'badge_first_line' => '🌱',
    'badge_unit_01' => '⭐',
    'badge_unit_02' => '📦',
    'badge_unit_03' => '🔀',
    'badge_unit_04' => '🔁',
    'badge_unit_05' => '🧩',
    'badge_fast_solver' => '⚡',
    'badge_perseverant' => '🔥',
    'badge_researcher' => '🔎',
    'badge_graduate' => '🎓',
    _ => '🏅',
  };
}

class _HomeDashboardLoadingSkeleton extends StatelessWidget {
  const _HomeDashboardLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final skeleton = Column(
      children: [
          Container(height: 60, color: Theme.of(context).colorScheme.surfaceContainer),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = constraints.maxWidth < 700 ? 16.0 : 32.0;
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(padding, 24, padding, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SkeletonBlock(height: 150, radius: 16),
                            const SizedBox(height: 24),
                            _SkeletonBlock(height: 190, radius: 16),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, innerConstraints) {
                                final playground = _SkeletonBlock(
                                  height: 340,
                                  radius: 12,
                                );
                                final curriculum = Column(
                                  children: [
                                    for (var index = 0; index < 5; index++) ...[
                                      if (index > 0)
                                        const SizedBox(height: 10),
                                      const _SkeletonBlock(
                                        height: 74,
                                        radius: 10,
                                      ),
                                    ],
                                  ],
                                );
                                if (innerConstraints.maxWidth < 980) {
                                  return Column(
                                    children: [
                                      playground,
                                      const SizedBox(height: 24),
                                      curriculum,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: playground),
                                    const SizedBox(width: 24),
                                    Expanded(child: curriculum),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, innerConstraints) {
                                final count = innerConstraints.maxWidth < 1050
                                    ? 1
                                    : 3;
                                return Column(
                                  children: [
                                    for (var index = 0; index < count; index++) ...[
                                      if (index > 0)
                                        const SizedBox(height: 16),
                                      const _SkeletonBlock(
                                        height: 150,
                                        radius: 12,
                                      ),
                                    ],
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
          ),
      ],
    );
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainer,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: skeleton,
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
    ),
  );
}
