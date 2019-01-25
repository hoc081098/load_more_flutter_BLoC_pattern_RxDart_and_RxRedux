import 'dart:convert';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/people_data_source.dart';
import 'package:load_more_flutter/model/person.dart';

///
/// An implementation of [PeopleDataSource], used to test when having no internet connection
///

class MemoryPersonDataSource implements PeopleDataSource {
  final BuildContext _context;

  ///
  ///
  ///
  int _page = 0;
  bool _hasError = false;
  bool _done = false;

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
      _page = 0;
      _done = _hasError = false;
    } else {
      ++_page;
    }
    if (_page == 3) {
      if (Random().nextBool()) {
        _done = true;
      } else {
        _hasError = true;
      }
    }
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
