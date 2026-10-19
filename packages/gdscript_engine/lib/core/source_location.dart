import 'dart:math' as math;
import 'source.dart';

/// Represents a precise character span or point in source code.
///
/// Immutable location containing start/end line and column information,
/// as well as character offset and length within the referenced [Source].
class SourceLocation {
  /// The source file or buffer this location belongs to.
  final Source source;

  /// Starting 0-based character offset in [source].
  final int offset;

  /// Length in characters of this span (0 for point locations).
  final int length;

  /// Starting 1-indexed line number.
  final int line;

  /// Starting 1-indexed column number.
  final int column;

  /// Ending 1-indexed line number.
  final int endLine;

  /// Ending 1-indexed column number.
  final int endColumn;

  /// Constructs an explicit [SourceLocation].
  const SourceLocation({
    required this.source,
    required this.offset,
    required this.length,
    required this.line,
    required this.column,
    required this.endLine,
    required this.endColumn,
  });

  /// Constructs a [SourceLocation] from a character [offset] and [length],
  /// automatically calculating line and column numbers from [source].
  factory SourceLocation.fromOffsets(
    Source source,
    int offset, [
    int length = 0,
  ]) {
    final start = source.getLineAndColumn(offset);
    final end = source.getLineAndColumn(offset + length);
    return SourceLocation(
      source: source,
      offset: offset,
      length: length,
      line: start.line,
      column: start.column,
      endLine: end.line,
      endColumn: end.column,
    );
  }

  /// Constructs a 0-length point location at [offset].
  factory SourceLocation.point(Source source, int offset) {
    return SourceLocation.fromOffsets(source, offset, 0);
  }

  /// Constructs a synthetic location for generated or builtin code.
  factory SourceLocation.synthetic(Source source) {
    return SourceLocation(
      source: source,
      offset: 0,
      length: 0,
      line: 1,
      column: 1,
      endLine: 1,
      endColumn: 1,
    );
  }

  /// Constructs a location at a specific [line] and optional [column].
  factory SourceLocation.at(int line, [int column = 1, Source? source]) {
    final src = source ?? Source.memory('');
    return SourceLocation(
      source: src,
      offset: 0,
      length: 0,
      line: line,
      column: column,
      endLine: line,
      endColumn: column,
    );
  }

  /// Returns the text slice spanned by this location.
  String get text => source.slice(offset, offset + length);

  /// Combines this location and [other] into a single bounding location
  /// spanning from the earliest start to the latest end.
  ///
  /// Throws [ArgumentError] if [other] belongs to a different [Source].
  SourceLocation merge(SourceLocation other) {
    if (source != other.source) {
      throw ArgumentError('Cannot merge locations from different sources');
    }

    final startOffset = math.min(offset, other.offset);
    final endOffset = math.max(offset + length, other.offset + other.length);
    final totalLength = endOffset - startOffset;

    return SourceLocation.fromOffsets(source, startOffset, totalLength);
  }

  /// Formats location as `uri:line:col`.
  String toCoordinateString() => '${source.uri}:$line:$column';

  @override
  String toString() =>
      'SourceLocation(${source.uri}:$line:$column..$endLine:$endColumn, offset: $offset, len: $length)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceLocation &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          offset == other.offset &&
          length == other.length &&
          line == other.line &&
          column == other.column &&
          endLine == other.endLine &&
          endColumn == other.endColumn;

  @override
  int get hashCode =>
      Object.hash(source, offset, length, line, column, endLine, endColumn);
}
