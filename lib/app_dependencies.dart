import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/app_constants.dart';
import 'data/repositories/curriculum_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/syntax_reference_repository.dart';
import 'data/repositories/workspace_repository.dart';
import 'data/sqlite/database_helper.dart';
import 'logic/providers/app_settings_provider.dart';
import 'logic/providers/curriculum_provider.dart';
import 'logic/providers/exercise_provider.dart';
import 'logic/providers/language_server_provider.dart';
import 'logic/providers/lesson_provider.dart';
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
    required this.languageServerProvider,
    required this.exerciseProvider,
    required this.progressProvider,
  });

  final GetIt services;
  final AppSettingsProvider appSettingsProvider;
  final CurriculumProvider curriculumProvider;
  final LessonProvider lessonProvider;
  final LanguageServerProvider languageServerProvider;
  final ExerciseProvider exerciseProvider;
  final ProgressProvider progressProvider;
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
      services.registerSingleton(settingsRepository);
      services.registerSingleton(ProgressRepository(database));
      services.registerSingleton(WorkspaceRepository(database));
      services.registerSingleton(curriculumRepository);
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
      final languageServerProvider = LanguageServerProvider(
        workspaceRepository: services<WorkspaceRepository>(),
      );
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

      return AppDependencies._(
        services: services,
        appSettingsProvider: appSettingsProvider,
        curriculumProvider: curriculumProvider,
        lessonProvider: LessonProvider(curriculumRepository),
        languageServerProvider: languageServerProvider,
        exerciseProvider: ExerciseProvider(),
        progressProvider: progressProvider,
      );
    } on Object {
      await services.reset();
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    appSettingsProvider.dispose();
    curriculumProvider.dispose();
    lessonProvider.dispose();
    exerciseProvider.dispose();
    progressProvider.dispose();
    try {
      await languageServerProvider.disconnect();
    } finally {
      languageServerProvider.dispose();
      await services.reset();
    }
  }
}
