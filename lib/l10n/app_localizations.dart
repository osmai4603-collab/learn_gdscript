import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn GDScript'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Learn GDScript step by step'**
  String get homeWelcome;

  /// No description provided for @learningPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning path'**
  String get learningPathTitle;

  /// No description provided for @learningPathEmpty.
  ///
  /// In en, this message translates to:
  /// **'Learning content will be added in a later phase.'**
  String get learningPathEmpty;

  /// No description provided for @workspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspaceTitle;

  /// No description provided for @workspaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Local language-server processes are supported on desktop platforms only.'**
  String get workspaceDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a learning path and continue at your own pace.'**
  String get onboardingDescription;

  /// No description provided for @lessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lessonTitle;

  /// No description provided for @lessonMissing.
  ///
  /// In en, this message translates to:
  /// **'The requested lesson could not be found.'**
  String get lessonMissing;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeLabel;

  /// No description provided for @themeVariantLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeVariantLabel;

  /// No description provided for @themeAcademy.
  ///
  /// In en, this message translates to:
  /// **'Godot Developer Academy'**
  String get themeAcademy;

  /// No description provided for @themeArabicIde.
  ///
  /// In en, this message translates to:
  /// **'Godot Arabic IDE & Academy'**
  String get themeArabicIde;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @saveSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Settings could not be saved. Your previous choice was restored.'**
  String get saveSettingsError;

  /// No description provided for @navigateHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigateHome;

  /// No description provided for @navigatePath.
  ///
  /// In en, this message translates to:
  /// **'Learning path'**
  String get navigatePath;

  /// No description provided for @navigateCodeEditor.
  ///
  /// In en, this message translates to:
  /// **'Code editor'**
  String get navigateCodeEditor;

  /// No description provided for @navigateWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get navigateWorkspace;

  /// No description provided for @navigateSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigateSettings;

  /// No description provided for @navigateOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get navigateOnboarding;

  /// No description provided for @onboardingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Have you programmed before?'**
  String get onboardingQuestion;

  /// No description provided for @onboardingNewbie.
  ///
  /// In en, this message translates to:
  /// **'I\'m completely new'**
  String get onboardingNewbie;

  /// No description provided for @onboardingExperienced.
  ///
  /// In en, this message translates to:
  /// **'I know programming basics'**
  String get onboardingExperienced;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @quickTry.
  ///
  /// In en, this message translates to:
  /// **'Quick Try'**
  String get quickTry;

  /// No description provided for @runCode.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get runCode;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetCode;

  /// No description provided for @showHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get showHint;

  /// No description provided for @showSolution.
  ///
  /// In en, this message translates to:
  /// **'Show Solution'**
  String get showSolution;

  /// No description provided for @nextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next Lesson'**
  String get nextLesson;

  /// No description provided for @previousLesson.
  ///
  /// In en, this message translates to:
  /// **'Previous Lesson'**
  String get previousLesson;

  /// No description provided for @exercisePrompt.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercisePrompt;

  /// No description provided for @outputLabel.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get outputLabel;

  /// No description provided for @outputEmpty.
  ///
  /// In en, this message translates to:
  /// **'Press Run to see output'**
  String get outputEmpty;

  /// No description provided for @outputRunning.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get outputRunning;

  /// No description provided for @testResults.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get testResults;

  /// No description provided for @testPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get testPassed;

  /// No description provided for @testFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get testFailed;

  /// No description provided for @lessonComplete.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get lessonComplete;

  /// No description provided for @completedLesson.
  ///
  /// In en, this message translates to:
  /// **'Completed lesson \"{name}\"'**
  String completedLesson(Object name);

  /// No description provided for @exercisesSolved.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises solved'**
  String exercisesSolved(Object count);

  /// No description provided for @hintsUsed.
  ///
  /// In en, this message translates to:
  /// **'{count} hints used'**
  String hintsUsed(Object count);

  /// No description provided for @timeSpent.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String timeSpent(Object minutes);

  /// No description provided for @backToPath.
  ///
  /// In en, this message translates to:
  /// **'Back to Path'**
  String get backToPath;

  /// No description provided for @unitLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get unitLocked;

  /// No description provided for @unitInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get unitInProgress;

  /// No description provided for @unitCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get unitCompleted;

  /// No description provided for @editorFontSize.
  ///
  /// In en, this message translates to:
  /// **'Editor Font Size'**
  String get editorFontSize;

  /// No description provided for @fontSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSmall;

  /// No description provided for @fontMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontMedium;

  /// No description provided for @fontLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontLarge;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @resetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? All your progress will be deleted.'**
  String get resetConfirmation;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @lspStatus.
  ///
  /// In en, this message translates to:
  /// **'Language Server Status'**
  String get lspStatus;

  /// No description provided for @lspConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get lspConnected;

  /// No description provided for @lspDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get lspDisconnected;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearning;

  /// No description provided for @newUserWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Start your programming journey'**
  String get newUserWelcome;

  /// No description provided for @returningWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get returningWelcome;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noLessons.
  ///
  /// In en, this message translates to:
  /// **'There are no lessons in this unit.'**
  String get noLessons;

  /// No description provided for @runExample.
  ///
  /// In en, this message translates to:
  /// **'Run Example'**
  String get runExample;

  /// No description provided for @exampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get exampleLabel;

  /// No description provided for @exerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String exerciseProgress(Object current, Object total);

  /// No description provided for @nextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next Exercise'**
  String get nextExercise;

  /// No description provided for @runTests.
  ///
  /// In en, this message translates to:
  /// **'Check solution'**
  String get runTests;

  /// No description provided for @allTestsPassed.
  ///
  /// In en, this message translates to:
  /// **'Well done! All tests passed'**
  String get allTestsPassed;

  /// No description provided for @testSummary.
  ///
  /// In en, this message translates to:
  /// **'{passed} of {total} passed'**
  String testSummary(Object passed, Object total);

  /// No description provided for @resetCodeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Reset code to its starting point?'**
  String get resetCodeConfirmation;

  /// No description provided for @hintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'There are no more hints.'**
  String get hintUnavailable;

  /// No description provided for @lessonUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The lesson could not be loaded.'**
  String get lessonUnavailable;

  /// No description provided for @lessonProgress.
  ///
  /// In en, this message translates to:
  /// **'Lesson progress'**
  String get lessonProgress;

  /// No description provided for @quickTryCode.
  ///
  /// In en, this message translates to:
  /// **'print(\"Hello!\")'**
  String get quickTryCode;

  /// No description provided for @workspaceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Workspace features are not available yet.'**
  String get workspaceUnavailable;

  /// No description provided for @executionFailed.
  ///
  /// In en, this message translates to:
  /// **'The code could not be run.'**
  String get executionFailed;

  /// No description provided for @expectedOutput.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get expectedOutput;

  /// No description provided for @actualOutput.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actualOutput;

  /// No description provided for @errorLine.
  ///
  /// In en, this message translates to:
  /// **'Error on line {line}'**
  String errorLine(Object line);

  /// No description provided for @workspacePath.
  ///
  /// In en, this message translates to:
  /// **'Project directory path'**
  String get workspacePath;

  /// No description provided for @lspExecutablePath.
  ///
  /// In en, this message translates to:
  /// **'Language server executable path (optional)'**
  String get lspExecutablePath;

  /// No description provided for @connectLsp.
  ///
  /// In en, this message translates to:
  /// **'Connect and index'**
  String get connectLsp;

  /// No description provided for @disconnectLsp.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectLsp;

  /// No description provided for @indexedFiles.
  ///
  /// In en, this message translates to:
  /// **'{count} files indexed'**
  String indexedFiles(Object count);

  /// No description provided for @lspConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the language server.'**
  String get lspConnectionError;

  /// No description provided for @completeCode.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeCode;

  /// No description provided for @formatCode.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get formatCode;

  /// No description provided for @lspFeatureError.
  ///
  /// In en, this message translates to:
  /// **'The language server feature failed.'**
  String get lspFeatureError;

  /// No description provided for @diagnosticLine.
  ///
  /// In en, this message translates to:
  /// **'Line {line}'**
  String diagnosticLine(Object line);

  /// No description provided for @workspaceSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search workspace'**
  String get workspaceSearchTitle;

  /// No description provided for @workspaceSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter text or a symbol'**
  String get workspaceSearchPlaceholder;

  /// No description provided for @searchWorkspaceText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get searchWorkspaceText;

  /// No description provided for @searchWorkspaceSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get searchWorkspaceSymbols;

  /// No description provided for @workspaceSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get workspaceSearchEmpty;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(Object level);

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String totalXp(Object xp);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streakDays(Object count);

  /// No description provided for @streakInfo.
  ///
  /// In en, this message translates to:
  /// **'Learn at least once each day to keep your streak. Missing a day resets the current streak but never removes your XP or badges.'**
  String get streakInfo;

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @badgeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'New badge unlocked!'**
  String get badgeUnlocked;

  /// No description provided for @badgeLocked.
  ///
  /// In en, this message translates to:
  /// **'Not yet earned'**
  String get badgeLocked;

  /// No description provided for @badgeProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {target}'**
  String badgeProgress(Object current, Object target);

  /// No description provided for @earnedOn.
  ///
  /// In en, this message translates to:
  /// **'Earned {date}'**
  String earnedOn(Object date);

  /// No description provided for @xpAwarded.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP earned'**
  String xpAwarded(Object xp);

  /// No description provided for @showStreak.
  ///
  /// In en, this message translates to:
  /// **'Show daily streak'**
  String get showStreak;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @syntaxExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Syntax explorer'**
  String get syntaxExplorerTitle;

  /// No description provided for @syntaxExplorerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search keywords, syntax, and examples'**
  String get syntaxExplorerPlaceholder;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
