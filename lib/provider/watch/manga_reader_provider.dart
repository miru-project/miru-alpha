import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MangaProvider {
  static final _mangaReaderProvider =
      NotifierProvider.autoDispose<MangaReaderProvider, MangaReaderState>(
        MangaReaderProvider.new,
      );
  static late NotifierProvider<MangaEpisodeNotifier, MangaEpisodeNotifierState>
  _episodeNotifier;

  static NotifierProvider<MangaReaderProvider, MangaReaderState> get provider =>
      _mangaReaderProvider;
  static NotifierProvider<MangaEpisodeNotifier, MangaEpisodeNotifierState>
  get epProvider => _episodeNotifier;

  static void initEpisode(
    List<ExtensionEpisodeGroup> epGroup,
    String name,
    int selectedGroupIndex,
    int selectedEpisodeIndex,
  ) {
    _episodeNotifier =
        NotifierProvider.autoDispose<
          MangaEpisodeNotifier,
          MangaEpisodeNotifierState
        >(MangaEpisodeNotifier.new);
  }
}

class MangaReaderState {
  final List<String> content;
  // final ItemScrollController? itemScrollController;
  // final ItemPositionsListener? itemPositionsListener;
  // final ScrollOffsetController? scrollOffsetController;
  // final ScrollOffsetListener? scrollOffsetListener;
  final double offset;
  final int itemPosition;
  final int totalPage;
  const MangaReaderState({
    this.content = const [],
    // this.itemPositionsListener,
    // this.itemScrollController,
    // this.scrollOffsetController,
    // this.scrollOffsetListener,
    this.offset = 0,
    this.totalPage = 0,
    this.itemPosition = 0,
  });

  MangaReaderState copyWith({
    List<String>? content,
    ItemScrollController? itemScrollController,
    ItemPositionsListener? itemPositionsListener,
    ScrollOffsetController? scrollOffsetController,
    ScrollOffsetListener? scrollOffsetListener,
    double? offset,
    int? itemPosition,
    int? totalPage,
  }) {
    return MangaReaderState(
      content: content ?? this.content,
      totalPage: totalPage ?? this.totalPage,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
    );
  }
}

class MangaReaderProvider extends Notifier<MangaReaderState> {
  MangaReaderProvider() : _initialContent = const [];

  final List<String> _initialContent;
  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();

  @override
  MangaReaderState build() {
    final content = _initialContent;
    return MangaReaderState(
      content: content,
      totalPage: content.isNotEmpty ? content.length - 1 : 0,
    );
  }

  void putContent(List<String> content) {
    state = state.copyWith(content: content, totalPage: content.length - 1);
  }

  void initListener() {
    itemPositionsListener.itemPositions.addListener(_whenItemPositionChange);
    scrollOffsetListener.changes.listen(_whenScrollOffsetChange);
  }

  void _whenItemPositionChange() {
    final index = itemPositionsListener.itemPositions.value.first.index;

    state = state.copyWith(itemPosition: index);
  }

  void _whenScrollOffsetChange(double val) {
    state = state.copyWith(offset: val);
  }

  void setContent(List<String> content) {
    state = state.copyWith(content: content, totalPage: content.length - 1);
  }
}

class MangaEpisodeNotifierState {
  final List<ExtensionEpisodeGroup> epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;
  MangaEpisodeNotifierState({
    this.epGroup = const [],
    this.selectedGroupIndex = 0,
    this.name = '',
    this.selectedEpisodeIndex = 0,
  });
  MangaEpisodeNotifierState copyWith({
    List<ExtensionEpisodeGroup>? epGroup,
    String? name,
    bool? flag,
    int? selectedGroupIndex,
    int? selectedEpisodeIndex,
  }) {
    return MangaEpisodeNotifierState(
      epGroup: epGroup ?? this.epGroup,
      name: name ?? this.name,
      selectedGroupIndex: selectedGroupIndex ?? this.selectedGroupIndex,
      selectedEpisodeIndex: selectedEpisodeIndex ?? this.selectedEpisodeIndex,
    );
  }
}

class MangaEpisodeNotifier extends Notifier<MangaEpisodeNotifierState> {
  MangaEpisodeNotifier() {
    ref.onDispose(() {
      try {
        DatabaseService.putHistory(
          History(
            title: state.name,
            package: package,
            type: type.toString(),
            episodeGroupId: state.selectedGroupIndex,
            episodeId: state.selectedEpisodeIndex,
            progress: state.selectedEpisodeIndex.toString(),
            cover: imageUrl,
            totalProgress: state.epGroup[state.selectedGroupIndex].urls.length
                .toString(),
            episodeTitle: state
                .epGroup[state.selectedGroupIndex]
                .urls[state.selectedEpisodeIndex]
                .name,
            url: detailUrl,
            date: DateTime.now(),
          ),
        );
      } catch (_) {}
    });
  }

  void initEpisodes(
    int groupIndex,
    int episodeIndex,
    List<ExtensionEpisodeGroup> epGroup,
    String name,
  ) {
    state = state.copyWith(
      epGroup: epGroup,
      name: name,
      selectedGroupIndex: groupIndex,
      selectedEpisodeIndex: episodeIndex,
    );
  }

  @override
  MangaEpisodeNotifierState build() {
    return MangaEpisodeNotifierState();
  }

  final scrollController = ScrollController();
  void setSelectedGroupIndex(int index) {
    state = state.copyWith(selectedGroupIndex: index);
  }

  void setSelectedEpisodeIndex(int index) {
    state = state.copyWith(selectedEpisodeIndex: index);
  }

  void nextChapter() {
    if (state.selectedEpisodeIndex <
        state.epGroup[state.selectedGroupIndex].urls.length) {
      state = state.copyWith(
        selectedEpisodeIndex: state.selectedEpisodeIndex + 1,
      );
    }
  }

  void prevChapter() {
    if (state.selectedEpisodeIndex > 0) {
      state = state.copyWith(
        selectedEpisodeIndex: state.selectedEpisodeIndex - 1,
      );
    }
  }

  late String imageUrl;
  late String package;
  late ExtensionType type;
  late String detailUrl;
  void putinformation(
    ExtensionType type,
    String package,
    String imageUrl,
    String detailUrl,
  ) {
    this.package = package;
    this.type = type;
    this.imageUrl = imageUrl;
    this.detailUrl = detailUrl;
  }

  // dispose behavior moved to ref.onDispose in build()
}
