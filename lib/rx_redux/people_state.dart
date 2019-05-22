import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:load_more_flutter/model/person.dart';
import 'package:meta/meta.dart';

part 'people_state.g.dart';

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

  factory PeopleListState.initial() {}
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

class LoadNextPageAction implements Action {
  const LoadNextPageAction();
}

class LoadFirstPageAction implements Action {
  const LoadFirstPageAction();
}

class RefreshListAction implements Action {
  const RefreshListAction();
}

class RetryLoadPageAction implements Action {
  const RetryLoadPageAction();
}
