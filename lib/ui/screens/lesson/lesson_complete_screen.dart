import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/async_state.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/gamification_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/lesson_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../../logic/services/badge_evaluator.dart';
import '../../routers/app_routes.dart';
import '../../widgets/gamification/badge_unlocked_dialog.dart';
import '../../widgets/gamification/confetti_celebration.dart';
import 'desktop_lesson_complete_flutter_dart.dart';

class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({
    super.key,
    required this.lessonId,
    this.earnedXP = 0,
    this.hintsUsedCount = 0,
    this.timeSpentMinutes = 0,
    this.newlyUnlockedBadges = const [],
  });

  final String lessonId;
  final int earnedXP;
  final int hintsUsedCount;
  final int timeSpentMinutes;
  final List<String> newlyUnlockedBadges;

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showBadgeCelebration());
  }

  Future<void> _showBadgeCelebration() async {
    if (!mounted || widget.newlyUnlockedBadges.isEmpty) return;
    for (final badgeId in widget.newlyUnlockedBadges) {
      if (!mounted) return;
      final badge = _badgeFor(badgeId);
      if (badge != null) {
        await BadgeUnlockedDialog.show(context, badge);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final curriculumProvider = context.watch<CurriculumProvider>();
    final lesson = lessonProvider.selectedLesson;
    final progress = progressProvider.progress;
    final curriculum = curriculumProvider.state.value;

    if ((lesson == null &&
            (lessonProvider.state.status == LoadStatus.initial ||
                lessonProvider.state.status == LoadStatus.loading)) ||
        (progress == null &&
            (progressProvider.state.status == LoadStatus.initial ||
                progressProvider.state.status == LoadStatus.loading)) ||
        lessonProvider.state.status == LoadStatus.loading ||
        progressProvider.state.status == LoadStatus.loading ||
        curriculumProvider.state.status == LoadStatus.loading) {
      return const LessonCompleteLoadingSkeleton();
    }

    final locale = Localizations.localeOf(context);
    final lessonTitle = lesson?.title.resolve(locale) ?? widget.lessonId;
    final lessonProgress = progress?.lessonsProgress[widget.lessonId];
    final exerciseCount =
        lessonProgress?.exercisesCompleted ?? lesson?.exercises.length ?? 0;
    final currentLevel = progress == null ? null : progress.totalXP ~/ 100 + 1;
    final previousTotalXp = progress == null
        ? null
        : (progress.totalXP - widget.earnedXP).clamp(0, progress.totalXP);
    final previousLevel = previousTotalXp == null
        ? null
        : previousTotalXp ~/ 100 + 1;
    final leveledUp =
        currentLevel != null &&
        previousLevel != null &&
        currentLevel > previousLevel;
    final nextLessonId = _nextLessonId(curriculum, widget.lessonId);
    final l10n = context.l10n;
    final providerErrors = [
      lessonProvider.state.error,
      progressProvider.state.error,
      curriculumProvider.state.error,
    ].whereType<Object>();
    final detailsError = providerErrors.isEmpty
        ? null
        : l10n.lessonCompleteDetailsError(
            providerErrors.map((error) => error.toString()).join('\n'),
          );
    final model = LessonCompleteRewardModel(
      lessonTitle: lessonTitle,
      earnedXp: widget.earnedXP,
      exercisesCompleted: exerciseCount,
      hintsUsedCount: widget.hintsUsedCount,
      timeSpentMinutes: widget.timeSpentMinutes,
      currentStreak: progress?.currentStreak,
      currentLevel: leveledUp ? currentLevel : null,
      levelProgress: leveledUp ? progress?.levelProgressRatio : null,
      leveledUp: leveledUp,
      badges: [
        for (final badgeId in widget.newlyUnlockedBadges)
          if (_badgeFor(badgeId) case final badge?)
            LessonCompleteBadgeModel(title: badge.title.resolve(locale)),
      ],
    );

    return Stack(
      children: [
        DesktopLessonCompleteScreen(
          data: model,
          detailsError: detailsError,
          onBackToCurriculum: () => context.go(AppRoutes.learningPath),
          onContinueNextLesson: nextLessonId == null
              ? null
              : () => context.go(AppRoutes.lessonPath(nextLessonId)),
        ),
        const Positioned.fill(child: ConfettiCelebration()),
      ],
    );
  }

  static BadgeDefinition? _badgeFor(String id) {
    for (final badge in BadgeEvaluator.catalog) {
      if (badge.id == id) return badge;
    }
    return null;
  }

  static String? _nextLessonId(Curriculum? curriculum, String lessonId) {
    if (curriculum == null) return null;
    final lessons = [for (final unit in curriculum.units) ...unit.lessonIds];
    final index = lessons.indexOf(lessonId);
    return index >= 0 && index + 1 < lessons.length ? lessons[index + 1] : null;
  }
}
