import 'package:flutter/material.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'manga_reader_provider.g.dart';

class MangaReaderState {
  final List<String> content;
  final double offset;
  final int itemPosition;
  final int totalPage;
  final MangaReadMode readMode;

  const MangaReaderState({
    this.content = const [],
    this.offset = 0,
    this.totalPage = 0,
    this.itemPosition = 0,
    this.readMode = MangaReadMode.standard,
  });

  MangaReaderState copyWith({
    List<String>? content,
    double? offset,
    int? itemPosition,
    int? totalPage,
    MangaReadMode? readMode,
  }) {
    return MangaReaderState(
      content: content ?? this.content,
      totalPage: totalPage ?? this.totalPage,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
      readMode: readMode ?? this.readMode,
    );
  }
}

@riverpod
class MangaReader extends _$MangaReader {
  @override
  MangaReaderState build(
    int epIndex,
    int total,
    ExtensionMangaWatch data, {
    Map<String, String>? headers,
  }) {
    final initState = MangaReaderState(content: data.urls, totalPage: total);
    ref.onDispose(() {
      pageController.dispose();
    });
    initListener();
    return initState;
  }

  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();
  final pageController = PageController();

  void initListener() {
    itemPositionsListener.itemPositions.addListener(_whenItemPositionChange);
    scrollOffsetListener.changes.listen(_whenScrollOffsetChange);
    pageController.addListener(() {
      logger.info('eee');
    });
  }

  void _whenItemPositionChange() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final index = positions.first.index;
      state = state.copyWith(itemPosition: index);
    }
  }

  void _whenScrollOffsetChange(double val) {
    state = state.copyWith(offset: val);
  }

  void changeReadMode(MangaReadMode mode) {
    state = state.copyWith(readMode: mode);
  }

  // void reattach() {
  //   initListener();
  // }
}
