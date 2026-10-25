// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 5: مستكشف الصياغة والمكتبة المرجعية (Desktop Syntax Explorer & API Reference)
// الملف: desktop_syntax_explorer_screen.dart
// ==============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_gdscript/l10n/app_localizations.dart';
import 'package:learn_gdscript/ui/routers/app_routes.dart';
import 'package:learn_gdscript/ui/widgets/common/navigation_bar.dart';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات الخاصة بمستكشف الصياغة (Data Models)
// -----------------------------------------------------------------------------

enum SyntaxCategory {
  all,
  keywords,
  builtinTypes,
  coreFunctions,
  engineDecorators,
  math2D,
}

class SyntaxDocEntryModel {
  final String id;
  final String title;
  final String signature;
  final SyntaxCategory category;
  final String categoryLabel;
  final String briefDescription;
  final String detailedExplanation;
  final String codeExample;
  final List<String> relatedConcepts;
  final List<String> keyFeatures;
  final List<String> cautions;
  final String godotVersion;
  final bool isBookmark;
  final String? relatedLesson;

  const SyntaxDocEntryModel({
    required this.id,
    required this.title,
    required this.signature,
    required this.category,
    required this.categoryLabel,
    required this.briefDescription,
    required this.detailedExplanation,
    required this.codeExample,
    required this.relatedConcepts,
    this.keyFeatures = const [],
    this.cautions = const [],
    this.godotVersion = 'Godot 4.3+',
    this.isBookmark = false,
    this.relatedLesson,
  });
}

class SyntaxExplorerDataModel {
  final String searchQuery;
  final SyntaxCategory selectedCategory;
  final List<SyntaxDocEntryModel> entries;
  final String selectedEntryId;
  final int? totalEntriesCount;

  const SyntaxExplorerDataModel({
    required this.searchQuery,
    required this.selectedCategory,
    required this.entries,
    required this.selectedEntryId,
    this.totalEntriesCount,
  });

  SyntaxDocEntryModel get activeEntry => entries.firstWhere(
    (e) => e.id == selectedEntryId,
    orElse: () => entries.first,
  );

  static SyntaxExplorerDataModel sampleData() {
    return const SyntaxExplorerDataModel(
      searchQuery: '',
      selectedCategory: SyntaxCategory.all,
      selectedEntryId: 'syn_match',
      totalEntriesCount: 32,
      entries: [
        SyntaxDocEntryModel(
          id: 'syn_match',
          title: 'match',
          signature:
              '// البنية العامة لمطابقة الحالات والأنماط\nmatch target_expression:\n    pattern_1:\n        handle_case_one()\n    pattern_2, pattern_3:\n        handle_multiple()\n    _:\n        handle_default()',
          category: SyntaxCategory.keywords,
          categoryLabel: 'الكلمات المفتاحية',
          briefDescription:
              'بديل متطور وآمن لعبارات switch / elif للتحقق من القيم والأنماط المعقدة ومطابقة الحالات في Godot 4.',
          detailedExplanation:
              'تعتبر تعليمة match في لغة GDScript البديل الأقوى والأشمل لتعليمات switch في لغات البرمجة الأخرى. تدعم مطابقة القيم والأنواع والمصفوفات والقواميس والنطاقات الرقمية، وتنفذ كل حالة مطابقة دون الحاجة إلى break.',
          codeExample: '''# تجربة حية لمطابقة الحالات وتغيير سرعة اللاعب
var player_state: String = "JUMP"
match player_state:
    "IDLE":
        print("اللاعب متوقف في مكانه - السرعة: 0")
    "RUN":
        print("اللاعب يجري بسرعة 200 وحدة.")
    "JUMP":
        print("اللاعب قفز للأعلى! متجه الحركة: Vector2(0, -320)")
    _:
        print("حالة غير معروفة، تم التفعيل الافتراضي.")''',
          relatedConcepts: [
            'enum',
            'if / elif',
            'Wildcard _',
            'Pattern Guards',
          ],
          keyFeatures: [
            'لا تحتاج إلى break بين الحالات.',
            'تدعم تفكيك المصفوفات والقواميس.',
            'تدعم مطابقة الأنواع والنطاقات.',
          ],
          cautions: [
            'أضف النمط الشامل _ لمعالجة الحالات الأخرى.',
            'استخدم when لقيود المطابقة بدلاً من الشروط المباشرة.',
          ],
          godotVersion: 'Godot 4.3 (GDScript 2.0)',
          isBookmark: true,
        ),
        SyntaxDocEntryModel(
          id: 'syn_export',
          title: '@export',
          signature: '@export var variable_name: Type = default_value',
          category: SyntaxCategory.engineDecorators,
          categoryLabel: 'محددات المحرك (Decorators)',
          briefDescription:
              'تصدير المتغير إلى مفتش الخصائص (Inspector) في محرر Godot مع نوع صارم.',
          detailedExplanation:
              'في Godot 4، حلت المحددات @export محل كلمة export القديمة. تدعم قيود النطاقات مثل @export_range(0, 100) وتوفر واجهة تفاعلية لمصممي المراحل دون تعديل كود السكربت.',
          codeExample: '''@export_group("إعدادات الحركة")
@export var speed: float = 300.0
@export_range(10.0, 100.0, 5.0) var jump_height: float = 45.0
@export var character_icon: Texture2D''',
          relatedConcepts: [
            '@export_range',
            '@export_group',
            'Inspector UI',
            'Static Typing',
          ],
          godotVersion: 'Godot 4.0+',
        ),
        SyntaxDocEntryModel(
          id: 'syn_vector2',
          title: 'Vector2',
          signature: 'struct Vector2(x: float, y: float)',
          category: SyntaxCategory.builtinTypes,
          categoryLabel: 'الأنواع الهندسية المدمجة',
          briefDescription:
              'بنية متجه ثنائي الأبعاد تمثل الموقع، السرعة، والاتجاه في الفضاء 2D.',
          detailedExplanation:
              'تتكون من مركبتين x و y بدقة 32-bit float. تدعم المتجهات العمليات الحسابية المتجهة، المسافة distance_to()، التطبيع normalized()، والضرب القياسي dot().',
          codeExample:
              '''var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
if direction != Vector2.ZERO:
    velocity = direction.normalized() * speed
move_and_slide()''',
          relatedConcepts: [
            'Vector2.ZERO',
            'normalized()',
            'distance_to()',
            'CharacterBody2D',
          ],
          godotVersion: 'Godot 4.3',
        ),
        SyntaxDocEntryModel(
          id: 'syn_signal',
          title: 'signal',
          signature: 'signal signal_name(param: Type)',
          category: SyntaxCategory.keywords,
          categoryLabel: 'الكلمات المفتاحية',
          briefDescription:
              'تعريف رسالة حدثية مخصصة لتحقيق الارتباط الضعيف (Loose Coupling).',
          detailedExplanation:
              'تسمح الإشارات للعقد بإعلام الكائنات الأخرى بوقوع حدث دون الحاجة لمعرفة تفاصيل تلك الكائنات. يتم إطلاق الإشارة باستخدام signal_name.emit(args).',
          codeExample: '''signal health_depleted(final_score: int)

func take_damage(amount: int) -> void:
    current_health -= amount
    if current_health <= 0:
        health_depleted.emit(score)''',
          relatedConcepts: [
            'emit()',
            'connect()',
            'Callable',
            'Loose Coupling',
          ],
          godotVersion: 'Godot 4.0+',
        ),
        SyntaxDocEntryModel(
          id: 'syn_clamp',
          title: 'clamp()',
          signature: 'clamp(value, min, max)',
          category: SyntaxCategory.coreFunctions,
          categoryLabel: 'الدوال المدمجة',
          briefDescription:
              'تقييد قيمة رقمية لتبقى ضمن الحدين الأدنى والأقصى، مثل تحديد نقاط الصحة أو السرعة.',
          detailedExplanation:
              'تعيد clamp() القيمة محصورة بين الحدين المحددين. إذا كانت القيمة أقل من الحد الأدنى فستعيد الحد الأدنى، وإذا تجاوزت الحد الأعلى فستعيد الحد الأعلى.',
          codeExample: '''var health: float = 125.0
health = clamp(health, 0.0, 100.0)
print(health) # 100.0''',
          relatedConcepts: ['min()', 'max()', 'clampf()', 'تقييد القيم'],
          godotVersion: 'Godot 4.0+',
        ),
        SyntaxDocEntryModel(
          id: 'syn_var',
          title: 'var / const',
          signature: 'var name: Type = value\nconst NAME: Type = value',
          category: SyntaxCategory.keywords,
          categoryLabel: 'الكلمات المفتاحية',
          briefDescription:
              'تعريف متغيرات قابلة للتغيير وثوابت لا تتغير أثناء تشغيل البرنامج.',
          detailedExplanation:
              'استخدم var لتعريف قيمة قابلة للتغيير، ويمكن تحديد نوعها صراحةً بعد النقطتين. أما const فتعرّف قيمة ثابتة يجب تحديدها وقت التحميل.',
          codeExample: '''var speed: float = 240.0
const MAX_HEALTH: int = 100

speed = 300.0''',
          relatedConcepts: ['Static Typing', 'متغيرات الأعضاء', 'الثوابت'],
          godotVersion: 'Godot 4.0+',
        ),
        SyntaxDocEntryModel(
          id: 'syn_randi_range',
          title: 'randi_range()',
          signature: 'randi_range(from: int, to: int) -> int',
          category: SyntaxCategory.math2D,
          categoryLabel: 'دوال عشوائية',
          briefDescription:
              'توليد عدد صحيح عشوائي ضمن نطاق شامل للحد الأدنى والحد الأعلى.',
          detailedExplanation:
              'تُرجع randi_range() عدداً صحيحاً عشوائياً من المجال المحدد، مع تضمين قيمتي البداية والنهاية. يمكن استخدامها في توليد الضرر أو اختيار عنصر عشوائي.',
          codeExample: '''var damage: int = randi_range(8, 15)
print("Damage: ", damage)''',
          relatedConcepts: [
            'randf_range()',
            'RandomNumberGenerator',
            'الأعداد العشوائية',
          ],
          godotVersion: 'Godot 4.0+',
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. الشاشة الرئيسية لمستكشف الصياغة (DesktopSyntaxExplorerScreen)
// -----------------------------------------------------------------------------

class DesktopSyntaxExplorerScreen extends StatefulWidget {
  final SyntaxExplorerDataModel data;
  final ValueChanged<String>? onOpenInWorkspace;
  final ValueChanged<String>? onNavigateRoute;
  final Future<void> Function(String query)? onSearchSubmitted;

  const DesktopSyntaxExplorerScreen({
    super.key,
    required this.data,
    this.onOpenInWorkspace,
    this.onNavigateRoute,
    this.onSearchSubmitted,
  });

  @override
  State<DesktopSyntaxExplorerScreen> createState() =>
      _DesktopSyntaxExplorerScreenState();
}

class _DesktopSyntaxExplorerScreenState
    extends State<DesktopSyntaxExplorerScreen> {
  late String _selectedEntryId;
  late SyntaxCategory _currentCategory;
  late TextEditingController _searchController;
  late final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  String _sortOrder = 'alphabetical';
  int _visibleEntryLimit = 5;

  @override
  void initState() {
    super.initState();
    final initialEntry = widget.data.entries.isEmpty
        ? null
        : widget.data.entries.firstWhere(
            (entry) => entry.id == widget.data.selectedEntryId,
            orElse: () => widget.data.entries.first,
          );
    _selectedEntryId = initialEntry?.id ?? widget.data.selectedEntryId;
    _currentCategory = widget.data.selectedCategory;
    _searchController = TextEditingController(text: widget.data.searchQuery);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DesktopSyntaxExplorerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.entries != widget.data.entries) {
      final selectedEntry = widget.data.entries
          .where((entry) => entry.id == _selectedEntryId)
          .firstOrNull;
      _selectedEntryId =
          selectedEntry?.id ??
          widget.data.entries.firstOrNull?.id ??
          widget.data.selectedEntryId;
    }
  }

  List<SyntaxDocEntryModel> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.data.entries.where((entry) {
      final matchesCategory =
          _currentCategory == SyntaxCategory.all ||
          entry.category == _currentCategory;
      final searchableText = [
        entry.title,
        entry.signature,
        entry.categoryLabel,
        entry.briefDescription,
        entry.detailedExplanation,
        ...entry.relatedConcepts,
        entry.codeExample,
      ].join(' ').toLowerCase();
      final matchesSearch = query.isEmpty || searchableText.contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
    filtered.sort((a, b) => a.title.compareTo(b.title));
    return filtered;
  }

  SyntaxDocEntryModel? get _currentEntry {
    return _filteredEntries
        .where((entry) => entry.id == _selectedEntryId)
        .firstOrNull ??
        _filteredEntries.firstOrNull;
  }

  void _updateSearch(String value) {
    if (_searchController.text != value) {
      _searchController.text = value;
    }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      _applySearch();
    });
  }

  void _applySearch() {
    setState(() {
      _visibleEntryLimit = 5;
      final matches = _filteredEntries;
      if (matches.isNotEmpty &&
          !matches.any((entry) => entry.id == _selectedEntryId)) {
          _selectedEntryId = matches.first.id;
      }
    });
  }

  Future<void> _submitSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _filteredEntries.isEmpty) return;
    final submit = widget.onSearchSubmitted;
    if (submit == null) return;
    try {
      await submit(query);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.syntaxExplorerProgressError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _selectEntry(SyntaxDocEntryModel entry) {
    _searchDebounce?.cancel();
    setState(() {
      _selectedEntryId = entry.id;
    });
  }

  Future<void> _copyText(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.syntaxExplorerCopied(label),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const _FocusSyntaxSearchIntent(),
      },
      child: Actions(
        actions: {
          _FocusSyntaxSearchIntent: CallbackAction<_FocusSyntaxSearchIntent>(
            onInvoke: (_) {
              _searchFocusNode.requestFocus();
              _searchController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _searchController.text.length,
              );
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottomNavigationBar: MediaQuery.sizeOf(context).width < 840
                ? AppNavigationBar(
                    selectedRoute: AppRoutes.syntaxReference,
                    onSelected: (route) => widget.onNavigateRoute?.call(route),
                  )
                : null,
          body: SafeArea(
            
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SyntaxPageHeading(
                            entryCount: widget.data.entries.length,
                          ),
                          const SizedBox(height: 18),
                          _SyntaxSearchAndFilters(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            selectedCategory: _currentCategory,
                            sortOrder: _sortOrder,
                            quickSearchTokens: widget.data.entries
                                .take(5)
                                .map((entry) => entry.title)
                                .toList(growable: false),
                            onSearchChanged: _updateSearch,
                            onSearchSubmitted: _submitSearch,
                            onCategorySelected: (category) {
                              setState(() {
                                _visibleEntryLimit = 5;
                                _currentCategory = category;
                                final matches = _filteredEntries;
                                if (matches.isNotEmpty &&
                                    !matches.any(
                                      (entry) => entry.id == _selectedEntryId,
                                    )) {
                                  _selectedEntryId = matches.first.id;
                                }
                              });
                            },
                            onSortChanged: (sortOrder) {
                              setState(() {
                                _visibleEntryLimit = 5;
                                _sortOrder = sortOrder;
                              });
                            },
                            onQuickSearch: (query) {
                              _searchController.text = query;
                              _updateSearch(query);
                              _submitSearch();
                            },
                          ),
                          const SizedBox(height: 18),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final catalog = _SyntaxCatalog(
                                entries: _filteredEntries
                                    .take(_visibleEntryLimit)
                                    .toList(),
                                selectedEntryId: _selectedEntryId,
                                bookmarkedEntryIds: const {},
                                totalCount: _searchController.text.trim().isEmpty
                                    ? widget.data.totalEntriesCount ??
                                          widget.data.entries.length
                                    : _filteredEntries.length,
                                canLoadMore:
                                    _visibleEntryLimit < _filteredEntries.length,
                                onLoadMore: () =>
                                    setState(() => _visibleEntryLimit += 5),
                                onSelectEntry: _selectEntry,
                              );
                              final entry = _currentEntry;
                              final detail = entry == null
                                  ? const _EmptySyntaxDetail()
                                  : _SyntaxDetailView(
                                      entry: entry,
                                      onCopyTitle: () => _copyText(
                                        entry.title,
                                        AppLocalizations.of(
                                          context,
                                        )!.syntaxExplorerCopyEntry,
                                      ),
                                      onCopyCode: () => _copyText(
                                        entry.codeExample,
                                        AppLocalizations.of(
                                          context,
                                        )!.syntaxExplorerCopyExample,
                                      ),
                                      onOpenLesson: entry.relatedLesson == null
                                          ? null
                                          : () {
                                        final navigate = widget.onNavigateRoute;
                                        navigate?.call(
                                          AppRoutes.lessonPath(
                                            entry.relatedLesson!,
                                          ),
                                        );
                                      },
                                      onOpenWorkspace: () {
                                        final openWorkspace =
                                            widget.onOpenInWorkspace;
                                        openWorkspace?.call(entry.id);
                                      },
                                    );
                              if (constraints.maxWidth >= 900) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 5, child: catalog),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 7, child: detail),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  catalog,
                                  const SizedBox(height: 24),
                                  detail,
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              ],
            ),
          ),  
        ),
      ),
    );
  }
}

class _FocusSyntaxSearchIntent extends Intent {
  const _FocusSyntaxSearchIntent();
}

abstract final class _SyntaxColors {
  static const background = Color(0xFF0F141B);
  static const lowest = Color(0xFF090F15);
  static const low = Color(0xFF171C23);
  static const surface = Color(0xFF1B2027);
  static const high = Color(0xFF252A32);
  static const highest = Color(0xFF30353D);
  static const primary = Color(0xFF91CDFF);
  static const primaryContainer = Color(0xFF5397CA);
  static const tertiary = Color(0xFF4AE183);
  static const secondary = Color(0xFFFFB783);
  static const text = Color(0xFFDEE2EC);
  static const muted = Color(0xFFC0C7D0);
  static const outline = Color(0xFF8A919A);
  static const outlineVariant = Color(0xFF40484F);
}

const _bodyFont = 'IBM Plex Sans';
const _codeFont = 'JetBrains Mono';

class _SyntaxPageHeading extends StatelessWidget {
  final int entryCount;

  const _SyntaxPageHeading({required this.entryCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _SyntaxMetrics(entryCount: entryCount);
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: _SyntaxColors.primary,
                  size: 30,
                ),
                Text(
                  l10n.syntaxExplorerTitle,
                  style: TextStyle(
                    fontFamily: _bodyFont,
                    fontSize: 31,
                    fontWeight: FontWeight.bold,
                    color: _SyntaxColors.text,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  '/ API Reference',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: _codeFont,
                    fontSize: 13,
                    color: _SyntaxColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.syntaxExplorerPageDescription,
              style: TextStyle(
                fontFamily: _bodyFont,
                fontSize: 14,
                height: 1.6,
                color: _SyntaxColors.muted,
              ),
            ),
          ],
        );
        if (constraints.maxWidth < 850) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [heading, const SizedBox(height: 18), metrics],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 24),
            metrics,
          ],
        );
      },
    );
  }
}

class _SyntaxMetrics extends StatelessWidget {
  final int entryCount;

  const _SyntaxMetrics({required this.entryCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _SyntaxColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: compact
              ? Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _MetricValue(
                      value: '$entryCount',
                      label: l10n.syntaxExplorerDocumentedCount,
                      color: _SyntaxColors.tertiary,
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MetricValue(
                      value: '$entryCount',
                      label: l10n.syntaxExplorerDocumentedCount,
                      color: _SyntaxColors.primary,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _MetricValue extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricValue({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: _codeFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _bodyFont,
              fontSize: 10,
              color: _SyntaxColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: _SyntaxColors.highest);
}

class _SyntaxSearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final SyntaxCategory selectedCategory;
  final String sortOrder;
  final List<String> quickSearchTokens;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;
  final ValueChanged<SyntaxCategory> onCategorySelected;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onQuickSearch;

  const _SyntaxSearchAndFilters({
    required this.controller,
    required this.focusNode,
    required this.selectedCategory,
    required this.sortOrder,
    required this.quickSearchTokens,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onCategorySelected,
    required this.onSortChanged,
    required this.onQuickSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      (SyntaxCategory.all, l10n.syntaxCategoryAll),
      (SyntaxCategory.keywords, l10n.syntaxCategoryKeywords),
      (SyntaxCategory.coreFunctions, l10n.syntaxCategoryBuiltins),
      (SyntaxCategory.builtinTypes, l10n.syntaxCategoryTypes),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _SyntaxColors.low,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final search = _SearchInput(
                controller: controller,
                focusNode: focusNode,
                onChanged: onSearchChanged,
                onSubmitted: onSearchSubmitted,
              );
              final sort = _SortSelector(
                value: sortOrder,
                onChanged: onSortChanged,
              );
              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [search, const SizedBox(height: 10), sort],
                );
              }
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 12),
                  SizedBox(width: 220, child: sort),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...categories.map((category) {
                return _CategoryChip(
                  label: category.$2,
                  isSelected: selectedCategory == category.$1,
                  onTap: () => onCategorySelected(category.$1),
                );
              }),
              const SizedBox(width: 8),
              ...quickSearchTokens.map(
                (token) => _QuickSearchToken(
                  label: token,
                  onTap: () => onQuickSearch(token),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted(),
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        color: _SyntaxColors.text,
      ),
      decoration: InputDecoration(
        hintText: l10n.syntaxExplorerSearchHint,
        hintStyle: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 12,
          color: _SyntaxColors.outline,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _SyntaxColors.primary,
        ),
        suffixIcon: controller.text.isEmpty
            ? Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Center(
                  widthFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _SyntaxColors.high,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ctrl + K',
                      style: TextStyle(
                        fontFamily: _codeFont,
                        fontSize: 9,
                        color: _SyntaxColors.outline,
                      ),
                    ),
                  ),
                ),
              )
            : IconButton(
                tooltip: l10n.syntaxExplorerClearSearch,
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: _SyntaxColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _SyntaxColors.primaryContainer),
        ),
      ),
    );
  }
}

class _SortSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SortSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _SyntaxColors.surface,
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _SyntaxColors.high,
          iconEnabledColor: _SyntaxColors.muted,
          style: const TextStyle(
            fontFamily: _bodyFont,
            fontSize: 12,
            color: _SyntaxColors.muted,
          ),
          items: [
            DropdownMenuItem(
              value: 'alphabetical',
              child: Text(l10n.syntaxExplorerSortAlphabetical),
            ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _SyntaxColors.primary : _SyntaxColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: _bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? _SyntaxColors.background
                  : _SyntaxColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickSearchToken extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSearchToken({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: _SyntaxColors.high,
      side: BorderSide.none,
      labelStyle: const TextStyle(
        fontFamily: _codeFont,
        fontSize: 10,
        color: _SyntaxColors.primary,
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _SyntaxCatalog extends StatelessWidget {
  final List<SyntaxDocEntryModel> entries;
  final String selectedEntryId;
  final Set<String> bookmarkedEntryIds;
  final int totalCount;
  final bool canLoadMore;
  final VoidCallback onLoadMore;
  final ValueChanged<SyntaxDocEntryModel> onSelectEntry;

  const _SyntaxCatalog({
    required this.entries,
    required this.selectedEntryId,
    required this.bookmarkedEntryIds,
    required this.totalCount,
    required this.canLoadMore,
    required this.onLoadMore,
    required this.onSelectEntry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.syntaxExplorerEntriesHeading,
                style: TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _SyntaxColors.text,
                ),
              ),
              _CountBadge(count: totalCount),
              const Text(
                'GDScript',
                style: TextStyle(
                  fontFamily: _codeFont,
                  fontSize: 9,
                  color: _SyntaxColors.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const _EmptyCatalog()
        else
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SyntaxEntryCard(
                entry: entry,
                isSelected: entry.id == selectedEntryId,
                isBookmarked: bookmarkedEntryIds.contains(entry.id),
                onTap: () => onSelectEntry(entry),
              ),
            ),
          ),
        if (totalCount > 0) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: _SyntaxColors.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.syntaxExplorerVisibleCount(
                      entries.length,
                      totalCount,
                    ),
                    style: const TextStyle(
                      fontFamily: _codeFont,
                      fontSize: 10,
                      color: _SyntaxColors.outline,
                    ),
                  ),
                ),
                if (canLoadMore)
                  TextButton.icon(
                    onPressed: onLoadMore,
                    icon: const Icon(Icons.expand_more_rounded, size: 15),
                    label: Text(l10n.syntaxExplorerLoadMore),
                    style: TextButton.styleFrom(
                      foregroundColor: _SyntaxColors.primary,
                      textStyle: const TextStyle(
                        fontFamily: _bodyFont,
                        fontSize: 10,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _SyntaxColors.high,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        l10n.syntaxExplorerCount(count),
        style: TextStyle(
          fontFamily: _codeFont,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _SyntaxColors.primary,
        ),
      ),
    );
  }
}

class _SyntaxEntryCard extends StatelessWidget {
  final SyntaxDocEntryModel entry;
  final bool isSelected;
  final bool isBookmarked;
  final VoidCallback onTap;

  const _SyntaxEntryCard({
    required this.entry,
    required this.isSelected,
    required this.isBookmarked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = isSelected
        ? _SyntaxColors.primary
        : switch (entry.category) {
            SyntaxCategory.keywords => _SyntaxColors.primary,
            SyntaxCategory.builtinTypes => _SyntaxColors.secondary,
            SyntaxCategory.engineDecorators => _SyntaxColors.primaryContainer,
            SyntaxCategory.coreFunctions ||
            SyntaxCategory.math2D => _SyntaxColors.tertiary,
            SyntaxCategory.all => _SyntaxColors.outline,
          };
    final cardTitle = entry.title;
    return Material(
      color: isSelected ? _SyntaxColors.high : _SyntaxColors.low,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: _SyntaxColors.primary,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 5,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _SmallTag(label: entry.categoryLabel, color: accent),
                      Text(
                        entry.godotVersion.isEmpty
                            ? ''
                            : entry.godotVersion.replaceAll('Godot ', ''),
                        style: const TextStyle(
                          fontFamily: _codeFont,
                          fontSize: 9,
                          color: _SyntaxColors.outline,
                        ),
                      ),
                      if (isSelected)
                        _SelectedLabel(label: l10n.syntaxExplorerSelected)
                      else if (isBookmarked)
                        const Icon(
                          Icons.bookmark_rounded,
                          size: 15,
                          color: _SyntaxColors.secondary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    cardTitle,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: _codeFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? _SyntaxColors.primary
                          : _SyntaxColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.briefDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: _bodyFont,
                      fontSize: 12,
                      height: 1.5,
                      color: _SyntaxColors.muted,
                    ),
                  ),
                  if (!isSelected) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.relatedConcepts.isEmpty
                                ? entry.categoryLabel
                                : entry.relatedConcepts.first,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: _bodyFont,
                              fontSize: 9,
                              color: _SyntaxColors.outline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            entry.signature.split('\n').first,
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: _codeFont,
                              fontSize: 8,
                              color: _SyntaxColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SelectedLabel extends StatelessWidget {
  const _SelectedLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 7, color: _SyntaxColors.tertiary),
      SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 9,
          color: _SyntaxColors.tertiary,
        ),
      ),
    ],
  );
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _SyntaxColors.low,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: _SyntaxColors.outline),
          const SizedBox(height: 8),
          Text(
            l10n.syntaxExplorerNoResults,
            style: const TextStyle(
              fontFamily: _bodyFont,
              color: _SyntaxColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyntaxDetailView extends StatelessWidget {
  final SyntaxDocEntryModel entry;
  final VoidCallback onCopyTitle;
  final VoidCallback onCopyCode;
  final VoidCallback? onOpenLesson;
  final VoidCallback onOpenWorkspace;

  const _SyntaxDetailView({
    required this.entry,
    required this.onCopyTitle,
    required this.onCopyCode,
    required this.onOpenLesson,
    required this.onOpenWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SyntaxOverviewCard(
          entry: entry,
          onCopyTitle: onCopyTitle,
          onOpenLesson: onOpenLesson,
        ),
        const SizedBox(height: 14),
        _SyntaxSignatureCard(entry: entry),
        const SizedBox(height: 14),
        if (entry.keyFeatures.isNotEmpty || entry.cautions.isNotEmpty) ...[
          _SyntaxKeyPoints(entry: entry),
          const SizedBox(height: 14),
        ],
        _SyntaxExampleCard(
          entry: entry,
          onCopyCode: onCopyCode,
          onOpenWorkspace: onOpenWorkspace,
        ),
      ],
    );
  }
}

class _SyntaxExampleCard extends StatelessWidget {
  const _SyntaxExampleCard({
    required this.entry,
    required this.onCopyCode,
    required this.onOpenWorkspace,
  });

  final SyntaxDocEntryModel entry;
  final VoidCallback onCopyCode;
  final VoidCallback onOpenWorkspace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _SyntaxColors.low,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.syntaxExplorerExample,
                  style: const TextStyle(
                    fontFamily: _bodyFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _SyntaxColors.text,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.syntaxExplorerCopyExample,
                onPressed: onCopyCode,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _SyntaxColors.lowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              entry.codeExample,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: _codeFont,
                fontSize: 12,
                height: 1.65,
                color: _SyntaxColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: onOpenWorkspace,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(l10n.syntaxExplorerOpenWorkspace),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyntaxOverviewCard extends StatelessWidget {
  final SyntaxDocEntryModel entry;
  final VoidCallback onCopyTitle;
  final VoidCallback? onOpenLesson;

  const _SyntaxOverviewCard({
    required this.entry,
    required this.onCopyTitle,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _SyntaxColors.low,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _SyntaxColors.primaryContainer.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.data_object_rounded,
                      color: _SyntaxColors.primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 7,
                          runSpacing: 4,
                          children: [
                            Text(
                              entry.title,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                fontFamily: _codeFont,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: _SyntaxColors.text,
                              ),
                            ),
                            _SmallTag(
                              label: entry.categoryLabel,
                              color: _SyntaxColors.primary,
                            ),
                            if (entry.godotVersion.isNotEmpty)
                              _SmallTag(
                                label: entry.godotVersion,
                                color: _SyntaxColors.outline,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.briefDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _bodyFont,
                            fontSize: 11,
                            color: _SyntaxColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 7,
                children: [
                  _IconAction(
                    tooltip: l10n.syntaxExplorerCopyEntry,
                    icon: Icons.content_copy_rounded,
                    onPressed: onCopyTitle,
                  ),
                  if (onOpenLesson != null)
                    TextButton.icon(
                      onPressed: onOpenLesson,
                      icon: const Icon(Icons.school_outlined, size: 15),
                      label: Text(l10n.syntaxExplorerOpenLesson),
                      style: TextButton.styleFrom(
                        backgroundColor: _SyntaxColors.primaryContainer,
                        foregroundColor: const Color(0xFF002C46),
                        textStyle: const TextStyle(
                          fontFamily: _bodyFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              );
              if (constraints.maxWidth < 640) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heading,
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: actions,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _SyntaxColors.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              entry.detailedExplanation,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 13,
                height: 1.8,
                color: _SyntaxColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _IconAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color = _SyntaxColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: _SyntaxColors.surface,
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 17),
    );
  }
}

class _SyntaxSignatureCard extends StatelessWidget {
  final SyntaxDocEntryModel entry;

  const _SyntaxSignatureCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.syntaxExplorerSignature,
                style: const TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _SyntaxColors.outline,
                ),
              ),
            ),
            Text(
              entry.godotVersion,
              style: const TextStyle(
                fontFamily: _codeFont,
                fontSize: 10,
                color: _SyntaxColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _SyntaxColors.lowest,
            borderRadius: BorderRadius.circular(9),
          ),
          child: SelectableText(
            entry.signature,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: _codeFont,
              fontSize: 12,
              height: 1.7,
              color: _SyntaxColors.tertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SyntaxKeyPoints extends StatelessWidget {
  final SyntaxDocEntryModel entry;

  const _SyntaxKeyPoints({required this.entry});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final features = _KeyPointPanel(
          title: 'أهم المزايا والخصائص',
          icon: Icons.check_circle_outline_rounded,
          color: _SyntaxColors.tertiary,
          items: entry.keyFeatures,
        );
        final cautions = _KeyPointPanel(
          title: 'تحذيرات الاستخدام',
          icon: Icons.warning_amber_rounded,
          color: _SyntaxColors.secondary,
          items: entry.cautions,
        );
        if (constraints.maxWidth < 560) {
          return Column(
            children: [features, const SizedBox(height: 8), cautions],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: features),
            const SizedBox(width: 8),
            Expanded(child: cautions),
          ],
        );
      },
    );
  }
}

class _KeyPointPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _KeyPointPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _SyntaxColors.surface,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontFamily: _bodyFont,
                      fontSize: 10,
                      color: color,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: _bodyFont,
                        fontSize: 10,
                        height: 1.5,
                        color: _SyntaxColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyntaxSandbox extends StatelessWidget {
  final SyntaxDocEntryModel entry;
  final TextEditingController codeController;
  final String consoleMessage;
  final VoidCallback onCopyCode;
  final VoidCallback onOpenWorkspace;
  final VoidCallback onOpenLesson;
  final VoidCallback onResetCode;
  final VoidCallback onClearConsole;

  const _SyntaxSandbox({
    required this.entry,
    required this.codeController,
    required this.consoleMessage,
    required this.onCopyCode,
    required this.onOpenWorkspace,
    required this.onOpenLesson,
    required this.onResetCode,
    required this.onClearConsole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _SyntaxColors.low,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SandboxToolbar(onReset: onResetCode, onRun: onOpenWorkspace),
          _CodeEditor(codeController: codeController, entry: entry),
          _SandboxConsole(message: consoleMessage, onClear: onClearConsole),
          _SandboxFooter(
            onCopy: onCopyCode,
            onOpenWorkspace: onOpenWorkspace,
            onOpenLesson: onOpenLesson,
          ),
        ],
      ),
    );
  }
}

class _SandboxToolbar extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onRun;

  const _SandboxToolbar({required this.onReset, required this.onRun});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      color: _SyntaxColors.surface,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WindowDot(color: Color(0xFFFF6B6B)),
              SizedBox(width: 5),
              _WindowDot(color: _SyntaxColors.secondary),
              SizedBox(width: 5),
              _WindowDot(color: _SyntaxColors.tertiary),
              SizedBox(width: 10),
              Text(
                'res://sandbox/example.gd',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: _codeFont,
                  fontSize: 9,
                  color: _SyntaxColors.muted,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded, size: 16),
            label: const Text('إعادة ضبط'),
            style: TextButton.styleFrom(
              foregroundColor: _SyntaxColors.muted,
              textStyle: const TextStyle(fontFamily: _bodyFont, fontSize: 10),
            ),
          ),
          FilledButton.icon(
            onPressed: onRun,
            icon: const Icon(Icons.play_arrow_rounded, size: 17),
            label: const Text('فتح في مساحة العمل'),
            style: FilledButton.styleFrom(
              backgroundColor: _SyntaxColors.tertiary,
              foregroundColor: const Color(0xFF003919),
              textStyle: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  final Color color;

  const _WindowDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 9,
    height: 9,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _CodeEditor extends StatelessWidget {
  final TextEditingController codeController;
  final SyntaxDocEntryModel entry;

  const _CodeEditor({required this.codeController, required this.entry});

  @override
  Widget build(BuildContext context) {
    final lineCount = codeController.text.split('\n').length;
    return Container(
      color: _SyntaxColors.lowest,
      padding: const EdgeInsets.all(14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '# مثال GDScript — ${entry.title}',
              style: const TextStyle(
                fontFamily: _codeFont,
                fontSize: 10,
                color: _SyntaxColors.outline,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lineCount < 12 ? 12 : lineCount,
                    (index) => SizedBox(
                      height: 18.7,
                      child: Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: const TextStyle(
                          fontFamily: _codeFont,
                          fontSize: 9,
                          color: _SyntaxColors.outline,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: _SyntaxColors.outlineVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: codeController,
                    minLines: 12,
                    maxLines: 20,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontFamily: _codeFont,
                      fontSize: 11,
                      height: 1.7,
                      color: _SyntaxColors.primary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: _SyntaxColors.outlineVariant),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 7, color: _SyntaxColors.tertiary),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'gdscript_engine · جاهز للتشغيل',
                      style: TextStyle(
                        fontFamily: _codeFont,
                        fontSize: 8,
                        color: _SyntaxColors.outline,
                      ),
                    ),
                  ),
                  Text(
                    'LSP: متصل',
                    style: TextStyle(
                      fontFamily: _codeFont,
                      fontSize: 8,
                      color: _SyntaxColors.outline,
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
}

class _SandboxConsole extends StatelessWidget {
  final String message;
  final VoidCallback onClear;

  const _SandboxConsole({required this.message, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          color: _SyntaxColors.surface,
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: _SyntaxColors.tertiary),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'تنفيذ عبر gdscript_engine (3ms)',
                  style: TextStyle(
                    fontFamily: _codeFont,
                    fontSize: 9,
                    color: _SyntaxColors.tertiary,
                  ),
                ),
              ),
              const Text(
                'LSP: متصل',
                style: TextStyle(
                  fontFamily: _codeFont,
                  fontSize: 8,
                  color: _SyntaxColors.outline,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: _SyntaxColors.outline,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 28),
                ),
                child: const Text(
                  'مسح السجل',
                  style: TextStyle(fontFamily: _bodyFont, fontSize: 9),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          color: _SyntaxColors.lowest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SelectableText(
                '[GDScript 4.3 Virtual LSP Engine: Initialized successfully]',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: _codeFont,
                  fontSize: 8,
                  color: _SyntaxColors.outline,
                ),
              ),
              const SizedBox(height: 5),
              const SelectableText(
                '> Output Execution Result:',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: _codeFont,
                  fontSize: 9,
                  color: _SyntaxColors.tertiary,
                ),
              ),
              const SizedBox(height: 3),
              SelectableText(
                message,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: _codeFont,
                  fontSize: 9,
                  height: 1.6,
                  color: _SyntaxColors.text,
                ),
              ),
              const SizedBox(height: 4),
              const SelectableText(
                '> Process finished with exit code 0 (Success).',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: _codeFont,
                  fontSize: 8,
                  color: _SyntaxColors.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SandboxFooter extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onOpenWorkspace;
  final VoidCallback onOpenLesson;

  const _SandboxFooter({
    required this.onCopy,
    required this.onOpenWorkspace,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          Wrap(
            spacing: 7,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenWorkspace,
                icon: const Icon(Icons.terminal_rounded, size: 16),
                label: const Text('فتح في محرر مساحة العمل'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _SyntaxColors.text,
                  side: const BorderSide(color: _SyntaxColors.outlineVariant),
                  textStyle: const TextStyle(
                    fontFamily: _bodyFont,
                    fontSize: 10,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'نسخ الكود الكامل',
                onPressed: onCopy,
                icon: const Icon(Icons.content_copy_rounded, size: 17),
                color: _SyntaxColors.muted,
                style: IconButton.styleFrom(
                  backgroundColor: _SyntaxColors.high,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: onOpenLesson,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text(
              'انتقل إلى الدرس المرتبط: الدرس 8 — المطابقة match',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _SyntaxColors.primary,
              foregroundColor: const Color(0xFF003350),
              textStyle: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySyntaxDetail extends StatelessWidget {
  const _EmptySyntaxDetail();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: const BoxConstraints(minHeight: 250),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _SyntaxColors.low,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.syntaxExplorerSelectEntry,
        style: const TextStyle(
          fontFamily: _bodyFont,
          color: _SyntaxColors.muted,
        ),
      ),
    );
  }
}
