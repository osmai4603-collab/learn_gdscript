import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/review_schedule.dart';
import 'package:learn_gdscript/logic/services/review_service.dart';

void main() {
  const service = ReviewService();
  final reviewedAt = DateTime.utc(2026, 10, 25, 9);

  test('successful SM-2 reviews use the initial and subsequent intervals', () {
    final first = service.schedule(
      cardId: 'card-1',
      conceptId: 'concept-1',
      rating: Sm2Rating.good,
      now: reviewedAt,
    );
    expect(first.repetitionCount, 1);
    expect(first.intervalDays, 1);
    expect(first.nextReviewAt, reviewedAt.add(const Duration(days: 1)));

    final second = service.schedule(
      cardId: first.cardId,
      conceptId: first.conceptId,
      rating: Sm2Rating.good,
      previous: first,
      now: reviewedAt,
    );
    expect(second.repetitionCount, 2);
    expect(second.intervalDays, 6);

    final third = service.schedule(
      cardId: second.cardId,
      conceptId: second.conceptId,
      rating: Sm2Rating.easy,
      previous: second,
      now: reviewedAt,
    );
    expect(third.repetitionCount, 3);
    expect(third.intervalDays, (6 * third.easinessFactor).round());
    expect(third.easinessFactor, greaterThan(second.easinessFactor));
  });

  test('Again resets repetitions and schedules a short retry', () {
    final previous = ReviewSchedule(
      cardId: 'card-1',
      conceptId: 'concept-1',
      repetitionCount: 4,
      easinessFactor: 2.1,
      intervalDays: 12,
      lastReviewedAt: reviewedAt.subtract(const Duration(days: 12)),
      nextReviewAt: reviewedAt,
      lastRating: Sm2Rating.good,
    );
    final retry = service.schedule(
      cardId: previous.cardId,
      conceptId: previous.conceptId,
      rating: Sm2Rating.again,
      previous: previous,
      now: reviewedAt,
    );
    expect(retry.repetitionCount, 0);
    expect(retry.intervalDays, 0);
    expect(retry.lastRating, Sm2Rating.again);
    expect(
      retry.nextReviewAt,
      reviewedAt.add(ReviewService.retryDelay),
    );
  });

  test('easiness factor never drops below the SM-2 minimum', () {
    var schedule = service.schedule(
      cardId: 'card-1',
      conceptId: 'concept-1',
      rating: Sm2Rating.again,
      now: reviewedAt,
    );
    for (var attempt = 0; attempt < 10; attempt++) {
      schedule = service.schedule(
        cardId: schedule.cardId,
        conceptId: schedule.conceptId,
        rating: Sm2Rating.again,
        previous: schedule,
        now: reviewedAt,
      );
    }
    expect(
      schedule.easinessFactor,
      ReviewService.minimumEasinessFactor,
    );
  });
}
