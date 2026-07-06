import 'package:extended_image/extended_image.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'manga_reader_view_model.g.dart';

class MangaReaderViewState {
  final int currentEpIndex;
  final int selectedGroupIndex;
  final int totalPages;
  final MangaReadMode readMode;
  final bool isZoom;
  final double offset;
  final int itemPosition;

  const MangaReaderViewState({
    this.currentEpIndex = 0,
    this.selectedGroupIndex = 0,
    this.totalPages = 0,
    this.readMode = MangaReadMode.standard,
    this.isZoom = false,
    this.offset = 0,
    this.itemPosition = 0,
  });

  MangaReaderViewState copyWith({
    int? currentEpIndex,
    int? selectedGroupIndex,
    int? totalPages,
    MangaReadMode? readMode,
    bool? isZoom,
    double? offset,
    int? itemPosition,
  }) {
    return MangaReaderViewState(
      currentEpIndex: currentEpIndex ?? this.currentEpIndex,
      selectedGroupIndex: selectedGroupIndex ?? this.selectedGroupIndex,
      totalPages: totalPages ?? this.totalPages,
      readMode: readMode ?? this.readMode,
      isZoom: isZoom ?? this.isZoom,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
    );
  }
}

@riverpod
class MangaReaderViewModel extends _$MangaReaderViewModel {
  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();
  final ExtendedPageController pageController = ExtendedPageController();
  bool isAdjusting = false;

  @override
  MangaReaderViewState build({
    int epIndex = 0,
    int total = 0,
    ExtensionMangaWatch? data,
    Map<String, String>? headers,
  }) {
    final mangaProvider = mangaReaderProvider(
      epIndex,
      total,
      data,
      headers: headers,
    );
    final mangaState = ref.watch(mangaProvider);
    return MangaReaderViewState(
      readMode: mangaState.readMode,
      isZoom: mangaState.isZoom,
      totalPages: mangaState.totalPage,
      itemPosition: mangaState.itemPosition,
      offset: mangaState.offset,
    );
  }

  // Expose state values as getters
  MangaReadMode get readMode => state.readMode;
  bool get isZoom => state.isZoom;
  int get totalPages => state.totalPages;
  int get itemPosition => state.itemPosition;
  double get offset => state.offset;

  void changeReadMode(MangaReadMode mode) {
    ref
        .read(
          mangaReaderProvider(epIndex, total, data, headers: headers).notifier,
        )
        .changeReadMode(mode);
  }

  void changeZoomMode(bool isZoom) {
    ref
        .read(
          mangaReaderProvider(epIndex, total, data, headers: headers).notifier,
        )
        .changeZoomMode(isZoom);
  }

  void setPageNumber(int page) {
    ref
        .read(
          mangaReaderProvider(epIndex, total, data, headers: headers).notifier,
        )
        .setPageNumber(page);
  }

  void jumpTo(int page) {
    ref
        .read(
          mangaReaderProvider(epIndex, total, data, headers: headers).notifier,
        )
        .jumpTo(page);
  }
}
