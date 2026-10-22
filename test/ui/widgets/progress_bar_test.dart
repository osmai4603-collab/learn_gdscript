import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/ui/widgets/progress/progress_bar.dart';

void main() {
  testWidgets('progress bar clamps values and displays a label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonProgressBar(completed: 4, total: 3),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('4/3'), findsOneWidget);
    expect(tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    ).value, 1);
  });
}
