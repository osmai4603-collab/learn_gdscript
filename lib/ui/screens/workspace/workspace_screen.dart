import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/providers/language_server_provider.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/output_panel/error_display.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final TextEditingController _rootPathController = TextEditingController();
  final TextEditingController _executableController = TextEditingController();
  Object? _error;
  bool _loadedSavedPath = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedSavedPath) return;
    _loadedSavedPath = true;
    _loadSavedPath();
  }

  Future<void> _loadSavedPath() async {
    try {
      await context.read<LanguageServerProvider>().loadSavedWorkspace();
      if (!mounted) return;
      _rootPathController.text =
          context.read<LanguageServerProvider>().rootPath ?? '';
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _toggleConnection() async {
    final server = context.read<LanguageServerProvider>();
    setState(() => _error = null);
    try {
      if (server.isConnected) {
        await server.disconnect();
      } else {
        await server.connect(
          _rootPathController.text.trim(),
          executablePath: _executableController.text.trim().isEmpty
              ? null
              : _executableController.text.trim(),
        );
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final server = context.watch<LanguageServerProvider>();
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
            icon: server.isConnecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    server.isConnected
                        ? Icons.link_off
                        : Icons.link,
                  ),
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
          if (server.isConnected) ...[
            const SizedBox(height: 8),
            Text(server.rootPath ?? ''),
            Text(l10n.indexedFiles(server.indexedFileCount)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.workspaceSearch),
              icon: const Icon(Icons.search),
              label: Text(l10n.workspaceSearchTitle),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorDisplay(
              message: '${l10n.lspConnectionError} $_error',
            ),
          ],
          if (server.lastError != null && _error == null) ...[
            const SizedBox(height: 12),
            ErrorDisplay(message: server.lastError.toString()),
          ],
          if (server.isConnecting) ...[
            const SizedBox(height: 12),
            const LoadingIndicator(),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rootPathController.dispose();
    _executableController.dispose();
    super.dispose();
  }
}
