import 'dart:async';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:load_more_flutter/rx_redux/people_effects.dart';
import 'package:load_more_flutter/rx_redux/people_state_action.dart';
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
    final messageSubject = PublishSubject<Message>();

    ///
    /// Use package rx_redux to transform actions stream to state stream
    ///
    final state$ = reduxStore<PeopleListState, Action>(
      actions: actionSubject
          .doOnData((action) => print('$tag Input action = $action')),
      initialStateSupplier: () => PeopleListState.initial(),
      reducer: _reducer,
      sideEffects: [
        effects.loadFirstPageEffect,
        effects.loadNextPageEffect,
        effects.refreshListEffect,
        effects.retryLoadFirstPageEffect,
        effects.retryLoadNextPageEffect,
      ],
    ).doOnData((state) => print('$tag state from redux store = $state'));

    ///
    /// Broadcast, distinct until changed, value observable
    ///
    final stateDistinct$ = publishValueSeededDistinct(
      state$,
      seedValue: PeopleListState.initial(),
    );
    final subscriptions = <StreamSubscription>[
      stateDistinct$.listen((state) => print('$tag final state = $state')),
      stateDistinct$.connect(),
      messageSubject.listen((message) => print('$tag message = $message')),
      effects.message$.listen(messageSubject.add),
    ];

    ///
    /// Dispatch an [action]
    ///
    dispatch(Action action) => () => actionSubject.add(action);

    return PeopleRxReduxBloc._(
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait([
          actionSubject,
          messageSubject,
        ].map((s) => s.close()));
        print('$tag disposed');
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
      message$: messageSubject,
      retryFirstPage: dispatch(const RetryFirstPageAction()),
    );
  }

  static PeopleListState _reducer(PeopleListState state, Action action) {
    if (action is LoadNextPageAction ||
        action is LoadFirstPageAction ||
        action is RefreshListAction ||
        action is RetryNextPageAction ||
        action is RetryFirstPageAction) {
      return state;
    }

    if (action is PageLoadedAction) {
      if (action.isFirstPage) {
        return state.rebuild(
          (b) => b
            ..isFirstPageLoading = false
            ..firstPageError = null
            ..people = action.people.toBuilder()
            ..getAllPeople = action.people.isEmpty,
        );
      } else {
        return state.rebuild(
          (b) => b
            ..isFirstPageLoading = false
            ..firstPageError = null
            ..nextPageError = null
            ..isNextPageLoading = false
            ..people = (b.people..addAll(action.people))
            ..getAllPeople = action.people.isEmpty,
        );
      }
    }
    if (action is PageLoadingAction) {
      if (action.isFirstPage) {
        return state.rebuild((b) => b..isFirstPageLoading = true);
      } else {
        return state.rebuild((b) => b..isNextPageLoading = true);
      }
    }
    if (action is ErrorLoadingPageAction) {
      if (action.isFirstPage) {
        return state.rebuild(
          (b) => b
            ..isFirstPageLoading = false
            ..firstPageError = action.error,
        );
      } else {
        return state.rebuild(
          (b) => b
            ..isNextPageLoading = false
            ..nextPageError = action.error,
        );
      }
    }

    return state;
  }
}
