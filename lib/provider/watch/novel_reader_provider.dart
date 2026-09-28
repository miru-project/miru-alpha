import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_pagination.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
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
  final List<String> content;
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
    this.content = const [],
    this.readMode = NovelReadMode.webToon,
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
    List<String>? content,
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
  }) {
    return NovelReaderState(
      content: content ?? this.content,
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
    );
  }
}

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

  @override
  NovelReaderState build(List<String>? content, String? localPath) {
    ref.onDispose(() {
      scrollController.removeListener(_onScroll);
      pageController.removeListener(_onPageMoved);
      scrollController.dispose();
      pageController.dispose();
    });
    scrollController.addListener(_onScroll);
    pageController.addListener(_onPageMoved);
    return NovelReaderState(
      content: content ?? const [],
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

  void setContent(List<String> content) {
    state = state.copyWith(content: content);
  }

  // ---------------------------------------------------------------------
  // Measured layout and position
  // ---------------------------------------------------------------------

  /// Publishes the canvas's measurement for the current typography and size.
  ///
  /// The position is re-anchored rather than kept. A reflow — a different font
  /// size, a different page margin, or a switch between reading modes, where the
  /// same prose is repacked into a different number of pages and lines — makes
  /// the old number meaningless. The reader is put back on the line they were
  /// reading, whichever mode they came from or go to.
  void setLayout(NovelLayout layout) {
    final anchor = _anchorLine();
    _layout = layout;
    final totalLine = layout.totalLine;
    final totalPage = layout.pages.length;
    final isPaged = state.isPaged;
    // Both units are always current: the mode decides which one the reader sees,
    // but the other is what a mode switch back will anchor on, and leaving it
    // stale made switching to a paged mode and back lose the place.
    final line = totalLine == 0 ? 0 : anchor.clamp(1, totalLine);
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
      _isAdjusting = true;
      scrollController.jumpTo(
        ((line - 1) * state.lineExtent).clamp(
          0,
          scrollController.position.maxScrollExtent,
        ),
      );
      _isAdjusting = false;
    }
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
    final line = _layout.lineForOffset(
      scrollController.offset,
      state.lineExtent,
    );
    if (line <= 0 || line == state.line) return;
    state = state.copyWith(line: line);
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
    final target = (line - 1) * lineExtent;
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

  // ---------------------------------------------------------------------
  // HUD
  // ---------------------------------------------------------------------

  void setHudVisible(bool visible) {
    if (visible == state.hudVisible) return;
    state = state.copyWith(hudVisible: visible);
  }

  void toggleHud() => setHudVisible(!state.hudVisible);

  // ---------------------------------------------------------------------
  // Display settings
  // ---------------------------------------------------------------------

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

  // ---------------------------------------------------------------------
  // Bookmarks
  // ---------------------------------------------------------------------

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
