import 'package:built_collection/built_collection.dart';
import 'package:load_more_flutter/data/model/comic.dart';

abstract class ComicsRepository {
  Future<BuiltList<Comic>> getUpdatedComics({int page = 1});

  Future<BuiltList<Comic>> getMostViewedComics({int page = 1});

  Future<BuiltList<Comic>> getNewestComics({int page = 1});
}
