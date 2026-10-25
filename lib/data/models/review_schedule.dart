import 'package:flutter/foundation.dart';

enum Sm2Rating { again, hard, good, easy }

@immutable
class ReviewSchedule {
  ReviewSchedule({
    required this.cardId,
    required this.conceptId,
    required this.repetitionCount,
    required this.easinessFactor,
    required this.intervalDays,
    required this.lastReviewedAt,
    required this.nextReviewAt,
    required this.lastRating,
  }) {
    if (cardId.trim().isEmpty) throw ArgumentError.value(cardId, 'cardId');
    if (conceptId.trim().isEmpty) {
      throw ArgumentError.value(conceptId, 'conceptId');
    }
    if (repetitionCount < 0 || intervalDays < 0) {
      throw ArgumentError('Review counts and intervals must be non-negative.');
    }
    if (!easinessFactor.isFinite || easinessFactor < 1.3) {
      throw ArgumentError.value(easinessFactor, 'easinessFactor');
    }
  }

  final String cardId;
  final String conceptId;
  final int repetitionCount;
  final double easinessFactor;
  final int intervalDays;
  final DateTime lastReviewedAt;
  final DateTime nextReviewAt;
  final Sm2Rating lastRating;
}
