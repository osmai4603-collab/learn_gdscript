import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/ui/widgets/lesson_error_widget.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders lesson error widget with retry and back buttons', (
    tester,
  ) async {
    var retryPressed = false;
    var backPressed = false;

    await tester.pumpWidget(
      buildTestableWidget(
        LessonErrorWidget(
          error: const LessonNotFoundException('lesson_01'),
          onRetry: () => retryPressed = true,
          onBackToPath: () => backPressed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LessonErrorWidget), findsOneWidget);
    expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);

    final retryButton = find.widgetWithText(OutlinedButton, 'إعادة المحاولة');
    expect(retryButton, findsOneWidget);
    await tester.tap(retryButton);
    expect(retryPressed, isTrue);

    final backButton = find.widgetWithText(FilledButton, 'العودة للمسار');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    expect(backPressed, isTrue);
  });
}
