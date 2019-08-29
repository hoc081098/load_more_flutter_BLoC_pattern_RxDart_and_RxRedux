import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/model/person.dart';
import 'package:load_more_flutter/data/people/people_data_source.dart';

///
/// An implementation of [PeopleDataSource], used to test when having no internet connection
///

class MemoryPersonDataSource implements PeopleDataSource {
  final BuildContext _context;

  ///
  ///
  ///
  bool _hasError = false;
  bool _done = false;
  int _count = 0;
  bool _doneOrError = true;
  bool f = true;

  ///
  ///
  ///

  MemoryPersonDataSource({@required context})
      : assert(context != null),
        _context = context;

  @override
  Future<BuiltList<Person>> getPeople({
    @required int limit,
    @required String field,
    Person startAfter,
  }) async {
    await Future.delayed(Duration(seconds: 2));

    if (startAfter == null && f) {
      f = !f;
      throw StateError('[DEBUG] Random error :)');
    }

    _increasePageAndRandomErrorOrDone(startAfter);

    if (_done) {
      return BuiltList.of([]);
    }
    if (_hasError) {
      throw StateError('[DEBUG] Random error :)');
    }

    return _actual(field, startAfter, limit);
  }

  Future<BuiltList<Person>> _actual(
    String field,
    Person startAfter,
    int limit,
  ) async {
    final list = await (DefaultAssetBundle.of(_context).loadStructuredData(
      'assets/json/people.json',
      (value) => compute(
        _parseJson,
        <String, String>{
          'jsonString': value,
          'field': field,
        },
      ),
    ));

    if (startAfter == null) {
      return BuiltList.of(list.take(limit).toList());
    } else {
      return BuiltList.of(
        list.skipWhile((p) => p == startAfter).take(limit).toList(),
      );
    }
  }

  void _increasePageAndRandomErrorOrDone(Person startAfter) {
    if (startAfter == null) {
      _count = 0;
      _done = _hasError = false;
    } else {
      ++_count;
    }

    if (_count == 3) {
      if (_doneOrError) {
        _done = true;
        _hasError = false;
      } else {
        _hasError = true;
        _done = false;
      }
      _doneOrError = !_doneOrError;
    } else {
      _done = _hasError = false;
    }

    print('[DEBUG] count=$_count, hasError=$_hasError, done=$_done');
  }
}

List<Person> _parseJson(Map<String, dynamic> input) {
  final field = input['field'];
  final jsonString = input['jsonString'];

  final list = (json.decode(jsonString) as Iterable)
      .cast<Map<String, dynamic>>()
      .toList()
        ..sort((l, r) => l[field].compareTo(r[field]));
  return list.map((json) => Person.fromJson(json)).toList();
}
