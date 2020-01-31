import 'package:load_more_flutter/data/comics/comic_repository_impl.dart';

void main() async {
  final comicsRepo = ComicsRepositoryImpl();
  final list = await Future.wait([
    comicsRepo.getMostViewedComics(),
    comicsRepo.getNewestComics(),
    comicsRepo.getUpdatedComics(),
  ]);
  list.map((l) => l.length).forEach(print);
}
