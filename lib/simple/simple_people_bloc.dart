import 'dart:async';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:load_more_flutter/simple/people_interactor.dart';
import 'package:load_more_flutter/simple/people_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// ignore_for_file: close_sinks

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
  factory SimplePeopleBloc(final PeopleInteractor peopleInteractor) {
    assert(peopleInteractor != null, 'peopleInteractor cannot be null');

    ///
    /// Stream controllers
    ///
    final loadController = PublishSubject<void>();
    final refreshController = PublishSubject<Completer<void>>();
    final retryController = PublishSubject<void>();
    final messageController = PublishSubject<Message>();

    ///
    /// State stream
    ///
    DistinctValueConnectableObservable<PeopleListState> state$;

    ///
    /// All actions stream
    ///
    final allActions$ = Observable.merge([
      loadController.stream
          .throttleTime(Duration(milliseconds: 500))
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
      allActions$.switchMap(
          (tuple) => peopleInteractor.fetchData(tuple, messageController)),
      seedValue: PeopleListState.initial(),
    );

    ///
    /// Keep subscriptions and controllers references to dispose later
    ///
    final subscriptions = <StreamSubscription>[
      state$.listen((state) => print('[STATE] $state')),
      state$.connect(),
    ];
    final controllers = <StreamController>[
      loadController,
      refreshController,
      retryController,
      messageController,
    ];

    return SimplePeopleBloc._(
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      load: () => loadController.add(null),
      message$: messageController.stream,
      peopleList$: state$,
      refresh: () {
        final completer = Completer<void>();
        refreshController.add(completer);
        return completer.future;
      },
      retry: () => retryController.add(null),
    );
  }
}
