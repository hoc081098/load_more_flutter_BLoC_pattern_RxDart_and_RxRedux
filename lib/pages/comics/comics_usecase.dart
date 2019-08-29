import 'package:built_collection/built_collection.dart';
import 'package:load_more_flutter/data/comics/comics_repository.dart';
import 'package:load_more_flutter/data/model/comic.dart';

abstract class GetComicsUseCase {
  Future<BuiltList<Comic>> getComics(int page);
}

class GetNewestComicsUseCase implements GetComicsUseCase {
  final ComicsRepository _comicRepo;

  GetNewestComicsUseCase(this._comicRepo);

  @override
  Future<BuiltList<Comic>> getComics(int page) =>
      _comicRepo.getNewestComics(page: page);
}

class GetMostViewedComicsUseCase implements GetComicsUseCase {
  final ComicsRepository _comicRepo;

  GetMostViewedComicsUseCase(this._comicRepo);

  @override
  Future<BuiltList<Comic>> getComics(int page) =>
      _comicRepo.getMostViewedComics(page: page);
}

class GetUpdatedComicsUseCase implements GetComicsUseCase {
  final ComicsRepository _comicRepo;

  GetUpdatedComicsUseCase(this._comicRepo);

  @override
  Future<BuiltList<Comic>> getComics(int page) =>
      _comicRepo.getUpdatedComics(page: page);
}
