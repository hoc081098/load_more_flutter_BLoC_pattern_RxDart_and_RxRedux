import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:load_more_flutter/data/model/person.dart';
import 'package:load_more_flutter/data/people/people_data_source.dart';
import 'package:load_more_flutter/pages/simple/people_state.dart';
import 'package:load_more_flutter/util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

const int pageSize = 10;

class PeopleInteractor {
  final PeopleDataSource _peopleDataSource;

  const PeopleInteractor(this._peopleDataSource)
      : assert(_peopleDataSource != null);

  Stream<PeopleListState> fetchData(
      Tuple3<PeopleListState, bool, Completer<void>> tuple,
      Sink<Message> messageSink) {
    ///
    /// Destruct variables from [tuple]
    ///
    final currentState = tuple.item1;
    final refreshList = tuple.item2;
    final completer = tuple.item3;

    ///
    /// Get people from [peopleDataSource]
    ///
    final getPeople = _peopleDataSource.getPeople(
      field: 'name',
      limit: pageSize,
      startAfter: refreshList ? null : currentState.people.lastOrNull,
    );

    ///
    ///
    ///
    PeopleListState toListState(BuiltList<Person> people) =>
        PeopleListState((b) {
          final listBuilder = currentState.people.toBuilder()
            ..update((b) {
              if (refreshList) {
                b.clear();
              }
              b.addAll(people);
            });

          return b
            ..error = null
            ..isLoading = false
            ..people = listBuilder
            ..getAllPeople = people.isEmpty;
        });

    PeopleListState toErrorState(dynamic e) => currentState.rebuild((b) => b
      ..error = e
      ..getAllPeople = false
      ..isLoading = false);

    final loadingState = currentState.rebuild((b) => b
      ..isLoading = true
      ..getAllPeople = false
      ..error = null);

    ///
    /// Perform side affects:
    ///
    /// - Add [LoadAllPeopleMessage] or [ErrorMessage] to [messageSink]
    /// - Complete [completer] if [completer] is not null
    ///
    void addLoadAllPeopleMessageIfLoadedAll(PeopleListState state) {
      if (state.getAllPeople) {
        messageSink.add(const LoadAllPeopleMessage());
      }
    }

    void addErrorMessage(dynamic error, StackTrace _) =>
        messageSink.add(ErrorMessage(error));

    void completeCompleter() => completer?.complete();

    ///
    /// Return state [Stream]
    ///
    return Stream.fromFuture(getPeople)
        .map(toListState)
        .doOnData(addLoadAllPeopleMessageIfLoadedAll)
        .doOnError(addErrorMessage)
        .startWith(loadingState)
        .onErrorReturnWith(toErrorState)
        .doOnDone(completeCompleter);
  }
}
