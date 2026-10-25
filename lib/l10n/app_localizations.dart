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

  /// No description provided for @dashboardDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String dashboardDays(int days);

  /// No description provided for @dashboardWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name} 👋'**
  String dashboardWelcomeBack(String name);

  /// No description provided for @dashboardWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'You are one step away from mastering game branching. Keep writing code and controlling node behavior today!'**
  String get dashboardWelcomeMessage;

  /// No description provided for @dashboardCurrentUnit.
  ///
  /// In en, this message translates to:
  /// **'Current unit:'**
  String get dashboardCurrentUnit;

  /// No description provided for @dashboardPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String dashboardPercentComplete(int percent);

  /// No description provided for @dashboardNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Progress to next level'**
  String get dashboardNextLevel;

  /// No description provided for @dashboardLessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} lessons'**
  String dashboardLessonsCompleted(int completed, int total);

  /// No description provided for @dashboardXpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to next level'**
  String dashboardXpToNextLevel(int xp);

  /// No description provided for @dashboardContinueDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off. Your progress is saved automatically.'**
  String get dashboardContinueDescription;

  /// No description provided for @dashboardContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get dashboardContinueAction;

  /// No description provided for @dashboardDraftAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Last code draft saved automatically'**
  String get dashboardDraftAutoSaved;

  /// No description provided for @dashboardCurriculumTitle.
  ///
  /// In en, this message translates to:
  /// **'Curriculum map'**
  String get dashboardCurriculumTitle;

  /// No description provided for @dashboardCurriculumDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your progress from your first program to building game logic with GDScript.'**
  String get dashboardCurriculumDescription;

  /// No description provided for @dashboardViewFullPath.
  ///
  /// In en, this message translates to:
  /// **'View complete learning path'**
  String get dashboardViewFullPath;

  /// No description provided for @dashboardRecentBadges.
  ///
  /// In en, this message translates to:
  /// **'Recently earned badges'**
  String get dashboardRecentBadges;

  /// No description provided for @dashboardBadgeCount.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total}'**
  String dashboardBadgeCount(int earned, int total);

  /// No description provided for @dashboardNoBadges.
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get dashboardNoBadges;

  /// No description provided for @dashboardEarnBadges.
  ///
  /// In en, this message translates to:
  /// **'Complete lessons to earn badges'**
  String get dashboardEarnBadges;

  /// No description provided for @dashboardStreak.
  ///
  /// In en, this message translates to:
  /// **'Learning streak'**
  String get dashboardStreak;

  /// No description provided for @dashboardConsecutiveDays.
  ///
  /// In en, this message translates to:
  /// **'{days} consecutive days 🔥'**
  String dashboardConsecutiveDays(int days);

  /// No description provided for @dashboardEngineTitle.
  ///
  /// In en, this message translates to:
  /// **'GDScript engine'**
  String get dashboardEngineTitle;

  /// No description provided for @dashboardEngineConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get dashboardEngineConnecting;

  /// No description provided for @dashboardEngineConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get dashboardEngineConnected;

  /// No description provided for @dashboardEngineDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get dashboardEngineDisconnected;

  /// No description provided for @dashboardWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get dashboardWorkspace;

  /// No description provided for @dashboardRuntime.
  ///
  /// In en, this message translates to:
  /// **'GDScript runtime'**
  String get dashboardRuntime;

  /// No description provided for @dashboardLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get dashboardLocal;

  /// No description provided for @dashboardPlaygroundReset.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get dashboardPlaygroundReset;

  /// No description provided for @dashboardPlaygroundRun.
  ///
  /// In en, this message translates to:
  /// **'Run code (F5)'**
  String get dashboardPlaygroundRun;

  /// No description provided for @dashboardPlaygroundRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get dashboardPlaygroundRunning;

  /// No description provided for @dashboardPlaygroundOutputTitle.
  ///
  /// In en, this message translates to:
  /// **'Godot output console'**
  String get dashboardPlaygroundOutputTitle;

  /// No description provided for @dashboardPlaygroundOutputRunning.
  ///
  /// In en, this message translates to:
  /// **'Running code...'**
  String get dashboardPlaygroundOutputRunning;

  /// No description provided for @dashboardPlaygroundOutputEmpty.
  ///
  /// In en, this message translates to:
  /// **'Press Run code to see the result here.'**
  String get dashboardPlaygroundOutputEmpty;

  /// No description provided for @dashboardPlaygroundOutputSuccess.
  ///
  /// In en, this message translates to:
  /// **'Executed successfully with no output.'**
  String get dashboardPlaygroundOutputSuccess;

  /// No description provided for @dashboardSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the draft: {error}'**
  String dashboardSaveError(String error);

  /// No description provided for @dashboardExecutionError.
  ///
  /// In en, this message translates to:
  /// **'Could not execute the code: {error}'**
  String dashboardExecutionError(String error);

  /// No description provided for @dashboardExecutionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not execute the code.'**
  String get dashboardExecutionFailed;

  /// No description provided for @dashboardExampleTag.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get dashboardExampleTag;

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

  /// No description provided for @learningPathHeading.
  ///
  /// In en, this message translates to:
  /// **'Learning path and programming concept map'**
  String get learningPathHeading;

  /// No description provided for @conceptMapAction.
  ///
  /// In en, this message translates to:
  /// **'Concept map'**
  String get conceptMapAction;

  /// No description provided for @smartReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Smart review'**
  String get smartReviewAction;

  /// No description provided for @curriculumVersion.
  ///
  /// In en, this message translates to:
  /// **'GDScript {version} curriculum'**
  String curriculumVersion(String version);

  /// No description provided for @completedUnitsSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} units completed'**
  String completedUnitsSummary(int completed, int total);

  /// No description provided for @completedLessonsSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} lessons completed'**
  String completedLessonsSummary(int completed, int total);

  /// No description provided for @milestoneCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get milestoneCompleted;

  /// No description provided for @milestoneCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current stage'**
  String get milestoneCurrent;

  /// No description provided for @milestoneUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get milestoneUpcoming;

  /// No description provided for @completedModulesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String completedModulesCount(int count);

  /// No description provided for @upcomingModulesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String upcomingModulesCount(int count);

  /// No description provided for @moduleNumber.
  ///
  /// In en, this message translates to:
  /// **'Module {number}'**
  String moduleNumber(int number);

  /// No description provided for @moduleLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String moduleLessonCount(int count);

  /// No description provided for @moduleDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} min total'**
  String moduleDurationHours(int hours);

  /// No description provided for @lessonStatusCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current lesson'**
  String get lessonStatusCurrent;

  /// No description provided for @lessonStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lessonStatusCompleted;

  /// No description provided for @lessonStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get lessonStatusAvailable;

  /// No description provided for @lessonStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lessonStatusLocked;

  /// No description provided for @moduleDetails.
  ///
  /// In en, this message translates to:
  /// **'Module details'**
  String get moduleDetails;

  /// No description provided for @showLessons.
  ///
  /// In en, this message translates to:
  /// **'Show lessons'**
  String get showLessons;

  /// No description provided for @hideLessons.
  ///
  /// In en, this message translates to:
  /// **'Hide lessons'**
  String get hideLessons;

  /// No description provided for @masteryStatistics.
  ///
  /// In en, this message translates to:
  /// **'Learning progress and statistics'**
  String get masteryStatistics;

  /// No description provided for @progressByUnit.
  ///
  /// In en, this message translates to:
  /// **'Progress by unit'**
  String get progressByUnit;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your achievements'**
  String get achievementsTitle;

  /// No description provided for @earnedBadgesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} badges earned'**
  String earnedBadgesSummary(int count);

  /// No description provided for @reviewNextStep.
  ///
  /// In en, this message translates to:
  /// **'Your next lesson'**
  String get reviewNextStep;

  /// No description provided for @openReview.
  ///
  /// In en, this message translates to:
  /// **'Open review'**
  String get openReview;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @workspaceStatus.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspaceStatus;

  /// No description provided for @workspaceReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to practice the lessons'**
  String get workspaceReady;

  /// No description provided for @openWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Open workspace'**
  String get openWorkspace;

  /// No description provided for @xpTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get xpTotalLabel;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily streak'**
  String get streakLabel;

  /// No description provided for @capstoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Capstone project'**
  String get capstoneTitle;

  /// No description provided for @capstoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Put your GDScript skills into practice with a complete project.'**
  String get capstoneDescription;

  /// No description provided for @workspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspaceTitle;

  /// No description provided for @workspaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a local project directory to inspect and edit its GDScript files.'**
  String get workspaceDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsReload.
  ///
  /// In en, this message translates to:
  /// **'Reload settings'**
  String get settingsReload;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Settings could not be loaded. Please try again.'**
  String get settingsLoadError;

  /// No description provided for @settingsResetProgressError.
  ///
  /// In en, this message translates to:
  /// **'Progress could not be reset.'**
  String get settingsResetProgressError;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Settings categories'**
  String get settingsCategories;

  /// No description provided for @settingsEditorCategory.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get settingsEditorCategory;

  /// No description provided for @settingsAppearanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Appearance and language'**
  String get settingsAppearanceCategory;

  /// No description provided for @settingsEngineCategory.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get settingsEngineCategory;

  /// No description provided for @settingsAboutCategory.
  ///
  /// In en, this message translates to:
  /// **'About and progress'**
  String get settingsAboutCategory;

  /// No description provided for @settingsEditorDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize GDScript editor preferences.'**
  String get settingsEditorDescription;

  /// No description provided for @settingsAppearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the display language, color theme, and appearance behavior.'**
  String get settingsAppearanceDescription;

  /// No description provided for @settingsEngineDescription.
  ///
  /// In en, this message translates to:
  /// **'GDScript engine diagnostics and development tools.'**
  String get settingsEngineDescription;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Application information and learning progress management.'**
  String get settingsAboutDescription;

  /// No description provided for @settingsEditorFontDescription.
  ///
  /// In en, this message translates to:
  /// **'The selected font size is applied to the code editor.'**
  String get settingsEditorFontDescription;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'The interface language updates as soon as it is selected.'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsThemeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the system preference or choose a fixed appearance.'**
  String get settingsThemeModeDescription;

  /// No description provided for @settingsThemeVariantDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose one of the color themes included in the app.'**
  String get settingsThemeVariantDescription;

  /// No description provided for @settingsStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Show the learning streak throughout the app.'**
  String get settingsStreakDescription;

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

  /// No description provided for @currentStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day learning streak'**
  String currentStreakDays(int count);

  /// No description provided for @levelUpTo.
  ///
  /// In en, this message translates to:
  /// **'Level up to level {level}'**
  String levelUpTo(int level);

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress to next level: {progress}%'**
  String levelProgress(int progress);

  /// No description provided for @lessonCompleteDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Some lesson completion details could not be loaded: {error}'**
  String lessonCompleteDetailsError(String error);

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

  /// No description provided for @engineDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'GDScript engine diagnostics'**
  String get engineDiagnosticsTitle;

  /// No description provided for @engineDiagnosticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Review diagnostics from GDScript files in the selected workspace.'**
  String get engineDiagnosticsDescription;

  /// No description provided for @engineDiagnosticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no diagnostics in the indexed workspace files.'**
  String get engineDiagnosticsEmpty;

  /// No description provided for @engineDiagnosticsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} diagnostics'**
  String engineDiagnosticsSummary(int count);

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

  /// No description provided for @completeCode.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeCode;

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
  /// **'Enter text to search in indexed GDScript files'**
  String get workspaceSearchPlaceholder;

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

  /// No description provided for @badgesCompletionSummary.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} badges earned'**
  String badgesCompletionSummary(int unlocked, int total);

  /// No description provided for @badgeFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String badgeFilterAll(int count);

  /// No description provided for @badgeFilterEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned ({count})'**
  String badgeFilterEarned(int count);

  /// No description provided for @badgeFilterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress ({count})'**
  String badgeFilterInProgress(int count);

  /// No description provided for @badgeFilterLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked ({count})'**
  String badgeFilterLocked(int count);

  /// No description provided for @badgeFilterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No badges in this category.'**
  String get badgeFilterEmpty;

  /// No description provided for @badgeCatalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No badges are available right now.'**
  String get badgeCatalogEmpty;

  /// No description provided for @badgeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Badge details'**
  String get badgeDetailsTitle;

  /// No description provided for @badgeEarnedStatus.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get badgeEarnedStatus;

  /// No description provided for @badgeInProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get badgeInProgressStatus;

  /// No description provided for @badgesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load badges. Check your connection and try again.'**
  String get badgesLoadError;

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

  /// No description provided for @onboardingBrand.
  ///
  /// In en, this message translates to:
  /// **'Godot Academy'**
  String get onboardingBrand;

  /// No description provided for @onboardingPlacementLabel.
  ///
  /// In en, this message translates to:
  /// **'Placement & Onboarding'**
  String get onboardingPlacementLabel;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip to home ↵'**
  String get onboardingSkip;

  /// No description provided for @onboardingStepWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingStepWelcome;

  /// No description provided for @onboardingStepExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get onboardingStepExperience;

  /// No description provided for @onboardingStepAssessment.
  ///
  /// In en, this message translates to:
  /// **'Quick assessment'**
  String get onboardingStepAssessment;

  /// No description provided for @onboardingStepRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Your roadmap'**
  String get onboardingStepRoadmap;

  /// No description provided for @onboardingWelcomeHeading.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Godot Developer Academy!'**
  String get onboardingWelcomeHeading;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'The first complete Arabic platform to master GDScript 2.0 and Godot 4.3 through hands-on practice, quality assessments, and applied projects.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingWelcomeAction.
  ///
  /// In en, this message translates to:
  /// **'Start your placement (2 minutes) ↵'**
  String get onboardingWelcomeAction;

  /// No description provided for @onboardingExperiencePrompt.
  ///
  /// In en, this message translates to:
  /// **'What is your current programming background?'**
  String get onboardingExperiencePrompt;

  /// No description provided for @onboardingExperienceDescription.
  ///
  /// In en, this message translates to:
  /// **'We will tailor the curriculum pace and exercises to your experience.'**
  String get onboardingExperienceDescription;

  /// No description provided for @onboardingTierBeginner.
  ///
  /// In en, this message translates to:
  /// **'Completely new to programming'**
  String get onboardingTierBeginner;

  /// No description provided for @onboardingTierBeginnerDescription.
  ///
  /// In en, this message translates to:
  /// **'I have never written code and want to start from scratch with variables and functions.'**
  String get onboardingTierBeginnerDescription;

  /// No description provided for @onboardingTierTransition.
  ///
  /// In en, this message translates to:
  /// **'Programmer coming from another language (Python, JS, C#)'**
  String get onboardingTierTransition;

  /// No description provided for @onboardingTierTransitionDescription.
  ///
  /// In en, this message translates to:
  /// **'I understand programming basics and objects, and want to master GDScript 2.0 and Godot.'**
  String get onboardingTierTransitionDescription;

  /// No description provided for @onboardingTierVeteran.
  ///
  /// In en, this message translates to:
  /// **'Godot 3 developer moving to Godot 4'**
  String get onboardingTierVeteran;

  /// No description provided for @onboardingTierVeteranDescription.
  ///
  /// In en, this message translates to:
  /// **'I have experience with Godot 3 and want to explore GDScript 2.0, static typing, and signals.'**
  String get onboardingTierVeteranDescription;

  /// No description provided for @onboardingContinueAssessment.
  ///
  /// In en, this message translates to:
  /// **'Continue to the quick diagnostic (3 questions) ↵'**
  String get onboardingContinueAssessment;

  /// No description provided for @onboardingQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String onboardingQuestionProgress(int current, int total);

  /// No description provided for @onboardingAssessmentTag.
  ///
  /// In en, this message translates to:
  /// **'Academic placement'**
  String get onboardingAssessmentTag;

  /// No description provided for @onboardingQuestionTyping.
  ///
  /// In en, this message translates to:
  /// **'What is the correct way to declare a strictly typed numeric variable in GDScript 2.0?'**
  String get onboardingQuestionTyping;

  /// No description provided for @onboardingCodeTyping.
  ///
  /// In en, this message translates to:
  /// **'# Choose the most efficient and compiler-safe syntax:'**
  String get onboardingCodeTyping;

  /// No description provided for @onboardingOptionTyping0.
  ///
  /// In en, this message translates to:
  /// **'var player_speed = 300.0'**
  String get onboardingOptionTyping0;

  /// No description provided for @onboardingOptionTyping1.
  ///
  /// In en, this message translates to:
  /// **'var player_speed: float = 300.0'**
  String get onboardingOptionTyping1;

  /// No description provided for @onboardingOptionTyping2.
  ///
  /// In en, this message translates to:
  /// **'float player_speed = 300.0;'**
  String get onboardingOptionTyping2;

  /// No description provided for @onboardingOptionTyping3.
  ///
  /// In en, this message translates to:
  /// **'let player_speed: number = 300.0'**
  String get onboardingOptionTyping3;

  /// No description provided for @onboardingQuestionPhysics.
  ///
  /// In en, this message translates to:
  /// **'Which function handles movement synchronized with Godot\'s physics engine?'**
  String get onboardingQuestionPhysics;

  /// No description provided for @onboardingCodePhysics.
  ///
  /// In en, this message translates to:
  /// **'func ???(delta: float) -> void:\\n    move_and_slide()'**
  String get onboardingCodePhysics;

  /// No description provided for @onboardingOptionPhysics0.
  ///
  /// In en, this message translates to:
  /// **'_process(delta: float)'**
  String get onboardingOptionPhysics0;

  /// No description provided for @onboardingOptionPhysics1.
  ///
  /// In en, this message translates to:
  /// **'_physics_process(delta: float)'**
  String get onboardingOptionPhysics1;

  /// No description provided for @onboardingOptionPhysics2.
  ///
  /// In en, this message translates to:
  /// **'_fixed_update(delta: float)'**
  String get onboardingOptionPhysics2;

  /// No description provided for @onboardingOptionPhysics3.
  ///
  /// In en, this message translates to:
  /// **'_integrate_forces(state: PhysicsDirectBodyState2D)'**
  String get onboardingOptionPhysics3;

  /// No description provided for @onboardingQuestionMatch.
  ///
  /// In en, this message translates to:
  /// **'What role does the _ pattern play in a match statement in Godot 4.3?'**
  String get onboardingQuestionMatch;

  /// No description provided for @onboardingCodeMatch.
  ///
  /// In en, this message translates to:
  /// **'match player_state:\\n    \"IDLE\": velocity.x = 0.0\\n    _: handle_fallback()'**
  String get onboardingCodeMatch;

  /// No description provided for @onboardingOptionMatch0.
  ///
  /// In en, this message translates to:
  /// **'It ignores the rest of the code and stops execution'**
  String get onboardingOptionMatch0;

  /// No description provided for @onboardingOptionMatch1.
  ///
  /// In en, this message translates to:
  /// **'It is a wildcard fallback for any unmatched value'**
  String get onboardingOptionMatch1;

  /// No description provided for @onboardingOptionMatch2.
  ///
  /// In en, this message translates to:
  /// **'It declares a private unused variable'**
  String get onboardingOptionMatch2;

  /// No description provided for @onboardingOptionMatch3.
  ///
  /// In en, this message translates to:
  /// **'It immediately raises an assertion error'**
  String get onboardingOptionMatch3;

  /// No description provided for @onboardingPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get onboardingPrevious;

  /// No description provided for @onboardingNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question ↵'**
  String get onboardingNextQuestion;

  /// No description provided for @onboardingFinishAssessment.
  ///
  /// In en, this message translates to:
  /// **'Finish assessment and suggest a plan ↵'**
  String get onboardingFinishAssessment;

  /// No description provided for @onboardingRoadmapSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your personalized learning plan is ready!'**
  String get onboardingRoadmapSuccess;

  /// No description provided for @onboardingRecommendedStart.
  ///
  /// In en, this message translates to:
  /// **'Recommended starting point: {unit}'**
  String onboardingRecommendedStart(String unit);

  /// No description provided for @onboardingUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit {number}'**
  String onboardingUnitLabel(String number);

  /// No description provided for @onboardingSummaryBeginner.
  ///
  /// In en, this message translates to:
  /// **'We will start with the fundamentals to build a strong foundation in programming and GDScript.'**
  String get onboardingSummaryBeginner;

  /// No description provided for @onboardingSummaryTransition.
  ///
  /// In en, this message translates to:
  /// **'Based on your answers and programming background, we will start at the level best suited to accelerate your learning.'**
  String get onboardingSummaryTransition;

  /// No description provided for @onboardingSummaryVeteran.
  ///
  /// In en, this message translates to:
  /// **'We will focus on the concepts that help you move to GDScript 2.0 and Godot 4.'**
  String get onboardingSummaryVeteran;

  /// No description provided for @onboardingStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Go to the learning path and start your first lesson ↵'**
  String get onboardingStartLearning;

  /// No description provided for @onboardingSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save onboarding progress. Please try again.'**
  String get onboardingSaveError;

  /// No description provided for @onboardingRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Could not restore your saved onboarding data.'**
  String get onboardingRestoreError;

  /// No description provided for @syntaxCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get syntaxCategoryAll;

  /// No description provided for @syntaxCategoryKeywords.
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get syntaxCategoryKeywords;

  /// No description provided for @syntaxCategoryBuiltins.
  ///
  /// In en, this message translates to:
  /// **'Built-ins'**
  String get syntaxCategoryBuiltins;

  /// No description provided for @syntaxCategoryTypes.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get syntaxCategoryTypes;

  /// No description provided for @syntaxExplorerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the syntax reference.'**
  String get syntaxExplorerLoadError;

  /// No description provided for @syntaxExplorerProgressError.
  ///
  /// In en, this message translates to:
  /// **'Could not record syntax explorer usage.'**
  String get syntaxExplorerProgressError;

  /// No description provided for @syntaxExplorerPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Search GDScript keywords, built-ins, and types.'**
  String get syntaxExplorerPageDescription;

  /// No description provided for @syntaxExplorerRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get syntaxExplorerRetry;

  /// No description provided for @syntaxExplorerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a keyword, built-in, or data type...'**
  String get syntaxExplorerSearchHint;

  /// No description provided for @syntaxExplorerSortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Sort: alphabetical'**
  String get syntaxExplorerSortAlphabetical;

  /// No description provided for @syntaxExplorerEntriesHeading.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get syntaxExplorerEntriesHeading;

  /// No description provided for @syntaxExplorerCount.
  ///
  /// In en, this message translates to:
  /// **'{count} documented entries'**
  String syntaxExplorerCount(int count);

  /// No description provided for @syntaxExplorerVisibleCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {visible} of {total}'**
  String syntaxExplorerVisibleCount(int visible, int total);

  /// No description provided for @syntaxExplorerLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get syntaxExplorerLoadMore;

  /// No description provided for @syntaxExplorerSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get syntaxExplorerSelected;

  /// No description provided for @syntaxExplorerNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results.'**
  String get syntaxExplorerNoResults;

  /// No description provided for @syntaxExplorerSelectEntry.
  ///
  /// In en, this message translates to:
  /// **'Select an entry to view its details.'**
  String get syntaxExplorerSelectEntry;

  /// No description provided for @syntaxExplorerSignature.
  ///
  /// In en, this message translates to:
  /// **'Syntax'**
  String get syntaxExplorerSignature;

  /// No description provided for @syntaxExplorerExample.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get syntaxExplorerExample;

  /// No description provided for @syntaxExplorerExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get syntaxExplorerExplanation;

  /// No description provided for @syntaxExplorerCopyEntry.
  ///
  /// In en, this message translates to:
  /// **'Copy entry'**
  String get syntaxExplorerCopyEntry;

  /// No description provided for @syntaxExplorerCopyExample.
  ///
  /// In en, this message translates to:
  /// **'Copy example'**
  String get syntaxExplorerCopyExample;

  /// No description provided for @syntaxExplorerCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied {item}'**
  String syntaxExplorerCopied(String item);

  /// No description provided for @syntaxExplorerOpenLesson.
  ///
  /// In en, this message translates to:
  /// **'Open lesson'**
  String get syntaxExplorerOpenLesson;

  /// No description provided for @syntaxExplorerOpenWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Open workspace'**
  String get syntaxExplorerOpenWorkspace;

  /// No description provided for @syntaxExplorerRelatedConcepts.
  ///
  /// In en, this message translates to:
  /// **'Related concepts'**
  String get syntaxExplorerRelatedConcepts;

  /// No description provided for @syntaxExplorerLessonUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No related lesson is available for this entry.'**
  String get syntaxExplorerLessonUnavailable;

  /// No description provided for @syntaxExplorerClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get syntaxExplorerClearSearch;
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
