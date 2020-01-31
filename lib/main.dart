import 'package:built_value/built_value.dart' show newBuiltValueToStringHelper;
import 'package:flutter/material.dart';
import 'package:load_more_flutter/app.dart';
import 'package:load_more_flutter/util.dart';

void main() {
  newBuiltValueToStringHelper =
      (className) => CustomIndentingBuiltValueToStringHelper(className);
  runApp(const MyApp());
}
