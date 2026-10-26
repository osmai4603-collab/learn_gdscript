// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 14: الإعدادات وتفضيلات النظام وبيئة المحرك (Desktop Settings & Engine Preferences)
// الملف: desktop_settings_screen.dart
// نموذج تصميم غير موصول؛ لا يعكس إعدادات التكامل الفعلية في التطبيق.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/color_schemes.dart';
import 'package:learn_gdscript/ui/routers/app_routes.dart';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات الخاصة بالإعدادات والتفضيلات (Data Models)
// -----------------------------------------------------------------------------

enum SettingsCategory {
  editor,
  engineLsp,
  appearance,
  audioAccessibility,
  account,
}

class EditorPreferencesModel {
  final int fontSize;
  final String fontFamily;
  final int tabSize;
  final bool insertSpaces;
  final bool showLineNumbers;
  final bool enableWordWrap;
  final bool highlightActiveLine;
  final bool autoCloseBrackets;

  const EditorPreferencesModel({
    required this.fontSize,
    required this.fontFamily,
    required this.tabSize,
    required this.insertSpaces,
    required this.showLineNumbers,
    required this.enableWordWrap,
    required this.highlightActiveLine,
    required this.autoCloseBrackets,
  });
}

class EngineLspPreferencesModel {
  final String godotBinaryPath;
  final String lspServerAddress;
  final int lspPort;
  final bool autoStartLsp;
  final bool strictTypingWarnings;
  final bool unreachableCodeWarnings;
  final int targetFpsLimit;

  const EngineLspPreferencesModel({
    required this.godotBinaryPath,
    required this.lspServerAddress,
    required this.lspPort,
    required this.autoStartLsp,
    required this.strictTypingWarnings,
    required this.unreachableCodeWarnings,
    required this.targetFpsLimit,
  });
}

class AppAppearancePreferencesModel {
  final String themeMode; // Dark, Light, System
  final String uiFont;
  final bool enableGpuVsync;
  final bool enableCodeMinimap;

  const AppAppearancePreferencesModel({
    required this.themeMode,
    required this.uiFont,
    required this.enableGpuVsync,
    required this.enableCodeMinimap,
  });
}

class SettingsDataModel {
  final SettingsCategory activeCategory;
  final EditorPreferencesModel editor;
  final EngineLspPreferencesModel engineLsp;
  final AppAppearancePreferencesModel appearance;
  final String userEmail;
  final String accountType;

  const SettingsDataModel({
    required this.activeCategory,
    required this.editor,
    required this.engineLsp,
    required this.appearance,
    required this.userEmail,
    required this.accountType,
  });

  static SettingsDataModel sampleData() {
    return const SettingsDataModel(
      activeCategory: SettingsCategory.editor,
      editor: EditorPreferencesModel(
        fontSize: 14,
        fontFamily: 'JetBrains Mono',
        tabSize: 4,
        insertSpaces: true,
        showLineNumbers: true,
        enableWordWrap: false,
        highlightActiveLine: true,
        autoCloseBrackets: true,
      ),
      engineLsp: EngineLspPreferencesModel(
        godotBinaryPath: '/usr/local/bin/godot4',
        lspServerAddress: '127.0.0.1',
        lspPort: 6005,
        autoStartLsp: true,
        strictTypingWarnings: true,
        unreachableCodeWarnings: true,
        targetFpsLimit: 60,
      ),
      appearance: AppAppearancePreferencesModel(
        themeMode: 'داكن (Godot 4 Dark)',
        uiFont: 'IBM Plex Sans Arabic',
        enableGpuVsync: true,
        enableCodeMinimap: false,
      ),
      userEmail: 'tariq.godot@academy.dev',
      accountType: 'Godot Developer Pro',
    );
  }
}

// -----------------------------------------------------------------------------
// 2. الشاشة الرئيسية للإعدادات والتفضيلات (DesktopSettingsScreen)
// -----------------------------------------------------------------------------

class DesktopSettingsScreen extends StatefulWidget {
  final SettingsDataModel data;
  final ValueChanged<String>? onNavigateRoute;
  final VoidCallback? onResetPlacement;

  const DesktopSettingsScreen({
    super.key,
    required this.data,
    this.onNavigateRoute,
    this.onResetPlacement,
  });

  @override
  State<DesktopSettingsScreen> createState() => _DesktopSettingsScreenState();
}

class _DesktopSettingsScreenState extends State<DesktopSettingsScreen> {
  late SettingsCategory _selectedCategory;
  late double _fontSize;
  late int _tabSize;
  late bool _showLineNumbers;
  late bool _highlightActiveLine;
  late bool _autoCloseBrackets;
  late bool _strictTyping;
  late bool _autoStartLsp;
  late TextEditingController _godotPathController;
  late TextEditingController _lspPortController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.data.activeCategory;
    _fontSize = widget.data.editor.fontSize.toDouble();
    _tabSize = widget.data.editor.tabSize;
    _showLineNumbers = widget.data.editor.showLineNumbers;
    _highlightActiveLine = widget.data.editor.highlightActiveLine;
    _autoCloseBrackets = widget.data.editor.autoCloseBrackets;
    _strictTyping = widget.data.engineLsp.strictTypingWarnings;
    _autoStartLsp = widget.data.engineLsp.autoStartLsp;
    _godotPathController = TextEditingController(
      text: widget.data.engineLsp.godotBinaryPath,
    );
    _lspPortController = TextEditingController(
      text: '${widget.data.engineLsp.lspPort}',
    );
  }

  @override
  void dispose() {
    _godotPathController.dispose();
    _lspPortController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.successContainer,
        content: Text(
          'تم حفظ كافة التفضيلات بنجاح وتمت مزامنتها مع محرك Godot 4.3 ✓',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // 1. الشريط العلوي العام
          _SettingsTopNav(
            onSave: _saveSettings,
            onNavigate: widget.onNavigateRoute,
          ),
           Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),

          // 2. الهيكل الرئيسي (Settings Categories Nav + Detail Form)
          Expanded(
            child: Row(
              children: [
                // قائمة فئات الإعدادات الداخلية
                SizedBox(
                  width: 280,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            'أقسام التفضيلات',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        _CategoryTabTile(
                          icon: Icons.code_rounded,
                          title: 'محرر الأكواد والخطوط',
                          category: SettingsCategory.editor,
                          isSelected:
                              _selectedCategory == SettingsCategory.editor,
                          onTap: () => setState(
                            () => _selectedCategory = SettingsCategory.editor,
                          ),
                        ),
                        _CategoryTabTile(
                          icon: Icons.dns_rounded,
                          title: 'خادم LSP ومسار المحرك',
                          category: SettingsCategory.engineLsp,
                          isSelected:
                              _selectedCategory == SettingsCategory.engineLsp,
                          onTap: () => setState(
                            () =>
                                _selectedCategory = SettingsCategory.engineLsp,
                          ),
                        ),
                        _CategoryTabTile(
                          icon: Icons.palette_rounded,
                          title: 'المظهر والسمة البصرية',
                          category: SettingsCategory.appearance,
                          isSelected:
                              _selectedCategory == SettingsCategory.appearance,
                          onTap: () => setState(
                            () =>
                                _selectedCategory = SettingsCategory.appearance,
                          ),
                        ),
                        _CategoryTabTile(
                          icon: Icons.manage_accounts_rounded,
                          title: 'الحساب والمسار الأكاديمي',
                          category: SettingsCategory.account,
                          isSelected:
                              _selectedCategory == SettingsCategory.account,
                          onTap: () => setState(
                            () => _selectedCategory = SettingsCategory.account,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                 VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),

                // لوحة النماذج وتعديل الإعدادات
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 28,
                      ),
                      children: [
                        if (_selectedCategory == SettingsCategory.editor)
                          _EditorSettingsForm(
                            fontSize: _fontSize,
                            tabSize: _tabSize,
                            showLineNumbers: _showLineNumbers,
                            highlightActiveLine: _highlightActiveLine,
                            autoCloseBrackets: _autoCloseBrackets,
                            onFontSizeChanged: (v) =>
                                setState(() => _fontSize = v),
                            onTabSizeChanged: (v) =>
                                setState(() => _tabSize = v),
                            onToggleLineNumbers: (v) =>
                                setState(() => _showLineNumbers = v),
                            onToggleHighlight: (v) =>
                                setState(() => _highlightActiveLine = v),
                            onToggleBrackets: (v) =>
                                setState(() => _autoCloseBrackets = v),
                          )
                        else if (_selectedCategory ==
                            SettingsCategory.engineLsp)
                          _EngineLspSettingsForm(
                            godotPathController: _godotPathController,
                            portController: _lspPortController,
                            strictTyping: _strictTyping,
                            autoStartLsp: _autoStartLsp,
                            onToggleStrict: (v) =>
                                setState(() => _strictTyping = v),
                            onToggleAutoStart: (v) =>
                                setState(() => _autoStartLsp = v),
                            onOpenDiagnostics: () => widget.onNavigateRoute
                                ?.call(AppRoutes.engineDiagnostics),
                          )
                        else if (_selectedCategory ==
                            SettingsCategory.appearance)
                          _AppearanceSettingsForm(
                            appearance: widget.data.appearance,
                          )
                        else if (_selectedCategory == SettingsCategory.account)
                          _AccountSettingsForm(
                            email: widget.data.userEmail,
                            accountType: widget.data.accountType,
                            onResetPlacement: widget.onResetPlacement,
                          ),
                        const SizedBox(height: 40),
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

// -----------------------------------------------------------------------------
// 3. المكونات المستقلة للواجهة (Modular Widgets)
// -----------------------------------------------------------------------------

class _SettingsTopNav extends StatelessWidget {
  final VoidCallback onSave;
  final ValueChanged<String>? onNavigate;

  const _SettingsTopNav({required this.onSave, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Row(
            children:  [
              Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'أكاديمية جودو',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 8),
              Text('/', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              SizedBox(width: 8),
              Text(
                'الإعدادات وتفضيلات النظام وبيئة المحرك (Desktop Settings)',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_rounded, size: 16),
            label: const Text(
              'حفظ التغييرات (Ctrl+S) ↵',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final SettingsCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTabTile({
    required this.icon,
    required this.title,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.surfaceContainerHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorSettingsForm extends StatelessWidget {
  final double fontSize;
  final int tabSize;
  final bool showLineNumbers;
  final bool highlightActiveLine;
  final bool autoCloseBrackets;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<int> onTabSizeChanged;
  final ValueChanged<bool> onToggleLineNumbers;
  final ValueChanged<bool> onToggleHighlight;
  final ValueChanged<bool> onToggleBrackets;

  const _EditorSettingsForm({
    required this.fontSize,
    required this.tabSize,
    required this.showLineNumbers,
    required this.highlightActiveLine,
    required this.autoCloseBrackets,
    required this.onFontSizeChanged,
    required this.onTabSizeChanged,
    required this.onToggleLineNumbers,
    required this.onToggleHighlight,
    required this.onToggleBrackets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'تفضيلات محرر الكود (GDScript Editor)',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
         Text(
          'تخصيص مقاس الخط، التباعد، وسلوك الإكمال التلقائي في بيئة التطوير.',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
         Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 20),

        // مقاس الخط البرمجي
        _SettingRow(
          title: 'مقاس خط المحرر البرمجي (${fontSize.toInt()} px):',
          subtitle:
              'يتم تطبيق المقاس على خط JetBrains Mono المخصص لكتابة GDScript.',
          control: SizedBox(
            width: 220,
            child: Slider(
              value: fontSize,
              min: 11,
              max: 20,
              divisions: 9,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: onFontSizeChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // مسافة التاب
        _SettingRow(
          title: 'مسافة الإزاحة (Tab Size):',
          subtitle: 'المعيار الرسمي في GDScript 2.0 هو 4 مسافات مسافية.',
          control: DropdownButton<int>(
            value: tabSize,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerLow,
            style:  TextStyle(
              fontFamily: 'JetBrains Mono',
              color: Theme.of(context).colorScheme.onSurface,
            ),
            items: const [
              DropdownMenuItem(value: 2, child: Text('2 مسافات')),
              DropdownMenuItem(value: 4, child: Text('4 مسافات (موصى به)')),
              DropdownMenuItem(value: 8, child: Text('8 مسافات')),
            ],
            onChanged: (v) => v != null ? onTabSizeChanged(v) : null,
          ),
        ),
        const SizedBox(height: 20),

        // إظهار أرقام الأسطر
        _SettingSwitchRow(
          title: 'إظهار أرقام الأسطر (Line Numbers)',
          subtitle: 'عرض عمود الأرقام على يمين المحرر لسهولة التتبع والتشخيص.',
          value: showLineNumbers,
          onChanged: onToggleLineNumbers,
        ),
        const SizedBox(height: 16),

        // تمييز السطر النشط
        _SettingSwitchRow(
          title: 'إبراز السطر النشط (Highlight Active Line)',
          subtitle: 'تظليل خلفية السطر الذي يقف عليه المؤشر بلون مغاير.',
          value: highlightActiveLine,
          onChanged: onToggleHighlight,
        ),
        const SizedBox(height: 16),

        // إغلاق الأقواس تلقائياً
        _SettingSwitchRow(
          title: 'إغلاق الأقواس وعلامات التنصيص تلقائياً',
          subtitle: 'إكمال الأقواس () و [] و {} وعلامات "" فور كتابتها.',
          value: autoCloseBrackets,
          onChanged: onToggleBrackets,
        ),
      ],
    );
  }
}

class _EngineLspSettingsForm extends StatelessWidget {
  final TextEditingController godotPathController;
  final TextEditingController portController;
  final bool strictTyping;
  final bool autoStartLsp;
  final ValueChanged<bool> onToggleStrict;
  final ValueChanged<bool> onToggleAutoStart;
  final VoidCallback onOpenDiagnostics;

  const _EngineLspSettingsForm({
    required this.godotPathController,
    required this.portController,
    required this.strictTyping,
    required this.autoStartLsp,
    required this.onToggleStrict,
    required this.onToggleAutoStart,
    required this.onOpenDiagnostics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text(
                  'خادم اللغة LSP ومحرك Godot 4.3',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'إدارة جسر الاتصال المحلي ومسارات تشغيل المحرك وبروتوكول JSON-RPC 2.0.',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: onOpenDiagnostics,
              icon: const Icon(Icons.monitor_heart_rounded, size: 16),
              label: const Text(
                'فتح سجل التشخيصات المباشر ↵',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side:  BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
         Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 20),

        // مسار ملف Godot التنفيذي
         Text(
          'مسار المحرك التنفيذي (Godot Executable Path):',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: godotPathController,
              style:  TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // منفذ خادم LSP
         Text(
          'منفذ الاتصال المحلي (LSP Port):',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              style:  TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 20),

        _SettingSwitchRow(
          title: 'فرض تحذيرات الأنواع غير الصارمة (Strict Typing)',
          subtitle:
              'إطلاق تحذيرات فورية عند كتابة متغيرات Variant ديناميكية بدون تصريح نوع صريح.',
          value: strictTyping,
          onChanged: onToggleStrict,
        ),
        const SizedBox(height: 16),

        _SettingSwitchRow(
          title: 'بدء تشغيل خادم LSP تلقائياً عند فتح الأكاديمية',
          subtitle: 'تهيئة وإطلاق جسر الاتصال في الخلفية بمجرد تشغيل الواجهة.',
          value: autoStartLsp,
          onChanged: onToggleAutoStart,
        ),
      ],
    );
  }
}

class _AppearanceSettingsForm extends StatelessWidget {
  final AppAppearancePreferencesModel appearance;

  const _AppearanceSettingsForm({required this.appearance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'المظهر والسمة البصرية',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
         Text(
          'تخصيص نسق الألوان بما يطابق واجهة محرك Godot الرسمية وتفضيلات شاشتك.',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
         Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 20),

        _SettingRow(
          title: 'السمة النشطة:',
          subtitle:
              'الوضع الداكن المعتمد بدرجات الأزرق والرمادي الداكن #0F141B.',
          control: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Text(
              appearance.themeMode,
              style:  TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        _SettingRow(
          title: 'خط الواجهة العربي:',
          subtitle: 'خط معتمد عالي الوضوح للغة العربية في البرمجيات التقنية.',
          control: Text(
            appearance.uiFont,
            style:  TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountSettingsForm extends StatelessWidget {
  final String email;
  final String accountType;
  final VoidCallback? onResetPlacement;

  const _AccountSettingsForm({
    required this.email,
    required this.accountType,
    this.onResetPlacement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'الحساب والمسار الأكاديمي',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
         Text(
          'بيانات حساب المتعلّم وإعادة تقييم المستوى الأكاديمي.',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
         Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 20),

        _SettingRow(
          title: 'البريد الإلكتروني المعتمد:',
          subtitle:
              'مرتبط بحساب حفظ ومزامنة مسارات التعلّم ومشاريع مساحة العمل.',
          control: Text(
            email,
            style:  TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 20),

        _SettingRow(
          title: 'خطة الاشتراك والرتبة:',
          subtitle:
              'ترقية الحساب تتيح الوصول لكامل بنك التحديات والشهادات المعتمدة.',
          control: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.successContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              accountType,
              style:  TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 11,
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text(
                    'إعادة اختبار تحديد المستوى الأكاديمي',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'إعادة ضبط مسار التعلّم وخوض التقييم التشخيصي للبدء من نقطة انطلاق جديدة.',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: onResetPlacement,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  side:  BorderSide(color: Theme.of(context).colorScheme.secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'إعادة التقييم ↵',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
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

class _SettingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget control;

  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:  TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style:  TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        control,
      ],
    );
  }
}

class _SettingSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:  TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style:  TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Theme.of(context).colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
