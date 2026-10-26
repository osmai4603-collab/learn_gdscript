import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/context_extensions.dart';

class DesktopLessonIdeLayout extends StatefulWidget {
  const DesktopLessonIdeLayout({
    super.key,
    required this.unitTitle,
    required this.estimatedMinutes,
    required this.isEngineReady,
    required this.explanationSection,
    required this.editorSection,
    required this.statusSection,
  });

  final String unitTitle;
  final int estimatedMinutes;
  final bool isEngineReady;
  final Widget explanationSection;
  final Widget editorSection;
  final Widget statusSection;

  @override
  State<DesktopLessonIdeLayout> createState() => _DesktopLessonIdeLayoutState();
}

class _DesktopLessonIdeLayoutState extends State<DesktopLessonIdeLayout> {
  static const _background = Color(0xFF0F141B);
  static const _panelColor = Color(0xFF131922);
  static const _border = Color(0xFF28323F);
  static const _initialExplanationRatio = 0.65;

  double _explanationRatio = _initialExplanationRatio;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _background,
    child: Column(
      children: [
        _LessonContextBar(
          unitTitle: widget.unitTitle,
          estimatedMinutes: widget.estimatedMinutes,
          isEngineReady: widget.isEngineReady,
        ),
        const Divider(height: 1, color: _border),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 960) {
                return Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _panel(
                        child: widget.explanationSection,
                        padding: const EdgeInsets.all(20),
                      ),
                    ),
                    const Divider(height: 1, color: _border),
                    Expanded(
                      flex: 6,
                      child: _panel(
                        child: _editorContent,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    key: const ValueKey('lesson_explanation_panel'),
                    width: constraints.maxWidth * _explanationRatio,
                    child: _panel(
                      child: widget.explanationSection,
                      padding: const EdgeInsets.all(24),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      key: const ValueKey('lesson_panel_resize_handle'),
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        final direction = Directionality.of(context);
                        final delta = direction == TextDirection.rtl
                            ? -details.delta.dx
                            : details.delta.dx;
                        setState(() {
                          _explanationRatio =
                              (_explanationRatio +
                                      delta / constraints.maxWidth)
                                      .clamp(0.25, 0.75)
                                  .toDouble();
                        });
                      },
                      child: Tooltip(
                        message:
                            Localizations.localeOf(context).languageCode ==
                                'ar'
                            ? 'اسحب لتغيير عرض اللوحتين'
                            : 'Drag to resize panels',
                        child: const SizedBox(
                          width: 20,
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFF5B6878),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              child: SizedBox(width: 4, height: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    key: const ValueKey('lesson_editor_panel'),
                    child: _panel(
                      child: _editorContent,
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget get _editorContent => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      widget.editorSection,
      const SizedBox(height: 12),
      widget.statusSection,
    ],
  );

  Widget _panel({required Widget child, required EdgeInsets padding}) =>
      Container(
        color: _panelColor,
        padding: padding,
        child: SingleChildScrollView(child: child),
      );
}

class _LessonContextBar extends StatelessWidget {
  const _LessonContextBar({
    required this.unitTitle,
    required this.estimatedMinutes,
    required this.isEngineReady,
  });

  final String unitTitle;
  final int estimatedMinutes;
  final bool isEngineReady;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor = isEngineReady
        ? const Color(0xFF22C55E)
        : const Color(0xFFF59E0B);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF131922),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xFF478CBF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              unitTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFFE2E8F0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ContextBadge(
            icon: Icons.schedule_rounded,
            label: l10n.timeSpent(estimatedMinutes),
          ),
          const SizedBox(width: 10),
          _ContextBadge(
            icon: Icons.circle,
            label: isEngineReady
                ? (Localizations.localeOf(context).languageCode == 'ar'
                      ? 'محرك GDScript جاهز'
                      : 'GDScript engine ready')
                : (Localizations.localeOf(context).languageCode == 'ar'
                      ? 'محرك GDScript غير متاح'
                      : 'GDScript engine unavailable'),
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

class _ContextBadge extends StatelessWidget {
  const _ContextBadge({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF94A3B8),
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF171C23),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFF28323F)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    ),
  );
}

class LessonLoadingSkeleton extends StatelessWidget {
  const LessonLoadingSkeleton({super.key, this.breakpoint = 840});

  final double breakpoint;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= breakpoint;
      final skeleton = Padding(
        padding: const EdgeInsets.all(20),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    flex: 5,
                    child: _SkeletonPanel(
                      children: [
                        _SkeletonBlock(height: 28, width: 190),
                        SizedBox(height: 20),
                        _SkeletonBlock(height: 18),
                        SizedBox(height: 10),
                        _SkeletonBlock(height: 90),
                        SizedBox(height: 24),
                        _SkeletonBlock(height: 180),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 7,
                    child: _SkeletonPanel(
                      children: [
                        _SkeletonBlock(height: 36),
                        SizedBox(height: 16),
                        _SkeletonBlock(height: 250),
                        SizedBox(height: 16),
                        _SkeletonBlock(height: 120),
                      ],
                    ),
                  ),
                ],
              )
            : const Column(
                children: [
                  _SkeletonPanel(
                    children: [
                      _SkeletonBlock(height: 28, width: 190),
                      SizedBox(height: 16),
                      _SkeletonBlock(height: 100),
                    ],
                  ),
                  SizedBox(height: 16),
                  _SkeletonPanel(
                    children: [
                      _SkeletonBlock(height: 36),
                      SizedBox(height: 12),
                      _SkeletonBlock(height: 200),
                    ],
                  ),
                ],
              ),
      );
      return Shimmer.fromColors(
        baseColor: const Color(0xFF1B2027),
        highlightColor: const Color(0xFF30353D),
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: isDesktop ? skeleton : SingleChildScrollView(child: skeleton),
      );
    },
  );
}

class _SkeletonPanel extends StatelessWidget {
  const _SkeletonPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF131922),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF28323F)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2027),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF30353D)),
      ),
    ),
  );
}
