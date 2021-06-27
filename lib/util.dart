import 'dart:async';

import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

extension LastOrNullExt<T> on Iterable<T> {
  ///
  /// Returns the last element if this iterable is not empty, otherwise return null
  ///
  T get lastOrNull => isNotEmpty ? last : null;
}

extension ShowSnackBarBuildContextExtension on BuildContext {
  void showSnackBar(
    String message, [
    Duration duration = const Duration(seconds: 2),
  ]) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
}

extension MapNotNullStreamExt<T> on Stream<T> {
  Stream<R> mapNotNull<R>(R Function(T) mapper) {
    return transform(
      StreamTransformer<T, R>.fromHandlers(
        handleData: (data, sink) {
          final mapped = mapper(data);
          if (mapped != null) {
            sink.add(mapped);
          }
        },
        handleError: (e, st, sink) => sink.addError(e, st),
        handleDone: (sink) => sink.close(),
      ),
    );
  }
}

extension ScrollPositionStreamExt on ScrollController {
  Stream<ScrollController> scroll$() {
    StreamController<ScrollController> controller;
    VoidCallback listener;

    controller = StreamController<ScrollController>(
      sync: true,
      onListen: () => addListener(listener = () => controller.add(this)),
      onCancel: () {
        try {
          removeListener(listener);
          listener = null;
        } catch (_) {}
      },
    );

    return controller.stream;
  }

  Stream<void> nearBottomEdge$(num offsetVisibleThreshold) => scroll$()
      .debounceTime(const Duration(milliseconds: 100))
      .mapNotNull((sc) => sc.hasClients
          ? sc.offset + offsetVisibleThreshold >= sc.position.maxScrollExtent
          : null);
}

int _indentingBuiltValueToStringHelperIndent = 0;

class CustomIndentingBuiltValueToStringHelper
    implements BuiltValueToStringHelper {
  StringBuffer _result = StringBuffer();

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
