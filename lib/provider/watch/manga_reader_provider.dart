import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/infinite_window.dart';
import 'package:miru_alpha/ui/features/watch/watch_data.dart' as watch_data;
import 'package:miru_alpha/provider/watch/chapter_watch_cache.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/scrollable_positioned_list.dart';

part 'manga_reader_provider.g.dart';

/// Bounds of the reader's [MangaReaderState.brightness] slider, in percent.
const kMangaBrightnessMin = 20;
const kMangaBrightnessMax = 100;

/// 100 = no scrim. The page must render untouched by default; dimming is
/// something the reader opts into, not something it inherits.
const kMangaBrightnessDefault = 100;

/// Brightness starts on [MangaBrightnessMode.auto], matching the shipped
/// default: the reader should not take the screen's brightness over on first
/// open, and manual at [kMangaBrightnessDefault] is a no-op that only wins the
/// argument with the system. Manual is for when the reader deliberately wants a
/// specific value.
const kMangaBrightnessModeDefault = MangaBrightnessMode.auto;

/// Bounds of the reader's [MangaReaderState.pageGap] slider, in logical px.
const kMangaPageGapMin = 0;
const kMangaPageGapMax = 32;

/// No gutter: a reader page is the artwork edge to edge.
const kMangaPageGapDefault = 0;

/// Immutable reader state: page position plus every display preference the
/// reader HUD and the settings sheet can change.
///
/// Deliberately excludes the page URL list and the live scroll offset. The
/// viewport reads the URLs from the watch data it already holds, and the scroll
/// position streams to the canvas through [ScrollOffsetListener] — neither
/// belongs in watched state, where every copy and every rebuild would carry
/// them along.
class MangaReaderState {
  final int itemPosition;
  final int totalPage;
  final MangaReadMode readMode;

  /// Whether the floating HUD (top bar + control panel) is shown.
  ///
  /// Starts hidden: the reader's resting state is the page alone, and a centre
  /// tap animates the overlay in or out. Not persisted, so every session opens
  /// the same way.
  final bool hudVisible;

  /// True while a programmatic jump's scroll animation is still in flight.
  ///
  /// The page scrubber holds the thumb where the reader left it until this
  /// clears — the position stream keeps reporting intermediate pages while the
  /// jump animates, and adopting them mid-scrub is what made the thumb snap
  /// back (worst in webtoon mode, whose animated `scrollTo` supersession
  /// churns the position stream the most).
  final bool jumpSettling;

  final MangaFitMode fitMode;
  final MangaCanvasBackground canvasBackground;

  /// Whether [brightness] is enforced by the reader ([MangaBrightnessMode.manual])
  /// or the system brightness is left in charge ([MangaBrightnessMode.auto]).
  final MangaBrightnessMode brightnessMode;

  /// Page dimming in percent, clamped to
  /// `[kMangaBrightnessMin, kMangaBrightnessMax]`. Only applied while
  /// [brightnessMode] is [MangaBrightnessMode.manual].
  final int brightness;

  /// Vertical breathing room between pages, in logical px, clamped to
  /// `[kMangaPageGapMin, kMangaPageGapMax]`.
  final int pageGap;

  final bool invertColors;
  final bool keepScreenOn;
  final bool tapToTurnPage;

  /// The loaded chapters, in reading order. Empty outside webtoon mode.
  /// The infinite scroll prepends/appends entries; each entry holds the
  /// chapter's page URLs (null while loading or after an error).
  final List<ChapterSegment<String>> segments;

  /// Index into [segments] of the chapter the reader is in — the one the
  /// position stream attributes pages to.
  final int trackedSegmentIndex;

  /// Bookmarked episodes, keyed `"<groupIndex>:<episodeIndex>"`.
  ///
  /// The reference's chapter list marks the open chapter and bookmarks it from
  /// the drawer, and both have to survive a relaunch, so the set is persisted
  /// rather than kept per reading session.
  final Set<String> bookmarks;

  /// Pages reached for history; controllers retain zero-based indices.
  int get historyProgress =>
      totalPage == 0 ? 0 : (itemPosition + 1).clamp(1, totalPage);

  /// One-based page number shown in the HUD. Never zero.
  int get page => historyProgress;

  /// Reading progress in `[0, 1]`; zero when the chapter has no pages.
  double get progress => totalPage == 0 ? 0 : historyProgress / totalPage;

  const MangaReaderState({
    this.totalPage = 0,
    this.itemPosition = 0,
    this.readMode = MangaReadMode.standard,
    this.hudVisible = false,
    this.jumpSettling = false,
    this.fitMode = MangaFitMode.fitWidth,
    this.canvasBackground = MangaCanvasBackground.black,
    this.brightnessMode = kMangaBrightnessModeDefault,
    this.brightness = kMangaBrightnessDefault,
    this.pageGap = kMangaPageGapDefault,
    this.invertColors = false,
    this.keepScreenOn = true,
    this.tapToTurnPage = true,
    this.bookmarks = const <String>{},
    this.segments = const <ChapterSegment<String>>[],
    this.trackedSegmentIndex = 0,
  });

  MangaReaderState copyWith({
    int? itemPosition,
    int? totalPage,
    MangaReadMode? readMode,
    bool? hudVisible,
    bool? jumpSettling,
    MangaFitMode? fitMode,
    MangaCanvasBackground? canvasBackground,
    MangaBrightnessMode? brightnessMode,
    int? brightness,
    int? pageGap,
    bool? invertColors,
    bool? keepScreenOn,
    bool? tapToTurnPage,
    Set<String>? bookmarks,
    List<ChapterSegment<String>>? segments,
    int? trackedSegmentIndex,
  }) {
    return MangaReaderState(
      totalPage: totalPage ?? this.totalPage,
      itemPosition: itemPosition ?? this.itemPosition,
      readMode: readMode ?? this.readMode,
      hudVisible: hudVisible ?? this.hudVisible,
      jumpSettling: jumpSettling ?? this.jumpSettling,
      fitMode: fitMode ?? this.fitMode,
      canvasBackground: canvasBackground ?? this.canvasBackground,
      brightnessMode: brightnessMode ?? this.brightnessMode,
      brightness: brightness ?? this.brightness,
      pageGap: pageGap ?? this.pageGap,
      invertColors: invertColors ?? this.invertColors,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      tapToTurnPage: tapToTurnPage ?? this.tapToTurnPage,
      bookmarks: bookmarks ?? this.bookmarks,
      segments: segments ?? this.segments,
      trackedSegmentIndex: trackedSegmentIndex ?? this.trackedSegmentIndex,
    );
  }
}

/// The one manga reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family minting an element per episode. An
/// episode switch is [MangaReader.open]; leaving the reader disposes the
/// element and everything it holds.
///
/// The family it replaces took the watch response as an argument. Family
/// arguments are hashed into the provider identity and stringified on every
/// state change by the debug tooling, so a fresh protobuf object per fetch
/// minted a new element each rebuild and pinned the whole page URL list on
/// every retained identity until the heap gave out.
///
/// The page URLs are not state either: the viewport reads them from the watch
/// data it already holds, and the live scroll position streams to the canvas
/// through [ScrollOffsetListener] instead of Riverpod state.
@riverpod
class MangaReader extends _$MangaReader {
  bool isAdjusting = false;

  /// Highest flat index the user reached on this session.
  ///
  /// The positions stream re-reports slots on every build — image decode
  /// re-flowing the list ahead of the anchor ghosts a backward blip into it.
  /// Backward moves have to prove themselves across a few consecutive frames
  /// before they get attribution; forwards never have to.
  int _stableFirstVisible = 0;
  int _backwardFrames = 0;
  static const int _backwardHysteresisFrames = 4;

  /// Identity of the episode currently opened, so a shell rebuild that passes
  /// the same episode does not reset the reader's position.
  String? _openKey;

  /// Episode list of the open group, captured at [open] time. The infinite
  /// webtoon window uses it to find sibling chapters' names and watch URLs.
  List<ExtensionEpisode> _episodes = const [];

  /// Meta of the open series; the window's adjacent-chapter fetch needs it.
  ExtensionMeta? _meta;

  /// Detail URL of the open series; required for adjacent-chapter fetches.
  String? _detailUrl;

  int _groupIndex = 0;

  /// Invoked with (groupIndex, episodeIndex) when the infinite window flips
  /// the tracked chapter to another one mid-session.
  void Function(int groupIndex, int episodeIndex)? _onTrackedEpisodeChanged;

  /// Episode indices with an in-flight adjacent-chapter fetch.
  final Set<int> _loadingSegments = {};

  /// Set when the reader itself flips the tracked chapter; the shell skips
  /// its open() reset on the same frame so the canvas stays.
  bool _internalChapterFlip = false;

  /// Memo for the flat slot list — the positions listener runs per scroll
  /// frame, so rebuilding it every tick would allocate a list per frame.
  List<WindowSlot>? _slotsCache;
  List<ChapterSegment<String>>? _slotsCacheKey;

  /// Test seam: replaces the network fetch for adjacent chapters.
  @visibleForTesting
  Future<List<String>?> Function(String url)? debugChapterFetcher;

  List<WindowSlot> _slots([MangaReaderState? s]) {
    s ??= state;
    final cached = _slotsCache;
    if (cached != null && identical(_slotsCacheKey, s.segments)) {
      return cached;
    }
    final slots = buildSlots(
      s.segments,
      atSeriesStart:
          s.segments.isNotEmpty && s.segments.first.episodeIndex == 0,
      atSeriesEnd: s.segments.isNotEmpty &&
          _episodes.isNotEmpty &&
          s.segments.last.episodeIndex == _episodes.length - 1,
    );
    _slotsCache = slots;
    _slotsCacheKey = s.segments;
    return slots;
  }

  /// Flat slots for the current window (series boundaries, junctions,
  /// pages). The webtoon canvas renders these one-for-one.
  List<WindowSlot> currentSlots() => _slots();

  int _flatIndexOfPage(int segmentIndex, int pageIndex) {
    final slots = _slots();
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (slot.kind == SlotKind.page &&
          slot.segmentIndex == segmentIndex &&
          slot.pageIndex == pageIndex) {
        return i;
      }
    }
    return 0;
  }

  @override
  MangaReaderState build() {
    ref.onDispose(() {
      pageController.dispose();
      itemPositionsListener.itemPositions.removeListener(
        _whenItemPositionChange,
      );
    });
    initListener();
    return _sessionState();
  }

  /// Opens [episodeIndex] of [groupIndex] with [totalPage] pages.
  ///
  /// [resumePage] is the zero-based page history reported for this episode
  /// (see `findSavedReadingProgress`): a re-entered chapter opens there
  /// instead of page one, and the session state carries it from the first
  /// frame so the HUD and the armed history snapshot agree with it.
  ///
  /// Webtoon mode chains chapters in one infinite list; [episodes] carries
  /// the whole group (names + watch URLs) so the window can lazily load
  /// sibling chapters in either direction, and [urls] carries this chapter's
  /// already-fetched pages so the anchor segment never refetches. History,
  /// HUD and the drawer follow whichever chapter the viewport is in: the
  /// tracked chapter flips via [onTrackedEpisodeChanged] so the shell can
  /// attribute the save to the right episode.
  ///
  /// Re-opening the episode that is already open is a no-op — a refetch of the
  /// same chapter must not throw the reader back to page one. A different
  /// episode starts a fresh session: position and HUD reset, the display
  /// preferences re-read from the store (they are persisted, so this only
  /// re-syncs them).
  void open({
    required int groupIndex,
    required int episodeIndex,
    required int totalPage,
    int? resumePage,
    List<ExtensionEpisode> episodes = const [],
    List<String>? urls,
    String chapterName = '',
    ExtensionMeta? meta,
    String? detailUrl,
    void Function(int groupIndex, int episodeIndex)? onTrackedEpisodeChanged,
  }) {
    final key = '$groupIndex:$episodeIndex:$totalPage';
    if (key == _openKey && ref.mounted) return;
    _openKey = key;
    isAdjusting = false;

    _groupIndex = groupIndex;
    _episodes = List<ExtensionEpisode>.unmodifiable(episodes);
    _meta = meta;
    _detailUrl = detailUrl;
    _onTrackedEpisodeChanged = onTrackedEpisodeChanged;
    _loadingSegments.clear();
    _slotsCache = null;
    _slotsCacheKey = null;

    final anchorUrls = urls == null
        ? List<String>.generate(
            totalPage,
            (_) => '',
            growable: false,
          )
        : List<String>.unmodifiable(urls);
    final anchorTotal = anchorUrls.length;
    final name = chapterName.isNotEmpty
        ? chapterName
        : episodes.isNotEmpty && episodeIndex >= 0 && episodeIndex < episodes.length
        ? episodes[episodeIndex].name
        : '';
    final url = episodes.isNotEmpty &&
            episodeIndex >= 0 &&
            episodeIndex < episodes.length
        ? episodes[episodeIndex].url
        : '';
    final anchor = ChapterSegment<String>(
      episodeIndex: episodeIndex,
      name: name,
      url: url,
      items: anchorUrls,
    );

    final session = _sessionState(totalPage: anchorTotal).copyWith(
      segments: [anchor],
      trackedSegmentIndex: 0,
    );
    // Seed the backward-hysteresis anchor at the resume position so resumes
    // do not suppress attribution above it. The list re-anchors relative to
    // the resume slot, so this seeds the flat index we would expect.
    _stableFirstVisible = resumePage == null ? 0 : resumePage.clamp(
        0, anchorTotal <= 0 ? 0 : anchorTotal - 1);
    _backwardFrames = 0;
    if (resumePage == null || resumePage <= 0 || anchorTotal <= 0) {
      state = session;
      return;
    }
    state = session.copyWith(
      itemPosition: resumePage.clamp(0, anchorTotal - 1),
    );
  }

  /// Instant restore of [page] onto the canvas.
  ///
  /// The shell calls this one frame after [open] — the fresh canvas attaches
  /// the controllers while that frame lays out, so the jump targets the new
  /// canvas rather than the outgoing one. Instant on purpose: an animated fly
  /// through a resumed chapter churns the position stream and builds pages the
  /// reader never looks at.
  void restorePosition(int page) {
    if (!ref.mounted || state.totalPage == 0) return;
    final target = page.clamp(0, state.totalPage - 1);
    switch (state.readMode) {
      case MangaReadMode.webToon:
        if (itemScrollController.isAttached) {
          final flat = state.segments.isNotEmpty
              ? _flatIndexOfPage(state.trackedSegmentIndex, target)
              : target;
          itemScrollController.jumpTo(index: flat);
        }
      case MangaReadMode.rightToLeft || MangaReadMode.standard:
        if (pageController.hasClients) {
          pageController.jumpToPage(target);
        }
    }
  }

  /// A fresh session state: the persisted display preferences, no position.
  MangaReaderState _sessionState({int totalPage = 0}) {
    return MangaReaderState(
      totalPage: totalPage,
      readMode: _readSetting<MangaReadMode>(
        SettingKey.mangaReadingMode,
        MangaReadMode.standard,
      ),
      fitMode: _readSetting<MangaFitMode>(
        SettingKey.mangaFitMode,
        MangaFitMode.fitWidth,
      ),
      canvasBackground: _readSetting<MangaCanvasBackground>(
        SettingKey.mangaCanvasBackground,
        MangaCanvasBackground.black,
      ),
      brightnessMode: _readSetting<MangaBrightnessMode>(
        SettingKey.mangaBrightnessMode,
        kMangaBrightnessModeDefault,
      ),
      brightness: _readSetting<int>(
        SettingKey.mangaBrightness,
        kMangaBrightnessDefault,
      ),
      pageGap: _readSetting<int>(SettingKey.mangaPageGap, kMangaPageGapDefault),
      invertColors: _readSetting<bool>(SettingKey.mangaInvertColors, false),
      keepScreenOn: _readSetting<bool>(SettingKey.mangaKeepScreenOn, true),
      tapToTurnPage: _readSetting<bool>(SettingKey.mangaTapToTurnPage, true),
    );
  }

  // Settings may be missing (fresh install before the gRPC store answers, or
  // a test that did not seed defaults), so every read falls back to a default
  // instead of throwing.
  T _readSetting<T>(String key, T fallback) {
    try {
      return MiruSettings.getSettingSync<T>(key);
    } catch (error, stack) {
      logger.fine(
        'Reader setting $key unreadable, using default',
        error,
        stack,
      );
      return fallback;
    }
  }

  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();

  /// Plain [PageController]: the reader's zoom is a paint transform over the
  /// pages, so nothing needs extended_image's own page controller — and its
  /// gesture page view would put a third set of recognisers in the arena.
  ///
  /// `keepPage: false` so a fresh canvas (an episode switch rebuilds it)
  /// attaches at page one instead of restoring the previous episode's page.
  final PageController pageController = PageController(keepPage: false);

  bool _listenersInitialized = false;

  void initListener() {
    if (_listenersInitialized) return;
    _listenersInitialized = true;
    itemPositionsListener.itemPositions.addListener(_whenItemPositionChange);
  }

  void _whenItemPositionChange() {
    if (state.readMode == MangaReadMode.webToon &&
        state.segments.isNotEmpty) {
      _webtoonPositionChanged();
      return;
    }
    final visible = itemPositionsListener.itemPositions.value.where(
      (position) =>
          position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
    );
    if (visible.isEmpty) return;
    final firstVisible = visible.reduce((a, b) => a.index < b.index ? a : b);
    setPageNumber(firstVisible.index);
  }

  void _webtoonPositionChanged() {
    final visible = itemPositionsListener.itemPositions.value.where(
      (position) =>
          position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
    );
    if (visible.isEmpty) {
        return;
    }
    final firstVisible = visible.reduce((a, b) => a.index < b.index ? a : b);
    final slots = _slots();
    if (slots.isEmpty) return;

    // Backward blip filter: the positions stream sometimes re-reports a slot
    // the user has already scrolled past when an image above re-lays out the
    // list. Require the backward position to persist across consecutive frames
    // before letting attribution follow it.
    final stable = _stableFirstVisible;
    if (firstVisible.index < stable) {
      _backwardFrames++;
      if (_backwardFrames < _backwardHysteresisFrames) {
        logger.fine(
          'window_track suppressed-blip flat=${firstVisible.index} ($_backwardFrames < $_backwardHysteresisFrames)',
        );
        return;
      }
    } else {
      _backwardFrames = 0;
      _stableFirstVisible = firstVisible.index;
    }

    final slot = slots[firstVisible.index.clamp(0, slots.length - 1)];
    if (slot.kind == SlotKind.page) {
      if (slot.segmentIndex != state.trackedSegmentIndex) {
        _flipTrackedChapter(slot.segmentIndex, slot.pageIndex);
      } else {
        setPageNumber(slot.pageIndex);
      }
    }
    _maybeLoadAdjacent(firstVisible.index);
  }

  void _flipTrackedChapter(int segmentIndex, int localPage) {
    final segment = state.segments[segmentIndex];
    _internalChapterFlip = true;
    _onTrackedEpisodeChanged?.call(_groupIndex, segment.episodeIndex);
    state = state.copyWith(
      trackedSegmentIndex: segmentIndex,
      totalPage: segment.items?.length ?? state.totalPage,
      itemPosition: segment.items == null
          ? 0
          : localPage.clamp(0, segment.items!.length - 1),
    );
  }

  /// One-shot: returns true when the reader itself flipped the tracked
  /// chapter (an infinite-scroll crossing) and clears the flag, so the shell
  /// skips its open() reset on the same frame and keeps the canvas.
  bool consumeChapterFlip() {
    final flipped = _internalChapterFlip;
    _internalChapterFlip = false;
    return flipped;
  }

  /// Kicks off an adjacent-chapter fetch when the viewport is near either
  /// end of the loaded window.
  void _maybeLoadAdjacent(int flatIndex) {
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) return;
    final length = _slots().length;
    if (flatIndex >= length - 4) _ensureAdjacent(1);
    if (flatIndex <= 3) _ensureAdjacent(-1);
  }

  Future<void> _ensureAdjacent(int direction) async {
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) {
      // ignore: avoid_print
      return;
    }
    if (state.segments.isEmpty) return;
    final boundary = direction > 0
        ? state.segments.last.episodeIndex + 1
        : state.segments.first.episodeIndex - 1;
    if (boundary < 0 || boundary >= _episodes.length) return;
    if (state.segments.any((s) => s.episodeIndex == boundary)) return;
    if (_loadingSegments.contains(boundary)) return;
    final episode = _episodes[boundary];
    _loadingSegments.add(boundary);
    final loading = ChapterSegment<String>(
      episodeIndex: boundary,
      name: episode.name,
      url: episode.url,
      items: null,
      loading: true,
    );
    if (direction > 0) {
      _commitSegments([...state.segments, loading]);
    } else {
      _commitSegments([loading, ...state.segments], atHead: true);
    }
    final urls = await _fetchChapterUrls(episode);
    _loadingSegments.remove(boundary);
    _replaceSegment(
      boundary,
      loading.copyWith(items: urls, loading: false, failed: urls == null),
      atHead: direction < 0,
    );
  }

  /// Applies a segment list mutation, keeping the scroll position stable
  /// when the change extends the list at its head.
  void _commitSegments(
    List<ChapterSegment<String>> segments, {
    bool atHead = false,
  }) {
    final before = _slots().length;
    final after = buildSlots(
      segments,
      atSeriesStart:
          segments.isNotEmpty && segments.first.episodeIndex == 0,
      atSeriesEnd: segments.isNotEmpty &&
          _episodes.isNotEmpty &&
          segments.last.episodeIndex == _episodes.length - 1,
    ).length;
    var trackedSegmentIndex = state.trackedSegmentIndex;
    if (atHead) {
      final delta = after - before;
      final insertedSegments = segments.length - state.segments.length;
      if (insertedSegments > 0) {
        // The same logical chapter is now further into the list; the index
        // it is tracked by moves with it.
        trackedSegmentIndex += insertedSegments;
      }
      if (delta > 0 && state.readMode == MangaReadMode.webToon) {
        itemScrollController.notifyItemsInsertedBefore(delta);
      }
    }
    state = state.copyWith(
      segments: List.unmodifiable(segments),
      trackedSegmentIndex: trackedSegmentIndex,
    );
  }

  /// Retries a failed chapter slot (tapping the error tile).
  Future<void> retrySegment(int episodeIndex) async {
    final index = state.segments.indexWhere(
      (s) => s.episodeIndex == episodeIndex,
    );
    if (index < 0) return;
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) return;
    if (_loadingSegments.contains(episodeIndex)) return;
    final episode = _episodes[episodeIndex];
    _loadingSegments.add(episodeIndex);
    _replaceSegment(
      episodeIndex,
      state.segments[index].copyWith(loading: true, failed: false),
      atHead: index == 0,
    );
    final urls = await _fetchChapterUrls(episode);
    _loadingSegments.remove(episodeIndex);
    _replaceSegment(
      episodeIndex,
      state.segments[state.segments.indexWhere(
            (s) => s.episodeIndex == episodeIndex,
          )]
          .copyWith(items: urls, loading: false, failed: urls == null),
      atHead: index == 0,
    );
  }

  void _replaceSegment(
    int episodeIndex,
    ChapterSegment<String> replacement, {
    required bool atHead,
  }) {
    _commitSegments(
      [
        for (final segment in state.segments)
          segment.episodeIndex == episodeIndex ? replacement : segment,
      ],
      atHead: atHead,
    );
  }

  Future<List<String>?> _fetchChapterUrls(ExtensionEpisode episode) async {
    final fetcher = debugChapterFetcher;
    if (fetcher != null) return fetcher(episode.url);
    final meta = _meta;
    final detailUrl = _detailUrl;
    if (meta == null || detailUrl == null) return null;
    try {
      final result = await WatchChapterCache.resolve(
        watchUrl: episode.url,
        detailUrl: detailUrl,
        meta: meta,
      );
      if (result.data is proto.Download) return null;
      final data = watch_data.toMangaWatch(
        watch_data.unwrapAll(result.data, meta.type),
      );
      final urls = data.urls;
      if (urls.isEmpty) return null;
      return List<String>.unmodifiable(urls);
    } catch (error, stack) {
      logger.warning(
        'Failed to load adjacent chapter ${episode.url}',
        error,
        stack,
      );
      return null;
    }
  }

  void changeReadMode(MangaReadMode mode) {
    if (mode == state.readMode) return;
    MiruSettings.setSettingSync(SettingKey.mangaReadingMode, mode.name);
    state = state.copyWith(readMode: mode);
  }

  void setHudVisible(bool visible) {
    if (visible == state.hudVisible) return;
    state = state.copyWith(hudVisible: visible);
  }

  void toggleHud() {
    setHudVisible(!state.hudVisible);
  }

  void setFitMode(MangaFitMode mode) {
    if (mode == state.fitMode) return;
    MiruSettings.setSettingSync(SettingKey.mangaFitMode, mode.name);
    state = state.copyWith(fitMode: mode);
  }

  void setCanvasBackground(MangaCanvasBackground background) {
    if (background == state.canvasBackground) return;
    MiruSettings.setSettingSync(
      SettingKey.mangaCanvasBackground,
      background.name,
    );
    state = state.copyWith(canvasBackground: background);
  }

  void setBrightnessMode(MangaBrightnessMode mode) {
    if (mode == state.brightnessMode) return;
    MiruSettings.setSettingSync(SettingKey.mangaBrightnessMode, mode.name);
    state = state.copyWith(brightnessMode: mode);
  }

  /// Sets the page brightness.
  ///
  /// Choosing a brightness while the screen is on [MangaBrightnessMode.auto]
  /// means the reader wants a specific value, so it takes the screen over — the
  /// way Android's adaptive brightness does. The rule lives here, not in the
  /// slider, so every caller gets it and it can be tested.
  void setBrightness(int value) {
    final clamped = value.clamp(kMangaBrightnessMin, kMangaBrightnessMax);
    if (clamped == state.brightness) return;
    MiruSettings.setSettingSync(SettingKey.mangaBrightness, '$clamped');
    state = state.copyWith(brightness: clamped);
    if (state.brightnessMode == MangaBrightnessMode.auto) {
      setBrightnessMode(MangaBrightnessMode.manual);
    }
  }

  void setPageGap(int value) {
    final clamped = value.clamp(kMangaPageGapMin, kMangaPageGapMax);
    if (clamped == state.pageGap) return;
    MiruSettings.setSettingSync(SettingKey.mangaPageGap, '$clamped');
    state = state.copyWith(pageGap: clamped);
  }

  void setInvertColors(bool value) {
    if (value == state.invertColors) return;
    MiruSettings.setSettingSync(SettingKey.mangaInvertColors, '$value');
    state = state.copyWith(invertColors: value);
  }

  void setKeepScreenOn(bool value) {
    if (value == state.keepScreenOn) return;
    MiruSettings.setSettingSync(SettingKey.mangaKeepScreenOn, '$value');
    state = state.copyWith(keepScreenOn: value);
  }

  /// Whether [episodeIndex] in [groupIndex] is bookmarked.
  bool isBookmarked(int groupIndex, int episodeIndex) =>
      state.bookmarks.contains('$groupIndex:$episodeIndex');

  /// Adds or removes the bookmark for one episode, leaving the rest alone.
  void toggleBookmark(int groupIndex, int episodeIndex) {
    final key = '$groupIndex:$episodeIndex';
    final bookmarks = {...state.bookmarks};
    if (!bookmarks.remove(key)) bookmarks.add(key);
    MiruSettings.setSettingSync(SettingKey.mangaBookmarks, bookmarks.join(','));
    state = state.copyWith(bookmarks: bookmarks);
  }

  void setTapToTurnPage(bool value) {
    if (value == state.tapToTurnPage) return;
    MiruSettings.setSettingSync(SettingKey.mangaTapToTurnPage, '$value');
    state = state.copyWith(tapToTurnPage: value);
  }

  /// Restores every display preference to its shipped default and persists it.
  void resetDisplaySettings() {
    changeReadMode(MangaReadMode.standard);
    setFitMode(MangaFitMode.fitWidth);
    setCanvasBackground(MangaCanvasBackground.black);
    setBrightnessMode(kMangaBrightnessModeDefault);
    setBrightness(kMangaBrightnessDefault);
    setPageGap(kMangaPageGapDefault);
    setInvertColors(false);
    setKeepScreenOn(true);
    setTapToTurnPage(true);
  }

  // Set the page number
  void setPageNumber(int page) {
    // Listener echoes only: while a jump is animating the stream reports the
    // intermediate pages it flies over, which must not overwrite the target.
    if (isAdjusting || state.totalPage == 0) return;
    _writePage(page);
  }

  /// Writes the reading position. The jump target is authoritative — it wins
  /// over any in-flight suppression, so a scrub's every tick lands even while
  /// the previous jump's animation is still running.
  void _writePage(int page) {
    if (state.totalPage == 0) return;
    final next = page.clamp(0, state.totalPage - 1);
    // The item-position stream fires on every scroll frame. Without this
    // guard, every frame allocated a fresh state and rebuilt every watcher —
    // the reader shell, the viewport and both HUD halves — while the pages
    // moved, which is the scroll-time memory and jank spiral.
    if (next == state.itemPosition) return;
    state = state.copyWith(itemPosition: next);
  }

  /// Steps the page by [delta], clamped to the available range.
  void stepPage(int delta) => jumpTo(state.itemPosition + delta);

  /// Bumped per jump. A scroll animation superseded by the next scrub tick
  /// still completes its own future — without the token its completion would
  /// clear [isAdjusting] while the NEWEST jump is mid-flight, un-gate the
  /// position stream, and let intermediate pages churn the state behind the
  /// reader's back (the scrub thumb's snap-back in webtoon mode).
  int _jumpGeneration = 0;

  /// Arms the settling flag for jump [token]. No-op when a newer jump has
  /// already taken over, so a scrub drag writes the flag once, not per tick.
  void _beginJump(int token) {
    isAdjusting = true;
    if (token == _jumpGeneration && !state.jumpSettling) {
      state = state.copyWith(jumpSettling: true);
    }
  }

  /// Clears the jump flags — but only for the jump that is still the newest.
  void _endJump(int token) {
    if (!ref.mounted || token != _jumpGeneration) return;
    isAdjusting = false;
    if (state.jumpSettling) state = state.copyWith(jumpSettling: false);
  }

  // Jump to the page and set the page number. [page] is the zero-based index
  // the position stream reports.
  void jumpTo(int page) {
    if (state.totalPage == 0) return;
    _writePage(page);
    final token = ++_jumpGeneration;
    final flatTarget = state.readMode == MangaReadMode.webToon &&
            state.segments.isNotEmpty
        ? _flatIndexOfPage(
            state.trackedSegmentIndex,
            page.clamp(0, state.totalPage - 1),
          )
        : page;
    switch (state.readMode) {
      case MangaReadMode.webToon:
        // A detached controller throws synchronously out of `scrollTo`; the
        // exception would leave the jump flags armed forever — page updates
        // gated off and the scrubber thumb locked on its last target.
        if (!itemScrollController.isAttached) return;
        _beginJump(token);
        itemScrollController
            .scrollTo(
              index: flatTarget,
              duration: const Duration(milliseconds: 100),
            )
            .then(
              (_) => _endJump(token),
              // An errored or cancelled scroll must still release the jump;
              // a dropped completion is the frozen-reader bug.
              onError: (Object error, StackTrace stack) {
                logger.warning('webtoon jump did not land', error, stack);
                _endJump(token);
              },
            );
      case MangaReadMode.rightToLeft || MangaReadMode.standard:
        if (pageController.hasClients) {
          _beginJump(token);
          pageController
              .animateToPage(
                page,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
              )
              .then(
                (_) => _endJump(token),
                onError: (Object error, StackTrace stack) {
                  logger.warning('page jump did not land', error, stack);
                  _endJump(token);
                },
              );
        }
    }
  }
}
