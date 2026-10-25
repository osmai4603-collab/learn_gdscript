import 'package:flutter/foundation.dart';

import '../../data/models/review_schedule.dart';

enum ReviewResult { correct, incorrect }

@immutable
class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.title,
    this.lessonId,
    this.category = 'lesson',
    this.lastReviewedAt,
    this.nextReviewAt,
    required this.intervalDays,
    this.lastResult,
  });

  final String id;
  final String title;
  final String? lessonId;
  final String category;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final int intervalDays;
  final ReviewResult? lastResult;

  ReviewItem copyWith({
    String? id,
    String? title,
    String? lessonId,
    String? category,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? intervalDays,
    ReviewResult? lastResult,
  }) => ReviewItem(
    id: id ?? this.id,
    title: title ?? this.title,
    lessonId: lessonId ?? this.lessonId,
    category: category ?? this.category,
    lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    intervalDays: intervalDays ?? this.intervalDays,
    lastResult: lastResult ?? this.lastResult,
  );
}

class ReviewService {
  const ReviewService();

  static const minimumEasinessFactor = 1.3;
  static const initialEasinessFactor = 2.5;
  static const retryDelay = Duration(minutes: 10);

  ReviewSchedule schedule({
    required String cardId,
    required String conceptId,
    required Sm2Rating rating,
    ReviewSchedule? previous,
    DateTime? now,
  }) {
    final reviewedAt = (now ?? DateTime.now()).toUtc();
    final quality = switch (rating) {
      Sm2Rating.again => 0,
      Sm2Rating.hard => 3,
      Sm2Rating.good => 4,
      Sm2Rating.easy => 5,
    };
    final previousEasiness =
        previous?.easinessFactor ?? initialEasinessFactor;
    final difference = 5 - quality;
    final easinessFactor = (previousEasiness +
            (0.1 - difference * (0.08 + difference * 0.02)))
        .clamp(minimumEasinessFactor, double.infinity)
        .toDouble();

    if (rating == Sm2Rating.again) {
      return ReviewSchedule(
        cardId: cardId,
        conceptId: conceptId,
        repetitionCount: 0,
        easinessFactor: easinessFactor,
        intervalDays: 0,
        lastReviewedAt: reviewedAt,
        nextReviewAt: reviewedAt.add(retryDelay),
        lastRating: rating,
      );
    }

    final repetitions = (previous?.repetitionCount ?? 0) + 1;
    final intervalDays = switch (repetitions) {
      1 => 1,
      2 => 6,
      _ => ((previous?.intervalDays ?? 0) * easinessFactor).round().clamp(
        1,
        36500,
      ).toInt(),
    };
    return ReviewSchedule(
      cardId: cardId,
      conceptId: conceptId,
      repetitionCount: repetitions,
      easinessFactor: easinessFactor,
      intervalDays: intervalDays,
      lastReviewedAt: reviewedAt,
      nextReviewAt: reviewedAt.add(Duration(days: intervalDays)),
      lastRating: rating,
    );
  }

  DateTime nextReviewDate({
    required ReviewItem item,
    required ReviewResult result,
    DateTime? now,
  }) {
    final reviewedAt = now ?? DateTime.now();
    final nextInterval = result == ReviewResult.correct
        ? _advanceInterval(item.intervalDays)
        : 1;
    return reviewedAt.add(Duration(days: nextInterval));
  }

  ReviewItem gradeReview({
    required ReviewItem item,
    required ReviewResult result,
    DateTime? now,
  }) {
    final reviewedAt = now ?? DateTime.now();
    final nextInterval = result == ReviewResult.correct
        ? _advanceInterval(item.intervalDays)
        : 1;
    return item.copyWith(
      lastReviewedAt: reviewedAt,
      nextReviewAt: reviewedAt.add(Duration(days: nextInterval)),
      intervalDays: nextInterval,
      lastResult: result,
    );
  }

  List<ReviewItem> getDueReviews({
    required List<ReviewItem> items,
    required DateTime now,
  }) {
    final due = items.where((item) {
      final dueDate = item.nextReviewAt ?? item.lastReviewedAt ?? now;
      return !dueDate.isAfter(now);
    }).toList(growable: false)
      ..sort((a, b) {
        final aDate = a.nextReviewAt ?? a.lastReviewedAt ?? DateTime.now();
        final bDate = b.nextReviewAt ?? b.lastReviewedAt ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
    return due;
  }

  int _advanceInterval(int currentInterval) {
    if (currentInterval <= 0) return 1;
    final base = currentInterval == 1 ? 3 : currentInterval * 2;
    return base;
  }
}
