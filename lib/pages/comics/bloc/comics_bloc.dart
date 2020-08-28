import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:load_more_flutter/pages/comics/bloc/comics_effects.dart';
import 'package:load_more_flutter/pages/comics/bloc/comics_state_and_action.dart';
import 'package:load_more_flutter/util.dart';
import 'package:meta/meta.dart';
import 'package:rx_redux/rx_redux.dart';

// ignore_for_file: close_sinks

class ComicsBloc {
  /// Input [Function]s
  final Future<void> Function() refresh;
  final void Function() loadFirstPage;
  final void Function() loadNextPage;
  final void Function() retryFirstPage;
  final void Function() retryNextPage;

  /// Output [Stream]s
  final Stream<ComicsListState> comicsList$;
  final GetState<ComicsListState> getComicsList;
  final Stream<Message> message$;

  /// Clean up: close controllers, cancel subscriptions
  final void Function() dispose;

  ComicsBloc._({
    @required this.refresh,
    @required this.loadFirstPage,
    @required this.loadNextPage,
    @required this.comicsList$,
    @required this.getComicsList,
    @required this.message$,
    @required this.dispose,
    @required this.retryFirstPage,
    @required this.retryNextPage,
  });

  factory ComicsBloc(final ComicsEffects effects, final String tag) {
    final initialState = ComicsListState.initial();

    // Reactive redux store.
    final store = RxReduxStore<Action, ComicsListState>(
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
      if (action is PageLoadedAction && action.comics.isEmpty) {
        return const LoadAllComicsMessage();
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

    return ComicsBloc._(
      dispose: () async {
        await store.dispose();
        await bag.dispose();
        print('$tag [DISPOSED]');
      },
      loadFirstPage: dispatch(const LoadFirstPageAction()),
      loadNextPage: dispatch(const LoadNextPageAction()),
      retryNextPage: dispatch(const RetryNextPageAction()),
      comicsList$: store.stateStream,
      refresh: () {
        final completer = Completer<void>();
        dispatch(RefreshListAction(completer))();
        return completer.future;
      },
      message$: message$,
      retryFirstPage: dispatch(const RetryFirstPageAction()),
      getComicsList: () => store.state,
    );
  }
}
