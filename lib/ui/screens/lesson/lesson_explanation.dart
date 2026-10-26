import 'package:flutter/material.dart';

import '../../../data/models/lesson_models.dart';
import '../../widgets/output_panel/output_panel.dart';
import 'lesson_documentation_section.dart';
import 'lesson_example_section.dart';
import 'lesson_markdown_content.dart';

class LessonExplanation extends StatelessWidget {
  const LessonExplanation({
    super.key,
    required this.lesson,
    required this.exampleCode,
    required this.exampleRunning,
    required this.exampleOutput,
    required this.exampleError,
    required this.exampleState,
    required this.onExampleCodeChanged,
    required this.onRunExample,
  });

  final Lesson lesson;
  final String? exampleCode;
  final bool exampleRunning;
  final String? exampleOutput;
  final String? exampleError;
  final OutputState exampleState;
  final ValueChanged<String> onExampleCodeChanged;
  final VoidCallback onRunExample;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          lesson.title.resolve(locale),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          lesson.objective.resolve(locale),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        LessonMarkdownContent(
          markdown: lesson.contentMarkdown.resolve(locale),
        ),
        if (lesson.documentation != null) ...[
          const SizedBox(height: 16),
          LessonDocumentationSection(lesson: lesson),
        ],
        if (lesson.exampleCode case final code?) ...[
          const SizedBox(height: 20),
          LessonExampleSection(
            code: exampleCode ?? code,
            running: exampleRunning,
            output: exampleOutput,
            error: exampleError,
            outputState: exampleState,
            onCodeChanged: onExampleCodeChanged,
            onRun: onRunExample,
          ),
        ],
      ],
    );
  }
}
