import 'dart:async';

import 'package:load_more_flutter/data/model/person.dart';
import 'package:load_more_flutter/data/people/people_data_source.dart';
import 'package:load_more_flutter/pages/home_page/people_state.dart';
import 'package:rxdart/rxdart.dart';

const int pageSize = 10;

///
/// [Deprecated], using [SimplePeopleBloc] instead of.
///

@deprecated
class PeopleBloc {
  final PeopleDataSource _peopleDataSource;

  ///
  /// PublishSubject emit object when reach max items
  ///
  final _loadAllController = PublishSubject<void>();

  ///
  /// BehaviorSubject of errors, emit null when have no error
  ///
  final _errorController = BehaviorSubject<Object>.seeded(null, sync: true);
  ValueStream<Object> _errorNullable$;
  Stream<Object> _errorNotNull$; // stream of errors exposed to UI

  ///
  /// BehaviorSubject and Stream handle first page is loading
  ///
  final _isLoadingFirstPageController =
      BehaviorSubject<bool>.seeded(false, sync: true);
  ValueStream<bool> _isLoadingFirstPage$;

  ///
  /// PublishSubject handle load first page intent
  ///
  final _loadFirstPageController = PublishSubject<void>();

  ///
  /// PublishSubject handle load more intent
  ///
  final _loadMoreController = PublishSubject<void>();

  ///
  /// Stream of states
  ///
  ValueConnectableStream<PeopleListState> _peopleList$;
  StreamSubscription<PeopleListState> _streamSubscription;

  ///
  /// Sinks
  ///
  Sink<void> get loadMore => _loadMoreController.sink;

  Sink<void> get loadFirstPage => _loadFirstPageController.sink;

  ///
  /// Streams
  ///
  Stream<PeopleListState> get peopleList => _peopleList$;

  Stream<void> get loadedAllPeople => _loadAllController.stream;

  Stream<Object> get error => _errorNotNull$;

  PeopleBloc(this._peopleDataSource) : assert(_peopleDataSource != null) {
    _errorNullable$ = _errorController;
    _errorNotNull$ = _errorController.where((error) => error != null);
    _isLoadingFirstPage$ = _isLoadingFirstPageController.stream;

    final loadMore = _loadMoreController
        .throttleTime(Duration(milliseconds: 500))
        .doOnData((_) => print('_loadMoreController emitted...'))
        .where((_) {
          final error = _errorNullable$.value;
          final isLoadingFirstPage = _isLoadingFirstPage$.value;
          return !isLoadingFirstPage && error == null;
        })
        .doOnData((_) => print('Load more emitted...'))
        .map((_) => false)
        .exhaustMap(_loadMoreData)
        .doOnData(
          (data) => print('after exhaustMap onNext = $data'),
        ); // use exhaustMap operator, to ignore all value source emit, while loading data from api,

    final loadFirstPage = _loadFirstPageController
        .doOnData((_) => print('Load first page emitted...'))
        .map((_) => true)
        .flatMap(_loadMoreData)
        .doOnData((data) => print('after flatMap onNext = $data'));

    final streams = Rx.merge([
      loadFirstPage,
      loadMore,
    ]).map((state) => Stream.value(state));
    // merger to one stream, and map each state to Observable

    _peopleList$ = Rx.switchLatest(streams)
        .distinct()
        .doOnData((state) => print('state = $state'))
        .publishValueSeeded(PeopleListState.initial());

    _streamSubscription = _peopleList$.connect();
  }

  Future<void> refresh() async {
    print('Refresh start');

    _isLoadingFirstPageController.add(true);
    _loadFirstPageController.add(null);
    await _isLoadingFirstPage$.firstWhere((b) => !b);

    print('Refresh done');
  }

  Stream<PeopleListState> _loadMoreData(bool loadFirstPage) async* {
    if (loadFirstPage) {
      _isLoadingFirstPageController.add(true);
    }

    // get latest state
    final latestState = _peopleList$.value;
    print(
      '_loadMoreData loadFirstPage = $loadFirstPage, latestState = $latestState',
    );

    final currentList = latestState.people;
    // emit loading state
    yield latestState.copyWith(isLoading: true);

    try {
      // fetch page from data source
      final page = await _peopleDataSource.getPeople(
        limit: pageSize,
        field: 'name',
        startAfter: loadFirstPage
            ? null
            : currentList.isNotEmpty ? currentList.last : null,
      );

      if (page.isEmpty) {
        // if page is empty, emit all paged loaded
        _loadAllController.add(null);
      }

      // if fetch success, emit null
      _errorController.add(null);

      final people = <Person>[
        // if not load first page, append current list
        if (!loadFirstPage)
          ...currentList,
        ...page,
      ];

      // emit list state
      yield latestState.copyWith(
        isLoading: false,
        error: null,
        people: people,
      );
    } catch (e) {
      // if error was occurred, emit error
      _errorController.add(e);

      yield latestState.copyWith(
        isLoading: false,
        error: e,
      );
    } finally {
      if (loadFirstPage) {
        _isLoadingFirstPageController.add(false);
      }
    }
  }

  void dispose() async {
    await _streamSubscription.cancel();
    await Future.wait([
      _loadAllController.close(),
      _loadMoreController.close(),
      _loadFirstPageController.close(),
      _errorController.close(),
      _isLoadingFirstPageController.close(),
    ]);
  }
}
