// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comic.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Comic> _$comicSerializer = new _$ComicSerializer();

class _$ComicSerializer implements StructuredSerializer<Comic> {
  @override
  final Iterable<Type> types = const [Comic, _$Comic];
  @override
  final String wireName = 'Comic';

  @override
  Iterable serialize(Serializers serializers, Comic object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'link',
      serializers.serialize(object.link, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Comic deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ComicBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'link':
          result.link = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Comic extends Comic {
  @override
  final String link;

  factory _$Comic([void Function(ComicBuilder) updates]) =>
      (new ComicBuilder()..update(updates)).build();

  _$Comic._({this.link}) : super._() {
    if (link == null) {
      throw new BuiltValueNullFieldError('Comic', 'link');
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
    return other is Comic && link == other.link;
  }

  @override
  int get hashCode {
    return $jf($jc(0, link.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Comic')..add('link', link)).toString();
  }
}

class ComicBuilder implements Builder<Comic, ComicBuilder> {
  _$Comic _$v;

  String _link;
  String get link => _$this._link;
  set link(String link) => _$this._link = link;

  ComicBuilder();

  ComicBuilder get _$this {
    if (_$v != null) {
      _link = _$v.link;
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
    final _$result = _$v ?? new _$Comic._(link: link);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
