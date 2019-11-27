import 'package:built_value/built_value.dart' hide Builder;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:load_more_flutter/app.dart';
import 'package:load_more_flutter/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  newBuiltValueToStringHelper =
      (className) => CustomIndentingBuiltValueToStringHelper(className);
  await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  runApp(const MyApp());
}
