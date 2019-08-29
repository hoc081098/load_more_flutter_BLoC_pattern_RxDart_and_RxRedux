// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_state_action.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PeopleListState extends PeopleListState {
  @override
  final BuiltList<Person> people;
  @override
  final bool isFirstPageLoading;
  @override
  final Object firstPageError;
  @override
  final bool isNextPageLoading;
  @override
  final Object nextPageError;
  @override
  final bool getAllPeople;

  factory _$PeopleListState([void Function(PeopleListStateBuilder) updates]) =>
      (new PeopleListStateBuilder()..update(updates)).build();

  _$PeopleListState._(
      {this.people,
      this.isFirstPageLoading,
      this.firstPageError,
      this.isNextPageLoading,
      this.nextPageError,
      this.getAllPeople})
      : super._() {
    if (people == null) {
      throw new BuiltValueNullFieldError('PeopleListState', 'people');
    }
    if (isFirstPageLoading == null) {
      throw new BuiltValueNullFieldError(
          'PeopleListState', 'isFirstPageLoading');
    }
    if (isNextPageLoading == null) {
      throw new BuiltValueNullFieldError(
          'PeopleListState', 'isNextPageLoading');
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
        isFirstPageLoading == other.isFirstPageLoading &&
        firstPageError == other.firstPageError &&
        isNextPageLoading == other.isNextPageLoading &&
        nextPageError == other.nextPageError &&
        getAllPeople == other.getAllPeople;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, people.hashCode), isFirstPageLoading.hashCode),
                    firstPageError.hashCode),
                isNextPageLoading.hashCode),
            nextPageError.hashCode),
        getAllPeople.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('PeopleListState')
          ..add('people', people)
          ..add('isFirstPageLoading', isFirstPageLoading)
          ..add('firstPageError', firstPageError)
          ..add('isNextPageLoading', isNextPageLoading)
          ..add('nextPageError', nextPageError)
          ..add('getAllPeople', getAllPeople))
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

  bool _isFirstPageLoading;
  bool get isFirstPageLoading => _$this._isFirstPageLoading;
  set isFirstPageLoading(bool isFirstPageLoading) =>
      _$this._isFirstPageLoading = isFirstPageLoading;

  Object _firstPageError;
  Object get firstPageError => _$this._firstPageError;
  set firstPageError(Object firstPageError) =>
      _$this._firstPageError = firstPageError;

  bool _isNextPageLoading;
  bool get isNextPageLoading => _$this._isNextPageLoading;
  set isNextPageLoading(bool isNextPageLoading) =>
      _$this._isNextPageLoading = isNextPageLoading;

  Object _nextPageError;
  Object get nextPageError => _$this._nextPageError;
  set nextPageError(Object nextPageError) =>
      _$this._nextPageError = nextPageError;

  bool _getAllPeople;
  bool get getAllPeople => _$this._getAllPeople;
  set getAllPeople(bool getAllPeople) => _$this._getAllPeople = getAllPeople;

  PeopleListStateBuilder();

  PeopleListStateBuilder get _$this {
    if (_$v != null) {
      _people = _$v.people?.toBuilder();
      _isFirstPageLoading = _$v.isFirstPageLoading;
      _firstPageError = _$v.firstPageError;
      _isNextPageLoading = _$v.isNextPageLoading;
      _nextPageError = _$v.nextPageError;
      _getAllPeople = _$v.getAllPeople;
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
              isFirstPageLoading: isFirstPageLoading,
              firstPageError: firstPageError,
              isNextPageLoading: isNextPageLoading,
              nextPageError: nextPageError,
              getAllPeople: getAllPeople);
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
