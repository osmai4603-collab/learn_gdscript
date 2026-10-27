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
    final title = lesson.title.resolve(locale);
    final objective = lesson.objective.resolve(locale);
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
    ) ?? const TextStyle(fontWeight: FontWeight.bold);
    final objectiveStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      height: 1.5,
    ) ?? const TextStyle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.contains('`'))
          SelectableText.rich(
            TextSpan(
              style: titleStyle,
              children: LessonMarkdownContent.buildInlineSpans(
                context,
                title,
                baseStyle: titleStyle,
              ),
            ),
          )
        else
          Text(
            title,
            style: titleStyle,
          ),
        const SizedBox(height: 8),
        if (objective.contains('`') || objective.contains('**'))
          SelectableText.rich(
            TextSpan(
              style: objectiveStyle,
              children: LessonMarkdownContent.buildInlineSpans(
                context,
                objective,
                baseStyle: objectiveStyle,
              ),
            ),
          )
        else
          Text(
            objective,
            style: objectiveStyle,
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
