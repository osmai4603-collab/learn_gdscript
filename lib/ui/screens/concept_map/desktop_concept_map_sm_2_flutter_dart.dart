// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 9: خريطة المفاهيم البصرية ونظام المراجعة الذكية والتكرار المتباعد SM-2
// الملف: desktop_concept_map_sm2_screen.dart
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:learn_gdscript/ui/routers/app_routes.dart';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات الخاصة بخريطة المفاهيم ونظام SM-2 (Data Models)
// -----------------------------------------------------------------------------

enum ConceptMasteryLevel { locked, learning, reviewing, mastered }
enum Sm2Rating { again, hard, good, easy }

class KnowledgeConceptNodeModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String category;
  final ConceptMasteryLevel mastery;
  final double retentionPercent;
  final int daysUntilNextReview;
  final String lastReviewedDate;
  final String description;
  final String codeExample;
  final List<String> prerequisites;
  final Offset visualPosition; // لإحداثيات الرسم البياني للشجرة

  const KnowledgeConceptNodeModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.category,
    required this.mastery,
    required this.retentionPercent,
    required this.daysUntilNextReview,
    required this.lastReviewedDate,
    required this.description,
    required this.codeExample,
    required this.prerequisites,
    required this.visualPosition,
  });
}

class Sm2FlashcardItemModel {
  final String id;
  final String conceptId;
  final String promptQuestion;
  final String codeContext;
  final String answerExplanation;
  final int repetitionCount;
  final double easinessFactor; // عامل السهولة EF وفق خوارزمية SM-2
  final int currentIntervalDays;

  const Sm2FlashcardItemModel({
    required this.id,
    required this.conceptId,
    required this.promptQuestion,
    required this.codeContext,
    required this.answerExplanation,
    required this.repetitionCount,
    required this.easinessFactor,
    required this.currentIntervalDays,
  });
}

class ConceptMapSm2DataModel {
  final int totalConceptsCount;
  final int masteredConceptsCount;
  final int dueTodayCardsCount;
  final double averageRetentionRate;
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

  KnowledgeConceptNodeModel get activeConcept =>
      concepts.firstWhere((c) => c.id == selectedConceptId, orElse: () => concepts.first);

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
          promptQuestion: 'ما هو دور النمط الشامل _ (Wildcard) في بنية match في GDScript 2.0؟',
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
          promptQuestion: 'كيف تعلن عن دالة تعيد نوعاً صارماً ولا ترجع أي قيمة؟',
          codeContext: 'func update_hud(score: int) -> ???:',
          answerExplanation: 'استخدام سهم التحديد الصريح مع الكلمة المحجوزة void: -> void لضمان السلامة البرمجية أثناء الترجمة.',
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
          description: 'طباعة الرسائل والقيم إلى نافذة الإخراج Debug Console للتحقق من سلامة التنفيذ.',
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
          description: 'تحديد نوع البيانات الصريح للمتغيرات والمعاملات لتمكين فاحص LSP وتحسين أداء JIT.',
          codeExample: 'var speed: float = 300.0\nvar player_name: String = "Tariq"',
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
          description: 'بنية هندسية لحساب الموقع والسرعة والتطبيع (Normalized) والمسافات في الفضاء 2D.',
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
          description: 'صياغة متقدمة للتحكم في التدفق وبناء آلات الحالات المحدودة وبديل فائق لـ switch/case.',
          codeExample: 'match state:\n    "IDLE": velocity.x = 0.0\n    _: move()',
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
          description: 'معمارية الاتصال غير المتزامن بين العقد (Loose Coupling) عبر إطلاق واستقبال الأحداث.',
          codeExample: 'signal health_changed(new_hp: int)\nhealth_changed.emit(85)',
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
          description: 'دورة المعالجة الفيزيائية المتزامنة مع محرك الاصطدام ودوال move_and_slide().',
          codeExample: 'func _physics_process(delta: float) -> void:\n    move_and_slide()',
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
  final ValueChanged<String>? onNavigateRoute;
  final ValueChanged<String>? onSelectConcept;
  final Function(String cardId, Sm2Rating rating)? onRateCard;

  const DesktopConceptMapSm2Screen({
    super.key,
    required this.data,
    this.onNavigateRoute,
    this.onSelectConcept,
    this.onRateCard,
  });

  @override
  State<DesktopConceptMapSm2Screen> createState() => _DesktopConceptMapSm2ScreenState();
}

class _DesktopConceptMapSm2ScreenState extends State<DesktopConceptMapSm2Screen> {
  late String _selectedConceptId;
  bool _isReviewDeckMode = false;
  int _activeCardIndex = 0;
  bool _isAnswerRevealed = false;

  @override
  void initState() {
    super.initState();
    _selectedConceptId = widget.data.selectedConceptId;
  }

  KnowledgeConceptNodeModel get _activeConcept =>
      widget.data.concepts.firstWhere((c) => c.id == _selectedConceptId, orElse: () => widget.data.concepts.first);

  void _handleRating(Sm2Rating rating) {
    final currentCard = widget.data.activeReviewDeck[_activeCardIndex];
    widget.onRateCard?.call(currentCard.id, rating);

    setState(() {
      _isAnswerRevealed = false;
      if (_activeCardIndex < widget.data.activeReviewDeck.length - 1) {
        _activeCardIndex++;
      } else {
        _isReviewDeckMode = false;
        _activeCardIndex = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF14532D),
            content: Text(
              'اكتملت جلسة مراجعة بطاقات اليوم بنجاح! تم تحديث فترات SM-2 (+25 XP)',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: Colors.white),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141B),
      body: Column(
        children: [
          // 1. الشريط العلوي العام
          _ConceptMapTopNav(
            streakDays: widget.data.streakDays,
            xp: widget.data.xp,
            dueTodayCount: widget.data.dueTodayCardsCount,
            retentionPercent: widget.data.averageRetentionRate,
            onNavigate: widget.onNavigateRoute,
          ),
          const Divider(height: 1, color: Color(0xFF28323F)),
    
          // 2. الهيكل الرئيسي لسطح المكتب
          Expanded(
            child: Row(
              children: [
                // مساحة الرسم البياني التفاعلي أو وضع مراجعة الفلاش كاردز
                Expanded(
                  flex: 7,
                  child: Container(
                    color: const Color(0xFF0A0D12),
                    child: Column(
                      children: [
                        // لافتة الإحصائيات وأزرار التبديل
                        _ConceptHeaderBanner(
                          totalCount: widget.data.totalConceptsCount,
                          masteredCount: widget.data.masteredConceptsCount,
                          dueCount: widget.data.dueTodayCardsCount,
                          isReviewDeckMode: _isReviewDeckMode,
                          onToggleMode: () => setState(() {
                            _isReviewDeckMode = !_isReviewDeckMode;
                            _isAnswerRevealed = false;
                          }),
                        ),
                        const Divider(height: 1, color: Color(0xFF28323F)),
    
                        // المحتوى الرئيسي التفاعلي
                        Expanded(
                          child: _isReviewDeckMode
                              ? _Sm2FlashcardDeckView(
                                  cards: widget.data.activeReviewDeck,
                                  currentIndex: _activeCardIndex,
                                  isAnswerRevealed: _isAnswerRevealed,
                                  onRevealAnswer: () => setState(() => _isAnswerRevealed = true),
                                  onRate: _handleRating,
                                )
                              : _InteractiveGraphCanvas(
                                  concepts: widget.data.concepts,
                                  selectedConceptId: _selectedConceptId,
                                  onSelectConcept: (id) => setState(() => _selectedConceptId = id),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    
                const VerticalDivider(width: 1, color: Color(0xFF28323F)),
    
                // لوحة فحص المفهوم المعرفي المختار
                SizedBox(
                  width: 380,
                  child: Container(
                    color: const Color(0xFF131922),
                    child: _ConceptInspectorPanel(
                      concept: _activeConcept,
                      onOpenLesson: () => widget.onNavigateRoute?.call(
                        AppRoutes.lessonPath('u2'),
                      ),
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

// -----------------------------------------------------------------------------
// 3. المكونات المستقلة للواجهة (Modular Widgets)
// -----------------------------------------------------------------------------

class _ConceptMapTopNav extends StatelessWidget {
  final int streakDays;
  final int xp;
  final int dueTodayCount;
  final double retentionPercent;
  final ValueChanged<String>? onNavigate;

  const _ConceptMapTopNav({
    required this.streakDays,
    required this.xp,
    required this.dueTodayCount,
    required this.retentionPercent,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF131922),
      child: Row(
        children: [
          Row(
            children: const [
              Icon(Icons.psychology_rounded, color: Color(0xFF478CBF), size: 24),
              SizedBox(width: 8),
              Text(
                'أكاديمية جودو',
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
              ),
              SizedBox(width: 8),
              Text('/', style: TextStyle(color: Color(0xFF64748B))),
              SizedBox(width: 8),
              Text(
                'خريطة المفاهيم والتكرار المتباعد (Spaced Repetition & SM-2)',
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF171C23),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF28323F)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF38BDF8)),
                const SizedBox(width: 6),
                Text(
                  'معدل الاسترجاع: ${(retentionPercent * 100).toInt()}%',
                  style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _MetricBadge(icon: Icons.local_fire_department_rounded, text: '$streakDays أيام', color: const Color(0xFFFB923C)),
          const SizedBox(width: 8),
          _MetricBadge(icon: Icons.diamond_rounded, text: '$xp XP', color: const Color(0xFFA855F7)),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MetricBadge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF171C23),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF28323F)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, fontWeight: FontWeight.bold, color: color)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF131922),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF478CBF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_tree_rounded, size: 20, color: Color(0xFF478CBF)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'شجرة المعرفة التراكمية في GDScript 2.0',
                    style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'أتقنت $masteredCount من أصل $totalCount مفهوماً برمجياً • $dueCount بطاقات مستحقة للمراجعة اليوم',
                    style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: onToggleMode,
            icon: Icon(isReviewDeckMode ? Icons.map_rounded : Icons.style_rounded, size: 16),
            label: Text(
              isReviewDeckMode ? 'العودة للخريطة البصرية' : 'بدء جلسة المراجعة الذكية ($dueCount) ↵',
              style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isReviewDeckMode ? const Color(0xFF1F2630) : const Color(0xFF38BDF8),
              foregroundColor: isReviewDeckMode ? const Color(0xFFE2E8F0) : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // شبكة خلفية هندسية
            Positioned.fill(
              child: CustomPaint(
                painter: _GraphBackgroundGridPainter(),
              ),
            ),

            // رسم خطوط الترابط بين العقد (Connections)
            Positioned.fill(
              child: CustomPaint(
                painter: _GraphConnectionsPainter(concepts: concepts),
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
        );
      },
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
    Color statusColor = const Color(0xFF22C55E); // mastered
    if (node.mastery == ConceptMasteryLevel.reviewing) statusColor = const Color(0xFFF59E0B);
    if (node.mastery == ConceptMasteryLevel.learning) statusColor = const Color(0xFF38BDF8);
    if (node.mastery == ConceptMasteryLevel.locked) statusColor = const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2837) : const Color(0xFF131922),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF478CBF) : statusColor.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF478CBF).withValues(alpha: 0.3), blurRadius: 12)]
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
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    node.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              node.titleAr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              node.daysUntilNextReview == 0 ? 'مستحق للمراجعة اليوم ⚠️' : 'المراجعة بعد ${node.daysUntilNextReview} أيام',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 10,
                color: node.daysUntilNextReview == 0 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphBackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2632).withValues(alpha: 0.2)
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

  _GraphConnectionsPainter({required this.concepts});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF478CBF).withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final nodeMap = {for (var c in concepts) c.id: c};

    for (var node in concepts) {
      for (var preId in node.prerequisites) {
        final preNode = nodeMap[preId];
        if (preNode != null) {
          final p1 = Offset(preNode.visualPosition.dx + 170, preNode.visualPosition.dy + 35);
          final p2 = Offset(node.visualPosition.dx, node.visualPosition.dy + 35);

          final path = Path()
            ..moveTo(p1.dx, p1.dy)
            ..cubicTo(p1.dx + 40, p1.dy, p2.dx - 40, p2.dy, p2.dx, p2.dy);

          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Sm2FlashcardDeckView extends StatelessWidget {
  final List<Sm2FlashcardItemModel> cards;
  final int currentIndex;
  final bool isAnswerRevealed;
  final VoidCallback onRevealAnswer;
  final ValueChanged<Sm2Rating> onRate;

  const _Sm2FlashcardDeckView({
    required this.cards,
    required this.currentIndex,
    required this.isAnswerRevealed,
    required this.onRevealAnswer,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد بطاقات مستحقة للمراجعة حالياً! أحسنت 🎉',
          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16, color: Color(0xFF22C55E)),
        ),
      );
    }

    final card = cards[currentIndex];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF131922),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF28323F)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
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
                    'البطاقة ${currentIndex + 1} من أصل ${cards.length}',
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF0F141B), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      'خوارزمية SM-2: الفاصل ${card.currentIntervalDays} أيام',
                      style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 10, color: Color(0xFF38BDF8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // السؤال
              Text(
                card.promptQuestion,
                style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0), height: 1.5),
              ),
              const SizedBox(height: 14),

              // سياق الكود البرمجي
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0D12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF28323F)),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    card.codeContext,
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: Color(0xFF38BDF8), height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // الإجابة والشرح عند الكشف
              if (isAnswerRevealed) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14532D).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الشرح النموذجي:',
                        style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        card.answerExplanation,
                        style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13, color: Color(0xFFCBD5E1), height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // أزرار تقييم SM-2 الأربعة
                Row(
                  children: [
                    _Sm2RatingBtn(label: 'إعادة (0)', sublabel: '<10د', color: const Color(0xFFEF4444), onTap: () => onRate(Sm2Rating.again)),
                    const SizedBox(width: 8),
                    _Sm2RatingBtn(label: 'صعب (3)', sublabel: '2 أيام', color: const Color(0xFFF59E0B), onTap: () => onRate(Sm2Rating.hard)),
                    const SizedBox(width: 8),
                    _Sm2RatingBtn(label: 'جيد (4)', sublabel: '6 أيام', color: const Color(0xFF38BDF8), onTap: () => onRate(Sm2Rating.good)),
                    const SizedBox(width: 8),
                    _Sm2RatingBtn(label: 'سهل (5)', sublabel: '14 يوماً', color: const Color(0xFF22C55E), onTap: () => onRate(Sm2Rating.easy)),
                  ],
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRevealAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF478CBF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'كشف الإجابة النموذجية (Space) ↵',
                      style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13, fontWeight: FontWeight.bold),
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
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _Sm2RatingBtn({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(sublabel, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConceptInspectorPanel extends StatelessWidget {
  final KnowledgeConceptNodeModel concept;
  final VoidCallback onOpenLesson;

  const _ConceptInspectorPanel({required this.concept, required this.onOpenLesson});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF478CBF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.school_rounded, color: Color(0xFF478CBF), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concept.titleAr,
                    style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                  ),
                  Text(
                    concept.titleEn,
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(color: Color(0xFF28323F)),
        const SizedBox(height: 14),

        const Text('شرح المفهوم البرمجي:', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0))),
        const SizedBox(height: 6),
        Text(concept.description, style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, color: Color(0xFF94A3B8), height: 1.5)),
        const SizedBox(height: 16),

        const Text('صيغة الكود في Godot 4.3:', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF0A0D12), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF28323F))),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(concept.codeExample, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Color(0xFF38BDF8), height: 1.5)),
          ),
        ),
        const SizedBox(height: 18),

        // بطاقة خوارزمية SM-2
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0F141B), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF28323F))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('مستوى الاسترجاع بالذاكرة:', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, color: Color(0xFF64748B))),
                  Text('${(concept.retentionPercent * 100).toInt()}%', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: concept.retentionPercent,
                  minHeight: 5,
                  backgroundColor: const Color(0xFF1F2630),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'آخر مراجعة: ${concept.lastReviewedDate}',
                style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: onOpenLesson,
          icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
          label: const Text('انتقل للدرس المرتبط بهذا المفهوم ↵', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF478CBF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
