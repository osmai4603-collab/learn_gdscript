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
  String get navigateWorkspace => 'Workspace';

  @override
  String get navigateSettings => 'Settings';

  @override
  String get navigateOnboarding => 'Welcome';
}
