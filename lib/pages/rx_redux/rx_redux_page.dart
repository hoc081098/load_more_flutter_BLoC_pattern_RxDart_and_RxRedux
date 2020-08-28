import 'dart:async';

import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/people/memory_person_data_source.dart';
import 'package:load_more_flutter/generated/l10n.dart';
import 'package:load_more_flutter/pages/rx_redux/bloc/bloc.dart';
import 'package:load_more_flutter/util.dart';
import 'package:load_more_flutter/widgets/people_item.dart';

class RxReduxPage extends StatefulWidget {
  @override
  _RxReduxPageState createState() => _RxReduxPageState();
}

class _RxReduxPageState extends State<RxReduxPage> {
  static const offsetVisibleThreshold = 50.0;

  PeopleRxReduxBloc _rxReduxBloc;
  StreamSubscription<Message> _subscription;

  ScrollController _scrollController;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();

    _scaffoldKey = GlobalKey();

    ///
    /// Setup [SimplePeopleBloc]
    ///
    final dataSource = MemoryPersonDataSource(context: context);
    final effects = PeopleEffects(dataSource);
    _rxReduxBloc = PeopleRxReduxBloc(effects);

    ///
    /// Listen [_simplePeopleBloc.message$]
    /// And load first page
    ///
    _subscription = _rxReduxBloc.message$.listen((message) {
      if (message is LoadAllPeopleMessage) {
        _scaffoldKey.showSnackBar(S.of(context).loaded_all_people);
        makeAnimation();
      }
      if (message is ErrorMessage) {
        final error = message.error;
        _scaffoldKey
            .showSnackBar(S.of(context).error_occurred(error.toString()));
      }
    });
    _rxReduxBloc.loadFirstPage();

    ///
    ///
    ///
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription.cancel();
    _rxReduxBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('RxRedux page'),
      ),
      body: RefreshIndicator(
        onRefresh: _rxReduxBloc.refresh,
        child: Container(
          constraints: BoxConstraints.expand(),
          child: StreamBuilder<PeopleListState>(
            stream: _rxReduxBloc.peopleList$,
            initialData: _rxReduxBloc.getPeopleList(),
            builder: (context, snapshot) {
              final state = snapshot.data;
              if (state.isFirstPageLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              }

              if (state.firstPageError != null) {
                return _buildFirstPageError(state);
              }

              final people = state.people;
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                controller: _scrollController,
                itemCount: people.length + 1,
                itemBuilder: (context, index) {
                  if (index < people.length) {
                    return PersonListItem(
                      index: index,
                      length: people.length,
                      item: people[index],
                      key: ObjectKey(people[index]),
                    );
                  }

                  if (state.isNextPageLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (state.nextPageError != null) {
                    return _buildNextPageError(state);
                  }

                  return Container(width: 0, height: 0);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPageError(PeopleListState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                S.of(context).error_occurred_loading_next_page(
                    state.firstPageError.toString()),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              isThreeLine: false,
              leading: CircleAvatar(
                child: Icon(
                  Icons.mood_bad,
                  color: Colors.white,
                ),
                backgroundColor: Colors.redAccent,
              ),
            ),
            RaisedButton(
              child: Text(S.of(context).retry),
              padding: const EdgeInsets.all(16),
              onPressed: _rxReduxBloc.retryFirstPage,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPageError(PeopleListState state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              S.of(context).error_occurred_loading_next_page(
                  state.nextPageError.toString()),
              style: Theme.of(context).textTheme.subtitle2,
            ),
            isThreeLine: false,
            leading: CircleAvatar(
              child: Icon(
                Icons.mood_bad,
                color: Colors.white,
              ),
              backgroundColor: Colors.redAccent,
            ),
          ),
          FlatButton.icon(
            padding: const EdgeInsets.all(16),
            icon: Icon(Icons.refresh),
            label: Text(S.of(context).retry),
            onPressed: _rxReduxBloc.retryNextPage,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;

    if (offset + offsetVisibleThreshold >= max) {
      _rxReduxBloc.loadNextPage();
    }
  }

  Future<void> makeAnimation() async {
    final max = _scrollController.position.maxScrollExtent;

    await _scrollController.animateTo(
      max - offsetVisibleThreshold * 1.5,
      duration: Duration(milliseconds: 2000),
      curve: Curves.easeOut,
    );
  }
}
