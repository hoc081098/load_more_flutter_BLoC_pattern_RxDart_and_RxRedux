import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:load_more_flutter/pages/rx_redux/bloc/bloc.dart';
import 'package:load_more_flutter/util.dart';
import 'package:meta/meta.dart';
import 'package:rx_redux/rx_redux.dart';

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
  final Stream<PeopleListState> peopleList$;
  final GetState<PeopleListState> getPeopleList;
  final Stream<Message> message$;

  /// Clean up: close controller, cancel subscription
  final void Function() dispose;

  PeopleRxReduxBloc._({
    @required this.refresh,
    @required this.loadFirstPage,
    @required this.loadNextPage,
    @required this.peopleList$,
    @required this.getPeopleList,
    @required this.message$,
    @required this.dispose,
    @required this.retryFirstPage,
    @required this.retryNextPage,
  });

  factory PeopleRxReduxBloc(PeopleEffects effects) {
    final initialState = PeopleListState.initial();

    // Reactive redux store
    final store = RxReduxStore<Action, PeopleListState>(
      initialState: initialState,
      reducer: (state, action) => action.reducer(state),
      sideEffects: [
        effects.loadFirstPageEffect,
        effects.loadNextPageEffect,
        effects.refreshListEffect,
        effects.retryLoadFirstPageEffect,
        effects.retryLoadNextPageEffect,
      ],
      logger: rxReduxDefaultLogger,
      errorHandler: (error, st) => print('$tag [ERROR] = $error'),
    );

    final message$ = store.actionStream.mapNotNull((action) {
      if (action is PageLoadedAction && action.people.isEmpty) {
        return const LoadAllPeopleMessage();
      }
      if (action is ErrorLoadingPageAction) {
        return ErrorMessage(action.error);
      }
      return null;
    });

    final bag = DisposeBag([
      store.stateStream.listen((state) => print('$tag [STATE] = $state')),
      message$.listen((message) => print('$tag [MESSAGE] = $message')),
    ]);

    // Dispatch an action
    void Function() dispatch(Action action) => () => store.dispatch(action);

    return PeopleRxReduxBloc._(
      dispose: () async {
        await store.dispose();
        await bag.dispose();
        print('$tag [DISPOSED]');
      },
      loadFirstPage: dispatch(const LoadFirstPageAction()),
      loadNextPage: dispatch(const LoadNextPageAction()),
      retryNextPage: dispatch(const RetryNextPageAction()),
      peopleList$: store.stateStream,
      refresh: () {
        final completer = Completer<void>();
        dispatch(RefreshListAction(completer))();
        return completer.future;
      },
      message$: message$,
      retryFirstPage: dispatch(const RetryFirstPageAction()),
      getPeopleList: () => store.state,
    );
  }
}
