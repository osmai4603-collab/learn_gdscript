// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 2: الرئيسية - لوحة التحكم الشاملة (Desktop Home Dashboard Screen)
// الملف: desktop_home_dashboard.dart
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/providers/home_dashboard_provider.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../widgets/code_editor/code_editor_widget.dart';
import '../../routers/app_routes.dart';
import '../../widgets/academy_metric_badge.dart';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات الخاصة باللوحة الرئيسية (Data Models)
// -----------------------------------------------------------------------------

class DashboardDataModel {
  final UserProgressModel userProgress;
  final ContinueLearningModel continueLesson;
  final List<UnitSummaryModel> units;
  final DailyChallengeModel dailyChallenge;
  final SpacedRepetitionSummaryModel reviewSummary;
  final QuickStatsModel quickStats;

  const DashboardDataModel({
    required this.userProgress,
    required this.continueLesson,
    required this.units,
    required this.dailyChallenge,
    required this.reviewSummary,
    required this.quickStats,
  });

  static DashboardDataModel sample() {
    return const DashboardDataModel(
      userProgress: UserProgressModel(
        userName: 'طارق الأحمد',
        userLevel: 'Godot v4.3 Dev (المستوى 4)',
        levelProgress: 0.67,
        currentXp: 420,
        nextLevelXp: 600,
        dailyStreak: 3,
        longestStreak: 12,
        activeProject: 'مشروع 2D Platformer Starter',
      ),
      continueLesson: ContinueLearningModel(
        unitId: 'u2',
        unitTitle: 'الوحدة 02: البنى الشرطية ومطابقة الأنماط',
        lessonId: 'l4',
        lessonTitle: 'الدرس 04: مطابقة الأنماط المتقدمة (match)',
        estimatedTime: '15 دقيقة',
        progress: 0.75,
        xpReward: 35,
        codeSnippetPreview:
            'match player_state:\n    "IDLE": velocity.x = 0.0\n    "RUN": velocity.x = 220.0',
      ),
      units: [
        UnitSummaryModel(
          number: '01',
          title: 'أول برنامج',
          description: 'الطباعة، بنية الدوال الأساسية، وربط السكربت الأول',
          completedLessons: 4,
          totalLessons: 4,
          isCompleted: true,
          isActive: false,
          isLocked: false,
        ),
        UnitSummaryModel(
          number: '02',
          title: 'المتغيرات والأنواع',
          description:
              'البيانات الرقمية، النصوص، المتجهات Vector2، والنوع الصارم',
          completedLessons: 5,
          totalLessons: 5,
          isCompleted: true,
          isActive: false,
          isLocked: false,
        ),
        UnitSummaryModel(
          number: '03',
          title: 'الشروط والقرارات',
          description: 'مقارنات المنطق، switch/match، والتنقل الشرطي',
          completedLessons: 3,
          totalLessons: 5,
          isCompleted: false,
          isActive: true,
          isLocked: false,
        ),
        UnitSummaryModel(
          number: '04',
          title: 'الحلقات والتكرار',
          description: 'حلقات for و while وقوائم الأعداء والمصفوفات (Arrays)',
          completedLessons: 0,
          totalLessons: 6,
          isCompleted: false,
          isActive: false,
          isLocked: true,
        ),
        UnitSummaryModel(
          number: '05',
          title: 'الدوال وإعادة الاستخدام',
          description:
              'بناء دوال مخصصة، إرجاع القيم، والإشارات Signals في جودو',
          completedLessons: 0,
          totalLessons: 5,
          isCompleted: false,
          isActive: false,
          isLocked: true,
        ),
      ],
      dailyChallenge: DailyChallengeModel(
        title: 'تحدي اليوم: صائد الأخطاء الدلالية (Bug Fix)',
        description:
            'اكتشف الخطأ في تعريف الإشارة المخصصة custom signal في Godot 4.3 قبل انتهاء الوقت.',
        timeRemaining: '04:22:15',
        xpBonus: 50,
        participantsCount: 142,
      ),
      reviewSummary: SpacedRepetitionSummaryModel(
        dueCardsCount: 8,
        retentionRatePercent: 92,
        estimatedMinutes: 5,
      ),
      quickStats: QuickStatsModel(
        codeLinesWritten: 840,
        completedChallenges: 19,
        earnedBadges: 4,
        totalBadges: 10,
      ),
    );
  }
}

class UserProgressModel {
  final String userName;
  final String userLevel;
  final double levelProgress;
  final int currentXp;
  final int nextLevelXp;
  final int dailyStreak;
  final int longestStreak;
  final String activeProject;
  final String currentUnitTitle;
  final int completedLessons;
  final int totalLessons;
  final double overallProgress;
  final DateTime? lastActiveDate;

  const UserProgressModel({
    required this.userName,
    required this.userLevel,
    required this.levelProgress,
    required this.currentXp,
    required this.nextLevelXp,
    required this.dailyStreak,
    required this.longestStreak,
    required this.activeProject,
    this.currentUnitTitle = '',
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.overallProgress = 0,
    this.lastActiveDate,
  });
}

class ContinueLearningModel {
  final String unitId;
  final String unitTitle;
  final String lessonId;
  final String lessonTitle;
  final String estimatedTime;
  final double progress;
  final int xpReward;
  final String codeSnippetPreview;

  const ContinueLearningModel({
    required this.unitId,
    required this.unitTitle,
    required this.lessonId,
    required this.lessonTitle,
    required this.estimatedTime,
    required this.progress,
    required this.xpReward,
    required this.codeSnippetPreview,
  });
}

class UnitSummaryModel {
  final String number;
  final String title;
  final String description;
  final int completedLessons;
  final int totalLessons;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;

  const UnitSummaryModel({
    required this.number,
    required this.title,
    required this.description,
    required this.completedLessons,
    required this.totalLessons,
    required this.isCompleted,
    required this.isActive,
    required this.isLocked,
  });

  double get progress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
}

class DailyChallengeModel {
  final String title;
  final String description;
  final String timeRemaining;
  final int xpBonus;
  final int participantsCount;

  const DailyChallengeModel({
    required this.title,
    required this.description,
    required this.timeRemaining,
    required this.xpBonus,
    required this.participantsCount,
  });
}

class SpacedRepetitionSummaryModel {
  final int dueCardsCount;
  final int retentionRatePercent;
  final int estimatedMinutes;

  const SpacedRepetitionSummaryModel({
    required this.dueCardsCount,
    required this.retentionRatePercent,
    required this.estimatedMinutes,
  });
}

class QuickStatsModel {
  final int codeLinesWritten;
  final int completedChallenges;
  final int earnedBadges;
  final int totalBadges;
  final List<DashboardBadgeModel> recentBadges;

  const QuickStatsModel({
    required this.codeLinesWritten,
    required this.completedChallenges,
    required this.earnedBadges,
    required this.totalBadges,
    this.recentBadges = const [],
  });
}

class DashboardBadgeModel {
  const DashboardBadgeModel({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;
}

// -----------------------------------------------------------------------------
// 2. الشاشة الرئيسية لسطح المكتب (DesktopHomeDashboardScreen)
// -----------------------------------------------------------------------------

class DesktopHomeDashboardScreen extends StatefulWidget {
  final DashboardDataModel data;
  final ValueChanged<String>? onNavigateRoute;
  final VoidCallback? onResumeLesson;
  final bool isLspConnected;
  final bool isLspConnecting;
  final String playgroundCode;
  final Future<void> Function(String code) onPlaygroundCodeChanged;

  const DesktopHomeDashboardScreen({
    super.key,
    required this.data,
    required this.isLspConnected,
    required this.isLspConnecting,
    required this.playgroundCode,
    required this.onPlaygroundCodeChanged,
    this.onNavigateRoute,
    this.onResumeLesson,
  });

  @override
  State<DesktopHomeDashboardScreen> createState() =>
      _DesktopHomeDashboardScreenState();
}

class _DesktopHomeDashboardScreenState extends State<DesktopHomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F141B),
      child: Column(
        children: [
          DashboardTopNav(
            streakDays: widget.data.userProgress.dailyStreak,
            xp: widget.data.userProgress.currentXp,
            userName: widget.data.userProgress.userName,
            isEngineConnected: widget.isLspConnected,
            isEngineConnecting: widget.isLspConnecting,
            onNavigate: widget.onNavigateRoute,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 700
                    ? 16.0
                    : 32.0;
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          24,
                          horizontalPadding,
                          32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _GreetingBanner(
                              userName: widget.data.userProgress.userName,
                              userProgress: widget.data.userProgress,
                              pulseAnimation: _pulseAnimation,
                            ),
                            const SizedBox(height: 24),
                            _ContinueLearningHeroCard(
                              continueData: widget.data.continueLesson,
                              onResume: widget.onResumeLesson,
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, gridConstraints) {
                                final playground = _QuickTryPlayground(
                                  initialCode: widget.playgroundCode,
                                  onCodeChanged: widget.onPlaygroundCodeChanged,
                                );
                                final curriculum = _CurriculumOverviewSection(
                                  units: widget.data.units,
                                  onExploreCurriculum: () => widget
                                      .onNavigateRoute
                                      ?.call(AppRoutes.learningPath),
                                  onSelectUnit: (unitNumber) {
                                    final number = int.tryParse(unitNumber);
                                    if (number == null) return;
                                    widget.onNavigateRoute?.call(
                                      AppRoutes.learningPath,
                                    );
                                  },
                                );
                                if (gridConstraints.maxWidth < 980) {
                                  return Column(
                                    children: [
                                      playground,
                                      const SizedBox(height: 24),
                                      curriculum,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: playground),
                                    const SizedBox(width: 24),
                                    Expanded(child: curriculum),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _DashboardBottomSection(
                              userProgress: widget.data.userProgress,
                              stats: widget.data.quickStats,
                              onViewBadges: () => widget.onNavigateRoute?.call(
                                AppRoutes.badges,
                              ),
                              onViewDiagnostics: () => widget.onNavigateRoute
                                  ?.call(AppRoutes.workspace),
                              isEngineConnected: widget.isLspConnected,
                              isEngineConnecting: widget.isLspConnecting,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. المكونات المستقلة للواجهة (Modular Widgets)
// -----------------------------------------------------------------------------

/// الشريط العلوي العام للوحة التحكم
class DashboardTopNav extends StatelessWidget {
  final int streakDays;
  final int xp;
  final String userName;
  final bool isEngineConnected;
  final bool isEngineConnecting;
  final ValueChanged<String>? onNavigate;

  const DashboardTopNav({
    super.key,
    required this.streakDays,
    required this.xp,
    required this.userName,
    required this.isEngineConnected,
    required this.isEngineConnecting,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor = isEngineConnecting
        ? const Color(0xFFFFB783)
        : isEngineConnected
        ? const Color(0xFF4AE183)
        : const Color(0xFF8A919A);
    final statusText = isEngineConnecting
        ? l10n.dashboardLspConnecting
        : isEngineConnected
        ? l10n.dashboardLspActive
        : l10n.dashboardLspDisconnected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141B).withValues(alpha: 0.94),
        border: const Border(bottom: BorderSide(color: Color(0xFF252A32))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          InkWell(
            onTap: () => onNavigate?.call(AppRoutes.workspace),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2027),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  CircleAvatar(radius: 4, backgroundColor: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcademyMetricBadge(
                icon: Icons.local_fire_department_rounded,
                text: l10n.dashboardDays(streakDays),
                color: const Color(0xFFFFB783),
              ),
              const SizedBox(width: 8),
              AcademyMetricBadge(
                icon: Icons.diamond_rounded,
                text: '$xp XP',
                color: const Color(0xFFFFB783),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => onNavigate?.call(AppRoutes.settings),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5397CA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          userName.isEmpty ? '?' : userName[0],
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002C46),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        color: Color(0xFFDEE2EC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// لافتة الترحيب الشخصية
class _GreetingBanner extends StatelessWidget {
  final String userName;
  final UserProgressModel userProgress;
  final Animation<double> pulseAnimation;

  const _GreetingBanner({
    required this.userName,
    required this.userProgress,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardWelcomeBack(userName),
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE2E8F0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.dashboardWelcomeMessage,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 14,
            color: Color(0xFFC0C7D0),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _WelcomeMetric(
              icon: Icons.account_tree_rounded,
              label: l10n.dashboardCurrentUnit,
              value: userProgress.currentUnitTitle,
              color: const Color(0xFF91CDFF),
            ),
            _WelcomeMetric(
              icon: Icons.trending_up_rounded,
              label: l10n.dashboardPercentComplete(
                (userProgress.overallProgress * 100).toInt(),
              ),
              color: const Color(0xFF4AE183),
            ),
            _WelcomeMetric(
              icon: Icons.military_tech_rounded,
              label: userProgress.userLevel,
              color: const Color(0xFFFFB783),
            ),
          ],
        ),
      ],
    );
    final levelProgress = ScaleTransition(
      scale: pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF090F15),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: userProgress.levelProgress,
                    strokeWidth: 4,
                    backgroundColor: const Color(0xFF252A32),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF91CDFF)),
                  ),
                  Center(
                    child: Text(
                      '${(userProgress.levelProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDEE2EC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardNextLevel,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDEE2EC),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.dashboardLessonsCompleted(
                    userProgress.completedLessons,
                    userProgress.totalLessons,
                  ),
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: Color(0xFF8A919A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.dashboardXpToNextLevel(userProgress.nextLevelXp),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: Color(0xFF4AE183),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF252A32), Color(0xFF1B2027), Color(0xFF171C23)],
          begin: AlignmentGeometry.centerStart,
          end: AlignmentGeometry.centerEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF40484F)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 760
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  greeting,
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: levelProgress,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: greeting),
                  const SizedBox(width: 16),
                  levelProgress,
                ],
              ),
      ),
    );
  }
}

class _WelcomeMetric extends StatelessWidget {
  const _WelcomeMetric({
    required this.icon,
    required this.label,
    required this.color,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF30353D).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          if (value != null)
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDEE2EC),
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: color,
                ),
              ),
            ),
          if (value != null) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// بطاقة الاستئناف الرئيسية المتألقة (Continue Learning Hero Card)
class _ContinueLearningHeroCard extends StatelessWidget {
  final ContinueLearningModel continueData;
  final VoidCallback? onResume;

  const _ContinueLearningHeroCard({required this.continueData, this.onResume});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF91CDFF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                continueData.unitTitle,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF91CDFF),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  continueData.estimatedTime,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.diamond_rounded,
                  size: 14,
                  color: Color(0xFFA855F7),
                ),
                const SizedBox(width: 4),
                Text(
                  '+${continueData.xpReward} XP',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA855F7),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          continueData.lessonTitle,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE2E8F0),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: continueData.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1F2630),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF22C55E),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.dashboardPercentComplete(
                (continueData.progress * 100).toInt(),
              ),
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l10n.dashboardContinueDescription,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: Color(0xFF8A919A),
          ),
        ),
      ],
    );
    final actions = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onResume,
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 20,
              textDirection: Directionality.of(context) == .ltr ? .rtl : .ltr,
            ),
            iconAlignment: .end,
            label: Text(
              l10n.dashboardContinueAction,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF91CDFF),
              foregroundColor: const Color(0xFF003350),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.dashboardDraftAutoSaved,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            color: Color(0xFF8A919A),
          ),
        ),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2027),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30353D)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 760
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [details, const SizedBox(height: 20), actions],
              )
            : Row(
                children: [
                  Expanded(flex: 6, child: details),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: actions),
                ],
              ),
      ),
    );
  }
}

/// بطاقة تحدي اليوم البرمجي
class DashboardDailyChallengeCard extends StatelessWidget {
  final DailyChallengeModel challenge;
  final VoidCallback onStartChallenge;

  const DashboardDailyChallengeCard({
    super.key,
    required this.challenge,
    required this.onStartChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28323F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.military_tech_rounded,
                    size: 20,
                    color: Color(0xFFF59E0B),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'تحدي اليوم السريع',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2630),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: Color(0xFFFB923C),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      challenge.timeRemaining,
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        color: Color(0xFFFB923C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge.title,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            challenge.description,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'شارك ${challenge.participantsCount} مطوراً اليوم',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
              ElevatedButton(
                onPressed: onStartChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2630),
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B), width: 0.8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'خوض التحدي (+${challenge.xpBonus} XP)',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// بطاقة المراجعة الذكية والتكرار المتباعد SM-2
class DashboardSpacedRepetitionCard extends StatelessWidget {
  final SpacedRepetitionSummaryModel review;
  final VoidCallback onStartReview;

  const DashboardSpacedRepetitionCard({
    super.key,
    required this.review,
    required this.onStartReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28323F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.psychology_rounded,
                size: 20,
                color: Color(0xFF38BDF8),
              ),
              SizedBox(width: 8),
              Text(
                'المراجعة الذكية (SM-2)',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'لديك ${review.dueCardsCount} بطاقات مفاهيم مستحقة للمراجعة اليوم لتثبيت الذاكرة طويلة المدى.',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF14532D),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'معدل الاسترجاع ${review.retentionRatePercent}%',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '~${review.estimatedMinutes} دقائق',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2630),
                foregroundColor: const Color(0xFF38BDF8),
                side: const BorderSide(color: Color(0xFF38BDF8), width: 0.8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'بدء جلسة المراجعة السريعة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة الإحصائيات والأوسمة
class DashboardQuickStatsCard extends StatelessWidget {
  final QuickStatsModel stats;
  final VoidCallback onViewBadges;

  const DashboardQuickStatsCard({
    super.key,
    required this.stats,
    required this.onViewBadges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28323F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.insights_rounded,
                    size: 20,
                    color: Color(0xFFA855F7),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'إحصائياتك البرمجية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewBadges,
                child: const Text(
                  'الأوسمة ↵',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: Color(0xFF478CBF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatRow(
            title: 'أسطر كود GDScript مكتوبة:',
            value: '${stats.codeLinesWritten} سطر',
          ),
          const SizedBox(height: 8),
          _StatRow(
            title: 'تحديات برمجية تم اجتيازها:',
            value: '${stats.completedChallenges} تحدٍّ',
          ),
          const SizedBox(height: 8),
          _StatRow(
            title: 'أوسمة مكتسبة معتمدة:',
            value: '${stats.earnedBadges} من ${stats.totalBadges} أوسمة',
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.earnedBadges / stats.totalBadges,
              minHeight: 5,
              backgroundColor: const Color(0xFF1F2630),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA855F7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String title;
  final String value;

  const _StatRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}

/// قسم فهرس الوحدات التعليمية
class _CurriculumOverviewSection extends StatelessWidget {
  final List<UnitSummaryModel> units;
  final VoidCallback onExploreCurriculum;
  final ValueChanged<String> onSelectUnit;

  const _CurriculumOverviewSection({
    required this.units,
    required this.onExploreCurriculum,
    required this.onSelectUnit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardCurriculumTitle,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE2E8F0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.dashboardCurriculumDescription,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
    final pathAction = TextButton.icon(
      onPressed: onExploreCurriculum,
      icon: const Icon(Icons.arrow_back_rounded, size: 16),
      label: Text(
        l10n.dashboardViewFullPath,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 13,
        ),
      ),
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF478CBF)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 620
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heading,
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: pathAction,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: heading),
                    pathAction,
                  ],
                ),
        ),
        const SizedBox(height: 16),

        // قائمة بطاقات الوحدات الخمس
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: units.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final unit = units[index];
            return _UnitProgressTile(
              unit: unit,
              onTap: () => onSelectUnit(unit.number),
            );
          },
        ),
      ],
    );
  }
}

class _UnitProgressTile extends StatelessWidget {
  final UnitSummaryModel unit;
  final VoidCallback onTap;

  const _UnitProgressTile({required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFF28323F);
    Color badgeColor = const Color(0xFF1F2630);
    Color textColor = const Color(0xFFE2E8F0);

    if (unit.isActive) {
      borderColor = const Color(0xFF478CBF);
      badgeColor = const Color(0xFF478CBF).withValues(alpha: 0.2);
    } else if (unit.isCompleted) {
      borderColor = const Color(0xFF22C55E).withValues(alpha: 0.4);
      badgeColor = const Color(0xFF14532D);
    } else if (unit.isLocked) {
      textColor = const Color(0xFF64748B);
    }

    return InkWell(
      onTap: unit.isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131922),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // رقم وشارة الوحدة
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: unit.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF22C55E),
                        size: 20,
                      )
                    : unit.isLocked
                    ? const Icon(
                        Icons.lock_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      )
                    : Text(
                        unit.number,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF478CBF),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // عنوان الوحدة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.title,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 14,
                      fontWeight: unit.isActive
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unit.description,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            // مؤشر التقدم
            SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(unit.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: unit.isCompleted
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: unit.progress,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF1F2630),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        unit.isCompleted
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF478CBF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              unit.isActive
                  ? Icons.arrow_back_rounded
                  : Icons.chevron_left_rounded,
              color: unit.isLocked
                  ? const Color(0xFF478CBF).withValues(alpha: 0.2)
                  : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTryPlayground extends StatefulWidget {
  const _QuickTryPlayground({
    required this.initialCode,
    required this.onCodeChanged,
  });

  final String initialCode;
  final Future<void> Function(String code) onCodeChanged;

  @override
  State<_QuickTryPlayground> createState() => _QuickTryPlaygroundState();
}

class _QuickTryPlaygroundState extends State<_QuickTryPlayground> {
  late String _code = widget.initialCode;
  int _runCount = 0;
  String? _output;
  bool? _lastRunSucceeded;
  bool _isRunning = false;

  Future<void> _saveCode(String code) async {
    _code = code;
    try {
      await widget.onCodeChanged(code);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dashboardSaveError('$error'))),
      );
    }
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = null;
      _lastRunSucceeded = null;
    });
    try {
      final result = await context.read<CodeRunnerService>().runCode(_code);
      if (!mounted) return;
      setState(() {
        _output = result.isSuccess
            ? result.output.join('\n')
            : result.errorMessage ?? context.l10n.dashboardExecutionFailed;
        _lastRunSucceeded = result.isSuccess;
        _runCount++;
        _isRunning = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _output = context.l10n.dashboardExecutionError('$error');
        _lastRunSucceeded = false;
        _isRunning = false;
      });
    }
  }

  void _resetCode() {
    setState(() {
      _code = HomeDashboardProvider.defaultPlaygroundCode;
      _output = null;
      _lastRunSucceeded = null;
    });
    _saveCode(_code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2027),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30353D)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF252A32),
            child: Row(
              children: [
                const _WindowDots(),
                const SizedBox(width: 12),
                const Icon(
                  Icons.data_object_rounded,
                  size: 18,
                  color: Color(0xFF91CDFF),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'player_controller.gd',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC0C7D0),
                    ),
                  ),
                ),
                const _MonoTag(label: 'Godot 4.3'),
                IconButton(
                  tooltip: l10n.dashboardPlaygroundReset,
                  onPressed: _resetCode,
                  icon: const Icon(Icons.restart_alt_rounded, size: 20),
                  color: const Color(0xFF8A919A),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            color: const Color(0xFF090F15),
            child: Directionality(
              textDirection: .ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CodeLine(
                    number: '1',
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          color: Color(0xFFDEE2EC),
                        ),
                        children: [
                          const TextSpan(
                            text: 'var ',
                            style: TextStyle(
                              color: Color(0xFFFFB783),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: 'player_health = '),
                          TextSpan(
                            text: '75',
                            style: const TextStyle(
                              color: Color(0xFFFFB783),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _CodeLine(
                    number: '2',
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'if ',
                            style: TextStyle(
                              color: Color(0xFF91CDFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: 'player_health ',
                            style: TextStyle(color: Color(0xFFDEE2EC)),
                          ),
                          TextSpan(
                            text: '> 50:',
                            style: TextStyle(color: Color(0xFF8A919A)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _CodeLine(
                    number: '3',
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '    print',
                            style: TextStyle(
                              color: Color(0xFF4AE183),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '("اللاعب بصحة جيدة! ❤️")',
                            style: TextStyle(color: Color(0xFF6BFE9C)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '# جرّب التشغيل لتغيير قيمة صحة اللاعب',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF8A919A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CodeEditorWidget(
                    initialCode: _code,
                    fontSize: 13,
                    showLineNumbers: true,
                    showActionBar: false,
                    onChanged: _saveCode,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF252A32),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF4AE183),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.dashboardExampleTag,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            color: Color(0xFFC0C7D0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runCode,
                  icon: Icon(
                    _isRunning
                        ? Icons.hourglass_top_rounded
                        : Icons.play_arrow_rounded,
                    size: 18,
                    textDirection: Directionality.of(context) == .ltr
                        ? .rtl
                        : .ltr,
                  ),
                  iconAlignment: .end,
                  label: Text(
                    _isRunning
                        ? l10n.dashboardPlaygroundRunning
                        : l10n.dashboardPlaygroundRun,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF91CDFF),
                    foregroundColor: const Color(0xFF003350),
                    textStyle: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF090F15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.terminal_rounded,
                      size: 16,
                      color: Color(0xFF4AE183),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.dashboardPlaygroundOutputTitle,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11,
                          color: Color(0xFFC0C7D0),
                        ),
                      ),
                    ),
                    _MonoTag(label: l10n.dashboardExampleTag),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2027),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        Icon(
                          _lastRunSucceeded == null
                              ? Icons.info_outline_rounded
                              : _lastRunSucceeded!
                              ? Icons.check_circle_outline_rounded
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: _lastRunSucceeded == null
                              ? const Color(0xFF8A919A)
                              : _lastRunSucceeded!
                              ? const Color(0xFF4AE183)
                              : const Color(0xFFFFB783),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isRunning
                                ? l10n.dashboardPlaygroundOutputRunning
                                : _runCount == 0
                                ? l10n.dashboardPlaygroundOutputEmpty
                                : _output?.isNotEmpty == true
                                ? _output!
                                : l10n.dashboardPlaygroundOutputSuccess,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12,
                              color: _lastRunSucceeded == false
                                  ? const Color(0xFFFFB783)
                                  : _lastRunSucceeded == true
                                  ? const Color(0xFF4AE183)
                                  : const Color(0xFFC0C7D0),
                            ),
                          ),
                        ),
                        if (_runCount > 0)
                          Text(
                            '$_runCount',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              color: Color(0xFF8A919A),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({required this.number, required this.child});

  final String number;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                color: Color(0xFF8A919A),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _WindowDots extends StatelessWidget {
  const _WindowDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowDot(color: Color(0xFFFFB4AB)),
        SizedBox(width: 5),
        _WindowDot(color: Color(0xFFFFB783)),
        SizedBox(width: 5),
        _WindowDot(color: Color(0xFF4AE183)),
      ],
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 5, backgroundColor: color);
  }
}

class _MonoTag extends StatelessWidget {
  const _MonoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF30353D),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 9,
          color: Color(0xFF8A919A),
        ),
      ),
    );
  }
}

class _DashboardBottomSection extends StatelessWidget {
  const _DashboardBottomSection({
    required this.userProgress,
    required this.stats,
    required this.onViewBadges,
    required this.onViewDiagnostics,
    required this.isEngineConnected,
    required this.isEngineConnecting,
  });

  final UserProgressModel userProgress;
  final QuickStatsModel stats;
  final VoidCallback onViewBadges;
  final VoidCallback onViewDiagnostics;
  final bool isEngineConnected;
  final bool isEngineConnecting;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _AchievementsCard(stats: stats, onViewBadges: onViewBadges),
          _StreakCard(
            streakDays: userProgress.dailyStreak,
            lastActiveDate: userProgress.lastActiveDate,
          ),
          _EngineStatusCard(
            onTap: onViewDiagnostics,
            isConnected: isEngineConnected,
            isConnecting: isEngineConnecting,
          ),
        ];
        if (constraints.maxWidth < 1050) {
          return Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                if (index > 0) const SizedBox(height: 16),
                cards[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              if (index > 0) const SizedBox(width: 16),
              Expanded(child: cards[index]),
            ],
          ],
        );
      },
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2027),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30353D)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard({required this.stats, required this.onViewBadges});

  final QuickStatsModel stats;
  final VoidCallback onViewBadges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 20,
                color: Color(0xFFFFB783),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.dashboardRecentBadges,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDEE2EC),
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewBadges,
                child: Text(
                  l10n.dashboardBadgeCount(
                    stats.earnedBadges,
                    stats.totalBadges,
                  ),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: Color(0xFF8A919A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var index = 0; index < 2; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: index < stats.recentBadges.length
                      ? _AchievementBadge(
                          emoji: stats.recentBadges[index].emoji,
                          title: stats.recentBadges[index].title,
                          subtitle: stats.recentBadges[index].description,
                        )
                      : _AchievementBadge(
                          emoji: '◇',
                          title: l10n.dashboardNoBadges,
                          subtitle: l10n.dashboardEarnBadges,
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF252A32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 7),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDEE2EC),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 9,
                    color: Color(0xFF8A919A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streakDays, required this.lastActiveDate});

  final int streakDays;
  final DateTime? lastActiveDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = lastActiveDate == null
        ? null
        : DateTime(
            lastActiveDate!.year,
            lastActiveDate!.month,
            lastActiveDate!.day,
          );
    final days = [
      for (var index = 4; index >= 0; index--)
        today.subtract(Duration(days: index)),
    ];
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: Color(0xFFDB7619),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.dashboardStreak,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDEE2EC),
                  ),
                ),
              ),
              Text(
                l10n.dashboardConsecutiveDays(streakDays),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  color: Color(0xFFFFB783),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in days)
                _StreakDay(
                  day: intl.DateFormat.E(locale).format(day),
                  isDone:
                      lastActive != null &&
                      !day.isAfter(lastActive) &&
                      lastActive.difference(day).inDays < streakDays,
                  isToday: day == today,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakDay extends StatelessWidget {
  const _StreakDay({
    required this.day,
    required this.isDone,
    required this.isToday,
  });

  final String day;
  final bool isDone;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final color = isDone ? const Color(0xFFFFB783) : const Color(0xFF30353D);
    return Opacity(
      opacity: isDone ? 1 : 0.45,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isToday ? 1 : 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isDone ? '✓' : '○',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isToday && isDone ? const Color(0xFF4F2500) : color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            day,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 9,
              color: isToday
                  ? const Color(0xFFDEE2EC)
                  : const Color(0xFF8A919A),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineStatusCard extends StatelessWidget {
  const _EngineStatusCard({
    required this.onTap,
    required this.isConnected,
    required this.isConnecting,
  });

  final VoidCallback onTap;
  final bool isConnected;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor = isConnecting
        ? const Color(0xFFFFB783)
        : isConnected
        ? const Color(0xFF4AE183)
        : const Color(0xFF8A919A);
    final statusLabel = isConnecting
        ? l10n.dashboardEngineConnecting
        : isConnected
        ? l10n.dashboardEngineConnected
        : l10n.dashboardEngineDisconnected;
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.memory_rounded,
                    size: 20,
                    color: Color(0xFF91CDFF),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.dashboardEngineTitle,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDEE2EC),
                      ),
                    ),
                  ),
                  CircleAvatar(radius: 4, backgroundColor: statusColor),
                  const SizedBox(width: 5),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF090F15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _EngineDetail(
                  label: '${l10n.dashboardRuntime}:',
                  value: l10n.dashboardLocal,
                ),
                const SizedBox(height: 7),
                _EngineDetail(
                  label: '${l10n.dashboardLsp}:',
                  value: statusLabel,
                  valueColor: statusColor,
                ),
                const SizedBox(height: 7),
                _EngineDetail(
                  label: '${l10n.dashboardWorkspace}:',
                  value: '—',
                  valueColor: Color(0xFF91CDFF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineDetail extends StatelessWidget {
  const _EngineDetail({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFDEE2EC),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              color: Color(0xFF8A919A),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
