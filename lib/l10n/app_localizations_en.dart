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

  @override
  String workspaceIndexedFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count indexed files',
      one: '1 indexed file',
      zero: '0 indexed files',
    );
    return '$_temp0';
  }

  @override
  String workspaceFileCountSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
      zero: '0 files',
    );
    return '$_temp0';
  }

  @override
  String get workspaceSettings => 'Workspace settings';

  @override
  String get workspaceReindex => 'Reindex';

  @override
  String get workspaceEngineReady => 'GDScript engine ready';

  @override
  String get workspaceEngineUnavailable => 'GDScript engine unavailable';

  @override
  String get workspaceFilesTab => 'Files';

  @override
  String get workspaceSearchTab => 'Search';

  @override
  String get workspaceSearchProjectFiles => 'Search project files';

  @override
  String get workspaceSearchFiles => 'Search files';

  @override
  String get workspaceMatchingFiles => 'Matching files';

  @override
  String get workspaceSaveFile => 'Save file';

  @override
  String get workspaceFileInfoTitle => 'File information';

  @override
  String get workspaceNoFileOpen => 'No file is open';

  @override
  String workspaceFileLinesCount(int count) {
    return 'Lines: $count';
  }

  @override
  String workspaceFileSizeCharacters(int count) {
    return 'Size: $count characters';
  }

  @override
  String get workspaceOutputTab => 'Output';

  @override
  String get workspaceProblemsTab => 'Problems';

  @override
  String get workspaceCopyOutput => 'Copy output';

  @override
  String get workspaceClearOutput => 'Clear output';

  @override
  String get workspaceEngineStatusReady => 'Ready';

  @override
  String get workspaceEngineStatusUnavailable => 'Unavailable';

  @override
  String get workspaceExecutionRunning => 'Running...';

  @override
  String get workspaceEmptyOutput => 'No output yet. Run the script to see results.';

  @override
  String get workspaceNoProblems => 'No problems detected in the open file.';

  @override
  String get workspaceSearchFilterPlaceholder => 'Search for a file or script...';

  @override
  String get workspaceEngineUnavailableNotice => 'GDScript 2.0 • engine unavailable';

  @override
  String workspaceStatusBarCoordinates(int line, int column) {
    return 'Line $line, column $column';
  }

  @override
  String get workspaceUnsavedChangesWarning => 'This file has unsaved changes. Close it and discard them?';

  @override
  String get workspaceDirectInspectAction => 'Direct in-process analysis and editing';

  @override
  String get conceptMapHeroTitle => 'Concept Map & SM-2 Spaced Repetition';

  @override
  String get conceptMapHeroSubtitle => 'Track your progress through the knowledge tree and strengthen memory with spaced repetition.';

  @override
  String get conceptMapQuickReviewSession => 'Quick Review Session';

  @override
  String conceptMapRecallRate(int rate) {
    return 'Recall: $rate%';
  }

  @override
  String conceptMapDueCardsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due today',
      one: '1 card due today',
      zero: 'No cards due today',
    );
    return '$_temp0';
  }

  @override
  String get conceptMapStartReviewAction => 'Start review now';

  @override
  String get conceptMapBackToMap => 'Back to map';

  @override
  String get conceptMapDueTodayBadge => 'Due today';

  @override
  String conceptMapRemainingCards(int count) {
    return 'Remaining cards: $count';
  }

  @override
  String get conceptMapSm2RatingAgain => 'Again';

  @override
  String get conceptMapSm2RatingHard => 'Hard';

  @override
  String get conceptMapSm2RatingGood => 'Good';

  @override
  String get conceptMapSm2RatingEasy => 'Easy';

  @override
  String get conceptMapRevealAnswer => 'Reveal answer';

  @override
  String get conceptMapOverviewHeading => 'Concept overview:';

  @override
  String get conceptMapCodeExampleHeading => 'Code example:';

  @override
  String get conceptMapStatusHeading => 'Concept status';

  @override
  String conceptMapLastReviewedDate(String date) {
    return 'Last reviewed: $date';
  }

  @override
  String get conceptMasteryLocked => 'Locked';

  @override
  String get conceptMasteryLearning => 'Learning';

  @override
  String get conceptMasteryReviewing => 'Reviewing';

  @override
  String get conceptMasteryMastered => 'Mastered';

  @override
  String get conceptMapEmptyState => 'No concepts are available yet.';

  @override
  String get conceptMapRetryAction => 'Retry';

  @override
  String get settingsSavedSuccessToast => 'All preferences saved successfully and synced with Godot 4.3 ✓';

  @override
  String get settingsPreferencesSections => 'Preference sections';

  @override
  String get settingsTabCodeEditor => 'Code editor & fonts';

  @override
  String get settingsTabLspEngine => 'LSP server & engine path';

  @override
  String get settingsTabAppearanceTheme => 'Appearance & visual theme';

  @override
  String get settingsTabAccountAcademic => 'Account & learning progress';

  @override
  String get settingsDesktopTitle => 'Desktop Settings & Engine Environment';

  @override
  String get settingsSaveShortcutAction => 'Save changes (Ctrl+S) ↵';

  @override
  String get settingsEditorPrefsTitle => 'GDScript Editor Preferences';

  @override
  String get settingsEditorPrefsSubtitle => 'Customize font size, tab spacing, and auto-completion behavior.';

  @override
  String settingsEditorFontSize(int size) {
    return 'Editor font size ($size px):';
  }

  @override
  String get settingsEditorFontSizeHint => 'Applied to the JetBrains Mono font dedicated to GDScript.';

  @override
  String get settingsEditorTabSize => 'Tab size:';

  @override
  String get settingsEditorTabSizeStandard => 'The official standard in GDScript 2.0 is 4 spaces.';

  @override
  String settingsTabSpacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spaces',
      one: '1 space',
    );
    return '$_temp0';
  }

  @override
  String get settingsTabSpacesRecommended => '4 spaces (Recommended)';

  @override
  String get settingsShowLineNumbersTitle => 'Show line numbers';

  @override
  String get settingsShowLineNumbersSubtitle => 'Display line numbers column for easier tracing and diagnostics.';

  @override
  String get settingsHighlightActiveLineTitle => 'Highlight active line';

  @override
  String get settingsHighlightActiveLineSubtitle => 'Highlight the background of the line where cursor is placed.';

  @override
  String get settingsAutoCloseBracketsTitle => 'Auto-close brackets and quotes';

  @override
  String get settingsAutoCloseBracketsSubtitle => 'Automatically complete parentheses, brackets, braces, and quotes as you type.';

  @override
  String get settingsLspSectionTitle => 'Language Server Protocol & Godot 4.3';

  @override
  String get settingsLspSectionSubtitle => 'Manage local connection bridge, engine paths, and JSON-RPC 2.0.';

  @override
  String get settingsOpenDiagnosticsLog => 'Open live diagnostics log ↵';

  @override
  String get settingsGodotExecutablePath => 'Godot executable path:';

  @override
  String get settingsLspPort => 'LSP connection port:';

  @override
  String get settingsStrictTypingTitle => 'Enforce strict typing warnings';

  @override
  String get settingsStrictTypingSubtitle => 'Raise instant warnings when dynamic Variant variables lack explicit type.';

  @override
  String get settingsAutoStartLspTitle => 'Automatically start LSP server on launch';

  @override
  String get settingsAutoStartLspSubtitle => 'Initialize and launch local bridge in background upon application start.';

  @override
  String get settingsAppearanceSectionTitle => 'Appearance & Visual Theme';

  @override
  String get settingsAppearanceSectionSubtitle => 'Customize color schemes to match official Godot editor interface.';

  @override
  String get settingsActiveThemeLabel => 'Active theme:';

  @override
  String get settingsDarkThemeGodotDesc => 'Dark theme with official Godot blue and dark grey tones #0F141B.';

  @override
  String get settingsArabicFontTitle => 'Arabic UI font:';

  @override
  String get settingsArabicFontSubtitle => 'High-clarity accredited font for technical software interfaces.';

  @override
  String get learningPathAcademyBrand => 'Godot Academy';

  @override
  String get learningPathCurriculumYear => '2025 Curriculum';

  @override
  String get learningPathCourseTab => 'Course Path';

  @override
  String get learningPathConceptMapTab => 'Concept Map';

  @override
  String get learningPathSmartReviewTab => 'Smart Review';

  @override
  String get learningPathNoLessonsYet => 'No lessons have been added to this path yet.';

  @override
  String get learningPathStageFundamentals => 'Fundamentals';

  @override
  String get learningPathStageJourneyStart => 'Start of the journey';

  @override
  String get learningPathStageLogicMaker => 'Logic Maker';

  @override
  String get learningPathStageNextPhase => 'Next phase';

  @override
  String get learningPathStageEngineExpert => 'Engine Expert';

  @override
  String get learningPathStageAdvancedPhase => 'Advanced phase';

  @override
  String get learningPathUnitStatusDone => 'Completed';

  @override
  String get learningPathUnitStatusCurrent => 'Current unit';

  @override
  String get learningPathUnitStatusLocked => 'Locked';

  @override
  String get learningPathCompletePrevious => 'Complete previous unit first';

  @override
  String get learningPathHideLessons => 'Hide lessons';

  @override
  String get learningPathShowLessonsAction => 'Show lessons';

  @override
  String get learningPathLessonStatusDone => 'Completed';

  @override
  String get learningPathLessonStatusCurrent => 'Current lesson';

  @override
  String get learningPathLessonStatusSoon => 'Coming soon';

  @override
  String get learningPathMasteryDashboard => 'Mastery Dashboard & Statistics';

  @override
  String get dashboardDailyChallengeTitle => 'Daily Speed Challenge';

  @override
  String dashboardChallengeParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count developers participated today',
      one: '1 developer participated today',
    );
    return '$_temp0';
  }

  @override
  String dashboardChallengeStartAction(int xp) {
    return 'Take challenge (+$xp XP)';
  }

  @override
  String get dashboardSmartReviewCardTitle => 'Smart Spaced Review (SM-2)';

  @override
  String dashboardSmartReviewCardBody(int count) {
    return 'You have $count concept cards due for review today to consolidate long-term memory.';
  }

  @override
  String dashboardSmartReviewRetention(int percent) {
    return 'Recall rate $percent%';
  }

  @override
  String dashboardSmartReviewDuration(int minutes) {
    return '~$minutes mins';
  }

  @override
  String get dashboardStartQuickReview => 'Start quick review session';

  @override
  String get dashboardCodingStatsTitle => 'Your Programming Statistics';

  @override
  String get dashboardViewBadgesAction => 'Badges ↵';

  @override
  String get dashboardStatsLinesWritten => 'GDScript lines written:';

  @override
  String dashboardStatsLinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatsChallengesPassed => 'Challenges completed:';

  @override
  String dashboardStatsChallengesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count challenges',
      one: '1 challenge',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatsBadgesEarned => 'Accredited badges earned:';

  @override
  String dashboardStatsBadgesRatio(int earned, int total) {
    return '$earned of $total badges';
  }

  @override
  String get calloutOfficialWarning => 'Official Warning';

  @override
  String get calloutBestPractice => 'Best Practice';

  @override
  String get calloutTechnicalNote => 'Technical Note';

  @override
  String get calloutGoldenRule => 'Golden Rule';

  @override
  String get lessonDocumentationHeader => 'Lesson documentation';

  @override
  String get lessonDocumentationSources => 'Sources';

  @override
  String get lessonDocumentationLicenseNotice => 'Based on Godot Engine Documentation, licensed under CC BY 3.0. This educational text is an independent adaptation and is not endorsed by Godot.';

  @override
  String get lessonSplitterDragTooltip => 'Drag to resize panes';

  @override
  String get reviewScreenTitle => 'Smart Review';

  @override
  String get reviewScreenTodayHeader => 'Today\'s Review';

  @override
  String reviewDueItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due items',
      one: '1 due item',
      zero: 'No due items',
    );
    return '$_temp0';
  }

  @override
  String get reviewEmptyStateMessage => 'No reviews due today. Check back later.';

  @override
  String reviewIntervalDays(int days) {
    return 'Interval: $days days';
  }

  @override
  String reviewLessonReference(String lessonId) {
    return 'Lesson: $lessonId';
  }

  @override
  String reviewCardUpdatedNotice(String title, String date) {
    return 'Updated $title → $date';
  }

  @override
  String get capstoneScreenTitle => 'Integrated Capstone Project';

  @override
  String get exerciseActionCheckAnswer => 'Check answer';

  @override
  String get exerciseActionRun => 'Run code';
}
