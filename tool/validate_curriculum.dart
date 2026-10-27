import 'dart:io';

import 'src/audit_models.dart';
import 'src/curriculum_auditor.dart';
import 'src/reporters/console_reporter.dart';
import 'src/reporters/markdown_reporter.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runValidationCli(arguments);
}

Future<int> runValidationCli(
  List<String> arguments, {
  Directory? rootDirectory,
}) async {
  String? unit;
  String? outputPath;
  var checkLinks = false;
  var strict = false;
  for (final argument in arguments) {
    if (argument == '--check-links') {
      checkLinks = true;
    } else if (argument == '--strict') {
      strict = true;
    } else if (argument == '--help' || argument == '-h') {
      _printUsage();
      return 0;
    } else if (argument.startsWith('--unit=')) {
      unit = argument.substring('--unit='.length);
      if (unit.trim().isEmpty) {
        stderr.writeln('The --unit option requires a unit ID or directory prefix.');
        return 2;
      }
    } else if (argument.startsWith('--output=')) {
      outputPath = argument.substring('--output='.length);
      if (outputPath.trim().isEmpty) {
        stderr.writeln('The --output option requires a file path.');
        return 2;
      }
    } else {
      stderr.writeln('Unknown argument: $argument');
      _printUsage();
      return 2;
    }
  }

  final root = rootDirectory ?? Directory.current;
  final report = await CurriculumAuditor(root).run(
    unitFilter: unit,
    checkLinks: checkLinks,
  );
  printConsoleReport(report, strict: strict);
  if (outputPath != null) {
    final outputFile = File(
      outputPath.startsWith('/') ? outputPath : '${root.path}/$outputPath',
    );
    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsString(
      buildMarkdownReport(report, strict: strict),
    );
    stdout.writeln('Markdown report written to ${outputFile.path}');
  }
  return report.hasErrors ||
          (strict && report.count(IssueSeverity.warning) > 0)
      ? 1
      : 0;
}

void _printUsage() {
  stdout.writeln('''
Usage: dart run tool/validate_curriculum.dart [options]

Options:
  --unit=01          Limit findings to a unit directory prefix or full unit ID.
  --check-links      Make HTTP requests to verify documentation URL status.
  --strict           Return a failure code when warnings are present.
  --output=PATH      Write the findings as a Markdown report.
  --help             Show this help.
''');
}
