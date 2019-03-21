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
    final refreshController = PublishSubject<void>();
    final retryController = PublishSubject<void>();

    ///
    /// Completer emit done event when refresh list
    ///
    Completer<void> completer;

    ///
    /// Streams
    ///

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
          .map((state) => Tuple2(state, false))
          .doOnData((_) => print('[ACTION] Load')),
      refreshController.stream
          .map((_) => Tuple2(state$.value, true))
          .doOnData((_) => print('[ACTION] Refresh')),
      retryController.stream
          .map((_) => Tuple2(state$.value, false))
          .doOnData((_) => print('[ACTION] Retry')),
    ]);

    ///
    /// Transform actions stream to state stream
    ///
    state$ = DistinctValueConnectableObservable.seeded(
      allActions$
          .switchMap((tuple) => _fetchData(tuple, peopleDataSource, completer)),
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
      state$.listen((state) {
        print(
            '[STATE] state={loading: ${state.isLoading}, error: ${state.error},'
            ' done: ${state.getAllPeople}, length: ${state.people.length}}');
      }),
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
        _completeCompleter(completer);

        completer = Completer();
        refreshController.add(null);
        return completer.future;
      },
      retry: () => retryController.add(null),
    );
  }

  static Observable<PeopleListState> _fetchData(
    Tuple2<PeopleListState, bool> tuple,
    PeopleDataSource peopleDataSource,
    Completer<void> completer,
  ) {
    final currentState = tuple.item1;
    final refresh = tuple.item2;

    final getPeople = peopleDataSource.getPeople(
      field: 'name',
      limit: pageSize,
      startAfter: refresh ? null : lastOrNull(currentState.people),
    );

    PeopleListState toListState(BuiltList<Person> people) {
      final listBuilder = currentState.people.toBuilder()
        ..update((b) {
          if (refresh) {
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

    return Observable.fromFuture(getPeople)
        .doOnEach((void _) {
          if (refresh) {
            _completeCompleter(completer);
          }
        })
        .map(toListState)
        .startWith(loadingState)
        .onErrorReturnWith(toErrorState);
  }
}

T lastOrNull<T>(Iterable<T> list) {
  if (list.isEmpty) return null;
  return list.last;
}

void _completeCompleter(Completer<void> completer) {
  try {
    if (completer != null && !completer.isCompleted) {
      completer?.complete();
    }
  } on StateError catch (e) {
    print(e);
  }
}
