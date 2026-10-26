import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/core/theme/blue_theme.dart';
import 'package:learn_gdscript/core/theme/godot_arabic_ide_theme.dart';
import 'package:provider/provider.dart';

import 'app_dependencies.dart';
import 'core/theme/theme_data.dart';
import 'data/models/app_settings.dart';
import 'l10n/app_localizations.dart';
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
import 'logic/services/test_runner_service.dart';
import 'ui/routers/app_router.dart';

class LearnGdscriptApp extends StatefulWidget {
  const LearnGdscriptApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<LearnGdscriptApp> createState() => _LearnGdscriptAppState();
}

class _LearnGdscriptAppState extends State<LearnGdscriptApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      dependencies: widget.dependencies,
      settings: widget.dependencies.appSettingsProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettingsProvider>.value(
          value: dependencies.appSettingsProvider,
        ),
        ChangeNotifierProvider<CurriculumProvider>.value(
          value: dependencies.curriculumProvider,
        ),
        ChangeNotifierProvider<LessonProvider>.value(
          value: dependencies.lessonProvider,
        ),
        ChangeNotifierProvider<OnboardingProvider>.value(
          value: dependencies.onboardingProvider,
        ),
        ChangeNotifierProvider<ExerciseProvider>.value(
          value: dependencies.exerciseProvider,
        ),
        ChangeNotifierProvider<ProgressProvider>.value(
          value: dependencies.progressProvider,
        ),
        ChangeNotifierProvider<HomeDashboardProvider>.value(
          value: dependencies.homeDashboardProvider,
        ),
        ChangeNotifierProvider<LearningPathProvider>.value(
          value: dependencies.learningPathProvider,
        ),
        ChangeNotifierProvider<ConceptMapProvider>.value(
          value: dependencies.conceptMapProvider,
        ),
        Provider<CodeRunnerService>.value(
          value: dependencies.services<CodeRunnerService>(),
        ),
        Provider<TestRunnerService>.value(
          value: dependencies.services<TestRunnerService>(),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: settings.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: settings.themeVariant == AppThemeVariant.arabicIde
              ? GodotArabicIdeTheme().light
              : BlueTheme().light,
          darkTheme: settings.themeVariant == AppThemeVariant.arabicIde
              ? GodotArabicIdeTheme().dark
              : BlueTheme().dark,
          themeMode: settings.themeMode,
          routerConfig: _router,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _router.dispose();
    unawaited(widget.dependencies.dispose());
    super.dispose();
  }
}
