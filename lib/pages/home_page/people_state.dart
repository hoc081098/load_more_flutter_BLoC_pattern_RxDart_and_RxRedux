import 'dart:collection' show UnmodifiableListView;

import 'package:collection/collection.dart' show ListEquality;
import 'package:load_more_flutter/data/model/person.dart';
import 'package:meta/meta.dart';

///
///
///

@immutable
class PeopleListState {
  final UnmodifiableListView<Person> people;
  final bool isLoading;
  final Object error;

  const PeopleListState({
    @required this.people,
    @required this.isLoading,
    @required this.error,
  });

  factory PeopleListState.initial() => PeopleListState(
        isLoading: false,
        people: UnmodifiableListView(<Person>[]),
        error: null,
      );

  PeopleListState copyWith({
    List<Person> people,
    bool isLoading,
    Object error,
  }) =>
      PeopleListState(
        error: error,
        people: people != null ? UnmodifiableListView(people) : this.people,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeopleListState &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(people, other.people) &&
          isLoading == other.isLoading;

  @override
  int get hashCode => people.hashCode ^ isLoading.hashCode;

  @override
  String toString() =>
      'PeopleListState(people.length=${people.length}, isLoading=$isLoading, error=$error)';
}
