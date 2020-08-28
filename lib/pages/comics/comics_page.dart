import 'dart:async';

import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/comics/comic_repository_impl.dart';
import 'package:load_more_flutter/generated/l10n.dart';
import 'package:load_more_flutter/pages/comics/bloc/comic.dart';
import 'package:load_more_flutter/pages/comics/widgets/widgets.dart';
import 'package:load_more_flutter/util.dart';

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
        _scaffoldKey.showSnackBar(S.of(context).loaded_all_people);
        makeAnimation();
      }
      if (message is ErrorMessage) {
        final error = message.error;
        _scaffoldKey
            .showSnackBar(S.of(context).error_occurred(error.toString()));
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
              child: HeaderItem(
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
              child: HeaderItem(
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
              child: HeaderItem(
                headerText: 'Recent updated comics',
              ),
            ),
            SliverPadding(
              sliver: StreamBuilder<ComicsListState>(
                stream: _comicsBloc.comicsList$,
                initialData: _comicsBloc.getComicsList(),
                builder: (context, snapshot) => _buildGridView(snapshot.data),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            SliverToBoxAdapter(
              child: StreamBuilder<ComicsListState>(
                stream: _comicsBloc.comicsList$,
                initialData: _comicsBloc.getComicsList(),
                builder: (context, snapshot) => _buildBottomItem(snapshot.data),
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

  Widget _buildGridView(ComicsListState state) {
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
  }

  Widget _buildBottomItem(ComicsListState state) {
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
  }
}
