import 'dart:io';

import '../audit_context.dart';
import '../audit_models.dart';

Future<void> checkDocumentationLinks(
  AuditContext context, {
  required bool checkNetwork,
}) async {
  final seen = <String>{};
  for (final record in context.lessons) {
    for (final source in record.lesson.documentationSources) {
      final uri = Uri.tryParse(source);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host != 'docs.godotengine.org') {
        context.report.add(
          IssueSeverity.error,
          'documentation-links',
          'Documentation URL must use https://docs.godotengine.org/: $source',
          path: context.pathFor(record.file),
        );
        continue;
      }
      if (!uri.path.startsWith('/en/4.3/')) {
        context.report.add(
          IssueSeverity.warning,
          'documentation-version',
          'Documentation URL is not pinned to Godot 4.3: $source',
          path: context.pathFor(record.file),
        );
      }
      if (checkNetwork && seen.add(source)) {
        await _checkStatus(context, record, uri);
      }
    }
  }
}

Future<void> _checkStatus(
  AuditContext context,
  LessonRecord record,
  Uri uri,
) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    final request = await client.getUrl(uri).timeout(
      const Duration(seconds: 10),
    );
    final response = await request.close().timeout(
      const Duration(seconds: 10),
    );
    await response.drain<void>();
    if (response.statusCode < 200 || response.statusCode >= 400) {
      context.report.add(
        IssueSeverity.warning,
        'documentation-http',
        'Documentation URL returned HTTP ${response.statusCode}: $uri',
        path: context.pathFor(record.file),
      );
    }
  } on Object catch (error) {
    context.report.add(
      IssueSeverity.warning,
      'documentation-http',
      'Could not verify documentation URL $uri: $error',
      path: context.pathFor(record.file),
    );
  } finally {
    client.close(force: true);
  }
}
