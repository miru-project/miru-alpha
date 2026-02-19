import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/utils/setting_dir_index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'manga_reader_provider.g.dart';

class MangaReaderState {
  final List<String> content;
  final double offset;
  final int itemPosition;
  final int totalPage;
  final MangaReadMode readMode;
  final bool isZoom;

  const MangaReaderState({
    this.content = const [],
    this.offset = 0,
    this.totalPage = 0,
    this.itemPosition = 0,
    this.readMode = MangaReadMode.standard,
    this.isZoom = false,
  });

  MangaReaderState copyWith({
    List<String>? content,
    double? offset,
    int? itemPosition,
    int? totalPage,
    MangaReadMode? readMode,
    bool? isZoom,
  }) {
    return MangaReaderState(
      content: content ?? this.content,
      totalPage: totalPage ?? this.totalPage,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
      readMode: readMode ?? this.readMode,
      isZoom: isZoom ?? this.isZoom,
    );
  }
}

@riverpod
class MangaReader extends _$MangaReader {
  bool isAdjusting = false;
  @override
  MangaReaderState build(
    int epIndex,
    int total,
    ExtensionMangaWatch? data, {
    Map<String, String>? headers,
  }) {
    final readMode = MiruSettings.getSettingSync<MangaReadMode>(
      SettingKey.mangaReadingMode,
    );
    final initState = MangaReaderState(
      content: data?.urls ?? [],
      totalPage: data?.urls.length ?? 0,
      readMode: readMode,
    );
    ref.onDispose(() {
      pageController.dispose();
      itemPositionsListener.itemPositions.removeListener(
        _whenItemPositionChange,
      );
    });
    initListener();
    return initState;
  }

  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();
  final ExtendedPageController pageController = ExtendedPageController();

  void initListener() {
    itemPositionsListener.itemPositions.addListener(_whenItemPositionChange);
    scrollOffsetListener.changes.asBroadcastStream().listen(
      _whenScrollOffsetChange,
    );
  }

  void _whenItemPositionChange() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final index = positions.first.index;
      setPageNumber(index);
    }
  }

  void _whenScrollOffsetChange(double val) {
    state = state.copyWith(offset: val);
  }

  void changeReadMode(MangaReadMode mode) {
    state = state.copyWith(readMode: mode);
  }

  void changeZoomMode(bool isZoom) {
    state = state.copyWith(isZoom: isZoom);
  }

  // Set the page number
  void setPageNumber(int page) {
    if (isAdjusting) return;
    EpisodeNotifier.progress = page;
    EpisodeNotifier.totalProgress = state.totalPage;
    state = state.copyWith(itemPosition: page);
  }

  // Jump to the page and set the page number
  void jumpTo(int page) {
    setPageNumber(page);
    switch (state.readMode) {
      case MangaReadMode.webTonn:
        isAdjusting = true;
        itemScrollController
            .scrollTo(index: page, duration: const Duration(milliseconds: 100))
            .then((_) {
              isAdjusting = false;
            });
      default:
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
    }
  }
}
