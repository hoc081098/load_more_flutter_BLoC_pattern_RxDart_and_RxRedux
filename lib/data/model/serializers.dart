import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:load_more_flutter/data/model/person.dart';

part 'serializers.g.dart';

/// Collection of generated serializers for the built_value chat example.
@SerializersFor([Person])
final Serializers _serializers = _$serializers;

final standardSerializers = (_serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();