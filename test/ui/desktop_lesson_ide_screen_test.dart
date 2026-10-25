import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/app.dart';
import 'package:learn_gdscript/app_dependencies.dart';
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
    await tester.pumpAndSettle();
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

    await dependencies.appSettingsProvider.setLocale(const Locale('en'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Test lesson'), findsWidgets);
    expect(find.text('Test content'), findsOneWidget);
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
        contentAr: 'محتوى الدرس',
        contentEn: 'Test content',
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
  }) => jsonEncode({
    'id': id,
    'unitId': 'unit_01_intro',
    'title': {'ar': titleAr, 'en': titleEn},
    'objective': {'ar': 'تعلّم الأساسيات', 'en': 'Learn the basics'},
    'estimatedMinutes': 5,
    'order': 0,
    'contentMarkdown': {'ar': contentAr, 'en': contentEn},
    'exercises': [],
  });
}
