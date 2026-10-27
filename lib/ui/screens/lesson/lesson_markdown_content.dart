import 'package:flutter/material.dart';

import '../../../core/theme/editor_theme_extension.dart';
import '../../widgets/code_editor/syntax_highlighter.dart';
import 'lesson_code_block.dart';
import 'widgets/lesson_callout_card.dart';

class LessonMarkdownContent extends StatelessWidget {
  const LessonMarkdownContent({super.key, required this.markdown});

  final String markdown;

  static final _syntaxHighlighter = GDScriptSyntaxHighlighter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bodyStyle =
        theme.textTheme.bodyMedium?.copyWith(
          height: 1.65,
          fontSize: 15,
          color: theme.textTheme.bodyMedium?.color?.withValues(
            alpha: isDark ? 0.95 : 0.90,
          ),
        ) ??
        const TextStyle(height: 1.65, fontSize: 15);

    final h1Style =
        theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ) ??
        const TextStyle(fontWeight: FontWeight.bold);

    final h2Style =
        theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ) ??
        const TextStyle(fontWeight: FontWeight.bold);

    final h3Style =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700) ??
        const TextStyle(fontWeight: FontWeight.w700);

    final lines = markdown.split('\n');
    final widgets = <Widget>[];

    var inCodeBlock = false;
    final codeLines = <String>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i];
      final trimmedLine = line.trim();

      // 1. Code block delimiter
      if (trimmedLine.startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(LessonCodeBlock(code: codeLines.join('\n')));
          codeLines.clear();
        }
        inCodeBlock = !inCodeBlock;
        i++;
        continue;
      }

      if (inCodeBlock) {
        codeLines.add(line);
        i++;
        continue;
      }

      // Skip blank lines
      if (trimmedLine.isEmpty) {
        i++;
        continue;
      }

      // 2. Directive callouts: > [!WARNING], > [!NOTE], > [!TIP]
      final directiveMatch = RegExp(
        r'^>\s*\[!(WARNING|NOTE|TIP)\]',
        caseSensitive: false,
      ).firstMatch(trimmedLine);

      if (directiveMatch != null) {
        final directiveType = CalloutType.fromDirective(
          directiveMatch.group(1)!,
        );
        final calloutLines = <String>[];
        i++;

        while (i < lines.length && lines[i].trimLeft().startsWith('>')) {
          final contentLine = lines[i].trimLeft();
          final stripped = contentLine.startsWith('> ')
              ? contentLine.substring(2)
              : contentLine.substring(1).trimLeft();
          calloutLines.add(stripped);
          i++;
        }

        final fullText = calloutLines.join('\n').trim();
        final (extractedTitle, bodyText) = _extractCalloutTitle(fullText);

        widgets.add(
          LessonCalloutCard(
            type: directiveType,
            title: extractedTitle,
            contentSpans: buildInlineSpans(
              context,
              bodyText,
              baseStyle: bodyStyle,
            ),
          ),
        );
        continue;
      }

      // 3. Blockquotes and Golden Rules: > ...
      if (trimmedLine.startsWith('>')) {
        final quoteLines = <String>[];
        while (i < lines.length && lines[i].trimLeft().startsWith('>')) {
          final contentLine = lines[i].trimLeft();
          final stripped = contentLine.startsWith('> ')
              ? contentLine.substring(2)
              : contentLine.substring(1).trimLeft();
          quoteLines.add(stripped);
          i++;
        }

        final fullText = quoteLines.join('\n').trim();
        final isGoldenRule =
            fullText.contains('قاعدة ذهبية') ||
            fullText.contains('Golden Rule') ||
            fullText.contains('قاعدة عملية') ||
            fullText.contains('Practical Rule');

        if (isGoldenRule) {
          final (title, bodyText) = _extractCalloutTitle(fullText);
          widgets.add(
            LessonCalloutCard(
              type: CalloutType.goldenRule,
              title: title,
              contentSpans: buildInlineSpans(
                context,
                bodyText,
                baseStyle: bodyStyle,
              ),
            ),
          );
        } else {
          // Standard blockquote container
          widgets.add(
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: BorderDirectional(
                  start: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3.5,
                  ),
                ),
              ),
              child: SelectableText.rich(
                TextSpan(
                  style: bodyStyle.copyWith(fontStyle: FontStyle.italic),
                  children: buildInlineSpans(
                    context,
                    fullText,
                    baseStyle: bodyStyle.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          );
        }
        continue;
      }

      // 4. Inline alert list items: - ⚠️, - ℹ️, - 💡
      final inlineAlertMatch = RegExp(
        r'^[-*]\s*(⚠️|ℹ️|💡)\s*(.*)$',
      ).firstMatch(trimmedLine);

      if (inlineAlertMatch != null) {
        final emoji = inlineAlertMatch.group(1)!;
        final rawContent = inlineAlertMatch.group(2)!.trim();
        final type = switch (emoji) {
          '⚠️' => CalloutType.warning,
          '💡' => CalloutType.tip,
          _ => CalloutType.note,
        };

        final (extractedTitle, bodyText) = _extractCalloutTitle(rawContent);

        widgets.add(
          LessonCalloutCard(
            type: type,
            title: extractedTitle,
            contentSpans: buildInlineSpans(
              context,
              bodyText,
              baseStyle: bodyStyle,
            ),
          ),
        );
        i++;
        continue;
      }

      // 5. Headings: #, ##, ###
      if (line.startsWith('# ') || trimmedLine.startsWith('# ')) {
        final headingText = line.startsWith('# ')
            ? line.substring(2).trim()
            : trimmedLine.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: SelectableText.rich(
              TextSpan(
                style: h1Style,
                children: buildInlineSpans(
                  context,
                  headingText,
                  baseStyle: h1Style,
                ),
              ),
            ),
          ),
        );
        i++;
        continue;
      }

      if (line.startsWith('## ') || trimmedLine.startsWith('## ')) {
        final headingText = line.startsWith('## ')
            ? line.substring(3).trim()
            : trimmedLine.substring(3).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: SelectableText.rich(
              TextSpan(
                style: h2Style,
                children: buildInlineSpans(
                  context,
                  headingText,
                  baseStyle: h2Style,
                ),
              ),
            ),
          ),
        );
        i++;
        continue;
      }

      if (line.startsWith('### ') || trimmedLine.startsWith('### ')) {
        final headingText = line.startsWith('### ')
            ? line.substring(4).trim()
            : trimmedLine.substring(4).trim();

        // Check if heading has a step number e.g. "1. المفهوم في سياق الألعاب"
        final numberedMatch = RegExp(
          r'^(\d+)\.\s*(.+)$',
        ).firstMatch(headingText);

        if (numberedMatch != null) {
          final number = numberedMatch.group(1)!;
          final title = numberedMatch.group(2)!;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      number,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText.rich(
                      TextSpan(
                        style: h3Style,
                        children: buildInlineSpans(
                          context,
                          title,
                          baseStyle: h3Style,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: SelectableText.rich(
                TextSpan(
                  style: h3Style,
                  children: buildInlineSpans(
                    context,
                    headingText,
                    baseStyle: h3Style,
                  ),
                ),
              ),
            ),
          );
        }
        i++;
        continue;
      }

      // 6. Bullet lists: - item or * item
      if (trimmedLine.startsWith('- ') || trimmedLine.startsWith('* ')) {
        final itemText = trimmedLine.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8,
                    end: 10,
                    start: 4,
                  ),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: SelectableText.rich(
                    TextSpan(
                      style: bodyStyle,
                      children: buildInlineSpans(
                        context,
                        itemText,
                        baseStyle: bodyStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // 7. Regular paragraph
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SelectableText.rich(
            TextSpan(
              style: bodyStyle,
              children: buildInlineSpans(
                context,
                trimmedLine,
                baseStyle: bodyStyle,
              ),
            ),
          ),
        ),
      );
      i++;
    }

    if (codeLines.isNotEmpty) {
      widgets.add(LessonCodeBlock(code: codeLines.join('\n')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  /// Builds styled inline spans supporting:
  /// - Syntax-highlighted inline code `code` (with backticks stripped and BiDi protection)
  /// - Bold text **bold**
  /// - Italic text *italic*
  /// - Normal text matching [baseStyle]
  static List<InlineSpan> buildInlineSpans(
    BuildContext context,
    String text, {
    required TextStyle baseStyle,
  }) {
    if (text.isEmpty) return const [];

    final theme = Theme.of(context);
    final codeTheme = CodeEditorTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final codeBackground = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
        : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.7);

    final pattern = RegExp(r'`([^`]+)`|\*\*([^*]+)\*\*|\*([^*]+)\*');
    final spans = <InlineSpan>[];
    var offset = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > offset) {
        spans.add(
          TextSpan(text: text.substring(offset, match.start), style: baseStyle),
        );
      }

      // Match 1: Inline code `code`
      if (match.group(1) case final code?) {
        spans.add(
          TextSpan(
            children: [
              const TextSpan(text: '\u2066'),
              ..._syntaxHighlighter.highlight(code, codeTheme),
              const TextSpan(text: '\u2069'),
            ],
            style: CodeTextTheme.of(context).bodySmall.copyWith(
              fontSize: baseStyle.fontSize,
              fontWeight: FontWeight.w600,
              backgroundColor: codeBackground,
              fontFamily: CodeEditorTheme.codeFontFamily,
            ),
          ),
        );
      }
      // Match 2: Bold text **bold**
      else if (match.group(2) case final boldText?) {
        final boldStyle = baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: baseStyle.color ?? theme.colorScheme.onSurface,
        );
        if (boldText.contains('`')) {
          spans.addAll(
            buildInlineSpans(context, boldText, baseStyle: boldStyle),
          );
        } else {
          spans.add(TextSpan(text: boldText, style: boldStyle));
        }
      }
      // Match 3: Italic text *italic*
      else if (match.group(3) case final italicText?) {
        final italicStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
        if (italicText.contains('`')) {
          spans.addAll(
            buildInlineSpans(context, italicText, baseStyle: italicStyle),
          );
        } else {
          spans.add(TextSpan(text: italicText, style: italicStyle));
        }
      }

      offset = match.end;
    }

    if (offset < text.length) {
      spans.add(TextSpan(text: text.substring(offset), style: baseStyle));
    }

    return spans;
  }

  /// Extracts bold title prefix such as `**تحذير رسمي:** محتوى...` or `**Golden Rule:** content`
  static (String?, String) _extractCalloutTitle(String text) {
    final titleMatch = RegExp(
      r'^\*\*([^*:]+)(?::)?\*\*\s*[:]?\s*(.*)$',
      dotAll: true,
    ).firstMatch(text.trim());
    if (titleMatch != null) {
      final title = titleMatch.group(1)!.trim();
      final body = titleMatch.group(2)!.trim();
      return (title.isNotEmpty ? title : null, body);
    }
    return (null, text);
  }
}
