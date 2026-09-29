import 'dart:async';

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
class MangaReaderState {
  final List<String> content;
  final double offset;
  final int itemPosition;
  final int totalPage;
  final MangaReadMode readMode;

  /// Whether the floating HUD (top bar + control panel) is shown.
  ///
  /// Starts hidden: the reader's resting state is the page alone, and a centre
  /// tap animates the overlay in or out. Not persisted, so every session opens
  /// the same way.
  final bool hudVisible;

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
    this.content = const [],
    this.offset = 0,
    this.totalPage = 0,
    this.itemPosition = 0,
    this.readMode = MangaReadMode.standard,
    this.hudVisible = false,
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
    List<String>? content,
    double? offset,
    int? itemPosition,
    int? totalPage,
    MangaReadMode? readMode,
    bool? hudVisible,
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
      content: content ?? this.content,
      totalPage: totalPage ?? this.totalPage,
      offset: offset ?? this.offset,
      itemPosition: itemPosition ?? this.itemPosition,
      readMode: readMode ?? this.readMode,
      hudVisible: hudVisible ?? this.hudVisible,
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
    final initState = MangaReaderState(
      content: data?.urls ?? [],
      totalPage: data?.urls.length ?? 0,
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
    ref.onDispose(() {
      _scrollSubscription?.cancel();
      pageController.dispose();
      itemPositionsListener.itemPositions.removeListener(
        _whenItemPositionChange,
      );
    });
    initListener();
    return initState;
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

  StreamSubscription<double>? _scrollSubscription;
  final itemPositionsListener = ItemPositionsListener.create();
  final scrollOffsetController = ScrollOffsetController();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final itemScrollController = ItemScrollController();

  /// Plain [PageController]: the reader's zoom is a paint transform over the
  /// pages, so nothing needs extended_image's own page controller — and its
  /// gesture page view would put a third set of recognisers in the arena.
  final PageController pageController = PageController();

  void initListener() {
    itemPositionsListener.itemPositions.addListener(_whenItemPositionChange);
    _scrollSubscription = scrollOffsetListener.changes.listen(
      _whenScrollOffsetChange,
    );
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

  void _whenScrollOffsetChange(double val) {
    state = state.copyWith(offset: val);
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
    if (isAdjusting || state.totalPage == 0) return;
    state = state.copyWith(itemPosition: page.clamp(0, state.totalPage - 1));
  }

  /// Steps the page by [delta], clamped to the available range.
  void stepPage(int delta) => jumpTo(state.itemPosition + delta);

  // Jump to the page and set the page number
  void jumpTo(int page) {
    if (state.totalPage == 0) return;
    setPageNumber(page);
    switch (state.readMode) {
      case MangaReadMode.webToon:
        isAdjusting = true;
        itemScrollController
            .scrollTo(index: page, duration: const Duration(milliseconds: 100))
            .then((_) {
              if (ref.mounted) isAdjusting = false;
            });
      case MangaReadMode.rightToLeft || MangaReadMode.standard:
        if (pageController.hasClients) {
          pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        }
    }
  }
}
