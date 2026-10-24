import 'package:flutter/material.dart';

import '../../../core/theme/code_editor_theme.dart';

class LineNumbers extends StatelessWidget {
  const LineNumbers({
    super.key,
    required this.lineCount,
    required this.scrollController,
    required this.fontSize,
  });

  final int lineCount;
  final ScrollController scrollController;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final editorTheme = CodeEditorTheme.of(context);
    final width = (lineCount.toString().length + 1) * fontSize * 0.7;
    return SizedBox(
      width: width,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var line = 1; line <= lineCount; line++)
                SizedBox(
                  height: fontSize * 1.5,
                  child: Text(
                    '$line',
                    style: TextStyle(
                      color: editorTheme.lineNumber,
                      fontFamily: 'JetBrains Mono',
                      fontSize: fontSize,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
