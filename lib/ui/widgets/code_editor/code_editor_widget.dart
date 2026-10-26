import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdscript_engine/gdscript_engine.dart';
import '../../../core/theme/editor_theme_extension.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../logic/services/code_runner_service.dart';
import '../code_directionality.dart';
import 'code_actions_bar.dart';
import 'code_completion_overlay.dart';
import 'line_numbers.dart';
import 'syntax_highlighter.dart';

class CodeEditorWidget extends StatefulWidget {
  const CodeEditorWidget({
    super.key,
    required this.initialCode,
    this.documentId,
    this.initialSelection,
    this.focusNode,
    this.readOnly = false,
    this.expands = false,
    this.onChanged,
    this.onSelectionChanged,
    this.onRun,
    this.onRunCode,
    this.onSave,
    this.onCompletionRequested,
    this.onCompletionItemsRequested,
    this.onSyntaxHighlightsRequested,
    this.onSemanticHighlightsRequested,
    this.onDiagnosticsRequested,
    this.onSignatureHelpRequested,
    this.onHoverInfoRequested,
    this.onDefinitionRequested,
    this.onMatchingBracketRequested,
    this.fontSize = 14,
    this.showLineNumbers = true,
    this.showActionBar = true,
    this.showRunResults = true,
    this.backgroundColor,
  });

  final String initialCode;
  final String? documentId;
  final TextSelection? initialSelection;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool expands;
  final ValueChanged<String>? onChanged;
  final ValueChanged<TextSelection>? onSelectionChanged;
  final VoidCallback? onRun;
  final Future<CodeRunResult> Function(String code)? onRunCode;
  final Future<void> Function()? onSave;
  final Future<List<String>> Function(String code, int cursorOffset)?
  onCompletionRequested;
  final Future<List<CompletionItem>> Function(String code, int cursorOffset)?
  onCompletionItemsRequested;
  final List<SyntaxHighlight> Function(String code)?
  onSyntaxHighlightsRequested;
  final List<SemanticHighlight> Function(String code)?
  onSemanticHighlightsRequested;
  final List<Diagnostic> Function(String code)? onDiagnosticsRequested;
  final SignatureHelp? Function(String code, int cursorOffset)?
  onSignatureHelpRequested;
  final HoverInfo? Function(String code, int cursorOffset)?
  onHoverInfoRequested;
  final GoToDefinition? Function(String code, int cursorOffset)?
  onDefinitionRequested;
  final (int, int)? Function(String code, int cursorOffset)?
  onMatchingBracketRequested;
  final double fontSize;
  final bool showLineNumbers;
  final bool showActionBar;
  final bool showRunResults;
  final Color? backgroundColor;

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  late final _SyntaxTextController _controller;
  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _lineScrollController = ScrollController();
  List<CompletionItem> _completionItems = const [];
  int _selectedCompletionIndex = 0;
  int _editorRequestSequence = 0;
  bool _editorRequestRunning = false;
  Object? _editorError;
  List<Diagnostic> _diagnostics = const [];
  Object? _diagnosticsError;
  Timer? _diagnosticsDebounce;
  Timer? _hoverDebounce;
  SignatureHelp? _signatureHelp;
  HoverInfo? _hoverInfo;
  Object? _hoverError;
  bool _runningCode = false;
  int _runSequence = 0;
  CodeRunResult? _runResult;
  Object? _runError;
  bool _syncingControllerValue = false;
  late String _lastNotifiedText;

  @override
  void initState() {
    super.initState();
    _lastNotifiedText = widget.initialCode;
    final initialSelection = widget.initialSelection;
    _controller =
        _SyntaxTextController(
            text: widget.initialCode,
            selection: initialSelection == null
                ? TextSelection.collapsed(offset: widget.initialCode.length)
                : TextSelection(
                    baseOffset: initialSelection.baseOffset
                        .clamp(0, widget.initialCode.length)
                        .toInt(),
                    extentOffset: initialSelection.extentOffset
                        .clamp(0, widget.initialCode.length)
                        .toInt(),
                  ),
          )
          ..syntaxHighlightsRequested = widget.onSyntaxHighlightsRequested
          ..semanticHighlightsRequested = widget.onSemanticHighlightsRequested
          ..addListener(_handleControllerChanged);
    _refreshDiagnostics();
    _refreshSignatureHelp();
    _refreshMatchingBracket();
    _scheduleHoverInfo();
    _editorScrollController.addListener(_syncLineScroll);
  }

  @override
  void didUpdateWidget(covariant CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onSyntaxHighlightsRequested !=
            widget.onSyntaxHighlightsRequested ||
        oldWidget.onSemanticHighlightsRequested !=
            widget.onSemanticHighlightsRequested) {
      _controller.invalidateHighlights();
    }
    _controller.syntaxHighlightsRequested = widget.onSyntaxHighlightsRequested;
    _controller.semanticHighlightsRequested =
        widget.onSemanticHighlightsRequested;
    final documentChanged = oldWidget.documentId != widget.documentId;
    final codeChanged = oldWidget.initialCode != widget.initialCode;
    final externalCodeChanged =
        codeChanged && _controller.text != widget.initialCode;
    if (documentChanged || externalCodeChanged) {
      final selection = widget.initialSelection;
      _setControllerValue(
        TextEditingValue(
          text: widget.initialCode,
          selection: selection == null
              ? TextSelection.collapsed(offset: widget.initialCode.length)
              : TextSelection(
                  baseOffset: selection.baseOffset
                      .clamp(0, widget.initialCode.length)
                      .toInt(),
                  extentOffset: selection.extentOffset
                      .clamp(0, widget.initialCode.length)
                      .toInt(),
                ),
        ),
      );
      _lastNotifiedText = widget.initialCode;
      _runResult = null;
      _runError = null;
      _editorRequestSequence++;
      _editorRequestRunning = false;
      _editorError = null;
      _completionItems = const [];
      _runSequence++;
      _runningCode = false;
    }
    if (documentChanged ||
        externalCodeChanged ||
        oldWidget.onDiagnosticsRequested != widget.onDiagnosticsRequested ||
        oldWidget.onMatchingBracketRequested !=
            widget.onMatchingBracketRequested ||
        oldWidget.onHoverInfoRequested != widget.onHoverInfoRequested) {
      _diagnosticsDebounce?.cancel();
      _refreshDiagnostics();
      _refreshSignatureHelp();
      _refreshMatchingBracket();
      _scheduleHoverInfo();
    }
  }

  void _setControllerValue(TextEditingValue value) {
    _syncingControllerValue = true;
    _controller.value = value;
    _syncingControllerValue = false;
  }

  void _handleControllerChanged() {
    if (_syncingControllerValue) return;
    final text = _controller.text;
    if (text != _lastNotifiedText) {
      _lastNotifiedText = text;
      _scheduleDiagnostics();
      _editorRequestSequence++;
      _editorRequestRunning = false;
      _completionItems = const [];
      _runSequence++;
      _runningCode = false;
      _runResult = null;
      _runError = null;
      widget.onChanged?.call(text);
    }
    _refreshSignatureHelp();
    _refreshMatchingBracket();
    _scheduleHoverInfo();
    widget.onSelectionChanged?.call(_controller.selection);
    if (mounted) setState(() {});
  }

  void _refreshDiagnostics() {
    final request = widget.onDiagnosticsRequested;
    _diagnosticsError = null;
    if (request == null) {
      _diagnostics = const [];
      _controller.diagnostics = _diagnostics;
      return;
    }
    try {
      _diagnostics = request(_controller.text);
    } on Object catch (error) {
      _diagnostics = const [];
      _diagnosticsError = error;
    }
    _controller.diagnostics = _diagnostics;
  }

  void _scheduleDiagnostics() {
    _diagnosticsDebounce?.cancel();
    _diagnostics = const [];
    _controller.diagnostics = _diagnostics;
    _diagnosticsError = null;
    final request = widget.onDiagnosticsRequested;
    if (request == null) return;
    final code = _controller.text;
    final documentId = widget.documentId;
    _diagnosticsDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted ||
          code != _controller.text ||
          documentId != widget.documentId) {
        return;
      }
      try {
        final diagnostics = request(code);
        if (!mounted ||
            code != _controller.text ||
            documentId != widget.documentId) {
          return;
        }
        setState(() {
          _diagnostics = diagnostics;
          _controller.diagnostics = diagnostics;
          _diagnosticsError = null;
        });
      } on Object catch (error) {
        if (!mounted ||
            code != _controller.text ||
            documentId != widget.documentId) {
          return;
        }
        setState(() {
          _diagnostics = const [];
          _controller.diagnostics = _diagnostics;
          _diagnosticsError = error;
        });
      }
    });
  }

  void _refreshSignatureHelp() {
    _signatureHelp = widget.onSignatureHelpRequested?.call(
      _controller.text,
      _controller.selection.extentOffset,
    );
  }

  void _refreshMatchingBracket() {
    _controller.matchingBracketOffsets = widget.onMatchingBracketRequested
        ?.call(_controller.text, _controller.selection.extentOffset);
  }

  void _scheduleHoverInfo() {
    _hoverDebounce?.cancel();
    _hoverInfo = null;
    _hoverError = null;
    final request = widget.onHoverInfoRequested;
    if (request == null) return;
    final code = _controller.text;
    final offset = _controller.selection.extentOffset;
    final documentId = widget.documentId;
    _hoverDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted ||
          code != _controller.text ||
          offset != _controller.selection.extentOffset ||
          documentId != widget.documentId) {
        return;
      }
      try {
        final info = request(code, offset);
        if (!mounted ||
            code != _controller.text ||
            offset != _controller.selection.extentOffset ||
            documentId != widget.documentId) {
          return;
        }
        setState(() {
          _hoverInfo = info;
          _hoverError = null;
        });
      } on Object catch (error) {
        if (!mounted ||
            code != _controller.text ||
            offset != _controller.selection.extentOffset ||
            documentId != widget.documentId) {
          return;
        }
        setState(() {
          _hoverInfo = null;
          _hoverError = error;
        });
      }
    });
  }

  void _syncLineScroll() {
    if (!_lineScrollController.hasClients) return;
    final offset = _editorScrollController.offset.clamp(
      0.0,
      _lineScrollController.position.maxScrollExtent,
    );
    _lineScrollController.jumpTo(offset);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (_completionItems.isNotEmpty) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedCompletionIndex =
              (_selectedCompletionIndex + 1) % _completionItems.length;
        });
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedCompletionIndex =
              (_selectedCompletionIndex - 1 + _completionItems.length) %
              _completionItems.length;
        });
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        _applyCompletion(_completionItems[_selectedCompletionIndex]);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() => _completionItems = const []);
        return KeyEventResult.handled;
      }
    }

    final keyboard = HardwareKeyboard.instance;
    if ((keyboard.isControlPressed || keyboard.isMetaPressed) &&
        event.logicalKey == LogicalKeyboardKey.space &&
        (widget.onCompletionRequested != null ||
            widget.onCompletionItemsRequested != null)) {
      unawaited(_requestCompletions());
      return KeyEventResult.handled;
    }
    if ((keyboard.isControlPressed || keyboard.isMetaPressed) &&
        event.logicalKey == LogicalKeyboardKey.keyS &&
        widget.onSave != null) {
      unawaited(widget.onSave!.call());
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f12 &&
        widget.onDefinitionRequested != null) {
      _goToDefinition();
      return KeyEventResult.handled;
    }
    if (event.logicalKey != LogicalKeyboardKey.tab || widget.readOnly) {
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
    final itemRequest = widget.onCompletionItemsRequested;
    final request = widget.onCompletionRequested;
    if (itemRequest == null && request == null) return;
    final requestSequence = ++_editorRequestSequence;
    final code = _controller.text;
    final documentId = widget.documentId;
    setState(() {
      _editorRequestRunning = true;
      _editorError = null;
      _completionItems = const [];
    });
    try {
      final cursorOffset = _controller.selection.extentOffset;
      final items = itemRequest != null
          ? await itemRequest(code, cursorOffset)
          : [
              for (final item in await request!(code, cursorOffset))
                CompletionItem(
                  label: item,
                  kind: CompletionKind.snippet,
                  insertText: item,
                ),
            ];
      if (!mounted ||
          requestSequence != _editorRequestSequence ||
          code != _controller.text ||
          documentId != widget.documentId) {
        return;
      }
      setState(() {
        _completionItems = items;
        _selectedCompletionIndex = 0;
        _editorRequestRunning = false;
      });
    } on Object catch (error) {
      if (!mounted ||
          requestSequence != _editorRequestSequence ||
          code != _controller.text ||
          documentId != widget.documentId) {
        return;
      }
      setState(() {
        _editorError = error;
        _editorRequestRunning = false;
      });
    }
  }

  void _applyCompletion(CompletionItem completion) {
    var suggestion = completion.insertText ?? completion.label;
    final selection = _controller.selection;
    final cursor = selection.extentOffset.clamp(0, _controller.text.length);
    final start = selection.isCollapsed
        ? _identifierStart(_controller.text, cursor)
        : selection.start.clamp(0, _controller.text.length).toInt();
    final end = selection.isCollapsed
        ? cursor
        : selection.end.clamp(start, _controller.text.length).toInt();
    final functionCompletion =
        completion.kind == CompletionKind.function ||
        completion.kind == CompletionKind.method;
    final openingParen = functionCompletion ? suggestion.indexOf('(') : -1;
    var selectionOffset = start + suggestion.length;
    if (openingParen >= 0 && suggestion.endsWith(')')) {
      final suffix = _controller.text.substring(end);
      if (suffix.startsWith('(')) {
        suggestion = suggestion.substring(0, openingParen);
        selectionOffset = start + suggestion.length;
      } else {
        if (suffix.startsWith(')')) {
          suggestion = suggestion.substring(0, suggestion.length - 1);
        }
        selectionOffset = start + openingParen + 1;
      }
    }
    final text = _controller.text.replaceRange(start, end, suggestion);
    _setControllerValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: selectionOffset),
      ),
    );
    _lastNotifiedText = text;
    _scheduleDiagnostics();
    _refreshSignatureHelp();
    _refreshMatchingBracket();
    _scheduleHoverInfo();
    widget.onChanged?.call(text);
    widget.onSelectionChanged?.call(_controller.selection);
    setState(() => _completionItems = const []);
  }

  void _goToDefinition() {
    final definition = widget.onDefinitionRequested?.call(
      _controller.text,
      _controller.selection.extentOffset,
    );
    if (definition == null) return;
    final start = definition.offset.clamp(0, _controller.text.length);
    final end = (definition.offset + definition.length).clamp(
      start,
      _controller.text.length,
    );
    _setControllerValue(
      TextEditingValue(
        text: _controller.text,
        selection: TextSelection(baseOffset: start, extentOffset: end),
      ),
    );
    _refreshSignatureHelp();
    _refreshMatchingBracket();
    _scheduleHoverInfo();
    widget.onSelectionChanged?.call(_controller.selection);
    if (_editorScrollController.hasClients) {
      _editorScrollController.animateTo(
        (definition.line - 1) * widget.fontSize * 1.5,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    }
    setState(() {});
  }

  Future<void> _runCode() async {
    final run = widget.onRunCode;
    if (run == null || _runningCode) return;
    final runSequence = ++_runSequence;
    final code = _controller.text;
    final documentId = widget.documentId;
    setState(() {
      _runningCode = true;
      _runResult = null;
      _runError = null;
    });
    try {
      final result = await run(code);
      if (!mounted ||
          runSequence != _runSequence ||
          code != _controller.text ||
          documentId != widget.documentId) {
        return;
      }
      setState(() {
        _runResult = result;
        _runningCode = false;
      });
    } on Object catch (error) {
      if (!mounted ||
          runSequence != _runSequence ||
          code != _controller.text ||
          documentId != widget.documentId) {
        return;
      }
      setState(() {
        _runError = error;
        _runningCode = false;
      });
    }
  }

  int _identifierStart(String code, int cursor) {
    var start = cursor;
    while (start > 0 && RegExp(r'[A-Za-z0-9_]').hasMatch(code[start - 1])) {
      start--;
    }
    return start;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    final theme = CodeEditorTheme.of(context);
    _controller.editorTheme = theme;
    _controller.refreshSyntaxHighlights();
    final lineCount = '\n'.allMatches(_controller.text).length + 1;
    final textStyle = CodeTextTheme.of(context).bodyMedium.copyWith(
      color: theme.foreground,
      fontSize: widget.fontSize,
      height: 1.5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.expands)
          Expanded(
            child: _buildEditorField(colors, theme, lineCount, textStyle),
          )
        else
          _buildEditorField(colors, theme, lineCount, textStyle),
        if (_signatureHelp != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                _signatureHelp!.signature,
                textDirection: TextDirection.ltr,
                style: CodeTextTheme.of(context).bodyMedium.copyWith(
                  fontSize: widget.fontSize - 1,
                  color: theme.function,
                ),
              ),
            ),
          ),
        if (_hoverInfo != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _HoverInfoPanel(info: _hoverInfo!),
          ),
        if (_hoverError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${context.l10n.executionFailed} $_hoverError',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (widget.showActionBar &&
            (widget.onRun != null ||
                widget.onRunCode != null ||
                widget.onCompletionRequested != null ||
                widget.onCompletionItemsRequested != null))
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: CodeActionsBar(
              onRun: widget.onRunCode != null
                  ? (_runningCode ? null : _runCode)
                  : widget.onRun,
              onCompletion: _editorRequestRunning
                  ? null
                  : widget.onCompletionRequested == null &&
                        widget.onCompletionItemsRequested == null
                  ? null
                  : _requestCompletions,
            ),
          ),
        if (_completionItems.isNotEmpty)
          CodeDirectionality(
            child: CodeCompletionOverlay(
              items: _completionItems,
              selectedIndex: _selectedCompletionIndex,
              onSelected: _applyCompletion,
            ),
          ),
        if (_editorError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${context.l10n.executionFailed} $_editorError',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (_diagnosticsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${context.l10n.executionFailed} $_diagnosticsError',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (widget.showRunResults && _runError != null)
          _ResultPanel(
            title: context.l10n.executionFailed,
            content: _runError.toString(),
            isError: true,
          ),
        if (widget.showRunResults && _runResult != null)
          _ResultPanel(
            title: _runResult!.isSuccess
                ? (Localizations.localeOf(context).languageCode == 'ar'
                      ? 'اكتمل التنفيذ'
                      : 'Execution completed')
                : context.l10n.executionFailed,
            content: [
              ..._runResult!.output,
              ?_runResult!.errorMessage,
              '${_runResult!.executionTimeMs} ms - '
                  '${_runResult!.instructionsExecuted} instructions',
            ].join('\n'),
            isError: !_runResult!.isSuccess,
          ),
      ],
    );
  }

  Widget _buildEditorField(
    ColorScheme colors,
    CodeEditorTheme editorTheme,
    int lineCount,
    TextStyle textStyle,
  ) {
    final errorLines = <int>{};
    final warningLines = <int>{};
    for (final diagnostic in _diagnostics) {
      if (diagnostic.severity == DiagnosticSeverity.error) {
        errorLines.add(diagnostic.location.line);
      } else if (diagnostic.severity == DiagnosticSeverity.warning) {
        warningLines.add(diagnostic.location.line);
      }
    }
    return CodeDirectionality(
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(minHeight: 132),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLineNumbers)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, top: 1),
                child: LineNumbers(
                  lineCount: lineCount,
                  scrollController: _lineScrollController,
                  fontSize: widget.fontSize,
                  errorLines: errorLines,
                  warningLines: warningLines,
                ),
              ),
            Expanded(
              child: Focus(
                onKeyEvent: _handleKey,
                child: LayoutBuilder(
                  builder: (context, constraints) => AnimatedBuilder(
                    animation: _editorScrollController,
                    builder: (context, _) {
                      final lineHeight = widget.fontSize * 1.5;
                      final scrollOffset = _editorScrollController.hasClients
                          ? _editorScrollController.offset
                          : 0.0;
                      final diagnosticLines = <int, List<Diagnostic>>{};
                      for (final diagnostic in _diagnostics) {
                        diagnosticLines
                            .putIfAbsent(diagnostic.location.line, () => [])
                            .add(diagnostic);
                      }
                      final annotationWidth = (constraints.maxWidth - 16)
                          .clamp(0.0, 320.0)
                          .toDouble();
                      return Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          TextField(
                            controller: _controller,
                            focusNode: widget.focusNode,
                            textAlignVertical: .top,
                            scrollController: _editorScrollController,
                            readOnly: widget.readOnly,
                            minLines: widget.expands ? null : 5,
                            maxLines: null,
                            expands: widget.expands,
                            keyboardType: TextInputType.multiline,
                            inputFormatters: widget.readOnly
                                ? null
                                : const [_GDScriptInputFormatter()],
                            style: textStyle,
                            cursorColor: colors.primary,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              filled: true,
                              hoverColor:
                                  widget.backgroundColor ??
                                  editorTheme.background,
                              fillColor:
                                  widget.backgroundColor ??
                                  editorTheme.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 17,
                              ),
                            ),
                            enableSuggestions: false,
                            autocorrect: false,
                            textDirection: TextDirection.ltr,
                          ),
                          for (final entry in diagnosticLines.entries)
                            _buildInlineDiagnostic(
                              entry.key,
                              entry.value,
                              top:
                                  15 +
                                  (entry.key - 1) * lineHeight -
                                  scrollOffset,
                              left:
                                  30 +
                                  _diagnosticLeft(
                                    _lineTextAt(entry.key),
                                    textStyle,
                                    constraints.maxWidth,
                                    annotationWidth,
                                  ),
                              width: annotationWidth,
                              colors: colors,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineDiagnostic(
    int line,
    List<Diagnostic> diagnostics, {
    required double top,
    required double left,
    required double width,
    required ColorScheme colors,
  }) {
    final diagnostic = diagnostics.firstWhere(
      (item) => item.severity == DiagnosticSeverity.error,
      orElse: () => diagnostics.first,
    );
    final color = switch (diagnostic.severity) {
      DiagnosticSeverity.error => colors.error,
      DiagnosticSeverity.warning => colors.secondary,
      DiagnosticSeverity.hint || DiagnosticSeverity.info => colors.primary,
    };
    final message = diagnostics.map((item) => item.message).join(' · ');
    if (width < 80) return const SizedBox.shrink();
    return Positioned(
      key: ValueKey('inline-diagnostic-line-$line'),
      top: top,
      left: left,
      // width: width,
      child: Tooltip(
        message: message,
        waitDuration: const Duration(milliseconds: 350),
        child: Container(
          height: 20,
          alignment: AlignmentDirectional.topStart,
          padding: const EdgeInsetsDirectional.only(start: 5, end: 7, top: 2),
          decoration: BoxDecoration(
            //color: colors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(4),
            //border: Border.all(color: color.withValues(alpha: 0.55)),
          ),
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: CodeTextTheme.of(
              context,
            ).bodySmall.copyWith(color: color, fontSize: 10, height: 1),
          ),
        ),
      ),
    );
  }

  String _lineTextAt(int line) {
    final lines = _controller.text.split('\n');
    if (line < 1 || line > lines.length) return '';
    return lines[line - 1];
  }

  double _diagnosticLeft(
    String lineText,
    TextStyle textStyle,
    double editorWidth,
    double annotationWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: lineText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final maxLeft = (editorWidth - annotationWidth - 8).clamp(
      8.0,
      double.infinity,
    );
    return (12 + painter.width + 8).clamp(8.0, maxLeft).toDouble();
  }

  // void _selectDiagnostic(Diagnostic diagnostic) {
  //   final start = diagnostic.location.offset.clamp(0, _controller.text.length);
  //   final end = (start + diagnostic.location.length).clamp(
  //     start,
  //     _controller.text.length,
  //   );
  //   _setControllerValue(
  //     TextEditingValue(
  //       text: _controller.text,
  //       selection: TextSelection(baseOffset: start, extentOffset: end),
  //     ),
  //   );
  //   _refreshSignatureHelp();
  //   _refreshMatchingBracket();
  //   _scheduleHoverInfo();
  //   widget.onSelectionChanged?.call(_controller.selection);
  //   if (_editorScrollController.hasClients) {
  //     _editorScrollController.animateTo(
  //       (diagnostic.location.line - 1) * widget.fontSize * 1.5,
  //       duration: const Duration(milliseconds: 120),
  //       curve: Curves.easeOut,
  //     );
  //   }
  //   setState(() {});
  // }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    _diagnosticsDebounce?.cancel();
    _hoverDebounce?.cancel();
    _editorScrollController
      ..removeListener(_syncLineScroll)
      ..dispose();
    _lineScrollController.dispose();
    super.dispose();
  }
}

class _SyntaxTextController extends TextEditingController {
  _SyntaxTextController({
    required String text,
    required TextSelection selection,
  }) : super.fromValue(TextEditingValue(text: text, selection: selection));

  CodeEditorTheme? editorTheme;
  List<SyntaxHighlight> Function(String code)? syntaxHighlightsRequested;
  List<SemanticHighlight> Function(String code)? semanticHighlightsRequested;
  final GDScriptSyntaxHighlighter _highlighter = GDScriptSyntaxHighlighter();
  List<SyntaxHighlight>? _syntaxHighlights;
  List<SemanticHighlight>? _semanticHighlights;
  List<Diagnostic> _diagnostics = const [];
  (int, int)? matchingBracketOffsets;
  String? _highlightedText;

  List<Diagnostic> get diagnostics => _diagnostics;

  set diagnostics(List<Diagnostic> value) {
    if (identical(_diagnostics, value)) return;
    _diagnostics = value;
    notifyListeners();
  }

  void refreshSyntaxHighlights() {
    if (_highlightedText == text) return;
    _highlightedText = text;
    _syntaxHighlights = syntaxHighlightsRequested?.call(text);
    _semanticHighlights = semanticHighlightsRequested?.call(text);
  }

  void invalidateHighlights() => _highlightedText = null;

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
    refreshSyntaxHighlights();
    return TextSpan(
      style: style,
      children: _highlighter.highlight(
        text,
        currentTheme,
        engineHighlights: _syntaxHighlights,
        semanticHighlights: _semanticHighlights,
        diagnostics: diagnostics,
        matchingBracketOffsets: matchingBracketOffsets,
        errorColor: Theme.of(context).colorScheme.error,
        warningColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.title,
    required this.content,
    required this.isError,
  });

  final String title;
  final String content;
  final bool isError;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 100),
    child: Card(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            content,
            style: CodeTextTheme.of(context).bodySmall.copyWith(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _HoverInfoPanel extends StatelessWidget {
  const _HoverInfoPanel({required this.info});

  final HoverInfo info;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          info.signature,
          textDirection: TextDirection.ltr,
          style: CodeTextTheme.of(context).bodySmall.copyWith(fontSize: 12),
        ),
        if (info.type case final type?)
          Text(
            type,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (info.documentation case final documentation?)
          Text(documentation, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class _GDScriptInputFormatter extends TextInputFormatter {
  const _GDScriptInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    const pairs = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'"};
    final oldSelection = oldValue.selection;
    final newSelection = newValue.selection;
    if (oldSelection.isCollapsed &&
        newSelection.isCollapsed &&
        newValue.text.length == oldValue.text.length + 1) {
      final cursor = oldSelection.extentOffset;
      if (cursor >= 0 && cursor < oldValue.text.length) {
        final inserted = newValue.text.substring(cursor, cursor + 1);
        if (pairs.values.contains(inserted) &&
            oldValue.text.substring(cursor, cursor + 1) == inserted) {
          return TextEditingValue(
            text: oldValue.text,
            selection: TextSelection.collapsed(offset: cursor + 1),
          );
        }
      }
      if (newSelection.extentOffset > 0) {
        final cursor = newSelection.extentOffset;
        final inserted = newValue.text.substring(cursor - 1, cursor);
        final closing = pairs[inserted];
        if (closing != null) {
          return TextEditingValue(
            text: newValue.text.replaceRange(cursor, cursor, closing),
            selection: TextSelection.collapsed(offset: cursor),
          );
        }
      }
    }

    if (oldSelection.isCollapsed &&
        newSelection.isCollapsed &&
        oldValue.text.length == newValue.text.length + 1 &&
        oldSelection.extentOffset > 0) {
      final cursor = oldSelection.extentOffset;
      final deleted = oldValue.text.substring(cursor - 1, cursor);
      final closing = pairs[deleted];
      if (closing != null &&
          cursor < oldValue.text.length &&
          oldValue.text.substring(cursor, cursor + 1) == closing) {
        return TextEditingValue(
          text: newValue.text.replaceRange(cursor - 1, cursor, ''),
          selection: TextSelection.collapsed(offset: cursor - 1),
        );
      }
    }

    if (newValue.text.length <= oldValue.text.length ||
        newSelection.baseOffset <= 0) {
      return newValue;
    }
    final cursor = newSelection.baseOffset;
    final inserted = newValue.text.substring(
      oldSelection.baseOffset.clamp(0, oldValue.text.length),
      cursor,
    );
    if (inserted != '\n') return newValue;
    final oldLineStart = oldValue.text.lastIndexOf(
      '\n',
      oldSelection.baseOffset - 1,
    );
    final previousLine = oldValue.text.substring(
      oldLineStart + 1,
      oldSelection.baseOffset,
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
