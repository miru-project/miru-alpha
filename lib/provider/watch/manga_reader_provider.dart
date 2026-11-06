import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
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

  /// Identity of the episode currently opened, so a shell rebuild that passes
  /// the same episode does not reset the reader's position.
  String? _openKey;

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
  /// Re-opening the episode that is already open is a no-op — a refetch of the
  /// same chapter must not throw the reader back to page one. A different
  /// episode starts a fresh session: position and HUD reset, the display
  /// preferences re-read from the store (they are persisted, so this only
  /// re-syncs them).
  void open({
    required int groupIndex,
    required int episodeIndex,
    required int totalPage,
  }) {
    final key = '$groupIndex:$episodeIndex:$totalPage';
    if (key == _openKey && ref.mounted) return;
    _openKey = key;
    isAdjusting = false;
    state = _sessionState(totalPage: totalPage);
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
    final visible = itemPositionsListener.itemPositions.value.where(
      (position) =>
          position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
    );
    if (visible.isEmpty) return;
    final firstVisible = visible.reduce((a, b) => a.index < b.index ? a : b);
    setPageNumber(firstVisible.index);
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

  void toggleHud() => setHudVisible(!state.hudVisible);

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
    switch (state.readMode) {
      case MangaReadMode.webToon:
        // A detached controller throws synchronously out of `scrollTo`; the
        // exception would leave the jump flags armed forever — page updates
        // gated off and the scrubber thumb locked on its last target.
        if (!itemScrollController.isAttached) return;
        _beginJump(token);
        itemScrollController
            .scrollTo(index: page, duration: const Duration(milliseconds: 100))
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
