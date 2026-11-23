import 'dart:async';

import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/infinite_window.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_zoom_surface.dart';
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
///
/// Kept alive on purpose. The reader subtree is only built inside
/// `watchSessionProvider`'s `AsyncData` branch, so every chapter transition
/// (which re-keys the watch session and passes through `AsyncLoading`)
/// momentarily leaves this provider with no listeners. Auto-dispose tore the
/// notifier down there: `_openKey` reset to null and the window emptied, so
/// the next `open()` saw a fresh session and threw the reader back to slot 0 —
/// the scroll-up flicker that survived every guard inside `open()`.
@Riverpod(keepAlive: true)
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

  /// Bumped only when [open] starts a genuinely new session (a chapter the
  /// window does not already hold). In-flight adjacent fetches are voided when
  /// this moves on — and ONLY then.
  ///
  /// This is deliberately NOT `_openKey`: that key now follows the tracked
  /// chapter across flips, and a flip is not a new session — the window and
  /// its in-flight fetches persist through it. Gating the fetch on `_openKey`
  /// voided every neighbour fetch the moment the reader crossed a junction
  /// (the tracked chapter changed, the key followed, the pending ch1 fill was
  /// discarded), which is what re-broke the three-prepend drag test.
  int _sessionId = 0;

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
  /// complete (progress == total) — the shell owns the actual write.
  void Function(int groupIndex, int episodeIndex, int totalPages)?
  _onChapterCompleted;

  /// Episode indices with an in-flight adjacent-chapter fetch.
  final Set<int> _loadingSegments = {};

  /// Set when the reader itself flips the tracked chapter; the shell skips
  /// its open() reset on the same frame so the canvas stays.
  bool _internalChapterFlip = false;

  /// Memo for the flat slot list — the positions listener runs per scroll
  /// frame, so rebuilding it every tick would allocate a list per frame.
  List<WindowSlot>? _slotsCache;
  List<ChapterSegment<String>>? _slotsCacheKey;

  /// Offset at the last position report, for direction tracking. The
  /// positions stream fires post-frame — by then `userScrollDirection` has
  /// been reset to idle by the gesture ending — so direction is inferred
  /// from the offset delta between consecutive reports instead.
  double _lastReportedOffset = 0;

  /// The itemPosition the session opened at: the adopted resume page, or 0.
  ///
  /// The anchor for "has the reader moved since the session began" — see
  /// [_readerMoved].
  int _sessionStartItemPosition = 0;

  /// Whether the reader has live attribution away from where the session
  /// started — it scrolled, scrubbed, or flipped into another chapter.
  ///
  /// A resume page that disagrees with the current position afterwards is
  /// stale history, not a missed adopt: re-adopting it yanks the reader off
  /// the page it is looking at. Device log of the failure:
  ///
  ///   JUMP flip seg=2 page=0 prevEp=27 newEp=28   <- reader crosses back
  ///   SHELL effect ep=28 total=18 resume=18       <- history says page 18
  ///   JUMP open ep=28 resume=18 currentKey=0:28:18 <- dedupe re-adopts!
  ///   SLV jumpTo index=56                          <- teleported to the END
  ///   POS flat=56 offset=0.0 delta=8426.1
  ///
  /// The jump threw the reader from ep28's first page to its last, and the
  /// forward scrolling at that end cascaded appends of chapters 29-33.
  bool _readerMoved = false;

  /// Test seam: replaces the network fetch for adjacent chapters.
  @visibleForTesting
  Future<List<String>?> Function(String url)? debugChapterFetcher;

  /// Test seam: observes the (groupIndex, episodeIndex) passed to
  /// [onTrackedEpisodeChanged], so a test can assert the provider state has
  /// already moved to the new chapter at that moment.
  @visibleForTesting
  void Function(int groupIndex, int episodeIndex)? debugOnTrackedEpisodeChanged;

  /// Test seam: prepends the adjacent chapter on [direction]'s side, the same
  /// thing a threshold crossing in [_webtoonPositionChanged] triggers.
  ///
  /// The live path threads the URL and episode lookups through the shell, so
  /// only [debugChapterFetcher] can stand in for the network here.
  @visibleForTesting
  Future<void> debugEnsureAdjacent(int direction) => _ensureAdjacent(direction);

  /// Test seam: flips the tracked chapter to [segmentIndex] at [localPage],
  /// which is what a position report landing in a neighbouring chapter does.
  @visibleForTesting
  void debugFlipTo(int segmentIndex, int localPage) =>
      _flipTrackedChapter(segmentIndex, localPage);

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
      atSeriesEnd:
          s.segments.isNotEmpty &&
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

  /// The flat slot the list should open at, so the first layout lands on the
  /// resumed page.
  ///
  /// Resuming must not be a post-frame `jumpTo`: the canvas lays out at slot 0
  /// first and paints that frame before jumping, which the reader sees as the
  /// chapter's first page flashing before the page they left. The canvas seeds
  /// `ScrollablePositionedList.initialScrollIndex` from this instead, so the
  /// very first layout is already at the resume slot.
  int initialScrollSlot() {
    final page = state.itemPosition;
    final segments = state.segments;
    if (segments.isEmpty || page <= 0) return 0;
    return _flatIndexOfPage(state.trackedSegmentIndex, page);
  }

  /// A slot the viewport must move the list to.
  ///
  /// `ScrollablePositionedList.initialScrollIndex` is read only in `initState`,
  /// so changing it on an already-mounted list does nothing. A resume page
  /// adopted after the canvas mounted — which is what a re-entry into the same
  /// episode does, because `open()`'s dedupe early-return keeps the existing
  /// segment list — therefore cannot reach the list through
  /// `initialScrollIndex`. It is published here instead, and the viewport
  // listens and issues a `jumpTo`. Null when there is no pending jump.
  final ValueNotifier<int?> pendingJumpSlot = ValueNotifier(null);

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

  /// Bumped per notifier construction, so the log shows the provider being
  /// torn down and rebuilt mid-session — the only way `_openKey` is null and
  /// the window is empty at once.
  int _providerBirths = 0;

  @override
  MangaReaderState build() {
    // `_providerBirths` is a field initializer, so it survives the empty
    // `build()` — but nothing else about this notifier does. Log without
    // touching `state` (uninitialised at this point) or `_openKey` (reset
    // per instance).
    _providerBirths++;
    diag('PROVIDER create #$_providerBirths');
    ref.onDispose(() {
      // `onDispose` runs inside a lifecycle where touching `state` throws, so
      // only the dispose signal is logged here; the live identity is logged
      // from the shell instead (see `debugOpenKey`).
      diag('PROVIDER dispose #$_providerBirths');
      pageController.dispose();
      pendingJumpSlot.dispose();
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
    void Function(int groupIndex, int episodeIndex, int totalPages)?
    onChapterCompleted,
  }) {
    final key = '$groupIndex:$episodeIndex:$totalPage';
    diag(
      'JUMP open group=$groupIndex ep=$episodeIndex total=$totalPage '
      'resume=$resumePage currentKey=$_openKey '
      'segments=${state.segments.map((s) => s.episodeIndex).toList()} '
      'tracked=${state.trackedSegmentIndex}',
    );
    if (key == _openKey && ref.mounted) {
      // A re-open of the same episode is normally a no-op, but it must still
      // adopt a resume page that has only now become available: history loads
      // asynchronously, so a session opened before the entry arrived has none.
      // [needsResumeAdopt] refuses once the reader has live attribution
      // elsewhere — that position is the reader's, not a missed adopt.
      //
      // Setting `itemPosition` alone is not enough: the canvas is already
      // mounted and `ScrollablePositionedList.initialScrollIndex` is read only
      // in `initState`, so the list keeps the slot it opened at. Publishing the
      // slot is what lets the viewport move the list to the adopted page.
      if (needsResumeAdopt(resumePage) && state.totalPage > 0) {
        final page = resumePage!.clamp(0, state.totalPage - 1);
        state = state.copyWith(itemPosition: page);
        pendingJumpSlot.value = _flatIndexOfPage(
          state.trackedSegmentIndex,
          page,
        );
      }
      // Re-entry: the canvas is remounting at the tracked chapter's current
      // row, but the hysteresis anchor still describes the PREVIOUS session's
      // layout (it survives in this keepAlive notifier). Left stale, the boot
      // report is judged a backward blip against it: scrolling toward lower
      // slots attributed after the hysteresis, scrolling toward higher ones
      // stayed suppressed until the reader passed the old anchor — the pill
      // worked for the previous chapter but froze for the next one.
      _stableFirstVisible = _flatIndexOfPage(
        state.trackedSegmentIndex,
        state.itemPosition,
      );
      return;
    }
    _openKey = key;

    // Re-opening a chapter the window already holds must NEVER reset the
    // session. The old guard compared `key` with `_openKey`, but `_openKey`
    // only described the chapter the reader opened on: after a chain flip it
    // named the outgoing chapter, so the re-open slipped through, wiped the
    // session and remounted the canvas at slot 0 — the flicker.
    //
    // The window, not the open key, is the truth about what is mounted: if it
    // already holds this chapter, the reader is looking at it right now and a
    // reset would throw away that position. This cannot be defeated by stale
    // bookkeeping because it reads the same segments the canvas renders.
    if (ref.mounted && state.segments.isNotEmpty) {
      final already = state.segments.any((s) => s.episodeIndex == episodeIndex);
      if (already) {
        diag(
          'JUMP open ignored: ep=$episodeIndex already in window '
          'segs=${state.segments.map((s) => s.episodeIndex).toList()} '
          'tracked=${state.trackedSegmentIndex}',
        );
        if (needsResumeAdopt(resumePage) && state.totalPage > 0) {
          final page = resumePage!.clamp(0, state.totalPage - 1);
          state = state.copyWith(itemPosition: page);
          pendingJumpSlot.value = _flatIndexOfPage(
            state.trackedSegmentIndex,
            page,
          );
        }
        // Same re-entry re-seed as the dedupe path above: the canvas mounts
        // at the tracked chapter's row, so the anchor must describe THIS
        // layout, not the previous session's.
        _stableFirstVisible = _flatIndexOfPage(
          state.trackedSegmentIndex,
          state.itemPosition,
        );
        return;
      }
    }

    isAdjusting = false;

    // A genuinely new session: in-flight neighbour fetches from the previous
    // one must not land in this window (see `_sessionId`).
    _sessionId++;
    _readerMoved = false;

    _groupIndex = groupIndex;
    _episodes = List<ExtensionEpisode>.unmodifiable(episodes);
    _meta = meta;
    _detailUrl = detailUrl;
    _onTrackedEpisodeChanged = onTrackedEpisodeChanged;
    _onChapterCompleted = onChapterCompleted;
    _loadingSegments.clear();
    _slotsCache = null;
    _slotsCacheKey = null;

    final anchorUrls = urls == null
        ? List<String>.generate(totalPage, (_) => '', growable: false)
        : List<String>.unmodifiable(urls);
    final anchorTotal = anchorUrls.length;
    final name = chapterName.isNotEmpty
        ? chapterName
        : episodes.isNotEmpty &&
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
    final anchor = ChapterSegment<String>(
      episodeIndex: episodeIndex,
      name: name,
      url: url,
      items: anchorUrls,
    );

    final session = _sessionState(totalPage: anchorTotal)
        .copyWith(segments: [anchor], trackedSegmentIndex: 0);
    // Seed the backward-hysteresis anchor at the resume position so resumes
    // do not suppress attribution above it. The list re-anchors relative to
    // the resume slot, so this seeds the flat index we would expect.
    _stableFirstVisible = resumePage == null
        ? 0
        : resumePage.clamp(0, anchorTotal <= 0 ? 0 : anchorTotal - 1);
    _backwardFrames = 0;
    _lastReportedOffset = 0;
    // PAGE coordinates (itemPosition), not flat slots — this is what
    // [_readerMoved] compares against. Both session states below carry
    // exactly this position.
    _sessionStartItemPosition =
        resumePage == null || resumePage <= 0 || anchorTotal <= 0
        ? 0
        : resumePage.clamp(0, anchorTotal - 1);
    // A fresh session does NOT remount the canvas when the switch stays
    // within the same group (the shell keys the canvas on groupIndex only):
    // the mounted fork keeps the OLD anchor (its didUpdateWidget only clamps
    // targets, never re-pins), and the next position report attributes
    // whatever slot the shrunken list shows there — the "fresh episode starts
    // at page 15" report. Publishing the start slot on pendingJumpSlot makes
    // the viewport jump the mounted list to the new session's first page.
    final startPage = resumePage == null || resumePage <= 0 || anchorTotal <= 0
        ? 0
        : resumePage.clamp(0, anchorTotal - 1);
    if (resumePage == null || resumePage <= 0 || anchorTotal <= 0) {
      state = session;
    } else {
      state = session.copyWith(itemPosition: startPage);
    }
    pendingJumpSlot.value = _flatIndexOfPage(0, startPage);
  }

  /// Ends the session when the watch route is left (back to detail).
  ///
  /// keepAlive keeps this notifier alive through the watch session's
  /// `AsyncLoading` gaps — but the window, anchors and flags must not survive
  /// the route itself, or a re-entry starts entangled with the previous
  /// session's ref (the "every chapter intertwined with the previous one"
  /// report). This is the explicit teardown: controllers are NOT disposed
  /// (the notifier is kept alive, so its `build` never re-runs to recreate
  /// them); everything session-scoped is.
  void endSession() {
    _sessionId++;
    _openKey = null;
    _internalChapterFlip = false;
    _readerMoved = false;
    _backwardFrames = 0;
    _stableFirstVisible = 0;
    _lastReportedOffset = 0;
    _sessionStartItemPosition = 0;
    _loadingSegments.clear();
    _slotsCache = null;
    _slotsCacheKey = null;
    pendingJumpSlot.value = null;
    state = _sessionState();
  }

  /// Instant restore of [page] onto the canvas.
  ///
  /// The shell calls this one frame after [open] — the fresh canvas attaches
  /// the controllers while that frame lays out, so the jump targets the new
  /// canvas rather than the outgoing one. Instant on purpose: an animated fly
  /// through a resumed chapter churns the position stream and builds pages the
  /// reader never looks at.
  void restorePosition(int page) {
    diag(
      'JUMP restorePosition page=$page total=${state.totalPage} '
      'tracked=${state.trackedSegmentIndex} '
      'segs=${state.segments.map((s) => s.episodeIndex).toList()}',
    );
    if (!ref.mounted || state.totalPage == 0) return;
    final target = page.clamp(0, state.totalPage - 1);
    switch (state.readMode) {
      case MangaReadMode.webToon:
        if (itemScrollController.isAttached) {
          final flat = state.segments.isNotEmpty
              ? _flatIndexOfPage(state.trackedSegmentIndex, target)
              : target;
          itemScrollController.jumpTo(index: flat);
          // A jump re-frames the magnified view onto the landing page (see
          // [ReaderZoomController.reanchor]); a no-op at 1x.
          webtoonZoom.reanchor();
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

  /// Zoom handle for the webtoon canvas. Owned here (like the controllers
  /// above) so the viewport does not have to keep it across rebuilds and a
  /// programmatic jump can re-frame the magnified view onto its landing
  /// page via [ReaderZoomController.reanchor].
  final ReaderZoomController webtoonZoom = ReaderZoomController();

  bool _listenersInitialized = false;

  void initListener() {
    if (_listenersInitialized) return;
    _listenersInitialized = true;
    itemPositionsListener.itemPositions.addListener(_whenItemPositionChange);
  }

  void _whenItemPositionChange() {
    if (state.readMode == MangaReadMode.webToon && state.segments.isNotEmpty) {
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
    final segmentsAtEntry = state.segments;
    if (slots.isEmpty) return;
    // Direction from the offset delta: the positions stream fires
    // post-frame, by which time `userScrollDirection` has been reset to
    // idle. The offset itself is the ground truth — negative delta = head
    // (reverse), positive = tail (forward). Programmatic jumps are
    // excluded: `isAdjusting` gates them. This fires on EVERY report,
    // before the attribution hysteresis below — loading is not gated by
    // the chapter-flip debounce.
    final offset = scrollOffsetController.offset;
    final delta = offset - _lastReportedOffset;
    _lastReportedOffset = offset;
    final direction = delta < -0.5
        ? ScrollDirection.reverse
        : delta > 0.5
        ? ScrollDirection.forward
        : ScrollDirection.idle;
    diag(
      'POS flat=${firstVisible.index} stable=$_stableFirstVisible '
      'offset=${offset.toStringAsFixed(1)} delta=${delta.toStringAsFixed(1)} '
      'dir=$direction adjusting=$isAdjusting',
    );
    if (!isAdjusting) {
      _maybeLoadAdjacent(firstVisible.index, direction);
    }

    // A synchronous prepend (_maybeLoadAdjacent -> _ensureAdjacent) re-indexed
    // the window under THIS report. The report's index belongs to the OLD
    // layout, but the hysteresis anchor was already shifted to the new one;
    // comparing them directly would misjudge a stationary reader as a
    // backward blip. Re-base the index by the slot delta — for the hysteresis
    // comparison only.
    //
    // The slot lookup below deliberately stays in OLD coordinates (that is
    // what the index was measured against); the segment it names is
    // translated by episode identity instead, which is exact for prepends and
    // a no-op for appends.
    var hysteresisIndex = firstVisible.index;
    final headInserted =
        state.segments.isNotEmpty &&
        segmentsAtEntry.isNotEmpty &&
        !identical(state.segments.first, segmentsAtEntry.first);
    if (headInserted) {
      final slotsAfterLoad = _slots();
      hysteresisIndex += slotsAfterLoad.length - slots.length;
      diag(
        'POS re-based flat=${firstVisible.index} -> $hysteresisIndex '
        'after head insert ${slotsAfterLoad.length - slots.length}',
      );
    }

    // Backward blip filter: the positions stream sometimes re-reports a slot
    // the user has already scrolled past when an image above re-lays out the
    // list. Require the backward position to persist across consecutive frames
    // before letting attribution follow it.
    final stable = _stableFirstVisible;
    if (hysteresisIndex < stable) {
      _backwardFrames++;
      if (_backwardFrames < _backwardHysteresisFrames) {
        diag(
          'window_track suppressed-blip flat=$hysteresisIndex '
          'raw=${firstVisible.index} '
          'stable=$stable dir=$direction segs=${state.segments.map((s) => s.episodeIndex).toList()} '
          'tracked=${state.trackedSegmentIndex} total=${state.totalPage}',
        );
        return;
      }
    } else {
      _backwardFrames = 0;
      _stableFirstVisible = hysteresisIndex;
    }

    final slot = slots[firstVisible.index.clamp(0, slots.length - 1)];
    if (slot.kind == SlotKind.page) {
      var segmentIndex = slot.segmentIndex;
      if (headInserted && segmentIndex < segmentsAtEntry.length) {
        // The slot names a segment by its OLD position; find that chapter's
        // position in the CURRENT window. A prepend shifted every existing
        // segment; without this the stale index lands on the freshly
        // inserted loading placeholder and the flip cascade begins.
        final episode = segmentsAtEntry[segmentIndex].episodeIndex;
        final translated = state.segments.indexWhere(
          (s) => s.episodeIndex == episode,
        );
        if (translated >= 0) segmentIndex = translated;
        diag(
          'POS segment re-based ${slot.segmentIndex} -> $segmentIndex '
          '(ep $episode) after head insert',
        );
      }
      if (segmentIndex != state.trackedSegmentIndex) {
        diag(
          'window_track FLIP seg=$segmentIndex page=${slot.pageIndex} '
          'tracked=${state.trackedSegmentIndex} dir=$direction '
          'segs=${state.segments.map((s) => s.episodeIndex).toList()}',
        );
        _flipTrackedChapter(segmentIndex, slot.pageIndex);
      } else {
        // Reaching here means the hysteresis let the report through: either it
        // was not a backward move, or it persisted long enough to be accepted.
        // The early return above already swallowed the transient backward blips,
        // so this is the first point where writing the page number is safe.
        setPageNumber(slot.pageIndex);
      }
    }
  }

  void _flipTrackedChapter(int segmentIndex, int localPage) {
    final segment = state.segments[segmentIndex];
    // A loading or failed segment has no pages: attributing the reader to it
    // would zero the page and park the session on a chapter that cannot be
    // read yet (its flat index lookup also misses, resetting the hysteresis
    // anchor to 0). A report landing here is a measurement artifact of the
    // window growing under it; the real crossing is attributed once the pages
    // arrive and the stream re-reports.
    if (segment.items == null) {
      diag(
        'JUMP flip ignored: seg=$segmentIndex ep=${segment.episodeIndex} '
        'has no pages (loading=${segment.loading} failed=${segment.failed})',
      );
      return;
    }
    final previous = state.segments[state.trackedSegmentIndex];
    _internalChapterFlip = true;
    // A flip is live attribution: the reader crossed into another chapter and
    // its position is the reader's, however it compares with history.
    _readerMoved = true;
    diag(
      'JUMP flip seg=$segmentIndex page=$localPage '
      'prevSeg=${state.trackedSegmentIndex} prevEp=${previous.episodeIndex} '
      'newEp=${segment.episodeIndex} '
      'forward=${segment.episodeIndex > previous.episodeIndex} '
      'total=${state.totalPage} itemPos=${state.itemPosition}',
    );
    if (segment.episodeIndex > previous.episodeIndex) {
      // Crossing forward: the reader scrolled past the outgoing chapter's
      // end, so it is finished — its history is written as complete
      // instead of the last reported page (a fast fling can skip the
      // final page reports).
      _onChapterCompleted?.call(
        _groupIndex,
        previous.episodeIndex,
        previous.items?.length ?? 0,
      );
    }
    // The attribution anchor is monotone — it is only ever raised, because a
    // backward report is usually an image re-laying out above the viewport.
    // After a flip the flat indices of the chapter the reader is in change
    // completely, so the old anchor no longer describes where they are: left
    // stale it sits ABOVE the reader's new index and the next forward report
    // is swallowed by the backward-hysteresis guard, leaving the pill on the
    // previous chapter until the reader jiggles the scroll.
    //
    // Re-seed it at the flipped page so attribution resumes immediately.
    _stableFirstVisible = _flatIndexOfPage(segmentIndex, localPage);
    _backwardFrames = 0;
    // The session identity has to follow the tracked chapter. The shell's open
    // effect re-runs when `onTrackedEpisodeChanged` moves the episode
    // provider, and it checks `isOpenFor` against `_openKey`: left describing
    // the outgoing chapter, that check fails, the effect calls `open()`, and
    // the session is wiped and remounted at slot 0 — the flicker. Only the
    // episode changes; the total page count follows the segment's own items.
    _openKey =
        '$_groupIndex:${segment.episodeIndex}:'
        '${segment.items?.length ?? state.totalPage}';
    // State must land BEFORE the listeners fire. `selectEpisode` refreshes the
    // episode notifier's `_capturedState`, and `prepareHistorySave` bakes the
    // episode identity (url, episodeId, title) out of it. Calling the listeners
    // first let a history save armed from the outgoing state write the new
    // chapter's progress onto the PREVIOUS chapter's row — the "page 18 of
    // chapter 231 saved as chapter 230" report.
    state = state.copyWith(
      trackedSegmentIndex: segmentIndex,
      totalPage: segment.items?.length ?? state.totalPage,
      itemPosition: segment.items == null
          ? 0
          : localPage.clamp(0, segment.items!.length - 1),
    );
    _onTrackedEpisodeChanged?.call(_groupIndex, segment.episodeIndex);
    debugOnTrackedEpisodeChanged?.call(_groupIndex, segment.episodeIndex);
  }

  /// One-shot: returns true when the reader itself flipped the tracked
  /// chapter (an infinite-scroll crossing) and clears the flag, so the shell
  /// skips its open() reset on the same frame and keeps the canvas.
  bool consumeChapterFlip() {
    final flipped = _internalChapterFlip;
    _internalChapterFlip = false;
    return flipped;
  }

  /// Whether the tracked chapter is [episodeIndex] — its pages are loaded at
  /// the reader's live scroll position.
  ///
  /// The shell's open effect also re-runs when the watch session refreshes
  /// the new episode's page list after a chain flip (the flip's one-shot
  /// guard is long spent by then). Re-opening there would collapse the
  /// window to the single chapter AND jump to its history position — the
  /// "scrolling into the previous chapter yanks me to its saved page" bug.
  /// A user-initiated chapter switch has a different tracked chapter and
  /// still opens normally.
  bool tracksEpisode(int episodeIndex) {
    final segments = state.segments;
    final tracked = state.trackedSegmentIndex;
    return tracked >= 0 &&
        tracked < segments.length &&
        segments[tracked].episodeIndex == episodeIndex;
  }

  /// Whether the reader already has a session open for [groupIndex]/[episodeIndex].
  ///
  /// Unlike [tracksEpisode] this does not read `state.segments`, which is
  /// rebuilt asynchronously — during a chain flip it is momentarily empty, and
  /// the shell's open effect then saw "not tracked" and called [open], which
  /// wiped the session and remounted the canvas at slot 0. `_openKey` is set
  /// once by [open] and survives that churn, so it is the reliable identity.
  bool isOpenFor(int groupIndex, int episodeIndex) {
    final key = _openKey;
    if (key == null) return false;
    return key == '$groupIndex:$episodeIndex:${state.totalPage}';
  }

  /// Whether a resume page is now available that the current session did not
  /// adopt when it opened.
  ///
  /// [HistoryPageNotifier.build] returns an empty history synchronously and
  /// fills it from the DB a microtask later. A reader opened in that first
  /// window has no resume page, so it starts at page one; when the entry
  /// arrives the shell re-runs its open effect, and this is what tells it to
  /// re-open rather than bail out on [tracksEpisode]. Without it the first
  /// open wins forever and the reader sits on page one while the HUD reports
  /// the saved page.
  ///
  /// Only while the reader still sits where the session started, though. Once
  /// it has live attribution elsewhere — it scrolled, or flipped into another
  /// chapter and back — the position is the reader's, and a disagreeing
  /// history page is stale, not a missed adopt. Adopting it then threw the
  /// reader from a chapter's first page to its last (see [_readerMoved]).
  ///
  /// [resumePage] is null when history has no entry for this episode, so a
  /// reader with nothing to resume never re-opens.
  bool needsResumeAdopt(int? resumePage) {
    if (resumePage == null || resumePage <= 0) return false;
    if (_readerMoved) return false;
    return state.itemPosition != resumePage;
  }

  /// The session key of the currently open chapter (`group:episode:pages`), or
  /// null when nothing has been opened yet.
  String? get debugOpenKey => _openKey;

  /// Diagnostics for the shell's effect log: current attribution without
  /// handing out the mutable state.
  int get debugTrackedSegmentIndex => state.trackedSegmentIndex;

  /// Diagnostics: the window's chapter list.
  List<int> get debugSegments =>
      state.segments.map((s) => s.episodeIndex).toList();

  /// Kicks off an adjacent-chapter fetch when the viewport is near the end of
  /// the loaded window **in the direction the reader is travelling**.
  ///
  /// The positions stream reports on every layout, so an ungated check sees a
  /// boot-time report (flat 0, anchor-only window) as an approach to BOTH
  /// edges at once and eagerly fetches two neighbours — the "loading 2 not 1"
  /// report. Gating on the live scroll direction loads lazily and one chapter
  /// at a time: idle (boot, re-pin frames, programmatic jumps) loads nothing.
  void _maybeLoadAdjacent(int flatIndex, ScrollDirection direction) {
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) return;
    final length = _slots().length;
    if (direction == ScrollDirection.reverse && flatIndex <= 3) {
      _ensureAdjacent(-1);
    }
    if (direction == ScrollDirection.forward && flatIndex >= length - 4) {
      _ensureAdjacent(1);
    }
  }

  /// A drag pushed past either end of the loaded window.
  ///
  /// The only scroll signal that still fires when there is no content beyond
  /// the edge to scroll into: entering at chapter C page 1 there is nothing
  /// above the anchor, so scrolling up never changes the position stream —
  /// the overscroll notification is what loads the previous chapter.
  void onWebtoonOverscroll(double overscroll) {
    if (state.readMode != MangaReadMode.webToon) return;
    if (_episodes.isEmpty || _meta == null || _detailUrl == null) return;
    if (overscroll < 0) {
      _ensureAdjacent(-1);
    } else if (overscroll > 0) {
      _ensureAdjacent(1);
    }
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
    // The session this fetch belongs to: a re-open that starts a NEW session
    // (or a dispose) must void the result, or stale data lands in the NEW
    // session's segment with the same episodeIndex. A chapter FLIP is not a
    // new session — the window persists — so this is `_sessionId`, not the
    // open-key that follows the tracked chapter.
    final session = _sessionId;
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
    // Async gap: the notifier may be disposed (reader closed) or the
    // session may have moved on (chapter re-opened) while the fetch ran.
    if (!ref.mounted || _sessionId != session) return;
    if (!state.segments.any((s) => s.episodeIndex == boundary)) return;
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
      atSeriesStart: segments.isNotEmpty && segments.first.episodeIndex == 0,
      atSeriesEnd:
          segments.isNotEmpty &&
          _episodes.isNotEmpty &&
          segments.last.episodeIndex == _episodes.length - 1,
    ).length;
    var trackedSegmentIndex = state.trackedSegmentIndex;
    if (atHead) {
      final delta = after - before;
      final insertedSegments = segments.length - state.segments.length;
      diag(
        'JUMP commitSegments atHead delta=$delta '
        'insertedSegments=$insertedSegments '
        'before=$before after=$after '
        'tracked=$trackedSegmentIndex stable=$_stableFirstVisible '
        'segs=${state.segments.map((s) => s.episodeIndex).toList()} '
        '-> ${segments.map((s) => s.episodeIndex).toList()}',
      );
      if (insertedSegments > 0) {
        // The same logical chapter is now further into the list; the index
        // it is tracked by moves with it.
        trackedSegmentIndex += insertedSegments;
      }
      if (delta > 0 && state.readMode == MangaReadMode.webToon) {
        // The anchored layout re-pins on the same logical row, so every slot
        // index after the insertion point moves by `delta`. The hysteresis
        // anchor is such an index: leaving it unshifted made the next position
        // report look like a backward blip, which the guard then swallowed for
        // four frames — the reader sat on the wrong chapter until it settled.
        // This is the "scroll up into the previous chapter and it jumps to the
        // next one" report.
        _stableFirstVisible += delta;
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
    final session = _sessionId;
    _loadingSegments.add(episodeIndex);
    _replaceSegment(
      episodeIndex,
      state.segments[index].copyWith(loading: true, failed: false),
      atHead: index == 0,
    );
    final urls = await _fetchChapterUrls(episode);
    _loadingSegments.remove(episodeIndex);
    // Async gap: the notifier may be disposed or the session may have
    // moved on while the fetch ran (see `_ensureAdjacent`).
    if (!ref.mounted || _sessionId != session) return;
    final current = state.segments.indexWhere(
      (s) => s.episodeIndex == episodeIndex,
    );
    if (current < 0) return;
    _replaceSegment(
      episodeIndex,
      state.segments[current].copyWith(
        items: urls,
        loading: false,
        failed: urls == null,
      ),
      atHead: index == 0,
    );
  }

  void _replaceSegment(
    int episodeIndex,
    ChapterSegment<String> replacement, {
    required bool atHead,
  }) {
    if (!ref.mounted) return;
    _commitSegments([
      for (final segment in state.segments)
        segment.episodeIndex == episodeIndex ? replacement : segment,
    ], atHead: atHead);
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
    // Any position away from where the session started is live attribution:
    // a resume page that disagrees with it afterwards is stale history, not a
    // missed adopt (see [needsResumeAdopt]). Checked before the echo guard —
    // the check must run even when the write is a no-op.
    if (next != _sessionStartItemPosition) _readerMoved = true;
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
    diag(
      'JUMP jumpTo page=$page itemPosition=${state.itemPosition} '
      'total=${state.totalPage} adjusting=$isAdjusting '
      'segs=${state.segments.map((s) => s.episodeIndex).toList()}',
    );
    if (state.totalPage == 0) return;
    _writePage(page);
    final token = ++_jumpGeneration;
    final flatTarget =
        state.readMode == MangaReadMode.webToon && state.segments.isNotEmpty
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
              (_) {
                _endJump(token);
                // The jump re-anchored the list (possibly onto a new anchor
                // item): re-frame the magnified view onto the landing page
                // instead of leaving stale translated content on screen.
                webtoonZoom.reanchor();
              },
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
