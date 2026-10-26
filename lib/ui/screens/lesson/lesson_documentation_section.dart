import 'package:flutter/material.dart';

import '../../../data/models/lesson_models.dart';
import 'lesson_markdown_content.dart';

class LessonDocumentationSection extends StatelessWidget {
  const LessonDocumentationSection({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final documentation = lesson.documentation;
    if (documentation == null) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    return Card(
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(
          isEnglish ? 'Lesson documentation' : 'توثيق الدرس',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          LessonMarkdownContent(markdown: documentation.resolve(locale)),
          if (lesson.documentationSources.isNotEmpty) ...[
            const Divider(height: 24),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                isEnglish ? 'Sources' : 'المصادر',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final source in lesson.documentationSources)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: EdgeInsets.zero,
                title: Text(source.title.resolve(locale)),
                subtitle: SelectableText(
                  source.url,
                  textDirection: TextDirection.ltr,
                ),
                dense: true,
              ),
            Text(
              isEnglish
                  ? 'Based on Godot Engine Documentation, licensed under CC BY 3.0. This educational text is an independent adaptation and is not endorsed by Godot.'
                  : 'يستند هذا المحتوى إلى توثيق Godot Engine المرخّص بموجب CC BY 3.0. هذا إعداد تعليمي مستقل وليس معتمداً من Godot.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            const SelectableText(
              'https://creativecommons.org/licenses/by/3.0/',
              textDirection: TextDirection.ltr,
            ),
          ],
        ],
      ),
    );
  }
}
