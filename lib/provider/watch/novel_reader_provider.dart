import 'package:flutter/widgets.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/store/storage_index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'novel_reader_provider.g.dart';

class NovelReaderState {
  final List<String> content;
  final double offset;
  final int itemPosition;
  final NovelReadMode readMode;
  final int totalPage;

  const NovelReaderState({
    this.content = const [],
    this.offset = 0,
    this.totalPage = 0,
    this.itemPosition = 0,
    this.readMode = NovelReadMode.standard,
  });

  NovelReaderState copyWith({
    List<String>? content,
    double? offset,
    int? itemPosition,
    int? totalPage,
    NovelReadMode? readMode,
  }) {
    return NovelReaderState(
      content: content ?? this.content,
      totalPage: totalPage ?? this.totalPage,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
      readMode: readMode ?? this.readMode,
    );
  }
}

@riverpod
class NovelReader extends _$NovelReader {
  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();
  final pageController = PageController();
  bool isAdjusting = false;

  @override
  NovelReaderState build(List<String>? content, String? localPath) {
    final readMode = MiruSettings.getSettingSync<NovelReadMode>(
      SettingKey.novelReadingMode,
    );
    final state = NovelReaderState(content: content ?? [], readMode: readMode);
    return state;
  }

  void putContent(List<String> content) {
    state = state.copyWith(content: content, totalPage: content.length - 1);
  }

  void initListener() {
    itemPositionsListener.itemPositions.addListener(_whenItemPositionChange);
    scrollOffsetListener.changes.listen(_whenScrollOffsetChange);
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

  void setContent(List<String> content) {
    state = state.copyWith(content: content, totalPage: content.length - 1);
  }

  // Set the page number
  void setPageNumber(int page) {
    if (isAdjusting) return;
    state = state.copyWith(itemPosition: page);
  }

  void jumpTo(int page) {
    setPageNumber(page);
    switch (state.readMode) {
      case NovelReadMode.standard:
        isAdjusting = true;
        itemScrollController
            .scrollTo(index: page, duration: const Duration(milliseconds: 100))
            .then((_) {
              isAdjusting = false;
            });
      case NovelReadMode.rightToLeft:
        isAdjusting = true;
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      case NovelReadMode.webToon:
        isAdjusting = true;
        itemScrollController.scrollTo(
          index: page,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      default:
        throw Exception("Unsupported read mode");
    }
  }
}
