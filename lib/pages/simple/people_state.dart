import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:load_more_flutter/data/model/person.dart';
import 'package:meta/meta.dart';

part 'people_state.g.dart';

abstract class PeopleListState
    implements Built<PeopleListState, PeopleListStateBuilder> {
  BuiltList<Person> get people;

  bool get isLoading;

  bool get getAllPeople;

  @nullable
  Object get error;

  PeopleListState._();

  factory PeopleListState([Function(PeopleListStateBuilder b) updates]) =
      _$PeopleListState;

  factory PeopleListState.initial() {
    return PeopleListState((b) => b
      ..people = ListBuilder()
      ..error = null
      ..isLoading = false
      ..getAllPeople = false);
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
