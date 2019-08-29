import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/comics/comic_repository_impl.dart';
import 'package:load_more_flutter/data/model/comic.dart';
import 'package:load_more_flutter/generated/i18n.dart';
import 'package:load_more_flutter/pages/comics/comics_effects.dart';
import 'package:load_more_flutter/pages/comics/comics_rx_redux_bloc.dart';
import 'package:load_more_flutter/pages/comics/comics_state_and_action.dart';
import 'package:load_more_flutter/pages/comics/comics_usecase.dart';

enum ComicsListType { newest, mostViewed, updated }

class ComicsPage extends StatefulWidget {
  @override
  _ComicsPageState createState() => _ComicsPageState();
}

class _ComicsPageState extends State<ComicsPage> {
  static const offsetVisibleThreshold = 200;

  ComicsBloc _comicsBloc;
  StreamSubscription<Message> _subscription;

  ScrollController _scrollController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _initBloc();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _initBloc() {
    _comicsBloc = ComicsBloc(
      ComicsEffects(
        GetUpdatedComicsUseCase(
          ComicsRepositoryImpl(),
        ),
      ),
      ComicsListType.updated.toString(),
    );

    _subscription = _comicsBloc.message$.listen((message) {
      if (message is LoadAllComicsMessage) {
        _showSnackBar(S.of(context).loaded_all_people);
        makeAnimation();
      }
      if (message is ErrorMessage) {
        final error = message.error;
        _showSnackBar(S.of(context).error_occurred(error.toString()));
      }
    });
    _comicsBloc.loadFirstPage();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;

    if (offset + offsetVisibleThreshold >= max) {
      _comicsBloc.loadNextPage();
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
    _comicsBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Comics page'),
      ),
      body: RefreshIndicator(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Header(
                headerText: 'Newest comis',
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 250,
                child: ComicsHorizontalListView(
                  listType: ComicsListType.newest,
                  key: ValueKey(ComicsListType.newest),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Header(
                headerText: 'Most viewed comics',
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 250,
                child: ComicsHorizontalListView(
                  listType: ComicsListType.mostViewed,
                  key: ValueKey(ComicsListType.mostViewed),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Header(
                headerText: 'Recent updated comics',
              ),
            ),
            SliverPadding(
              sliver: StreamBuilder<ComicsListState>(
                stream: _comicsBloc.comicsList$,
                initialData: _comicsBloc.comicsList$.value,
                builder: (context, snapshot) {
                  final state = snapshot.data;

                  if (state.isFirstPageLoading) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(64),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state.firstPageError != null) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: Center(
                          child: Container(
                            width: 250 / 1.618,
                            child: ErrorItemWidget(
                              errorText: state.firstPageError.toString(),
                              onPressed: _comicsBloc.retryFirstPage,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ComicItemWidget(comic: state.comics[index]);
                      },
                      childCount: state.comics.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.618,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                  );
                },
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            SliverToBoxAdapter(
              child: StreamBuilder<ComicsListState>(
                stream: _comicsBloc.comicsList$,
                initialData: _comicsBloc.comicsList$.value,
                builder: (context, snapshot) {
                  final state = snapshot.data;

                  if (state.isNextPageLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(64),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (state.nextPageError != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: Container(
                          width: 250 / 1.618,
                          child: ErrorItemWidget(
                            errorText: state.nextPageError.toString(),
                            onPressed: _comicsBloc.retryNextPage,
                          ),
                        ),
                      ),
                    );
                  }

                  return Container(width: 0, height: 0);
                },
              ),
            )
          ],
        ),
        onRefresh: _comicsBloc.refresh,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 2000),
            curve: Curves.easeOut,
          );
        },
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    Key key,
    @required this.headerText,
  }) : super(key: key);

  final String headerText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xff3A3A3A),
            boxShadow: const [
              BoxShadow(
                color: Color(0xff5A5A5A),
                blurRadius: 2,
                offset: Offset(1, 1),
              )
            ],
          ),
          child: Text(
            headerText,
            style: Theme.of(context).textTheme.subtitle.copyWith(
                  color: const Color(0xffFFAB00),
                ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}

class ComicsHorizontalListView extends StatefulWidget {
  final ComicsListType listType;

  const ComicsHorizontalListView({Key key, this.listType}) : super(key: key);

  @override
  _ComicsHorizontalListViewState createState() =>
      _ComicsHorizontalListViewState();
}

class _ComicsHorizontalListViewState extends State<ComicsHorizontalListView> {
  static const offsetVisibleThreshold = 50.0;

  ComicsBloc _comicsBloc;
  StreamSubscription<Message> _subscription;

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _initBloc();

    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _initBloc() {
    const _comicRepo = ComicsRepositoryImpl();

    final comicsUseCase = () {
      switch (widget.listType) {
        case ComicsListType.newest:
          return GetNewestComicsUseCase(_comicRepo);
        case ComicsListType.mostViewed:
          return GetMostViewedComicsUseCase(_comicRepo);
        default:
          return null;
      }
    }();
    _comicsBloc = ComicsBloc(
      ComicsEffects(comicsUseCase),
      widget.listType.toString(),
    );

    _subscription = _comicsBloc.message$.listen((message) {
      if (message is LoadAllComicsMessage) {
        _showSnackBar(S.of(context).loaded_all_people);
        makeAnimation();
      }
      if (message is ErrorMessage) {
        final error = message.error;
        _showSnackBar(S.of(context).error_occurred(error.toString()));
      }
    });
    _comicsBloc.loadFirstPage();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;

    if (offset + offsetVisibleThreshold >= max) {
      _comicsBloc.loadNextPage();
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

  _showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(
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
    _comicsBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: StreamBuilder<ComicsListState>(
        stream: _comicsBloc.comicsList$,
        initialData: _comicsBloc.comicsList$.value,
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
            return Center(
              child: AspectRatio(
                aspectRatio: 1 / 1.618,
                child: ErrorItemWidget(
                  errorText: state.firstPageError.toString(),
                  onPressed: _comicsBloc.retryFirstPage,
                ),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            itemCount: state.comics.length + 1,
            itemBuilder: (context, index) {
              if (index < state.comics.length) {
                return ComicItemWidget(comic: state.comics[index]);
              }

              if (state.isNextPageLoading) {
                return AspectRatio(
                  aspectRatio: 1 / 1.618,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (state.nextPageError != null) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: 1 / 1.618,
                    child: ErrorItemWidget(
                      errorText: state.nextPageError.toString(),
                      onPressed: _comicsBloc.retryNextPage,
                    ),
                  ),
                );
              }

              return Container(width: 0, height: 0);
            },
          );
        },
      ),
    );
  }
}

class ComicItemWidget extends StatelessWidget {
  final Comic comic;

  const ComicItemWidget({Key key, @required this.comic})
      : assert(comic != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: comic.thumbnail,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      const Color(0xffFFAB00),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error,
                        color: const Color(0xffFFAB00),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Load image error',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      comic.title,
                      style: Theme.of(context).textTheme.title.copyWith(
                            fontSize: 14,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            comic.view,
                            style: Theme.of(context).textTheme.title.copyWith(
                                  fontSize: 13,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    for (var chapter in comic.lastChapters)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                chapter.chapterName,
                                style:
                                    Theme.of(context).textTheme.title.copyWith(
                                          fontSize: 12,
                                        ),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                chapter.time,
                                style:
                                    Theme.of(context).textTheme.title.copyWith(
                                          fontSize: 12,
                                        ),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      aspectRatio: 1 / 1.618,
    );
  }
}

class ErrorItemWidget extends StatelessWidget {
  final String errorText;
  final void Function() onPressed;

  const ErrorItemWidget({
    Key key,
    @required this.errorText,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          errorText,
          style: Theme.of(context).textTheme.subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: RaisedButton(
            child: Text(S.of(context).retry),
            padding: const EdgeInsets.all(16),
            onPressed: onPressed,
            color: const Color(0xff3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: const Color(0xffFFAB00),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
