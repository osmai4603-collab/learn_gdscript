import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_dependencies.dart';
import 'core/theme/theme_data.dart';
import 'data/repositories/syntax_reference_repository.dart';
import 'l10n/app_localizations.dart';
import 'logic/providers/app_settings_provider.dart';
import 'logic/providers/curriculum_provider.dart';
import 'logic/providers/exercise_provider.dart';
import 'logic/providers/language_server_provider.dart';
import 'logic/providers/lesson_provider.dart';
import 'logic/providers/progress_provider.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/learning_path/learning_path_screen.dart';
import 'ui/screens/lesson/lesson_complete_screen.dart';
import 'ui/screens/lesson/lesson_screen.dart';
import 'ui/screens/not_found_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/syntax_reference/syntax_reference_screen.dart';
import 'ui/screens/workspace/workspace_screen.dart';
import 'ui/screens/workspace/workspace_search_screen.dart';

class LearnGdscriptApp extends StatefulWidget {
  const LearnGdscriptApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<LearnGdscriptApp> createState() => _LearnGdscriptAppState();
}

class _LearnGdscriptAppState extends State<LearnGdscriptApp> {
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
        ChangeNotifierProvider<LanguageServerProvider>.value(
          value: dependencies.languageServerProvider,
        ),
        ChangeNotifierProvider<ExerciseProvider>.value(
          value: dependencies.exerciseProvider,
        ),
        ChangeNotifierProvider<ProgressProvider>.value(
          value: dependencies.progressProvider,
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: settings.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          initialRoute: settings.settings.hasCompletedOnboarding
              ? '/'
              : '/onboarding',
          onGenerateRoute: _route,
          onUnknownRoute: (_) =>
              MaterialPageRoute<void>(builder: (_) => const NotFoundScreen()),
        ),
      ),
    );
  }

  Route<void> _route(RouteSettings routeSettings) {
    final name = routeSettings.name ?? '/';
    final screen = switch (name) {
      '/' => const HomeScreen(),
      '/path' => const LearningPathScreen(),
      '/settings' => const SettingsScreen(),
      '/syntax-reference' => SyntaxReferenceScreen(
        repository: widget.dependencies.services<SyntaxReferenceRepository>(),
      ),
      '/onboarding' => const OnboardingScreen(),
      '/workspace' => const WorkspaceScreen(),
      '/workspace/search' => const WorkspaceSearchScreen(),
      _ when name.startsWith('/lesson/') => _lessonScreen(name),
      _ when name.startsWith('/lesson-complete/') =>
        _lessonCompleteScreen(name, routeSettings.arguments),
      _ => const NotFoundScreen(),
    };
    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (_) => screen,
    );
  }

  Widget _lessonCompleteScreen(String route, Object? arguments) {
    final id = route.substring('/lesson-complete/'.length);
    if (id.isEmpty || !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(id)) {
      return const NotFoundScreen();
    }
    final values = arguments is Map<String, Object?>
        ? arguments
        : const <String, Object?>{};
    final badgeIds = values['newlyUnlockedBadges'];
    return LessonCompleteScreen(
      lessonId: id,
      earnedXP: values['earnedXP'] is int ? values['earnedXP']! as int : 0,
      hintsUsedCount: values['hintsUsedCount'] is int
          ? values['hintsUsedCount']! as int
          : 0,
      timeSpentMinutes: values['timeSpentMinutes'] is int
          ? values['timeSpentMinutes']! as int
          : 0,
      newlyUnlockedBadges: badgeIds is List<String> ? badgeIds : const [],
    );
  }

  Widget _lessonScreen(String route) {
    final id = route.substring('/lesson/'.length);
    if (id.isEmpty || !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(id)) {
      return const NotFoundScreen();
    }
    return LessonScreen(lessonId: id);
  }

  @override
  void dispose() {
    unawaited(widget.dependencies.dispose());
    super.dispose();
  }
}
