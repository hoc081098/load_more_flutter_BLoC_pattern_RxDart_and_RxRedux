import 'dart:async';

import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/people/memory_person_data_source.dart';
import 'package:load_more_flutter/data/people/people_api.dart';
import 'package:load_more_flutter/generated/l10n.dart';
import 'package:load_more_flutter/pages/home_page/people_bloc.dart';
import 'package:load_more_flutter/pages/home_page/people_state.dart';
import 'package:load_more_flutter/util.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static const offsetVisibleThreshold = 50;

  ///
  /// pass [PeopleApi] or [MemoryPersonDataSource] to [PeopleBloc]'s constructor
  ///
  PeopleBloc _bloc;
  StreamSubscription<void> _subscriptionReachMaxItems;
  StreamSubscription<Object> _subscriptionError;

  @override
  void initState() {
    super.initState();

    _bloc = PeopleBloc(PeopleApi());
    // listen error, reach max items
    _subscriptionReachMaxItems = _bloc.loadedAllPeople.listen(_onReachMaxItem);
    _subscriptionError = _bloc.error.listen(_onError);

    // add listener to scroll controller
    _scrollController.addListener(_onScroll);

    // load first page
    _bloc.loadFirstPage.add(null);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _subscriptionError.cancel();
    _subscriptionReachMaxItems.cancel();
    _bloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Load more flutter'),
      ),
      body: RefreshIndicator(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: StreamBuilder<PeopleListState>(
            stream: _bloc.peopleList,
            builder: (BuildContext context,
                AsyncSnapshot<PeopleListState> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      S.of(context).error_occurred(snapshot.error.toString())),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return _buildList(snapshot);
            },
          ),
        ),
        onRefresh: _bloc.refresh,
      ),
    );
  }

  ListView _buildList(AsyncSnapshot<PeopleListState> snapshot) {
    final people = snapshot.data.people;
    final isLoading = snapshot.data.isLoading;
    final error = snapshot.data.error;

    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        if (index < people.length) {
          return ListTile(
            title: Text(people[index].name),
            subtitle: Text(people[index].bio),
            leading: CircleAvatar(
              child: Text(people[index].emoji),
              foregroundColor: Colors.white,
              backgroundColor: Colors.purple,
            ),
            trailing: CircleAvatar(
              child: Text(
                '${index + 1}/${people.length}',
                style: Theme.of(context).textTheme.overline,
              ),
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal,
            ),
          );
        }

        if (error != null) {
          return ListTile(
            title: Text(
              S.of(context).error_occurred_loading_next_page(error.toString()),
              style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 16.0),
            ),
            isThreeLine: false,
            leading: CircleAvatar(
              child: Text(':('),
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Opacity(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
              opacity: isLoading ? 1 : 0,
            ),
          ),
        );
      },
      itemCount: people.length + 1,
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  Future<void> makeAnimation() async {
    final offsetFromBottom =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    if (offsetFromBottom < offsetVisibleThreshold) {
      await _scrollController.animateTo(
        _scrollController.offset - (offsetVisibleThreshold - offsetFromBottom),
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    }
  }

  void _onScroll() {
    // if scroll to bottom of list, then load next page
    if (_scrollController.offset + offsetVisibleThreshold >=
        _scrollController.position.maxScrollExtent) {
      print('_bloc.loadMore.add(null)');
      _bloc.loadMore.add(null);
    }
  }

  void _onReachMaxItem(void _) async {
    // show animation when loaded all data
    await makeAnimation();
    _scaffoldKey.showSnackBar(S.of(context).loaded_all_people);
  }

  void _onError(Object error) {
    _scaffoldKey.showSnackBar(S.of(context).error_occurred(error.toString()));
  }
}
