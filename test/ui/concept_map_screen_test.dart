import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/data/models/async_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:learn_gdscript/data/models/progress_models.dart';
import 'package:learn_gdscript/data/models/review_schedule.dart';
import 'package:learn_gdscript/data/repositories/concept_map_repository.dart';
import 'package:learn_gdscript/data/repositories/curriculum_repository.dart';
import 'package:learn_gdscript/data/repositories/progress_repository.dart';
import 'package:learn_gdscript/data/repositories/review_schedule_repository.dart';
import 'package:learn_gdscript/data/sqlite/database_helper.dart';
import 'package:learn_gdscript/logic/providers/concept_map_provider.dart';
import 'package:learn_gdscript/logic/providers/curriculum_provider.dart';
import 'package:learn_gdscript/logic/providers/progress_provider.dart';
import 'package:learn_gdscript/ui/screens/concept_map/concept_map_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads translated concept map, reviews a card, and persists it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await _ConceptMapHarness.create();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      harness.dispose();
    });
    await tester.pumpWidget(harness.app(locale: const Locale('en')));

    expect(find.byType(Shimmer), findsOneWidget);
    await _pumpUntilLoaded(tester, harness.provider);
    expect(find.text('Concept Map & Spaced Repetition'), findsOneWidget);
    expect(harness.provider.state.value!.allCards, hasLength(510));
    expect(harness.provider.state.value!.dueCards, isNotEmpty);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(harness.app(locale: const Locale('ar')));
    await tester.pump();
    expect(find.text('خريطة المفاهيم والتكرار المتباعد'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpWidget(harness.app(locale: const Locale('en')));
    await tester.pump();

    final dueCount = harness.provider.state.value!.dueCards.length;
    await tester.tap(find.text('Start review ($dueCount)'));
    await tester.pump();
    await tester.tap(find.text('Reveal answer'));
    await tester.pump();
    await tester.tap(find.text('Good'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final ratedCardId = harness.provider.state.value!.schedules.keys.single;
    expect(
      harness.provider.state.value!.schedules[ratedCardId]?.lastRating,
      Sm2Rating.good,
    );
    expect(
      (await harness.scheduleRepository.loadSchedules(
        _ConceptMapHarness.visitorId,
      ))[ratedCardId]?.repetitionCount,
      1,
    );
    await tester.tap(find.text('Back to map'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The Editor and Your First Program').first);
    await tester.pumpAndSettle();
    expect(find.text('Opened lesson_01_hello'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpUntilLoaded(
  WidgetTester tester,
  ConceptMapProvider provider,
) async {
  for (var frame = 0; frame < 20; frame++) {
    if (provider.state.value != null ||
        provider.state.status == LoadStatus.error) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(provider.state.status, LoadStatus.data);
  await tester.pump();
}

class _ConceptMapHarness {
  _ConceptMapHarness({
    required this.database,
    required this.curriculumProvider,
    required this.progressProvider,
    required this.provider,
    required this.scheduleRepository,
    required this.router,
  });

  static const visitorId = 'concept-map-widget-visitor';

  final DatabaseHelper database;
  final CurriculumProvider curriculumProvider;
  final ProgressProvider progressProvider;
  final ConceptMapProvider provider;
  final ReviewScheduleRepository scheduleRepository;
  final GoRouter router;

  static Future<_ConceptMapHarness> create() async {
    final database = DatabaseHelper(inMemory: true);
    final progressRepository = ProgressRepository(database);
    await progressRepository.save(
      UserProgress(
        visitorId: visitorId,
        currentUnitId: 'unit_01_first_program',
        currentLessonId: 'lesson_01_hello',
        totalXP: 20,
        currentStreak: 2,
        longestStreak: 2,
        lastActiveDate: DateTime.utc(2026, 10, 25),
        lessonsProgress: {
          'lesson_01_hello': LessonProgress(
            lessonId: 'lesson_01_hello',
            status: LessonStatus.completed,
          ),
        },
        earnedBadges: const [],
      ),
    );
    final curriculumProvider = CurriculumProvider(
      CurriculumRepository(assetBundle: rootBundle),
    );
    await curriculumProvider.load();
    final progressProvider = ProgressProvider(progressRepository);
    await progressProvider.load(visitorId);
    final scheduleRepository = ReviewScheduleRepository(database);
    final provider = ConceptMapProvider(
      conceptMapRepository: ConceptMapRepository(assetBundle: rootBundle),
      reviewScheduleRepository: scheduleRepository,
      curriculumProvider: curriculumProvider,
      progressProvider: progressProvider,
      visitorId: visitorId,
      clock: () => DateTime.utc(2026, 10, 25, 9),
    );
    final router = GoRouter(
      initialLocation: '/concept-map',
      routes: [
        GoRoute(
          path: '/concept-map',
          builder: (_, _) => const ConceptMapScreen(),
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (_, state) => Scaffold(
            body: Text('Opened ${state.pathParameters['lessonId']}'),
          ),
        ),
      ],
    );
    return _ConceptMapHarness(
      database: database,
      curriculumProvider: curriculumProvider,
      progressProvider: progressProvider,
      provider: provider,
      scheduleRepository: scheduleRepository,
      router: router,
    );
  }

  Widget app({required Locale locale}) => MultiProvider(
    providers: [
      ChangeNotifierProvider<ConceptMapProvider>.value(value: provider),
    ],
    child: MaterialApp.router(
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: router,
    ),
  );

  void dispose() {
    router.dispose();
    provider.dispose();
    curriculumProvider.dispose();
    progressProvider.dispose();
  }
}
