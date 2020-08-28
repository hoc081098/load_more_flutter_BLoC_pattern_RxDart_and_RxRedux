import 'package:load_more_flutter/data/model/person.dart';
import 'package:load_more_flutter/data/people/people_data_source.dart';
import 'package:load_more_flutter/pages/rx_redux/bloc/bloc.dart';
import 'package:load_more_flutter/util.dart';
import 'package:rx_redux/rx_redux.dart';
import 'package:rxdart/rxdart.dart';

/// Class that holds [SideEffect]s.
class PeopleEffects {
  static const pageSize = 20;

  final PeopleDataSource _peopleDataSource;

  PeopleEffects(this._peopleDataSource);

  Stream<Action> loadFirstPageEffect(
    Stream<Action> actions,
    GetState<PeopleListState> state,
  ) =>
      actions
          .whereType<LoadFirstPageAction>()
          .take(1)
          .map((_) => state())
          .where((state) => state.people.isEmpty)
          .flatMap((_) => _nextPage(true));

  Stream<Action> loadNextPageEffect(
    Stream<Action> actions,
    GetState<PeopleListState> state,
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
          .exhaustMap((state) => _nextPage(false, state.people.lastOrNull));

  Stream<Action> _nextPage(bool isFirstPage, [Person startAfter]) =>
      Rx.defer(() => Stream.fromFuture(
                _peopleDataSource.getPeople(
                  field: 'name',
                  limit: pageSize,
                  startAfter: startAfter,
                ),
              ))
          .map<Action>((people) {
            return PageLoadedAction(
              people,
              isFirstPage,
            );
          })
          .onErrorReturnWith(
              (error) => ErrorLoadingPageAction(error, isFirstPage))
          .startWith(PageLoadingAction(isFirstPage));

  Stream<Action> refreshListEffect(
    Stream<Action> actions,
    GetState<PeopleListState> state,
  ) =>
      actions.whereType<RefreshListAction>().exhaustMap((action) =>
          _nextPage(true).doOnDone(() => action.completer.complete()));

  Stream<Action> retryLoadNextPageEffect(
    Stream<Action> actions,
    GetState<PeopleListState> state,
  ) =>
      actions
          .whereType<RetryNextPageAction>()
          .map((_) => state())
          .where((state) =>
              !state.isNextPageLoading && state.nextPageError != null)
          .exhaustMap((state) => _nextPage(false, state.people.lastOrNull));

  Stream<Action> retryLoadFirstPageEffect(
    Stream<Action> actions,
    GetState<PeopleListState> state,
  ) =>
      actions
          .whereType<RetryFirstPageAction>()
          .map((_) => state())
          .where((state) =>
              !state.isFirstPageLoading && state.firstPageError != null)
          .exhaustMap((_) => _nextPage(true));
}
