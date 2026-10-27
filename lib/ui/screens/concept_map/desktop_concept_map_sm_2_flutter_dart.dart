// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 9: خريطة المفاهيم البصرية ونظام المراجعة الذكية والتكرار المتباعد SM-2
// الملف: desktop_concept_map_sm2_screen.dart
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';
import 'package:learn_gdscript/core/theme/color_schemes.dart';
import 'package:learn_gdscript/data/models/review_schedule.dart';
import 'package:learn_gdscript/ui/routers/app_routes.dart';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات الخاصة بخريطة المفاهيم ونظام SM-2 (Data Models)
// -----------------------------------------------------------------------------

enum ConceptMasteryLevel { locked, learning, reviewing, mastered }

class KnowledgeConceptNodeModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String category;
  final String? categoryEn;
  final ConceptMasteryLevel mastery;
  final double? retentionPercent;
  final int? daysUntilNextReview;
  final String lastReviewedDate;
  final String description;
  final String? descriptionEn;
  final String codeExample;
  final String? lessonId;
  final List<String> prerequisites;
  final Offset visualPosition; // لإحداثيات الرسم البياني للشجرة

  const KnowledgeConceptNodeModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.category,
    this.categoryEn,
    required this.mastery,
    required this.retentionPercent,
    required this.daysUntilNextReview,
    required this.lastReviewedDate,
    required this.description,
    this.descriptionEn,
    required this.codeExample,
    this.lessonId,
    required this.prerequisites,
    required this.visualPosition,
  });
}

class Sm2FlashcardItemModel {
  final String id;
  final String conceptId;
  final String promptQuestion;
  final String? promptQuestionEn;
  final String codeContext;
  final String answerExplanation;
  final String? answerExplanationEn;
  final String answerCode;
  final int repetitionCount;
  final double easinessFactor; // عامل السهولة EF وفق خوارزمية SM-2
  final int currentIntervalDays;

  const Sm2FlashcardItemModel({
    required this.id,
    required this.conceptId,
    required this.promptQuestion,
    this.promptQuestionEn,
    required this.codeContext,
    required this.answerExplanation,
    this.answerExplanationEn,
    this.answerCode = '',
    required this.repetitionCount,
    required this.easinessFactor,
    required this.currentIntervalDays,
  });
}

class ConceptMapSm2DataModel {
  final int totalConceptsCount;
  final int masteredConceptsCount;
  final int dueTodayCardsCount;
  final double? averageRetentionRate;
  final int streakDays;
  final int xp;
  final List<KnowledgeConceptNodeModel> concepts;
  final List<Sm2FlashcardItemModel> activeReviewDeck;
  final String selectedConceptId;

  const ConceptMapSm2DataModel({
    required this.totalConceptsCount,
    required this.masteredConceptsCount,
    required this.dueTodayCardsCount,
    required this.averageRetentionRate,
    required this.streakDays,
    required this.xp,
    required this.concepts,
    required this.activeReviewDeck,
    required this.selectedConceptId,
  });

  KnowledgeConceptNodeModel? get activeConcept {
    if (concepts.isEmpty) return null;
    for (final concept in concepts) {
      if (concept.id == selectedConceptId) return concept;
    }
    return concepts.first;
  }

  static ConceptMapSm2DataModel sampleData() {
    return const ConceptMapSm2DataModel(
      totalConceptsCount: 32,
      masteredConceptsCount: 18,
      dueTodayCardsCount: 8,
      averageRetentionRate: 0.92,
      streakDays: 3,
      xp: 420,
      selectedConceptId: 'c_match',
      activeReviewDeck: [
        Sm2FlashcardItemModel(
          id: 'card_1',
          conceptId: 'c_match',
          promptQuestion:
              'ما هو دور النمط الشامل _ (Wildcard) في بنية match في GDScript 2.0؟',
          codeContext: '''match player_state:
    "IDLE": velocity.x = 0.0
    "RUN": velocity.x = 240.0
    _: handle_fallback()''',
          answerExplanation:
              'يعمل النمط _ كحالة افتراضية (Default Fallback) يلتقط أي مدخل لا يتطابق مع الأنماط الصريحة المعرفة مسبقاً، ويمنع استثناءات عدم التطابق.',
          repetitionCount: 4,
          easinessFactor: 2.5,
          currentIntervalDays: 6,
        ),
        Sm2FlashcardItemModel(
          id: 'card_2',
          conceptId: 'c_static_typing',
          promptQuestion:
              'كيف تعلن عن دالة تعيد نوعاً صارماً ولا ترجع أي قيمة؟',
          codeContext: 'func update_hud(score: int) -> ???:',
          answerExplanation:
              'استخدام سهم التحديد الصريح مع الكلمة المحجوزة void: -> void لضمان السلامة البرمجية أثناء الترجمة.',
          repetitionCount: 5,
          easinessFactor: 2.6,
          currentIntervalDays: 10,
        ),
      ],
      concepts: [
        KnowledgeConceptNodeModel(
          id: 'c_print',
          titleAr: 'دالة print() والمخرجات',
          titleEn: 'Standard I/O & print',
          category: 'الأساسيات',
          mastery: ConceptMasteryLevel.mastered,
          retentionPercent: 0.98,
          daysUntilNextReview: 14,
          lastReviewedDate: 'قبل 3 أيام',
          description:
              'طباعة الرسائل والقيم إلى نافذة الإخراج Debug Console للتحقق من سلامة التنفيذ.',
          codeExample: 'print("مرحباً بمحرك Godot 4.3")',
          prerequisites: [],
          visualPosition: Offset(60, 100),
        ),
        KnowledgeConceptNodeModel(
          id: 'c_static_typing',
          titleAr: 'الأنواع الصارمة (Static Typing)',
          titleEn: 'Static Typing System',
          category: 'الأنواع والمتغيرات',
          mastery: ConceptMasteryLevel.mastered,
          retentionPercent: 0.94,
          daysUntilNextReview: 7,
          lastReviewedDate: 'أمس',
          description:
              'تحديد نوع البيانات الصريح للمتغيرات والمعاملات لتمكين محلل GDScript وتحسين أداء JIT.',
          codeExample:
              'var speed: float = 300.0\nvar player_name: String = "Tariq"',
          prerequisites: ['c_print'],
          visualPosition: Offset(220, 100),
        ),
        KnowledgeConceptNodeModel(
          id: 'c_vector2',
          titleAr: 'المتجهات ثنائية الأبعاد (Vector2)',
          titleEn: 'Vector2 Mathematics',
          category: 'الرياضيات والفيزياء',
          mastery: ConceptMasteryLevel.mastered,
          retentionPercent: 0.91,
          daysUntilNextReview: 4,
          lastReviewedDate: 'قبل يومين',
          description:
              'بنية هندسية لحساب الموقع والسرعة والتطبيع (Normalized) والمسافات في الفضاء 2D.',
          codeExample: 'var dir: Vector2 = Vector2.RIGHT * speed',
          prerequisites: ['c_static_typing'],
          visualPosition: Offset(380, 80),
        ),
        KnowledgeConceptNodeModel(
          id: 'c_match',
          titleAr: 'مطابقة الأنماط (match Statement)',
          titleEn: 'Pattern Matching & match',
          category: 'التدفق المنطقي',
          mastery: ConceptMasteryLevel.reviewing,
          retentionPercent: 0.85,
          daysUntilNextReview: 0, // مستحقة اليوم
          lastReviewedDate: 'اليوم',
          description:
              'صياغة متقدمة للتحكم في التدفق وبناء آلات الحالات المحدودة وبديل فائق لـ switch/case.',
          codeExample:
              'match state:\n    "IDLE": velocity.x = 0.0\n    _: move()',
          prerequisites: ['c_static_typing'],
          visualPosition: Offset(380, 220),
        ),
        KnowledgeConceptNodeModel(
          id: 'c_signals',
          titleAr: 'نظام الإشارات (Custom Signals)',
          titleEn: 'Observer Signals & Callable',
          category: 'المعمارية والأحداث',
          mastery: ConceptMasteryLevel.learning,
          retentionPercent: 0.65,
          daysUntilNextReview: 1,
          lastReviewedDate: 'لم تراجع بعد',
          description:
              'معمارية الاتصال غير المتزامن بين العقد (Loose Coupling) عبر إطلاق واستقبال الأحداث.',
          codeExample:
              'signal health_changed(new_hp: int)\nhealth_changed.emit(85)',
          prerequisites: ['c_match'],
          visualPosition: Offset(540, 160),
        ),
        KnowledgeConceptNodeModel(
          id: 'c_physics',
          titleAr: 'معالجة الحركة الفيزيائية (_physics_process)',
          titleEn: '2D Physics & Kinematics',
          category: 'المحرك والحركة',
          mastery: ConceptMasteryLevel.locked,
          retentionPercent: 0.0,
          daysUntilNextReview: 0,
          lastReviewedDate: 'مغلق',
          description:
              'دورة المعالجة الفيزيائية المتزامنة مع محرك الاصطدام ودوال move_and_slide().',
          codeExample:
              'func _physics_process(delta: float) -> void:\n    move_and_slide()',
          prerequisites: ['c_vector2', 'c_signals'],
          visualPosition: Offset(700, 160),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. الشاشة الرئيسية لخريطة المفاهيم و SM-2 (DesktopConceptMapSm2Screen)
// -----------------------------------------------------------------------------

class DesktopConceptMapSm2Screen extends StatefulWidget {
  final ConceptMapSm2DataModel data;
  final ValueChanged<String> onNavigateRoute;
  final ValueChanged<String>? onSelectConcept;
  final Future<void> Function(String cardId, Sm2Rating rating) onRateCard;
  final bool isSavingRating;

  const DesktopConceptMapSm2Screen({
    super.key,
    required this.data,
    required this.onNavigateRoute,
    required this.onRateCard,
    this.onSelectConcept,
    this.isSavingRating = false,
  });

  @override
  State<DesktopConceptMapSm2Screen> createState() =>
      _DesktopConceptMapSm2ScreenState();
}

class _DesktopConceptMapSm2ScreenState
    extends State<DesktopConceptMapSm2Screen> {
  late String _selectedConceptId;
  bool _isReviewDeckMode = false;
  int _activeCardIndex = 0;
  bool _isAnswerRevealed = false;

  @override
  void initState() {
    super.initState();
    _selectedConceptId = widget.data.selectedConceptId;
  }

  @override
  void didUpdateWidget(covariant DesktopConceptMapSm2Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.data.concepts.any(
      (concept) => concept.id == _selectedConceptId,
    )) {
      _selectedConceptId = widget.data.selectedConceptId;
    }
    if (_activeCardIndex >= widget.data.activeReviewDeck.length) {
      _activeCardIndex = 0;
    }
  }

  Future<void> _handleRating(Sm2Rating rating) async {
    if (widget.isSavingRating ||
        _activeCardIndex >= widget.data.activeReviewDeck.length) {
      return;
    }
    final currentCard = widget.data.activeReviewDeck[_activeCardIndex];
    final remainingCards = widget.data.activeReviewDeck.length;
    try {
      await widget.onRateCard(currentCard.id, rating);
      if (!mounted) return;
      setState(() {
        _isAnswerRevealed = false;
        _activeCardIndex = 0;
        if (remainingCards <= 1) {
          _isReviewDeckMode = false;
        }
      });
      if (remainingCards <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.successContainer,
            content: Text(
              _conceptMapCopy(
                context,
                'اكتملت جلسة المراجعة.',
                'Review session complete.',
              ),
            ),
          ),
        );
      }
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _conceptMapCopy(
              context,
              'تعذر حفظ التقييم. حاول مرة أخرى.',
              'Could not save the rating. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeConcept = widget.data.activeConcept;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // 1. الشريط العلوي العام
          _ConceptMapTopNav(
            streakDays: widget.data.streakDays,
            xp: widget.data.xp,
            dueTodayCount: widget.data.dueTodayCardsCount,
            retentionPercent: widget.data.averageRetentionRate,
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),

          // 2. الهيكل الرئيسي لسطح المكتب
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final main = _ConceptMapMainPanel(
                  data: widget.data,
                  isReviewDeckMode: _isReviewDeckMode,
                  isAnswerRevealed: _isAnswerRevealed,
                  activeCardIndex: _activeCardIndex,
                  isSavingRating: widget.isSavingRating,
                  onToggleMode: () => setState(() {
                    _isReviewDeckMode = !_isReviewDeckMode;
                    _isAnswerRevealed = false;
                    _activeCardIndex = 0;
                  }),
                  onRevealAnswer: () =>
                      setState(() => _isAnswerRevealed = true),
                  onRate: _handleRating,
                  onSelectConcept: (id) {
                    setState(() => _selectedConceptId = id);
                    widget.onSelectConcept?.call(id);
                  },
                  selectedConceptId: _selectedConceptId,
                );
                final inspector = activeConcept == null
                    ? const SizedBox.shrink()
                    : _ConceptInspectorPanel(
                        concept: activeConcept,
                        onOpenLesson: (lessonId) => widget.onNavigateRoute(
                          AppRoutes.lessonPath(lessonId),
                        ),
                      );
                if (wide) {
                  return Row(
                    children: [
                      Expanded(flex: 7, child: main),
                      VerticalDivider(
                        width: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      SizedBox(width: 380, child: inspector),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(flex: 6, child: main),
                    if (activeConcept != null) ...[
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      Expanded(flex: 4, child: inspector),
                    ],
                  ],
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

class _ConceptMapTopNav extends StatelessWidget {
  final int streakDays;
  final int xp;
  final int dueTodayCount;
  final double? retentionPercent;

  const _ConceptMapTopNav({
    required this.streakDays,
    required this.xp,
    required this.dueTodayCount,
    required this.retentionPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _conceptMapCopy(
                    context,
                    'خريطة المفاهيم والتكرار المتباعد',
                    'Concept Map & Spaced Repetition',
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          );
          final metrics = Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (retentionPercent != null)
                _MetricBadge(
                  icon: Icons.bolt_rounded,
                  text:
                      '${_conceptMapCopy(context, 'معدل الاسترجاع', 'Recall')}: ${(retentionPercent! * 100).toInt()}%',
                  color: Theme.of(context).colorScheme.primary,
                ),
              _MetricBadge(
                icon: Icons.local_fire_department_rounded,
                text: _conceptMapCopy(
                  context,
                  '$streakDays أيام',
                  '$streakDays days',
                ),
                color: Theme.of(context).colorScheme.secondary,
              ),
              _MetricBadge(
                icon: Icons.diamond_rounded,
                text: '$xp XP',
                color: Theme.of(context).colorScheme.achievement,
              ),
            ],
          );
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 8), metrics],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 12),
              metrics,
            ],
          );
        },
      ),
    );
  }
}

class _ConceptMapMainPanel extends StatelessWidget {
  const _ConceptMapMainPanel({
    required this.data,
    required this.isReviewDeckMode,
    required this.isAnswerRevealed,
    required this.activeCardIndex,
    required this.isSavingRating,
    required this.onToggleMode,
    required this.onRevealAnswer,
    required this.onRate,
    required this.onSelectConcept,
    required this.selectedConceptId,
  });

  final ConceptMapSm2DataModel data;
  final bool isReviewDeckMode;
  final bool isAnswerRevealed;
  final int activeCardIndex;
  final bool isSavingRating;
  final VoidCallback onToggleMode;
  final VoidCallback onRevealAnswer;
  final Future<void> Function(Sm2Rating rating) onRate;
  final ValueChanged<String> onSelectConcept;
  final String selectedConceptId;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Column(
      children: [
        _ConceptHeaderBanner(
          totalCount: data.totalConceptsCount,
          masteredCount: data.masteredConceptsCount,
          dueCount: data.dueTodayCardsCount,
          isReviewDeckMode: isReviewDeckMode,
          onToggleMode: onToggleMode,
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        Expanded(
          child: isReviewDeckMode
              ? _Sm2FlashcardDeckView(
                  cards: data.activeReviewDeck,
                  currentIndex: activeCardIndex,
                  isAnswerRevealed: isAnswerRevealed,
                  isSavingRating: isSavingRating,
                  onRevealAnswer: onRevealAnswer,
                  onRate: onRate,
                )
              : _InteractiveGraphCanvas(
                  concepts: data.concepts,
                  selectedConceptId: selectedConceptId,
                  onSelectConcept: onSelectConcept,
                ),
        ),
      ],
    ),
  );
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MetricBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptHeaderBanner extends StatelessWidget {
  final int totalCount;
  final int masteredCount;
  final int dueCount;
  final bool isReviewDeckMode;
  final VoidCallback onToggleMode;

  const _ConceptHeaderBanner({
    required this.totalCount,
    required this.masteredCount,
    required this.dueCount,
    required this.isReviewDeckMode,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final details = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_tree_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _conceptMapCopy(
                      context,
                      'شجرة المعرفة التراكمية في GDScript 2.0',
                      'GDScript 2.0 knowledge map',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _conceptMapCopy(
                      context,
                      'أتقنت $masteredCount من أصل $totalCount مفهوماً • $dueCount بطاقة مستحقة اليوم',
                      '$masteredCount of $totalCount mastered • $dueCount cards due today',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final button = ElevatedButton.icon(
          onPressed: onToggleMode,
          icon: Icon(
            isReviewDeckMode ? Icons.map_rounded : Icons.style_rounded,
            size: 16,
          ),
          label: Text(
            isReviewDeckMode
                ? _conceptMapCopy(context, 'العودة للخريطة', 'Back to map')
                : _conceptMapCopy(
                    context,
                    'بدء المراجعة ($dueCount)',
                    'Start review ($dueCount)',
                  ),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isReviewDeckMode
                ? Theme.of(context).colorScheme.surfaceContainer
                : Theme.of(context).colorScheme.primary,
            foregroundColor: isReviewDeckMode
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: constraints.maxWidth < 700
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: button,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 12),
                    button,
                  ],
                ),
        );
      },
    );
  }
}

class _InteractiveGraphCanvas extends StatelessWidget {
  final List<KnowledgeConceptNodeModel> concepts;
  final String selectedConceptId;
  final ValueChanged<String> onSelectConcept;

  const _InteractiveGraphCanvas({
    required this.concepts,
    required this.selectedConceptId,
    required this.onSelectConcept,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InteractiveViewer(
      constrained: false,
      minScale: 0.4,
      maxScale: 2,
      boundaryMargin: const EdgeInsets.all(120),
      child: SizedBox(
        width: 2440,
        height: 1500,
        child: Stack(
          children: [
            // شبكة خلفية هندسية
            Positioned.fill(
              child: CustomPaint(
                painter: _GraphBackgroundGridPainter(
                  color: colorScheme.surfaceContainer,
                ),
              ),
            ),

            // رسم خطوط الترابط بين العقد (Connections)
            Positioned.fill(
              child: CustomPaint(
                painter: _GraphConnectionsPainter(
                  concepts: concepts,
                  selectedConceptId: selectedConceptId,
                  color: colorScheme.primary,
                ),
              ),
            ),

            // عقد المفاهيم التفاعلية
            ...concepts.map((node) {
              final isSelected = node.id == selectedConceptId;

              return Positioned(
                left: node.visualPosition.dx,
                top: node.visualPosition.dy,
                child: _ConceptNodeWidget(
                  node: node,
                  isSelected: isSelected,
                  onTap: () => onSelectConcept(node.id),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ConceptNodeWidget extends StatelessWidget {
  final KnowledgeConceptNodeModel node;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConceptNodeWidget({
    required this.node,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    Color statusColor = Theme.of(context).colorScheme.tertiary; // mastered
    if (node.mastery == ConceptMasteryLevel.reviewing)
      statusColor = Theme.of(context).colorScheme.secondary;
    if (node.mastery == ConceptMasteryLevel.learning)
      statusColor = Theme.of(context).colorScheme.primary;
    if (node.mastery == ConceptMasteryLevel.locked)
      statusColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : statusColor.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    locale.languageCode == 'en'
                        ? node.categoryEn ?? node.category
                        : node.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              locale.languageCode == 'en' ? node.titleEn : node.titleAr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            if (node.daysUntilNextReview != null)
              Text(
                node.daysUntilNextReview == 0
                    ? _conceptMapCopy(context, 'مستحق اليوم', 'Due today')
                    : _conceptMapCopy(
                        context,
                        'بعد ${node.daysUntilNextReview} يوم',
                        'In ${node.daysUntilNextReview} days',
                      ),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10,
                  color: node.daysUntilNextReview == 0
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GraphBackgroundGridPainter extends CustomPainter {
  _GraphBackgroundGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GraphConnectionsPainter extends CustomPainter {
  final List<KnowledgeConceptNodeModel> concepts;
  final String selectedConceptId;
  final Color color;

  _GraphConnectionsPainter({
    required this.concepts,
    required this.selectedConceptId,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (var c in concepts) c.id: c};
    final selected = nodeMap[selectedConceptId];

    for (var node in concepts) {
      for (var preId in node.prerequisites) {
        final preNode = nodeMap[preId];
        if (preNode != null) {
          final isRelated =
              node.id == selectedConceptId ||
              preId == selectedConceptId ||
              (selected?.prerequisites.contains(node.id) ?? false) ||
              (selected?.prerequisites.contains(preId) ?? false);
          final paint = Paint()
            ..color = color.withValues(alpha: isRelated ? 0.82 : 0.16)
            ..strokeWidth = isRelated ? 2.2 : 1.2
            ..style = PaintingStyle.stroke;
          final p1 = Offset(
            preNode.visualPosition.dx + 170,
            preNode.visualPosition.dy + 35,
          );
          final p2 = Offset(
            node.visualPosition.dx,
            node.visualPosition.dy + 35,
          );

          final path = Path()
            ..moveTo(p1.dx, p1.dy)
            ..cubicTo(p1.dx + 40, p1.dy, p2.dx - 40, p2.dy, p2.dx, p2.dy);

          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GraphConnectionsPainter oldDelegate) =>
      oldDelegate.concepts != concepts ||
      oldDelegate.selectedConceptId != selectedConceptId;
}

class _Sm2FlashcardDeckView extends StatelessWidget {
  final List<Sm2FlashcardItemModel> cards;
  final int currentIndex;
  final bool isAnswerRevealed;
  final bool isSavingRating;
  final VoidCallback onRevealAnswer;
  final Future<void> Function(Sm2Rating rating) onRate;

  const _Sm2FlashcardDeckView({
    required this.cards,
    required this.currentIndex,
    required this.isAnswerRevealed,
    required this.isSavingRating,
    required this.onRevealAnswer,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Text(
          _conceptMapCopy(
            context,
            'لا توجد بطاقات مستحقة للمراجعة حالياً.',
            'There are no cards due for review.',
          ),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 16,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      );
    }

    final locale = Localizations.localeOf(context);
    final card = cards[currentIndex];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عداد البطاقات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _conceptMapCopy(
                      context,
                      'البطاقة ${currentIndex + 1} من ${cards.length}',
                      'Card ${currentIndex + 1} of ${cards.length}',
                    ),
                    style: CodeTextTheme.of(context).bodyMedium.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _conceptMapCopy(
                        context,
                        'SM-2 • الفاصل ${card.currentIntervalDays} يوم',
                        'SM-2 • ${card.currentIntervalDays}-day interval',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // السؤال
              Text(
                locale.languageCode == 'en'
                    ? card.promptQuestionEn ?? card.promptQuestion
                    : card.promptQuestion,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              // سياق الكود البرمجي
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    card.codeContext,
                    style: CodeTextTheme.of(context).bodyMedium.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // الإجابة والشرح عند الكشف
              if (isAnswerRevealed) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.successContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'شرح الإجابة:',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        locale.languageCode == 'en'
                            ? card.answerExplanationEn ?? card.answerExplanation
                            : card.answerExplanation,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      if (card.answerCode.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              card.answerCode,
                              style: CodeTextTheme.of(context).bodyMedium
                                  .copyWith(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // أزرار تقييم SM-2 الأربعة
                Row(
                  children: [
                    _Sm2RatingBtn(
                      label: _conceptMapCopy(context, 'إعادة', 'Again'),
                      color: Theme.of(context).colorScheme.error,
                      enabled: !isSavingRating,
                      onTap: () => onRate(Sm2Rating.again),
                    ),
                    const SizedBox(width: 8),
                    _Sm2RatingBtn(
                      label: _conceptMapCopy(context, 'صعب', 'Hard'),
                      color: Theme.of(context).colorScheme.secondary,
                      enabled: !isSavingRating,
                      onTap: () => onRate(Sm2Rating.hard),
                    ),
                    const SizedBox(width: 8),
                    _Sm2RatingBtn(
                      label: _conceptMapCopy(context, 'جيد', 'Good'),
                      color: Theme.of(context).colorScheme.primary,
                      enabled: !isSavingRating,
                      onTap: () => onRate(Sm2Rating.good),
                    ),
                    const SizedBox(width: 8),
                    _Sm2RatingBtn(
                      label: _conceptMapCopy(context, 'سهل', 'Easy'),
                      color: Theme.of(context).colorScheme.tertiary,
                      enabled: !isSavingRating,
                      onTap: () => onRate(Sm2Rating.easy),
                    ),
                  ],
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSavingRating ? null : onRevealAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _conceptMapCopy(context, 'كشف الإجابة', 'Reveal answer'),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sm2RatingBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool enabled;
  final Future<void> Function() onTap;

  const _Sm2RatingBtn({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: enabled ? () => onTap() : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: enabled ? color : color.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConceptInspectorPanel extends StatelessWidget {
  final KnowledgeConceptNodeModel concept;
  final ValueChanged<String> onOpenLesson;

  const _ConceptInspectorPanel({
    required this.concept,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    final canOpenLesson =
        concept.lessonId != null &&
        concept.mastery != ConceptMasteryLevel.locked;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? concept.titleEn : concept.titleAr,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _masteryLabel(context, concept.mastery),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 14),

        Text(
          _conceptMapCopy(context, 'شرح المفهوم:', 'Concept overview:'),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEnglish
              ? concept.descriptionEn ?? concept.description
              : concept.description,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        if (concept.codeExample.isNotEmpty) ...[
          Text(
            _conceptMapCopy(context, 'مثال برمجي:', 'Code example:'),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                concept.codeExample,
                style: CodeTextTheme.of(context).bodyMedium.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _conceptMapCopy(context, 'حالة المفهوم', 'Concept status'),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _masteryLabel(context, concept.mastery),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (concept.lastReviewedDate.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_conceptMapCopy(context, 'آخر مراجعة:', 'Last reviewed:')} ${concept.lastReviewedDate}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (canOpenLesson) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => onOpenLesson(concept.lessonId!),
            icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
            label: Text(
              _conceptMapCopy(
                context,
                'فتح الدرس المرتبط',
                'Open linked lesson',
              ),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _conceptMapCopy(BuildContext context, String arabic, String english) =>
    Localizations.localeOf(context).languageCode == 'en' ? english : arabic;

String _masteryLabel(BuildContext context, ConceptMasteryLevel mastery) {
  final (arabic, english) = switch (mastery) {
    ConceptMasteryLevel.locked => ('مقفل', 'Locked'),
    ConceptMasteryLevel.learning => ('قيد التعلم', 'Learning'),
    ConceptMasteryLevel.reviewing => ('قيد المراجعة', 'Reviewing'),
    ConceptMasteryLevel.mastered => ('متقن', 'Mastered'),
  };
  return _conceptMapCopy(context, arabic, english);
}
