import 'package:flutter/material.dart';
import 'package:load_more_flutter/people_api.dart';
import 'package:load_more_flutter/people_bloc.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _bloc = PeopleBloc(PeopleApi());
  static const offsetToBottom = 50;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // if scroll to bottom of list, then load next page
      if (_scrollController.offset + offsetToBottom >=
          _scrollController.position.maxScrollExtent) {
        _bloc.loadMore.add(null);
      }
    });

    // load first page
    _bloc.loadMore.add(null);
    _bloc.loadedAllPeople.listen((_) async {
      // show animation when loaded all data
      await makeAnimation();
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Got all data!'),
        ),
      );
    });
  }

  @override
  void dispose() async {
    _scrollController.dispose();
    await _bloc.dispose();

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
        child: StreamBuilder<PeopleListState>(
          stream: _bloc.peopleList,
          builder:
              (BuildContext context, AsyncSnapshot<PeopleListState> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error ${snapshot.error}',
                  style: Theme.of(context).textTheme.body1,
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final people = snapshot.data.people;

            return ListView.separated(
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
                  );
                }

                return Center(
                  child: Opacity(
                    opacity: snapshot.data.isLoading ? 1.0 : 0.0,
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              itemCount: people.length + 1,
              separatorBuilder: (BuildContext context, int index) => Divider(),
            );
          },
        ),
        onRefresh: _bloc.refresh,
      ),
    );
  }

  Future<void> makeAnimation() async {
    final offsetFromBottom =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    if (offsetFromBottom < 50) {
      await _scrollController.animateTo(
        _scrollController.offset - (50 - offsetFromBottom),
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    }
  }
}
