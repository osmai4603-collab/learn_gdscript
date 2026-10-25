import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/logic/providers/curriculum_provider.dart';
import 'package:learn_gdscript/logic/providers/progress_provider.dart';
import 'package:learn_gdscript/ui/screens/gamification/badges_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows live badge counts, filters, and selected details', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    final fixture = await _createProviders();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_app(fixture));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1 of 10 badges earned'), findsOneWidget);
    expect(find.text('All (10)'), findsOneWidget);
    expect(find.text('Earned (1)'), findsOneWidget);
    expect(find.text('In progress (0)'), findsOneWidget);
    expect(find.text('Locked (9)'), findsOneWidget);
    expect(find.text('Badge details'), findsOneWidget);
    expect(find.text('First Line'), findsWidgets);

    await tester.tap(find.text('In progress (0)'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No badges in this category.'), findsOneWidget);

    await tester.tap(find.text('All (10)'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('First Line').first);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Badge details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(_BadgeProviders fixture) => MultiProvider(
  providers: [
    ChangeNotifierProvider<ProgressProvider>.value(value: fixture.progress),
    ChangeNotifierProvider<CurriculumProvider>.value(value: fixture.curriculum),
  ],
  child: MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: const BadgesScreen(),
  ),
);

Future<_BadgeProviders> _createProviders() async {
  final progress = ProgressProvider(_TestProgressRepository());
  final curriculum = CurriculumProvider(
    CurriculumRepository(assetBundle: rootBundle),
  );
  await curriculum.load();
  await progress.initialize(
    visitorId: 'visitor',
    unitId: 'unit_01',
    lessonId: 'lesson_01',
  );
  final initial = progress.progress!;
  await progress.save(
    UserProgress(
      visitorId: initial.visitorId,
      currentUnitId: initial.currentUnitId,
      currentLessonId: initial.currentLessonId,
      totalXP: 25,
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: DateTime(2026, 10, 25),
      lessonsProgress: const {},
      earnedBadges: const ['badge_first_line'],
      earnedBadgeDates: {'badge_first_line': DateTime(2026, 10, 20)},
      hasExecutedPrint: true,
    ),
  );
  return _BadgeProviders(progress: progress, curriculum: curriculum);
}

class _BadgeProviders {
  const _BadgeProviders({required this.progress, required this.curriculum});

  final ProgressProvider progress;
  final CurriculumProvider curriculum;

  void dispose() {
    progress.dispose();
    curriculum.dispose();
  }
}

class _TestProgressRepository extends ProgressRepository {
  _TestProgressRepository() : super(DatabaseHelper(inMemory: true));

  @override
  Future<UserProgress?> load(String visitorId) async => null;

  @override
  Future<void> save(UserProgress progress) async {}
}
