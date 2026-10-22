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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
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

  String get onboardingQuestion;
  String get onboardingNewbie;
  String get onboardingExperienced;
  String get continueLearning;
  String get quickTry;
  String get runCode;
  String get resetCode;
  String get showHint;
  String get showSolution;
  String get nextLesson;
  String get previousLesson;
  String get exercisePrompt;
  String get outputLabel;
  String get outputEmpty;
  String get outputRunning;
  String get testResults;
  String get testPassed;
  String get testFailed;
  String get lessonComplete;
  String completedLesson(String name);
  String exercisesSolved(int count);
  String hintsUsed(int count);
  String timeSpent(int minutes);
  String get backToPath;
  String get unitLocked;
  String get unitInProgress;
  String get unitCompleted;
  String get editorFontSize;
  String get fontSmall;
  String get fontMedium;
  String get fontLarge;
  String get resetProgress;
  String get resetConfirmation;
  String get aboutApp;
  String get sendFeedback;
  String get lspStatus;
  String get lspConnected;
  String get lspDisconnected;
  String get startLearning;
  String get newUserWelcome;
  String get returningWelcome;
  String get retry;
  String get loading;
  String get noLessons;
  String get runExample;
  String get exampleLabel;
  String exerciseProgress(int current, int total);
  String get nextExercise;
  String get runTests;
  String get allTestsPassed;
  String testSummary(int passed, int total);
  String get resetCodeConfirmation;
  String get hintUnavailable;
  String get lessonUnavailable;
  String get lessonProgress;
  String get quickTryCode;
  String get workspaceUnavailable;
  String get executionFailed;
  String get expectedOutput;
  String get actualOutput;
  String errorLine(int line);
  String get workspacePath;
  String get lspExecutablePath;
  String get connectLsp;
  String get disconnectLsp;
  String indexedFiles(int count);
  String get lspConnectionError;
  String get completeCode;
  String get formatCode;
  String get lspFeatureError;
  String diagnosticLine(int line);
  String get workspaceSearchTitle;
  String get workspaceSearchPlaceholder;
  String get searchWorkspaceText;
  String get searchWorkspaceSymbols;
  String get workspaceSearchEmpty;

  String levelLabel(int level);

  String totalXp(int xp);

  String streakDays(int count);

  String get streakInfo;

  String get badgesTitle;

  String get badgeUnlocked;

  String get badgeLocked;

  String badgeProgress(int current, int target);

  String earnedOn(String date);

  String xpAwarded(int xp);

  String get showStreak;

  String get great;

  String get syntaxExplorerTitle;

  String get syntaxExplorerPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
