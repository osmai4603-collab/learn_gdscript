import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/gamification_models.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../logic/services/badge_evaluator.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/lesson_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../routers/app_routes.dart';
import '../../widgets/gamification/badge_unlocked_dialog.dart';
import '../../widgets/gamification/confetti_celebration.dart';

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
    final lesson = context.watch<LessonProvider>().selectedLesson;
    final progress = context
        .watch<ProgressProvider>()
        .progress
        ?.lessonsProgress[widget.lessonId];
    final curriculum = context.watch<CurriculumProvider>().state.value;
    final title =
        lesson?.title.resolve(Localizations.localeOf(context)) ??
        widget.lessonId;
    final nextLessonId = _nextLessonId(curriculum, widget.lessonId);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lessonComplete)),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 72,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.lessonComplete,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.completedLesson(title),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.stars,
                              color: Theme.of(context).colorScheme.primary,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.xpAwarded(widget.earnedXP),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.newlyUnlockedBadges.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      for (final badgeId in widget.newlyUnlockedBadges)
                        if (_badgeFor(badgeId) case final badge?)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.emoji_events),
                              title: Text(
                                badge.title.resolve(
                                  Localizations.localeOf(context),
                                ),
                              ),
                              subtitle: Text(l10n.badgeUnlocked),
                            ),
                          ),
                    ],
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text(
                              l10n.exercisesSolved(
                                progress?.exercisesCompleted ??
                                    lesson?.exercises.length ??
                                    0,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.lightbulb_outline),
                            title: Text(l10n.hintsUsed(widget.hintsUsedCount)),
                          ),
                          ListTile(
                            leading: const Icon(Icons.timer_outlined),
                            title: Text(l10n.timeSpent(widget.timeSpentMinutes)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go(AppRoutes.learningPath),
                          child: Text(l10n.backToPath),
                        ),
                        if (nextLessonId != null)
                          FilledButton(
                            onPressed: () => context.go(
                              AppRoutes.lessonPath(nextLessonId),
                            ),
                            child: Text(l10n.nextLesson),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: ConfettiCelebration()),
        ],
      ),
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
    final lessons = [
      for (final unit in curriculum.units) ...unit.lessonIds,
    ];
    final index = lessons.indexOf(lessonId);
    return index >= 0 && index + 1 < lessons.length ? lessons[index + 1] : null;
  }
}
