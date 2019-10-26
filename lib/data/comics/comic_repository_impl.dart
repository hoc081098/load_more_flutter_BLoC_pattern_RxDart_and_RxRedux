import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart' as http;
import 'package:load_more_flutter/data/comics/comics_repository.dart';
import 'package:load_more_flutter/data/model/comic.dart';

class ComicsRepositoryImpl implements ComicsRepository {
  const ComicsRepositoryImpl();

  @override
  Future<BuiltList<Comic>> getMostViewedComics({int page}) =>
      _getComics('/most_viewed_comics', page);

  @override
  Future<BuiltList<Comic>> getNewestComics({int page}) =>
      _getComics('/newest_comics', page);

  @override
  Future<BuiltList<Comic>> getUpdatedComics({int page}) =>
      _getComics('/updated_comics', page);

  Future<BuiltList<Comic>> _getComics(String unencodedPath, int page) async {
    print('[COMICS_REPO] _getComics $unencodedPath, $page');

    final url = Uri.https(
      'comic-app-081098.herokuapp.com',
      unencodedPath,
      {'page': page.toString()},
    );
    final response = await http.get(url);
    final decoded = json.decode(response.body);

    if (response.statusCode != HttpStatus.ok) {
      throw ErrorResponse.fromJson(decoded);
    }

    return BuiltList.of(
      (decoded as List)
          .cast<Map<String, dynamic>>()
          .map((json) => Comic.fromJson(json)),
    );
  }
}
