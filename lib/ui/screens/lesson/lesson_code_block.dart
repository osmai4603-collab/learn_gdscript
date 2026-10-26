import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/arabic_ide_theme.dart';
import '../../../core/theme/code_editor_theme.dart';
import '../../widgets/code_directionality.dart';
import '../../widgets/code_editor/syntax_highlighter.dart';

class LessonCodeBlock extends StatelessWidget {
  const LessonCodeBlock({super.key, required this.code});

  final String code;

  static final _syntaxHighlighter = GDScriptSyntaxHighlighter();

  @override
  Widget build(BuildContext context) {
    final codeTheme = CodeEditorTheme.of(context);
    final spans = _syntaxHighlighter.highlight(code, codeTheme);
    return CodeDirectionality(
      child: Card(
        color: CodeEditorTheme.of(context).background,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText.rich(
                  TextSpan(
                    style: TextStyle(
                      color: codeTheme.foreground,
                      fontFamily: ArabicIdeTheme.codeFontFamily(context),
                    ),
                    children: spans,
                  ),
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
