import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:load_more_flutter/data/model/person.dart';
import 'package:meta/meta.dart';

part 'people_state_action.g.dart';

abstract class PeopleListState
    implements Built<PeopleListState, PeopleListStateBuilder> {
  BuiltList<Person> get people;

  bool get isFirstPageLoading;

  @nullable
  Object get firstPageError;

  bool get isNextPageLoading;

  @nullable
  Object get nextPageError;

  bool get getAllPeople;

  PeopleListState._();

  factory PeopleListState([Function(PeopleListStateBuilder b) updates]) =
      _$PeopleListState;

  factory PeopleListState.initial() {
    return PeopleListState(
      (b) => b
        ..people = ListBuilder<Person>()
        ..isFirstPageLoading = true
        ..firstPageError = null
        ..isNextPageLoading = false
        ..nextPageError = null
        ..getAllPeople = false,
    );
  }
}

@immutable
abstract class Message {}

class LoadAllPeopleMessage implements Message {
  const LoadAllPeopleMessage();
}

class ErrorMessage implements Message {
  final Object error;

  const ErrorMessage(this.error);
}

@immutable
abstract class Action {
  ///
  /// Pure function return new view state from current view state and an action
  ///
  PeopleListState reducer(PeopleListState state);
}

///
/// User's actions
///

class LoadNextPageAction implements Action {
  const LoadNextPageAction();

  @override
  PeopleListState reducer(PeopleListState state) => state;
}

class LoadFirstPageAction implements Action {
  const LoadFirstPageAction();

  @override
  PeopleListState reducer(PeopleListState state) => state;
}

class RefreshListAction implements Action {
  final Completer<void> completer;

  const RefreshListAction(this.completer);

  @override
  PeopleListState reducer(PeopleListState state) => state;
}

class RetryNextPageAction implements Action {
  const RetryNextPageAction();

  @override
  PeopleListState reducer(PeopleListState state) => state;
}

class RetryFirstPageAction implements Action {
  const RetryFirstPageAction();

  @override
  PeopleListState reducer(PeopleListState state) => state;
}

///
/// Action triggered by SideEffect
///

class PageLoadedAction implements Action {
  final BuiltList<Person> people;
  final bool isFirstPage;

  const PageLoadedAction(this.people, this.isFirstPage);

  @override
  PeopleListState reducer(PeopleListState state) {
    if (isFirstPage) {
      return state.rebuild(
        (b) => b
          ..isFirstPageLoading = false
          ..firstPageError = null
          ..people = people.toBuilder()
          ..getAllPeople = people.isEmpty,
      );
    } else {
      return state.rebuild(
        (b) => b
          ..isFirstPageLoading = false
          ..firstPageError = null
          ..nextPageError = null
          ..isNextPageLoading = false
          ..people = (b.people..addAll(people))
          ..getAllPeople = people.isEmpty,
      );
    }
  }
}

class PageLoadingAction implements Action {
  final bool isFirstPage;

  const PageLoadingAction(this.isFirstPage);

  @override
  PeopleListState reducer(PeopleListState state) {
    if (isFirstPage) {
      return state.rebuild((b) => b..isFirstPageLoading = true);
    } else {
      return state.rebuild((b) => b..isNextPageLoading = true);
    }
  }
}

class ErrorLoadingPageAction implements Action {
  final error;
  final bool isFirstPage;

  const ErrorLoadingPageAction(this.error, this.isFirstPage);

  @override
  PeopleListState reducer(PeopleListState state) {
    if (isFirstPage) {
      return state.rebuild(
        (b) => b
          ..isFirstPageLoading = false
          ..firstPageError = error,
      );
    } else {
      return state.rebuild(
        (b) => b
          ..isNextPageLoading = false
          ..nextPageError = error,
      );
    }
  }
}
