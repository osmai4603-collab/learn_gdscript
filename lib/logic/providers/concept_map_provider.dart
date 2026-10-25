import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/async_state.dart';
import '../../data/models/concept_map_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/models/review_schedule.dart';
import '../../data/repositories/concept_map_repository.dart';
import '../../data/repositories/review_schedule_repository.dart';
import '../services/review_service.dart';
import 'curriculum_provider.dart';
import 'progress_provider.dart';

class ConceptMapProvider extends ChangeNotifier {
  ConceptMapProvider({
    required ConceptMapRepository conceptMapRepository,
    required ReviewScheduleRepository reviewScheduleRepository,
    required CurriculumProvider curriculumProvider,
    required ProgressProvider progressProvider,
    required this.visitorId,
    ReviewService reviewService = const ReviewService(),
    DateTime Function()? clock,
  }) : _conceptMapRepository = conceptMapRepository,
       _reviewScheduleRepository = reviewScheduleRepository,
       _curriculumProvider = curriculumProvider,
       _progressProvider = progressProvider,
       _reviewService = reviewService,
       _clock = clock ?? DateTime.now {
    _curriculumProvider.addListener(_refreshWhenReady);
    _progressProvider.addListener(_refreshWhenReady);
  }

  final ConceptMapRepository _conceptMapRepository;
  final ReviewScheduleRepository _reviewScheduleRepository;
  final CurriculumProvider _curriculumProvider;
  final ProgressProvider _progressProvider;
  final ReviewService _reviewService;
  final DateTime Function() _clock;
  final String visitorId;

  AsyncState<ConceptMapSnapshot> state = const AsyncState.initial();
  bool isSavingRating = false;
  int _loadSequence = 0;
  bool _disposed = false;

  Future<void> load() async {
    final sequence = ++_loadSequence;
    state = const AsyncState.loading();
    notifyListeners();
    await _loadSnapshot(sequence);
  }

  Future<void> _loadSnapshot(int sequence) async {
    try {
      final curriculum = _curriculumProvider.state.value;
      if (curriculum == null) {
        throw StateError('Curriculum must be loaded before the concept map.');
      }
      final progress = _progressProvider.progress;
      if (progress == null || progress.visitorId != visitorId) {
        throw StateError('User progress must be loaded before the concept map.');
      }
      final content = await _conceptMapRepository.load(curriculum);
      final schedules = await _reviewScheduleRepository.loadSchedules(
        visitorId,
      );
      if (_disposed || sequence != _loadSequence) return;
      state = AsyncState.data(
        _snapshot(content: content, progress: progress, schedules: schedules),
      );
      notifyListeners();
    } on Object catch (error) {
      if (_disposed || sequence != _loadSequence) return;
      state = AsyncState.error(error);
      notifyListeners();
    }
  }

  Future<void> rateCard({
    required String cardId,
    required Sm2Rating rating,
  }) async {
    if (isSavingRating) {
      throw StateError('A review rating is already being saved.');
    }
    final snapshot = state.value;
    if (state.status != LoadStatus.data || snapshot == null) {
      throw StateError('Concept map data is not available.');
    }
    final card = snapshot.allCards.where((item) => item.id == cardId);
    if (card.isEmpty) throw ArgumentError.value(cardId, 'cardId');
    if (!snapshot.dueCards.any((item) => item.id == cardId)) {
      throw StateError('The review card is not due.');
    }

    isSavingRating = true;
    notifyListeners();
    try {
      final schedule = _reviewService.schedule(
        cardId: cardId,
        conceptId: card.first.conceptId,
        rating: rating,
        previous: snapshot.schedules[cardId],
        now: _clock(),
      );
      await _reviewScheduleRepository.saveSchedule(
        visitorId: visitorId,
        schedule: schedule,
      );
      if (_disposed) return;
      final schedules = Map<String, ReviewSchedule>.from(snapshot.schedules)
        ..[cardId] = schedule;
      state = AsyncState.data(
        _snapshot(
          content: snapshot.content,
          progress: _progressProvider.progress ?? snapshot.progress,
          schedules: schedules,
        ),
      );
    } finally {
      isSavingRating = false;
      if (!_disposed) notifyListeners();
    }
  }

  ConceptMapSnapshot _snapshot({
    required ConceptMapContent content,
    required UserProgress progress,
    required Map<String, ReviewSchedule> schedules,
  }) {
    final loadedAt = _clock().toUtc();
    return ConceptMapSnapshot(
      content: content,
      progress: progress,
      schedules: schedules,
      dueCards: _dueCards(content, schedules, progress, loadedAt),
      loadedAt: loadedAt,
    );
  }

  List<ConceptMapReviewCard> _dueCards(
    ConceptMapContent content,
    Map<String, ReviewSchedule> schedules,
    UserProgress progress,
    DateTime now,
  ) {
    return ConceptMapSnapshot(
      content: content,
      progress: progress,
      schedules: schedules,
      dueCards: const [],
      loadedAt: now,
    ).dueCardsAt(now);
  }

  void _refreshWhenReady() {
    if (_disposed || state.status == LoadStatus.initial) return;
    final sequence = ++_loadSequence;
    unawaited(_loadSnapshot(sequence));
  }

  @override
  void dispose() {
    _disposed = true;
    _loadSequence++;
    _curriculumProvider.removeListener(_refreshWhenReady);
    _progressProvider.removeListener(_refreshWhenReady);
    super.dispose();
  }
}
