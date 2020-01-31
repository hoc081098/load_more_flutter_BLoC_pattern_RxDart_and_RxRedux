import 'package:built_collection/built_collection.dart';
import 'package:load_more_flutter/data/comics/comics_repository.dart';
import 'package:load_more_flutter/data/model/comic.dart';

abstract class GetComicsUseCase {
  Stream<BuiltList<Comic>> call(int page);
}

class GetNewestComicsUseCase implements GetComicsUseCase {
  final ComicsRepository _comicRepo;

  GetNewestComicsUseCase(this._comicRepo);

  @override
  Stream<BuiltList<Comic>> call(int page) async* {
    yield await _comicRepo.getNewestComics(page: page);
  }
}

class GetMostViewedComicsUseCase implements GetComicsUseCase {
  final ComicsRepository _comicRepo;

  GetMostViewedComicsUseCase(this._comicRepo);

  @override
  Stream<BuiltList<Comic>> call(int page) async* {
    yield await _comicRepo.getMostViewedComics(page: page);
  }
}

class GetUpdatedComicsUseCase implements GetComicsUseCase {
  final ComicsRepository _comicRepo;

  GetUpdatedComicsUseCase(this._comicRepo);

  @override
  Stream<BuiltList<Comic>> call(int page) async* {
    yield await _comicRepo.getUpdatedComics(page: page);
  }
}
