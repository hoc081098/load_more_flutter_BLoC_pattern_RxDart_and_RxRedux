import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:load_more_flutter/data/model/comic.dart';
import 'package:meta/meta.dart';

part 'comics_state_and_action.g.dart';

abstract class ComicsListState
    implements Built<ComicsListState, ComicsListStateBuilder> {
  BuiltList<Comic> get comics;

  bool get isFirstPageLoading;

  @nullable
  Object get firstPageError;

  bool get isNextPageLoading;

  @nullable
  Object get nextPageError;

  bool get getAllComics;

  int get page;

  ComicsListState._();

  factory ComicsListState([Function(ComicsListStateBuilder b) updates]) =
      _$ComicsListState;

  factory ComicsListState.initial() {
    return ComicsListState(
      (b) => b
        ..isFirstPageLoading = true
        ..firstPageError = null
        ..isNextPageLoading = false
        ..nextPageError = null
        ..getAllComics = false
        ..page = 0,
    );
  }
}

@immutable
abstract class Message {}

class LoadAllComicsMessage implements Message {
  const LoadAllComicsMessage();
}

class ErrorMessage implements Message {
  final Object error;

  const ErrorMessage(this.error);
}

@immutable
abstract class Action {
  ///
  /// Pure function return new view state from current view state and an action
  ///
  ComicsListState reducer(ComicsListState state);
}

///
/// User's actions
///

class LoadNextPageAction implements Action {
  const LoadNextPageAction();

  @override
  ComicsListState reducer(ComicsListState state) => state;
}

class LoadFirstPageAction implements Action {
  const LoadFirstPageAction();

  @override
  ComicsListState reducer(ComicsListState state) => state;
}

class RefreshListAction implements Action {
  final Completer<void> completer;

  const RefreshListAction(this.completer);

  @override
  ComicsListState reducer(ComicsListState state) => state;
}

class RetryNextPageAction implements Action {
  const RetryNextPageAction();

  @override
  ComicsListState reducer(ComicsListState state) => state;
}

class RetryFirstPageAction implements Action {
  const RetryFirstPageAction();

  @override
  ComicsListState reducer(ComicsListState state) => state;
}

///
/// Action triggered by SideEffect
///

class PageLoadedAction implements Action {
  final BuiltList<Comic> comics;
  final bool isFirstPage;

  const PageLoadedAction(this.comics, this.isFirstPage);

  @override
  ComicsListState reducer(ComicsListState state) {
    if (isFirstPage) {
      return state.rebuild(
        (b) => b
          ..isFirstPageLoading = false
          ..firstPageError = null
          ..comics = comics.toBuilder()
          ..getAllComics = comics.isEmpty
          ..page = b.page + 1,
      );
    } else {
      final added = <String>{};
      bool predicate(Comic comic) => added.add(comic.link);

      final newComics = [
        ...state.comics.where(predicate),
        ...comics.where(predicate),
      ];

      return state.rebuild(
        (b) => b
          ..isFirstPageLoading = false
          ..firstPageError = null
          ..nextPageError = null
          ..isNextPageLoading = false
          ..comics.replace(newComics)
          ..getAllComics = comics.isEmpty
          ..page = b.page + 1,
      );
    }
  }
}

class PageLoadingAction implements Action {
  final bool isFirstPage;

  const PageLoadingAction(this.isFirstPage);

  @override
  ComicsListState reducer(ComicsListState state) {
    if (isFirstPage) {
      return state.rebuild((b) => b..isFirstPageLoading = true);
    } else {
      return state.rebuild((b) => b..isNextPageLoading = true);
    }
  }
}

class ErrorLoadingPageAction implements Action {
  final error;
  final bool isFirstPage;

  const ErrorLoadingPageAction(this.error, this.isFirstPage);

  @override
  ComicsListState reducer(ComicsListState state) {
    if (isFirstPage) {
      return state.rebuild(
        (b) => b
          ..isFirstPageLoading = false
          ..firstPageError = error,
      );
    } else {
      return state.rebuild(
        (b) => b
          ..isNextPageLoading = false
          ..nextPageError = error,
      );
    }
  }
}
