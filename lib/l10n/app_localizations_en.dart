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
  String get learningPathTitle => 'Learning path';

  @override
  String get learningPathEmpty => 'Learning content will be added in a later phase.';

  @override
  String get workspaceTitle => 'Workspace';

  @override
  String get workspaceDescription => 'Local language-server processes are supported on desktop platforms only.';

  @override
  String get settingsTitle => 'Settings';

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
  String get lspStatus => 'Language Server Status';

  @override
  String get lspConnected => 'Connected';

  @override
  String get lspDisconnected => 'Disconnected';

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
  String get lspExecutablePath => 'Language server executable path (optional)';

  @override
  String get connectLsp => 'Connect and index';

  @override
  String get disconnectLsp => 'Disconnect';

  @override
  String indexedFiles(Object count) {
    return '$count files indexed';
  }

  @override
  String get lspConnectionError => 'Could not connect to the language server.';

  @override
  String get completeCode => 'Complete';

  @override
  String get formatCode => 'Format';

  @override
  String get lspFeatureError => 'The language server feature failed.';

  @override
  String diagnosticLine(Object line) {
    return 'Line $line';
  }

  @override
  String get workspaceSearchTitle => 'Search workspace';

  @override
  String get workspaceSearchPlaceholder => 'Enter text or a symbol';

  @override
  String get searchWorkspaceText => 'Text';

  @override
  String get searchWorkspaceSymbols => 'Symbols';

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
}
