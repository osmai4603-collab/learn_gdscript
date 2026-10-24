import 'package:flutter/foundation.dart';

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
