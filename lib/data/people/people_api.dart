import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:load_more_flutter/data/model/person.dart';
import 'package:load_more_flutter/data/model/serializers.dart';
import 'package:load_more_flutter/data/people/people_data_source.dart';
import 'package:meta/meta.dart';

///
/// An implementation of [PeopleDataSource], load 'people' collection from cloud [FirebaseFirestore]
///
class PeopleApi implements PeopleDataSource {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<BuiltList<Person>> getPeople({
    @required int limit,
    @required String field,
    Person startAfter,
  }) async {
    var query = _firestore.collection('people').orderBy(field);
    if (startAfter != null) {
      query = query.startAfter([startAfter.name]);
    }
    final documents = (await query.limit(limit).get()).docs;

    //wait to test
    await Future.delayed(Duration(seconds: 2));

    final json = documents.map((snapshot) => CombinedMapView([
          {'id': snapshot.id},
          snapshot.data()
        ]));
    return standardSerializers.deserialize(
      json,
      specifiedType: const FullType(BuiltList, [FullType(Person)]),
    ) as BuiltList<Person>;
  }
}
