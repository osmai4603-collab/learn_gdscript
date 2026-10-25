// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 6: محرر ومشاريع مساحة العمل والبحث الشامل (Workspace & Projects IDE)
// الملف: desktop_workspace_ide_screen.dart
// ==============================================================================

import 'package:flutter/material.dart';

import '../../widgets/output_panel/error_display.dart';

String _localized(BuildContext context, String arabic, String english) =>
    Localizations.localeOf(context).languageCode == 'ar' ? arabic : english;

int _countFiles(List<ProjectFileNodeModel> nodes) {
  var total = 0;
  for (final node in nodes) {
    if (node.isDirectory) {
      total += _countFiles(node.children);
    } else {
      total++;
    }
  }
  return total;
}

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
  final int diagnosticsCount;
  final List<String> diagnosticMessages;

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
    this.diagnosticsCount = 0,
    this.diagnosticMessages = const [],
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
  final ValueChanged<String>? onOpenFile;
  final ValueChanged<String>? onSelectFile;
  final ValueChanged<String>? onCodeChanged;
  final Future<void> Function()? onSaveFile;
  final ValueChanged<String>? onCloseFile;
  final VoidCallback? onReindex;
  final VoidCallback? onOpenSettings;
  final Object? error;
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
    this.onOpenFile,
    this.onSelectFile,
    this.onCodeChanged,
    this.onSaveFile,
    this.onCloseFile,
    this.onReindex,
    this.onOpenSettings,
    this.error,
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
    _findController.addListener(_onSearchChanged);
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

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _findController.removeListener(_onSearchChanged);
    _codeEditorController.dispose();
    _editorFocusNode.dispose();
    _findController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DesktopWorkspaceIdeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.activeTabFileId != widget.data.activeTabFileId) {
      _activeTabId = widget.data.activeTabFileId;
      _codeEditorController.text = widget.data.activeCodeContent;
    }
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
            onOpenSettings: widget.onOpenSettings,
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
                        Text(
                          _localized(context, 'مساحة العمل', 'Workspace'),
                          style: const TextStyle(
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
                        if (widget.data.godotVersion.isNotEmpty)
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
                          icon: Icons.insert_drive_file_outlined,
                          text: _localized(
                            context,
                            '${_countFiles(widget.data.fileTree)} ملف مفهرس',
                            '${_countFiles(widget.data.fileTree)} indexed files',
                          ),
                          color: const Color(0xFF4AE183),
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
                      label: _localized(
                        context,
                        'إعداد مساحة العمل',
                        'Workspace settings',
                      ),
                      onPressed: widget.onOpenSettings,
                    ),
                    _WorkspaceActionButton(
                      icon: Icons.sync_rounded,
                      label: _localized(context, 'إعادة الفهرسة', 'Reindex'),
                      onPressed: widget.onReindex,
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
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ErrorDisplay(message: widget.error.toString()),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1000;
                  final explorerWidth = 255.0;
                  final inspectorWidth = 285.0;
                  if (compact) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 185,
                          child: _WorkspaceExplorerPanel(
                            data: widget.data,
                            searchOpen: _isSearchOpen,
                            searchController: _findController,
                            activeFilePath: widget.data.activeTabFileId,
                            onToggleSearch: () =>
                                setState(() => _isSearchOpen = !_isSearchOpen),
                            onOpenFile: widget.onOpenFile,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _WorkspaceEditorPanel(
                            data: widget.data,
                            controller: _codeEditorController,
                            activeTabId: _activeTabId,
                            focusNode: _editorFocusNode,
                            onSelectTab: (id) {
                              setState(() => _activeTabId = id);
                              widget.onSelectFile?.call(id);
                            },
                            onCodeChanged: widget.onCodeChanged,
                            onSaveFile: widget.onSaveFile,
                            onCloseFile: widget.onCloseFile,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 126,
                          child: _WorkspaceDockPanel(data: widget.data),
                        ),
                      ],
                    );
                  }
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
                                activeFilePath: widget.data.activeTabFileId,
                                onToggleSearch: () => setState(
                                  () => _isSearchOpen = !_isSearchOpen,
                                ),
                                onOpenFile: widget.onOpenFile,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _WorkspaceEditorPanel(
                                data: widget.data,
                                controller: _codeEditorController,
                                activeTabId: _activeTabId,
                                focusNode: _editorFocusNode,
                                onSelectTab: (id) {
                                  setState(() => _activeTabId = id);
                                  widget.onSelectFile?.call(id);
                                },
                                onCodeChanged: widget.onCodeChanged,
                                onSaveFile: widget.onSaveFile,
                                onCloseFile: widget.onCloseFile,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: inspectorWidth,
                              child: _WorkspaceInspectorPanel(
                                data: widget.data,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 178,
                        child: _WorkspaceDockPanel(data: widget.data),
                      ),
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
  final VoidCallback? onOpenSettings;

  const _WorkspaceTopNav({
    required this.isLspOnline,
    required this.pulseAnimation,
    this.onOpenSettings,
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
                          ? _localized(
                              context,
                              'خادم GDScript: متصل',
                              'GDScript server: connected',
                            )
                          : _localized(
                              context,
                              'خادم GDScript: غير متصل',
                              'GDScript server: disconnected',
                            ),
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
          IconButton(
            tooltip: _localized(
              context,
              'إعدادات مساحة العمل',
              'Workspace settings',
            ),
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
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
  final VoidCallback? onPressed;

  const _WorkspaceActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
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
  final String activeFilePath;
  final ValueChanged<String>? onOpenFile;

  const _WorkspaceExplorerPanel({
    required this.data,
    required this.searchOpen,
    required this.searchController,
    required this.activeFilePath,
    required this.onToggleSearch,
    this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final matchingFiles = _collectFileNodes(data.fileTree)
        .where(
          (file) =>
              query.isEmpty ||
              file.name.toLowerCase().contains(query) ||
              file.path.toLowerCase().contains(query),
        )
        .toList(growable: false);
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
                                  child: Row(
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
                                          _localized(
                                            context,
                                            'الملفات',
                                            'Files',
                                          ),
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
                                    child: Row(
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
                                            _localized(
                                              context,
                                              'البحث',
                                              'Search',
                                            ),
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
                        tooltip: _localized(
                          context,
                          'بحث في ملفات المشروع',
                          'Search project files',
                        ),
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
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Padding(
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
                          '${_countFiles(data.fileTree)} ${_localized(context, 'ملف', 'files')}',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: Color(0xFF8A919A),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF252A32)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: data.fileTree
                        .map(
                          (node) => _FileTreeNodeTile(
                            node: node,
                            activeFilePath: activeFilePath,
                            onOpenFile: onOpenFile,
                          ),
                        )
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
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.manage_search_rounded,
                        size: 17,
                        color: Color(0xFF91CDFF),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _localized(
                            context,
                            searchOpen
                                ? 'البحث في الملفات'
                                : 'الملفات المطابقة',
                            searchOpen ? 'Search files' : 'Matching files',
                          ),
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: Color(0xFFDEE2EC),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _WorkspaceChip(
                        label: '${matchingFiles.length}',
                        color: const Color(0xFF91CDFF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  _QuickSearchInput(controller: searchController),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: matchingFiles.length,
                      itemBuilder: (context, index) {
                        final file = matchingFiles[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.code_rounded,
                            size: 15,
                            color: Color(0xFF38BDF8),
                          ),
                          title: Text(
                            file.path,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: Color(0xFFC0C7D0),
                              fontSize: 9,
                            ),
                          ),
                          selected: file.path == activeFilePath,
                          onTap: () => onOpenFile?.call(file.path),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<ProjectFileNodeModel> _collectFileNodes(
    List<ProjectFileNodeModel> nodes,
  ) => [
    for (final node in nodes)
      if (node.isDirectory) ..._collectFileNodes(node.children) else node,
  ];
}

class _WorkspaceEditorPanel extends StatelessWidget {
  final WorkspaceDataModel data;
  final TextEditingController controller;
  final String activeTabId;
  final FocusNode focusNode;
  final ValueChanged<String> onSelectTab;
  final ValueChanged<String>? onCodeChanged;
  final Future<void> Function()? onSaveFile;
  final ValueChanged<String>? onCloseFile;

  const _WorkspaceEditorPanel({
    required this.data,
    required this.controller,
    required this.activeTabId,
    required this.focusNode,
    required this.onSelectTab,
    this.onCodeChanged,
    this.onSaveFile,
    this.onCloseFile,
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
                    onCloseTab: onCloseFile,
                  ),
                ),
                IconButton(
                  tooltip: _localized(context, 'حفظ الملف', 'Save file'),
                  onPressed:
                      data.openTabs.any(
                        (tab) => tab.fileId == activeTabId && tab.isDirty,
                      )
                      ? onSaveFile
                      : null,
                  icon: const Icon(
                    Icons.save_outlined,
                    color: Color(0xFF91CDFF),
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
                      itemBuilder: (context, index) {
                        return SizedBox(
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
                        );
                      },
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
                        onChanged: onCodeChanged,
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
  const _WorkspaceInspectorPanel({required this.data});

  final WorkspaceDataModel data;

  @override
  Widget build(BuildContext context) {
    final activeTab = data.openTabs.where(
      (tab) => tab.fileId == data.activeTabFileId,
    );
    final code = data.activeCodeContent;
    return _WorkspaceInfoCard(
      title: _localized(context, 'معلومات الملف', 'File information'),
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF91CDFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeTab.isEmpty
                ? _localized(context, 'لا يوجد ملف مفتوح', 'No file is open')
                : activeTab.first.filePath,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: Color(0xFF91CDFF),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _localized(
              context,
              'الأسطر: ${code.split('\n').length}',
              'Lines: ${code.split('\n').length}',
            ),
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              color: Color(0xFFC0C7D0),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _localized(
              context,
              'الحجم: ${code.length} محرف',
              'Size: ${code.length} characters',
            ),
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              color: Color(0xFFC0C7D0),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _WorkspaceInfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
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
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

class _WorkspaceDockPanel extends StatelessWidget {
  const _WorkspaceDockPanel({required this.data});

  final WorkspaceDataModel data;

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
                _DockTab(
                  icon: Icons.warning_amber_rounded,
                  label: _localized(context, 'تشخيصات LSP', 'LSP diagnostics'),
                  count: '${data.diagnosticsCount}',
                  active: true,
                ),
                const Spacer(),
                Text(
                  _localized(
                    context,
                    data.isLspConnected ? 'متصل' : 'غير متصل',
                    data.isLspConnected ? 'Connected' : 'Disconnected',
                  ),
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: data.isLspConnected
                        ? const Color(0xFF4AE183)
                        : const Color(0xFFFFB783),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF252A32)),
          Expanded(
            child: data.diagnosticMessages.isEmpty
                ? Center(
                    child: Text(
                      _localized(
                        context,
                        'لا توجد تشخيصات للمستندات المفهرسة.',
                        'No diagnostics for indexed documents.',
                      ),
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: Color(0xFF8A919A),
                        fontSize: 11,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    itemCount: data.diagnosticMessages.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        data.diagnosticMessages[index],
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: Color(0xFFFFB783),
                          fontSize: 10,
                        ),
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
        decoration: InputDecoration(
          hintText: _localized(
            context,
            'ابحث عن ملف أو سكربت...',
            'Search files or scripts...',
          ),
          hintStyle: const TextStyle(
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
  final String activeFilePath;
  final ValueChanged<String>? onOpenFile;

  const _FileTreeNodeTile({
    required this.node,
    required this.activeFilePath,
    required this.onOpenFile,
  });

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
              .map(
                (child) => _FileTreeNodeTile(
                  node: child,
                  activeFilePath: activeFilePath,
                  onOpenFile: onOpenFile,
                ),
              )
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
          selected: node.path == activeFilePath,
          selectedTileColor: const Color(0xFF1E2837),
          onTap: () => onOpenFile?.call(node.path),
        ),
      ),
    );
  }
}

class _EditorTabBar extends StatelessWidget {
  final List<EditorTabModel> tabs;
  final String activeTabId;
  final ValueChanged<String> onSelectTab;
  final ValueChanged<String>? onCloseTab;

  const _EditorTabBar({
    required this.tabs,
    required this.activeTabId,
    required this.onSelectTab,
    this.onCloseTab,
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
                  InkWell(
                    onTap: () => onCloseTab?.call(tab.filePath),
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
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
                ? 'GDScript 2.0 • LSP'
                : _localized(
                    context,
                    'GDScript 2.0 • خادم اللغة غير متصل',
                    'GDScript 2.0 • language server offline',
                  ),
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
            _localized(
              context,
              'السطر $cursorLine، العمود $cursorCol',
              'Line $cursorLine, column $cursorCol',
            ),
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 14),
          const Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'UTF-8 • Tab: 4 spaces • LF',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
