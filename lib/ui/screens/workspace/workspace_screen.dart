import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gdscript_engine/gdscript_engine.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/repositories/workspace_repository.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../widgets/output_panel/error_display.dart';
import 'workspace_projects_ide_flutter_dart.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key, required this.repository});

  final WorkspaceRepository repository;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final TextEditingController _rootPathController = TextEditingController();
  final Map<String, String> _drafts = {};
  final Map<String, String> _savedContents = {};
  final List<String> _openFilePaths = [];
  String? _activeFilePath;
  Object? _error;
  List<WorkspaceFileSnapshot> _files = const [];
  bool _loadingWorkspace = true;
  bool _loadedSavedPath = false;
  String? _loadedRootPath;
  String? _rootPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedSavedPath) return;
    _loadedSavedPath = true;
    unawaited(_loadSavedWorkspace());
  }

  Future<void> _loadSavedWorkspace() async {
    try {
      _rootPath = await widget.repository.getRootPath();
      if (!mounted) return;
      _loadedRootPath = _rootPath;
      _rootPathController.text = _rootPath ?? '';
      await _loadFiles();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loadingWorkspace = false;
      });
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _loadingWorkspace = true;
      _error = null;
    });
    try {
      final currentRoot = await widget.repository.getRootPath();
      final files = await widget.repository.loadFiles();
      if (!mounted) return;
      setState(() {
        if (currentRoot != null &&
            _loadedRootPath != null &&
            currentRoot != _loadedRootPath) {
          _drafts.clear();
          _savedContents.clear();
          _openFilePaths.clear();
          _activeFilePath = null;
        }
        _loadedRootPath = currentRoot ?? _loadedRootPath;
        _files = files;
        for (final file in files) {
          final path = _displayPath(file);
          if (!_drafts.containsKey(path) || !_savedContents.containsKey(path)) {
            _savedContents[path] = file.content;
          }
        }
        _openFilePaths.removeWhere(
          (path) => !_files.any((file) => _displayPath(file) == path),
        );
        if (_activeFilePath != null &&
            !_files.any((file) => _displayPath(file) == _activeFilePath)) {
          _activeFilePath = _openFilePaths.isEmpty ? null : _openFilePaths.last;
        }
        _loadingWorkspace = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loadingWorkspace = false;
      });
    }
  }

  Future<void> _openWorkspace() async {
    setState(() {
      _error = null;
      _loadingWorkspace = true;
    });
    try {
      final files = await widget.repository.discoverAndSetWorkspace(
        _rootPathController.text.trim(),
      );
      final rootPath = await widget.repository.getRootPath();
      if (!mounted) return;
      setState(() {
        _rootPath = rootPath;
        _files = files;
        _loadedRootPath = _rootPath;
        _drafts.clear();
        _savedContents
          ..clear()
          ..addEntries(
            files.map((file) => MapEntry(_displayPath(file), file.content)),
          );
        _openFilePaths.clear();
        _activeFilePath = null;
        _loadingWorkspace = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loadingWorkspace = false;
        });
      }
    }
  }

  Future<void> _openFile(String path) async {
    final file = _fileForPath(path);
    if (file == null) return;
    setState(() {
      if (!_openFilePaths.contains(path)) _openFilePaths.add(path);
      _activeFilePath = path;
      _error = null;
    });
  }

  void _onCodeChanged(String code) {
    final path = _activeFilePath;
    final file = path == null ? null : _fileForPath(path);
    if (path == null || file == null) return;
    setState(() {
      if (code == (_savedContents[path] ?? file.content)) {
        _drafts.remove(path);
      } else {
        _drafts[path] = code;
      }
    });
  }

  Future<void> _saveActiveFile() async {
    final path = _activeFilePath;
    final file = path == null ? null : _fileForPath(path);
    if (path == null || file == null) return;
    try {
      final content = _drafts[path] ?? file.content;
      setState(() => _error = null);
      await widget.repository.saveGDScriptFile(file.uri, content);
      if (!mounted) return;
      setState(() {
        _drafts.remove(path);
        _savedContents[path] = content;
        _files = [
          for (final current in _files)
            if (current.uri == file.uri)
              WorkspaceFileSnapshot(
                uri: current.uri,
                relativePath: current.relativePath,
                content: content,
                modifiedMillis: DateTime.now().millisecondsSinceEpoch,
              )
            else
              current,
        ];
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _closeTab(String path) async {
    final file = _fileForPath(path);
    if (file == null) return;
    final isDirty =
        (_drafts[path] ?? file.content) !=
        (_savedContents[path] ?? file.content);
    if (isDirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.workspaceTitle),
          content: Text(context.l10n.workspaceUnsavedChangesWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    try {
      final refreshedFiles = await widget.repository.loadFiles();
      if (!mounted) return;
      setState(() {
        _files = refreshedFiles;
        final refreshedFile = _fileForPath(path);
        if (refreshedFile != null) {
          _savedContents[path] = refreshedFile.content;
        }
        _openFilePaths.remove(path);
        _drafts.remove(path);
        if (_activeFilePath == path) {
          _activeFilePath = _openFilePaths.isEmpty ? null : _openFilePaths.last;
        }
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _synchronizeWorkspace() async {
    setState(() {
      _error = null;
      _loadingWorkspace = true;
    });
    try {
      final rootPath = _rootPath;
      if (rootPath == null) throw StateError('No workspace is selected.');
      final files = await widget.repository.discoverAndSetWorkspace(rootPath);
      if (!mounted) return;
      setState(() {
        _files = files;
        for (final file in files) {
          _savedContents[_displayPath(file)] = file.content;
        }
        _savedContents.removeWhere(
          (path, _) => !files.any((file) => _displayPath(file) == path),
        );
        _drafts.removeWhere(
          (path, _) => !files.any((file) => _displayPath(file) == path),
        );
      });
      _openFilePaths.removeWhere((path) => _fileForPath(path) == null);
      if (_activeFilePath != null && _fileForPath(_activeFilePath!) == null) {
        _activeFilePath = null;
      }
      setState(() => _loadingWorkspace = false);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loadingWorkspace = false;
        });
      }
    }
  }

  String _displayPath(WorkspaceFileSnapshot file) =>
      'res://${file.relativePath.replaceAll(r'\', '/')}';

  WorkspaceFileSnapshot? _fileForPath(String path) {
    for (final file in _files) {
      if (_displayPath(file) == path) return file;
    }
    return null;
  }

  WorkspaceDataModel _buildData({required CodeRunnerService? codeRunner}) {
    final root = _MutableWorkspaceNode('res://', 'res://');
    for (final file in _files) {
      final segments = file.relativePath.split('/');
      var node = root;
      for (var index = 0; index < segments.length; index++) {
        final segment = segments[index];
        final path = 'res://${segments.take(index + 1).join('/')}';
        final child = node.children.putIfAbsent(
          segment,
          () => _MutableWorkspaceNode(segment, path),
        );
        if (index == segments.length - 1) child.file = file;
        node = child;
      }
    }

    ProjectFileNodeModel toModel(_MutableWorkspaceNode node) {
      final file = node.file;
      final children = node.children.values.toList()
        ..sort((a, b) {
          if (a.file == null && b.file != null) return -1;
          if (a.file != null && b.file == null) return 1;
          return a.name.compareTo(b.name);
        });
      return ProjectFileNodeModel(
        id: file?.uri ?? node.path,
        name: node.name,
        path: node.path,
        type: file == null ? FileType.asset : FileType.gdscript,
        isDirectory: file == null,
        isExpanded: true,
        children: children.map(toModel).toList(growable: false),
        content: file?.content ?? '',
      );
    }

    final openFiles = _openFilePaths
        .map(_fileForPath)
        .whereType<WorkspaceFileSnapshot>()
        .toList(growable: false);
    final activeFile = _activeFilePath == null
        ? null
        : _fileForPath(_activeFilePath!);
    final rootPath = _rootPath ?? '';
    final projectName = rootPath
        .replaceAll(RegExp(r'[/\\]+$'), '')
        .split(RegExp(r'[/\\]'))
        .last;
    final diagnostics = activeFile == null
        ? const <Diagnostic>[]
        : codeRunner!.getDiagnostics(
            _drafts[_activeFilePath] ?? activeFile.content,
          );
    return WorkspaceDataModel(
      projectName: projectName.isEmpty
          ? context.l10n.workspaceTitle
          : projectName,
      godotVersion: '',
      isEngineReady: true,
      fileTree: root.children.values.map(toModel).toList(growable: false),
      openTabs: [
        for (final file in openFiles)
          EditorTabModel(
            fileId: _displayPath(file),
            fileName: file.relativePath.split('/').last,
            filePath: _displayPath(file),
            isDirty:
                (_drafts[_displayPath(file)] ?? file.content) !=
                (_savedContents[_displayPath(file)] ?? file.content),
            type: FileType.gdscript,
          ),
      ],
      activeTabFileId: _activeFilePath ?? '',
      activeCodeContent: activeFile == null
          ? ''
          : _drafts[_activeFilePath] ?? activeFile.content,
      cursorLine: 1,
      cursorColumn: 1,
      diagnosticsCount: diagnostics.length,
      diagnostics: diagnostics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loadingWorkspace) {
      return const _WorkspaceLoadingSkeleton();
    }
    if (_rootPath != null) {
      final editorService = _activeFilePath == null
          ? null
          : context.read<CodeRunnerService>();
      final data = _buildData(codeRunner: editorService);
      return DesktopWorkspaceIdeScreen(
        data: data,
        editorService: editorService,
        initialFilePath: _activeFilePath,
        onOpenFile: _openFile,
        onSelectFile: (path) => setState(() => _activeFilePath = path),
        onCodeChanged: _onCodeChanged,
        onSaveFile: _saveActiveFile,
        onCloseFile: _closeTab,
        onReindex: _synchronizeWorkspace,
        onOpenSettings: _showConnectionSettings,
        error: _error,
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workspaceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.workspaceDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _rootPathController,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: l10n.workspacePath,
              prefixIcon: const Icon(Icons.folder_open),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _openWorkspace,
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.openWorkspace),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('gdscript_engine'),
              subtitle: Text(l10n.workspaceDirectInspectAction),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorDisplay(message: '${l10n.lessonUnavailable} $_error'),
          ],
        ],
      ),
    );
  }

  Future<void> _showConnectionSettings() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.workspaceTitle),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _rootPathController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: context.l10n.workspacePath,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openWorkspace();
            },
            child: Text(context.l10n.openWorkspace),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rootPathController.dispose();
    super.dispose();
  }
}

class _MutableWorkspaceNode {
  _MutableWorkspaceNode(this.name, this.path);

  final String name;
  final String path;
  final Map<String, _MutableWorkspaceNode> children = {};
  WorkspaceFileSnapshot? file;
}

class _WorkspaceLoadingSkeleton extends StatelessWidget {
  const _WorkspaceLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: scheme.surfaceContainer,
        highlightColor: scheme.surfaceContainerHighest,
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SkeletonBlock(height: 48),
              const SizedBox(height: 16),
              const _SkeletonBlock(height: 72),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 760) {
                      return Column(
                        children: [
                          const _SkeletonBlock(height: 128),
                          const SizedBox(height: 12),
                          const Expanded(child: _SkeletonBlock(height: 300)),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        const SizedBox(
                          width: 240,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 180,
                                child: _SkeletonBlock(height: 180),
                              ),
                              SizedBox(height: 12),
                              Expanded(
                                flex: 220,
                                child: _SkeletonBlock(height: 220),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: _SkeletonBlock(height: 420)),
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 250,
                          child: _SkeletonBlock(height: 420),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const _SkeletonBlock(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
