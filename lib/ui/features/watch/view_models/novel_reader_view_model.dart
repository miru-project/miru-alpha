import 'package:flutter/widgets.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'novel_reader_view_model.g.dart';

class NovelReaderViewState {
  final List<String> content;
  final double offset;
  final int itemPosition;
  final NovelReadMode readMode;
  final int totalPage;

  const NovelReaderViewState({
    this.content = const [],
    this.offset = 0,
    this.totalPage = 0,
    this.itemPosition = 0,
    this.readMode = NovelReadMode.standard,
  });

  NovelReaderViewState copyWith({
    List<String>? content,
    double? offset,
    int? itemPosition,
    NovelReadMode? readMode,
    int? totalPage,
  }) {
    return NovelReaderViewState(
      content: content ?? this.content,
      totalPage: totalPage ?? this.totalPage,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
      readMode: readMode ?? this.readMode,
    );
  }
}

@riverpod
class NovelReaderViewModel extends _$NovelReaderViewModel {
  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();
  final pageController = PageController();
  bool isAdjusting = false;

  @override
  NovelReaderViewState build({
    required List<String>? content,
    required String? localPath,
  }) {
    final readMode = MiruSettings.getSettingSync<NovelReadMode>(
      SettingKey.novelReadingMode,
    );
    final state = NovelReaderViewState(
      content: content ?? [],
      readMode: readMode,
    );
    return state;
  }

  void putContent(List<String> content) {
    state = state.copyWith(content: content, totalPage: content.length - 1);
  }

  void setContent(List<String> content) {
    state = state.copyWith(content: content, totalPage: content.length - 1);
  }

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
