import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/chapter_watch_cache.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/infinite_window.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_pagination.dart';
import 'package:miru_alpha/ui/features/watch/watch_data.dart' as watch_data;
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'novel_reader_provider.g.dart';

/// Bounds of the reader's font size slider, in logical px.
const double kNovelFontSizeMin = 12;
const double kNovelFontSizeMax = 28;
const double kNovelFontSizeDefault = 18;

/// Bounds of the reader's line-spacing slider, as a multiple of the font size.
const double kNovelLineHeightMin = 1.0;
const double kNovelLineHeightMax = 2.4;
const double kNovelLineHeightDefault = 1.6;
const double kNovelLineHeightStep = 0.1;

/// Bounds of the reader's page-margin slider, in logical px.
const double kNovelMarginMin = 8;
const double kNovelMarginMax = 40;
const double kNovelMarginDefault = 20;
const double kNovelMarginStep = 2;

/// The reader owns the screen brightness while it is open, which is what a
/// reader wants in a dark room.
const MangaBrightnessMode kNovelBrightnessModeDefault =
    MangaBrightnessMode.auto;

/// 100 = no scrim, so the page is untouched until the reader asks otherwise.
const int kNovelBrightnessDefault = 100;

const int kNovelBrightnessMin = 20;
const int kNovelBrightnessMax = 100;

/// Immutable reader state: reading position plus every display preference the
/// HUD and the settings sheet can change.
class NovelReaderState {
  final NovelReadMode readMode;
  final NovelFontFamily fontFamily;

  /// Body font size in logical px, clamped to
  /// `[kNovelFontSizeMin, kNovelFontSizeMax]`.
  final double fontSize;

  /// Leading as a multiple of [fontSize], clamped to
  /// `[kNovelLineHeightMin, kNovelLineHeightMax]` and snapped to
  /// [kNovelLineHeightStep].
  final double lineHeight;

  /// Horizontal page padding in logical px, clamped to
  /// `[kNovelMarginMin, kNovelMarginMax]` and snapped to [kNovelMarginStep].
  final double margin;

  final NovelTheme theme;

  final bool keepScreenOn;
  final bool tapToTurnPage;
  final bool volumeKeysTurnPage;

  /// Whether the floating HUD (top bar + control capsule) is shown.
  ///
  /// Starts hidden: the reader's resting state is the page alone, and a centre
  /// tap animates the overlay in or out. Not persisted, so every session opens
  /// the same way.
  final bool hudVisible;

  /// Whether [brightness] is enforced by the reader ([MangaBrightnessMode.manual])
  /// or the system brightness is left in charge ([MangaBrightnessMode.auto]).
  final MangaBrightnessMode brightnessMode;

  /// Screen dimming in percent, only applied while [brightnessMode] is
  /// [MangaBrightnessMode.manual].
  final int brightness;

  /// 1-based line the reader is on.
  final int line;

  /// Lines in the chapter, or 0 before the canvas has been measured.
  final int totalLine;

  /// 1-based page the reader is on, or 0 in the continuous mode, which has no
  /// pages.
  final int page;

  /// Pages in the chapter, or 0 in the continuous mode.
  final int totalPage;

  /// Loaded chapters in reading order. The infinite webtoon window prepends
  /// and appends; empty outside the continuous mode once a window exists, and
  /// absent before the first open.
  final List<ChapterSegment<NovelContentBlock>> segments;

  /// Index into [segments] of the chapter the reader is in — the one the
  /// position stream attributes lines to.
  final int trackedSegmentIndex;

  /// Bookmarked episodes, keyed `"<groupIndex>:<episodeIndex>"`.
  final Set<String> bookmarks;

  /// Distance between two baselines, the unit [line] counts in.
  double get lineExtent => fontSize * lineHeight;

  /// Whether the reader has pages to turn. The continuous mode never does, even
  /// for the one frame before the canvas has re-measured and cleared the count.
  bool get isPaged => readMode.resolved != NovelReadMode.webToon;

  /// Reading position saved to history, in the unit the current mode navigates:
  /// pages for a paged mode, lines while scrolling.
  int get historyProgress {
    final total = totalProgress;
    if (total <= 0) return 0;
    return (isPaged ? page : line).clamp(1, total);
  }

  /// The matching total, so history receives a progress/total pair in the same
  /// units.
  int get totalProgress => isPaged ? totalPage : totalLine;

  /// Reading progress in `[0, 1]`; zero when the chapter is empty.
  double get progress {
    final total = totalProgress;
    if (total <= 0) return 0;
    return historyProgress / total;
  }

  /// The progress/total pair to record in history for this chapter.
  ///
  /// A novel's total is only known once the canvas has measured the chapter,
  /// which happens after the content arrives — unlike the manga reader, whose
  /// page count it knows the moment it opens. So a chapter opened and then left
  /// before it finished measuring would report a total of zero, and
  /// [EpisodeNotifier.prepareHistorySave] drops an entry with no total: the
  /// chapter silently never reaches history at all. Falling back to zero of one
  /// keeps the chapter remembered and resumable, and the measured total replaces
  /// it as soon as the page is laid out.
  ({int progress, int totalProgress}) get historySnapshot {
    final total = totalProgress;
    if (total <= 0) return (progress: 0, totalProgress: 1);
    return (progress: historyProgress, totalProgress: total);
  }

  const NovelReaderState({
    this.readMode = NovelReadMode.webToon,
    this.segments = const <ChapterSegment<NovelContentBlock>>[],
    this.trackedSegmentIndex = 0,
    this.fontFamily = NovelFontFamily.serif,
    this.fontSize = kNovelFontSizeDefault,
    this.lineHeight = kNovelLineHeightDefault,
    this.margin = kNovelMarginDefault,
    this.theme = NovelTheme.midnight,
    this.keepScreenOn = true,
    this.tapToTurnPage = true,
    this.volumeKeysTurnPage = false,
    this.hudVisible = false,
    this.brightnessMode = kNovelBrightnessModeDefault,
    this.brightness = kNovelBrightnessDefault,
    this.line = 0,
    this.totalLine = 0,
    this.page = 0,
    this.totalPage = 0,
    this.bookmarks = const <String>{},
  });

  NovelReaderState copyWith({
    NovelReadMode? readMode,
    NovelFontFamily? fontFamily,
    double? fontSize,
    double? lineHeight,
    double? margin,
    NovelTheme? theme,
    bool? keepScreenOn,
    bool? tapToTurnPage,
    bool? volumeKeysTurnPage,
    bool? hudVisible,
    MangaBrightnessMode? brightnessMode,
    int? brightness,
    int? line,
    int? totalLine,
    int? page,
    int? totalPage,
    Set<String>? bookmarks,
    List<ChapterSegment<NovelContentBlock>>? segments,
    int? trackedSegmentIndex,
  }) {
    return NovelReaderState(
      readMode: readMode ?? this.readMode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      margin: margin ?? this.margin,
      theme: theme ?? this.theme,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      tapToTurnPage: tapToTurnPage ?? this.tapToTurnPage,
      volumeKeysTurnPage: volumeKeysTurnPage ?? this.volumeKeysTurnPage,
      hudVisible: hudVisible ?? this.hudVisible,
      brightnessMode: brightnessMode ?? this.brightnessMode,
      brightness: brightness ?? this.brightness,
      line: line ?? this.line,
      totalLine: totalLine ?? this.totalLine,
      page: page ?? this.page,
      totalPage: totalPage ?? this.totalPage,
      bookmarks: bookmarks ?? this.bookmarks,
      segments: segments ?? this.segments,
      trackedSegmentIndex: trackedSegmentIndex ?? this.trackedSegmentIndex,
    );
  }
}

/// The one novel reader state.
///
/// A reader is a single full-screen surface, so the state is a single
/// auto-dispose provider — not a family keyed on the chapter text. Family
/// arguments are hashed into provider identity, so keying on the content
/// minted a fresh element (and pinned the whole chapter) per fetch. The
/// chapter text flows to the canvas through the shell's widget parameters
/// instead; [open] injects a fresh session on entry, and leaving the reader
/// disposes the element back to nothing.
@riverpod
class NovelReader extends _$NovelReader {
  /// Measured by the canvas, read by [setScrollOffset] and the page navigators.
  NovelLayout _layout = const NovelLayout(
    blockHeights: [],
    blockFirstLines: [],
    totalLine: 0,
    pages: [],
  );

  /// Suppresses the scroll listener while the reader itself is moving the
  /// canvas, so a programmatic jump does not fight the position it just set.
  bool _isAdjusting = false;

  final ScrollController scrollController = ScrollController();
  final PageController pageController = PageController();

  /// Identity of the chapter currently opened, so a shell rebuild that passes
  /// the same chapter does not reset the reader's position.
  String? _openKey;

  @override
  NovelReaderState build() {
    ref.onDispose(() {
      scrollController.removeListener(_onScroll);
      pageController.removeListener(_onPageMoved);
      scrollController.dispose();
      pageController.dispose();
    });
    scrollController.addListener(_onScroll);
    pageController.addListener(_onPageMoved);
    return _sessionState();
  }

  /// The position history reported for the chapter being opened, waiting for
  /// the canvas's first measurement (see [open]).
  ({int progress, int totalProgress})? _pendingResume;

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

  /// Invoked when the reader crosses FORWARD into a later chapter: the
  /// outgoing chapter is finished, so its history should be written as
  /// complete (progress == total lines) — the shell owns the write.
  void Function(int groupIndex, int episodeIndex, int totalLines)?
  _onChapterCompleted;

  /// Episode indices with an in-flight adjacent-chapter fetch.
  final Set<int> _loadingSegments = {};

  /// Blocks inserted at the head by the last prepend; consumed by [setLayout]
  /// to re-anchor the scroll offset and the anchor line, so a prepended chapter
  /// does not move the content on screen.
  int _pendingPrependBlocks = 0;

  /// Set when the reader itself flips the tracked chapter; the shell skips
  /// its open() reset on the same frame so the canvas stays.
  bool _internalChapterFlip = false;

  /// Test seam: replaces the network fetch for adjacent chapters with a raw
  /// content list.
  @visibleForTesting
  Future<List<String>?> Function(String url)? debugChapterFetcher;

  /// Opens a fresh session for the chapter the shell selected.
  ///
  /// [resume] is the position history reported for this chapter (see
  /// `findSavedReadingProgress`): a re-entered chapter opens there. The saved
  /// total only maps onto the new layout once the canvas has measured it, so
  /// the pair is held in [_pendingResume] and consumed by [setLayout].
  ///
  /// Webtoon mode chains chapters in one infinite list: [episodes] carries
  /// the whole group (names and watch URLs) so the window can lazily load
  /// sibling chapters in either direction, and [blocks] carries this
  /// chapter's already-parsed content. History, HUD and the drawer follow
  /// whichever chapter the viewport is in: the tracked chapter flips via
  /// [onTrackedEpisodeChanged] so the shell can attribute the save to the
  /// right episode.
  ///
  /// Re-opening the chapter that is already open is a no-op — a shell rebuild
  /// must not throw the reader back to page one. A different chapter starts a
  /// fresh session: position and HUD reset, the display preferences re-read
  /// from the store (they are persisted, so this only re-syncs them).
  void open({
    required int groupIndex,
    required int episodeIndex,
    ({int progress, int totalProgress})? resume,
    List<ExtensionEpisode> episodes = const [],
    List<NovelContentBlock>? blocks,
    ExtensionMeta? meta,
    String? detailUrl,
    void Function(int groupIndex, int episodeIndex)? onTrackedEpisodeChanged,
    void Function(int groupIndex, int episodeIndex, int totalLines)?
    onChapterCompleted,
  }) {
    final key = '$groupIndex:$episodeIndex';
    if (key == _openKey && ref.mounted) return;
    _openKey = key;
    _isAdjusting = false;
    _groupIndex = groupIndex;
    _episodes = List<ExtensionEpisode>.unmodifiable(episodes);
    _meta = meta;
    _detailUrl = detailUrl;
    _onTrackedEpisodeChanged = onTrackedEpisodeChanged;
    _onChapterCompleted = onChapterCompleted;
    _loadingSegments.clear();
    _pendingPrependBlocks = 0;
    _layout = const NovelLayout(
      blockHeights: [],
      blockFirstLines: [],
      totalLine: 0,
      pages: [],
    );
    _pendingResume = resume == null || resume.progress <= 1 ? null : resume;

    final name =
        episodes.isNotEmpty &&
            episodeIndex >= 0 &&
            episodeIndex < episodes.length
        ? episodes[episodeIndex].name
        : '';
    final url =
        episodes.isNotEmpty &&
            episodeIndex >= 0 &&
            episodeIndex < episodes.length
        ? episodes[episodeIndex].url
        : '';
    final anchor = ChapterSegment<NovelContentBlock>(
      episodeIndex: episodeIndex,
      name: name,
      url: url,
      items: blocks ?? const <NovelContentBlock>[],
    );
    state = _sessionState().copyWith(
      segments: [anchor],
      trackedSegmentIndex: 0,
    );
  }

  /// The flat block list the canvas renders: every loaded chapter as a
  /// [NovelChapterHeader] block plus its content, an [NovelJunction] block
  /// between consecutive chapters and [NovelSeriesBoundary] blocks at the
  /// absolute ends. Ordered reading order; the canvas measures it once per
  /// layout pass.
  List<NovelContentBlock> currentBlocks() {
    final cached = _flatCache;
    if (cached != null && identical(_flatCacheKey, state.segments)) {
      return cached;
    }
    final blocks = <NovelContentBlock>[];
    final segments = state.segments;
    if (segments.isEmpty) return blocks;
    final atStart = segments.first.episodeIndex == 0;
    final atEnd = segments.last.episodeIndex == _episodes.length - 1;
    if (atStart) {
      blocks.add(
        NovelSeriesBoundary(isStart: true, chapterName: segments.first.name),
      );
    }
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        final prev = segments[i - 1];
        final next = segments[i];
        blocks.add(
          NovelJunction(
            leftChapter: prev.name,
            rightChapter: next.name,
            rightEpisodeIndex: next.episodeIndex,
            loading: next.loading,
            failed: next.failed,
          ),
        );
      }
      final seg = segments[i];
      blocks.add(
        NovelChapterHeader(
          title: seg.name,
          eyebrow: 'reader.novel.chapter'.i18n.fill({
            'n': '${seg.episodeIndex + 1}',
          }),
        ),
      );
      final items = seg.items;
      if (items == null) continue;
      blocks.addAll(items);
    }
    if (atEnd) {
      blocks.add(
        NovelSeriesBoundary(isStart: false, chapterName: segments.last.name),
      );
    }
    _flatCache = List<NovelContentBlock>.unmodifiable(blocks);
    _flatCacheKey = state.segments;
    return _flatCache!;
  }

  List<NovelContentBlock>? _flatCache;
  List<ChapterSegment<NovelContentBlock>>? _flatCacheKey;

  bool get _windowActive =>
      state.segments.any((s) => s.items != null && s.items!.isNotEmpty);

  /// Per segment: the union line range it occupies, derived from the measured
  /// layout. Segments without prose report a zero-height range.
  List<({int startLine, int lineCount})> _spansFor(NovelLayout layout) {
    final segments = state.segments;
    if (segments.isEmpty) return const [];
    if (identical(_spansCacheLayout, layout) &&
        identical(_spansCacheSegments, segments)) {
      return _spansCache!;
    }
    final blocks = currentBlocks();
    final mapping = _segmentOfBlock();
    final spans = List<({int startLine, int lineCount})>.filled(
      segments.length,
      (startLine: 1, lineCount: 0),
      growable: false,
    );
    var line = 1;
    var segIdx = -1;
    var start = -1;
    var count = 0;
    for (var i = 0; i < blocks.length; i++) {
      final s = mapping[i];
      if (s == -1) continue;
      if (s != segIdx) {
        if (segIdx >= 0) {
          spans[segIdx] = (
            startLine: start == -1 ? line : start,
            lineCount: count,
          );
        }
        segIdx = s;
        start = -1;
        count = 0;
      }
      final block = blocks[i];
      if (block is NovelParagraph) {
        final n = i < layout.blockLineCounts.length
            ? layout.blockLineCounts[i]
            : 0;
        if (start == -1) start = line;
        count += n;
        line += n;
      }
    }
    if (segIdx >= 0) {
      spans[segIdx] = (startLine: start == -1 ? line : start, lineCount: count);
    }
    _spansCache = spans;
    _spansCacheLayout = layout;
    _spansCacheSegments = segments;
    return spans;
  }

  List<({int startLine, int lineCount})>? _spansCache;
  NovelLayout? _spansCacheLayout;
  List<ChapterSegment<NovelContentBlock>>? _spansCacheSegments;

  /// The block index at a scroll offset, or -1 when it hits a boundary tile.
  int _blockIndexAtOffset(double offset) {
    final layout = _layout;
    final offsets = layout.blockOffsets;
    if (offsets.isEmpty) return -1;
    var lo = 0;
    var hi = offsets.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (offsets[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  void _flipTrackedChapter(int segmentIndex, int unionLine) {
    final spans = _spansFor(_layout);
    final span = spans[segmentIndex];
    final previous = state.trackedSegmentIndex;
    _internalChapterFlip = true;
    if (state.segments[segmentIndex].episodeIndex >
        state.segments[previous].episodeIndex) {
      // Crossing forward: the reader scrolled past the outgoing chapter's
      // end, so it is finished — its history is written as complete
      // instead of the last reported line.
      _onChapterCompleted?.call(
        _groupIndex,
        state.segments[previous].episodeIndex,
        spans[previous].lineCount,
      );
    }
    _onTrackedEpisodeChanged?.call(
      _groupIndex,
      state.segments[segmentIndex].episodeIndex,
    );
    state = state.copyWith(
      trackedSegmentIndex: segmentIndex,
      totalLine: span.lineCount,
      line: span.lineCount == 0
          ? 1
          : (unionLine - span.startLine + 1).clamp(1, span.lineCount),
    );
  }

  /// For each [currentBlocks] block, the segment it belongs to — or -1 for
  /// the boundary tiles, which advance no chapter attribution.
  List<int> _segmentOfBlock() {
    final cached = _segmentOfBlockCache;
    final blocks = currentBlocks();
    if (cached != null && identical(_segmentOfBlockCacheKey, blocks)) {
      return cached;
    }
    final mapping = <int>[];
    final segments = state.segments;
    if (segments.isNotEmpty && segments.first.episodeIndex == 0) {
      mapping.add(-1);
    }
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) mapping.add(-1); // junction
      mapping.add(i); // chapter header
      final items = segments[i].items;
      if (items == null) continue;
      mapping.addAll(List<int>.filled(items.length, i));
    }
    if (segments.isNotEmpty &&
        segments.last.episodeIndex == _episodes.length - 1) {
      mapping.add(-1);
    }
    _segmentOfBlockCache = mapping;
    _segmentOfBlockCacheKey = blocks;
    return mapping;
  }

  List<int>? _segmentOfBlockCache;
  List<NovelContentBlock>? _segmentOfBlockCacheKey;

  /// Kicks off an adjacent-chapter fetch when the viewport is near either
  /// end of the loaded window.
  void _maybeLoadAdjacent(int blockIndex) {
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) return;
    final blocks = currentBlocks();
    if (blocks.isEmpty) return;
    if (blockIndex >= blocks.length - 4) _ensureAdjacent(1);
    if (blockIndex <= 3) _ensureAdjacent(-1);
  }

  Future<void> _ensureAdjacent(int direction) async {
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) return;
    if (state.segments.isEmpty) return;
    final boundary = direction > 0
        ? state.segments.last.episodeIndex + 1
        : state.segments.first.episodeIndex - 1;
    if (boundary < 0 || boundary >= _episodes.length) return;
    if (state.segments.any((s) => s.episodeIndex == boundary)) return;
    if (_loadingSegments.contains(boundary)) return;
    final episode = _episodes[boundary];
    // The session this fetch belongs to: a re-open or a dispose must void
    // the result, or stale blocks land in the new session's segment.
    final session = _openKey;
    _loadingSegments.add(boundary);
    final loading = ChapterSegment<NovelContentBlock>(
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
    final blocks = await _fetchChapterBlocks(episode);
    _loadingSegments.remove(boundary);
    // Async gap: the notifier may be disposed or the session may have
    // moved on while the fetch ran (see the manga reader's guard).
    if (!ref.mounted || _openKey != session) return;
    if (!state.segments.any((s) => s.episodeIndex == boundary)) return;
    _replaceSegment(
      boundary,
      loading.copyWith(items: blocks, loading: false, failed: blocks == null),
      atHead: direction < 0,
    );
  }

  int _flatLength(List<ChapterSegment<NovelContentBlock>> segments) {
    if (segments.isEmpty) return 0;
    final atStart = segments.first.episodeIndex == 0;
    final atEnd = segments.last.episodeIndex == _episodes.length - 1;
    var count = (atStart ? 1 : 0) + (atEnd ? 1 : 0);
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) count++; // junction
      count++; // chapter header
      final items = segments[i].items;
      count += items == null ? 1 : items.length;
    }
    return count;
  }

  /// Applies a segment list mutation, keeping the scroll position stable
  /// when the change extends the list at its head.
  void _commitSegments(
    List<ChapterSegment<NovelContentBlock>> segments, {
    bool atHead = false,
  }) {
    if (atHead) {
      final before = _flatLength(state.segments);
      final after = _flatLength(segments);
      final insertedBlocks = after - before;
      if (insertedBlocks > 0) _pendingPrependBlocks += insertedBlocks;
      final insertedSegments = segments.length - state.segments.length;
      if (insertedSegments > 0) {
        state = state.copyWith(
          trackedSegmentIndex: state.trackedSegmentIndex + insertedSegments,
        );
      }
    }
    state = state.copyWith(
      segments: List<ChapterSegment<NovelContentBlock>>.unmodifiable(segments),
    );
  }

  void _replaceSegment(
    int episodeIndex,
    ChapterSegment<NovelContentBlock> replacement, {
    required bool atHead,
  }) {
    _commitSegments([
      for (final segment in state.segments)
        segment.episodeIndex == episodeIndex ? replacement : segment,
    ], atHead: atHead);
  }

  /// Retries a failed chapter slot (tapping its error tile).
  Future<void> retrySegment(int episodeIndex) async {
    final index = state.segments.indexWhere(
      (s) => s.episodeIndex == episodeIndex,
    );
    if (index < 0) return;
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) return;
    if (_loadingSegments.contains(episodeIndex)) return;
    final episode = _episodes[episodeIndex];
    final session = _openKey;
    _loadingSegments.add(episodeIndex);
    _replaceSegment(
      episodeIndex,
      state.segments[index].copyWith(loading: true, failed: false),
      atHead: index == 0,
    );
    final blocks = await _fetchChapterBlocks(episode);
    _loadingSegments.remove(episodeIndex);
    // Async gap: the notifier may be disposed or the session may have
    // moved on while the fetch ran (see `_ensureAdjacent`).
    if (!ref.mounted || _openKey != session) return;
    final current = state.segments.indexWhere(
      (s) => s.episodeIndex == episodeIndex,
    );
    if (current < 0) return;
    _replaceSegment(
      episodeIndex,
      state.segments[current].copyWith(
        items: blocks,
        loading: false,
        failed: blocks == null,
      ),
      atHead: index == 0,
    );
  }

  Future<List<NovelContentBlock>?> _fetchChapterBlocks(
    ExtensionEpisode episode,
  ) async {
    final fetcher = debugChapterFetcher;
    if (fetcher != null) {
      final content = await fetcher(episode.url);
      return content == null ? null : parseNovelContent(content);
    }
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
      final data = watch_data.toNovelWatch(
        watch_data.unwrapAll(result.data, meta.type),
      );
      final content = data.content;
      if (content.isEmpty) return null;
      return parseNovelContent(List<String>.unmodifiable(content));
    } catch (error, stack) {
      logger.warning(
        'Failed to load adjacent chapter ${episode.url}',
        error,
        stack,
      );
      return null;
    }
  }

  /// One-shot: returns true when the reader itself flipped the tracked
  /// chapter (an infinite-scroll crossing) and clears the flag, so the shell
  /// skips its open() reset on the same frame and keeps the canvas.
  bool consumeChapterFlip() {
    final flipped = _internalChapterFlip;
    _internalChapterFlip = false;
    return flipped;
  }

  /// Whether the infinite window's tracked chapter is already
  /// [episodeIndex] — its blocks are loaded at the reader's live scroll
  /// position. Holds the line when the session refresh after a chain flip
  /// re-runs the shell's open effect (see the manga reader's helper).
  bool tracksEpisode(int episodeIndex) {
    final segments = state.segments;
    final tracked = state.trackedSegmentIndex;
    return tracked >= 0 &&
        tracked < segments.length &&
        segments[tracked].episodeIndex == episodeIndex;
  }

  /// Fresh session state: persisted display preferences, no position.
  NovelReaderState _sessionState() {
    return NovelReaderState(
      readMode: _readSetting<NovelReadMode>(
        SettingKey.novelReadingMode,
        NovelReadMode.webToon,
      ),
      fontFamily: _readSetting<NovelFontFamily>(
        SettingKey.novelFontFamily,
        NovelFontFamily.serif,
      ),
      fontSize: _readSetting<double>(
        SettingKey.novelFontSize,
        kNovelFontSizeDefault,
      ).clamp(kNovelFontSizeMin, kNovelFontSizeMax),
      lineHeight: _snap(
        _readSetting<double>(
          SettingKey.novelLineHeight,
          kNovelLineHeightDefault,
        ),
        kNovelLineHeightStep,
        kNovelLineHeightMin,
        kNovelLineHeightMax,
      ),
      margin: _snap(
        _readSetting<double>(SettingKey.novelMargin, kNovelMarginDefault),
        kNovelMarginStep,
        kNovelMarginMin,
        kNovelMarginMax,
      ),
      theme: _readSetting<NovelTheme>(
        SettingKey.novelTheme,
        NovelTheme.midnight,
      ),
      keepScreenOn: _readSetting<bool>(SettingKey.novelKeepScreenOn, true),
      tapToTurnPage: _readSetting<bool>(SettingKey.novelTapToTurnPage, true),
      volumeKeysTurnPage: _readSetting<bool>(
        SettingKey.novelVolumeKeysTurnPage,
        false,
      ),
      brightnessMode: _readSetting<MangaBrightnessMode>(
        SettingKey.mangaBrightnessMode,
        kNovelBrightnessModeDefault,
      ),
      brightness: _readSetting<int>(
        SettingKey.mangaBrightness,
        kNovelBrightnessDefault,
      ).clamp(kNovelBrightnessMin, kNovelBrightnessMax),
      bookmarks: _readBookmarks(),
    );
  }

  /// Settings may be missing (fresh install before the gRPC store answers, or a
  /// test that did not seed defaults), so every read falls back to a default
  /// instead of throwing.
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

  /// Bookmarks are stored as a comma-joined list. The empty string is the
  /// shipped default and must not become a bookmark named `''`.
  Set<String> _readBookmarks() {
    final raw = _readSetting<String>(SettingKey.novelBookmarks, '');
    if (raw.isEmpty) return const <String>{};
    return raw
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet();
  }

  /// Rounds [value] to the slider's [step] and clamps it into range, so a
  /// stored value from another device cannot land between two steps.
  static double _snap(double value, double step, double min, double max) {
    final snapped = (value / step).roundToDouble() * step;
    return snapped.clamp(min, max);
  }

  /// Publishes the canvas's measurement for the current typography and size.
  ///
  /// The position is re-anchored rather than kept. A reflow — a different font
  /// size, a different page margin, or a switch between reading modes, where the
  /// same prose is repacked into a different number of pages and lines — makes
  /// the old number meaningless. The reader is put back on the line they were
  /// reading, whichever mode they came from or go to.
  void setLayout(NovelLayout layout) {
    final anchor = _resumeAnchor(layout) ?? _anchorLine();
    _layout = layout;
    final windowActive = _windowActive;
    final spans = windowActive ? _spansFor(layout) : const [];
    final tracked = windowActive
        ? state.trackedSegmentIndex.clamp(0, state.segments.length - 1)
        : 0;
    final trackedSpan = windowActive ? spans[tracked] : null;
    final totalLine = windowActive
        ? (trackedSpan?.lineCount ?? 0)
        : layout.totalLine;
    final totalPage = layout.pages.length;
    final isPaged = state.isPaged;

    // Prepend compensation: blocks were inserted above the reader's line.
    // The anchor line is tracked per chapter, so it stays put; the scroll
    // offset must grow by the inserted extent instead.
    if (_pendingPrependBlocks > 0 && scrollController.hasClients) {
      final insertedHeight = _pendingPrependBlocks < layout.blockOffsets.length
          ? layout.blockOffsets[_pendingPrependBlocks]
          : layout.blockHeights.fold<double>(0, (a, b) => a + b);
      _isAdjusting = true;
      scrollController.jumpTo(
        (scrollController.offset + insertedHeight).clamp(
          0.0,
          scrollController.position.maxScrollExtent,
        ),
      );
      _isAdjusting = false;
      _pendingPrependBlocks = 0;
    }

    // Both units are always current: the mode decides which one the reader sees,
    // but the other is what a mode switch back will anchor on, and leaving it
    // stale made switching to a paged mode and back lose the place.
    // With a window loaded, the line is tracked local to the chapter; the
    // union coordinate space belongs to the scroll controller alone.
    final lineIsUnion = !windowActive;
    final unionAnchor = windowActive && trackedSpan != null
        ? trackedSpan.startLine + state.line - 1
        : anchor;
    final local = windowActive && trackedSpan != null
        ? (unionAnchor - trackedSpan.startLine + 1).clamp(
            1,
            math.max(1, trackedSpan.lineCount),
          )
        : anchor;
    final line = totalLine == 0
        ? 0
        : (lineIsUnion ? anchor : local).clamp(1, totalLine);
    var page = 0;
    if (isPaged && totalPage > 0) {
      final index = layout.pages.indexWhere(
        (candidate) => candidate.startLine >= anchor,
      );
      page = index < 0 ? totalPage : index + 1;
    }
    if (line == state.line &&
        totalLine == state.totalLine &&
        page == state.page &&
        totalPage == state.totalPage) {
      return;
    }
    final pageMoved = isPaged && page != state.page;
    state = state.copyWith(
      line: line,
      totalLine: totalLine,
      page: page,
      totalPage: totalPage,
    );
    if (isPaged) {
      if (pageMoved && pageController.hasClients) {
        // The page view still sits on the old index, and `jumpToPage` does not
        // report itself, so this cannot loop back through the reader.
        pageController.jumpToPage((page - 1).clamp(0, totalPage - 1));
      }
      return;
    }
    // Coming the other way — into the continuous scroll — the list is rebuilt
    // from the top, so the anchor line has to be put back on screen or the
    // reader lands at the start of the chapter.
    if (line > 0 && scrollController.hasClients) {
      final offset = !windowActive || trackedSpan == null
          ? (line - 1) * state.lineExtent
          : ((trackedSpan.startLine + line - 2)) * state.lineExtent;
      _isAdjusting = true;
      scrollController.jumpTo(
        offset.clamp(0.0, scrollController.position.maxScrollExtent),
      );
      _isAdjusting = false;
    }
  }

  /// Resolves the pending resume onto [layout] and consumes it.
  ///
  /// History stores the position in the unit the reading mode navigated in,
  /// which the reader only learns once the canvas has measured: a total equal
  /// to the measured line count is a line, one equal to the measured page
  /// count is a page, and anything else is a reflow (different font, device or
  /// mode) where the saved fraction converts to this layout's lines.
  ///
  /// Returns null while there is nothing to consume — no resume, or an empty
  /// first measurement, which keeps the pending pair for a real layout.
  int? _resumeAnchor(NovelLayout layout) {
    final pending = _pendingResume;
    if (pending == null || layout.totalLine <= 0) return null;
    _pendingResume = null;
    final (:progress, :totalProgress) = pending;
    if (totalProgress == layout.totalLine) {
      return progress.clamp(1, layout.totalLine);
    }
    if (layout.pages.isNotEmpty && totalProgress == layout.pages.length) {
      final page = progress.clamp(1, layout.pages.length);
      return layout.pages[page - 1].startLine;
    }
    final ratio = progress / totalProgress;
    return ((ratio * layout.totalLine).round()).clamp(1, layout.totalLine);
  }

  /// The line the reader is looking at, in the current layout.
  ///
  /// Deliberately not keyed on the mode: by the time a new layout arrives the
  /// mode has already changed, so asking "are we paged?" would answer for the
  /// mode being switched *to* rather than the one being left. A paged reader
  /// has a page number and no line of its own; a continuous one is the reverse.
  int _anchorLine() {
    if (state.page > 0 && _layout.pages.isNotEmpty) {
      return _layout
          .pages[(state.page - 1).clamp(0, _layout.pages.length - 1)]
          .startLine;
    }
    return state.line;
  }

  /// The canvas reports its position by scrolling, so the listener *is* the
  /// position source. Programmatic moves set [_isAdjusting] first, so a jump the
  /// reader asked for does not report the position it started from.
  void _onScroll() {
    if (_isAdjusting) return;
    _syncLineFromScroll();
  }

  /// The paged canvas reports its position the same way, through its page
  /// controller.
  ///
  /// Without this the page number only ever moved when the reader jumped it, so
  /// a swipe or an edge tap changed the page on screen while the scrubber, the
  /// status pill and the saved history stayed on the old number.
  ///
  /// Registered in [build], which a hot reload does not re-run for a notifier
  /// that is already alive — so after editing this, restart the app (or leave
  /// and re-enter the reader) before concluding a swipe does not report. Edge
  /// taps go through [turnPage] and work either way, which is what makes this
  /// easy to misread as fixed.
  void _onPageMoved() {
    if (!pageController.hasClients) return;
    final page = pageController.page;
    if (page == null || !state.isPaged) return;
    // Fractional while a swipe is in flight, so the *settled* page is reported.
    final index = (page.round() + 1).clamp(
      1,
      math.max(1, state.totalPage).toInt(),
    );
    if (index == state.page) return;
    state = state.copyWith(page: index);
  }

  void _syncLineFromScroll() {
    if (!scrollController.hasClients) return;
    final windowActive = _windowActive;
    if (!windowActive) {
      final line = _layout.lineForOffset(
        scrollController.offset,
        state.lineExtent,
      );
      if (line <= 0 || line == state.line) return;
      state = state.copyWith(line: line);
      return;
    }
    final offset = scrollController.offset;
    final blockIndex = _blockIndexAtOffset(offset);
    if (blockIndex < 0) return;
    final mapping = _segmentOfBlock();
    if (blockIndex >= mapping.length) return;
    final segIdx = mapping[blockIndex];
    if (segIdx == -1) return; // boundary tile: keep tracked attribution
    final layout = _layout;
    final unionLine = layout.lineForOffset(offset, state.lineExtent);
    if (unionLine <= 0) return;
    if (segIdx != state.trackedSegmentIndex) {
      _flipTrackedChapter(segIdx, unionLine);
      return;
    }
    final span = _spansFor(layout)[segIdx];
    if (span.lineCount == 0) return;
    final local = (unionLine - span.startLine + 1).clamp(1, span.lineCount);
    if (local == state.line) {
      _maybeLoadAdjacent(blockIndex);
      return;
    }
    state = state.copyWith(line: local);
    _maybeLoadAdjacent(blockIndex);
  }

  void setLine(int line) {
    final total = state.totalLine;
    if (total <= 0) return;
    state = state.copyWith(line: line.clamp(1, total));
  }

  void setPage(int page) {
    final total = state.totalPage;
    if (total <= 0) return;
    state = state.copyWith(page: page.clamp(1, total));
  }

  /// Scrolls the continuous canvas to [line].
  void jumpToLine(int line) {
    final total = state.totalLine;
    if (total <= 0 || !scrollController.hasClients) return;
    final lineExtent = state.lineExtent;
    if (lineExtent <= 0) return;
    final target = !_windowActive || state.segments.isEmpty
        ? (line - 1) * lineExtent
        : (_spansFor(_layout)[state.trackedSegmentIndex].startLine + line - 2) *
              lineExtent;
    setLine(line);
    _isAdjusting = true;
    unawaited(
      scrollController
          .animateTo(
            target.clamp(0, scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() => _isAdjusting = false),
    );
  }

  /// Animates the paged canvas to [page].
  void jumpToPage(int page) {
    final total = state.totalPage;
    if (total <= 0) return;
    setPage(page);
    if (!pageController.hasClients) return;
    final index = (page - 1).clamp(0, total - 1);
    _isAdjusting = true;
    unawaited(
      pageController
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() => _isAdjusting = false),
    );
  }

  /// Moves [delta] pages.
  ///
  /// The gesture is the same everywhere; the reading mode decides what it does.
  /// A paged mode turns the page, and the continuous mode has no pages, so the
  /// same edge tap nudges the scroll by most of a screenful.
  void turnPage(int delta) {
    if (!state.isPaged || state.totalPage <= 0) {
      _nudgeScroll(delta);
      return;
    }
    jumpToPage(state.page + delta);
  }

  void _nudgeScroll(int delta) {
    if (delta == 0 || !scrollController.hasClients) return;
    final position = scrollController.position;
    final step = position.viewportDimension * 0.75 * delta;
    final target = (scrollController.offset + step).clamp(
      0.0,
      position.maxScrollExtent,
    );
    if (target == scrollController.offset) return;
    _isAdjusting = true;
    unawaited(
      scrollController
          .animateTo(
            target,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() => _isAdjusting = false),
    );
  }

  void setHudVisible(bool visible) {
    if (visible == state.hudVisible) return;
    state = state.copyWith(hudVisible: visible);
  }

  void toggleHud() => setHudVisible(!state.hudVisible);

  void changeReadMode(NovelReadMode mode) {
    if (mode == state.readMode) return;
    MiruSettings.setSettingSync(SettingKey.novelReadingMode, mode.name);
    state = state.copyWith(readMode: mode);
  }

  void setFontFamily(NovelFontFamily family) {
    if (family == state.fontFamily) return;
    MiruSettings.setSettingSync(SettingKey.novelFontFamily, family.name);
    state = state.copyWith(fontFamily: family);
  }

  void setFontSize(double value) {
    final size = _snap(value, 1, kNovelFontSizeMin, kNovelFontSizeMax);
    if (size == state.fontSize) return;
    MiruSettings.setSettingSync(SettingKey.novelFontSize, '$size');
    state = state.copyWith(fontSize: size);
  }

  void setLineHeight(double value) {
    final height = _snap(
      value,
      kNovelLineHeightStep,
      kNovelLineHeightMin,
      kNovelLineHeightMax,
    );
    if (height == state.lineHeight) return;
    MiruSettings.setSettingSync(SettingKey.novelLineHeight, '$height');
    state = state.copyWith(lineHeight: height);
  }

  void setMargin(double value) {
    final margin = _snap(
      value,
      kNovelMarginStep,
      kNovelMarginMin,
      kNovelMarginMax,
    );
    if (margin == state.margin) return;
    MiruSettings.setSettingSync(SettingKey.novelMargin, '$margin');
    state = state.copyWith(margin: margin);
  }

  void setTheme(NovelTheme theme) {
    if (theme == state.theme) return;
    MiruSettings.setSettingSync(SettingKey.novelTheme, theme.name);
    state = state.copyWith(theme: theme);
  }

  void setKeepScreenOn(bool value) {
    if (value == state.keepScreenOn) return;
    MiruSettings.setSettingSync(SettingKey.novelKeepScreenOn, '$value');
    state = state.copyWith(keepScreenOn: value);
  }

  void setTapToTurnPage(bool value) {
    if (value == state.tapToTurnPage) return;
    MiruSettings.setSettingSync(SettingKey.novelTapToTurnPage, '$value');
    state = state.copyWith(tapToTurnPage: value);
  }

  void setVolumeKeysTurnPage(bool value) {
    if (value == state.volumeKeysTurnPage) return;
    MiruSettings.setSettingSync(SettingKey.novelVolumeKeysTurnPage, '$value');
    state = state.copyWith(volumeKeysTurnPage: value);
  }

  void setBrightnessMode(MangaBrightnessMode mode) {
    if (mode == state.brightnessMode) return;
    MiruSettings.setSettingSync(SettingKey.mangaBrightnessMode, mode.name);
    state = state.copyWith(brightnessMode: mode);
  }

  /// Sets the screen brightness.
  ///
  /// Choosing a brightness while the screen is on [MangaBrightnessMode.auto]
  /// means the reader wants a specific value, so it takes the screen over — the
  /// way Android's adaptive brightness does. The rule lives here, not in the
  /// slider, so every caller gets it and it can be tested.
  void setBrightness(int value) {
    final clamped = value.clamp(kNovelBrightnessMin, kNovelBrightnessMax);
    if (clamped == state.brightness) return;
    MiruSettings.setSettingSync(SettingKey.mangaBrightness, '$clamped');
    state = state.copyWith(brightness: clamped);
    if (state.brightnessMode == MangaBrightnessMode.auto) {
      setBrightnessMode(MangaBrightnessMode.manual);
    }
  }

  /// Restores every display preference to its shipped default and persists it.
  void resetDisplaySettings() {
    changeReadMode(NovelReadMode.webToon);
    setFontFamily(NovelFontFamily.serif);
    setFontSize(kNovelFontSizeDefault);
    setLineHeight(kNovelLineHeightDefault);
    setMargin(kNovelMarginDefault);
    setTheme(NovelTheme.midnight);
    setKeepScreenOn(true);
    setTapToTurnPage(true);
    setVolumeKeysTurnPage(false);
    setBrightnessMode(kNovelBrightnessModeDefault);
    setBrightness(kNovelBrightnessDefault);
  }

  /// Whether [episodeIndex] in [groupIndex] is bookmarked.
  bool isBookmarked(int groupIndex, int episodeIndex) =>
      state.bookmarks.contains('$groupIndex:$episodeIndex');

  /// Adds or removes the bookmark for one episode, leaving the rest alone.
  void toggleBookmark(int groupIndex, int episodeIndex) {
    final key = '$groupIndex:$episodeIndex';
    final bookmarks = {...state.bookmarks};
    if (!bookmarks.remove(key)) bookmarks.add(key);
    MiruSettings.setSettingSync(SettingKey.novelBookmarks, bookmarks.join(','));
    state = state.copyWith(bookmarks: bookmarks);
  }
}
