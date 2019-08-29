// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PeopleListState extends PeopleListState {
  @override
  final BuiltList<Person> people;
  @override
  final bool isLoading;
  @override
  final bool getAllPeople;
  @override
  final Object error;

  factory _$PeopleListState([void Function(PeopleListStateBuilder) updates]) =>
      (new PeopleListStateBuilder()..update(updates)).build();

  _$PeopleListState._(
      {this.people, this.isLoading, this.getAllPeople, this.error})
      : super._() {
    if (people == null) {
      throw new BuiltValueNullFieldError('PeopleListState', 'people');
    }
    if (isLoading == null) {
      throw new BuiltValueNullFieldError('PeopleListState', 'isLoading');
    }
    if (getAllPeople == null) {
      throw new BuiltValueNullFieldError('PeopleListState', 'getAllPeople');
    }
  }

  @override
  PeopleListState rebuild(void Function(PeopleListStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PeopleListStateBuilder toBuilder() =>
      new PeopleListStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PeopleListState &&
        people == other.people &&
        isLoading == other.isLoading &&
        getAllPeople == other.getAllPeople &&
        error == other.error;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, people.hashCode), isLoading.hashCode),
            getAllPeople.hashCode),
        error.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('PeopleListState')
          ..add('people', people)
          ..add('isLoading', isLoading)
          ..add('getAllPeople', getAllPeople)
          ..add('error', error))
        .toString();
  }
}

class PeopleListStateBuilder
    implements Builder<PeopleListState, PeopleListStateBuilder> {
  _$PeopleListState _$v;

  ListBuilder<Person> _people;
  ListBuilder<Person> get people =>
      _$this._people ??= new ListBuilder<Person>();
  set people(ListBuilder<Person> people) => _$this._people = people;

  bool _isLoading;
  bool get isLoading => _$this._isLoading;
  set isLoading(bool isLoading) => _$this._isLoading = isLoading;

  bool _getAllPeople;
  bool get getAllPeople => _$this._getAllPeople;
  set getAllPeople(bool getAllPeople) => _$this._getAllPeople = getAllPeople;

  Object _error;
  Object get error => _$this._error;
  set error(Object error) => _$this._error = error;

  PeopleListStateBuilder();

  PeopleListStateBuilder get _$this {
    if (_$v != null) {
      _people = _$v.people?.toBuilder();
      _isLoading = _$v.isLoading;
      _getAllPeople = _$v.getAllPeople;
      _error = _$v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PeopleListState other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$PeopleListState;
  }

  @override
  void update(void Function(PeopleListStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$PeopleListState build() {
    _$PeopleListState _$result;
    try {
      _$result = _$v ??
          new _$PeopleListState._(
              people: people.build(),
              isLoading: isLoading,
              getAllPeople: getAllPeople,
              error: error);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'people';
        people.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'PeopleListState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
