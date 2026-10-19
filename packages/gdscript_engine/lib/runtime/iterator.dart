import '../core/gdscript_error.dart';
import 'value.dart';

/// Base interface for iterators used by the GDScript Virtual Machine in `for` loops.
abstract class GDIterator {
  /// Advances to the next element. Returns true if there is a next element,
  /// or false if iteration has reached the end.
  bool moveNext();

  /// Gets the current element in iteration.
  GDValue get current;
}

/// Iterator over a [GDArray].
class GDArrayIterator implements GDIterator {
  final GDArray array;
  int _index = -1;

  GDArrayIterator(this.array);

  @override
  bool moveNext() {
    _index++;
    return _index < array.elements.length;
  }

  @override
  GDValue get current {
    if (_index < 0 || _index >= array.elements.length) {
      throw GDRuntimeError('Iterator index $_index out of bounds.');
    }
    return array.elements[_index];
  }
}

/// Iterator over keys in a [GDDictionary].
class GDDictionaryIterator implements GDIterator {
  final GDDictionary dictionary;
  late final List<GDValue> _keys = dictionary.elements.keys.toList();
  int _index = -1;

  GDDictionaryIterator(this.dictionary);

  @override
  bool moveNext() {
    _index++;
    return _index < _keys.length;
  }

  @override
  GDValue get current {
    if (_index < 0 || _index >= _keys.length) {
      throw GDRuntimeError('Iterator index $_index out of bounds.');
    }
    return _keys[_index];
  }
}

/// Iterator over characters in a [GDString].
class GDStringIterator implements GDIterator {
  final GDString string;
  int _index = -1;

  GDStringIterator(this.string);

  @override
  bool moveNext() {
    _index++;
    return _index < string.value.length;
  }

  @override
  GDValue get current {
    if (_index < 0 || _index >= string.value.length) {
      throw GDRuntimeError('Iterator index $_index out of bounds.');
    }
    return GDString(string.value[_index]);
  }
}

/// Iterator over a numeric range `range(start, end, step)`.
class GDRangeIterator implements GDIterator {
  final int start;
  final int end;
  final int step;
  int _current;
  bool _started = false;

  GDRangeIterator(this.start, this.end, [this.step = 1]) : _current = start {
    if (step == 0) {
      throw GDRuntimeError('range() step cannot be zero.');
    }
  }

  @override
  bool moveNext() {
    if (!_started) {
      _started = true;
      return step > 0 ? _current < end : _current > end;
    }
    _current += step;
    return step > 0 ? _current < end : _current > end;
  }

  @override
  GDValue get current => GDInt(_current);
}

/// Creates an appropriate [GDIterator] for any iterable [GDValue].
GDIterator createGDIterator(GDValue value) {
  if (value is GDArray) {
    return GDArrayIterator(value);
  }
  if (value is GDDictionary) {
    return GDDictionaryIterator(value);
  }
  if (value is GDString) {
    return GDStringIterator(value);
  }
  if (value is GDInt) {
    return GDRangeIterator(0, value.value, 1);
  }
  if (value is GDIteratorValue && value.iterator is GDIterator) {
    return value.iterator as GDIterator;
  }
  throw GDRuntimeError(
    'Cannot iterate over value of type "${value.typeName}".',
  );
}
