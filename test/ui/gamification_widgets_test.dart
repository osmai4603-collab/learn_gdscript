import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/repositories/settings_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/logic/providers/app_settings_provider.dart';
import 'package:learn_gdscript/logic/providers/curriculum_provider.dart';
import 'package:learn_gdscript/logic/providers/progress_provider.dart';
import 'package:learn_gdscript/ui/widgets/gamification/badges_grid_widget.dart';
import 'package:learn_gdscript/ui/widgets/gamification/streak_badge_widget.dart';
import 'package:learn_gdscript/ui/widgets/gamification/xp_level_header.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('XP, streak visibility, and badge grid reflect provider state', (
    tester,
  ) async {
    final helper = DatabaseHelper(inMemory: true);
    final settingsRepository = SettingsRepository(helper);
    final settingsProvider = AppSettingsProvider(
      repository: settingsRepository,
      initialSettings: await settingsRepository.load(),
    );
    final progressProvider = ProgressProvider(ProgressRepository(helper));
    await progressProvider.initialize(
      visitorId: 'visitor',
      unitId: 'unit',
      lessonId: 'lesson',
    );
    final initialized = progressProvider.progress!;
    await progressProvider.save(
      UserProgress(
        visitorId: initialized.visitorId,
        currentUnitId: initialized.currentUnitId,
        currentLessonId: initialized.currentLessonId,
        totalXP: 145,
        currentStreak: 3,
        longestStreak: 3,
        lastActiveDate: DateTime.now(),
        lessonsProgress: const {},
        earnedBadges: const [],
      ),
    );
    final curriculumProvider = CurriculumProvider(
      CurriculumRepository(assetBundle: rootBundle),
    );
    addTearDown(() async {
      settingsProvider.dispose();
      progressProvider.dispose();
      curriculumProvider.dispose();
      await helper.close();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider<ProgressProvider>.value(
            value: progressProvider,
          ),
          ChangeNotifierProvider<CurriculumProvider>.value(
            value: curriculumProvider,
          ),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: ListView(
              children: [
                XpLevelHeader(),
                StreakBadgeWidget(),
                BadgesGridWidget(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('145 XP'), findsOneWidget);
    expect(find.text('3 day streak'), findsOneWidget);
    expect(find.text('Badges'), findsOneWidget);

    await settingsProvider.setShowStreakInUi(false);
    await tester.pumpAndSettle();
    expect(find.text('3 day streak'), findsNothing);

    await helper.close();
  });
}
