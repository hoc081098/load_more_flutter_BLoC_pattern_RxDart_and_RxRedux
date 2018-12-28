import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/people_data_source.dart';
import 'package:load_more_flutter/model/person.dart';

///
/// An implementation of [PeopleDataSource], used to test when having no internet connection
///

class MemoryPersonDataSource implements PeopleDataSource {
  final BuildContext _context;
  int _page = 0;

  MemoryPersonDataSource({@required context})
      : assert(context != null),
        _context = context;

  @override
  Future<List<Person>> getPeople({
    @required int limit,
    @required String field,
    Person startAfter,
  }) async {
    // test error
    if (startAfter == null) {
      _page = 0;
    } else {
      ++_page;
    }

    if (_page == 3) {
      // test error
      await Future.delayed(Duration(seconds: 2));
      throw StateError('Random error :)');
    }

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

    //wait to test
    if (_page > 0) {
      await Future.delayed(Duration(seconds: 2));
    }

    if (startAfter == null) {
      return list.take(limit).toList();
    } else {
      return list.skipWhile((p) => p == startAfter).take(limit).toList();
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
