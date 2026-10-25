import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/repositories/workspace_repository.dart';
import '../../../logic/providers/language_server_provider.dart';
import '../../widgets/common/loading_indicator.dart';
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
  final TextEditingController _executableController = TextEditingController();
  final Map<String, String> _drafts = {};
  final Map<String, String> _savedContents = {};
  final List<String> _openFilePaths = [];
  String? _activeFilePath;
  Object? _error;
  List<WorkspaceFileSnapshot> _files = const [];
  bool _loadingWorkspace = true;
  bool _loadedSavedPath = false;
  String? _loadedRootPath;
  Timer? _documentSyncTimer;
  final Map<String, String> _pendingDocumentChanges = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedSavedPath) return;
    _loadedSavedPath = true;
    unawaited(_loadSavedWorkspace());
  }

  Future<void> _loadSavedWorkspace() async {
    try {
      final server = context.read<LanguageServerProvider>();
      await server.loadSavedWorkspace();
      if (!mounted) return;
      _rootPathController.text = server.rootPath ?? '';
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
      final currentRoot = context.read<LanguageServerProvider>().rootPath;
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
          _pendingDocumentChanges.clear();
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

  Future<void> _toggleConnection() async {
    final server = context.read<LanguageServerProvider>();
    setState(() => _error = null);
    try {
      if (server.isConnected) {
        await _flushPendingDocumentChanges(rethrowErrors: true);
        await server.disconnect();
      } else {
        await server.connect(
          _rootPathController.text.trim(),
          executablePath: _executableController.text.trim().isEmpty
              ? null
              : _executableController.text.trim(),
        );
      }
      if (!mounted) return;
      await _loadFiles();
      if (server.isConnected) {
        for (final path in List<String>.of(_openFilePaths)) {
          final file = _fileForPath(path);
          if (file != null) {
            await server.openWorkspaceDocument(
              Uri.parse(file.uri),
              _drafts[path] ?? file.content,
            );
          }
        }
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
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
    try {
      await context.read<LanguageServerProvider>().openWorkspaceDocument(
        Uri.parse(file.uri),
        _drafts[path] ?? file.content,
      );
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  void _onCodeChanged(String code) {
    final path = _activeFilePath;
    final file = path == null ? null : _fileForPath(path);
    if (path == null || file == null) return;
    final baseline = _savedContents[path] ?? file.content;
    setState(() {
      if (code == baseline) {
        _drafts.remove(path);
        _pendingDocumentChanges.remove(path);
      } else {
        _drafts[path] = code;
        _pendingDocumentChanges[path] = code;
      }
    });
    _documentSyncTimer?.cancel();
    _documentSyncTimer = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(_flushPendingDocumentChanges()),
    );
  }

  Future<void> _flushPendingDocumentChanges({
    bool rethrowErrors = false,
  }) async {
    if (!mounted) return;
    _documentSyncTimer?.cancel();
    _documentSyncTimer = null;
    final server = context.read<LanguageServerProvider>();
    for (final entry in Map<String, String>.of(
      _pendingDocumentChanges,
    ).entries) {
      final file = _fileForPath(entry.key);
      if (file == null || !server.isConnected) continue;
      try {
        await server.changeWorkspaceDocument(Uri.parse(file.uri), entry.value);
        if (_pendingDocumentChanges[entry.key] == entry.value) {
          _pendingDocumentChanges.remove(entry.key);
        }
      } on Object catch (error) {
        if (mounted) setState(() => _error = error);
        if (rethrowErrors) rethrow;
      }
    }
  }

  Future<void> _saveActiveFile() async {
    final path = _activeFilePath;
    final file = path == null ? null : _fileForPath(path);
    if (path == null || file == null) return;
    try {
      await _flushPendingDocumentChanges(rethrowErrors: true);
      final content = _drafts[path] ?? file.content;
      setState(() => _error = null);
      await widget.repository.saveGDScriptFile(file.uri, content);
      await context.read<LanguageServerProvider>().saveWorkspaceDocument(
        Uri.parse(file.uri),
        content,
      );
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
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'هناك تعديلات غير محفوظة. هل تريد إغلاق الملف والتخلص منها؟'
                : 'This file has unsaved changes. Close it and discard them?',
          ),
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
      await _flushPendingDocumentChanges(rethrowErrors: true);
      await context.read<LanguageServerProvider>().closeWorkspaceDocument(
        Uri.parse(file.uri),
      );
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
        _pendingDocumentChanges.remove(path);
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
      await context.read<LanguageServerProvider>().synchronizeWorkspace();
      await _loadFiles();
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

  WorkspaceDataModel _buildData(LanguageServerProvider server) {
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
    final rootPath = server.rootPath ?? '';
    final projectName = rootPath
        .replaceAll(RegExp(r'[/\\]+$'), '')
        .split(RegExp(r'[/\\]'))
        .last;
    final diagnostics = server.diagnosticsByUri.entries
        .where((entry) => _files.any((file) => file.uri == entry.key))
        .expand((entry) => entry.value)
        .map((diagnostic) => diagnostic['message'])
        .whereType<String>()
        .toList(growable: false);
    return WorkspaceDataModel(
      projectName: projectName.isEmpty
          ? context.l10n.workspaceTitle
          : projectName,
      godotVersion: '',
      isLspConnected: server.isConnected,
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
      diagnosticMessages: diagnostics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final server = context.watch<LanguageServerProvider>();
    if (_loadingWorkspace || server.isConnecting) {
      return const _WorkspaceLoadingSkeleton();
    }
    if (server.isConnected) {
      final data = _buildData(server);
      return DesktopWorkspaceIdeScreen(
        data: data,
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
          TextField(
            controller: _executableController,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: l10n.lspExecutablePath,
              prefixIcon: const Icon(Icons.terminal),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: server.isConnecting ? null : _toggleConnection,
            icon: Icon(server.isConnected ? Icons.link_off : Icons.link),
            label: Text(
              server.isConnected ? l10n.disconnectLsp : l10n.connectLsp,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                server.isConnected ? Icons.check_circle : Icons.circle_outlined,
                color: server.isConnected
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.outline,
              ),
              title: Text(l10n.lspStatus),
              subtitle: Text(
                server.isConnecting
                    ? l10n.loading
                    : server.isConnected
                    ? l10n.lspConnected
                    : l10n.lspDisconnected,
              ),
            ),
          ),
          if (_error != null || server.lastError != null) ...[
            const SizedBox(height: 12),
            ErrorDisplay(
              message:
                  '${l10n.lspConnectionError} ${_error ?? server.lastError}',
            ),
          ],
          if (server.isConnecting) ...[
            const SizedBox(height: 12),
            const LoadingIndicator(),
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
              const SizedBox(height: 12),
              TextField(
                controller: _executableController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: context.l10n.lspExecutablePath,
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
              await _toggleConnection();
            },
            child: Text(
              context.read<LanguageServerProvider>().isConnected
                  ? context.l10n.disconnectLsp
                  : context.l10n.connectLsp,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _documentSyncTimer?.cancel();
    _rootPathController.dispose();
    _executableController.dispose();
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
        baseColor: scheme.surfaceContainerHigh,
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
                              _SkeletonBlock(height: 180),
                              SizedBox(height: 12),
                              _SkeletonBlock(height: 220),
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
