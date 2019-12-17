import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:load_more_flutter/pages/simple/people_interactor.dart';
import 'package:load_more_flutter/pages/simple/people_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// ignore_for_file: close_sinks

/// Simple version of BLoC, pagination list
class SimplePeopleBloc {
  /// Input [Function]s
  final Future<void> Function() refresh;
  final void Function() load;
  final void Function() retry;

  /// Output [Stream]s
  final ValueStream<PeopleListState> peopleList$;
  final Stream<Message> message$;

  /// Clean up: close controller, cancel subscription
  final void Function() dispose;

  SimplePeopleBloc._({
    @required this.refresh,
    @required this.load,
    @required this.peopleList$,
    @required this.message$,
    @required this.dispose,
    @required this.retry,
  });

  /// Use factory constructor to reduce number fields of class
  factory SimplePeopleBloc(final PeopleInteractor peopleInteractor) {
    assert(peopleInteractor != null, 'peopleInteractor cannot be null');

    /// Stream controllers
    final loadController = StreamController<void>();
    final refreshController = StreamController<Completer<void>>();
    final retryController = StreamController<void>();
    final messageS = PublishSubject<Message>();
    final controllers = [
      loadController,
      refreshController,
      retryController,
      messageS
    ];

    /// State stream
    DistinctValueConnectableStream<PeopleListState> state$;

    /// All actions stream
    final allActions$ = Rx.merge([
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

    /// Transform actions stream to state stream
    state$ = allActions$
        .switchMap((tuple) => peopleInteractor.fetchData(tuple, messageS))
        .publishValueSeededDistinct(seedValue: PeopleListState.initial());

    /// Keep subscriptions to cancel later
    final subscriptions = [
      state$.listen((state) => print('[STATE] $state')),
      state$.connect(),
    ];

    return SimplePeopleBloc._(
      dispose: DisposeBag([...subscriptions, ...controllers]).dispose,
      load: () => loadController.add(null),
      message$: messageS.stream,
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
