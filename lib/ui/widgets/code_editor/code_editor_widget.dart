import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/code_editor_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../code_directionality.dart';
import 'code_actions_bar.dart';
import 'code_completion_overlay.dart';
import 'line_numbers.dart';
import 'syntax_highlighter.dart';

class CodeEditorWidget extends StatefulWidget {
  const CodeEditorWidget({
    super.key,
    required this.initialCode,
    this.readOnly = false,
    this.onChanged,
    this.onRun,
    this.onCompletionRequested,
    this.onFormatRequested,
    this.fontSize = 14,
    this.showLineNumbers = true,
    this.showActionBar = true,
  });

  final String initialCode;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onRun;
  final Future<List<String>> Function(String code, int cursorOffset)?
  onCompletionRequested;
  final Future<String?> Function(String code)? onFormatRequested;
  final double fontSize;
  final bool showLineNumbers;
  final bool showActionBar;

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  late final _SyntaxTextController _controller;
  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _lineScrollController = ScrollController();
  List<String> _completionItems = const [];
  bool _lspRequestRunning = false;
  Object? _lspError;

  @override
  void initState() {
    super.initState();
    _controller = _SyntaxTextController(text: widget.initialCode)
      ..addListener(_notifyChanged);
    _editorScrollController.addListener(_syncLineScroll);
  }

  @override
  void didUpdateWidget(covariant CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCode != widget.initialCode &&
        widget.initialCode != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialCode,
        selection: TextSelection.collapsed(offset: widget.initialCode.length),
      );
    }
  }

  void _notifyChanged() => widget.onChanged?.call(_controller.text);

  void _syncLineScroll() {
    if (!_lineScrollController.hasClients) return;
    final offset = _editorScrollController.offset.clamp(
      0.0,
      _lineScrollController.position.maxScrollExtent,
    );
    _lineScrollController.jumpTo(offset);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.tab ||
        widget.readOnly) {
      return KeyEventResult.ignored;
    }
    final selection = _controller.selection;
    final value = _controller.value;
    final text = value.text.replaceRange(
      selection.start,
      selection.end,
      '    ',
    );
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selection.start + 4),
    );
    return KeyEventResult.handled;
  }

  Future<void> _requestCompletions() async {
    final request = widget.onCompletionRequested;
    if (request == null) return;
    setState(() {
      _lspRequestRunning = true;
      _lspError = null;
      _completionItems = const [];
    });
    try {
      final items = await request(
        _controller.text,
        _controller.selection.extentOffset,
      );
      if (!mounted) return;
      setState(() {
        _completionItems = items;
        _lspRequestRunning = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _lspError = error;
        _lspRequestRunning = false;
      });
    }
  }

  Future<void> _formatDocument() async {
    final format = widget.onFormatRequested;
    if (format == null) return;
    setState(() {
      _lspRequestRunning = true;
      _lspError = null;
    });
    try {
      final formatted = await format(_controller.text);
      if (!mounted) return;
      if (formatted != null) {
        _controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      setState(() => _lspRequestRunning = false);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _lspError = error;
        _lspRequestRunning = false;
      });
    }
  }

  void _applyCompletion(String suggestion) {
    final selection = _controller.selection;
    final start = selection.start.clamp(0, _controller.text.length).toInt();
    final end = selection.end.clamp(start, _controller.text.length).toInt();
    final text = _controller.text.replaceRange(start, end, suggestion);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + suggestion.length),
    );
    setState(() => _completionItems = const []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CodeEditorTheme.of(context);
    _controller.editorTheme = theme;
    final lineCount = '\n'.allMatches(_controller.text).length + 1;
    final textStyle = TextStyle(
      color: theme.foreground,
      fontFamily: 'JetBrains Mono',
      fontSize: widget.fontSize,
      height: 1.5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CodeDirectionality(
          child: Container(
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(theme.borderRadius),
            ),
            constraints: const BoxConstraints(minHeight: 132),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showLineNumbers)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      top: 1,
                    ),
                    child: LineNumbers(
                      lineCount: lineCount,
                      scrollController: _lineScrollController,
                      fontSize: widget.fontSize,
                    ),
                  ),
                Expanded(
                  child: Focus(
                    onKeyEvent: _handleKey,
                    child: TextField(
                      controller: _controller,
                      scrollController: _editorScrollController,
                      readOnly: widget.readOnly,
                      minLines: 5,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      inputFormatters: widget.readOnly
                          ? null
                          : const [_AutoIndentFormatter()],
                      style: textStyle,
                      cursorColor: theme.cursor,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      enableSuggestions: false,
                      autocorrect: false,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.showActionBar &&
            (widget.onRun != null ||
                widget.onCompletionRequested != null ||
                widget.onFormatRequested != null))
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CodeActionsBar(
              onRun: widget.onRun,
              onCompletion: _lspRequestRunning
                  ? null
                  : widget.onCompletionRequested == null
                  ? null
                  : _requestCompletions,
              onFormat: _lspRequestRunning
                  ? null
                  : widget.onFormatRequested == null
                  ? null
                  : _formatDocument,
            ),
          ),
        if (_completionItems.isNotEmpty)
          CodeDirectionality(
            child: CodeCompletionOverlay(
              items: _completionItems,
              onSelected: _applyCompletion,
            ),
          ),
        if (_lspError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${context.l10n.lspFeatureError} $_lspError',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_notifyChanged)
      ..dispose();
    _editorScrollController
      ..removeListener(_syncLineScroll)
      ..dispose();
    _lineScrollController.dispose();
    super.dispose();
  }
}

class _SyntaxTextController extends TextEditingController {
  _SyntaxTextController({super.text});

  CodeEditorTheme? editorTheme;
  final GDScriptSyntaxHighlighter _highlighter = GDScriptSyntaxHighlighter();

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final currentTheme = editorTheme;
    if (currentTheme == null) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    return TextSpan(
      style: style,
      children: _highlighter.highlight(text, currentTheme),
    );
  }
}

class _AutoIndentFormatter extends TextInputFormatter {
  const _AutoIndentFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= oldValue.text.length ||
        newValue.selection.baseOffset <= 0) {
      return newValue;
    }
    final cursor = newValue.selection.baseOffset;
    final inserted = newValue.text.substring(
      oldValue.selection.baseOffset.clamp(0, oldValue.text.length),
      cursor,
    );
    if (inserted != '\n') return newValue;
    final oldLineStart = oldValue.text.lastIndexOf(
      '\n',
      oldValue.selection.baseOffset - 1,
    );
    final previousLine = oldValue.text.substring(
      oldLineStart + 1,
      oldValue.selection.baseOffset,
    );
    final indentation = RegExp(r'^\s*').firstMatch(previousLine)!.group(0)!;
    final extra = previousLine.trimRight().endsWith(':') ? '    ' : '';
    final spaces = '$indentation$extra';
    if (spaces.isEmpty) return newValue;
    return TextEditingValue(
      text: newValue.text.replaceRange(cursor, cursor, spaces),
      selection: TextSelection.collapsed(offset: cursor + spaces.length),
    );
  }
}
