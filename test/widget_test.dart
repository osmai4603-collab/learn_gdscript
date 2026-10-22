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
import 'package:learn_gdscript/app.dart';
import 'package:learn_gdscript/app_dependencies.dart';
import 'package:learn_gdscript/data/models/app_settings.dart';
import 'package:learn_gdscript/data/repositories/settings_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
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
    expect(find.text('ستُضاف المواد التعليمية في مرحلة لاحقة.'), findsOneWidget);
    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();
    expect(find.text('اللغة'), findsOneWidget);
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
    Navigator.of(
      tester.element(find.byType(Scaffold).first),
    ).pushNamed('/lesson/intro_1');
    await tester.pumpAndSettle();
    expect(find.text('تعذّر تحميل الدرس.'), findsOneWidget);

    Navigator.of(
      tester.element(find.byType(Scaffold).first),
    ).pushNamed('/lesson/../bad');
    await tester.pumpAndSettle();
    expect(find.text('الصفحة غير موجودة'), findsOneWidget);
  });

  test('persists settings through repository recreation', () async {
    final database = DatabaseHelper(inMemory: true);
    await database.database;
    final settings = SettingsRepository(database);
    await settings.save(
      AppSettings(locale: Locale('en'), themeMode: ThemeMode.dark),
    );
    final restored = await SettingsRepository(database).load();
    expect(restored.locale, const Locale('en'));
    expect(restored.themeMode, ThemeMode.dark);
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
