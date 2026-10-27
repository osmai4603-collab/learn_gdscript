// ==============================================================================
// أكاديمية جودو التعليمية — Godot Developer Academy (GDScript 2.0)
// الشاشة 6: محرر ومشاريع مساحة العمل والبحث الشامل (Workspace & Projects IDE)
// الملف: desktop_workspace_ide_screen.dart
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdscript_engine/gdscript_engine.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../widgets/code_editor/code_editor_widget.dart';
import '../../widgets/output_panel/error_display.dart';



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
  final bool isEngineReady;
  final List<ProjectFileNodeModel> fileTree;
  final List<EditorTabModel> openTabs;
  final String activeTabFileId;
  final String activeCodeContent;
  final int cursorLine;
  final int cursorColumn;
  final int diagnosticsCount;
  final List<Diagnostic> diagnostics;

  const WorkspaceDataModel({
    required this.projectName,
    required this.godotVersion,
    required this.isEngineReady,
    required this.fileTree,
    required this.openTabs,
    required this.activeTabFileId,
    required this.activeCodeContent,
    this.cursorLine = 18,
    this.cursorColumn = 4,
    this.diagnosticsCount = 0,
    this.diagnostics = const [],
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
}

// -----------------------------------------------------------------------------
// 2. الشاشة الرئيسية لمحرر ومساحة العمل (DesktopWorkspaceIdeScreen)
// -----------------------------------------------------------------------------

class DesktopWorkspaceIdeScreen extends StatefulWidget {
  final WorkspaceDataModel data;
  final CodeRunnerService? editorService;
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
    this.editorService,
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
  late FocusNode _editorFocusNode;
  final Map<String, TextSelection> _selectionsByFileId = {};
  final List<_ConsoleLine> _consoleLogs = [];
  late String _activeTabId;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late bool _isSearchOpen;
  final TextEditingController _findController = TextEditingController();
  CodeRunResult? _lastRunResult;
  bool _isRunning = false;
  double _dockHeight = 160;

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
    _editorFocusNode = FocusNode();
    final cursorLine = widget.initialCursorLine;
    if (cursorLine != null && cursorLine > 0) {
      final initialCode =
          widget.initialCode ??
          (widget.initialFilePath == null
              ? widget.data.activeCodeContent
              : widget.data.codeForFilePath(widget.initialFilePath!) ?? '');
      var cursorOffset = 0;
      for (var line = 1; line < cursorLine; line++) {
        final nextLine = initialCode.indexOf('\n', cursorOffset);
        if (nextLine == -1) {
          cursorOffset = initialCode.length;
          break;
        }
        cursorOffset = nextLine + 1;
      }
      _selectionsByFileId[_activeTabId] = TextSelection.collapsed(
        offset: cursorOffset.clamp(0, initialCode.length).toInt(),
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
    }
  }

  void _saveSelection(String fileId, TextSelection selection) {
    if (_selectionsByFileId[fileId] == selection) return;
    setState(() => _selectionsByFileId[fileId] = selection);
  }

  void _resizeDock(DragUpdateDetails details) {
    setState(() {
      _dockHeight = (_dockHeight - details.delta.dy)
          .clamp(100.0, 360.0)
          .toDouble();
    });
  }

  Widget _buildResizableDock(double panelHeight) {
    return SizedBox(
      height: panelHeight + 12,
      child: Column(
        children: [
          _DockResizeHandle(onVerticalDragUpdate: _resizeDock),
          Expanded(
            child: _WorkspaceDockPanel(
              data: widget.data,
              consoleLogs: _consoleLogs,
              lastResult: _lastRunResult,
              isRunning: _isRunning,
              onClearConsole: () => setState(_consoleLogs.clear),
            ),
          ),
        ],
      ),
    );
  }

  Future<CodeRunResult> _runCode(String code) async {
    final service = widget.editorService;
    if (service == null) {
      throw StateError('The code execution service is unavailable.');
    }
    if (mounted) {
      setState(() {
        _isRunning = true;
        _lastRunResult = null;
      });
    }
    try {
      final result = await service.runCode(code);
      if (mounted) {
        setState(() {
          _lastRunResult = result;
          _consoleLogs.addAll(result.output.map((line) => _ConsoleLine(line)));
          _consoleLogs.addAll(
            result.diagnostics.map(
              (diagnostic) => _ConsoleLine(
                diagnostic.format(includeSource: false),
                severity: diagnostic.severity,
              ),
            ),
          );
          if (result.errorMessage case final message?) {
            _consoleLogs.add(
              _ConsoleLine(
                'Error: $message',
                severity: DiagnosticSeverity.error,
              ),
            );
          }
        });
      }
      return result;
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _consoleLogs.add(
            _ConsoleLine(
              'Runtime Error: $error',
              severity: DiagnosticSeverity.error,
            ),
          );
        });
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  (int, int) _cursorPosition(String code, TextSelection? selection) {
    final offset = (selection?.extentOffset ?? 0).clamp(0, code.length).toInt();
    final beforeCursor = code.substring(0, offset);
    final line = '\n'.allMatches(beforeCursor).length + 1;
    final lastLineBreak = beforeCursor.lastIndexOf('\n');
    return (line, offset - lastLineBreak);
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.data.activeCodeContent;
    final selection = _selectionsByFileId.putIfAbsent(
      _activeTabId,
      () => TextSelection.collapsed(offset: code.length),
    );
    final cursor = _cursorPosition(code, selection);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _WorkspaceTopNav(
            isEngineReady: widget.data.isEngineReady,
            pulseAnimation: _pulseAnimation,
            onOpenSettings: widget.onOpenSettings,
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
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
                          context.l10n.workspaceTitle,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: Theme.of(context).colorScheme.outline,
                          size: 18,
                        ),
                        Icon(
                          Icons.folder_open_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                        Text(
                          widget.data.projectName,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                        ),
                        if (widget.data.godotVersion.isNotEmpty)
                          _WorkspaceChip(
                            label: widget.data.godotVersion,
                            color: Theme.of(context).colorScheme.primary,
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
                          text: context.l10n.workspaceIndexedFilesCount(
                            _countFiles(widget.data.fileTree),
                          ),
                          color: Theme.of(context).colorScheme.tertiary,
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
                      label: context.l10n.workspaceSettings,
                      onPressed: widget.onOpenSettings,
                    ),
                    _WorkspaceActionButton(
                      icon: Icons.sync_rounded,
                      label: context.l10n.workspaceReindex,
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
                    final maxDockHeight =
                        (constraints.maxHeight - 185 - 10 - 140 - 10 - 12)
                            .clamp(100.0, 360.0);
                    final dockHeight = _dockHeight
                        .clamp(100.0, maxDockHeight)
                        .toDouble();
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
                            editorService: widget.editorService,
                            onRunCode: widget.editorService == null
                                ? null
                                : _runCode,
                            initialSelection: selection,
                            onSelectionChanged: (selection) =>
                                _saveSelection(_activeTabId, selection),
                            initialCode: widget.data.activeCodeContent,
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
                        _buildResizableDock(dockHeight),
                      ],
                    );
                  }
                  final maxDockHeight = (constraints.maxHeight - 160 - 12 - 12)
                      .clamp(100.0, 360.0);
                  final dockHeight = _dockHeight
                      .clamp(100.0, maxDockHeight)
                      .toDouble();
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
                                editorService: widget.editorService,
                                onRunCode: widget.editorService == null
                                    ? null
                                    : _runCode,
                                initialSelection: selection,
                                onSelectionChanged: (selection) =>
                                    _saveSelection(_activeTabId, selection),
                                initialCode: widget.data.activeCodeContent,
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
                      _buildResizableDock(dockHeight),
                    ],
                  );
                },
              ),
            ),
          ),
          _WorkspaceStatusBar(
            cursorLine: cursor.$1,
            cursorCol: cursor.$2,
            engineReady: widget.data.isEngineReady,
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
  final bool isEngineReady;
  final Animation<double> pulseAnimation;
  final VoidCallback? onOpenSettings;

  const _WorkspaceTopNav({
    required this.isEngineReady,
    required this.pulseAnimation,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, _) {
              final statusColor = isEngineReady
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.secondary;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
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
                      isEngineReady
                          ? context.l10n.workspaceEngineReady
                          : context.l10n.workspaceEngineUnavailable,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
            tooltip: context.l10n.workspaceSettings,
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
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
      icon: Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_copy_outlined,
                                        size: 15,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          context.l10n.workspaceFilesTab,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontFamily:
                                                    'IBM Plex Sans Arabic',
                                                fontSize: 11,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
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
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            context.l10n.workspaceSearchTab,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontFamily:
                                                      'IBM Plex Sans Arabic',
                                                  fontSize: 11,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
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
                        tooltip: context.l10n.workspaceSearchProjectFiles,
                        onPressed: onToggleSearch,
                        icon: Icon(
                          Icons.manage_search_rounded,
                          color: Theme.of(context).colorScheme.outline,
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
                        Icon(
                          Icons.account_tree_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'res://',
                          style: CodeTextTheme.of(context).bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          context.l10n.workspaceFileCountSummary(_countFiles(data.fileTree)),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
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
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.manage_search_rounded,
                        size: 17,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          searchOpen
                            ? context.l10n.workspaceSearchFiles
                            : context.l10n.workspaceMatchingFiles,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      _WorkspaceChip(
                        label: '${matchingFiles.length}',
                        color: Theme.of(context).colorScheme.primary,
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
                        return Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.code_rounded,
                              size: 15,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              file.path,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              style: CodeTextTheme.of(context).bodyMedium
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 9,
                                  ),
                            ),
                            selected: file.path == activeFilePath,
                            onTap: () => onOpenFile?.call(file.path),
                          ),
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
  final CodeRunnerService? editorService;
  final Future<CodeRunResult> Function(String code)? onRunCode;
  final String initialCode;
  final TextSelection? initialSelection;
  final ValueChanged<TextSelection>? onSelectionChanged;
  final String activeTabId;
  final FocusNode focusNode;
  final ValueChanged<String> onSelectTab;
  final ValueChanged<String>? onCodeChanged;
  final Future<void> Function()? onSaveFile;
  final ValueChanged<String>? onCloseFile;

  const _WorkspaceEditorPanel({
    required this.data,
    required this.initialCode,
    required this.editorService,
    required this.onRunCode,
    required this.initialSelection,
    required this.onSelectionChanged,
    required this.activeTabId,
    required this.focusNode,
    required this.onSelectTab,
    this.onCodeChanged,
    this.onSaveFile,
    this.onCloseFile,
  });

  @override
  Widget build(BuildContext context) {
    final service = editorService;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                  tooltip: context.l10n.workspaceSaveFile,
                  onPressed:
                      data.openTabs.any(
                        (tab) => tab.fileId == activeTabId && tab.isDirty,
                      )
                      ? onSaveFile
                      : null,
                  icon: Icon(
                    Icons.save_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          Expanded(
            child: CodeEditorWidget(
              key: const ValueKey('workspace-code-editor'),
              documentId: activeTabId,
              initialCode: initialCode,
              initialSelection: initialSelection,
              focusNode: focusNode,
              expands: true,
              fontSize: 12,
              showActionBar: true,
              onChanged: onCodeChanged,
              onSelectionChanged: onSelectionChanged,
              onRunCode: onRunCode,
              showRunResults: false,
              onSave: onSaveFile,
              onCompletionItemsRequested: service == null
                  ? null
                  : (code, cursorOffset) async =>
                        service.getCompletionItems(code, cursorOffset),
              onSyntaxHighlightsRequested: service?.getSyntaxHighlights,
              onSemanticHighlightsRequested: service?.getSemanticHighlights,
              onDiagnosticsRequested: service?.getDiagnostics,
              onSignatureHelpRequested: service?.getSignatureHelp,
              onHoverInfoRequested: service?.getHoverInfo,
              onDefinitionRequested: service?.findDefinition,
              onMatchingBracketRequested: service?.findMatchingBracket,
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
      title: context.l10n.workspaceFileInfoTitle,
      icon: Icons.description_outlined,
      iconColor: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeTab.isEmpty
                ? context.l10n.workspaceNoFileOpen
                : activeTab.first.filePath,
            textDirection: TextDirection.ltr,
            style: CodeTextTheme.of(context).bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.workspaceFileLinesCount(code.split('\n').length),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.workspaceFileSizeCharacters(code.length),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
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
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: Theme.of(context).colorScheme.onSurface,
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

class _DockResizeHandle extends StatelessWidget {
  const _DockResizeHandle({required this.onVerticalDragUpdate});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: const ValueKey('workspace-dock-resize-handle'),
    behavior: HitTestBehavior.opaque,
    onVerticalDragUpdate: onVerticalDragUpdate,
    child: MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: SizedBox(
        height: 12,
        child: Center(
          child: Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ),
  );
}

class _WorkspaceDockPanel extends StatefulWidget {
  const _WorkspaceDockPanel({
    required this.data,
    required this.consoleLogs,
    required this.lastResult,
    required this.isRunning,
    required this.onClearConsole,
  });

  final WorkspaceDataModel data;
  final List<_ConsoleLine> consoleLogs;
  final CodeRunResult? lastResult;
  final bool isRunning;
  final VoidCallback onClearConsole;

  @override
  State<_WorkspaceDockPanel> createState() => _WorkspaceDockPanelState();
}

class _WorkspaceDockPanelState extends State<_WorkspaceDockPanel> {
  final ScrollController _consoleScrollController = ScrollController();
  var _selectedTab = 0;

  @override
  void didUpdateWidget(covariant _WorkspaceDockPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.consoleLogs.length != oldWidget.consoleLogs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _consoleScrollController.hasClients) {
          _consoleScrollController.animateTo(
            _consoleScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _consoleScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lastResult = widget.lastResult;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceContainerHigh),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
            color: colors.surfaceContainer,
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => setState(() => _selectedTab = 0),
                  child: _DockTab(
                    icon: Icons.terminal_rounded,
                    label: context.l10n.workspaceOutputTab,
                    count: '${widget.consoleLogs.length}',
                    active: _selectedTab == 0,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => setState(() => _selectedTab = 1),
                  child: _DockTab(
                    icon: Icons.warning_amber_rounded,
                    label: context.l10n.workspaceProblemsTab,
                    count: '${widget.data.diagnosticsCount}',
                    active: _selectedTab == 1,
                  ),
                ),
                const Spacer(),
                if (_selectedTab == 0 && widget.isRunning) ...[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (_selectedTab == 0 && lastResult != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (lastResult.isSuccess
                                  ? colors.tertiary
                                  : colors.error)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${lastResult.executionTimeMs} ms · '
                      '${lastResult.instructionsExecuted} ops',
                      style: CodeTextTheme.of(context).bodySmall.copyWith(
                        fontSize: 9,
                        color: lastResult.isSuccess
                            ? colors.tertiary
                            : colors.error,
                      ),
                    ),
                  ),
                if (_selectedTab == 0 && widget.consoleLogs.isNotEmpty)
                  IconButton(
                    tooltip: context.l10n.workspaceCopyOutput,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Clipboard.setData(
                      ClipboardData(
                        text: widget.consoleLogs
                            .map((line) => line.text)
                            .join('\n'),
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 15),
                  ),
                if (_selectedTab == 0 && widget.consoleLogs.isNotEmpty)
                  IconButton(
                    tooltip: context.l10n.workspaceClearOutput,
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onClearConsole,
                    icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  ),
                Text(
                  widget.data.isEngineReady
                      ? context.l10n.workspaceEngineStatusReady
                      : context.l10n.workspaceEngineStatusUnavailable,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: widget.data.isEngineReady
                        ? colors.tertiary
                        : colors.secondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          Divider(height: 1, color: colors.surfaceContainerHigh),
          Expanded(
            child: _selectedTab == 0
                ? _buildConsole(context)
                : _buildProblems(context),
          ),
        ],
      ),
    );
  }

  Widget _buildConsole(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (widget.consoleLogs.isEmpty) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isRunning ? Icons.sync_rounded : Icons.terminal_rounded,
              size: 16,
              color: widget.isRunning ? colors.primary : colors.outline,
            ),
            const SizedBox(width: 8),
            Text(
              widget.isRunning
                  ? context.l10n.workspaceExecutionRunning
                  : context.l10n.workspaceEmptyOutput,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'IBM Plex Sans Arabic',
                color: colors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _consoleScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: widget.consoleLogs.length,
      itemBuilder: (context, index) {
        final entry = widget.consoleLogs[index];
        final color = switch (entry.severity) {
          DiagnosticSeverity.error => colors.error,
          DiagnosticSeverity.warning => colors.secondary,
          DiagnosticSeverity.hint || DiagnosticSeverity.info => colors.primary,
          null => colors.onSurface,
        };
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SelectableText(
            entry.text,
            textDirection: TextDirection.ltr,
            style: CodeTextTheme.of(
              context,
            ).bodyMedium.copyWith(color: color, fontSize: 11),
          ),
        );
      },
    );
  }

  Widget _buildProblems(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (widget.data.diagnostics.isEmpty) {
      return Center(
        child: Text(
          context.l10n.workspaceNoProblems,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'IBM Plex Sans Arabic',
            color: colors.outline,
            fontSize: 11,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: widget.data.diagnostics.length,
      itemBuilder: (context, index) {
        final diagnostic = widget.data.diagnostics[index];
        final color = switch (diagnostic.severity) {
          DiagnosticSeverity.error => colors.error,
          DiagnosticSeverity.warning => colors.secondary,
          DiagnosticSeverity.hint || DiagnosticSeverity.info => colors.primary,
        };
        final icon = switch (diagnostic.severity) {
          DiagnosticSeverity.error => Icons.error_outline_rounded,
          DiagnosticSeverity.warning => Icons.warning_amber_rounded,
          DiagnosticSeverity.hint ||
          DiagnosticSeverity.info => Icons.info_outline_rounded,
        };
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnostic.message,
                      textDirection: TextDirection.ltr,
                      style: CodeTextTheme.of(
                        context,
                      ).bodyMedium.copyWith(color: color, fontSize: 10),
                    ),
                    Text(
                      'Ln ${diagnostic.location.line}, '
                      'Col ${diagnostic.location.column}',
                      textDirection: TextDirection.ltr,
                      style: CodeTextTheme.of(
                        context,
                      ).bodySmall.copyWith(color: colors.outline, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConsoleLine {
  const _ConsoleLine(this.text, {this.severity});

  final String text;
  final DiagnosticSeverity? severity;
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
        color: active
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 10,
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 5),
            Text(
              count!,
              style: CodeTextTheme.of(context).bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.secondary,
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: context.l10n.workspaceSearchFilterPlaceholder,
          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.filter_list_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            node.name,
            style: CodeTextTheme.of(context).bodyMedium.copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
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
    Color iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    if (node.type == FileType.gdscript) {
      fileIcon = Icons.code_rounded;
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (node.type == FileType.scene) {
      fileIcon = Icons.view_in_ar_rounded;
      iconColor = Theme.of(context).colorScheme.tertiary;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Icon(fileIcon, size: 15, color: iconColor),
          title: Text(
            node.name,
            style: CodeTextTheme.of(context).bodyMedium.copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          selected: node.path == activeFilePath,
          selectedTileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
      color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                    ? Theme.of(context).colorScheme.surfaceContainerLowest
                    : Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    width: 1,
                  ),
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tab.fileName,
                    style: CodeTextTheme.of(context).bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (tab.isDirty) ...[
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onCloseTab?.call(tab.filePath),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  final bool engineReady;

  const _WorkspaceStatusBar({
    required this.cursorLine,
    required this.cursorCol,
    required this.engineReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 14,
            color: engineReady
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            engineReady
                ? 'GDScript 2.0 • gdscript_engine'
                : context.l10n.workspaceEngineUnavailableNotice,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              color: engineReady
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Spacer(),
          Text(
            context.l10n.workspaceStatusBarCoordinates(cursorLine, cursorCol),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'UTF-8 • Tab: 4 spaces • LF',
              style: CodeTextTheme.of(context).bodyMedium.copyWith(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
