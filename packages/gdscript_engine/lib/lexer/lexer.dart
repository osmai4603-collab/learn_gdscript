import '../core/error_reporter.dart';
import '../core/source.dart';
import '../core/source_location.dart';
import 'indent_tracker.dart';
import 'keywords.dart';
import 'token.dart';
import 'token_type.dart';

/// Scanner/Lexer that converts GDScript source text into a stream of [Token]s.
class Lexer {
  /// The input source code.
  final Source source;

  /// Error reporter for recording lexical errors.
  final ErrorReporter reporter;

  /// Whether to include comments in the emitted token stream.
  final bool includeComments;

  /// Indentation tracking helper.
  final IndentTracker _indentTracker;

  int _start = 0;
  int _current = 0;
  bool _atStartOfLine = true;
  TokenType? _lastEmittedType;

  /// Creates a new [Lexer] for [source].
  Lexer({
    required this.source,
    required this.reporter,
    this.includeComments = false,
    int tabWidth = 4,
  }) : _indentTracker = IndentTracker(tabWidth: tabWidth);

  String get _content => source.content;
  bool get _isAtEnd => _current >= _content.length;

  /// Scans the entire source and returns the complete list of [Token]s,
  /// ending with [TokenType.eof].
  List<Token> scanTokens() {
    final tokens = <Token>[];

    while (!_isAtEnd) {
      if (_atStartOfLine) {
        final indentTokens = _handleLineStart();
        for (final t in indentTokens) {
          tokens.add(t);
          _lastEmittedType = t.type;
        }
        if (_isAtEnd) break;
      }

      _start = _current;
      final token = _scanNextToken();
      if (token != null) {
        tokens.add(token);
        _lastEmittedType = token.type;
      }
    }

    // Flush any dedents at EOF
    final eofLocation = SourceLocation.point(source, _current);
    final eofDedents = _indentTracker.flushAtEof(eofLocation);
    tokens.addAll(eofDedents);

    // Final EOF token
    tokens.add(Token(type: TokenType.eof, lexeme: '', location: eofLocation));

    return tokens;
  }

  /// Handles indentation and logical newlines at the start of a line.
  List<Token> _handleLineStart() {
    final tokens = <Token>[];

    while (!_isAtEnd) {
      final indentStart = _current;
      var indentWidth = 0;

      // Measure leading whitespace
      while (!_isAtEnd) {
        final c = _peek();
        if (c == ' ') {
          indentWidth++;
          _advance();
        } else if (c == '\t') {
          indentWidth += _indentTracker.tabWidth;
          _advance();
        } else {
          break;
        }
      }

      // Empty lines or lines with comments only do not generate indentation changes
      if (_isAtEnd || _peek() == '\n' || _peek() == '\r' || _peek() == '#') {
        if (!_isAtEnd && (_peek() == '\n' || _peek() == '\r')) {
          _skipNewline();
          continue; // Loop to next line without leaving _handleLineStart
        }
        // If line starts with a comment, let _scanNextToken scan the comment
        _atStartOfLine = false;
        return tokens;
      }

      // Non-blank line: Emit INDENT or DEDENT tokens as necessary
      final indentLocation = SourceLocation.fromOffsets(
        source,
        indentStart,
        _current - indentStart,
      );

      final indents = _indentTracker.processIndentation(
        indentWidth: indentWidth,
        location: indentLocation,
        reporter: reporter,
      );

      tokens.addAll(indents);
      _atStartOfLine = false;
      return tokens;
    }

    _atStartOfLine = false;
    return tokens;
  }

  /// Scans a single token from current cursor position.
  Token? _scanNextToken() {
    _skipHorizontalWhitespace();
    if (_isAtEnd) return null;

    _start = _current;
    final c = _advance();

    switch (c) {
      // Grouping brackets
      case '(':
        _indentTracker.openBracket();
        return _makeToken(TokenType.lparen);
      case ')':
        _indentTracker.closeBracket();
        return _makeToken(TokenType.rparen);
      case '[':
        _indentTracker.openBracket();
        return _makeToken(TokenType.lbracket);
      case ']':
        _indentTracker.closeBracket();
        return _makeToken(TokenType.rbracket);
      case '{':
        _indentTracker.openBracket();
        return _makeToken(TokenType.lbrace);
      case '}':
        _indentTracker.closeBracket();
        return _makeToken(TokenType.rbrace);

      // Punctuation
      case ',':
        return _makeToken(TokenType.comma);
      case ';':
        return _makeToken(TokenType.semicolon);
      case '?':
        return _makeToken(TokenType.question);
      case r'\':
        // Explicit line continuation
        if (_peek() == '\r' || _peek() == '\n') {
          _skipNewline();
          return null;
        }
        return _makeToken(TokenType.backslash);

      case '.':
        if (_match('.')) {
          return _makeToken(TokenType.dotDot);
        }
        if (_isDigit(_peek())) {
          return _number(isFloatLeadingDot: true);
        }
        return _makeToken(TokenType.dot);

      case ':':
        if (_match('=')) {
          return _makeToken(TokenType.colonEqual);
        }
        return _makeToken(TokenType.colon);

      // Node shortcuts
      case r'$':
        return _makeToken(TokenType.dollar);

      // Operators: Arithmetic & Bitwise
      case '+':
        if (_match('=')) return _makeToken(TokenType.plusEqual);
        return _makeToken(TokenType.plus);

      case '-':
        if (_match('=')) return _makeToken(TokenType.minusEqual);
        if (_match('>')) return _makeToken(TokenType.arrow);
        return _makeToken(TokenType.minus);

      case '*':
        if (_match('*')) {
          if (_match('=')) return _makeToken(TokenType.starStarEqual);
          return _makeToken(TokenType.starStar);
        }
        if (_match('=')) return _makeToken(TokenType.starEqual);
        return _makeToken(TokenType.star);

      case '/':
        if (_match('=')) return _makeToken(TokenType.slashEqual);
        return _makeToken(TokenType.slash);

      case '%':
        if (_match('=')) return _makeToken(TokenType.percentEqual);
        return _makeToken(TokenType.percent);

      case '~':
        return _makeToken(TokenType.tilde);

      case '&':
        if (_match('=')) return _makeToken(TokenType.ampersandEqual);
        if (_peek() == '"' || _peek() == "'") {
          // StringName literal: &"string" or &'string'
          return _string(isStringName: true);
        }
        return _makeToken(TokenType.ampersand);

      case '|':
        if (_match('=')) return _makeToken(TokenType.pipeEqual);
        return _makeToken(TokenType.pipe);

      case '^':
        if (_match('=')) return _makeToken(TokenType.caretEqual);
        if (_peek() == '"' || _peek() == "'") {
          // NodePath literal: ^"node/path" or ^'node/path'
          return _string(isNodePath: true);
        }
        return _makeToken(TokenType.caret);

      // Comparison & Assignment
      case '=':
        if (_match('=')) return _makeToken(TokenType.equalEqual);
        return _makeToken(TokenType.equal);

      case '!':
        if (_match('=')) return _makeToken(TokenType.bangEqual);
        return _makeToken(TokenType.kwNot);

      case '<':
        if (_match('<')) {
          if (_match('=')) return _makeToken(TokenType.shiftLeftEqual);
          return _makeToken(TokenType.shiftLeft);
        }
        if (_match('=')) return _makeToken(TokenType.lessEqual);
        return _makeToken(TokenType.less);

      case '>':
        if (_match('>')) {
          if (_match('=')) return _makeToken(TokenType.shiftRightEqual);
          return _makeToken(TokenType.shiftRight);
        }
        if (_match('=')) return _makeToken(TokenType.greaterEqual);
        return _makeToken(TokenType.greater);

      // Comments & Annotations
      case '#':
        return _comment();

      case '@':
        return _annotation();

      // String literals
      case '"':
      case "'":
        return _string(quoteChar: c);

      // Logical Newlines
      case '\n':
      case '\r':
        return _newline();

      default:
        if (_isDigit(c)) {
          return _number();
        }
        if (_isAlpha(c)) {
          return _identifier();
        }
        _error('Unexpected character "$c"');
        return _makeToken(TokenType.error);
    }
  }

  Token? _newline() {
    // Rewind back 1 char to capture \r\n properly
    _current--;
    _skipNewline();

    _atStartOfLine = true;

    // Suppress newlines when inside parentheses/brackets
    if (_indentTracker.isInsideBrackets) {
      return null;
    }

    // Avoid emitting duplicate newlines or newline at start of file
    if (_lastEmittedType == TokenType.newline ||
        _lastEmittedType == TokenType.indent ||
        _lastEmittedType == TokenType.dedent ||
        _lastEmittedType == null) {
      return null;
    }

    return _makeToken(TokenType.newline);
  }

  Token _comment() {
    final isDoc = _match('#');
    while (!_isAtEnd && _peek() != '\n' && _peek() != '\r') {
      _advance();
    }

    final commentText = _content.substring(_start, _current);
    final location = SourceLocation.fromOffsets(
      source,
      _start,
      _current - _start,
    );

    if (isDoc) {
      // Documentation comment ##
      return Token(
        type: TokenType.docComment,
        lexeme: commentText,
        literal: commentText.substring(2).trim(),
        location: location,
      );
    }

    if (includeComments) {
      return Token(
        type: TokenType.comment,
        lexeme: commentText,
        literal: commentText.substring(1).trim(),
        location: location,
      );
    }

    // Skip comment in compiler token stream
    return _makeToken(TokenType.comment);
  }

  Token _annotation() {
    if (!_isAlpha(_peek())) {
      _error(
        'Expected annotation name after "@" (e.g. @export, @onready, @tool)',
      );
      return _makeToken(TokenType.error);
    }

    while (!_isAtEnd && (_isAlphaNumeric(_peek()) || _peek() == '_')) {
      _advance();
    }

    final lexeme = _content.substring(_start, _current);
    final annotationName = lexeme.substring(1); // remove '@'
    return Token(
      type: TokenType.annotation,
      lexeme: lexeme,
      literal: annotationName,
      location: SourceLocation.fromOffsets(source, _start, _current - _start),
    );
  }

  Token _string({
    String? quoteChar,
    bool isStringName = false,
    bool isNodePath = false,
  }) {
    final delimiter = quoteChar ?? _advance();
    final isTriple = _peek() == delimiter && _peekNext() == delimiter;
    if (isTriple) {
      _advance();
      _advance();
    }

    final buffer = StringBuffer();

    while (!_isAtEnd) {
      if (isTriple) {
        if (_peek() == delimiter &&
            _peekNext() == delimiter &&
            _peekNth(2) == delimiter) {
          _advance();
          _advance();
          _advance();
          break;
        }
      } else {
        if (_peek() == delimiter) {
          _advance();
          break;
        }
        if (_peek() == '\n' || _peek() == '\r') {
          _error(
            'Unterminated string literal. Single-line strings cannot span across newlines.',
          );
          break;
        }
      }

      final c = _advance();
      if (c == r'\') {
        if (_isAtEnd) {
          _error('Unfinished escape sequence at end of string.');
          break;
        }
        final esc = _advance();
        switch (esc) {
          case 'n':
            buffer.write('\n');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 'a':
            buffer.write('\x07');
            break;
          case 'b':
            buffer.write('\b');
            break;
          case 'f':
            buffer.write('\f');
            break;
          case 'v':
            buffer.write('\v');
            break;
          case r'\':
            buffer.write(r'\');
            break;
          case '"':
            buffer.write('"');
            break;
          case "'":
            buffer.write("'");
            break;
          case 'u':
            // \uXXXX (4 hex characters)
            buffer.write(_parseUnicodeEscape(4));
            break;
          case 'U':
            // \UXXXXXXXX (8 hex characters)
            buffer.write(_parseUnicodeEscape(8));
            break;
          default:
            buffer.write(esc);
            break;
        }
      } else {
        buffer.write(c);
      }
    }

    final parsedString = buffer.toString();
    final lexeme = _content.substring(_start, _current);
    final location = SourceLocation.fromOffsets(
      source,
      _start,
      _current - _start,
    );

    if (isStringName) {
      return Token(
        type: TokenType.stringNameLiteral,
        lexeme: lexeme,
        literal: parsedString,
        location: location,
      );
    }
    if (isNodePath) {
      return Token(
        type: TokenType.nodePathLiteral,
        lexeme: lexeme,
        literal: parsedString,
        location: location,
      );
    }
    if (isTriple) {
      return Token(
        type: TokenType.multilineString,
        lexeme: lexeme,
        literal: parsedString,
        location: location,
      );
    }

    return Token(
      type: TokenType.stringLiteral,
      lexeme: lexeme,
      literal: parsedString,
      location: location,
    );
  }

  String _parseUnicodeEscape(int digitCount) {
    var hexStr = '';
    for (var i = 0; i < digitCount; i++) {
      if (_isAtEnd || !_isHexDigit(_peek())) {
        _error(
          'Invalid unicode escape sequence. Expected $digitCount hex digits.',
        );
        return '';
      }
      hexStr += _advance();
    }
    final codePoint = int.tryParse(hexStr, radix: 16);
    if (codePoint == null) {
      _error('Invalid unicode code point "\\u$hexStr"');
      return '';
    }
    return String.fromCharCode(codePoint);
  }

  Token _number({bool isFloatLeadingDot = false}) {
    if (!isFloatLeadingDot) {
      // Hexadecimal (0x...), Binary (0b...), Octal (0o...)
      if (_content.substring(_start, _current) == '0' && !_isAtEnd) {
        final baseChar = _peek().toLowerCase();
        if (baseChar == 'x') {
          _advance(); // consume 'x'
          return _hexNumber();
        } else if (baseChar == 'b') {
          _advance(); // consume 'b'
          return _binaryNumber();
        } else if (baseChar == 'o') {
          _advance(); // consume 'o'
          return _octalNumber();
        }
      }

      // Decimal integer digits
      while (!_isAtEnd && (_isDigit(_peek()) || _peek() == '_')) {
        _advance();
      }
    } else {
      // Leading dot already consumed; scan fractional digits
      while (!_isAtEnd && (_isDigit(_peek()) || _peek() == '_')) {
        _advance();
      }
    }

    // Check for fractional part
    var isFloat = isFloatLeadingDot;
    if (!isFloatLeadingDot &&
        _peek() == '.' &&
        _peekNext() != '.' &&
        _isDigit(_peekNext())) {
      isFloat = true;
      _advance(); // consume '.'
      while (!_isAtEnd && (_isDigit(_peek()) || _peek() == '_')) {
        _advance();
      }
    }

    // Check for scientific exponent: e/E (+/-) digits
    if (!_isAtEnd && (_peek() == 'e' || _peek() == 'E')) {
      isFloat = true;
      _advance(); // consume 'e'/'E'
      if (!_isAtEnd && (_peek() == '+' || _peek() == '-')) {
        _advance();
      }
      while (!_isAtEnd && (_isDigit(_peek()) || _peek() == '_')) {
        _advance();
      }
    }

    final rawLexeme = _content.substring(_start, _current);
    final cleanNum = rawLexeme.replaceAll('_', '');
    final location = SourceLocation.fromOffsets(
      source,
      _start,
      _current - _start,
    );

    if (isFloat) {
      final value = double.tryParse(cleanNum);
      if (value == null) {
        _error('Malformed floating point literal "$rawLexeme"');
        return _makeToken(TokenType.error);
      }
      return Token(
        type: TokenType.floatLiteral,
        lexeme: rawLexeme,
        literal: value,
        location: location,
      );
    } else {
      final value = int.tryParse(cleanNum);
      if (value == null) {
        _error('Integer literal out of range "$rawLexeme"');
        return _makeToken(TokenType.error);
      }
      return Token(
        type: TokenType.integerLiteral,
        lexeme: rawLexeme,
        literal: value,
        location: location,
      );
    }
  }

  Token _hexNumber() {
    while (!_isAtEnd && (_isHexDigit(_peek()) || _peek() == '_')) {
      _advance();
    }
    final rawLexeme = _content.substring(_start, _current);
    final digits = rawLexeme.substring(2).replaceAll('_', '');
    final value = int.tryParse(digits, radix: 16);
    final location = SourceLocation.fromOffsets(
      source,
      _start,
      _current - _start,
    );

    if (value == null) {
      _error('Invalid hexadecimal literal "$rawLexeme"');
      return _makeToken(TokenType.error);
    }
    return Token(
      type: TokenType.integerLiteral,
      lexeme: rawLexeme,
      literal: value,
      location: location,
    );
  }

  Token _binaryNumber() {
    while (!_isAtEnd && (_peek() == '0' || _peek() == '1' || _peek() == '_')) {
      _advance();
    }
    final rawLexeme = _content.substring(_start, _current);
    final digits = rawLexeme.substring(2).replaceAll('_', '');
    final value = int.tryParse(digits, radix: 2);
    final location = SourceLocation.fromOffsets(
      source,
      _start,
      _current - _start,
    );

    if (value == null) {
      _error('Invalid binary literal "$rawLexeme"');
      return _makeToken(TokenType.error);
    }
    return Token(
      type: TokenType.integerLiteral,
      lexeme: rawLexeme,
      literal: value,
      location: location,
    );
  }

  Token _octalNumber() {
    while (!_isAtEnd && (_isOctalDigit(_peek()) || _peek() == '_')) {
      _advance();
    }
    final rawLexeme = _content.substring(_start, _current);
    final digits = rawLexeme.substring(2).replaceAll('_', '');
    final value = int.tryParse(digits, radix: 8);
    final location = SourceLocation.fromOffsets(
      source,
      _start,
      _current - _start,
    );

    if (value == null) {
      _error('Invalid octal literal "$rawLexeme"');
      return _makeToken(TokenType.error);
    }
    return Token(
      type: TokenType.integerLiteral,
      lexeme: rawLexeme,
      literal: value,
      location: location,
    );
  }

  Token _identifier() {
    while (!_isAtEnd && (_isAlphaNumeric(_peek()) || _peek() == '_')) {
      _advance();
    }

    final text = _content.substring(_start, _current);
    final keywordType = Keywords.lookup(text);

    if (keywordType != null) {
      Object? literal;
      if (keywordType == TokenType.kwTrue) literal = true;
      if (keywordType == TokenType.kwFalse) literal = false;
      if (keywordType == TokenType.kwNull) literal = null;

      return Token(
        type: keywordType,
        lexeme: text,
        literal: literal,
        location: SourceLocation.fromOffsets(source, _start, _current - _start),
      );
    }

    return Token(
      type: TokenType.identifier,
      lexeme: text,
      location: SourceLocation.fromOffsets(source, _start, _current - _start),
    );
  }

  // === Character stream helpers ===

  void _skipHorizontalWhitespace() {
    while (!_isAtEnd) {
      final c = _peek();
      if (c == ' ' || c == '\t') {
        _advance();
      } else {
        break;
      }
    }
  }

  void _skipNewline() {
    if (_peek() == '\r') {
      _advance();
      if (_peek() == '\n') {
        _advance();
      }
    } else if (_peek() == '\n') {
      _advance();
    }
  }

  String _advance() => _content[_current++];

  bool _match(String expected) {
    if (_isAtEnd || _content[_current] != expected) return false;
    _current++;
    return true;
  }

  String _peek() => _isAtEnd ? '\x00' : _content[_current];

  String _peekNext() {
    if (_current + 1 >= _content.length) return '\x00';
    return _content[_current + 1];
  }

  String _peekNth(int offset) {
    if (_current + offset >= _content.length) return '\x00';
    return _content[_current + offset];
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  bool _isHexDigit(String c) {
    final code = c.toLowerCase().codeUnitAt(0);
    return (code >= 48 && code <= 57) || (code >= 97 && code <= 102);
  }

  bool _isOctalDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 48 && code <= 55;
  }

  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        c == '_';
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  Token _makeToken(TokenType type, [Object? literal]) {
    final length = _current - _start;
    final lexeme = _content.substring(_start, _current);
    return Token(
      type: type,
      lexeme: lexeme,
      literal: literal,
      location: SourceLocation.fromOffsets(source, _start, length),
    );
  }

  void _error(String message) {
    final loc = SourceLocation.fromOffsets(source, _start, _current - _start);
    reporter.error(message, loc);
  }
}
