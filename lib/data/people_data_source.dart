import 'package:load_more_flutter/model/person.dart';
import 'package:meta/meta.dart';

abstract class PeopleDataSource {
  Future<List<Person>> getPeople({
    @required int limit,
    @required String field,
    Person startAfter,
  });
}
