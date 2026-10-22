import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/async_state.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../widgets/common/continue_learning_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/navigation_bar.dart';
import '../../widgets/common/quick_try_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/progress/unit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.navigateSettings,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            AppNavigationBar(
              selectedRoute: '/',
              onSelected: (route) => Navigator.pushReplacementNamed(context, route),
            ),
          Expanded(
            child: Consumer<CurriculumProvider>(
              builder: (context, curriculumProvider, _) {
                final state = curriculumProvider.state;
                if (state.status == LoadStatus.loading ||
                    state.status == LoadStatus.initial) {
                  return const LoadingIndicator();
                }
                if (state.status == LoadStatus.error) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    message: l10n.lessonUnavailable,
                    action: FilledButton(
                      onPressed: curriculumProvider.load,
                      child: Text(l10n.retry),
                    ),
                  );
                }
                final curriculum = state.value;
                if (curriculum == null || curriculum.units.isEmpty) {
                  return EmptyState(
                    icon: Icons.menu_book_outlined,
                    message: l10n.learningPathEmpty,
                    action: FilledButton(
                      onPressed: () => Navigator.pushNamed(context, '/path'),
                      child: Text(l10n.learningPathTitle),
                    ),
                  );
                }
                return _HomeContent(curriculum: curriculum);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : AppNavigationBar(
              selectedRoute: '/',
              onSelected: (route) =>
                  Navigator.pushReplacementNamed(context, route),
            ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.curriculum});

  final Curriculum curriculum;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final progress = context.watch<ProgressProvider>().progress;
    final allLessons = [
      for (final unit in curriculum.units)
        for (final lessonId in unit.lessonIds) (unit, lessonId),
    ];
    if (allLessons.isEmpty) {
      return EmptyState(
        icon: Icons.menu_book_outlined,
        message: l10n.noLessons,
      );
    }
    var next = allLessons.firstWhere(
      (entry) =>
          progress?.lessonsProgress[entry.$2]?.status != LessonStatus.completed,
      orElse: () => allLessons.first,
    );
    for (final entry in allLessons) {
      if (entry.$2 == progress?.currentLessonId &&
          progress?.lessonsProgress[entry.$2]?.status !=
              LessonStatus.completed) {
        next = entry;
        break;
      }
    }
    final currentUnit = next.$1;
    final completed = currentUnit.lessonIds
        .where(
          (id) =>
              progress?.lessonsProgress[id]?.status == LessonStatus.completed,
        )
        .length;
    final lessonTitle = _readableLessonId(next.$2);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                progress?.lessonsProgress.values.any(
                          (item) => item.status == LessonStatus.completed,
                        ) ==
                        true
                    ? l10n.returningWelcome
                    : l10n.newUserWelcome,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(l10n.homeWelcome),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final continueCard = ContinueLearningCard(
                    unitTitle: currentUnit.title.resolve(locale),
                    lessonTitle: lessonTitle,
                    completedLessons: completed,
                    totalLessons: currentUnit.lessonIds.length,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/lesson/${next.$2}',
                    ),
                  );
                  final quickTry = const QuickTryCard();
                  if (constraints.maxWidth < 720) {
                    return Column(
                      children: [
                        continueCard,
                        const SizedBox(height: 12),
                        quickTry,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: continueCard),
                      const SizedBox(width: 16),
                      Expanded(child: quickTry),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                l10n.learningPathTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < curriculum.units.length; index++)
                _unitCard(
                  context,
                  curriculum.units[index],
                  index,
                  progress,
                  locale,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitCard(
    BuildContext context,
    Unit unit,
    int index,
    UserProgress? progress,
    Locale locale,
  ) {
    final previousUnit = index == 0 ? null : curriculum.units[index - 1];
    final isLocked =
        previousUnit != null &&
        previousUnit.lessonIds.any(
          (id) => progress?.lessonsProgress[id]?.status != LessonStatus.completed,
        );
    return UnitCard(
      title: unit.title.resolve(locale),
      description: unit.description.resolve(locale),
      completedLessons: unit.lessonIds
          .where(
            (id) =>
                progress?.lessonsProgress[id]?.status == LessonStatus.completed,
          )
          .length,
      totalLessons: unit.lessonIds.length,
      isLocked: isLocked,
      onTap: () => Navigator.pushNamed(context, '/path'),
    );
  }

  static String _readableLessonId(String id) {
    final readable = id
        .replaceFirst(RegExp(r'^lesson_[0-9]+_'), '')
        .replaceAll('_', ' ');
    return readable.isEmpty ? id : readable;
  }
}
