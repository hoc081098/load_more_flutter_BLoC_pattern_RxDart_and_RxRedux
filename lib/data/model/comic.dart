import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:load_more_flutter/data/model/serializers.dart';

part 'comic.g.dart';

abstract class Comic implements Built<Comic, ComicBuilder> {
  String get link;

  static Serializer<Comic> get serializer => _$comicSerializer;

  Comic._();

  factory Comic([updates(ComicBuilder b)]) = _$Comic;

  factory Comic.fromJson(Map<String, dynamic> json) {
    return standardSerializers.deserializeWith<Comic>(Comic.serializer, json);
  }
}
