import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_dependencies.dart';
import '../../data/repositories/syntax_reference_repository.dart';
import '../../data/repositories/workspace_repository.dart';
import '../../logic/providers/app_settings_provider.dart';
import '../layouts/academy_app_layout.dart';
import '../layouts/app_shell_sidebar.dart';
import '../screens/capstone/capstone_screen.dart';
import '../screens/concept_map/concept_map_screen.dart';
import '../screens/gamification/badges_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/learning_path/learning_path_screen.dart';
import '../screens/lesson/lesson_complete_screen.dart';
import '../screens/lesson/lesson_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/review/review_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/engine_diagnostics_screen.dart';
import '../screens/syntax_reference/syntax_reference_screen.dart';
import '../screens/workspace/workspace_screen.dart';
import '../screens/workspace/workspace_search_screen.dart';
import 'app_routes.dart';
export 'app_routes.dart';

GoRouter createAppRouter({
  required AppDependencies dependencies,
  required AppSettingsProvider settings,
}) {
  return GoRouter(
    initialLocation: settings.settings.hasCompletedOnboarding
        ? AppRoutes.root
        : AppRoutes.onboarding,
    refreshListenable: settings,
    redirect: (context, state) {
      final onboardingComplete = settings.settings.hasCompletedOnboarding;
      if (!onboardingComplete &&
          state.matchedLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      if (onboardingComplete && state.matchedLocation == AppRoutes.onboarding) {
        return AppRoutes.root;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          if (MediaQuery.sizeOf(context).width < 840) return child;

          return AcademyAppLayout(
            body: child,
            navigation: AppShellSidebar(
              activeRoute: _activeNavigationRoute(state.uri.path),
              onNavigate: context.go,
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.root,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.learningPath,
            builder: (context, state) => const LearningPathScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.engineDiagnostics,
            builder: (context, state) => EngineDiagnosticsScreen(
              repository: dependencies.services<WorkspaceRepository>(),
            ),
          ),
          GoRoute(
            path: AppRoutes.syntaxReference,
            builder: (context, state) => SyntaxReferenceScreen(
              repository: dependencies.services<SyntaxReferenceRepository>(),
            ),
          ),
          GoRoute(
            path: AppRoutes.workspace,
            builder: (context, state) => WorkspaceScreen(
              repository: dependencies.services<WorkspaceRepository>(),
            ),
          ),
          GoRoute(
            path: AppRoutes.workspaceSearch,
            builder: (context, state) => WorkspaceSearchScreen(
              repository: dependencies.services<WorkspaceRepository>(),
            ),
          ),
          GoRoute(
            path: AppRoutes.badges,
            builder: (context, state) => const BadgesScreen(),
          ),
          GoRoute(
            path: AppRoutes.review,
            builder: (context, state) => const ReviewScreen(),
          ),
          GoRoute(
            path: AppRoutes.conceptMap,
            builder: (context, state) => const ConceptMapScreen(),
          ),
          GoRoute(
            path: AppRoutes.capstone,
            builder: (context, state) => const CapstoneProjectScreen(),
          ),
          GoRoute(
            path: AppRoutes.lesson,
            builder: (context, state) {
              final lessonId = state.pathParameters['lessonId']!;
              if (!_isValidId(lessonId)) return const NotFoundScreen();
              return LessonScreen(lessonId: lessonId);
            },
          ),
          GoRoute(
            path: AppRoutes.lessonComplete,
            builder: (context, state) {
              final lessonId = state.pathParameters['lessonId']!;
              if (!_isValidId(lessonId)) return const NotFoundScreen();
              final values = state.extra;
              final arguments = values is Map<String, Object?>
                  ? values
                  : const <String, Object?>{};
              final badgeIds = arguments['newlyUnlockedBadges'];
              return LessonCompleteScreen(
                lessonId: lessonId,
                earnedXP: arguments['earnedXP'] is int
                    ? arguments['earnedXP']! as int
                    : 0,
                hintsUsedCount: arguments['hintsUsedCount'] is int
                    ? arguments['hintsUsedCount']! as int
                    : 0,
                timeSpentMinutes: arguments['timeSpentMinutes'] is int
                    ? arguments['timeSpentMinutes']! as int
                    : 0,
                newlyUnlockedBadges: badgeIds is List<String>
                    ? badgeIds
                    : const [],
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}

bool _isValidId(String id) => RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(id);

String _activeNavigationRoute(String path) {
  if (path == AppRoutes.root) return AppRoutes.root;
  if (path == AppRoutes.settings || path == AppRoutes.engineDiagnostics) {
    return AppRoutes.settings;
  }
  if (path == AppRoutes.learningPath || path.startsWith('/lesson')) {
    return AppRoutes.learningPath;
  }
  if (path == AppRoutes.workspace) return AppRoutes.workspace;
  if (path == AppRoutes.workspaceSearch) return AppRoutes.workspaceSearch;
  if (path == AppRoutes.syntaxReference) return AppRoutes.syntaxReference;
  if (path == AppRoutes.badges) return AppRoutes.badges;
  return '';
}
