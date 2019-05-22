import 'dart:async';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:load_more_flutter/rx_redux/people_state.dart';
import 'package:meta/meta.dart';
import 'package:rx_redux/rx_redux.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: close_sinks

///
/// BLoC pagination list using rx_redux package
///
class RxReduxPeopleBloc {
  ///
  /// Input [Function]s
  ///
  final Future<void> Function() refresh;
  final void Function() loadFirstPage;
  final void Function() loadNextPage;
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

  RxReduxPeopleBloc._({
    @required this.refresh,
    @required this.loadFirstPage,
    @required this.loadNextPage,
    @required this.peopleList$,
    @required this.message$,
    @required this.dispose,
    @required this.retry,
  });

  ///
  /// Use factory constructor to reduce number fields of class
  ///
  factory RxReduxPeopleBloc() {
    final actionSubject = PublishSubject<Action>();

    final state$ = reduxStore<PeopleListState, Action>(
      actions:
          actionSubject.doOnData((action) => print('[INPUT_ACTION] $action')),
      initialStateSupplier: () => PeopleListState.initial(),
      reducer: _reducer,
      sideEffects: [
        _loadFirstPageEffect,
        _loadNextPageEffect,
        (action, state) {
          //TODO
        },
      ],
    );

    final stateDistinct$ = publishValueSeededDistinct(
      state$,
      seedValue: PeopleListState.initial(),
    );

    ///
    /// Keep subscriptions and controllers references to dispose later
    ///
    final subscriptions = <StreamSubscription>[
      stateDistinct$.listen((state) => print('[STATE] $state')),
      stateDistinct$.connect(),
    ];

    return RxReduxPeopleBloc._(
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await actionSubject.close();
      },
      loadFirstPage: () => actionSubject.add(const LoadFirstPageAction()),
      loadNextPage: () => actionSubject.add(const LoadNextPageAction()),
      retry: () => actionSubject.add(const RetryLoadPageAction()),
      peopleList$: state$,
      refresh: () {
        final completer = Completer<void>();//TODO: need call completer.comlete somewhere
        actionSubject.add(const RefreshListAction());
        return completer.future;
      },
    );
  }

  static PeopleListState _reducer(PeopleListState state, Action action) {}

  static Observable<Action> _loadFirstPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) {}

  static Observable<Action> _loadNextPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) {}
}
