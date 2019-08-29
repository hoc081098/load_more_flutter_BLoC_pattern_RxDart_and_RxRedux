import 'package:built_collection/built_collection.dart';

abstract class ComicsRepository {
  Future<BuiltList<dynamic>> getUpdatedComics({int page = 1});

  Future<BuiltList<dynamic>> getMostViewedComics({int page = 1});

  Future<BuiltList<dynamic>> getNewestComics({int page = 1});
}
