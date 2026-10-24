import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/app_settings.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/language_server_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/navigation_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsProvider>();
    final languageServer = context.watch<LanguageServerProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _SectionTitle(l10n.languageLabel),
                DropdownButtonFormField<Locale>(
                  initialValue: settings.locale,
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
                _SectionTitle(l10n.themeLabel),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: settings.themeMode,
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
                const SizedBox(height: 24),
                _SectionTitle(l10n.themeVariantLabel),
                DropdownButtonFormField<AppThemeVariant>(
                  initialValue: settings.themeVariant,
                  items: [
                    DropdownMenuItem(
                      value: AppThemeVariant.academy,
                      child: Text(l10n.themeAcademy),
                    ),
                    DropdownMenuItem(
                      value: AppThemeVariant.arabicIde,
                      child: Text(l10n.themeArabicIde),
                    ),
                  ],
                  onChanged: (variant) {
                    if (variant != null) {
                      _save(context, () => settings.setThemeVariant(variant));
                    }
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.showStreak),
                  value: settings.showStreakInUi,
                  onChanged: (show) =>
                      _save(context, () => settings.setShowStreakInUi(show)),
                ),
                const SizedBox(height: 24),
                _SectionTitle(l10n.editorFontSize),
                DropdownButtonFormField<int>(
                  initialValue: settings.editorFontSize,
                  items: [
                    DropdownMenuItem(value: 12, child: Text(l10n.fontSmall)),
                    DropdownMenuItem(value: 14, child: Text(l10n.fontMedium)),
                    DropdownMenuItem(value: 16, child: Text(l10n.fontLarge)),
                  ],
                  onChanged: (size) {
                    if (size != null) {
                      _save(context, () => settings.setEditorFontSize(size));
                    }
                  },
                ),
                const SizedBox(height: 32),
                _SectionTitle(l10n.lspStatus),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(l10n.syntaxExplorerTitle),
                  onTap: () => context.push(AppRoutes.syntaxReference),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    languageServer.isConnected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: languageServer.isConnected
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: Text(
                    languageServer.isConnected
                        ? l10n.lspConnected
                        : l10n.lspDisconnected,
                  ),
                  subtitle: languageServer.rootPath == null
                      ? null
                      : Text(languageServer.rootPath!),
                  trailing: IconButton(
                    tooltip: l10n.workspaceTitle,
                    onPressed: () => context.push(AppRoutes.workspace),
                    icon: const Icon(Icons.open_in_new),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(l10n.aboutApp),
                Text(l10n.appTitle),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _resetProgress(context),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.resetProgress),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : AppNavigationBar(
              selectedRoute: '/settings',
              onSelected: (route) => context.go(route),
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

  static Future<void> _resetProgress(BuildContext context) async {
    final l10n = context.l10n;
    final progressProvider = context.read<ProgressProvider>();
    final units = context.read<CurriculumProvider>().state.value?.units ?? [];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetProgress),
        content: Text(l10n.resetConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.resetProgress),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await progressProvider.clear(AppConstants.visitorId);
      final firstUnit = units.isEmpty ? null : units.first;
      if (firstUnit != null && firstUnit.lessonIds.isNotEmpty) {
        await progressProvider.initialize(
          visitorId: AppConstants.visitorId,
          unitId: firstUnit.id,
          lessonId: firstUnit.lessonIds.first,
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveSettingsError)));
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}
