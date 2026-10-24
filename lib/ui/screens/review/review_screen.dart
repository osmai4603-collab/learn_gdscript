import 'package:flutter/material.dart';

import '../../../logic/services/review_service.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key, this.initialItems = const []});

  final List<ReviewItem> initialItems;

  @override
  Widget build(BuildContext context) {
    final service = const ReviewService();
    final items = initialItems.isNotEmpty
        ? initialItems
        : const [
            ReviewItem(
              id: 'variables',
              title: 'المتغيرات',
              lessonId: 'lesson_03_variables',
              category: 'lesson',
              lastReviewedAt: null,
              nextReviewAt: null,
              intervalDays: 1,
              lastResult: ReviewResult.correct,
            ),
          ];
    final now = DateTime.now();
    final due = service.getDueReviews(items: items, now: now);

    return Scaffold(
      appBar: AppBar(title: const Text('المراجعة الذكية')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'استعراض اليوم',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('العناصر المستحقة: ${due.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (due.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('لا توجد مراجعات مستحقة اليوم. عد لاحقاً.'),
              ),
            )
          else
            for (final item in due)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.repeat),
                  title: Text(item.title),
                  subtitle: Text(
                    item.lessonId == null
                        ? 'فاصل ${item.intervalDays} يوم'
                        : 'درس: ${item.lessonId}',
                  ),
                  trailing: IconButton(
                    onPressed: () {
                                      final updated = service.gradeReview(
                        item: item,
                        result: ReviewResult.correct,
                        now: now,
                      );
                      final nextReviewDay = updated.nextReviewAt ?? now;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تحديث ${updated.title} → ${nextReviewDay.day}/${nextReviewDay.month}',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
