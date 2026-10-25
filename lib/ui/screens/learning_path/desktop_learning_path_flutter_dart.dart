// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 3: مسار التعلّم وخريطة المفاهيم (Desktop Learning Path Screen)
// الملف: desktop_learning_path_screen.dart
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:learn_gdscript/ui/routers/app_routes.dart';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات الخاصة بمسار التعلّم (Data Models)
// -----------------------------------------------------------------------------

enum LessonNodeStatus { completed, active, locked }

class CurriculumModuleModel {
  final String moduleId;
  final String moduleNumber;
  final String title;
  final String subtitle;
  final String description;
  final int totalXp;
  final String estimatedHours;
  final bool isExpanded;
  final List<CurriculumLessonNodeModel> lessons;
  final CapstoneProjectModel? capstoneProject;

  const CurriculumModuleModel({
    required this.moduleId,
    required this.moduleNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.totalXp,
    required this.estimatedHours,
    this.isExpanded = true,
    required this.lessons,
    this.capstoneProject,
  });

  int get completedCount =>
      lessons.where((l) => l.status == LessonNodeStatus.completed).length;
  double get progress =>
      lessons.isEmpty ? 0.0 : completedCount / lessons.length;
}

class CurriculumLessonNodeModel {
  final String id;
  final String lessonNumber;
  final String title;
  final String briefDescription;
  final String durationMinutes;
  final int xpReward;
  final LessonNodeStatus status;
  final List<String> conceptsCovered;

  const CurriculumLessonNodeModel({
    required this.id,
    required this.lessonNumber,
    required this.title,
    required this.briefDescription,
    required this.durationMinutes,
    required this.xpReward,
    required this.status,
    required this.conceptsCovered,
  });
}

class CapstoneProjectModel {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final bool isUnlocked;
  final String badgeReward;

  const CapstoneProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.isUnlocked,
    required this.badgeReward,
  });
}

class LearningPathDataModel {
  final String overallProgressPercent;
  final int totalLessonsCompleted;
  final int totalLessonsCount;
  final int streakDays;
  final int earnedXp;
  final List<CurriculumModuleModel> modules;

  const LearningPathDataModel({
    required this.overallProgressPercent,
    required this.totalLessonsCompleted,
    required this.totalLessonsCount,
    required this.streakDays,
    required this.earnedXp,
    required this.modules,
  });

  static LearningPathDataModel sampleData() {
    return const LearningPathDataModel(
      overallProgressPercent: '42%',
      totalLessonsCompleted: 9,
      totalLessonsCount: 28,
      streakDays: 3,
      earnedXp: 420,
      modules: [
        CurriculumModuleModel(
          moduleId: 'u1',
          moduleNumber: 'الوحدة 01',
          title: 'الأساسيات والأنواع الصارمة في GDScript 2.0',
          subtitle: 'Static Typing, Variables & Scene Lifecycle',
          description:
              'بناء القاعدة المتينة: المتغيرات، الأنواع الصارمة (int, float, Vector2)، دوال دورة حياة العقد (_ready, _process)، وأفضل ممارسات محرك Godot 4.3.',
          totalXp: 180,
          estimatedHours: '3 ساعات',
          isExpanded: true,
          lessons: [
            CurriculumLessonNodeModel(
              id: 'u1_l1',
              lessonNumber: '01',
              title: 'مرحباً بـ Godot: دالة print() والشجرة الدلالية',
              briefDescription:
                  'كتابة أول نص برمجي واستدعاء دوال الطباعة والتحكم في إخراج وحدة المعالجة.',
              durationMinutes: '10 د',
              xpReward: 25,
              status: LessonNodeStatus.completed,
              conceptsCovered: ['print()', '_ready()', 'Node Tree'],
            ),
            CurriculumLessonNodeModel(
              id: 'u1_l2',
              lessonNumber: '02',
              title: 'المتغيرات والأنواع الصارمة (Static Typing)',
              briefDescription:
                  'استخدام : int و : float لتمكين الفاحص الدلالي وتحسين أداء JIT.',
              durationMinutes: '12 د',
              xpReward: 30,
              status: LessonNodeStatus.completed,
              conceptsCovered: [
                'var type annotation',
                'Inferred typing :=',
                'Type errors',
              ],
            ),
            CurriculumLessonNodeModel(
              id: 'u1_l3',
              lessonNumber: '03',
              title: 'المتجهات الحسابية (Vector2) وعمليات الحركة',
              briefDescription:
                  'تمثيل الإحداثيات المكانية والسرعات المتجهة في المستوي ثنائي الأبعاد.',
              durationMinutes: '15 د',
              xpReward: 35,
              status: LessonNodeStatus.completed,
              conceptsCovered: ['Vector2.ZERO', 'Vector2.UP', 'normalized()'],
            ),
            CurriculumLessonNodeModel(
              id: 'u1_l4',
              lessonNumber: '04',
              title: 'الدوال والمعاملات والأنواع المرجعة',
              briefDescription:
                  'تعريف الدوال المخصصة func my_func(arg: int) -> void وإرجاع النتائج.',
              durationMinutes: '15 د',
              xpReward: 35,
              status: LessonNodeStatus.completed,
              conceptsCovered: [
                'func definition',
                'Return types',
                'Default parameters',
              ],
            ),
            CurriculumLessonNodeModel(
              id: 'u1_l5',
              lessonNumber: '05',
              title: 'المصدّرات المتقدمة (@export) ومفتش الخصائص',
              briefDescription:
                  'تخصيص الخصائص وربطها مع محرر المشاهد Inspector عبر @export.',
              durationMinutes: '12 د',
              xpReward: 30,
              status: LessonNodeStatus.completed,
              conceptsCovered: ['@export var', '@export_range', 'Inspector UI'],
            ),
            CurriculumLessonNodeModel(
              id: 'u1_l6',
              lessonNumber: '06',
              title: 'المصفوفات والقواميس (Array & Dictionary)',
              briefDescription:
                  'إدارة مجموعات البيانات وجداول البحث المعنونة بنظام كتابة صارم Array[String].',
              durationMinutes: '18 د',
              xpReward: 40,
              status: LessonNodeStatus.completed,
              conceptsCovered: [
                'Typed Array',
                'Dictionary indexing',
                'append()',
              ],
            ),
          ],
          capstoneProject: CapstoneProjectModel(
            id: 'cap_u1',
            title:
                'المشروع التطبيقي: نظام بطاقة خصائص اللاعب (Player Stats Card)',
            description:
                'بناء كود متكامل يتحكم في طاقة اللاعب وسرعته وعرضها على واجهة المستخدم.',
            xpReward: 75,
            isUnlocked: true,
            badgeReward: 'خبير أساسيات GDScript',
          ),
        ),
        CurriculumModuleModel(
          moduleId: 'u2',
          moduleNumber: 'الوحدة 02',
          title: 'البنى الشرطية، الحلقات، ومطابقة الأنماط (match)',
          subtitle: 'Conditionals, Loops & State Machines',
          description:
              'التحكم في تدفق المنطق: صياغة if / elif / else، حلقات التكرار for و while، وبناء آلات الحالات المحدودة بواسطة match.',
          totalXp: 210,
          estimatedHours: '4 ساعات',
          isExpanded: true,
          lessons: [
            CurriculumLessonNodeModel(
              id: 'u2_l1',
              lessonNumber: '01',
              title: 'البنى الشرطية والمقارنات المنطقية',
              briefDescription:
                  'فحص شروط الاصطدام والصحة باستخدام if و elif والمعاملات المنطقية.',
              durationMinutes: '12 د',
              xpReward: 30,
              status: LessonNodeStatus.completed,
              conceptsCovered: [
                'if / elif / else',
                'and / or / not',
                'Ternary if',
              ],
            ),
            CurriculumLessonNodeModel(
              id: 'u2_l2',
              lessonNumber: '02',
              title: 'حلقات التكرار المحدودة (for ... in)',
              briefDescription:
                  'المرور عبر الأعداء والمقذوفات والمجالات العددية بواسطة range().',
              durationMinutes: '14 د',
              xpReward: 35,
              status: LessonNodeStatus.completed,
              conceptsCovered: [
                'for in range()',
                'break / continue',
                'Array iteration',
              ],
            ),
            CurriculumLessonNodeModel(
              id: 'u2_l3',
              lessonNumber: '03',
              title: 'حلقات while وتجنب التجميد البرمجي',
              briefDescription:
                  'تنفيذ العمليات التكرارية المتزامنة مع شروط الخروج الآمنة.',
              durationMinutes: '12 د',
              xpReward: 30,
              status: LessonNodeStatus.completed,
              conceptsCovered: [
                'while loop',
                'Infinite loop guard',
                'Yield / await',
              ],
            ),
            CurriculumLessonNodeModel(
              id: 'u2_l4',
              lessonNumber: '04',
              title: 'مطابقة الأنماط المتقدمة (match) وآلة الحالات',
              briefDescription:
                  'الدرس النشط حالياً: تنظيم سلوكيات الشخصيات (IDLE, RUN, JUMP) بنمط match.',
              durationMinutes: '15 د',
              xpReward: 35,
              status: LessonNodeStatus.active,
              conceptsCovered: [
                'match statement',
                'Wildcard _',
                'Compound patterns',
              ],
            ),
            CurriculumLessonNodeModel(
              id: 'u2_l5',
              lessonNumber: '05',
              title: 'التعدادات (enum) وتكاملها مع آلة الحالات',
              briefDescription:
                  'تعريف enum State { IDLE, RUN, ATTACK } لضمان الأمان البرمجي الكامل.',
              durationMinutes: '15 د',
              xpReward: 40,
              status: LessonNodeStatus.locked,
              conceptsCovered: [
                'enum declaration',
                'Named enums',
                'Export enums',
              ],
            ),
          ],
          capstoneProject: CapstoneProjectModel(
            id: 'cap_u2',
            title:
                'المشروع التطبيقي: محاكي آلة حالات الوحش (Boss State Machine)',
            description:
                'بناء ذكاء اصطناعي بسيط لوحش يغير سلوكه بين المطاردة والراحة والهجوم.',
            xpReward: 100,
            isUnlocked: false,
            badgeReward: 'صانع القرارات الشرطية',
          ),
        ),
        CurriculumModuleModel(
          moduleId: 'u3',
          moduleNumber: 'الوحدة 03',
          title: 'نظام الإشارات (Signals) والتواصل غير المتزامن',
          subtitle: 'Event-driven Architecture & Loose Coupling',
          description:
              'المعمارية الحدثية لمحرك Godot: الإشارات المدمجة والمخصصة، تمرير المعاملات، ودوال await.',
          totalXp: 240,
          estimatedHours: '4.5 ساعات',
          isExpanded: false,
          lessons: [
            CurriculumLessonNodeModel(
              id: 'u3_l1',
              lessonNumber: '01',
              title: 'مقدمة في الإشارات المدمجة (Built-in Signals)',
              briefDescription:
                  'الاستماع لنقرات الأزرار واصطدامات المناطق body_entered.',
              durationMinutes: '12 د',
              xpReward: 30,
              status: LessonNodeStatus.locked,
              conceptsCovered: ['connect()', 'Callable', 'area_entered'],
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. الشاشة الرئيسية لمسار التعلّم (DesktopLearningPathScreen)
// -----------------------------------------------------------------------------

class DesktopLearningPathScreen extends StatefulWidget {
  final LearningPathDataModel pathData;
  final ValueChanged<String>? onSelectLesson;
  final ValueChanged<String>? onSelectModuleOverview;
  final ValueChanged<String>? onNavigateRoute;

  const DesktopLearningPathScreen({
    super.key,
    required this.pathData,
    this.onSelectLesson,
    this.onSelectModuleOverview,
    this.onNavigateRoute,
  });

  @override
  State<DesktopLearningPathScreen> createState() =>
      _DesktopLearningPathScreenState();
}

class _DesktopLearningPathScreenState extends State<DesktopLearningPathScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late List<bool> _moduleExpandedStates;

  @override
  void initState() {
    super.initState();
    _moduleExpandedStates = widget.pathData.modules
        .map(
          (module) => module.lessons.any(
            (lesson) => lesson.status == LessonNodeStatus.active,
          ),
        )
        .toList();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _toggleModule(int index) {
    setState(() {
      _moduleExpandedStates[index] = !_moduleExpandedStates[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final pathData = widget.pathData;
    final completedLessons = pathData.modules.fold<int>(
      0,
      (count, module) => count + module.completedCount,
    );
    final totalLessons = pathData.modules.fold<int>(
      0,
      (count, module) => count + module.lessons.length,
    );
    final activeLessons = pathData.modules
        .expand((module) => module.lessons)
        .where((lesson) => lesson.status == LessonNodeStatus.active)
        .toList();
    final CurriculumLessonNodeModel? activeLesson = activeLessons.isEmpty
        ? null
        : activeLessons.first;

    return Scaffold(
      backgroundColor: _LearningPathColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1050;
          final horizontalPadding = constraints.maxWidth >= 1200
              ? 36.0
              : constraints.maxWidth >= 700
              ? 24.0
              : 16.0;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    28,
                    horizontalPadding,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LearningPathPageHeader(
                        data: pathData,
                        onShowConceptMap: () =>
                            widget.onNavigateRoute?.call(
                              AppRoutes.spacedRepetition,
                            ),
                        onStartReview: () =>
                            widget.onNavigateRoute?.call(
                              AppRoutes.spacedRepetition,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _LearningPathProgressStrip(
                        data: pathData,
                        completedLessons: completedLessons,
                        totalLessons: totalLessons,
                      ),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 8,
                              child: _buildCurriculum(
                                completedLessons,
                                totalLessons,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 4,
                              child: _LearningPathInsights(
                                data: pathData,
                                activeLesson: activeLesson,
                                onStartReview: () => widget.onNavigateRoute
                                    ?.call(AppRoutes.spacedRepetition),
                                onOpenWorkspace: () =>
                                    widget.onNavigateRoute?.call(
                                      AppRoutes.workspace,
                                    ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildCurriculum(completedLessons, totalLessons),
                        const SizedBox(height: 20),
                        _LearningPathInsights(
                          data: pathData,
                          activeLesson: activeLesson,
                          onStartReview: () => widget.onNavigateRoute
                              ?.call(AppRoutes.spacedRepetition),
                          onOpenWorkspace: () =>
                              widget.onNavigateRoute?.call(
                                AppRoutes.workspace,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurriculum(int completedLessons, int totalLessons) {
    final isFinalProjectUnlocked =
        totalLessons > 0 && completedLessons == totalLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(widget.pathData.modules.length, (index) {
          final module = widget.pathData.modules[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ModuleCard(
              module: module,
              index: index,
              isExpanded: _moduleExpandedStates[index],
              glowAnimation: _glowAnimation,
              onToggle: () => _toggleModule(index),
              onOpenOverview: () =>
                  widget.onSelectModuleOverview?.call(module.moduleId),
              onSelectLesson: widget.onSelectLesson,
            ),
          );
        }),
        _FinalProjectCard(
          isUnlocked: isFinalProjectUnlocked,
          onOpen: isFinalProjectUnlocked
              ? () => widget.onNavigateRoute?.call(AppRoutes.miniGame)
              : null,
        ),
      ],
    );
  }
}

class _LearningPathColors {
  static const background = Color(0xFF0F141B);
  static const surface = Color(0xFF171C23);
  static const surfaceRaised = Color(0xFF1B2027);
  static const surfaceHigh = Color(0xFF252A32);
  static const border = Color(0xFF40484F);
  static const text = Color(0xFFDEE2EC);
  static const muted = Color(0xFFC0C7D0);
  static const subtle = Color(0xFF8A919A);
  static const primary = Color(0xFF91CDFF);
  static const green = Color(0xFF4AE183);
  static const orange = Color(0xFFFFB783);
  static const purple = Color(0xFFCAA7FF);
}

class _LearningPathPageHeader extends StatelessWidget {
  const _LearningPathPageHeader({
    required this.data,
    required this.onShowConceptMap,
    required this.onStartReview,
  });

  final LearningPathDataModel data;
  final VoidCallback onShowConceptMap;
  final VoidCallback onStartReview;

  @override
  Widget build(BuildContext context) {
    final completedModules = data.modules
        .where((module) => module.progress == 1)
        .length;
    final totalLessons = data.modules.fold<int>(
      0,
      (count, module) => count + module.lessons.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: const [
            Text('أكاديمية جودو', style: _LearningPathTextStyles.breadcrumb),
            Icon(
              Icons.chevron_left_rounded,
              size: 16,
              color: _LearningPathColors.subtle,
            ),
            Text('منهج 2025', style: _LearningPathTextStyles.breadcrumb),
            Icon(
              Icons.chevron_left_rounded,
              size: 16,
              color: _LearningPathColors.subtle,
            ),
            Text(
              'GDScript 4.3 Core Curriculum',
              style: _LearningPathTextStyles.monoMuted,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 16,
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مسار التعلّم وخريطة المفاهيم البرمجية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: MediaQuery.sizeOf(context).width < 700
                          ? 26
                          : 34,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: _LearningPathColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const _StatusPill(
                        icon: Icons.verified_rounded,
                        label: 'Godot v4.3 Engine Verified',
                        color: _LearningPathColors.green,
                      ),
                      _StatusPill(
                        icon: Icons.check_circle_rounded,
                        label:
                            '$completedModules من ${data.modules.length} وحدات مكتملة',
                        color: _LearningPathColors.muted,
                      ),
                      _StatusPill(
                        icon: Icons.menu_book_rounded,
                        label:
                            '${data.totalLessonsCompleted} من ${data.totalLessonsCount} درساً',
                        color: _LearningPathColors.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderAction(
                  icon: Icons.account_tree_rounded,
                  label: 'مسار المنهج',
                  selected: true,
                  onPressed: () {},
                ),
                _HeaderAction(
                  icon: Icons.hub_rounded,
                  label: 'خريطة المفاهيم',
                  onPressed: onShowConceptMap,
                ),
                _HeaderAction(
                  icon: Icons.psychology_alt_rounded,
                  label: 'مراجعة ذكية',
                  accent: _LearningPathColors.orange,
                  onPressed: onStartReview,
                ),
              ],
            ),
          ],
        ),
        if (totalLessons == 0)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'لا توجد دروس مضافة إلى هذا المسار بعد.',
              style: TextStyle(color: _LearningPathColors.orange),
            ),
          ),
      ],
    );
  }
}

class _LearningPathProgressStrip extends StatelessWidget {
  const _LearningPathProgressStrip({
    required this.data,
    required this.completedLessons,
    required this.totalLessons,
  });

  final LearningPathDataModel data;
  final int completedLessons;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    final activeModuleIndex = data.modules.indexWhere(
      (module) => module.lessons.any(
        (lesson) => lesson.status == LessonNodeStatus.active,
      ),
    );
    final progressToNextLevel = (data.earnedXp / 650).clamp(0.0, 1.0);
    final curriculumProgress =
        ((double.tryParse(data.overallProgressPercent.replaceAll('%', '')) ??
                    0) /
                100)
            .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _LearningPathColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _LearningPathColors.border.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final milestones = [
                _ProgressMilestone(
                  icon: Icons.check_circle_rounded,
                  title: 'الأساسيات',
                  subtitle: 'بداية الرحلة',
                  state: activeModuleIndex > 0
                      ? _MilestoneState.completed
                      : _MilestoneState.active,
                ),
                _ProgressMilestone(
                  icon: activeModuleIndex == 1
                      ? Icons.bolt_rounded
                      : Icons.code_rounded,
                  title: 'صانع المنطق',
                  subtitle: activeModuleIndex == 1
                      ? 'قيد التقدّم'
                      : 'المرحلة التالية',
                  state: activeModuleIndex == 1
                      ? _MilestoneState.active
                      : activeModuleIndex > 1
                      ? _MilestoneState.completed
                      : _MilestoneState.locked,
                ),
                _ProgressMilestone(
                  icon: Icons.lock_rounded,
                  title: 'خبير المحرك',
                  subtitle: 'المرحلة المتقدمة',
                  state: activeModuleIndex > 1
                      ? _MilestoneState.active
                      : _MilestoneState.locked,
                ),
              ];

              if (constraints.maxWidth < 600) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final milestone in milestones)
                      SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: milestone,
                      ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: milestones[0]),
                  const _MilestoneConnector(),
                  Expanded(child: milestones[1]),
                  const _MilestoneConnector(),
                  Expanded(child: milestones[2]),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: totalLessons == 0 ? 0 : curriculumProgress,
              minHeight: 8,
              backgroundColor: _LearningPathColors.surfaceHigh,
              valueColor: const AlwaysStoppedAnimation(
                _LearningPathColors.green,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              const Text(
                '0 XP • البداية',
                style: _LearningPathTextStyles.monoSubtle,
              ),
              Text(
                '${data.earnedXp} / 650 XP للمستوى التالي',
                style: _LearningPathTextStyles.monoMuted,
              ),
              Text(
                'المشروع النهائي • ${data.modules.fold<int>(0, (sum, module) => sum + (module.capstoneProject?.xpReward ?? 0))} XP',
                style: _LearningPathTextStyles.monoSubtle,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressToNextLevel,
              minHeight: 3,
              backgroundColor: _LearningPathColors.surfaceHigh,
              valueColor: const AlwaysStoppedAnimation(
                _LearningPathColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MilestoneState { completed, active, locked }

class _ProgressMilestone extends StatelessWidget {
  const _ProgressMilestone({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _MilestoneState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _MilestoneState.completed => _LearningPathColors.green,
      _MilestoneState.active => _LearningPathColors.primary,
      _MilestoneState.locked => _LearningPathColors.subtle,
    };

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _LearningPathTextStyles.monoSubtle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneConnector extends StatelessWidget {
  const _MilestoneConnector();

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: _LearningPathColors.border,
  );
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.index,
    required this.isExpanded,
    required this.glowAnimation,
    required this.onToggle,
    required this.onOpenOverview,
    required this.onSelectLesson,
  });

  final CurriculumModuleModel module;
  final int index;
  final bool isExpanded;
  final Animation<double> glowAnimation;
  final VoidCallback onToggle;
  final VoidCallback onOpenOverview;
  final ValueChanged<String>? onSelectLesson;

  @override
  Widget build(BuildContext context) {
    final isCompleted = module.lessons.isNotEmpty && module.progress == 1;
    final isActive = module.lessons.any(
      (lesson) => lesson.status == LessonNodeStatus.active,
    );
    final isLocked = !isCompleted && !isActive;
    final accent = isCompleted
        ? _LearningPathColors.green
        : isActive
        ? _LearningPathColors.primary
        : _LearningPathColors.subtle;
    final background = isActive
        ? _LearningPathColors.surfaceRaised
        : isLocked
        ? const Color(0xFF11161D)
        : _LearningPathColors.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? accent.withValues(alpha: 0.75)
              : _LearningPathColors.border.withValues(alpha: 0.4),
          width: isActive ? 1.3 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.06),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check_rounded, color: accent, size: 25)
                        : Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                module.moduleNumber,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              _ModuleStatusLabel(
                                label: isCompleted
                                    ? 'مكتملة'
                                    : isActive
                                    ? 'الوحدة الحالية'
                                    : 'مغلقة',
                                color: accent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            module.title,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 17,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                              color: isLocked
                                  ? _LearningPathColors.muted
                                  : _LearningPathColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.subtitle,
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              color: _LearningPathColors.subtle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(module.progress * 100).round()}%',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 72,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: module.progress,
                          minHeight: 5,
                          backgroundColor: _LearningPathColors.surfaceHigh,
                          valueColor: AlwaysStoppedAnimation(accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${module.lessons.length} دروس',
                      style: _LearningPathTextStyles.monoSubtle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  module.description,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    height: 1.8,
                    color: _LearningPathColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetadataChip(
                          icon: Icons.schedule_rounded,
                          label: module.estimatedHours,
                        ),
                        _MetadataChip(
                          icon: Icons.bolt_rounded,
                          label: '${module.totalXp} XP',
                        ),
                        if (isLocked)
                          const _MetadataChip(
                            icon: Icons.lock_outline_rounded,
                            label: 'أكمل الوحدة السابقة',
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        TextButton.icon(
                          onPressed: onOpenOverview,
                          icon: const Icon(Icons.open_in_new_rounded, size: 15),
                          label: const Text('تفاصيل الوحدة'),
                          style: TextButton.styleFrom(
                            foregroundColor: _LearningPathColors.muted,
                            textStyle: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onToggle,
                          icon: Icon(
                            isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isExpanded ? 'إخفاء الدروس' : 'عرض الدروس',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _LearningPathColors.primary,
                            textStyle: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: _LearningPathColors.border.withValues(alpha: 0.45),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 650
                      ? 3
                      : constraints.maxWidth >= 400
                      ? 2
                      : 1;
                  final tileWidth =
                      (constraints.maxWidth - (columns - 1) * 10) / columns;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final lesson in module.lessons)
                        SizedBox(
                          width: tileWidth,
                          child: _LessonCard(
                            lesson: lesson,
                            glowAnimation: glowAnimation,
                            onTap: () => onSelectLesson?.call(lesson.id),
                          ),
                        ),
                      if (module.capstoneProject != null)
                        SizedBox(
                          width: constraints.maxWidth,
                          child: _CapstoneProjectCard(
                            project: module.capstoneProject!,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.glowAnimation,
    required this.onTap,
  });

  final CurriculumLessonNodeModel lesson;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = lesson.status == LessonNodeStatus.active;
    final isCompleted = lesson.status == LessonNodeStatus.completed;
    final accent = isCompleted
        ? _LearningPathColors.green
        : isActive
        ? _LearningPathColors.primary
        : _LearningPathColors.subtle;
    final background = isActive
        ? const Color(0xFF252A32)
        : _LearningPathColors.surface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: lesson.status == LessonNodeStatus.locked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? accent.withValues(alpha: 0.6)
                  : _LearningPathColors.border.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (isActive)
                    AnimatedBuilder(
                      animation: glowAnimation,
                      builder: (context, child) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(
                                alpha: glowAnimation.value,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.lock_outline_rounded,
                      size: 16,
                      color: accent,
                    ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      isCompleted
                          ? 'تم الإنجاز'
                          : isActive
                          ? 'الدرس الحالي'
                          : 'قريباً',
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '#${lesson.lessonNumber}',
                    style: _LearningPathTextStyles.monoSubtle,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lesson.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w700,
                  color: _LearningPathColors.text,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                lesson.briefDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  height: 1.65,
                  color: _LearningPathColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 6,
                runSpacing: 5,
                children: [
                  _MetadataChip(
                    icon: Icons.schedule_rounded,
                    label: lesson.durationMinutes,
                  ),
                  _MetadataChip(
                    icon: Icons.bolt_rounded,
                    label: '+${lesson.xpReward} XP',
                    color: _LearningPathColors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningPathInsights extends StatelessWidget {
  const _LearningPathInsights({
    required this.data,
    required this.activeLesson,
    required this.onStartReview,
    required this.onOpenWorkspace,
  });

  final LearningPathDataModel data;
  final CurriculumLessonNodeModel? activeLesson;
  final VoidCallback onStartReview;
  final VoidCallback onOpenWorkspace;

  @override
  Widget build(BuildContext context) {
    final completedModules = data.modules
        .where((module) => module.progress == 1)
        .length;
    final totalLessons = data.modules.fold<int>(
      0,
      (count, module) => count + module.lessons.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InsightPanel(
          title: 'لوحة الإتقان والإحصائيات',
          icon: Icons.insights_rounded,
          trailing: const _StatusPill(
            icon: Icons.circle,
            label: 'مباشر',
            color: _LearningPathColors.green,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      value: '${data.earnedXp}',
                      label: 'مجموع XP',
                      icon: Icons.diamond_rounded,
                      color: _LearningPathColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      value: '${data.streakDays}',
                      label: 'أيام متتالية',
                      icon: Icons.local_fire_department_rounded,
                      color: _LearningPathColors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      value: '$completedModules/${data.modules.length}',
                      label: 'وحدات مكتملة',
                      icon: Icons.check_circle_rounded,
                      color: _LearningPathColors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _LearningPathColors.background.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _LearningPathColors.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'توزيع المهارات المكتسبة',
                      style: _LearningPathTextStyles.monoSubtle,
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: CustomPaint(painter: _MasteryRadarPainter()),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 4,
                      children: [
                        Text(
                          'أعلى مهارة: الصياغة والأوامر (95%)',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 9,
                            color: _LearningPathColors.subtle,
                          ),
                        ),
                        Text(
                          'مستوى GDScript 4',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9,
                            color: _LearningPathColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _LearningPathColors.background.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _LearningPathColors.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'تقدّم الدروس',
                      style: _LearningPathTextStyles.monoMuted,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: totalLessons == 0
                                  ? 0
                                  : data.totalLessonsCompleted /
                                        data.totalLessonsCount.clamp(
                                          1,
                                          1 << 30,
                                        ),
                              minHeight: 7,
                              backgroundColor: _LearningPathColors.surfaceHigh,
                              valueColor: const AlwaysStoppedAnimation(
                                _LearningPathColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          data.overallProgressPercent,
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: _LearningPathColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${data.totalLessonsCompleted} من ${data.totalLessonsCount} درساً أُنجزت',
                      style: _LearningPathTextStyles.monoSubtle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InsightPanel(
          title: 'المراجعة التكرارية',
          icon: Icons.psychology_alt_rounded,
          trailing: const _ModuleStatusLabel(
            label: 'مراجعة يومية',
            color: _LearningPathColors.orange,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _LearningPathColors.background.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'خطوتك التالية',
                      style: _LearningPathTextStyles.monoSubtle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeLesson?.title ??
                          'استكشف دروس المسار واختر ما تريد مراجعته.',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: _LearningPathColors.text,
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (activeLesson != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        activeLesson!.briefDescription,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: _LearningPathColors.muted,
                          fontSize: 11,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onStartReview,
                icon: const Icon(Icons.quiz_rounded, size: 18),
                iconAlignment: .end,
                label: const Text('فتح خريطة المراجعة'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDB7619),
                  foregroundColor: const Color(0xFF301400),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  textStyle: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InsightPanel(
          title: 'إنجازاتك',
          icon: Icons.workspace_premium_rounded,
          trailing: Text(
            '${data.totalLessonsCompleted} درساً',
            style: _LearningPathTextStyles.monoSubtle,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AchievementTile(
                icon: Icons.terminal_rounded,
                title: 'أول خطوة',
                subtitle: data.totalLessonsCompleted > 0
                    ? 'بدأت التعلّم'
                    : 'ابدأ أول درس',
                color: data.totalLessonsCompleted > 0
                    ? _LearningPathColors.green
                    : _LearningPathColors.subtle,
                unlocked: data.totalLessonsCompleted > 0,
              ),
              _AchievementTile(
                icon: Icons.local_fire_department_rounded,
                title: 'المثابرة',
                subtitle: '${data.streakDays} أيام متتالية',
                color: data.streakDays > 0
                    ? _LearningPathColors.orange
                    : _LearningPathColors.subtle,
                unlocked: data.streakDays > 0,
              ),
              _AchievementTile(
                icon: Icons.school_rounded,
                title: 'إتقان وحدة',
                subtitle: '$completedModules من ${data.modules.length} مكتملة',
                color: completedModules > 0
                    ? _LearningPathColors.primary
                    : _LearningPathColors.subtle,
                unlocked: completedModules > 0,
              ),
              _AchievementTile(
                icon: Icons.menu_book_rounded,
                title: 'متعلم نشط',
                subtitle: '$totalLessons درساً في المسار',
                color: _LearningPathColors.muted,
                unlocked: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InsightPanel(
          title: 'بيئة العمل',
          icon: Icons.code_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: _LearningPathColors.green,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'محرك Godot متصل',
                      style: TextStyle(
                        color: _LearningPathColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text('v4.3', style: _LearningPathTextStyles.monoMuted),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _LearningPathColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.folder_rounded,
                      color: _LearningPathColors.green,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'مساحة العمل جاهزة لتطبيق الدروس',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: _LearningPathColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onOpenWorkspace,
                icon: const Icon(Icons.terminal_rounded, size: 17),
                label: const Text('فتح مساحة العمل'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _LearningPathColors.text,
                  side: BorderSide(
                    color: _LearningPathColors.border.withValues(alpha: 0.7),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MasteryRadarPainter extends CustomPainter {
  const _MasteryRadarPainter();

  static const _outerRing = [
    Offset(100, 20),
    Offset(176, 75),
    Offset(147, 165),
    Offset(53, 165),
    Offset(24, 75),
  ];
  static const _innerRing = [
    Offset(100, 50),
    Offset(148, 85),
    Offset(130, 140),
    Offset(70, 140),
    Offset(52, 85),
  ];
  static const _skillPoints = [
    Offset(100, 32),
    Offset(165, 80),
    Offset(115, 145),
    Offset(65, 130),
    Offset(38, 78),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.save();
    canvas.scale(scale, scale);

    final gridPaint = Paint()
      ..color = _LearningPathColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    _drawPolygon(canvas, _outerRing, gridPaint);
    _drawPolygon(canvas, _innerRing, gridPaint..strokeWidth = 0.9);

    final skillPaint = Paint()
      ..color = _LearningPathColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final skillFillPaint = Paint()
      ..color = _LearningPathColors.primary.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final skillPath = _polygonPath(_skillPoints);
    canvas.drawPath(skillPath, skillFillPaint);
    canvas.drawPath(skillPath, skillPaint);

    for (var index = 0; index < _skillPoints.length; index++) {
      final pointColor = index == 2 || index == 4
          ? _LearningPathColors.green
          : _LearningPathColors.primary;
      canvas.drawCircle(_skillPoints[index], 3.5, Paint()..color = pointColor);
    }

    _drawLabel(canvas, 'السينتاكس', const Offset(100, 5), TextAlign.center);
    _drawLabel(canvas, 'الأنواع', const Offset(178, 73), TextAlign.left);
    _drawLabel(canvas, 'المنطق', const Offset(145, 170), TextAlign.center);
    _drawLabel(canvas, 'الحلقات', const Offset(45, 170), TextAlign.center);
    _drawLabel(canvas, 'الهيكلة', const Offset(4, 73), TextAlign.left);

    canvas.restore();
  }

  void _drawPolygon(Canvas canvas, List<Offset> points, Paint paint) {
    canvas.drawPath(_polygonPath(points), paint);
  }

  Path _polygonPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position,
    TextAlign align,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 10,
          color: _LearningPathColors.muted,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: align,
    )..layout();

    final left = switch (align) {
      TextAlign.center => position.dx - textPainter.width / 2,
      TextAlign.left => position.dx,
      _ => position.dx - textPainter.width,
    };
    textPainter.paint(canvas, Offset(left, position.dy));
  }

  @override
  bool shouldRepaint(covariant _MasteryRadarPainter oldDelegate) => false;
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _LearningPathColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _LearningPathColors.border.withValues(alpha: 0.4),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: _LearningPathColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: _LearningPathColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 92),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
    decoration: BoxDecoration(
      color: _LearningPathColors.surfaceRaised,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 9,
            color: _LearningPathColors.muted,
          ),
        ),
      ],
    ),
  );
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width < 700) ? 160 : 142,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _LearningPathColors.surfaceRaised,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _LearningPathColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 9,
                    color: unlocked ? color : _LearningPathColors.subtle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FinalProjectCard extends StatelessWidget {
  const _FinalProjectCard({required this.isUnlocked, required this.onOpen});

  final bool isUnlocked;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF252A32), Color(0xFF1B2027), Color(0xFF252A32)],
          begin: AlignmentGeometry.centerStart,
          end: AlignmentGeometry.centerEnd,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _LearningPathColors.border.withValues(alpha: 0.55),
      ),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 14,
      spacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 490),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _LearningPathColors.orange.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: _LearningPathColors.orange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مشروع الإتقان النهائي',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: _LearningPathColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'لعبة مصغّرة متكاملة في Godot',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: _LearningPathColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'طبّق ما تعلمته في مشروع واحد يجمع أساسيات GDScript.',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: _LearningPathColors.muted,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onOpen,
          icon: Icon(
            isUnlocked ? Icons.rocket_launch_rounded : Icons.lock_rounded,
            size: 17,
          ),
          iconAlignment: .end,
          label: Text(isUnlocked ? 'ابدأ المشروع' : 'أكمل المسار لفتحه'),
          style: FilledButton.styleFrom(
            backgroundColor: isUnlocked
                ? _LearningPathColors.primary
                : _LearningPathColors.surfaceHigh,
            foregroundColor: isUnlocked
                ? const Color(0xFF003350)
                : _LearningPathColors.subtle,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            textStyle: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: 0.16)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? _LearningPathColors.primary
        : accent ?? _LearningPathColors.muted;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: selected ? const Color(0xFF002C46) : color,
        backgroundColor: selected
            ? _LearningPathColors.primary
            : _LearningPathColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        textStyle: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ModuleStatusLabel extends StatelessWidget {
  const _ModuleStatusLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    this.color = _LearningPathColors.muted,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: _LearningPathColors.background.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _LearningPathTextStyles {
  static const breadcrumb = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 11,
    color: _LearningPathColors.subtle,
  );
  static const monoMuted = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 10,
    color: _LearningPathColors.muted,
  );
  static const monoSubtle = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 9,
    color: _LearningPathColors.subtle,
  );
}

class _CapstoneProjectCard extends StatelessWidget {
  const _CapstoneProjectCard({required this.project});

  final CapstoneProjectModel project;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _LearningPathColors.surfaceRaised,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _LearningPathColors.orange.withValues(alpha: 0.25),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _LearningPathColors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.military_tech_rounded,
            color: _LearningPathColors.orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _LearningPathColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                project.description,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10,
                  height: 1.6,
                  color: _LearningPathColors.muted,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'المكافأة: +${project.xpReward} XP • ${project.badgeReward}',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10,
                  color: _LearningPathColors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
