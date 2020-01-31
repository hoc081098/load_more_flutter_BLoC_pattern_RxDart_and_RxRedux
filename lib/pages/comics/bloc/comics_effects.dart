import 'package:load_more_flutter/pages/comics/bloc/comics_state_and_action.dart';
import 'package:load_more_flutter/pages/comics/bloc/comics_usecase.dart';
import 'package:rx_redux/rx_redux.dart';
import 'package:rxdart/rxdart.dart';

///
/// This class holds [SideEffect]s and exposes message stream
///
class ComicsEffects {
  final GetComicsUseCase _getComics;
  final _messageSubject = PublishSubject<Message>();

  ComicsEffects(this._getComics);

  ///
  /// Expose message stream, emit while execute [SideEffect]
  ///
  Stream<Message> get message$ => _messageSubject;

  Stream<Action> loadFirstPageEffect(
    Stream<Action> actions,
    StateAccessor<ComicsListState> state,
  ) =>
      actions
          .whereType<LoadFirstPageAction>()
          .take(1)
          .map((_) => state())
          .where((state) => state.comics.isEmpty)
          .flatMap((_) => _nextPage(true));

  Stream<Action> loadNextPageEffect(
    Stream<Action> actions,
    StateAccessor<ComicsListState> state,
  ) =>
      actions
          .whereType<LoadNextPageAction>()
          .throttleTime(Duration(milliseconds: 500))
          .map((_) => state())
          .where((state) =>
              state.firstPageError == null &&
              state.nextPageError == null &&
              !state.isFirstPageLoading &&
              !state.isNextPageLoading)
          .exhaustMap((state) => _nextPage(false, state.page + 1));

  Stream<Action> _nextPage(bool isFirstPage, [int page = 1]) => _getComics(page)
      .map<Action>((comics) {
        return PageLoadedAction(
          comics,
          isFirstPage,
        );
      })
      .onErrorReturnWith((error) => ErrorLoadingPageAction(error, isFirstPage))
      .startWith(PageLoadingAction(isFirstPage))
      .doOnData((action) {
        if (action is PageLoadedAction) {
          if (action.comics.isEmpty) {
            _messageSubject?.add(const LoadAllComicsMessage());
          }
        }
        if (action is ErrorLoadingPageAction) {
          _messageSubject?.add(ErrorMessage(action.error));
        }
      });

  Stream<Action> refreshListEffect(
    Stream<Action> actions,
    StateAccessor<ComicsListState> state,
  ) =>
      actions.whereType<RefreshListAction>().exhaustMap((action) =>
          _nextPage(true).doOnDone(() => action.completer.complete()));

  Stream<Action> retryLoadNextPageEffect(
    Stream<Action> actions,
    StateAccessor<ComicsListState> state,
  ) =>
      actions
          .whereType<RetryNextPageAction>()
          .map((_) => state())
          .where((state) =>
              !state.isNextPageLoading && state.nextPageError != null)
          .exhaustMap((state) => _nextPage(false, state.page + 1));

  Stream<Action> retryLoadFirstPageEffect(
    Stream<Action> actions,
    StateAccessor<ComicsListState> state,
  ) =>
      actions
          .whereType<RetryFirstPageAction>()
          .map((_) => state())
          .where((state) =>
              !state.isFirstPageLoading && state.firstPageError != null)
          .exhaustMap((_) => _nextPage(true));

  Future<void> dispose() => _messageSubject.close();
}
