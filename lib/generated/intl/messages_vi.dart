// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  static m0(error) => "Lỗi xảy ra: ${error}";

  static m1(error) => "Lỗi xảy ra khi tải dữ liệu: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "error_occurred" : m0,
    "error_occurred_loading_next_page" : m1,
    "flutter_demo" : MessageLookupByLibrary.simpleMessage("Phân trang flutter"),
    "loaded_all_people" : MessageLookupByLibrary.simpleMessage("Đã tải tất cả danh sách!"),
    "retry" : MessageLookupByLibrary.simpleMessage("Tải lại")
  };
}
