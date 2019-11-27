import 'package:built_value/built_value.dart';

extension LastOrNullExt<T> on Iterable<T> {
  ///
  /// Returns the last element if this iterable is not empty, otherwise return null
  ///
  T get lastOrNull => isNotEmpty ? last : null;
}


int _indentingBuiltValueToStringHelperIndent = 0;

class CustomIndentingBuiltValueToStringHelper
    implements BuiltValueToStringHelper {
  StringBuffer _result = new StringBuffer();

  CustomIndentingBuiltValueToStringHelper(String className) {
    _result..write(className)..write(' {\n');
    _indentingBuiltValueToStringHelperIndent += 2;
  }

  @override
  void add(String field, Object value) {
    if (value != null) {
      _result
        ..write(' ' * _indentingBuiltValueToStringHelperIndent)
        ..write(value is Iterable ? '$field.length' : field)
        ..write('=')
        ..write(value is Iterable ? value.length : value)
        ..write(',\n');
    }
  }

  @override
  String toString() {
    _indentingBuiltValueToStringHelperIndent -= 2;
    _result..write(' ' * _indentingBuiltValueToStringHelperIndent)..write('}');
    final stringResult = _result.toString();
    _result = null;
    return stringResult;
  }
}
