import 'package:built_collection/built_collection.dart';
import 'package:load_more_flutter/data/model/comic.dart';
import 'package:meta/meta.dart';

abstract class ComicsRepository {
  Future<BuiltList<Comic>> getUpdatedComics({@required int page});

  Future<BuiltList<Comic>> getMostViewedComics({@required int page});

  Future<BuiltList<Comic>> getNewestComics({@required int page});
}
