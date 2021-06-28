import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:load_more_flutter/data/comics/comic_repository_impl.dart';
import 'package:load_more_flutter/generated/l10n.dart';
import 'package:load_more_flutter/pages/comics/bloc/comics_bloc.dart';
import 'package:load_more_flutter/pages/comics/bloc/comics_effects.dart';
import 'package:load_more_flutter/pages/comics/bloc/comics_state_and_action.dart';
import 'package:load_more_flutter/pages/comics/bloc/comics_usecase.dart';
import 'package:load_more_flutter/pages/comics/widgets/widgets.dart';
import 'package:load_more_flutter/util.dart';

class ComicsHorizontalListView extends StatefulWidget {
  final ComicsListType listType;

  const ComicsHorizontalListView({Key key, this.listType}) : super(key: key);

  @override
  _ComicsHorizontalListViewState createState() =>
      _ComicsHorizontalListViewState();
}

class _ComicsHorizontalListViewState extends State<ComicsHorizontalListView>
    with DisposeBagMixin {
  static const offsetVisibleThreshold = 50.0;

  ComicsBloc _comicsBloc;
  Object token;
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    token ??= _comicsBloc.message$.listen((message) {
      if (message is LoadAllComicsMessage) {
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
    _comicsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: StreamBuilder<ComicsListState>(
        stream: _comicsBloc.comicsList$,
        initialData: _comicsBloc.getComicsList(),
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

          return _buildListView(state);
        },
      ),
    );
  }

  ListView _buildListView(ComicsListState state) {
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
  }
}
