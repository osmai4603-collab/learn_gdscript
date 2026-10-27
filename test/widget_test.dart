// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/app.dart';
import 'package:learn_gdscript/app_dependencies.dart';
import 'package:learn_gdscript/data/models/app_settings.dart';
import 'package:learn_gdscript/data/models/onboarding_draft.dart';
import 'package:learn_gdscript/data/repositories/home_dashboard_repository.dart';
import 'package:learn_gdscript/data/repositories/settings_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/ui/layouts/academy_app_layout.dart';
import 'package:learn_gdscript/ui/layouts/app_shell_sidebar.dart';
import 'package:learn_gdscript/ui/screens/gamification/badges_screen.dart';
import 'package:learn_gdscript/ui/screens/lesson/lesson_screen.dart';
import 'package:learn_gdscript/ui/screens/settings/engine_diagnostics_screen.dart';
import 'package:learn_gdscript/ui/widgets/common/navigation_bar.dart';
import 'package:learn_gdscript/ui/widgets/code_directionality.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  testWidgets('shows onboarding once and opens the main destinations', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TestAssetBundle(),
    );
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('ما هي خلفيتك البرمجية الحالية؟'), findsOneWidget);
    await tester.tap(find.text('تخطي إلى الرئيسية ↵'));
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(
      dependencies.onboardingProvider.draft?.status,
      OnboardingStatus.skipped,
    );
    expect(
      find.text('ستُضاف المواد التعليمية في مرحلة لاحقة.'),
      findsOneWidget,
    );
    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المظهر واللغة'));
    await tester.pumpAndSettle();
    expect(find.text('اللغة'), findsOneWidget);
  });

  testWidgets('uses the app shell sidebar on wide screens', (tester) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TestAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.byType(AcademyAppLayout), findsOneWidget);
    expect(find.byType(AppShellSidebar), findsOneWidget);
    expect(find.byType(AppNavigationBar), findsNothing);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('مسار التعلّم'), findsWidgets);
    expect(find.text('محرر الأكواد'), findsOneWidget);
    expect(find.text('مستكشف الصياغة'), findsOneWidget);
    expect(find.text('مساحة العمل'), findsOneWidget);
    expect(find.text('الشارات'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);

    await tester.tap(find.text('الشارات'));
    await tester.pumpAndSettle();
    expect(find.byType(BadgesScreen), findsOneWidget);

    await dependencies.appSettingsProvider.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learning path'), findsOneWidget);
    expect(find.text('Code editor'), findsOneWidget);
    expect(find.text('Syntax explorer'), findsOneWidget);
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Badges'), findsNWidgets(2));
    expect(find.text('Settings'), findsOneWidget);

    GoRouter.of(tester.element(find.byType(AcademyAppLayout))).go('/settings');
    await tester.pumpAndSettle();
    expect(find.byType(AcademyAppLayout), findsOneWidget);
    await tester.tap(find.text('Appearance and language').first);
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);

    GoRouter.of(
      tester.element(find.byType(AcademyAppLayout)),
    ).go('/diagnostics/engine');
    await tester.pumpAndSettle();
    expect(find.byType(EngineDiagnosticsScreen), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SidebarItem &&
            widget.route == '/settings' &&
            widget.isActive,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'settings follow current language and persist appearance choices',
    (tester) async {
      final dependencies = await AppDependencies.create(
        databaseHelper: DatabaseHelper(inMemory: true),
        assetBundle: _TestAssetBundle(),
      );
      addTearDown(dependencies.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      await dependencies.appSettingsProvider.completeOnboarding();

      await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/settings');
      await tester.pumpAndSettle();

      expect(find.byType(AppNavigationBar), findsOneWidget);
      expect(find.text('حجم خط المحرر'), findsOneWidget);
      await tester.tap(find.text('المظهر واللغة'));
      await tester.pumpAndSettle();
      expect(find.text('اللغة'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<Locale>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الإنجليزية').last);
      await tester.pumpAndSettle();

      expect(dependencies.appSettingsProvider.locale, const Locale('en'));
      expect(find.text('Appearance and language'), findsNWidgets(2));
      expect(find.text('Language'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      expect(dependencies.appSettingsProvider.themeMode, ThemeMode.dark);
      expect(
        await dependencies.services<SettingsRepository>().load(),
        isA<AppSettings>()
            .having((settings) => settings.locale, 'locale', const Locale('en'))
            .having(
              (settings) => settings.themeMode,
              'theme mode',
              ThemeMode.dark,
            ),
      );
    },
  );

  testWidgets('opens engine diagnostics from settings and direct route', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TestAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/diagnostics/engine');
    await tester.pumpAndSettle();
    expect(find.byType(EngineDiagnosticsScreen), findsOneWidget);
    expect(
      tester
          .widget<AppNavigationBar>(find.byType(AppNavigationBar))
          .selectedRoute,
      '/settings',
    );
    expect(find.text('Godot v4.3.stable.official'), findsNothing);

    await tester.tap(find.text('الإعدادات').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('المحرك'));
    await tester.pumpAndSettle();
    expect(find.text('تشخيصات محرك GDScript'), findsOneWidget);
    await tester.tap(find.text('تشخيصات محرك GDScript'));
    await tester.pumpAndSettle();
    expect(find.byType(EngineDiagnosticsScreen), findsOneWidget);
  });

  testWidgets('experienced onboarding starts at the chosen unit', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TwoUnitAssetBundle(),
    );
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مبرمج قادم من لغات أخرى (Python, JS, C#)'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('متابعة إلى الاختبار التشخيصي السريع (3 أسئلة) ↵'),
    );
    await tester.tap(
      find.text('متابعة إلى الاختبار التشخيصي السريع (3 أسئلة) ↵'),
    );
    await tester.pumpAndSettle();

    for (final question in [
      ('var player_speed: float = 300.0', 'السؤال التالي ↵'),
      ('_physics_process(delta: float)', 'السؤال التالي ↵'),
      (
        'يعمل كحالة افتراضية (Wildcard Fallback) لأي قيمة غير متطابقة',
        'إنهاء التقييم واقتراح الخطة ↵',
      ),
    ]) {
      await tester.ensureVisible(find.text(question.$1));
      await tester.tap(find.text(question.$1));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(question.$2));
      await tester.tap(find.text(question.$2));
      await tester.pumpAndSettle();
    }

    await tester.ensureVisible(
      find.text('انتقل إلى مسار التعلّم وابدأ الدرس الأول ↵'),
    );
    await tester.tap(find.text('انتقل إلى مسار التعلّم وابدأ الدرس الأول ↵'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      dependencies.progressProvider.progress?.currentUnitId,
      'unit_03_locked',
    );
    expect(
      dependencies.progressProvider.progress?.currentLessonId,
      'lesson_03_locked',
    );

    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/path');
    await tester.pump();
    expect(find.byType(Shimmer), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(
        const ValueKey('learning_path_module_title_unit_02_variables'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('learning_path_module_title_unit_03_locked')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('learning_path_lesson_lesson_03_locked')),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('learning_path_lesson_lesson_03_locked')),
    );
    await tester.tap(
      find.byKey(const ValueKey('learning_path_lesson_lesson_03_locked')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(LessonScreen), findsOneWidget);
  });

  testWidgets('onboarding assessment cannot advance without an answer', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TestAssetBundle(),
    );
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('متابعة إلى الاختبار التشخيصي السريع (3 أسئلة) ↵'),
    );
    await tester.tap(
      find.text('متابعة إلى الاختبار التشخيصي السريع (3 أسئلة) ↵'),
    );
    await tester.pumpAndSettle();

    final nextButton = find.widgetWithText(ElevatedButton, 'السؤال التالي ↵');
    expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNull);
    expect(
      find.text(
        'ما هي الطريقة الصحيحة للإعلان عن متغير رقمي صارم (Strict Typing) في GDScript 2.0؟',
      ),
      findsOneWidget,
    );
  });

  testWidgets('dashboard playground runs code through the shared service', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TwoUnitAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final runButton = find.byTooltip('تشغيل الكود (F5)');
    await tester.ensureVisible(runButton);
    await tester.tap(runButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('اللاعب بصحة جيدة! ❤️'), findsOneWidget);
  });

  testWidgets('dashboard playground saves its draft locally', (tester) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TwoUnitAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    const draft = 'print("saved dashboard draft")';
    final editor = find.byType(TextField).last;
    await tester.ensureVisible(editor);
    await tester.enterText(editor, draft);
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      await dependencies.services<HomeDashboardRepository>().loadPlaygroundCode(
        dependencies.homeDashboardProvider.visitorId,
      ),
      draft,
    );
  });

  testWidgets('home dashboard fits narrow and wide English layouts', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TwoUnitAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('مرحباً بعودتك، متعلّم 👋'), findsOneWidget);
    final arabicLayoutException = tester.takeException();
    expect(
      arabicLayoutException,
      isNull,
      reason: arabicLayoutException?.toString(),
    );

    await dependencies.appSettingsProvider.setLocale(const Locale('en'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Welcome back, Learner 👋'), findsOneWidget);
    expect(find.text('Curriculum map'), findsOneWidget);
    final layoutException = tester.takeException();
    if (layoutException is FlutterError) {
      fail(layoutException.toStringDeep());
    }
    expect(layoutException, isNull, reason: layoutException?.toString());

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('locale controls direction and preserves code direction', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TestAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(Scaffold).first)),
      TextDirection.rtl,
    );

    await dependencies.appSettingsProvider.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold).first)),
      TextDirection.ltr,
    );

    final code = CodeDirectionality(
      child: Builder(
        builder: (context) => Text(Directionality.of(context).name),
      ),
    );
    await tester.pumpWidget(MaterialApp(home: code));
    expect(find.text('ltr'), findsOneWidget);
  });

  testWidgets('supports static and validated lesson routes', (tester) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TestAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/lesson/intro_1');
    await tester.pumpAndSettle();
    expect(find.text('تعذّر تحميل الدرس.'), findsOneWidget);

    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/lesson/../bad');
    await tester.pumpAndSettle();
    expect(find.text('الصفحة غير موجودة'), findsOneWidget);
  });

  testWidgets('workspace search shows localized empty-query controls', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TestAssetBundle(),
    );
    addTearDown(dependencies.dispose);
    await dependencies.appSettingsProvider.completeOnboarding();

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/workspace/search');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('البحث في مساحة العمل'), findsNWidgets(2));
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.labelText,
      'أدخل نصاً للبحث في ملفات GDScript المفهرسة',
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  test('persists settings through repository recreation', () async {
    final database = DatabaseHelper(inMemory: true);
    await database.database;
    final settings = SettingsRepository(database);
    await settings.save(
      AppSettings(
        locale: Locale('en'),
        themeMode: ThemeMode.dark,
        themeVariant: AppThemeVariant.arabicIde,
      ),
    );
    final restored = await SettingsRepository(database).load();
    expect(restored.locale, const Locale('en'));
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.themeVariant, AppThemeVariant.arabicIde);
    expect(restored.editorFontSize, 14);
    expect(restored.hasCompletedOnboarding, isFalse);
    await database.close();
  });

  test('localization catalog exposes both generated locales', () {
    expect(
      AppLocalizations.supportedLocales,
      containsAll([const Locale('ar'), const Locale('en')]),
    );
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  static const _manifest = '''
    {"version":"1","targetGDScriptVersion":"4","units":[]}
  ''';

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(_manifest));
    return ByteData.sublistView(bytes);
  }
}

class _TwoUnitAssetBundle extends CachingAssetBundle {
  static const _manifest = '''
      {
        "version": "1",
        "targetGDScriptVersion": "4",
        "units": [
          {
            "id": "unit_01_intro",
            "title": {"ar": "المقدمة", "en": "Introduction"},
            "description": {"ar": "الوحدة الأولى", "en": "First unit"},
            "iconName": "school",
            "order": 0,
            "lessonIds": ["lesson_01_intro"]
          },
          {
            "id": "unit_02_variables",
            "title": {"ar": "المتغيرات", "en": "Variables"},
            "description": {"ar": "الوحدة الثانية", "en": "Second unit"},
            "iconName": "code",
            "order": 1,
            "lessonIds": ["lesson_02_next"]
          },
          {
            "id": "unit_03_locked",
            "title": {"ar": "الوحدة الثالثة", "en": "Third unit"},
            "description": {"ar": "وحدة لاحقة", "en": "Later unit"},
            "iconName": "code",
            "order": 2,
            "lessonIds": ["lesson_03_locked"]
          }
        ]
      }
    ''';

  @override
  Future<ByteData> load(String key) async {
    final source = switch (key.split('/').last) {
      'lesson_01_intro.json' => _lesson(
        id: 'lesson_01_intro',
        unitId: 'unit_01_intro',
        title: 'المقدمة',
      ),
      'lesson_02_next.json' => _lesson(
        id: 'lesson_02_next',
        unitId: 'unit_02_variables',
        title: 'الدرس التالي',
      ),
      'lesson_03_locked.json' => _lesson(
        id: 'lesson_03_locked',
        unitId: 'unit_03_locked',
        title: 'درس مقفل',
      ),
      _ => _manifest,
    };
    final bytes = Uint8List.fromList(utf8.encode(source));
    return ByteData.sublistView(bytes);
  }

  static String _lesson({
    required String id,
    required String unitId,
    required String title,
  }) => jsonEncode({
    'id': id,
    'unitId': unitId,
    'title': {'ar': title, 'en': title},
    'objective': {'ar': 'تعلم الأساسيات', 'en': 'Learn the basics'},
    'estimatedMinutes': 5,
    'order': 0,
    'contentMarkdown': {'ar': 'محتوى تجريبي', 'en': 'Test content'},
    'exercises': [],
  });
}
