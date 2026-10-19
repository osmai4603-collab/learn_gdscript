/// Represents source code input to the GDScript engine.
///
/// Holds the source identifier ([uri]) and text [content], along with
/// line start offsets for efficient binary search conversions between
/// character offsets and (line, column) pairs.
class Source {
  /// Identifier of this source (e.g. file path, URL, or `<memory>`).
  final String uri;

  /// Full source code text.
  final String content;

  /// Cached starting character offset for each line (0-indexed line start offsets).
  late final List<int> _lineStarts;

  /// Creates a new [Source] instance and precomputes line indices.
  Source({required this.uri, required this.content}) {
    _computeLineStarts();
  }

  /// Creates an in-memory source with a default anonymous URI.
  factory Source.memory(String content, [String name = '<memory>']) {
    return Source(uri: name, content: content);
  }

  void _computeLineStarts() {
    final starts = <int>[0];
    for (var i = 0; i < content.length; i++) {
      final char = content.codeUnitAt(i);
      if (char == 0x0A) {
        // \n
        starts.add(i + 1);
      } else if (char == 0x0D) {
        // \r or \r\n
        if (i + 1 < content.length && content.codeUnitAt(i + 1) == 0x0A) {
          i++; // skip \n
        }
        starts.add(i + 1);
      }
    }
    _lineStarts = List.unmodifiable(starts);
  }

  /// Total number of lines in this source (at least 1).
  int get lineCount => _lineStarts.length;

  /// Returns 1-indexed (line, column) for a given character [offset].
  ///
  /// Clamps offset to valid bounds [0, content.length].
  ({int line, int column}) getLineAndColumn(int offset) {
    if (content.isEmpty) return (line: 1, column: 1);

    final clampedOffset = offset.clamp(0, content.length);

    // Binary search for the line start <= clampedOffset
    var low = 0;
    var high = _lineStarts.length - 1;
    var bestLineIndex = 0;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (_lineStarts[mid] <= clampedOffset) {
        bestLineIndex = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    final line = bestLineIndex + 1; // 1-indexed
    final column = clampedOffset - _lineStarts[bestLineIndex] + 1; // 1-indexed
    return (line: line, column: column);
  }

  /// Returns character offset for a 1-indexed [line] and [column].
  int getOffset(int line, int column) {
    if (line < 1) line = 1;
    if (line > _lineStarts.length) line = _lineStarts.length;

    final lineStart = _lineStarts[line - 1];
    final lineEnd = line < _lineStarts.length
        ? _lineStarts[line]
        : content.length;

    final offset = lineStart + (column - 1);
    return offset.clamp(lineStart, lineEnd);
  }

  /// Extracts the text for a given 1-indexed [line], omitting trailing newlines.
  String getLine(int line) {
    if (line < 1 || line > _lineStarts.length) return '';

    final start = _lineStarts[line - 1];
    final end = (line < _lineStarts.length)
        ? _lineStarts[line]
        : content.length;

    var text = content.substring(start, end);
    if (text.endsWith('\r\n')) {
      text = text.substring(0, text.length - 2);
    } else if (text.endsWith('\n') || text.endsWith('\r')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  /// Slices source content by character offsets [start] and [end].
  String slice(int start, [int? end]) {
    final clampedStart = start.clamp(0, content.length);
    final clampedEnd = (end ?? content.length).clamp(
      clampedStart,
      content.length,
    );
    return content.substring(clampedStart, clampedEnd);
  }

  @override
  String toString() => 'Source(uri: $uri, length: ${content.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Source &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          content == other.content;

  @override
  int get hashCode => Object.hash(uri, content);
}
