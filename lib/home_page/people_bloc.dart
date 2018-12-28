import 'dart:async';
import 'dart:collection' show UnmodifiableListView;

import 'package:collection/collection.dart' show ListEquality;
import 'package:load_more_flutter/data/people_data_source.dart';
import 'package:load_more_flutter/model/person.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const int pageSize = 10;

///
///
///

@immutable
class PeopleListState {
  final UnmodifiableListView<Person> people;
  final bool isLoading;
  final Object error;

  const PeopleListState({
    @required this.people,
    @required this.isLoading,
    @required this.error,
  });

  factory PeopleListState.initial() => PeopleListState(
        isLoading: false,
        people: UnmodifiableListView(<Person>[]),
        error: null,
      );

  PeopleListState copyWith({
    List<Person> people,
    bool isLoading,
    Object error,
  }) =>
      PeopleListState(
        error: error,
        people: people != null ? UnmodifiableListView(people) : this.people,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeopleListState &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(people, other.people) &&
          isLoading == other.isLoading;

  @override
  int get hashCode => people.hashCode ^ isLoading.hashCode;

  @override
  String toString() =>
      'PeopleListState(people.length=${people.length}, isLoading=$isLoading, error=$error)';
}

///
///
///

class PeopleBloc {
  final PeopleDataSource _peopleDataSource;
  final _loadAllController = PublishSubject<void>();
  final _errorController = PublishSubject<Object>();
  final _loadMoreController = PublishSubject<void>();
  final _peopleListController =
      BehaviorSubject<PeopleListState>(seedValue: PeopleListState.initial());

  Sink<void> get loadMore => _loadMoreController.sink;

  Stream<PeopleListState> get peopleList => _peopleListController.stream;

  Stream<void> get loadedAllPeople => _loadAllController.stream;

  Stream<Object> get error => _errorController.stream;

  PeopleBloc(this._peopleDataSource) : assert(_peopleDataSource != null) {
    _loadMoreController
        .throttle(Duration(milliseconds: 500))
        .doOnData((_) => print('Load more emitted...'))
        .exhaustMap(_loadMoreData) // use exhaustMap operator,
        // to ignore all value source emit,
        // while loading data from api
        .distinct()
        .doOnData((state) => print('state = $state'))
        .pipe(_peopleListController);
  }

  Future<void> refresh() async {
    print('Refresh start');
    _peopleListController.add(PeopleListState.initial());

    final states = await _loadMoreData(null).toList();
    print('State refresh: $states');

    await Future.delayed(Duration(seconds: 2));
    print('Refresh done');
  }

  Stream<PeopleListState> _loadMoreData(void _) async* {
    // get latest state
    final latestState = _peopleListController.value;
    print('latestState=$latestState');
    if (latestState.error != null || latestState.isLoading) {
      return;
    }
    final currentList = latestState.people;
    // emit loading state
    yield latestState.copyWith(isLoading: true);

    try {
      // fetch page from api
      final page = await _peopleDataSource.getPeople(
        limit: pageSize,
        field: 'name',
        startAfter: currentList.isNotEmpty ? currentList.last : null,
      );

      if (page.isEmpty) {
        // if page is empty, emit all paged loaded
        _loadAllController.add(null);

        // emit not loading
        yield latestState.copyWith(isLoading: false);
      } else {
        // emit list state
        yield latestState.copyWith(
          isLoading: false,
          error: null,
          people: <Person>[]..addAll(currentList)..addAll(page),
        );
      }
    } catch (e) {
      // if error was occurred, emit error
      _errorController.add(e);

      yield latestState.copyWith(
        isLoading: false,
        error: e,
      );
    }
  }

  Future<void> dispose() => Future.wait([
        _loadAllController.close(),
        _loadMoreController.close(),
        _peopleListController.close(),
        _errorController.close(),
      ]);
}
