import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:load_more_flutter/data/people/memory_person_data_source.dart';
import 'package:load_more_flutter/generated/l10n.dart';
import 'package:load_more_flutter/pages/simple/people_interactor.dart';
import 'package:load_more_flutter/pages/simple/people_state.dart';
import 'package:load_more_flutter/pages/simple/simple_people_bloc.dart';
import 'package:load_more_flutter/util.dart';
import 'package:load_more_flutter/widgets/people_item.dart';

class SimplePage extends StatefulWidget {
  @override
  _SimplePageState createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> with DisposeBagMixin {
  static const offsetVisibleThreshold = 50.0;

  SimplePeopleBloc _simplePeopleBloc;
  final _scrollController = ScrollController();
  Object listenToken;

  @override
  void initState() {
    super.initState();

    /// Setup [SimplePeopleBloc].
    final dataSource = MemoryPersonDataSource(context: context);
    final interactor = PeopleInteractor(dataSource);
    _simplePeopleBloc = SimplePeopleBloc(interactor);

    /// Load first page.
    _simplePeopleBloc.load();

    /// Load next page when reaching bottom edge.
    _scrollController
        .nearBottomEdge$(offsetVisibleThreshold)
        .listen((_) => _simplePeopleBloc.load())
        .disposedBy(bag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Listen [_simplePeopleBloc.message$] only once.
    listenToken ??= _simplePeopleBloc.message$.listen((message) {
      if (message is LoadAllPeopleMessage) {
        context.showSnackBar(S.of(context).loaded_all_people);
        makeAnimation();
      }
      if (message is ErrorMessage) {
        final error = message.error;
        context.showSnackBar(S.of(context).error_occurred(error.toString()));
      }
    }).disposedBy(bag);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _simplePeopleBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              S.of(context).error_occurred_loading_next_page(
                                  error.toString()),
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

  Future<void> makeAnimation() async {
    final max = _scrollController.position.maxScrollExtent;

    await _scrollController.animateTo(
      max - offsetVisibleThreshold * 1.5,
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
