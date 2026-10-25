import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/repositories/workspace_repository.dart';
import '../../../logic/services/code_runner_service.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/navigation_bar.dart';

class EngineDiagnosticsScreen extends StatefulWidget {
  const EngineDiagnosticsScreen({super.key, required this.repository});

  final WorkspaceRepository repository;

  @override
  State<EngineDiagnosticsScreen> createState() =>
      _EngineDiagnosticsScreenState();
}

class _EngineDiagnosticsScreenState extends State<EngineDiagnosticsScreen> {
  late Future<List<_EngineIssue>> _issues;

  @override
  void initState() {
    super.initState();
    _issues = _loadIssues();
  }

  Future<List<_EngineIssue>> _loadIssues() async {
    final engine = context.read<CodeRunnerService>();
    final files = await widget.repository.loadFiles();
    return [
      for (final file in files)
        for (final diagnostic in engine.getDiagnostics(file.content))
          _EngineIssue(
            file: file.relativePath,
            line: diagnostic.location.line,
            column: diagnostic.location.column,
            code: diagnostic.code,
            message: diagnostic.message,
            isError: diagnostic.severity.name == 'error',
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.engineDiagnosticsTitle),
        leading: IconButton(
          tooltip: l10n.settingsTitle,
          onPressed: () => context.go(AppRoutes.settings),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<List<_EngineIssue>>(
        future: _issues,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  '${l10n.lessonUnavailable} ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final issues = snapshot.data!;
          if (issues.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.engineDiagnosticsEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.engineDiagnosticsSummary(issues.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              for (final issue in issues)
                Card(
                  child: ListTile(
                    leading: Icon(
                      issue.isError
                          ? Icons.error_outline
                          : Icons.warning_amber_outlined,
                      color: issue.isError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.tertiary,
                    ),
                    title: Text(issue.message),
                    subtitle: Text(
                      '${issue.file}:${issue.line}:${issue.column}'
                      '${issue.code == null ? '' : ' · ${issue.code}'}',
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: context.isWideLayout
          ? null
          : AppNavigationBar(
              selectedRoute: AppRoutes.settings,
              onSelected: context.go,
            ),
    );
  }
}

class _EngineIssue {
  const _EngineIssue({
    required this.file,
    required this.line,
    required this.column,
    required this.code,
    required this.message,
    required this.isError,
  });

  final String file;
  final int line;
  final int column;
  final String? code;
  final String message;
  final bool isError;
}
