import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/async_state.dart';
import '../../../data/models/curriculum_models.dart';
import '../../../data/models/progress_models.dart';
import '../../../logic/providers/curriculum_provider.dart';
import '../../../logic/providers/progress_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/navigation_bar.dart';
import '../../widgets/progress/unit_card.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.learningPathTitle)),
      body: Row(
        children: [
          if (wide)
            AppNavigationBar(
              selectedRoute: '/path',
              onSelected: (route) => Navigator.pushReplacementNamed(context, route),
            ),
          Expanded(
            child: Consumer<CurriculumProvider>(
              builder: (context, provider, _) {
                final state = provider.state;
                if (state.status == LoadStatus.initial ||
                    state.status == LoadStatus.loading) {
                  return const LoadingIndicator();
                }
                if (state.status == LoadStatus.error) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    message: l10n.lessonUnavailable,
                    action: FilledButton(
                      onPressed: provider.load,
                      child: Text(l10n.retry),
                    ),
                  );
                }
                final curriculum = state.value;
                if (curriculum == null || curriculum.units.isEmpty) {
                  return EmptyState(
                    icon: Icons.menu_book_outlined,
                    message: l10n.learningPathEmpty,
                  );
                }
                return _PathContent(curriculum: curriculum);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : AppNavigationBar(
              selectedRoute: '/path',
              onSelected: (route) =>
                  Navigator.pushReplacementNamed(context, route),
            ),
    );
  }
}

class _PathContent extends StatefulWidget {
  const _PathContent({required this.curriculum});

  final Curriculum curriculum;

  @override
  State<_PathContent> createState() => _PathContentState();
}

class _PathContentState extends State<_PathContent> {
  String? _expandedUnit;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final progress = context.watch<ProgressProvider>().progress;
    final units = widget.curriculum.units;
    final activeUnitIndex = units.indexWhere(
      (unit) => unit.id == progress?.currentUnitId,
    );
    final completedUnits = <String>{};
    final totalLessons = units.fold<int>(
      0,
      (sum, unit) => sum + unit.lessonIds.length,
    );
    final completedLessons = units.fold<int>(
      0,
      (sum, unit) =>
          sum +
          unit.lessonIds.where(
            (id) => progress?.lessonsProgress[id]?.status == LessonStatus.completed,
          ).length,
    );
    for (final unit in units) {
      if (unit.lessonIds.isNotEmpty &&
          unit.lessonIds.every(
            (id) => progress?.lessonsProgress[id]?.status == LessonStatus.completed,
          )) {
        completedUnits.add(unit.id);
      }
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.l10n.lessonProgress,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: totalLessons == 0 ? 0 : completedLessons / totalLessons,
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < units.length; index++)
          _buildUnit(
            context,
            units[index],
            index,
            activeUnitIndex < 0 ? 0 : activeUnitIndex,
            completedUnits,
            locale,
          ),
      ],
    );
  }

  Widget _buildUnit(
    BuildContext context,
    Unit unit,
    int index,
    int activeUnitIndex,
    Set<String> completedUnits,
    Locale locale,
  ) {
    final progress = context.watch<ProgressProvider>().progress;
    final locked =
        index > activeUnitIndex &&
        index > 0 &&
        !completedUnits.contains(widget.curriculum.units[index - 1].id);
    final completedCount = unit.lessonIds
        .where(
          (id) => progress?.lessonsProgress[id]?.status == LessonStatus.completed,
        )
        .length;
    final isExpanded = _expandedUnit == unit.id;
    return Column(
      children: [
        UnitCard(
          title: unit.title.resolve(locale),
          description: unit.description.resolve(locale),
          completedLessons: completedCount,
          totalLessons: unit.lessonIds.length,
          isLocked: locked,
          onTap: () => setState(
            () => _expandedUnit = isExpanded ? null : unit.id,
          ),
        ),
        if (isExpanded && !locked)
          for (final lessonId in unit.lessonIds)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 20),
              child: ListTile(
                leading: Icon(
                  progress?.lessonsProgress[lessonId]?.status ==
                          LessonStatus.completed
                      ? Icons.check_circle_outline
                      : Icons.play_circle_outline,
                ),
                title: Text(_readableLessonId(lessonId)),
                subtitle: Text(
                  progress?.lessonsProgress[lessonId]?.status ==
                          LessonStatus.completed
                      ? context.l10n.unitCompleted
                      : context.l10n.lessonTitle,
                ),
                onTap: () =>
                    Navigator.pushNamed(context, '/lesson/$lessonId'),
              ),
            ),
      ],
    );
  }

  static String _readableLessonId(String id) => id
      .replaceFirst(RegExp(r'^lesson_[0-9]+_'), '')
      .replaceAll('_', ' ');
}
