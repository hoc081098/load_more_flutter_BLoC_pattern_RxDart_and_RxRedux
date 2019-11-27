import 'package:load_more_flutter/data/model/person.dart';
import 'package:load_more_flutter/data/people/people_data_source.dart';
import 'package:load_more_flutter/pages/rx_redux/bloc/bloc.dart';
import 'package:load_more_flutter/util.dart';
import 'package:rx_redux/rx_redux.dart';
import 'package:rxdart/rxdart.dart';

///
/// Class hold [SideEffect]s
/// And expose message stream
///
class PeopleEffects {
  static const pageSize = 20;

  final PeopleDataSource _peopleDataSource;
  final _messageSubject = PublishSubject<Message>();

  PeopleEffects(this._peopleDataSource);

  ///
  /// Expose message stream, emit while execute [SideEffect]
  ///
  Stream<Message> get message$ => _messageSubject;

  Observable<Action> loadFirstPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions
          .whereType<LoadFirstPageAction>()
          .take(1)
          .map((_) => state())
          .where((state) => state.people.isEmpty)
          .flatMap((_) => _nextPage(true));

  Observable<Action> loadNextPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
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

  Observable<Action> _nextPage(bool isFirstPage, [Person startAfter]) =>
      Observable.defer(() => Stream.fromFuture(
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
          .startWith(PageLoadingAction(isFirstPage))
          .doOnData((action) {
            print('${PeopleRxReduxBloc.tag} Side effect: action = $action');

            if (action is PageLoadedAction) {
              if (action.people.isEmpty) {
                _messageSubject?.add(const LoadAllPeopleMessage());
              }
            }
            if (action is ErrorLoadingPageAction) {
              _messageSubject?.add(ErrorMessage(action.error));
            }
          });

  Observable<Action> refreshListEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions.whereType<RefreshListAction>().exhaustMap((action) =>
          _nextPage(true).doOnDone(() => action.completer.complete()));

  Observable<Action> retryLoadNextPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions
          .whereType<RetryNextPageAction>()
          .map((_) => state())
          .where((state) =>
              !state.isNextPageLoading && state.nextPageError != null)
          .exhaustMap((state) => _nextPage(false, state.people.lastOrNull));

  Observable<Action> retryLoadFirstPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions
          .whereType<RetryFirstPageAction>()
          .map((_) => state())
          .where((state) =>
              !state.isFirstPageLoading && state.firstPageError != null)
          .exhaustMap((_) => _nextPage(true));

  Future<void> dispose() => _messageSubject.close();
}
