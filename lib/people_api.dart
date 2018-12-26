import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:load_more_flutter/person.dart';
import 'package:meta/meta.dart';

class PeopleApi {
  final _firestore = Firestore.instance;

  Future<List<Person>> getPeople({
    @required int limit,
    @required String field,
    startAfter,
  }) async {
    var query = _firestore.collection('people').orderBy(field);
    if (startAfter != null) {
      query = query.startAfter([startAfter]);
    }
    final documents = (await query.limit(limit).getDocuments()).documents;
    print(documents);
    return documents.map((snapshot) => Person.fromJson(snapshot.data)).toList();
  }
}
