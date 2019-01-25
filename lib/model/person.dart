import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:load_more_flutter/model/serializers.dart';

part 'person.g.dart';

abstract class Person implements Built<Person, PersonBuilder> {
  String get id;

  String get emoji;

  String get name;

  String get bio;

  static Serializer<Person> get serializer => _$personSerializer;

  Person._();

  factory Person([updates(PersonBuilder b)]) = _$Person;

  factory Person.fromJson(Map<String, dynamic> json) {
    final standardSerializers =
        (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
    return standardSerializers.deserializeWith<Person>(Person.serializer, json);
  }
}
