// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Learn GDScript';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeWelcome => 'Learn GDScript step by step';

  @override
  String dashboardDays(int days) {
    return '$days days';
  }

  @override
  String dashboardWelcomeBack(String name) {
    return 'Welcome back, $name 👋';
  }

  @override
  String get dashboardWelcomeMessage => 'You are one step away from mastering game branching. Keep writing code and controlling node behavior today!';

  @override
  String get dashboardCurrentUnit => 'Current unit:';

  @override
  String dashboardPercentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get dashboardNextLevel => 'Progress to next level';

  @override
  String dashboardLessonsCompleted(int completed, int total) {
    return '$completed of $total lessons';
  }

  @override
  String dashboardXpToNextLevel(int xp) {
    return '$xp XP to next level';
  }

  @override
  String get dashboardContinueDescription => 'Pick up where you left off. Your progress is saved automatically.';

  @override
  String get dashboardContinueAction => 'Continue learning';

  @override
  String get dashboardDraftAutoSaved => 'Last code draft saved automatically';

  @override
  String get dashboardCurriculumTitle => 'Curriculum map';

  @override
  String get dashboardCurriculumDescription => 'Track your progress from your first program to building game logic with GDScript.';

  @override
  String get dashboardViewFullPath => 'View complete learning path';

  @override
  String get dashboardRecentBadges => 'Recently earned badges';

  @override
  String dashboardBadgeCount(int earned, int total) {
    return '$earned of $total';
  }

  @override
  String get dashboardNoBadges => 'No badges yet';

  @override
  String get dashboardEarnBadges => 'Complete lessons to earn badges';

  @override
  String get dashboardStreak => 'Learning streak';

  @override
  String dashboardConsecutiveDays(int days) {
    return '$days consecutive days 🔥';
  }

  @override
  String get dashboardEngineTitle => 'GDScript engine';

  @override
  String get dashboardEngineConnecting => 'Connecting';

  @override
  String get dashboardEngineConnected => 'Connected';

  @override
  String get dashboardEngineDisconnected => 'Disconnected';

  @override
  String get dashboardWorkspace => 'Workspace';

  @override
  String get dashboardRuntime => 'GDScript runtime';

  @override
  String get dashboardLocal => 'Local';

  @override
  String get dashboardPlaygroundReset => 'Reset code';

  @override
  String get dashboardPlaygroundRun => 'Run code (F5)';

  @override
  String get dashboardPlaygroundRunning => 'Running';

  @override
  String get dashboardPlaygroundOutputTitle => 'Godot output console';

  @override
  String get dashboardPlaygroundOutputRunning => 'Running code...';

  @override
  String get dashboardPlaygroundOutputEmpty => 'Press Run code to see the result here.';

  @override
  String get dashboardPlaygroundOutputSuccess => 'Executed successfully with no output.';

  @override
  String dashboardSaveError(String error) {
    return 'Could not save the draft: $error';
  }

  @override
  String dashboardExecutionError(String error) {
    return 'Could not execute the code: $error';
  }

  @override
  String get dashboardExecutionFailed => 'Could not execute the code.';

  @override
  String get dashboardExampleTag => 'Example';

  @override
  String get learningPathTitle => 'Learning path';

  @override
  String get learningPathEmpty => 'Learning content will be added in a later phase.';

  @override
  String get learningPathHeading => 'Learning path and programming concept map';

  @override
  String get conceptMapAction => 'Concept map';

  @override
  String get smartReviewAction => 'Smart review';

  @override
  String curriculumVersion(String version) {
    return 'GDScript $version curriculum';
  }

  @override
  String completedUnitsSummary(int completed, int total) {
    return '$completed of $total units completed';
  }

  @override
  String completedLessonsSummary(int completed, int total) {
    return '$completed of $total lessons completed';
  }

  @override
  String get milestoneCompleted => 'Completed';

  @override
  String get milestoneCurrent => 'Current stage';

  @override
  String get milestoneUpcoming => 'Upcoming';

  @override
  String completedModulesCount(int count) {
    return '$count completed';
  }

  @override
  String upcomingModulesCount(int count) {
    return '$count remaining';
  }

  @override
  String moduleNumber(int number) {
    return 'Module $number';
  }

  @override
  String moduleLessonCount(int count) {
    return '$count lessons';
  }

  @override
  String moduleDurationHours(int hours) {
    return '$hours min total';
  }

  @override
  String get lessonStatusCurrent => 'Current lesson';

  @override
  String get lessonStatusCompleted => 'Completed';

  @override
  String get lessonStatusAvailable => 'Available';

  @override
  String get lessonStatusLocked => 'Locked';

  @override
  String get moduleDetails => 'Module details';

  @override
  String get showLessons => 'Show lessons';

  @override
  String get hideLessons => 'Hide lessons';

  @override
  String get masteryStatistics => 'Learning progress and statistics';

  @override
  String get progressByUnit => 'Progress by unit';

  @override
  String get achievementsTitle => 'Your achievements';

  @override
  String earnedBadgesSummary(int count) {
    return '$count badges earned';
  }

  @override
  String get reviewNextStep => 'Your next lesson';

  @override
  String get openReview => 'Open review';

  @override
  String get reviewTitle => 'Review';

  @override
  String get workspaceStatus => 'Workspace';

  @override
  String get workspaceReady => 'Ready to practice the lessons';

  @override
  String get openWorkspace => 'Open workspace';

  @override
  String get xpTotalLabel => 'Total XP';

  @override
  String get streakLabel => 'Daily streak';

  @override
  String get capstoneTitle => 'Capstone project';

  @override
  String get capstoneDescription => 'Put your GDScript skills into practice with a complete project.';

  @override
  String get workspaceTitle => 'Workspace';

  @override
  String get workspaceDescription => 'Select a local project directory to inspect and edit its GDScript files.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsReload => 'Reload settings';

  @override
  String get settingsLoadError => 'Settings could not be loaded. Please try again.';

  @override
  String get settingsResetProgressError => 'Progress could not be reset.';

  @override
  String get settingsCategories => 'Settings categories';

  @override
  String get settingsEditorCategory => 'Editor';

  @override
  String get settingsAppearanceCategory => 'Appearance and language';

  @override
  String get settingsEngineCategory => 'Engine';

  @override
  String get settingsAboutCategory => 'About and progress';

  @override
  String get settingsEditorDescription => 'Customize GDScript editor preferences.';

  @override
  String get settingsAppearanceDescription => 'Choose the display language, color theme, and appearance behavior.';

  @override
  String get settingsEngineDescription => 'GDScript engine diagnostics and development tools.';

  @override
  String get settingsAboutDescription => 'Application information and learning progress management.';

  @override
  String get settingsEditorFontDescription => 'The selected font size is applied to the code editor.';

  @override
  String get settingsLanguageDescription => 'The interface language updates as soon as it is selected.';

  @override
  String get settingsThemeModeDescription => 'Follow the system preference or choose a fixed appearance.';

  @override
  String get settingsThemeVariantDescription => 'Choose one of the color themes included in the app.';

  @override
  String get settingsStreakDescription => 'Show the learning streak throughout the app.';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get onboardingDescription => 'Choose a learning path and continue at your own pace.';

  @override
  String get lessonTitle => 'Lesson';

  @override
  String get lessonMissing => 'The requested lesson could not be found.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get backHome => 'Back to home';

  @override
  String get languageLabel => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get themeLabel => 'Appearance';

  @override
  String get themeVariantLabel => 'Theme';

  @override
  String get themeAcademy => 'Godot Developer Academy';

  @override
  String get themeArabicIde => 'Godot Arabic IDE & Academy';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get saveSettingsError => 'Settings could not be saved. Your previous choice was restored.';

  @override
  String get navigateHome => 'Home';

  @override
  String get navigatePath => 'Learning path';

  @override
  String get navigateCodeEditor => 'Code editor';

  @override
  String get navigateWorkspace => 'Workspace';

  @override
  String get navigateSettings => 'Settings';

  @override
  String get navigateOnboarding => 'Welcome';

  @override
  String get onboardingQuestion => 'Have you programmed before?';

  @override
  String get onboardingNewbie => 'I\'m completely new';

  @override
  String get onboardingExperienced => 'I know programming basics';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get quickTry => 'Quick Try';

  @override
  String get runCode => 'Run';

  @override
  String get resetCode => 'Reset';

  @override
  String get showHint => 'Hint';

  @override
  String get showSolution => 'Show Solution';

  @override
  String get nextLesson => 'Next Lesson';

  @override
  String get previousLesson => 'Previous Lesson';

  @override
  String get exercisePrompt => 'Exercise';

  @override
  String get outputLabel => 'Output';

  @override
  String get outputEmpty => 'Press Run to see output';

  @override
  String get outputRunning => 'Running...';

  @override
  String get testResults => 'Test Results';

  @override
  String get testPassed => 'Passed';

  @override
  String get testFailed => 'Failed';

  @override
  String get lessonComplete => 'Well done!';

  @override
  String completedLesson(Object name) {
    return 'Completed lesson \"$name\"';
  }

  @override
  String exercisesSolved(Object count) {
    return '$count exercises solved';
  }

  @override
  String hintsUsed(Object count) {
    return '$count hints used';
  }

  @override
  String timeSpent(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String currentStreakDays(int count) {
    return '$count-day learning streak';
  }

  @override
  String levelUpTo(int level) {
    return 'Level up to level $level';
  }

  @override
  String levelProgress(int progress) {
    return 'Progress to next level: $progress%';
  }

  @override
  String lessonCompleteDetailsError(String error) {
    return 'Some lesson completion details could not be loaded: $error';
  }

  @override
  String get backToPath => 'Back to Path';

  @override
  String get unitLocked => 'Locked';

  @override
  String get unitInProgress => 'In Progress';

  @override
  String get unitCompleted => 'Completed';

  @override
  String get editorFontSize => 'Editor Font Size';

  @override
  String get fontSmall => 'Small';

  @override
  String get fontMedium => 'Medium';

  @override
  String get fontLarge => 'Large';

  @override
  String get resetProgress => 'Reset Progress';

  @override
  String get resetConfirmation => 'Are you sure? All your progress will be deleted.';

  @override
  String get aboutApp => 'About';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get engineDiagnosticsTitle => 'GDScript engine diagnostics';

  @override
  String get engineDiagnosticsDescription => 'Review diagnostics from GDScript files in the selected workspace.';

  @override
  String get engineDiagnosticsEmpty => 'There are no diagnostics in the indexed workspace files.';

  @override
  String engineDiagnosticsSummary(int count) {
    return '$count diagnostics';
  }

  @override
  String get startLearning => 'Start Learning';

  @override
  String get newUserWelcome => 'Welcome! Start your programming journey';

  @override
  String get returningWelcome => 'Welcome back!';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noLessons => 'There are no lessons in this unit.';

  @override
  String get runExample => 'Run Example';

  @override
  String get exampleLabel => 'Example';

  @override
  String exerciseProgress(Object current, Object total) {
    return 'Exercise $current of $total';
  }

  @override
  String get nextExercise => 'Next Exercise';

  @override
  String get runTests => 'Check solution';

  @override
  String get allTestsPassed => 'Well done! All tests passed';

  @override
  String testSummary(Object passed, Object total) {
    return '$passed of $total passed';
  }

  @override
  String get resetCodeConfirmation => 'Reset code to its starting point?';

  @override
  String get hintUnavailable => 'There are no more hints.';

  @override
  String get lessonUnavailable => 'The lesson could not be loaded.';

  @override
  String get lessonProgress => 'Lesson progress';

  @override
  String get quickTryCode => 'print(\"Hello!\")';

  @override
  String get workspaceUnavailable => 'Workspace features are not available yet.';

  @override
  String get executionFailed => 'The code could not be run.';

  @override
  String get expectedOutput => 'Expected';

  @override
  String get actualOutput => 'Actual';

  @override
  String errorLine(Object line) {
    return 'Error on line $line';
  }

  @override
  String get workspacePath => 'Project directory path';

  @override
  String get completeCode => 'Complete';

  @override
  String diagnosticLine(Object line) {
    return 'Line $line';
  }

  @override
  String get workspaceSearchTitle => 'Search workspace';

  @override
  String get workspaceSearchPlaceholder => 'Enter text to search in indexed GDScript files';

  @override
  String get workspaceSearchEmpty => 'No results found.';

  @override
  String levelLabel(Object level) {
    return 'Level $level';
  }

  @override
  String totalXp(Object xp) {
    return '$xp XP';
  }

  @override
  String streakDays(Object count) {
    return '$count day streak';
  }

  @override
  String get streakInfo => 'Learn at least once each day to keep your streak. Missing a day resets the current streak but never removes your XP or badges.';

  @override
  String get badgesTitle => 'Badges';

  @override
  String badgesCompletionSummary(int unlocked, int total) {
    return '$unlocked of $total badges earned';
  }

  @override
  String badgeFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String badgeFilterEarned(int count) {
    return 'Earned ($count)';
  }

  @override
  String badgeFilterInProgress(int count) {
    return 'In progress ($count)';
  }

  @override
  String badgeFilterLocked(int count) {
    return 'Locked ($count)';
  }

  @override
  String get badgeFilterEmpty => 'No badges in this category.';

  @override
  String get badgeCatalogEmpty => 'No badges are available right now.';

  @override
  String get badgeDetailsTitle => 'Badge details';

  @override
  String get badgeEarnedStatus => 'Earned';

  @override
  String get badgeInProgressStatus => 'In progress';

  @override
  String get badgesLoadError => 'Could not load badges. Check your connection and try again.';

  @override
  String get badgeUnlocked => 'New badge unlocked!';

  @override
  String get badgeLocked => 'Not yet earned';

  @override
  String badgeProgress(Object current, Object target) {
    return '$current of $target';
  }

  @override
  String earnedOn(Object date) {
    return 'Earned $date';
  }

  @override
  String xpAwarded(Object xp) {
    return '+$xp XP earned';
  }

  @override
  String get showStreak => 'Show daily streak';

  @override
  String get great => 'Great!';

  @override
  String get syntaxExplorerTitle => 'Syntax explorer';

  @override
  String get syntaxExplorerPlaceholder => 'Search keywords, syntax, and examples';

  @override
  String get onboardingBrand => 'Godot Academy';

  @override
  String get onboardingPlacementLabel => 'Placement & Onboarding';

  @override
  String get onboardingSkip => 'Skip to home ↵';

  @override
  String get onboardingStepWelcome => 'Welcome';

  @override
  String get onboardingStepExperience => 'Experience';

  @override
  String get onboardingStepAssessment => 'Quick assessment';

  @override
  String get onboardingStepRoadmap => 'Your roadmap';

  @override
  String get onboardingWelcomeHeading => 'Welcome to Godot Developer Academy!';

  @override
  String get onboardingWelcomeBody => 'The first complete Arabic platform to master GDScript 2.0 and Godot 4.3 through hands-on practice, quality assessments, and applied projects.';

  @override
  String get onboardingWelcomeAction => 'Start your placement (2 minutes) ↵';

  @override
  String get onboardingExperiencePrompt => 'What is your current programming background?';

  @override
  String get onboardingExperienceDescription => 'We will tailor the curriculum pace and exercises to your experience.';

  @override
  String get onboardingTierBeginner => 'Completely new to programming';

  @override
  String get onboardingTierBeginnerDescription => 'I have never written code and want to start from scratch with variables and functions.';

  @override
  String get onboardingTierTransition => 'Programmer coming from another language (Python, JS, C#)';

  @override
  String get onboardingTierTransitionDescription => 'I understand programming basics and objects, and want to master GDScript 2.0 and Godot.';

  @override
  String get onboardingTierVeteran => 'Godot 3 developer moving to Godot 4';

  @override
  String get onboardingTierVeteranDescription => 'I have experience with Godot 3 and want to explore GDScript 2.0, static typing, and signals.';

  @override
  String get onboardingContinueAssessment => 'Continue to the quick diagnostic (3 questions) ↵';

  @override
  String onboardingQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get onboardingAssessmentTag => 'Academic placement';

  @override
  String get onboardingQuestionTyping => 'What is the correct way to declare a strictly typed numeric variable in GDScript 2.0?';

  @override
  String get onboardingCodeTyping => '# Choose the most efficient and compiler-safe syntax:';

  @override
  String get onboardingOptionTyping0 => 'var player_speed = 300.0';

  @override
  String get onboardingOptionTyping1 => 'var player_speed: float = 300.0';

  @override
  String get onboardingOptionTyping2 => 'float player_speed = 300.0;';

  @override
  String get onboardingOptionTyping3 => 'let player_speed: number = 300.0';

  @override
  String get onboardingQuestionPhysics => 'Which function handles movement synchronized with Godot\'s physics engine?';

  @override
  String get onboardingCodePhysics => 'func ???(delta: float) -> void:\\n    move_and_slide()';

  @override
  String get onboardingOptionPhysics0 => '_process(delta: float)';

  @override
  String get onboardingOptionPhysics1 => '_physics_process(delta: float)';

  @override
  String get onboardingOptionPhysics2 => '_fixed_update(delta: float)';

  @override
  String get onboardingOptionPhysics3 => '_integrate_forces(state: PhysicsDirectBodyState2D)';

  @override
  String get onboardingQuestionMatch => 'What role does the _ pattern play in a match statement in Godot 4.3?';

  @override
  String get onboardingCodeMatch => 'match player_state:\\n    \"IDLE\": velocity.x = 0.0\\n    _: handle_fallback()';

  @override
  String get onboardingOptionMatch0 => 'It ignores the rest of the code and stops execution';

  @override
  String get onboardingOptionMatch1 => 'It is a wildcard fallback for any unmatched value';

  @override
  String get onboardingOptionMatch2 => 'It declares a private unused variable';

  @override
  String get onboardingOptionMatch3 => 'It immediately raises an assertion error';

  @override
  String get onboardingPrevious => 'Previous';

  @override
  String get onboardingNextQuestion => 'Next question ↵';

  @override
  String get onboardingFinishAssessment => 'Finish assessment and suggest a plan ↵';

  @override
  String get onboardingRoadmapSuccess => 'Your personalized learning plan is ready!';

  @override
  String onboardingRecommendedStart(String unit) {
    return 'Recommended starting point: $unit';
  }

  @override
  String onboardingUnitLabel(String number) {
    return 'Unit $number';
  }

  @override
  String get onboardingSummaryBeginner => 'We will start with the fundamentals to build a strong foundation in programming and GDScript.';

  @override
  String get onboardingSummaryTransition => 'Based on your answers and programming background, we will start at the level best suited to accelerate your learning.';

  @override
  String get onboardingSummaryVeteran => 'We will focus on the concepts that help you move to GDScript 2.0 and Godot 4.';

  @override
  String get onboardingStartLearning => 'Go to the learning path and start your first lesson ↵';

  @override
  String get onboardingSaveError => 'Could not save onboarding progress. Please try again.';

  @override
  String get onboardingRestoreError => 'Could not restore your saved onboarding data.';

  @override
  String get syntaxCategoryAll => 'All';

  @override
  String get syntaxCategoryKeywords => 'Keywords';

  @override
  String get syntaxCategoryBuiltins => 'Built-ins';

  @override
  String get syntaxCategoryTypes => 'Types';

  @override
  String get syntaxExplorerLoadError => 'Could not load the syntax reference.';

  @override
  String get syntaxExplorerProgressError => 'Could not record syntax explorer usage.';

  @override
  String get syntaxExplorerPageDescription => 'Search GDScript keywords, built-ins, and types.';

  @override
  String get syntaxExplorerRetry => 'Try again';

  @override
  String get syntaxExplorerSearchHint => 'Search for a keyword, built-in, or data type...';

  @override
  String get syntaxExplorerSortAlphabetical => 'Sort: alphabetical';

  @override
  String get syntaxExplorerEntriesHeading => 'Entries';

  @override
  String syntaxExplorerCount(int count) {
    return '$count documented entries';
  }

  @override
  String syntaxExplorerVisibleCount(int visible, int total) {
    return 'Showing $visible of $total';
  }

  @override
  String get syntaxExplorerLoadMore => 'Load more';

  @override
  String get syntaxExplorerSelected => 'Selected';

  @override
  String get syntaxExplorerNoResults => 'No matching results.';

  @override
  String get syntaxExplorerSelectEntry => 'Select an entry to view its details.';

  @override
  String get syntaxExplorerSignature => 'Syntax';

  @override
  String get syntaxExplorerExample => 'Example';

  @override
  String get syntaxExplorerExplanation => 'Explanation';

  @override
  String get syntaxExplorerCopyEntry => 'Copy entry';

  @override
  String get syntaxExplorerCopyExample => 'Copy example';

  @override
  String syntaxExplorerCopied(String item) {
    return 'Copied $item';
  }

  @override
  String get syntaxExplorerOpenLesson => 'Open lesson';

  @override
  String get syntaxExplorerOpenWorkspace => 'Open workspace';

  @override
  String get syntaxExplorerRelatedConcepts => 'Related concepts';

  @override
  String get syntaxExplorerLessonUnavailable => 'No related lesson is available for this entry.';

  @override
  String get syntaxExplorerClearSearch => 'Clear search';
}
