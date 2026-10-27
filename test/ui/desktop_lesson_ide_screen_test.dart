import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/app.dart';
import 'package:learn_gdscript/app_dependencies.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/ui/screens/lesson/desktop_lesson_ide_flutter_dart.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  testWidgets('desktop lesson uses repository content and current locale', (
    tester,
  ) async {
    final assetBundle = _LessonAssetBundle();
    addTearDown(assetBundle.completeDelayedLesson);
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: assetBundle,
    );
    addTearDown(dependencies.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/lesson/lesson_02_next');
    await tester.pump();
    expect(find.byType(Shimmer), findsOneWidget);
    assetBundle.completeDelayedLesson();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(DesktopLessonIdeLayout), findsOneWidget);
    expect(find.text('المقدمة'), findsWidgets);
    expect(find.text('درس تجريبي'), findsWidgets);
    expect(find.text('محتوى الدرس'), findsOneWidget);
    final exampleEditor = tester.widget<TextField>(
      find.byType(TextField).first,
    );
    final appTheme = Theme.of(tester.element(find.byType(TextField).first));
    expect(
      exampleEditor.decoration?.fillColor,
      appTheme.colorScheme.surfaceContainerLow,
    );
    final codeBlockFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SelectableText &&
          widget.textSpan?.toPlainText().contains('print(score)') == true,
    );
    final highlightedCode = tester.widget<SelectableText>(codeBlockFinder);
    final codeTheme = CodeEditorTheme.of(tester.element(codeBlockFinder));
    final codeBlockCard = find
        .ancestor(of: codeBlockFinder, matching: find.byType(Card))
        .first;
    expect(tester.widget<Card>(codeBlockCard).color, appTheme.cardColor);
    expect(
      highlightedCode.textSpan!.children!
          .whereType<TextSpan>()
          .where((span) => span.text == 'var')
          .single
          .style
          ?.color,
      codeTheme.keyword,
    );
    expect(
      highlightedCode.textSpan!.children!
          .whereType<TextSpan>()
          .where((span) => span.text == '10')
          .single
          .style
          ?.color,
      codeTheme.number,
    );
    final inlineCodeText = tester.widget<SelectableText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.textSpan?.toPlainText().contains('هذا') == true,
      ),
    );
    final inlineCodeSpan = inlineCodeText.textSpan!.children!
        .whereType<TextSpan>()
        .singleWhere((span) => span.children?.isNotEmpty == true);
    final inlineSpans = inlineCodeSpan.children!.whereType<TextSpan>().toList();
    expect(inlineSpans.first.text, '\u2066');
    expect(inlineSpans.last.text, '\u2069');
    expect(
      inlineSpans.singleWhere((span) => span.text == 'var').style?.color,
      codeTheme.keyword,
    );

    final explanationPanel = find.byKey(
      const ValueKey('lesson_explanation_panel'),
    );
    final editorPanel = find.byKey(const ValueKey('lesson_editor_panel'));
    final initialExplanationWidth = tester.getSize(explanationPanel).width;
    final initialEditorWidth = tester.getSize(editorPanel).width;
    expect(
      initialExplanationWidth,
      closeTo(
        tester.getSize(find.byType(DesktopLessonIdeLayout)).width * 0.65,
        1,
      ),
    );
    await tester.drag(
      find.byKey(const ValueKey('lesson_panel_resize_handle')),
      const Offset(-120, 0),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(explanationPanel).width,
      greaterThan(initialExplanationWidth),
    );
    expect(tester.getSize(editorPanel).width, lessThan(initialEditorWidth));

    await tester.ensureVisible(find.text('احسب النقاط مع المكافأة'));
    expect(find.text('احسب النقاط مع المكافأة'), findsOneWidget);
    await tester.tap(find.text('شغّل'));
    await tester.pumpAndSettle();
    expect(find.text('حالة معتادة'), findsOneWidget);
    expect(find.text('نقاط صفرية'), findsOneWidget);
    expect(find.text('نقاط مرتفعة'), findsOneWidget);
    expect(find.text('المتوقع: 999\nالفعلي: 15'), findsOneWidget);

    await dependencies.appSettingsProvider.setLocale(const Locale('en'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Test lesson'), findsWidgets);
    expect(find.text('Test content'), findsOneWidget);
    expect(
      find.text('Calculate score with the supplied bonus'),
      findsOneWidget,
    );
  });
}

class _LessonAssetBundle extends CachingAssetBundle {
  static const _manifest = '''
    {
      "version": "1",
      "targetGDScriptVersion": "4",
      "units": [{
        "id": "unit_01_intro",
        "title": {"ar": "المقدمة", "en": "Introduction"},
        "description": {"ar": "الوحدة الأولى", "en": "First unit"},
        "iconName": "school",
        "order": 0,
        "lessonIds": ["lesson_01_intro", "lesson_02_next"]
      }]
    }
  ''';

  final _delayedLesson = Completer<void>();

  void completeDelayedLesson() {
    if (!_delayedLesson.isCompleted) _delayedLesson.complete();
  }

  @override
  Future<ByteData> load(String key) async {
    final name = key.split('/').last;
    if (name == 'lesson_02_next.json') await _delayedLesson.future;
    final source = switch (name) {
      'lesson_01_intro.json' => _lesson(
        id: 'lesson_01_intro',
        titleAr: 'المقدمة',
        titleEn: 'Introduction',
        contentAr: 'محتوى البداية',
        contentEn: 'Introduction content',
      ),
      'lesson_02_next.json' => _lesson(
        id: 'lesson_02_next',
        titleAr: 'درس تجريبي',
        titleEn: 'Test lesson',
        contentAr:
            'محتوى الدرس\nهذا `var score = 10` مثال\n\n```gdscript\nvar score = 10\nprint(score)\n```',
        contentEn:
            'Test content\nThis is `var score = 10` inline code\n\n```gdscript\nvar score = 10\nprint(score)\n```',
        exercises: [
          {
            'id': 'ex_test_score',
            'lessonId': 'lesson_02_next',
            'order': 0,
            'type': 'writeCode',
            'prompt': {
              'ar': 'احسب النقاط مع المكافأة',
              'en': 'Calculate score with the supplied bonus',
            },
            'starterCode': 'print(score + bonus)',
            'solutionCode': 'print(score + bonus)',
            'testCases': [
              {
                'description': {'ar': 'حالة معتادة', 'en': 'Typical player'},
                'setupCode': 'var score = 10\nvar bonus = 5',
                'expectedOutput': '15',
              },
              {
                'description': {'ar': 'نقاط صفرية', 'en': 'Empty score'},
                'setupCode': 'var score = 0\nvar bonus = 0',
                'expectedOutput': '0',
              },
              {
                'description': {'ar': 'نقاط مرتفعة', 'en': 'High score'},
                'setupCode': 'var score = 20\nvar bonus = 10',
                'expectedOutput': '999',
              },
            ],
            'hints': [
              {'ar': 'اجمع النقاط والمكافأة.', 'en': 'Add score and bonus.'},
              {
                'ar': 'استخدم المتغيرات المهيأة للاختبار.',
                'en': 'Use the variables initialized for the test.',
              },
            ],
          },
        ],
      ),
      _ => _manifest,
    };
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }

  static String _lesson({
    required String id,
    required String titleAr,
    required String titleEn,
    required String contentAr,
    required String contentEn,
    List<Object?> exercises = const [],
  }) => jsonEncode({
    'id': id,
    'unitId': 'unit_01_intro',
    'title': {'ar': titleAr, 'en': titleEn},
    'objective': {'ar': 'تعلّم الأساسيات', 'en': 'Learn the basics'},
    'estimatedMinutes': 5,
    'order': 0,
    'contentMarkdown': {'ar': contentAr, 'en': contentEn},
    'exampleCode': 'var example_value = 1',
    'exercises': exercises,
  });
}
