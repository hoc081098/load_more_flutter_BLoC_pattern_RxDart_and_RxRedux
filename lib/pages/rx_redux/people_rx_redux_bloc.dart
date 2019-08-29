import 'dart:async';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:load_more_flutter/pages/rx_redux/people_effects.dart';
import 'package:load_more_flutter/pages/rx_redux/people_state_action.dart';
import 'package:meta/meta.dart';
import 'package:rx_redux/rx_redux.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: close_sinks

///
/// BLoC + RxRedux => ❤️
/// pagination list BLoC, using rx_redux package
///
class PeopleRxReduxBloc {
  static const tag = '[PEOPLE_RX_REDUX_BLOC]';

  ///
  /// Input [Function]s
  ///
  final Future<void> Function() refresh;
  final void Function() loadFirstPage;
  final void Function() loadNextPage;
  final void Function() retryFirstPage;
  final void Function() retryNextPage;

  ///
  /// Output [Stream]s
  ///
  final ValueObservable<PeopleListState> peopleList$;
  final Stream<Message> message$;

  ///
  /// Clean up: close controller, cancel subscription
  ///
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
    ///
    /// Subjects
    ///
    final actionSubject = PublishSubject<Action>();

    ///
    /// Use package pages.rx_redux to transform actions stream to state stream
    ///
    final initialState = PeopleListState.initial();

    final state$ = actionSubject
        .doOnData((action) => print('$tag [INPUT_ACTION] = $action'))
        .transform(
          ReduxStoreStreamTransformer<Action, PeopleListState>(
            reducer: (state, action) => action.reducer(state),
            initialStateSupplier: () => initialState,
            sideEffects: [
              effects.loadFirstPageEffect,
              effects.loadNextPageEffect,
              effects.refreshListEffect,
              effects.retryLoadFirstPageEffect,
              effects.retryLoadNextPageEffect,
            ],
          ),
        )
        .doOnData((state) => print('$tag [REDUX_STORE_STATE] = $state'));

    ///
    /// Broadcast, distinct until changed, value observable
    ///
    final stateDistinct$ =
        publishValueSeededDistinct(state$, seedValue: initialState);

    final subscriptions = <StreamSubscription>[
      /// Listen streams
      stateDistinct$.listen((state) => print('$tag [FINAL_STATE] = $state')),
      effects.message$.listen((message) => print('$tag [MESSAGE] = $message')),

      /// Connect [ConnectableObservable]
      stateDistinct$.connect(),
    ];

    ///
    /// Dispatch an [action]
    ///
    dispatch(Action action) => () => actionSubject.add(action);

    return PeopleRxReduxBloc._(
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await actionSubject.close();
        await effects.dispose();
        print('$tag [DISPOSED]');
      },
      loadFirstPage: dispatch(const LoadFirstPageAction()),
      loadNextPage: dispatch(const LoadNextPageAction()),
      retryNextPage: dispatch(const RetryNextPageAction()),
      peopleList$: stateDistinct$,
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
