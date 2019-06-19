import 'package:load_more_flutter/data/people_data_source.dart';
import 'package:load_more_flutter/model/person.dart';
import 'package:load_more_flutter/rx_redux/people_rx_redux_bloc.dart';
import 'package:load_more_flutter/rx_redux/people_state_action.dart';
import 'package:load_more_flutter/util.dart';
import 'package:rx_redux/rx_redux.dart';
import 'package:rxdart/rxdart.dart';

class PeopleEffects {
  static const pageSize = 20;

  final PeopleDataSource _peopleDataSource;
  // ignore: close_sinks
  final _messageSubject = PublishSubject<Message>();

  PeopleEffects(this._peopleDataSource);

  Observable<Message> get message$ => _messageSubject;

  Observable<Action> loadFirstPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions
          .ofType(TypeToken<LoadFirstPageAction>())
          .take(1)
          .map((_) => state())
          .where((state) => state.people.isEmpty)
          .flatMap((_) => _nextPage(true));

  Observable<Action> loadNextPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions
          .ofType(TypeToken<LoadNextPageAction>())
          .throttleTime(Duration(milliseconds: 500))
          .map((_) => state())
          .where((state) =>
              state.firstPageError == null &&
              state.nextPageError == null &&
              !state.isFirstPageLoading &&
              !state.isNextPageLoading)
          .exhaustMap((state) => _nextPage(false, lastOrNull(state.people)));

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
      actions.ofType(TypeToken<RefreshListAction>()).exhaustMap((action) =>
          _nextPage(true).doOnDone(() => action.completer.complete()));

  Observable<Action> retryLoadNextPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions
          .ofType(TypeToken<RetryNextPageAction>())
          .map((_) => state())
          .where((state) =>
              !state.isNextPageLoading && state.nextPageError != null)
          .exhaustMap((state) => _nextPage(false, lastOrNull(state.people)));

  Observable<Action> retryLoadFirstPageEffect(
    Observable<Action> actions,
    StateAccessor<PeopleListState> state,
  ) =>
      actions
          .ofType(TypeToken<RetryFirstPageAction>())
          .map((_) => state())
          .where((state) =>
              !state.isFirstPageLoading && state.firstPageError != null)
          .exhaustMap((_) => _nextPage(true));
}
