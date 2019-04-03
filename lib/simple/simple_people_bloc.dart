import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:load_more_flutter/data/people_data_source.dart';
import 'package:load_more_flutter/model/person.dart';
import 'package:load_more_flutter/simple/people_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// ignore_for_file: close_sinks

const int pageSize = 10;

///
/// Simple version of BLoC, pagination list
///

class SimplePeopleBloc {
  ///
  /// Input [Function]s
  ///
  final Future<void> Function() refresh;
  final void Function() load;
  final void Function() retry;

  ///
  /// Output [Stream]s
  ///
  final ValueObservable<PeopleListState> peopleList$;
  final Stream<Message> message$;

  ///
  /// Clean up: close controller, cancel subscription
  ///
  final void Function() dispose;

  SimplePeopleBloc._({
    @required this.refresh,
    @required this.load,
    @required this.peopleList$,
    @required this.message$,
    @required this.dispose,
    @required this.retry,
  });

  ///
  /// Use factory constructor to reduce number fields of class
  ///
  factory SimplePeopleBloc(PeopleDataSource peopleDataSource) {
    assert(peopleDataSource != null);

    ///
    /// Controllers
    ///
    final loadController = PublishSubject<void>();
    final refreshController = PublishSubject<Completer<void>>();
    final retryController = PublishSubject<void>();

    ///
    /// State stream
    ///
    DistinctValueConnectableObservable<PeopleListState> state$;

    ///
    /// All actions stream
    ///
    final allActions$ = Observable.merge([
      loadController.stream
          .throttle(Duration(milliseconds: 500))
          .map((_) => state$.value)
          .where((state) => state.error == null && !state.isLoading)
          .map((state) => Tuple3(state, false, null))
          .doOnData((_) => print('[ACTION] Load')),
      refreshController.stream
          .map((completer) => Tuple3(state$.value, true, completer))
          .doOnData((_) => print('[ACTION] Refresh')),
      retryController.stream
          .map((_) => Tuple3(state$.value, false, null))
          .doOnData((_) => print('[ACTION] Retry')),
    ]);

    ///
    /// Transform actions stream to state stream
    ///
    state$ = publishValueSeededDistinct(
      allActions$.switchMap((tuple) => _fetchData(tuple, peopleDataSource)),
      seedValue: PeopleListState.initial(),
    );

    final message$ = Observable.merge([
      state$
          .map((state) => state.error)
          .where((error) => error != null)
          .map((error) => ErrorMessage(error)),
      state$
          .map((state) => state.getAllPeople)
          .where((getAll) => getAll)
          .map((_) => const LoadAllPeopleMessage()),
    ]).share();

    ///
    /// Subscriptions and controllers
    ///
    final subscriptions = <StreamSubscription>[
      state$.listen((state) => print('[STATE] $state')),
      state$.connect(),
    ];
    final controllers = <StreamController>[
      loadController,
      refreshController,
    ];

    return SimplePeopleBloc._(
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      load: () => loadController.add(null),
      message$: message$,
      peopleList$: state$,
      refresh: () {
        final completer = Completer<void>();
        refreshController.add(completer);
        return completer.future;
      },
      retry: () => retryController.add(null),
    );
  }

  static Observable<PeopleListState> _fetchData(
    Tuple3<PeopleListState, bool, Completer<void>> tuple,
    PeopleDataSource peopleDataSource,
  ) {
    final currentState = tuple.item1;
    final refreshList = tuple.item2;
    final completer = tuple.item3;

    ///
    ///
    ///

    final getPeople = peopleDataSource.getPeople(
      field: 'name',
      limit: pageSize,
      startAfter: refreshList ? null : lastOrNull(currentState.people),
    );

    PeopleListState toListState(BuiltList<Person> people) {
      final listBuilder = currentState.people.toBuilder()
        ..update((b) {
          if (refreshList) {
            b.clear();
          }
          b.addAll(people);
        });

      return PeopleListState((b) => b
        ..error = null
        ..isLoading = false
        ..people = listBuilder
        ..getAllPeople = people.isEmpty);
    }

    PeopleListState toErrorState(dynamic e) {
      return currentState.rebuild((b) => b
        ..error = e
        ..getAllPeople = false
        ..isLoading = false);
    }

    final loadingState = currentState.rebuild((b) => b
      ..isLoading = true
      ..getAllPeople = false
      ..error = null);

    ///
    ///
    ///

    return Observable.fromFuture(getPeople)
        .map(toListState)
        .startWith(loadingState)
        .onErrorReturnWith(toErrorState)
        .doOnDone(() => completer?.complete());
  }
}

///
/// Returns the last element if [list] is not empty, otherwise return null
///
T lastOrNull<T>(Iterable<T> list) => list.isNotEmpty ? list.last : null;
