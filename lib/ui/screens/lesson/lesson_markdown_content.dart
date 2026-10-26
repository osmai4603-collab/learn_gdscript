import 'package:flutter/material.dart';
import '../../../core/theme/arabic_ide_theme.dart';
import '../../../core/theme/code_editor_theme.dart';
import '../../widgets/code_editor/syntax_highlighter.dart';
import 'lesson_code_block.dart';

class LessonMarkdownContent extends StatelessWidget {
  const LessonMarkdownContent({super.key, required this.markdown});

  final String markdown;

  static final _syntaxHighlighter = GDScriptSyntaxHighlighter();

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];
    var inCodeBlock = false;
    final codeLines = <String>[];
    for (final line in lines) {
      if (line.trimLeft().startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(LessonCodeBlock(code: codeLines.join('\n')));
          codeLines.clear();
        }
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        codeLines.add(line);
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        );
      } else if (line.trim().isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: SelectableText.rich(_inlineCodeSpans(context, line)),
          ),
        );
      }
    }
    if (codeLines.isNotEmpty) {
      widgets.add(LessonCodeBlock(code: codeLines.join('\n')));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  static TextSpan _inlineCodeSpans(BuildContext context, String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'`([^`]+)`');
    var offset = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: text.substring(offset, match.start)));
      }
      spans.add(
        TextSpan(
          children: [
            const TextSpan(text: '\u2066'),
            ..._syntaxHighlighter.highlight(
              match.group(1)!,
              CodeEditorTheme.of(context),
            ),
            const TextSpan(text: '\u2069'),
          ],
          style: TextStyle(fontFamily: ArabicIdeTheme.codeFontFamily(context)),
        ),
      );
      offset = match.end;
    }
    if (offset < text.length) spans.add(TextSpan(text: text.substring(offset)));
    return TextSpan(
      style: Theme.of(context).textTheme.bodySmall,
      children: spans,
    );
  }
}
