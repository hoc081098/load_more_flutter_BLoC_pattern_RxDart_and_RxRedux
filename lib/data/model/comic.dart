import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:load_more_flutter/data/model/serializers.dart';

part 'comic.g.dart';

abstract class ErrorResponse
    implements Built<ErrorResponse, ErrorResponseBuilder> {
  @BuiltValueField(wireName: 'message')
  String get message; // An error occurred: 'NotFoundError: Not Found'

  @BuiltValueField(wireName: 'status_code')
  int get statusCode; // 404

  static Serializer<ErrorResponse> get serializer => _$errorResponseSerializer;

  ErrorResponse._();

  factory ErrorResponse([Function(ErrorResponseBuilder b) updates]) =
      _$ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return standardSerializers.deserializeWith<ErrorResponse>(
        ErrorResponse.serializer, json);
  }
}

abstract class LastChapter implements Built<LastChapter, LastChapterBuilder> {
  @BuiltValueField(wireName: 'chapter_link')
  String
      get chapterLink; // https://ww2.mangafox.online/volcanic-age/chapter-90-512420270425665

  @BuiltValueField(wireName: 'chapter_name')
  String get chapterName; // Chapter 90

  @BuiltValueField(wireName: 'time')
  String get time; // 2 days ago

  static Serializer<LastChapter> get serializer => _$lastChapterSerializer;

  LastChapter._();

  factory LastChapter([Function(LastChapterBuilder b) updates]) = _$LastChapter;

  factory LastChapter.fromJson(Map<String, dynamic> json) {
    return standardSerializers.deserializeWith<LastChapter>(
        LastChapter.serializer, json);
  }
}

abstract class Comic implements Built<Comic, ComicBuilder> {
  @BuiltValueField(wireName: 'last_chapters')
  BuiltList<LastChapter> get lastChapters;

  @BuiltValueField(wireName: 'link')
  String get link; // https://ww2.mangafox.online/volcanic-age

  @BuiltValueField(wireName: 'thumbnail')
  String
      get thumbnail; // https://cdn1.mangafox.online/132/857/695/330/341/5/volcanic-age.jpg

  @BuiltValueField(wireName: 'title')
  String get title; // Volcanic Age

  @BuiltValueField(wireName: 'view')
  String get view; // 1.1k

  static Serializer<Comic> get serializer => _$comicSerializer;

  Comic._();

  factory Comic([Function(ComicBuilder b) updates]) = _$Comic;

  factory Comic.fromJson(Map<String, dynamic> json) {
    return standardSerializers.deserializeWith<Comic>(Comic.serializer, json);
  }
}
