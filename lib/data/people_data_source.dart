import 'package:load_more_flutter/model/person.dart';
import 'package:meta/meta.dart';

import 'package:built_collection/built_collection.dart';

abstract class PeopleDataSource {
  Future<BuiltList<Person>> getPeople({
    @required int limit,
    @required String field,
    Person startAfter,
  });
}
