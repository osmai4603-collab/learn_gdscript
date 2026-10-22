import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../logic/services/test_runner_service.dart';
import '../code_directionality.dart';

class TestResultsWidget extends StatelessWidget {
  const TestResultsWidget({
    super.key,
    required this.results,
    required this.allPassed,
  });

  final List<TestCaseResult> results;
  final bool allPassed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final passed = results.where((result) => result.passed).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.testResults} · ${l10n.testSummary(passed, results.length)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (allPassed) ...[
              const SizedBox(height: 8),
              Text(l10n.allTestsPassed),
            ],
            const SizedBox(height: 8),
            for (final result in results)
              _TestCaseResultRow(result: result),
          ],
        ),
      ),
    );
  }
}

class _TestCaseResultRow extends StatelessWidget {
  const _TestCaseResultRow({required this.result});

  final TestCaseResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                result.passed ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: result.passed
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.testCase.description.resolve(Localizations.localeOf(context)),
                ),
              ),
              Text(result.passed ? l10n.testPassed : l10n.testFailed),
            ],
          ),
          if (!result.passed)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 26, top: 4),
              child: CodeDirectionality(
                child: Text(
                  result.error ??
                      '${l10n.expectedOutput}: ${result.testCase.expectedOutput}\n'
                          '${l10n.actualOutput}: ${result.actualOutput}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
