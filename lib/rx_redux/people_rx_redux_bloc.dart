import 'dart:async';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:load_more_flutter/rx_redux/people_interactor.dart';
import 'package:load_more_flutter/rx_redux/people_state.dart';
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

  factory PeopleRxReduxBloc(PeopleInteractor interactor) {
    final actionSubject = PublishSubject<Action>();

    final state$ = reduxStore<PeopleListState, Action>(
      actions: actionSubject
          .doOnData((action) => print('$tag Input action = $action')),
      initialStateSupplier: () => PeopleListState.initial(),
      reducer: _reducer,
      sideEffects: [
        interactor.loadFirstPageEffect,
        interactor.loadNextPageEffect,
        interactor.refreshListEffect,
        interactor.retryLoadFirstPageEffect,
        interactor.retryLoadNextPageEffect,
      ],
    );

    final stateDistinct$ = publishValueSeededDistinct(
      state$,
      seedValue: PeopleListState.initial(),
    );

    final subscriptions = <StreamSubscription>[
      stateDistinct$.listen((state) => print('$tag state = $state')),
      stateDistinct$.connect(),
    ];

    return PeopleRxReduxBloc._(
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await actionSubject.close();
        print('$tag disposed');
      },
      loadFirstPage: () => actionSubject.add(const LoadFirstPageAction()),
      loadNextPage: () => actionSubject.add(const LoadNextPageAction()),
      retryNextPage: () => actionSubject.add(const RetryNextPageAction()),
      peopleList$: state$,
      refresh: () {
        final completer = Completer<void>();
        actionSubject.add(RefreshListAction(completer));
        return completer.future;
      },
      message$: null,
      retryFirstPage: () => actionSubject.add(const RetryFirstPageAction()),
    );
  }

  static PeopleListState _reducer(PeopleListState state, Action action) {}
}
