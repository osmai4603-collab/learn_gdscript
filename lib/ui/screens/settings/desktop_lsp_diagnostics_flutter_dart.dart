import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/providers/language_server_provider.dart';
import '../../routers/app_routes.dart';
import '../../widgets/common/navigation_bar.dart';

class DesktopLspDiagnosticsScreen extends StatefulWidget {
  const DesktopLspDiagnosticsScreen({super.key});

  @override
  State<DesktopLspDiagnosticsScreen> createState() =>
      _DesktopLspDiagnosticsScreenState();
}

class _DesktopLspDiagnosticsScreenState
    extends State<DesktopLspDiagnosticsScreen> {
  String? _selectedIssueId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final server = context.watch<LanguageServerProvider>();
    final issues = _issuesFrom(server.diagnosticsByUri, l10n);
    final selectedIssue = _selectedIssue(issues);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lspDiagnosticsTitle),
        leading: IconButton(
          tooltip: l10n.settingsTitle,
          onPressed: () => context.go(AppRoutes.settings),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            tooltip: l10n.workspaceTitle,
            onPressed: () => context.go(AppRoutes.workspace),
            icon: const Icon(Icons.folder_open),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!server.isConnected) {
            return _DisconnectedState(
              isConnecting: server.isConnecting,
              error: server.lastError,
            );
          }
          if (issues.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.lspDiagnosticsEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }

          final wide = constraints.maxWidth >= 840;
          final summary = _DiagnosticsSummary(issues: issues);
          final issueList = _IssueList(
            issues: issues,
            selectedIssueId: selectedIssue?.id,
            isWide: wide,
            onSelect: (issue) => setState(() => _selectedIssueId = issue.id),
          );
          final details = selectedIssue == null
              ? const SizedBox.shrink()
              : _IssueDetails(issue: selectedIssue);

          if (wide) {
            return Column(
              children: [
                summary,
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(width: 380, child: issueList),
                      const VerticalDivider(width: 1),
                      Expanded(child: details),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              summary,
              const SizedBox(height: 12),
              issueList,
              const SizedBox(height: 12),
              details,
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

  _LspIssue? _selectedIssue(List<_LspIssue> issues) {
    for (final issue in issues) {
      if (issue.id == _selectedIssueId) return issue;
    }
    return issues.isEmpty ? null : issues.first;
  }

  List<_LspIssue> _issuesFrom(
    Map<String, List<Map<String, Object?>>> diagnosticsByUri,
    AppLocalizations l10n,
  ) {
    final issues = <_LspIssue>[];
    for (final entry in diagnosticsByUri.entries) {
      for (var index = 0; index < entry.value.length; index++) {
        final diagnostic = entry.value[index];
        final range = diagnostic['range'];
        final start = range is Map ? range['start'] : null;
        final line = start is Map && start['line'] is int
            ? (start['line'] as int).clamp(0, 0x7fffffff) + 1
            : 1;
        final column = start is Map && start['character'] is int
            ? (start['character'] as int).clamp(0, 0x7fffffff) + 1
            : 1;
        final severityValue = diagnostic['severity'];
        final severity = severityValue is int
            ? DiagnosticSeverity.fromLspValue(severityValue)
            : DiagnosticSeverity.information;
        final codeValue = diagnostic['code'];
        final code = codeValue?.toString();
        final message = diagnostic['message'] is String
            ? diagnostic['message']! as String
            : l10n.lspDiagnosticNoMessage;

        issues.add(
          _LspIssue(
            id: '${entry.key}:$line:$column:${code ?? ''}:$message:$index',
            file: _fileName(entry.key),
            line: line,
            column: column,
            code: code,
            message: message,
            severity: severity,
          ),
        );
      }
    }
    return issues;
  }

  String _fileName(String rawUri) {
    final uri = Uri.tryParse(rawUri);
    if (uri == null || uri.pathSegments.isEmpty) return rawUri;
    return uri.pathSegments.last;
  }
}

enum DiagnosticSeverity {
  error,
  warning,
  information,
  hint;

  static DiagnosticSeverity fromLspValue(int value) => switch (value) {
    1 => DiagnosticSeverity.error,
    2 => DiagnosticSeverity.warning,
    4 => DiagnosticSeverity.hint,
    _ => DiagnosticSeverity.information,
  };
}

class _LspIssue {
  const _LspIssue({
    required this.id,
    required this.file,
    required this.line,
    required this.column,
    required this.code,
    required this.message,
    required this.severity,
  });

  final String id;
  final String file;
  final int line;
  final int column;
  final String? code;
  final String message;
  final DiagnosticSeverity severity;
}

class _DisconnectedState extends StatelessWidget {
  const _DisconnectedState({required this.isConnecting, required this.error});

  final bool isConnecting;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isConnecting)
                  const CircularProgressIndicator()
                else
                  const Icon(Icons.link_off, size: 40),
                const SizedBox(height: 16),
                Text(
                  isConnecting
                      ? l10n.loading
                      : l10n.lspDiagnosticsConnectPrompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.lspConnectionError} $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.workspace),
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.workspaceTitle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosticsSummary extends StatelessWidget {
  const _DiagnosticsSummary({required this.issues});

  final List<_LspIssue> issues;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = {
      DiagnosticSeverity.error: issues
          .where((issue) => issue.severity == DiagnosticSeverity.error)
          .length,
      DiagnosticSeverity.warning: issues
          .where((issue) => issue.severity == DiagnosticSeverity.warning)
          .length,
      DiagnosticSeverity.information: issues
          .where((issue) => issue.severity == DiagnosticSeverity.information)
          .length,
      DiagnosticSeverity.hint: issues
          .where((issue) => issue.severity == DiagnosticSeverity.hint)
          .length,
    };
    final labels = {
      DiagnosticSeverity.error: l10n.lspDiagnosticError,
      DiagnosticSeverity.warning: l10n.lspDiagnosticWarning,
      DiagnosticSeverity.information: l10n.lspDiagnosticInformation,
      DiagnosticSeverity.hint: l10n.lspDiagnosticHint,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.lspDiagnosticsSummary(issues.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final severity in DiagnosticSeverity.values)
            if (counts[severity]! > 0)
              Chip(label: Text('${labels[severity]}: ${counts[severity]}')),
        ],
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({
    required this.issues,
    required this.selectedIssueId,
    required this.isWide,
    required this.onSelect,
  });

  final List<_LspIssue> issues;
  final String? selectedIssueId;
  final bool isWide;
  final ValueChanged<_LspIssue> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      shrinkWrap: !isWide,
      physics: !isWide
          ? const NeverScrollableScrollPhysics()
          : null,
      itemCount: issues.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final issue = issues[index];
        final selected = issue.id == selectedIssueId;
        return Card(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            selected: selected,
            leading: Icon(
              _severityIcon(issue.severity),
              color: _severityColor(context, issue.severity),
            ),
            title: Text(
              '${issue.file}:${issue.line}',
              textDirection: TextDirection.ltr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              issue.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: issue.code == null
                ? null
                : Text(
                    issue.code!,
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            onTap: () => onSelect(issue),
          ),
        );
      },
    );
  }
}

class _IssueDetails extends StatelessWidget {
  const _IssueDetails({required this.issue});

  final _LspIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _severityIcon(issue.severity),
                color: _severityColor(context, issue.severity),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  issue.code ?? l10n.lspDiagnosticsTitle,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            issue.file,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text('${l10n.diagnosticLine(issue.line)} · ${issue.column}'),
          const SizedBox(height: 20),
          SelectableText(
            issue.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

IconData _severityIcon(DiagnosticSeverity severity) => switch (severity) {
  DiagnosticSeverity.error => Icons.error_outline,
  DiagnosticSeverity.warning => Icons.warning_amber_outlined,
  DiagnosticSeverity.information => Icons.info_outline,
  DiagnosticSeverity.hint => Icons.lightbulb_outline,
};

Color _severityColor(BuildContext context, DiagnosticSeverity severity) =>
    switch (severity) {
      DiagnosticSeverity.error => Theme.of(context).colorScheme.error,
      DiagnosticSeverity.warning => Colors.orange,
      DiagnosticSeverity.information => Theme.of(context).colorScheme.primary,
      DiagnosticSeverity.hint => Theme.of(context).colorScheme.tertiary,
    };
