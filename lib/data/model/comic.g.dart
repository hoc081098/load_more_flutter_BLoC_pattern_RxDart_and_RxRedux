// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comic.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ErrorResponse> _$errorResponseSerializer =
    new _$ErrorResponseSerializer();
Serializer<LastChapter> _$lastChapterSerializer = new _$LastChapterSerializer();
Serializer<Comic> _$comicSerializer = new _$ComicSerializer();

class _$ErrorResponseSerializer implements StructuredSerializer<ErrorResponse> {
  @override
  final Iterable<Type> types = const [ErrorResponse, _$ErrorResponse];
  @override
  final String wireName = 'ErrorResponse';

  @override
  Iterable<Object> serialize(Serializers serializers, ErrorResponse object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'message',
      serializers.serialize(object.message,
          specifiedType: const FullType(String)),
      'status_code',
      serializers.serialize(object.statusCode,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  ErrorResponse deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ErrorResponseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'message':
          result.message = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'status_code':
          result.statusCode = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$LastChapterSerializer implements StructuredSerializer<LastChapter> {
  @override
  final Iterable<Type> types = const [LastChapter, _$LastChapter];
  @override
  final String wireName = 'LastChapter';

  @override
  Iterable<Object> serialize(Serializers serializers, LastChapter object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'chapter_link',
      serializers.serialize(object.chapterLink,
          specifiedType: const FullType(String)),
      'chapter_name',
      serializers.serialize(object.chapterName,
          specifiedType: const FullType(String)),
      'time',
      serializers.serialize(object.time, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  LastChapter deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new LastChapterBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'chapter_link':
          result.chapterLink = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'chapter_name':
          result.chapterName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'time':
          result.time = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$ComicSerializer implements StructuredSerializer<Comic> {
  @override
  final Iterable<Type> types = const [Comic, _$Comic];
  @override
  final String wireName = 'Comic';

  @override
  Iterable<Object> serialize(Serializers serializers, Comic object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'last_chapters',
      serializers.serialize(object.lastChapters,
          specifiedType:
              const FullType(BuiltList, const [const FullType(LastChapter)])),
      'link',
      serializers.serialize(object.link, specifiedType: const FullType(String)),
      'thumbnail',
      serializers.serialize(object.thumbnail,
          specifiedType: const FullType(String)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'view',
      serializers.serialize(object.view, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Comic deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ComicBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'last_chapters':
          result.lastChapters.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(LastChapter)]))
              as BuiltList<Object>);
          break;
        case 'link':
          result.link = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'thumbnail':
          result.thumbnail = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'view':
          result.view = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$ErrorResponse extends ErrorResponse {
  @override
  final String message;
  @override
  final int statusCode;

  factory _$ErrorResponse([void Function(ErrorResponseBuilder) updates]) =>
      (new ErrorResponseBuilder()..update(updates)).build();

  _$ErrorResponse._({this.message, this.statusCode}) : super._() {
    if (message == null) {
      throw new BuiltValueNullFieldError('ErrorResponse', 'message');
    }
    if (statusCode == null) {
      throw new BuiltValueNullFieldError('ErrorResponse', 'statusCode');
    }
  }

  @override
  ErrorResponse rebuild(void Function(ErrorResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorResponseBuilder toBuilder() => new ErrorResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorResponse &&
        message == other.message &&
        statusCode == other.statusCode;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, message.hashCode), statusCode.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ErrorResponse')
          ..add('message', message)
          ..add('statusCode', statusCode))
        .toString();
  }
}

class ErrorResponseBuilder
    implements Builder<ErrorResponse, ErrorResponseBuilder> {
  _$ErrorResponse _$v;

  String _message;
  String get message => _$this._message;
  set message(String message) => _$this._message = message;

  int _statusCode;
  int get statusCode => _$this._statusCode;
  set statusCode(int statusCode) => _$this._statusCode = statusCode;

  ErrorResponseBuilder();

  ErrorResponseBuilder get _$this {
    if (_$v != null) {
      _message = _$v.message;
      _statusCode = _$v.statusCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorResponse other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ErrorResponse;
  }

  @override
  void update(void Function(ErrorResponseBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ErrorResponse build() {
    final _$result =
        _$v ?? new _$ErrorResponse._(message: message, statusCode: statusCode);
    replace(_$result);
    return _$result;
  }
}

class _$LastChapter extends LastChapter {
  @override
  final String chapterLink;
  @override
  final String chapterName;
  @override
  final String time;

  factory _$LastChapter([void Function(LastChapterBuilder) updates]) =>
      (new LastChapterBuilder()..update(updates)).build();

  _$LastChapter._({this.chapterLink, this.chapterName, this.time}) : super._() {
    if (chapterLink == null) {
      throw new BuiltValueNullFieldError('LastChapter', 'chapterLink');
    }
    if (chapterName == null) {
      throw new BuiltValueNullFieldError('LastChapter', 'chapterName');
    }
    if (time == null) {
      throw new BuiltValueNullFieldError('LastChapter', 'time');
    }
  }

  @override
  LastChapter rebuild(void Function(LastChapterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LastChapterBuilder toBuilder() => new LastChapterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LastChapter &&
        chapterLink == other.chapterLink &&
        chapterName == other.chapterName &&
        time == other.time;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, chapterLink.hashCode), chapterName.hashCode),
        time.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('LastChapter')
          ..add('chapterLink', chapterLink)
          ..add('chapterName', chapterName)
          ..add('time', time))
        .toString();
  }
}

class LastChapterBuilder implements Builder<LastChapter, LastChapterBuilder> {
  _$LastChapter _$v;

  String _chapterLink;
  String get chapterLink => _$this._chapterLink;
  set chapterLink(String chapterLink) => _$this._chapterLink = chapterLink;

  String _chapterName;
  String get chapterName => _$this._chapterName;
  set chapterName(String chapterName) => _$this._chapterName = chapterName;

  String _time;
  String get time => _$this._time;
  set time(String time) => _$this._time = time;

  LastChapterBuilder();

  LastChapterBuilder get _$this {
    if (_$v != null) {
      _chapterLink = _$v.chapterLink;
      _chapterName = _$v.chapterName;
      _time = _$v.time;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LastChapter other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$LastChapter;
  }

  @override
  void update(void Function(LastChapterBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$LastChapter build() {
    final _$result = _$v ??
        new _$LastChapter._(
            chapterLink: chapterLink, chapterName: chapterName, time: time);
    replace(_$result);
    return _$result;
  }
}

class _$Comic extends Comic {
  @override
  final BuiltList<LastChapter> lastChapters;
  @override
  final String link;
  @override
  final String thumbnail;
  @override
  final String title;
  @override
  final String view;

  factory _$Comic([void Function(ComicBuilder) updates]) =>
      (new ComicBuilder()..update(updates)).build();

  _$Comic._(
      {this.lastChapters, this.link, this.thumbnail, this.title, this.view})
      : super._() {
    if (lastChapters == null) {
      throw new BuiltValueNullFieldError('Comic', 'lastChapters');
    }
    if (link == null) {
      throw new BuiltValueNullFieldError('Comic', 'link');
    }
    if (thumbnail == null) {
      throw new BuiltValueNullFieldError('Comic', 'thumbnail');
    }
    if (title == null) {
      throw new BuiltValueNullFieldError('Comic', 'title');
    }
    if (view == null) {
      throw new BuiltValueNullFieldError('Comic', 'view');
    }
  }

  @override
  Comic rebuild(void Function(ComicBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComicBuilder toBuilder() => new ComicBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Comic &&
        lastChapters == other.lastChapters &&
        link == other.link &&
        thumbnail == other.thumbnail &&
        title == other.title &&
        view == other.view;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, lastChapters.hashCode), link.hashCode),
                thumbnail.hashCode),
            title.hashCode),
        view.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Comic')
          ..add('lastChapters', lastChapters)
          ..add('link', link)
          ..add('thumbnail', thumbnail)
          ..add('title', title)
          ..add('view', view))
        .toString();
  }
}

class ComicBuilder implements Builder<Comic, ComicBuilder> {
  _$Comic _$v;

  ListBuilder<LastChapter> _lastChapters;
  ListBuilder<LastChapter> get lastChapters =>
      _$this._lastChapters ??= new ListBuilder<LastChapter>();
  set lastChapters(ListBuilder<LastChapter> lastChapters) =>
      _$this._lastChapters = lastChapters;

  String _link;
  String get link => _$this._link;
  set link(String link) => _$this._link = link;

  String _thumbnail;
  String get thumbnail => _$this._thumbnail;
  set thumbnail(String thumbnail) => _$this._thumbnail = thumbnail;

  String _title;
  String get title => _$this._title;
  set title(String title) => _$this._title = title;

  String _view;
  String get view => _$this._view;
  set view(String view) => _$this._view = view;

  ComicBuilder();

  ComicBuilder get _$this {
    if (_$v != null) {
      _lastChapters = _$v.lastChapters?.toBuilder();
      _link = _$v.link;
      _thumbnail = _$v.thumbnail;
      _title = _$v.title;
      _view = _$v.view;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Comic other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Comic;
  }

  @override
  void update(void Function(ComicBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Comic build() {
    _$Comic _$result;
    try {
      _$result = _$v ??
          new _$Comic._(
              lastChapters: lastChapters.build(),
              link: link,
              thumbnail: thumbnail,
              title: title,
              view: view);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'lastChapters';
        lastChapters.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Comic', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
