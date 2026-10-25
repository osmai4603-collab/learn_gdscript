import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/async_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/language_server_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/navigation_bar.dart';

enum _SettingsCategory { editor, appearance, engine, about }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsCategory _selectedCategory = _SettingsCategory.editor;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final settingsProvider = context.watch<AppSettingsProvider>();
    final state = settingsProvider.state;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsReload,
            onPressed: () => _reloadSettings(context),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (state.status == LoadStatus.initial ||
              state.status == LoadStatus.loading) {
            return _SettingsLoadingSkeleton(wide: constraints.maxWidth >= 920);
          }
          if (state.status == LoadStatus.error) {
            return _SettingsLoadError(onRetry: () => _reloadSettings(context));
          }

          return _SettingsContent(
            category: _selectedCategory,
            showSidebar: constraints.maxWidth >= 920,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
            },
          );
        },
      ),
      bottomNavigationBar: wide
          ? null
          : AppNavigationBar(
              selectedRoute: AppRoutes.settings,
              onSelected: context.go,
            ),
    );
  }

  Future<void> _reloadSettings(BuildContext context) async {
    try {
      await context.read<AppSettingsProvider>().reload();
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.settingsLoadError)));
    }
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.category,
    required this.showSidebar,
    required this.onCategoryChanged,
  });

  final _SettingsCategory category;
  final bool showSidebar;
  final ValueChanged<_SettingsCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    if (!showSidebar) {
      return Column(
        children: [
          _CategorySelector(
            selected: category,
            onChanged: onCategoryChanged,
            horizontal: true,
          ),
          Expanded(child: _CategoryDetails(category: category)),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 256,
          child: _CategorySelector(
            selected: category,
            onChanged: onCategoryChanged,
            horizontal: false,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _CategoryDetails(category: category)),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selected,
    required this.onChanged,
    required this.horizontal,
  });

  final _SettingsCategory selected;
  final ValueChanged<_SettingsCategory> onChanged;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final categories = _SettingsCategory.values;

    if (horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            for (final category in categories)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(_categoryTitle(l10n, category)),
                  selected: category == selected,
                  onSelected: (_) => onChanged(category),
                ),
              ),
          ],
        ),
      );
    }

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 12),
            child: Text(
              l10n.settingsCategories,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: ListTile(
                selected: category == selected,
                selectedTileColor: theme.colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(_categoryIcon(category)),
                title: Text(_categoryTitle(l10n, category)),
                onTap: () => onChanged(category),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryDetails extends StatelessWidget {
  const _CategoryDetails({required this.category});

  final _SettingsCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = context.watch<AppSettingsProvider>();
    final languageServer = context.watch<LanguageServerProvider>();
    final padding = MediaQuery.sizeOf(context).width >= 1200 ? 36.0 : 24.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 28, padding, 36),
      children: [
        Row(
          children: [
            Icon(
              _categoryIcon(category),
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _categoryTitle(l10n, category),
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _categoryDescription(l10n, category),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        switch (category) {
          _SettingsCategory.editor => _EditorSettingsSection(
            fontSize: settings.editorFontSize,
            onFontSizeChanged: (size) =>
                _saveSettings(context, () => settings.setEditorFontSize(size)),
          ),
          _SettingsCategory.appearance => _AppearanceSettingsSection(
            settings: settings,
          ),
          _SettingsCategory.engine => _EngineSettingsSection(
            languageServer: languageServer,
          ),
          _SettingsCategory.about => const _AboutSettingsSection(),
        },
      ],
    );
  }
}

class _EditorSettingsSection extends StatelessWidget {
  const _EditorSettingsSection({
    required this.fontSize,
    required this.onFontSizeChanged,
  });

  final int fontSize;
  final ValueChanged<int> onFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SettingsCard(
      children: [
        _DropdownSetting<int>(
          title: l10n.editorFontSize,
          description: l10n.settingsEditorFontDescription,
          value: fontSize,
          items: [
            DropdownMenuItem(
              value: 12,
              child: Text('${l10n.fontSmall} (12 px)'),
            ),
            DropdownMenuItem(
              value: 14,
              child: Text('${l10n.fontMedium} (14 px)'),
            ),
            DropdownMenuItem(
              value: 16,
              child: Text('${l10n.fontLarge} (16 px)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onFontSizeChanged(value);
          },
        ),
      ],
    );
  }
}

class _AppearanceSettingsSection extends StatelessWidget {
  const _AppearanceSettingsSection({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SettingsCard(
      children: [
        _DropdownSetting<Locale>(
          title: l10n.languageLabel,
          description: l10n.settingsLanguageDescription,
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
              _saveSettings(context, () => settings.setLocale(locale));
            }
          },
        ),
        const SizedBox(height: 24),
        _DropdownSetting<ThemeMode>(
          title: l10n.themeLabel,
          description: l10n.settingsThemeModeDescription,
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
              _saveSettings(context, () => settings.setThemeMode(mode));
            }
          },
        ),
        const SizedBox(height: 24),
        _DropdownSetting<AppThemeVariant>(
          title: l10n.themeVariantLabel,
          description: l10n.settingsThemeVariantDescription,
          value: settings.themeVariant,
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
              _saveSettings(context, () => settings.setThemeVariant(variant));
            }
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.showStreak),
          subtitle: Text(l10n.settingsStreakDescription),
          value: settings.showStreakInUi,
          onChanged: (show) =>
              _saveSettings(context, () => settings.setShowStreakInUi(show)),
        ),
      ],
    );
  }
}

class _EngineSettingsSection extends StatelessWidget {
  const _EngineSettingsSection({required this.languageServer});

  final LanguageServerProvider languageServer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final connected = languageServer.isConnected;
    return _SettingsCard(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            connected ? Icons.check_circle : Icons.circle_outlined,
            color: connected
                ? theme.colorScheme.tertiary
                : theme.colorScheme.outline,
          ),
          title: Text(connected ? l10n.lspConnected : l10n.lspDisconnected),
          subtitle: languageServer.rootPath == null
              ? null
              : Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      languageServer.rootPath!,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
          trailing: IconButton(
            tooltip: l10n.workspaceTitle,
            onPressed: () => context.push(AppRoutes.workspace),
            icon: const Icon(Icons.open_in_new),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(l10n.syntaxExplorerTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.syntaxReference),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.monitor_heart_outlined),
          title: Text(l10n.lspDiagnosticsTitle),
          subtitle: Text(l10n.lspDiagnosticsDescription),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(AppRoutes.lspDiagnostics),
        ),
      ],
    );
  }
}

class _AboutSettingsSection extends StatelessWidget {
  const _AboutSettingsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SettingsCard(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.appTitle),
          subtitle: Text(l10n.aboutApp),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: () => _resetProgress(context),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.resetProgress),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _DropdownSetting<T> extends StatelessWidget {
  const _DropdownSetting({
    required this.title,
    required this.description,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final String description;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SettingsLoadingSkeleton extends StatelessWidget {
  const _SettingsLoadingSkeleton({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final skeleton = Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide) ...[
            SizedBox(
              width: 256,
              child: Column(
                children: [
                  for (var index = 0; index < 4; index++) ...[
                    if (index > 0) const SizedBox(height: 10),
                    const _SkeletonBlock(height: 48, radius: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 24),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SkeletonBlock(height: 36, width: 280, radius: 8),
                const SizedBox(height: 12),
                const _SkeletonBlock(height: 18, width: 420, radius: 6),
                const SizedBox(height: 28),
                for (var index = 0; index < 4; index++) ...[
                  if (index > 0) const SizedBox(height: 16),
                  const _SkeletonBlock(height: 96, radius: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHigh,
      highlightColor: scheme.surfaceContainerHighest,
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: skeleton,
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.height,
    required this.radius,
    this.width,
  });

  final double height;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SettingsLoadError extends StatelessWidget {
  const _SettingsLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(l10n.settingsLoadError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

String _categoryTitle(AppLocalizations l10n, _SettingsCategory category) {
  return switch (category) {
    _SettingsCategory.editor => l10n.settingsEditorCategory,
    _SettingsCategory.appearance => l10n.settingsAppearanceCategory,
    _SettingsCategory.engine => l10n.settingsEngineCategory,
    _SettingsCategory.about => l10n.settingsAboutCategory,
  };
}

String _categoryDescription(AppLocalizations l10n, _SettingsCategory category) {
  return switch (category) {
    _SettingsCategory.editor => l10n.settingsEditorDescription,
    _SettingsCategory.appearance => l10n.settingsAppearanceDescription,
    _SettingsCategory.engine => l10n.settingsEngineDescription,
    _SettingsCategory.about => l10n.settingsAboutDescription,
  };
}

IconData _categoryIcon(_SettingsCategory category) {
  return switch (category) {
    _SettingsCategory.editor => Icons.code_rounded,
    _SettingsCategory.appearance => Icons.palette_outlined,
    _SettingsCategory.engine => Icons.dns_outlined,
    _SettingsCategory.about => Icons.info_outline,
  };
}

Future<void> _saveSettings(
  BuildContext context,
  Future<void> Function() update,
) async {
  try {
    await update();
  } on Object {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.saveSettingsError)));
  }
}

Future<void> _resetProgress(BuildContext context) async {
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
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsResetProgressError)),
    );
  }
}
