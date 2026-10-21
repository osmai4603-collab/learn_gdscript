import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_extensions.dart';
import '../../logic/providers/app_settings_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.homeWelcome,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _DestinationTile(
            title: l10n.learningPathTitle,
            route: '/path',
            icon: Icons.route,
          ),
          _DestinationTile(
            title: l10n.workspaceTitle,
            route: '/workspace',
            icon: Icons.folder_open,
          ),
          _DestinationTile(
            title: l10n.settingsTitle,
            route: '/settings',
            icon: Icons.settings,
          ),
          _DestinationTile(
            title: l10n.onboardingTitle,
            route: '/onboarding',
            icon: Icons.waving_hand_outlined,
          ),
        ],
      ),
    );
  }
}

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) => _DestinationScreen(
    title: context.l10n.learningPathTitle,
    child: Text(context.l10n.learningPathEmpty),
  );
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) => _DestinationScreen(
    title: context.l10n.workspaceTitle,
    child: Text(context.l10n.workspaceDescription),
  );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => _DestinationScreen(
    title: context.l10n.onboardingTitle,
    child: Text(context.l10n.onboardingDescription),
  );
}

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) => _DestinationScreen(
    title: '${context.l10n.lessonTitle}: $lessonId',
    child: Text(context.l10n.lessonMissing),
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => _DestinationScreen(
    title: context.l10n.notFoundTitle,
    child: TextButton(
      onPressed: () =>
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
      child: Text(context.l10n.backHome),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.languageLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          DropdownButton<Locale>(
            value: settings.locale,
            items: [
              DropdownMenuItem(
                value: const Locale('ar'),
                child: Text(l10n.arabic),
              ),
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text(l10n.english),
              ),
            ],
            onChanged: (locale) {
              if (locale != null) {
                _save(context, () => settings.setLocale(locale));
              }
            },
          ),
          const SizedBox(height: 24),
          Text(l10n.themeLabel, style: Theme.of(context).textTheme.titleMedium),
          DropdownButton<ThemeMode>(
            value: settings.themeMode,
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(l10n.themeSystem),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(l10n.themeLight),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(l10n.themeDark),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) {
                _save(context, () => settings.setThemeMode(mode));
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _save(
    BuildContext context,
    Future<void> Function() update,
  ) async {
    try {
      await update();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveSettingsError)));
      }
    }
  }
}

class _DestinationScreen extends StatelessWidget {
  const _DestinationScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.title,
    required this.route,
    required this.icon,
  });

  final String title;
  final String route;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => Navigator.of(context).pushNamed(route),
  );
}
