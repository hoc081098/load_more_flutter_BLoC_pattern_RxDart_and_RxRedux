import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:load_more_flutter/pages/rx_redux/bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rx_redux/rx_redux.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: close_sinks

/// BLoC + RxRedux = ❤️
/// pagination list BLoC, using rx_redux package
class PeopleRxReduxBloc {
  static const tag = '[PEOPLE_RX_REDUX_BLOC]';

  /// Input [Function]s
  final Future<void> Function() refresh;
  final void Function() loadFirstPage;
  final void Function() loadNextPage;
  final void Function() retryFirstPage;
  final void Function() retryNextPage;

  /// Output [Stream]s
  final ValueStream<PeopleListState> peopleList$;
  final Stream<Message> message$;

  /// Clean up: close controller, cancel subscription
  final void Function() dispose;

  PeopleRxReduxBloc._({
    @required this.refresh,
    @required this.loadFirstPage,
    @required this.loadNextPage,
    @required this.peopleList$,
    @required this.message$,
    @required this.dispose,
    @required this.retryFirstPage,
    @required this.retryNextPage,
  });

  factory PeopleRxReduxBloc(PeopleEffects effects) {
    /// Subjects
    final actionS = PublishSubject<Action>();

    /// Use package pages.rx_redux to transform actions stream to state stream
    final initialState = PeopleListState.initial();

    /// Broadcast, distinct until changed, value observable
    final state$ = actionS.reduxStore<PeopleListState>(
      reducer: (state, action) => action.reducer(state),
      initialStateSupplier: () => initialState,
      sideEffects: [
        effects.loadFirstPageEffect,
        effects.loadNextPageEffect,
        effects.refreshListEffect,
        effects.retryLoadFirstPageEffect,
        effects.retryLoadNextPageEffect,
      ],
    ).publishValueSeededDistinct(seedValue: initialState);

    final subscriptions = [
      /// Listen streams
      state$.listen((state) => print('$tag [STATE] = $state')),
      effects.message$.listen((message) => print('$tag [MESSAGE] = $message')),

      /// Connect [ConnectableObservable]
      state$.connect(),
    ];

    /// Dispatch an [action]
    void Function() dispatch(Action action) => () => actionS.add(action);

    return PeopleRxReduxBloc._(
      dispose: () async {
        await DisposeBag([...subscriptions, actionS]).dispose();
        await effects.dispose();
        print('$tag [DISPOSED]');
      },
      loadFirstPage: dispatch(const LoadFirstPageAction()),
      loadNextPage: dispatch(const LoadNextPageAction()),
      retryNextPage: dispatch(const RetryNextPageAction()),
      peopleList$: state$,
      refresh: () {
        final completer = Completer<void>();
        dispatch(RefreshListAction(completer))();
        return completer.future;
      },
      message$: effects.message$,
      retryFirstPage: dispatch(const RetryFirstPageAction()),
    );
  }
}
