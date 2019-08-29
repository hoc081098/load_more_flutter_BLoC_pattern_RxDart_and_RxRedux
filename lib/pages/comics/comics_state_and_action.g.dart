// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comics_state_and_action.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ComicsListState extends ComicsListState {
  @override
  final BuiltList<Comic> comics;
  @override
  final bool isFirstPageLoading;
  @override
  final Object firstPageError;
  @override
  final bool isNextPageLoading;
  @override
  final Object nextPageError;
  @override
  final bool getAllComics;
  @override
  final int page;

  factory _$ComicsListState([void Function(ComicsListStateBuilder) updates]) =>
      (new ComicsListStateBuilder()..update(updates)).build();

  _$ComicsListState._(
      {this.comics,
      this.isFirstPageLoading,
      this.firstPageError,
      this.isNextPageLoading,
      this.nextPageError,
      this.getAllComics,
      this.page})
      : super._() {
    if (comics == null) {
      throw new BuiltValueNullFieldError('ComicsListState', 'comics');
    }
    if (isFirstPageLoading == null) {
      throw new BuiltValueNullFieldError(
          'ComicsListState', 'isFirstPageLoading');
    }
    if (isNextPageLoading == null) {
      throw new BuiltValueNullFieldError(
          'ComicsListState', 'isNextPageLoading');
    }
    if (getAllComics == null) {
      throw new BuiltValueNullFieldError('ComicsListState', 'getAllComics');
    }
    if (page == null) {
      throw new BuiltValueNullFieldError('ComicsListState', 'page');
    }
  }

  @override
  ComicsListState rebuild(void Function(ComicsListStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComicsListStateBuilder toBuilder() =>
      new ComicsListStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComicsListState &&
        comics == other.comics &&
        isFirstPageLoading == other.isFirstPageLoading &&
        firstPageError == other.firstPageError &&
        isNextPageLoading == other.isNextPageLoading &&
        nextPageError == other.nextPageError &&
        getAllComics == other.getAllComics &&
        page == other.page;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc($jc(0, comics.hashCode),
                            isFirstPageLoading.hashCode),
                        firstPageError.hashCode),
                    isNextPageLoading.hashCode),
                nextPageError.hashCode),
            getAllComics.hashCode),
        page.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ComicsListState')
          ..add('comics', comics)
          ..add('isFirstPageLoading', isFirstPageLoading)
          ..add('firstPageError', firstPageError)
          ..add('isNextPageLoading', isNextPageLoading)
          ..add('nextPageError', nextPageError)
          ..add('getAllComics', getAllComics)
          ..add('page', page))
        .toString();
  }
}

class ComicsListStateBuilder
    implements Builder<ComicsListState, ComicsListStateBuilder> {
  _$ComicsListState _$v;

  ListBuilder<Comic> _comics;
  ListBuilder<Comic> get comics => _$this._comics ??= new ListBuilder<Comic>();
  set comics(ListBuilder<Comic> comics) => _$this._comics = comics;

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

  bool _getAllComics;
  bool get getAllComics => _$this._getAllComics;
  set getAllComics(bool getAllComics) => _$this._getAllComics = getAllComics;

  int _page;
  int get page => _$this._page;
  set page(int page) => _$this._page = page;

  ComicsListStateBuilder();

  ComicsListStateBuilder get _$this {
    if (_$v != null) {
      _comics = _$v.comics?.toBuilder();
      _isFirstPageLoading = _$v.isFirstPageLoading;
      _firstPageError = _$v.firstPageError;
      _isNextPageLoading = _$v.isNextPageLoading;
      _nextPageError = _$v.nextPageError;
      _getAllComics = _$v.getAllComics;
      _page = _$v.page;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComicsListState other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ComicsListState;
  }

  @override
  void update(void Function(ComicsListStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ComicsListState build() {
    _$ComicsListState _$result;
    try {
      _$result = _$v ??
          new _$ComicsListState._(
              comics: comics.build(),
              isFirstPageLoading: isFirstPageLoading,
              firstPageError: firstPageError,
              isNextPageLoading: isNextPageLoading,
              nextPageError: nextPageError,
              getAllComics: getAllComics,
              page: page);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'comics';
        comics.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ComicsListState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
