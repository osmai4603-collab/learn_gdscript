import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/app_constants.dart';
import 'data/repositories/curriculum_repository.dart';
import 'data/repositories/concept_map_repository.dart';
import 'data/repositories/home_dashboard_repository.dart';
import 'data/repositories/onboarding_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/review_schedule_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/syntax_reference_repository.dart';
import 'data/repositories/workspace_repository.dart';
import 'data/sqlite/database_helper.dart';
import 'logic/providers/app_settings_provider.dart';
import 'logic/providers/curriculum_provider.dart';
import 'logic/providers/concept_map_provider.dart';
import 'logic/providers/exercise_provider.dart';
import 'logic/providers/home_dashboard_provider.dart';
import 'logic/providers/learning_path_provider.dart';
import 'logic/providers/lesson_provider.dart';
import 'logic/providers/onboarding_provider.dart';
import 'logic/providers/progress_provider.dart';
import 'logic/services/code_runner_service.dart';
import 'logic/services/hint_service.dart';
import 'logic/services/test_runner_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.services,
    required this.appSettingsProvider,
    required this.curriculumProvider,
    required this.lessonProvider,
    required this.onboardingProvider,
    required this.exerciseProvider,
    required this.progressProvider,
    required this.homeDashboardProvider,
    required this.learningPathProvider,
    required this.conceptMapProvider,
  });

  final GetIt services;
  final AppSettingsProvider appSettingsProvider;
  final CurriculumProvider curriculumProvider;
  final LessonProvider lessonProvider;
  final OnboardingProvider onboardingProvider;
  final ExerciseProvider exerciseProvider;
  final ProgressProvider progressProvider;
  final HomeDashboardProvider homeDashboardProvider;
  final LearningPathProvider learningPathProvider;
  final ConceptMapProvider conceptMapProvider;
  bool _disposed = false;

  static Future<AppDependencies> create({
    DatabaseHelper? databaseHelper,
    AssetBundle? assetBundle,
  }) async {
    final services = GetIt.asNewInstance();
    final database = databaseHelper ?? DatabaseHelper();
    services.registerSingleton<DatabaseHelper>(
      database,
      dispose: (helper) => helper.close(),
    );

    try {
      await database.database;
      final settingsRepository = SettingsRepository(database);
      final curriculumRepository = CurriculumRepository(
        assetBundle: assetBundle ?? rootBundle,
        manifestAsset: AppConstants.curriculumManifestAsset,
      );
      final syntaxReferenceRepository = AssetSyntaxReferenceRepository(
        assetBundle: assetBundle ?? rootBundle,
      );
      final conceptMapRepository = ConceptMapRepository(
        assetBundle: assetBundle ?? rootBundle,
      );
      services.registerSingleton(settingsRepository);
      services.registerSingleton(OnboardingRepository(database));
      services.registerSingleton(HomeDashboardRepository(database));
      services.registerSingleton(ProgressRepository(database));
      services.registerSingleton(ReviewScheduleRepository(database));
      services.registerSingleton(WorkspaceRepository(database));
      services.registerSingleton(curriculumRepository);
      services.registerSingleton(conceptMapRepository);
      services.registerSingleton<SyntaxReferenceRepository>(
        syntaxReferenceRepository,
      );

      final codeRunner = CodeRunnerService();
      services.registerSingleton<CodeRunnerService>(
        codeRunner,
        dispose: (runner) => runner.dispose(),
      );
      services.registerSingleton(TestRunnerService(codeRunner));
      services.registerSingleton(const HintService());

      final settings = await settingsRepository.load();
      final appSettingsProvider = AppSettingsProvider(
        repository: settingsRepository,
        initialSettings: settings,
      );
      final curriculumProvider = CurriculumProvider(curriculumRepository);
      await curriculumProvider.load();
      final progressProvider = ProgressProvider(services<ProgressRepository>());
      final onboardingProvider = OnboardingProvider(
        services<OnboardingRepository>(),
      );
      await onboardingProvider.load(AppConstants.visitorId);
      await progressProvider.load(AppConstants.visitorId);
      final curriculum = curriculumProvider.state.value;
      if (progressProvider.progress == null && curriculum?.units.isNotEmpty == true) {
        final firstUnit = curriculum!.units.first;
        if (firstUnit.lessonIds.isNotEmpty) {
          await progressProvider.initialize(
            visitorId: AppConstants.visitorId,
            unitId: firstUnit.id,
            lessonId: firstUnit.lessonIds.first,
          );
        }
      }
      final homeDashboardProvider = HomeDashboardProvider(
        repository: services<HomeDashboardRepository>(),
        curriculumRepository: curriculumRepository,
        curriculumProvider: curriculumProvider,
        progressProvider: progressProvider,
      );
      final learningPathProvider = LearningPathProvider(
        curriculumRepository: curriculumRepository,
        curriculumProvider: curriculumProvider,
        progressProvider: progressProvider,
      );
      final conceptMapProvider = ConceptMapProvider(
        conceptMapRepository: conceptMapRepository,
        reviewScheduleRepository: services<ReviewScheduleRepository>(),
        curriculumProvider: curriculumProvider,
        progressProvider: progressProvider,
        visitorId: AppConstants.visitorId,
      );

      return AppDependencies._(
        services: services,
        appSettingsProvider: appSettingsProvider,
        curriculumProvider: curriculumProvider,
        lessonProvider: LessonProvider(curriculumRepository),
        onboardingProvider: onboardingProvider,
        exerciseProvider: ExerciseProvider(),
        progressProvider: progressProvider,
        homeDashboardProvider: homeDashboardProvider,
        learningPathProvider: learningPathProvider,
        conceptMapProvider: conceptMapProvider,
      );
    } on Object {
      await services.reset();
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    homeDashboardProvider.dispose();
    learningPathProvider.dispose();
    conceptMapProvider.dispose();
    appSettingsProvider.dispose();
    curriculumProvider.dispose();
    lessonProvider.dispose();
    onboardingProvider.dispose();
    exerciseProvider.dispose();
    progressProvider.dispose();
    await services.reset();
  }
}
