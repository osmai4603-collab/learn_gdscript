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
import 'package:learn_gdscript/data/repositories/settings_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/ui/layouts/academy_app_layout.dart';
import 'package:learn_gdscript/ui/layouts/app_shell_sidebar.dart';
import 'package:learn_gdscript/ui/screens/gamification/badges_screen.dart';
import 'package:learn_gdscript/ui/widgets/common/navigation_bar.dart';
import 'package:learn_gdscript/ui/widgets/code_directionality.dart';

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

    expect(find.text('هل سبق لك البرمجة؟'), findsOneWidget);
    await tester.tap(find.text('أنا جديد تماماً'));
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(
      find.text('ستُضاف المواد التعليمية في مرحلة لاحقة.'),
      findsOneWidget,
    );
    await tester.tap(find.text('الإعدادات'));
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
    expect(find.text('Badges'), findsNWidgets(3));
    expect(find.text('Settings'), findsOneWidget);

    GoRouter.of(tester.element(find.byType(AcademyAppLayout))).go('/settings');
    await tester.pumpAndSettle();
    expect(find.byType(AcademyAppLayout), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('experienced onboarding starts at the chosen unit', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create(
      databaseHelper: DatabaseHelper(inMemory: true),
      assetBundle: _TwoUnitAssetBundle(),
    );
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(LearnGdscriptApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أعرف أساسيات البرمجة'));
    await tester.pumpAndSettle();

    expect(
      dependencies.progressProvider.progress?.currentUnitId,
      'unit_02_variables',
    );
    expect(find.text('المتغيرات · next'), findsOneWidget);

    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/path');
    await tester.pumpAndSettle();
    expect(find.text('المتغيرات'), findsOneWidget);
    expect(find.text('مقفل'), findsOneWidget);
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

  testWidgets('workspace search requires an active language server', (
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
    await tester.pumpAndSettle();

    expect(find.text('نص'), findsOneWidget);
    expect(find.text('رموز'), findsOneWidget);
    expect(find.text('أدخل نصاً أو رمزاً للبحث'), findsOneWidget);
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
    final bytes = Uint8List.fromList(utf8.encode(_manifest));
    return ByteData.sublistView(bytes);
  }
}
