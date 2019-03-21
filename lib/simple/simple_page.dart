import 'dart:async';

import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/memory_person_data_source.dart';
import 'package:load_more_flutter/model/person.dart';
import 'package:load_more_flutter/simple/people_state.dart';
import 'package:load_more_flutter/simple/simple_people_bloc.dart';

class SimplePage extends StatefulWidget {
  @override
  _SimplePageState createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> {
  static const offsetVisibleThreshold = 50.0;

  SimplePeopleBloc _simplePeopleBloc;
  StreamSubscription<Message> _subscription;

  ScrollController _scrollController;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();

    _scaffoldKey = GlobalKey();

    _simplePeopleBloc =
        SimplePeopleBloc(MemoryPersonDataSource(context: context));
    _subscription = _simplePeopleBloc.message$.listen((message) {
      if (message is LoadAllPeopleMessage) {
        _showSnackBar('Loaded all people!');
      }
      if (message is ErrorMessage) {
        final error = message.error;
        _showSnackBar('Error occurred $error');
      }
    });
    _simplePeopleBloc.load();

    _scrollController = ScrollController()..addListener(_onScroll);
  }

  _showSnackBar(String message) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription.cancel();
    _simplePeopleBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Simple page'),
      ),
      body: RefreshIndicator(
        onRefresh: _simplePeopleBloc.refresh,
        child: Container(
          constraints: BoxConstraints.expand(),
          child: StreamBuilder<PeopleListState>(
            stream: _simplePeopleBloc.peopleList$,
            initialData: _simplePeopleBloc.peopleList$.value,
            builder: (context, snapshot) {
              final data = snapshot.data;
              final people = data.people;
              final error = data.error;
              final isLoading = data.isLoading;

              return ListView.builder(
                physics: BouncingScrollPhysics(),
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index < people.length) {
                    return PersonListItem(
                      index: index,
                      length: people.length,
                      item: people[index],
                      key: ObjectKey(people[index]),
                    );
                  }

                  if (error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              'An error occurred while loading data... Try refresh!',
                              style: Theme.of(context).textTheme.subtitle,
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
                            label: Text('Retry'),
                            onPressed: _simplePeopleBloc.retry,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        ],
                      ),
                    );
                  }

                  return LoadingIndicator(
                    isLoading: isLoading,
                    key: ValueKey(isLoading),
                  );
                },
                itemCount: people.length + 1,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;

    if (offset + offsetVisibleThreshold >= max) {
      _simplePeopleBloc.load();
    }
  }

  Future<void> makeAnimation() async {
    final max = _scrollController.position.maxScrollExtent;

    await _scrollController.animateTo(
      max - offsetVisibleThreshold,
      duration: Duration(milliseconds: 2000),
      curve: Curves.easeOut,
    );
  }
}

class LoadingIndicator extends StatefulWidget {
  final bool isLoading;

  const LoadingIndicator({Key key, this.isLoading}) : super(key: key);

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin<LoadingIndicator> {
  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    if (widget.isLoading) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
}

class PersonListItem extends StatefulWidget {
  final int index;
  final int length;
  final Person item;

  const PersonListItem({Key key, this.index, this.length, this.item})
      : super(key: key);

  @override
  _PersonListItemState createState() => _PersonListItemState();
}

class _PersonListItemState extends State<PersonListItem>
    with TickerProviderStateMixin<PersonListItem> {
  AnimationController _scaleController;
  Animation<double> _scale;

  Animation<Offset> _position;
  AnimationController _positionController;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    _positionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _position = Tween(begin: Offset(2.0, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _positionController,
        curve: Curves.easeOut,
      ),
    );

    _scaleController.forward();
    _positionController.forward();
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final index = widget.index;
    final length = widget.length;

    return ScaleTransition(
      child: SlideTransition(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.shade800,
              spreadRadius: 2,
              blurRadius: 10,
            )
          ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.bio),
              leading: CircleAvatar(
                child: Text(item.emoji),
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple,
              ),
              trailing: CircleAvatar(
                child: Text(
                  '${index + 1}/$length',
                  style: Theme.of(context).textTheme.overline,
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
              ),
            ),
          ),
        ),
        position: _position,
      ),
      scale: _scale,
    );
  }
}
