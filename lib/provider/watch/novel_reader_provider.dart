import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'novel_reader_provider.g.dart';

class NovelReaderState {
  final List<String> content;
  final double offset;
  final int itemPosition;
  final int totalPage;

  const NovelReaderState({
    this.content = const [],
    this.offset = 0,
    this.totalPage = 0,
    this.itemPosition = 0,
  });

  NovelReaderState copyWith({
    List<String>? content,
    double? offset,
    int? itemPosition,
    int? totalPage,
  }) {
    return NovelReaderState(
      content: content ?? this.content,
      totalPage: totalPage ?? this.totalPage,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
    );
  }
}

@riverpod
class NovelReader extends _$NovelReader {
  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();

  @override
  NovelReaderState build() {
    return const NovelReaderState();
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
}
