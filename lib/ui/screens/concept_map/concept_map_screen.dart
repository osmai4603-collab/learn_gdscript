import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/async_state.dart';
import '../../../data/models/concept_map_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../data/models/review_schedule.dart';
import '../../../logic/providers/concept_map_provider.dart';
import '../../../logic/services/review_service.dart';
import 'desktop_concept_map_sm_2_flutter_dart.dart';

class ConceptMapScreen extends StatefulWidget {
  const ConceptMapScreen({super.key});

  @override
  State<ConceptMapScreen> createState() => _ConceptMapScreenState();
}

class _ConceptMapScreenState extends State<ConceptMapScreen> {
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) return;
    _loadStarted = true;
    unawaited(context.read<ConceptMapProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Consumer<ConceptMapProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        if (state.status == LoadStatus.initial ||
            state.status == LoadStatus.loading) {
          return _ConceptMapLoadingView(locale: locale);
        }
        if (state.status == LoadStatus.error) {
          return _ConceptMapErrorView(
            locale: locale,
            error: state.error!,
            onRetry: provider.load,
          );
        }
        final snapshot = state.value!;
        if (snapshot.content.manifest.concepts.isEmpty) {
          return _ConceptMapEmptyView(locale: locale);
        }
        final data = _buildViewData(snapshot, locale);
        return DesktopConceptMapSm2Screen(
          data: data,
          isSavingRating: provider.isSavingRating,
          onNavigateRoute: context.go,
          onRateCard: (cardId, rating) => provider.rateCard(
            cardId: cardId,
            rating: rating,
          ),
        );
      },
    );
  }

  ConceptMapSm2DataModel _buildViewData(
    ConceptMapSnapshot snapshot,
    Locale locale,
  ) {
    final concepts = [
      for (final definition in snapshot.content.manifest.concepts)
        _buildConceptNode(snapshot, definition, locale),
    ];
    final cards = [
      for (final card in snapshot.dueCards)
        _buildFlashcard(snapshot, card, locale),
    ];
    return ConceptMapSm2DataModel(
      totalConceptsCount: concepts.length,
      masteredConceptsCount: concepts
          .where((concept) => concept.mastery == ConceptMasteryLevel.mastered)
          .length,
      dueTodayCardsCount: cards.length,
      averageRetentionRate: null,
      streakDays: snapshot.progress.currentStreak,
      xp: snapshot.progress.totalXP,
      concepts: concepts,
      activeReviewDeck: cards,
      selectedConceptId: concepts.first.id,
    );
  }

  KnowledgeConceptNodeModel _buildConceptNode(
    ConceptMapSnapshot snapshot,
    ConceptDefinition definition,
    Locale locale,
  ) {
    final lesson = snapshot.content.lessons[definition.lessonId]!;
    final unit = snapshot.content.units[lesson.unitId]!;
    final schedules = snapshot.schedules.values
        .where((schedule) => schedule.conceptId == definition.id)
        .toList(growable: false)
      ..sort((a, b) => b.lastReviewedAt.compareTo(a.lastReviewedAt));
    final latestSchedule = schedules.isEmpty ? null : schedules.first;
    final lessonIsCompleted =
        snapshot.progress.lessonsProgress[lesson.id]?.status ==
        LessonStatus.completed;
    final prerequisitesCompleted = definition.prerequisiteIds.every((id) {
      final prerequisite = snapshot.content.manifest.concepts.firstWhere(
        (concept) => concept.id == id,
      );
      return snapshot.progress.lessonsProgress[prerequisite.lessonId]?.status ==
          LessonStatus.completed;
    });
    final mastery = lessonIsCompleted
        ? snapshot.dueCards.any((card) => card.conceptId == definition.id)
              ? ConceptMasteryLevel.reviewing
              : ConceptMasteryLevel.mastered
        : !prerequisitesCompleted
        ? ConceptMasteryLevel.locked
        : schedules.isNotEmpty
        ? ConceptMasteryLevel.reviewing
        : ConceptMasteryLevel.learning;
    final hasDueCards = snapshot.dueCards.any(
      (card) => card.conceptId == definition.id,
    );
    final nextReview = schedules
        .map((schedule) => schedule.nextReviewAt)
        .reduceOrNull((a, b) => a.isBefore(b) ? a : b);
    final daysUntilReview = hasDueCards
        ? 0
        : nextReview == null
        ? null
        : nextReview.difference(snapshot.loadedAt).inDays.clamp(0, 36500);
    final example = lesson.exampleCode ??
        (lesson.exercises.isEmpty ? '' : lesson.exercises.first.starterCode);

    return KnowledgeConceptNodeModel(
      id: definition.id,
      titleAr: lesson.title.ar,
      titleEn: lesson.title.en,
      category: unit.title.resolve(locale),
      categoryEn: unit.title.en,
      mastery: mastery,
      retentionPercent: null,
      daysUntilNextReview: daysUntilReview,
      lastReviewedDate: latestSchedule == null
          ? ''
          : DateFormat.yMMMd(locale.languageCode).format(
              latestSchedule.lastReviewedAt.toLocal(),
            ),
      description: lesson.objective.ar,
      descriptionEn: lesson.objective.en,
      codeExample: example,
      lessonId: lesson.id,
      prerequisites: definition.prerequisiteIds,
      visualPosition: Offset(definition.x, definition.y),
    );
  }

  Sm2FlashcardItemModel _buildFlashcard(
    ConceptMapSnapshot snapshot,
    ConceptMapReviewCard card,
    Locale locale,
  ) {
    final schedule = snapshot.schedules[card.id];
    return Sm2FlashcardItemModel(
      id: card.id,
      conceptId: card.conceptId,
      promptQuestion: card.prompt.resolve(locale),
      promptQuestionEn: card.prompt.en,
      codeContext: card.codeContext,
      answerExplanation: card.answerExplanation.resolve(locale),
      answerExplanationEn: card.answerExplanation.en,
      answerCode: card.answerCode,
      repetitionCount: schedule?.repetitionCount ?? 0,
      easinessFactor: schedule?.easinessFactor ?? ReviewService.initialEasinessFactor,
      currentIntervalDays: schedule?.intervalDays ?? 0,
    );
  }
}

class _ConceptMapLoadingView extends StatelessWidget {
  const _ConceptMapLoadingView({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: colors.surfaceContainerHighest,
        highlightColor: colors.surface,
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SkeletonBlock(height: 52, width: double.infinity),
              const SizedBox(height: 16),
              _SkeletonBlock(height: 70, width: double.infinity),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: _SkeletonBlock(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                          ),
                        ),
                        if (constraints.maxWidth > 720) ...[
                          const SizedBox(width: 16),
                          const SizedBox(
                            width: 300,
                            child: _SkeletonBlock(
                              width: 300,
                              height: double.infinity,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _conceptMapText(locale, 'جارٍ تحميل خريطة المفاهيم…', 'Loading concept map…'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

class _ConceptMapErrorView extends StatelessWidget {
  const _ConceptMapErrorView({
    required this.locale,
    required this.error,
    required this.onRetry,
  });

  final Locale locale;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _conceptMapText(
                  locale,
                  'تعذر تحميل خريطة المفاهيم.',
                  'Could not load the concept map.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SelectableText(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(_conceptMapText(locale, 'إعادة المحاولة', 'Retry')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ConceptMapEmptyView extends StatelessWidget {
  const _ConceptMapEmptyView({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text(
        _conceptMapText(
          locale,
          'لا توجد مفاهيم متاحة حالياً.',
          'No concepts are available yet.',
        ),
      ),
    ),
  );
}

String _conceptMapText(Locale locale, String arabic, String english) =>
    locale.languageCode == 'en' ? english : arabic;

extension on Iterable<DateTime> {
  DateTime? reduceOrNull(DateTime Function(DateTime, DateTime) combine) {
    if (isEmpty) return null;
    return reduce(combine);
  }
}
