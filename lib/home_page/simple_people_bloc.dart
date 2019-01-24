import 'dart:async';

import 'package:load_more_flutter/data/people_data_source.dart';
import 'package:load_more_flutter/home_page/peoples_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const int pageSize = 10;

///
///
///

class PeopleBloc {
  ///
  /// Input [Function]s
  ///
  final Future<void> Function() refresh;
  final void Function() load;

  ///
  /// Output [Stream]s
  ///
  final ValueObservable<PeopleListState> peopleList$;
  final Stream<Message> message$;

  ///
  /// Clean up
  ///
  final Future<void> Function() dispose;

  PeopleBloc._({
    @required this.refresh,
    @required this.load,
    @required this.peopleList$,
    @required this.message$,
    @required this.dispose,
  });

  factory PeopleBloc(PeopleDataSource peopleDataSource) {
    assert(peopleDataSource != null);

    ///
    ///TODO implements BLoC
    ///

    return PeopleBloc._(
      dispose: () {},
      load: () {},
      message$: null,
      peopleList$: null,
      refresh: () {},
    );
  }
}
