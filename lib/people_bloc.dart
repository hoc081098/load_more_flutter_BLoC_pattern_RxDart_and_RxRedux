import 'dart:async';
import 'dart:collection' show UnmodifiableListView;

import 'package:load_more_flutter/people_api.dart';
import 'package:load_more_flutter/person.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const int pageSize = 10;

@immutable
class PeopleListState {
  final UnmodifiableListView<Person> people;
  final bool isLoading;

  const PeopleListState({
    @required this.people,
    @required this.isLoading,
  });

  factory PeopleListState.initial() => PeopleListState(
        isLoading: false,
        people: UnmodifiableListView(<Person>[]),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeopleListState &&
          runtimeType == other.runtimeType &&
          people == other.people &&
          isLoading == other.isLoading;

  @override
  int get hashCode => people.hashCode ^ isLoading.hashCode;
}

class PeopleBloc {
  final PeopleApi _api;
  final _loadAllController = PublishSubject<void>();
  final _loadMoreController = PublishSubject<void>();
  final _peopleListController =
      BehaviorSubject<PeopleListState>(seedValue: PeopleListState.initial());

  Sink<void> get loadMore => _loadMoreController.sink;

  Stream<PeopleListState> get peopleList => _peopleListController.stream;

  Stream<void> get loadedAllPeople => _loadAllController.stream;

  PeopleBloc(this._api) : assert(_api != null) {
    _loadMoreController
        .exhaustMap(_loadMoreData) // use exhaustMap operator,
        // to ignore all value source emit,
        // while loading data from api
        .distinct()
        .doOnData((state) => print('${state.isLoading} | ${state.people}'))
        .pipe(_peopleListController);
  }

  Future<void> refresh() async {
    _peopleListController.add(PeopleListState.initial());
    _loadMoreController.add(null);
    await peopleList.firstWhere(
        (state) => state != PeopleListState.initial() && !state.isLoading);
  }

  Stream<PeopleListState> _loadMoreData(void _) async* {
    // get latest state
    final currentList = _peopleListController.value.people;

    // emit loading state
    yield PeopleListState(
      isLoading: true,
      people: currentList,
    );

    // fetch page from api
    final page = await _api.getPeople(
      limit: pageSize,
      field: 'name',
      startAfter: currentList.isNotEmpty ? currentList.last.name : null,
    );

    //wait to test
    await Future.delayed(Duration(seconds: 2));

    if (page.isEmpty) {
      // if page is empty, emit all paged loaded
      _loadAllController.add(null);

      // emit not loading
      yield PeopleListState(
        isLoading: false,
        people: currentList,
      );
    } else {
      // emit list state
      yield PeopleListState(
        isLoading: false,
        people: UnmodifiableListView(
          <Person>[]..addAll(currentList)..addAll(page),
        ),
      );
    }
  }

  Future<void> dispose() => Future.wait([
        _loadAllController.close(),
        _loadMoreController.close(),
        _peopleListController.close(),
      ]);
}
