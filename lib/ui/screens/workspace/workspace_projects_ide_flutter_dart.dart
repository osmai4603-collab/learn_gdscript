// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 6: محرر ومشاريع مساحة العمل والبحث الشامل (Workspace & Projects IDE)
// الملف: desktop_workspace_ide_screen.dart
// ==============================================================================

import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات الخاصة بمساحة العمل والمشاريع (Data Models)
// -----------------------------------------------------------------------------

enum FileType { gdscript, scene, resource, shader, json, asset }

class ProjectFileNodeModel {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final bool isDirectory;
  final bool isExpanded;
  final List<ProjectFileNodeModel> children;
  final String content;

  const ProjectFileNodeModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    this.isDirectory = false,
    this.isExpanded = false,
    this.children = const [],
    this.content = '',
  });
}

class EditorTabModel {
  final String fileId;
  final String fileName;
  final String filePath;
  final bool isDirty;
  final FileType type;

  const EditorTabModel({
    required this.fileId,
    required this.fileName,
    required this.filePath,
    this.isDirty = false,
    required this.type,
  });
}

class WorkspaceDataModel {
  final String projectName;
  final String godotVersion;
  final bool isLspConnected;
  final List<ProjectFileNodeModel> fileTree;
  final List<EditorTabModel> openTabs;
  final String activeTabFileId;
  final String activeCodeContent;
  final int cursorLine;
  final int cursorColumn;

  const WorkspaceDataModel({
    required this.projectName,
    required this.godotVersion,
    required this.isLspConnected,
    required this.fileTree,
    required this.openTabs,
    required this.activeTabFileId,
    required this.activeCodeContent,
    this.cursorLine = 18,
    this.cursorColumn = 4,
  });

  String? codeForFilePath(String path) {
    final activeTab = openTabs.where((tab) => tab.fileId == activeTabFileId);
    if (activeTab.isNotEmpty && activeTab.first.filePath == path) {
      return activeCodeContent;
    }

    String? findContent(List<ProjectFileNodeModel> nodes) {
      for (final node in nodes) {
        if (node.path == path && !node.isDirectory) return node.content;
        final childContent = findContent(node.children);
        if (childContent != null) return childContent;
      }
      return null;
    }

    return findContent(fileTree);
  }

  static WorkspaceDataModel sampleData() {
    return WorkspaceDataModel(
      projectName: 'مشروع 2D Platformer Starter',
      godotVersion: 'Godot v4.3.stable',
      isLspConnected: true,
      openTabs: const [
        EditorTabModel(
          fileId: 'f_player',
          fileName: 'player.gd',
          filePath: 'res://scripts/player.gd',
          isDirty: true,
          type: FileType.gdscript,
        ),
        EditorTabModel(
          fileId: 'f_state_machine',
          fileName: 'state_machine.gd',
          filePath: 'res://scripts/state_machine.gd',
          isDirty: false,
          type: FileType.gdscript,
        ),
        EditorTabModel(
          fileId: 'f_level',
          fileName: 'level_01.tscn',
          filePath: 'res://scenes/level_01.tscn',
          isDirty: false,
          type: FileType.scene,
        ),
      ],
      activeTabFileId: 'f_player',
      activeCodeContent: '''extends CharacterBody2D
class_name PlayerController

@export_group("إعدادات الحركة الأساسية")
@export var speed: float = 240.0
@export var jump_impulse: float = -420.0
@export var gravity: float = 980.0

@onready var sprite: AnimatedSprite2D = \$AnimatedSprite2D
@onready var state_machine: Node = \$StateMachine

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
    # 1. تطبيق الجاذبية في الفضاء الثنائي
    if not is_on_floor():
        velocity.y += gravity * delta

    # 2. قراءة مدخلات لوحة المفاتيح الموحدة
    var input_x: float = Input.get_axis("move_left", "move_right")
    if input_x != 0.0:
        velocity.x = input_x * speed
        sprite.flip_h = input_x < 0
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed * 4.0 * delta)

    # 3. معالجة القفز السلس
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_impulse

    move_and_slide()
''',
      fileTree: const [
        ProjectFileNodeModel(
          id: 'dir_res',
          name: 'res:// (جذر المشروع)',
          path: 'res://',
          type: FileType.asset,
          isDirectory: true,
          isExpanded: true,
          children: [
            ProjectFileNodeModel(
              id: 'dir_scripts',
              name: 'scripts',
              path: 'res://scripts',
              type: FileType.asset,
              isDirectory: true,
              isExpanded: true,
              children: [
                ProjectFileNodeModel(
                  id: 'f_player',
                  name: 'player.gd',
                  path: 'res://scripts/player.gd',
                  type: FileType.gdscript,
                ),
                ProjectFileNodeModel(
                  id: 'f_state_machine',
                  name: 'state_machine.gd',
                  path: 'res://scripts/state_machine.gd',
                  type: FileType.gdscript,
                ),
                ProjectFileNodeModel(
                  id: 'f_enemy',
                  name: 'enemy_ai.gd',
                  path: 'res://scripts/enemy_ai.gd',
                  type: FileType.gdscript,
                ),
              ],
            ),
            ProjectFileNodeModel(
              id: 'dir_scenes',
              name: 'scenes',
              path: 'res://scenes',
              type: FileType.asset,
              isDirectory: true,
              isExpanded: true,
              children: [
                ProjectFileNodeModel(
                  id: 'f_player_scene',
                  name: 'Player.tscn',
                  path: 'res://scenes/Player.tscn',
                  type: FileType.scene,
                ),
                ProjectFileNodeModel(
                  id: 'f_level',
                  name: 'level_01.tscn',
                  path: 'res://scenes/level_01.tscn',
                  type: FileType.scene,
                ),
              ],
            ),
            ProjectFileNodeModel(
              id: 'f_project_godot',
              name: 'project.godot',
              path: 'res://project.godot',
              type: FileType.resource,
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. الشاشة الرئيسية لمحرر ومساحة العمل (DesktopWorkspaceIdeScreen)
// -----------------------------------------------------------------------------

class DesktopWorkspaceIdeScreen extends StatefulWidget {
  final WorkspaceDataModel data;
  final ValueChanged<String>? onNavigateRoute;
  final VoidCallback? onRunProject;
  final String? initialCode;
  final String? initialFilePath;
  final int? initialCursorLine;
  final bool initialSearchOpen;
  final String? initialSearchQuery;
  final String? initialNotice;

  const DesktopWorkspaceIdeScreen({
    super.key,
    required this.data,
    this.onNavigateRoute,
    this.onRunProject,
    this.initialCode,
    this.initialFilePath,
    this.initialCursorLine,
    this.initialSearchOpen = false,
    this.initialSearchQuery,
    this.initialNotice,
  });

  @override
  State<DesktopWorkspaceIdeScreen> createState() =>
      _DesktopWorkspaceIdeScreenState();
}

class _DesktopWorkspaceIdeScreenState extends State<DesktopWorkspaceIdeScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _codeEditorController;
  late FocusNode _editorFocusNode;
  late String _activeTabId;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late bool _isSearchOpen;
  final TextEditingController _findController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final matchingTab = widget.initialFilePath == null
        ? null
        : widget.data.openTabs
              .where((tab) => tab.filePath == widget.initialFilePath)
              .firstOrNull;
    _activeTabId = matchingTab?.fileId ?? widget.data.activeTabFileId;
    _codeEditorController = TextEditingController(
      text:
          widget.initialCode ??
          (widget.initialFilePath == null
              ? widget.data.activeCodeContent
              : widget.data.codeForFilePath(widget.initialFilePath!) ?? ''),
    );
    _editorFocusNode = FocusNode();
    final cursorLine = widget.initialCursorLine;
    if (cursorLine != null && cursorLine > 0) {
      var cursorOffset = 0;
      for (var line = 1; line < cursorLine; line++) {
        final nextLine = _codeEditorController.text.indexOf('\n', cursorOffset);
        if (nextLine == -1) {
          cursorOffset = _codeEditorController.text.length;
          break;
        }
        cursorOffset = nextLine + 1;
      }
      _codeEditorController.selection = TextSelection.collapsed(
        offset: cursorOffset
            .clamp(0, _codeEditorController.text.length)
            .toInt(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _editorFocusNode.requestFocus();
      });
    }
    _isSearchOpen = widget.initialSearchOpen;
    _findController.text = widget.initialSearchQuery ?? '';

    final notice = widget.initialNotice;
    if (notice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(notice)));
        }
      });
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _codeEditorController.dispose();
    _editorFocusNode.dispose();
    _findController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141B),
      body: Column(
        children: [
          _WorkspaceTopNav(
            isLspOnline: widget.data.isLspConnected,
            pulseAnimation: _pulseAnimation,
          ),
          const Divider(height: 1, color: Color(0xFF28323F)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final projectDetails = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Text(
                          'مساحة العمل',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: Color(0xFFC0C7D0),
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF8A919A),
                          size: 18,
                        ),
                        const Icon(
                          Icons.folder_open_rounded,
                          color: Color(0xFF91CDFF),
                          size: 18,
                        ),
                        Text(
                          widget.data.projectName,
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: Color(0xFFDEE2EC),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        _WorkspaceChip(
                          label: widget.data.godotVersion,
                          color: const Color(0xFF91CDFF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _WorkspaceMeta(
                          icon: Icons.check_circle_rounded,
                          text: 'تم فهرسة 14 ملفاً بنجاح (100%)',
                          color: const Color(0xFF4AE183),
                        ),
                        _WorkspaceMeta(
                          icon: Icons.source_rounded,
                          text: 'Git: main (clean)',
                          color: const Color(0xFFC0C7D0),
                        ),
                      ],
                    ),
                  ],
                );
                final actions = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WorkspaceActionButton(
                      icon: Icons.create_new_folder_outlined,
                      label: 'فتح مجلد',
                    ),
                    _WorkspaceActionButton(
                      icon: Icons.note_add_outlined,
                      label: 'ملف جديد',
                    ),
                    _WorkspaceActionButton(
                      icon: Icons.sync_rounded,
                      label: 'بناء الفهرس',
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onRunProject,
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text(
                        'تشغيل المشروع (F5)',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5397CA),
                        foregroundColor: const Color(0xFF002C46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );

                if (constraints.maxWidth < 860) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      projectDetails,
                      const SizedBox(height: 12),
                      actions,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: projectDetails),
                    const SizedBox(width: 16),
                    Flexible(child: actions),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1000;
                  final explorerWidth = compact ? 205.0 : 255.0;
                  final inspectorWidth = compact ? 230.0 : 285.0;
                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: explorerWidth,
                              child: _WorkspaceExplorerPanel(
                                data: widget.data,
                                searchOpen: _isSearchOpen,
                                searchController: _findController,
                                onToggleSearch: () => setState(
                                  () => _isSearchOpen = !_isSearchOpen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _WorkspaceEditorPanel(
                                data: widget.data,
                                controller: _codeEditorController,
                                activeTabId: _activeTabId,
                                focusNode: _editorFocusNode,
                                onSelectTab: (id) =>
                                    setState(() => _activeTabId = id),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: inspectorWidth,
                              child: const _WorkspaceInspectorPanel(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 178, child: _WorkspaceDockPanel()),
                    ],
                  );
                },
              ),
            ),
          ),
          _WorkspaceStatusBar(
            cursorLine: widget.data.cursorLine,
            cursorCol: widget.data.cursorColumn,
            lspOnline: widget.data.isLspConnected,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. المكونات المستقلة للواجهة (Modular Widgets)
// -----------------------------------------------------------------------------

class _WorkspaceTopNav extends StatelessWidget {
  final bool isLspOnline;
  final Animation<double> pulseAnimation;

  const _WorkspaceTopNav({
    required this.isLspOnline,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0xFF0F141B),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, _) {
              final statusColor = isLspOnline
                  ? const Color(0xFF4AE183)
                  : const Color(0xFFFFB783);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2027),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: statusColor.withValues(alpha: pulseAnimation.value),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLspOnline
                          ? 'محرك GDScript: متصل  |  LSP: نشط'
                          : 'محرك GDScript: غير متصل',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          const _WorkspaceChip(label: '🔥  3 أيام', color: Color(0xFFFFB783)),
          const SizedBox(width: 10),
          const _WorkspaceChip(label: '◆  420 XP', color: Color(0xFF91CDFF)),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF252A32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFDEE2EC),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  final String label;
  final Color color;

  const _WorkspaceChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WorkspaceMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _WorkspaceMeta({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            color: color,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _WorkspaceActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WorkspaceActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 17, color: const Color(0xFF91CDFF)),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          color: Color(0xFFDEE2EC),
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF252A32),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _WorkspaceExplorerPanel extends StatelessWidget {
  final WorkspaceDataModel data;
  final bool searchOpen;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;

  const _WorkspaceExplorerPanel({
    required this.data,
    required this.searchOpen,
    required this.searchController,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171C23),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF252A32)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF090F15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF252A32),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_copy_outlined,
                                        size: 15,
                                        color: Color(0xFF91CDFF),
                                      ),
                                      SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          'الملفات',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontSize: 11,
                                            color: Color(0xFF91CDFF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: InkWell(
                                  onTap: onToggleSearch,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 7,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_rounded,
                                          size: 15,
                                          color: Color(0xFFC0C7D0),
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            'البحث',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                              fontSize: 11,
                                              color: Color(0xFFC0C7D0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'بحث في ملفات المشروع',
                        onPressed: onToggleSearch,
                        icon: const Icon(
                          Icons.manage_search_rounded,
                          color: Color(0xFF8A919A),
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_tree_rounded,
                        color: Color(0xFF91CDFF),
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'res://',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: Color(0xFFDEE2EC),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${data.fileTree.length} مجلد',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: Color(0xFF8A919A),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF252A32)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: data.fileTree
                        .map((node) => _FileTreeNodeTile(node: node))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171C23),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF252A32)),
            ),
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.manage_search_rounded,
                      size: 17,
                      color: Color(0xFF91CDFF),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'نتائج البحث السريع',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: Color(0xFFDEE2EC),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _WorkspaceChip(
                      label: searchOpen ? 'بحث' : '2 نتيجة',
                      color: const Color(0xFF91CDFF),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                _QuickSearchInput(controller: searchController),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    _SearchFilterChip(label: 'LSP Symbols', selected: true),
                    _SearchFilterChip(label: 'Full Text'),
                    _SearchFilterChip(label: 'References'),
                  ],
                ),
                const SizedBox(height: 8),
                const _SearchResultTile(
                  file: 'health_system.gd:18',
                  code: 'func take_damage(amount: int)',
                  isDefinition: true,
                ),
                const SizedBox(height: 5),
                const _SearchResultTile(
                  file: 'player.gd:84',
                  code: 'health_system.take_damage(20)',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchFilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _SearchFilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: selected ? const Color(0x1F91CDFF) : const Color(0xFF252A32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 9,
          color: selected ? const Color(0xFF91CDFF) : const Color(0xFFC0C7D0),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final String file;
  final String code;
  final bool isDefinition;

  const _SearchResultTile({
    required this.file,
    required this.code,
    this.isDefinition = false,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = isDefinition
        ? const Color(0xFF4AE183)
        : const Color(0xFFFFB783);
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2027),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            file,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              color: resultColor,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                color: Color(0xFFC0C7D0),
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceEditorPanel extends StatelessWidget {
  final WorkspaceDataModel data;
  final TextEditingController controller;
  final String activeTabId;
  final FocusNode focusNode;
  final ValueChanged<String> onSelectTab;

  const _WorkspaceEditorPanel({
    required this.data,
    required this.controller,
    required this.activeTabId,
    required this.focusNode,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final lineCount = controller.text.split('\n').length;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF090F15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252A32)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF171C23),
            padding: const EdgeInsetsDirectional.only(start: 8, end: 8, top: 6),
            child: Row(
              children: [
                Expanded(
                  child: _EditorTabBar(
                    tabs: data.openTabs,
                    activeTabId: activeTabId,
                    onSelectTab: onSelectTab,
                  ),
                ),
                const SizedBox(width: 8),
                const _WorkspaceChip(
                  label: '⚠ 1 تحذير  •  0 أخطاء',
                  color: Color(0xFFFFB783),
                ),
                IconButton(
                  tooltip: 'تقسيم المحرر',
                  onPressed: () {},
                  icon: const Icon(
                    Icons.vertical_split_rounded,
                    color: Color(0xFF8A919A),
                    size: 18,
                  ),
                ),
                IconButton(
                  tooltip: 'الخريطة المصغرة',
                  onPressed: () {},
                  icon: const Icon(
                    Icons.density_small_rounded,
                    color: Color(0xFF8A919A),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF252A32)),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 42,
                    color: const Color(0xFF090F15),
                    padding: const EdgeInsets.only(top: 15),
                    child: ListView.builder(
                      itemCount: lineCount < 24 ? 24 : lineCount,
                      itemBuilder: (context, index) => SizedBox(
                        height: 22.4,
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            color: Color(0xFF8A919A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: Color(0xFF252A32)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 12, 12, 8),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        maxLines: null,
                        expands: true,
                        scrollPadding: EdgeInsets.zero,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          height: 1.6,
                          color: Color(0xFFDEE2EC),
                        ),
                        cursorColor: const Color(0xFF91CDFF),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
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

class _WorkspaceInspectorPanel extends StatelessWidget {
  const _WorkspaceInspectorPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: _WorkspaceInfoCard(
            title: 'هيكل المستند (Symbols)',
            icon: Icons.schema_rounded,
            iconColor: const Color(0xFF91CDFF),
            trailing: 'GDScript LSP',
            child: const Column(
              children: [
                _SymbolRow(
                  icon: Icons.category_rounded,
                  label: 'PlayerController',
                  type: 'Class',
                  color: Color(0xFF91CDFF),
                  emphasized: true,
                ),
                _SymbolRow(
                  icon: Icons.tune_rounded,
                  label: '@export speed',
                  type: 'float',
                  color: Color(0xFFFFB783),
                  indented: true,
                ),
                _SymbolRow(
                  icon: Icons.tune_rounded,
                  label: '@export jump_impulse',
                  type: 'float',
                  color: Color(0xFFFFB783),
                  indented: true,
                ),
                _SymbolRow(
                  icon: Icons.sensors_rounded,
                  label: 'player_jumped',
                  type: 'Signal',
                  color: Color(0xFF4AE183),
                  indented: true,
                ),
                _SymbolRow(
                  icon: Icons.functions_rounded,
                  label: '_physics_process(delta)',
                  type: 'void',
                  color: Color(0xFF91CDFF),
                  indented: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 5,
          child: _WorkspaceInfoCard(
            title: 'العُقد والإشارات المرتبطة',
            icon: Icons.hub_rounded,
            iconColor: const Color(0xFFFFB783),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2027),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_tree_rounded,
                            color: Color(0xFF91CDFF),
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              r'$StateMachine',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: Color(0xFF91CDFF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'Node متصلة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: Color(0xFF4AE183),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      Text(
                        'مرتبطة بسكربت state_machine.gd وتدير انتقالات حالات اللاعب.',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: Color(0xFFC0C7D0),
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2027),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.cloud_done_rounded,
                            color: Color(0xFF4AE183),
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'المستودع المحلي',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: Color(0xFFC0C7D0),
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Text(
                            'Sync clean',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: Color(0xFF8A919A),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.save_outlined,
                            size: 15,
                            color: Color(0xFF91CDFF),
                          ),
                          label: const Text(
                            'حفظ التعديلات (Ctrl+S)',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 10,
                              color: Color(0xFFDEE2EC),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF252A32),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? trailing;
  final Widget child;

  const _WorkspaceInfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF171C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252A32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: Color(0xFFDEE2EC),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: Color(0xFF8A919A),
                    fontSize: 8,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

class _SymbolRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String type;
  final Color color;
  final bool emphasized;
  final bool indented;

  const _SymbolRow({
    required this.icon,
    required this.label,
    required this.type,
    required this.color,
    this.emphasized = false,
    this.indented = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: indented ? 13 : 0,
        top: 5,
        bottom: 5,
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                color: emphasized ? color : const Color(0xFFC0C7D0),
                fontSize: 9,
                fontWeight: emphasized ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: Color(0xFF8A919A),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceDockPanel extends StatelessWidget {
  const _WorkspaceDockPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252A32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            color: const Color(0xFF1B2027),
            child: Row(
              children: [
                const _DockTab(
                  icon: Icons.terminal_rounded,
                  label: 'مخرجات التشغيل Godot Output',
                  count: '3',
                  active: true,
                ),
                const SizedBox(width: 5),
                const _DockTab(
                  icon: Icons.warning_amber_rounded,
                  label: 'تشخيصات LSP',
                  count: '1',
                ),
                const SizedBox(width: 5),
                const _DockTab(
                  icon: Icons.code_rounded,
                  label: 'الطرفية المدمجة',
                ),
                const Spacer(),
                const Text(
                  'الاستجابة: 2ms  |  الذاكرة: 34MB',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: Color(0xFF4AE183),
                    fontSize: 9,
                  ),
                ),
                IconButton(
                  tooltip: 'مسح المخرجات',
                  onPressed: () {},
                  icon: const Icon(
                    Icons.block_rounded,
                    color: Color(0xFF8A919A),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF252A32)),
          const Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ConsoleLine(
                      time: '[14:48:12]',
                      tag: '[LSP Client]',
                      message:
                          'Initialized successfully with stdio connection.',
                      color: Color(0xFF91CDFF),
                    ),
                    _ConsoleLine(
                      time: '[14:48:13]',
                      tag: '[WorkspaceIndex]',
                      message:
                          'Indexed 14 GDScript files in 48ms. All symbols resolved.',
                      color: Color(0xFF4AE183),
                    ),
                    _ConsoleLine(
                      time: '[14:48:15]',
                      tag: '[Running]',
                      message:
                          'GDScriptEngine test: player.gd loaded without errors.',
                      color: Color(0xFF91CDFF),
                    ),
                    _ConsoleLine(
                      time: '[14:48:15]',
                      tag: '[LSP Warning]',
                      message:
                          "Line 12: Signal 'player_jumped' is never emitted.",
                      color: Color(0xFFFFB783),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? count;
  final bool active;

  const _DockTab({
    required this.icon,
    required this.label,
    this.count,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF252A32) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: active ? const Color(0xFF91CDFF) : const Color(0xFFC0C7D0),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 10,
              color: active ? const Color(0xFF91CDFF) : const Color(0xFFC0C7D0),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 5),
            Text(
              count!,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                color: Color(0xFFFFB783),
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConsoleLine extends StatelessWidget {
  final String time;
  final String tag;
  final String message;
  final Color color;

  const _ConsoleLine({
    required this.time,
    required this.tag,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: Color(0xFF8A919A),
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            tag,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                color: Color(0xFFC0C7D0),
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSearchInput extends StatelessWidget {
  final TextEditingController controller;

  const _QuickSearchInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2632),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF28323F)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          color: Color(0xFFE2E8F0),
        ),
        decoration: const InputDecoration(
          hintText: 'ابحث عن ملف أو سكربت...',
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
          prefixIcon: Icon(
            Icons.filter_list_rounded,
            size: 14,
            color: Color(0xFF94A3B8),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}

class _FileTreeNodeTile extends StatelessWidget {
  final ProjectFileNodeModel node;

  const _FileTreeNodeTile({required this.node});

  @override
  Widget build(BuildContext context) {
    if (node.isDirectory) {
      return Material(
        color: Colors.transparent,
        child: ExpansionTile(
          initiallyExpanded: node.isExpanded,
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(
            node.isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
            size: 16,
            color: const Color(0xFFF59E0B),
          ),
          title: Text(
            node.name,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.bold,
            ),
          ),
          children: node.children
              .map((child) => _FileTreeNodeTile(node: child))
              .toList(),
        ),
      );
    }

    IconData fileIcon = Icons.insert_drive_file_rounded;
    Color iconColor = const Color(0xFF94A3B8);

    if (node.type == FileType.gdscript) {
      fileIcon = Icons.code_rounded;
      iconColor = const Color(0xFF38BDF8);
    } else if (node.type == FileType.scene) {
      fileIcon = Icons.view_in_ar_rounded;
      iconColor = const Color(0xFF22C55E);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Icon(fileIcon, size: 15, color: iconColor),
          title: Text(
            node.name,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}

class _EditorTabBar extends StatelessWidget {
  final List<EditorTabModel> tabs;
  final String activeTabId;
  final ValueChanged<String> onSelectTab;

  const _EditorTabBar({
    required this.tabs,
    required this.activeTabId,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: const Color(0xFF131922),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = tab.fileId == activeTabId;

          return InkWell(
            onTap: () => onSelectTab(tab.fileId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF0A0D12)
                    : const Color(0xFF131922),
                border: Border(
                  top: BorderSide(
                    color: isActive
                        ? const Color(0xFF478CBF)
                        : Colors.transparent,
                    width: 2,
                  ),
                  left: const BorderSide(color: Color(0xFF1E2632), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    tab.type == FileType.gdscript
                        ? Icons.code_rounded
                        : Icons.view_in_ar_rounded,
                    size: 14,
                    color: isActive
                        ? const Color(0xFF478CBF)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tab.fileName,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  if (tab.isDirty) ...[
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFF38BDF8),
                    ),
                  ],
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WorkspaceStatusBar extends StatelessWidget {
  final int cursorLine;
  final int cursorCol;
  final bool lspOnline;

  const _WorkspaceStatusBar({
    required this.cursorLine,
    required this.cursorCol,
    required this.lspOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF090F15),
      child: Row(
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 14,
            color: lspOnline
                ? const Color(0xFF4AE183)
                : const Color(0xFFFFB783),
          ),
          const SizedBox(width: 6),
          Text(
            lspOnline
                ? 'GDScript 2.0 (Godot 4.3 Engine Bridge)'
                : 'GDScript 2.0 • المحرك غير متصل',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              color: lspOnline
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFFFFB783),
            ),
          ),
          const Spacer(),
          Text(
            'السطر $cursorLine، العمود $cursorCol',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'UTF-8 • Tab: 4 spaces • LF',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
