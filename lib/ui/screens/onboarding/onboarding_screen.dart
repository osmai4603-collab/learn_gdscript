import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_gdscript/core/constants/app_constants.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/providers/app_settings_provider.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../routers/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _choose(BuildContext context, {required bool experienced}) async {
    final units = context.read<CurriculumProvider>().state.value?.units ?? [];
    final progress = context.read<ProgressProvider>();
    final chosenUnit = experienced && units.length > 1
        ? units[1]
        : units.isNotEmpty
        ? units.first
        : null;
    if (chosenUnit != null && chosenUnit.lessonIds.isNotEmpty) {
      if (progress.progress == null) {
        await progress.initialize(
          visitorId: AppConstants.visitorId,
          unitId: chosenUnit.id,
          lessonId: chosenUnit.lessonIds.first,
        );
      } else {
        await progress.setStartingPoint(
          unitId: chosenUnit.id,
          lessonId: chosenUnit.lessonIds.first,
        );
      }
    }
    if (!context.mounted) return;
    await context.read<AppSettingsProvider>().completeOnboarding();
    if (!context.mounted) return;
    context.go(AppRoutes.root);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Icon(
                Icons.sports_esports_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(l10n.onboardingDescription, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Text(
                l10n.onboardingQuestion,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _OnboardingChoice(
                icon: Icons.eco_outlined,
                title: l10n.onboardingNewbie,
                subtitle: l10n.startLearning,
                onTap: () => _choose(context, experienced: false),
              ),
              const SizedBox(height: 12),
              _OnboardingChoice(
                icon: Icons.lightbulb_outline,
                title: l10n.onboardingExperienced,
                subtitle: l10n.continueLearning,
                onTap: () => _choose(context, experienced: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingChoice extends StatelessWidget {
  const _OnboardingChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
