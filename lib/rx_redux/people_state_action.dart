import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:load_more_flutter/model/person.dart';
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

  factory PeopleListState([updates(PeopleListStateBuilder b)]) =
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
abstract class Action {}

///
/// User's actions
///

class LoadNextPageAction implements Action {
  const LoadNextPageAction();
}

class LoadFirstPageAction implements Action {
  const LoadFirstPageAction();
}

class RefreshListAction implements Action {
  final Completer<void> completer;

  const RefreshListAction(this.completer);
}

class RetryNextPageAction implements Action {
  const RetryNextPageAction();
}

class RetryFirstPageAction implements Action {
  const RetryFirstPageAction();
}

///
/// Action triggered by SideEffect
///

class PageLoadedAction implements Action {
  final BuiltList<Person> people;
  final bool isFirstPage;

  const PageLoadedAction(this.people, this.isFirstPage);
}

class PageLoadingAction implements Action {
  final bool isFirstPage;

  const PageLoadingAction(this.isFirstPage);
}

class ErrorLoadingPageAction implements Action {
  final error;
  final bool isFirstPage;

  const ErrorLoadingPageAction(this.error, this.isFirstPage);
}
