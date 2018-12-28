import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:load_more_flutter/data/people_data_source.dart';
import 'package:load_more_flutter/model/person.dart';
import 'package:meta/meta.dart';

///
/// An implementation of [PeopleDataSource], load 'people' collection from cloud [Firestore]
///

class PeopleApi implements PeopleDataSource {
  final _firestore = Firestore.instance;

  @override
  Future<List<Person>> getPeople({
    @required int limit,
    @required String field,
    Person startAfter,
  }) async {
    var query = _firestore.collection('people').orderBy(field);
    if (startAfter != null) {
      query = query.startAfter([startAfter.name]);
    }
    final documents = (await query.limit(limit).getDocuments()).documents;
    print(documents);

    //wait to test
    await Future.delayed(Duration(seconds: 2));

    return documents
        .map(
          (snapshot) => Person.fromJson(
                CombinedMapView(
                  [
                    {'id': snapshot.documentID},
                    snapshot.data,
                  ],
                ),
              ),
        )
        .toList();
  }
}
