import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/chapter_drawer.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manga_viewport.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_bottom_bar.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_overlay.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_settings_sheet.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_position_pill.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_status_pill.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/watch/history_session.dart';

/// Full-screen manga reader.
///
/// One widget owns the whole surface: the page canvas, the floating HUD (top
/// bar + control panel), and the two modal sheets. Keeping HUD state in
/// [MangaReaderState] means the settings sheet, the chapter drawer and the
/// canvas all read the same values instead of keeping local copies.
class MiruMangaReader extends HookConsumerWidget {
  const MiruMangaReader({
    super.key,
    required this.value,
    required this.name,
    required this.meta,
    required this.url,
    required this.epProvider,
    this.detailUrl,
  }) : localPath = null;

  const MiruMangaReader.local({
    super.key,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.localPath,
    this.detailUrl,
  }) : url = null,
       value = null;

  final ExtensionMangaWatch? value;
  final String name;
  final ExtensionMeta meta;
  final String? url;
  final EpisodeNotifierProvider epProvider;
  final String? localPath;

  /// Detail URL of the series; the infinite webtoon window needs it to
  /// lazily fetch sibling chapters. Null for local downloads.
  final String? detailUrl;

  @override
  Widget build(BuildContext context, WidgetRef container) {
    final epState = container.watch(epProvider);
    final groupIndex = epState.selectedGroupIndex.clamp(
      0,
      epState.epGroup.isEmpty ? 0 : epState.epGroup.length - 1,
    );
    final episodes = epState.epGroup.isEmpty
        ? const <ExtensionEpisode>[]
        : epState.epGroup[groupIndex].urls;
    final episodeIndex = epState.selectedEpisodeIndex.clamp(
      0,
      episodes.isEmpty ? 0 : episodes.length - 1,
    );
    // One reader state for the whole app (see [MangaReader]): the shell opens
    // the selected episode on it and keys the canvas on the same identity, so
    // an episode switch rebuilds the canvas from page one instead of keeping
    // the previous chapter's scroll position.
    final mangaProvider = mangaReaderProvider;
    // One watch per variable: a change to any one rebuilds the shell, but a
    // HUD toggle no longer rebuilds the canvas gate and vice versa. Selecting
    // derived getters (page, progress) keeps the HUD arithmetic in the
    // notifier, so widgets below compare primitives.
    final segmentsEmpty = container.watch(
      mangaProvider.select((s) => s.segments.isEmpty),
    );
    final hudVisible = container.watch(
      mangaProvider.select((s) => s.hudVisible),
    );
    final brightnessMode = container.watch(
      mangaProvider.select((s) => s.brightnessMode),
    );
    final brightness = container.watch(
      mangaProvider.select((s) => s.brightness),
    );
    final keepScreenOn = container.watch(
      mangaProvider.select((s) => s.keepScreenOn),
    );
    final page = container.watch(mangaProvider.select((s) => s.page));
    final totalPage = container.watch(mangaProvider.select((s) => s.totalPage));
    final progress = container.watch(mangaProvider.select((s) => s.progress));
    final totalPages = value?.urls.length ?? 0;
    final chapterLabel = episodes.isEmpty ? '' : episodes[episodeIndex].name;

    // Session injection on entry: the single reader state opens the selected
    // episode fresh — position and HUD reset, the display preferences re-read
    // from the store (they are persisted, so this only re-syncs them).
    // Deferred per the build-phase rule: a provider mutation inside a build
    // lifecycle throws, so the open lands in the first microtask after it.
    // Re-opening the episode that is already open is a no-op inside
    // [MangaReader.open].
    //
    // A chapter history has a reported page for re-opens there instead of page
    // one: the session state adopts it, and the canvas jump waits one frame so
    // it targets the fresh canvas rather than the outgoing one.
    //
    // Declared before the open effect because its completion callback clears
    // the armed save (see `onChapterCompleted` below).
    final historySave = useRef<Future<void> Function()?>(null);

    // The open effect must re-run once history has loaded.
    //
    // [HistoryPageNotifier.build] returns an empty history synchronously and
    // fills it from the DB in a later microtask, so the first pass of the open
    // effect sees no saved page and opens at page one. Without this the effect
    // never re-runs, the reader stays on page one, and the HUD shows the
    // history-derived page — the "indicator says page 6, the canvas is on
    // page 1" report. Watching the history length gives the effect a key that
    // flips the moment the entry arrives, so `findSavedReadingProgress` sees it
    // and the canvas opens on the saved page.
    final historyCount = container.watch(
      historyPageProvider.select((history) => history.history.length),
    );

    void flushHistory() {
      final save = historySave.value;
      historySave.value = null;
      if (save != null) unawaited(save());
    }

    // Captured while mounted: the flip/completion callbacks fire from the
    // provider long after this element may be gone, and Riverpod throws
    // "Using ref when a widget is about to or has been unmounted" for any
    // read they attempt then.
    // Episode writes are routed through this guard: the episode provider is
    // a family keyed by WatchParams (which includes the selected episode), so
    // every selectEpisode re-keys it and auto-disposes the element this shell
    // captured. Calling into a disposed notifier throws "Cannot use the Ref
    // of episodeProvider after it has been disposed" — which fired on every
    // scroll after a history chapter jump. A dropped write is correct there:
    // nobody listens to the dead element, and the live session re-arms its
    // own save.
    final epNotifier = container.read(epProvider.notifier);
    void withEpisode(void Function(EpisodeNotifier notifier) action) {
      try {
        action(epNotifier);
      } catch (error, stack) {
        logger.fine('Episode write skipped (provider disposed)', error, stack);
      }
    }

    useEffect(() {
      final reader = container.read(mangaReaderProvider.notifier);
      // A chapter flip initiated by the infinite webtoon itself must not
      // reset the canvas — the effect would otherwise jump the scroller
      // back to the top and reload the chapter.
      if (reader.consumeChapterFlip()) return null;
      final episodeUrl = episodes.isEmpty ? '' : episodes[episodeIndex].url;
      final saved = findSavedReadingProgress(
        history: container.read(historyPageProvider).history,
        package: meta.packageName,
        episodeUrl: episodeUrl,
      );
      final resumePage = saved == null ? null : saved.progress - 1;
      // The window already tracks this chapter (a chain flip landed here):
      // the session refresh that follows re-runs this effect with a new
      // page count, and re-opening would collapse the window and jump to
      // the chapter's history position. The flip's one-shot guard is spent
      // by then, so the tracked-chapter check is what holds the line.
      //
      // Exception: the session was opened before history loaded, so it has no
      // resume page yet. [HistoryPageNotifier.build] returns an empty list
      // synchronously and fills it from the DB in a later microtask, so this
      // effect re-runs when the entry arrives (`historyCount` is a key).
      // Re-opening then is the only way the reader reaches the saved page —
      // without it the first open wins, the canvas stays on page one, and the
      // HUD shows the history page: the "indicator says 6, the canvas is on 1"
      // report.
      //
      // The marker alone is NOT enough here. `_openKey` only describes the
      // chapter the reader OPENED on, so after an infinite-scroll flip it
      // names the outgoing chapter and every re-run for the new one slipped
      // through: `open()` wiped the window, the canvas remounted at slot 0
      // and the reader was thrown back to the top — the scroll-up flicker.
      // The durable identity is the window's own segments (see [isOpenFor]).
      diag(
        'SHELL effect group=$groupIndex ep=$episodeIndex total=$totalPages '
        'historyCount=$historyCount resume=$resumePage '
        'tracked=${reader.debugTrackedSegmentIndex} '
        'segs=${reader.debugSegments} '
        'openKey=${reader.debugOpenKey}',
      );
      diag('SHELL effect STACK\n${StackTrace.current}');
      if (reader.tracksEpisode(episodeIndex) &&
          !reader.needsResumeAdopt(resumePage)) {
        return null;
      }
      if (reader.isOpenFor(groupIndex, episodeIndex) &&
          !reader.needsResumeAdopt(resumePage)) {
        return null;
      }
      Future.microtask(() {
        reader.open(
          groupIndex: groupIndex,
          episodeIndex: episodeIndex,
          totalPage: totalPages,
          resumePage: resumePage,
          episodes: episodes,
          urls: value?.urls,
          chapterName: chapterLabel,
          meta: meta,
          detailUrl: detailUrl,
          onTrackedEpisodeChanged: (flipGroup, flipEpisode) =>
              withEpisode((n) => n.selectEpisode(flipGroup, flipEpisode)),
          // Crossing forward finishes the outgoing chapter: its completion
          // write supersedes the armed snapshot (which holds the last
          // reported page, possibly mid-chapter after a fast fling).
          onChapterCompleted: (flipGroup, flipEpisode, totalFlipped) {
            historySave.value = null;
            withEpisode(
              (n) => n.saveHistory(
                progress: totalFlipped,
                totalProgress: totalFlipped,
              ),
            );
          },
        );
        // No post-frame restore here. `open` already adopted the resume page
        // into `itemPosition`, and the canvas seeds
        // `ScrollablePositionedList.initialScrollIndex` from it, so the first
        // layout lands on the right page. A `jumpTo` after the frame laid out
        // and painted slot 0 first — the reader saw the chapter's opening page
        // flash before the page they had left.
      });
      return null;
    }, [groupIndex, episodeIndex, totalPages, historyCount]);

    // Screen preferences are a side effect of the settings, so they are an
    // effect rather than a build side effect: the applied values are remembered
    // in a ref so a rebuild does not re-issue a platform call every frame, and
    // the release is the effect's cleanup.
    final applied = useRef<ReaderScreenApplied?>(null);
    useEffect(() {
      applyReaderScreenPreferences(
        applied,
        brightnessMode,
        brightness,
        keepScreenOn,
      );
      return null;
    }, [brightnessMode, brightness, keepScreenOn]);
    useEffect(
      () =>
          () => unawaited(releaseReaderScreen()),
      const [],
    );

    // Snapshots history for the outgoing episode and re-arms it for the
    // incoming one. The chapter identity is the effect's key: the cleanup is
    // what detects the switch, and it also runs when the reader leaves the
    // tree. listenManual — not listen — because plain ref.listen subscriptions
    // close at the start of every rebuild, which would leave the save armed
    // with the entry snapshot forever.
    useEffect(() {
      // Re-arm only when the SAVED quantities change — not on HUD toggles,
      // jump flags or window growth, which copy the reader state just as
      // often and re-read three providers + allocate a History snapshot
      // each time. listenManual fires once on subscribe, which covers the
      // initial arm — arming again here double-registered the chapter at
      // open.
      container.listenManual(
        mangaProvider.select((s) => (s.historyProgress, s.totalPage)),
        (_, next) {
          withEpisode(
            (n) => historySave.value = n.prepareHistorySave(
              progress: next.$1,
              totalProgress: next.$2,
            ),
          );
        },
      );
      // The manual listener lives until the element unmounts; the cleanup is
      // only about snapshotting the outgoing episode.
      return flushHistory;
    }, [groupIndex, episodeIndex]);

    final reader = container.read(mangaProvider.notifier);
    final mediaPadding = MediaQuery.paddingOf(context);

    return Stack(
      fit: .expand,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Reading dismisses the overlay too, not just a centre tap: once
            // the reader starts scrolling the pages the HUD is in the way.
            //
            // Only a finger-driven **vertical** scroll counts. A horizontal
            // drag is page navigation — the thing the HUD is for — and a
            // programmatic jump (the scrubber, a chapter change) must not slam
            // the overlay shut either. `ScrollStartNotification` carries the
            // drag details; later updates in the same drag do not, so this is
            // also the only place a drag is acted on.
            final isDrag =
                notification is ScrollStartNotification &&
                notification.dragDetails != null &&
                notification.metrics.axis == Axis.vertical;
            if (isDrag && hudVisible) {
              logger.fine('HUD hide via scrollStart drag');
              reader.setHudVisible(false);
            }
            return false;
          },
          child: KeyedSubtree(
            key: ValueKey('manga-canvas-$groupIndex'),
            child: segmentsEmpty
                // The session is not open yet: `open` runs from the shell's
                // effect, one microtask after this build. Mounting the canvas
                // here would make the list read `initialScrollIndex` while
                // `itemPosition` is still 0, pinning it to page one — and the
                // fork reads that value only in initState, so the correct slot
                // the session adopts a frame later never reaches the list.
                //
                // Holding off one frame is what makes a history resume land on
                // the saved page: the canvas mounts on the build where
                // `segments` first has content, which is the same build that
                // carries the adopted `itemPosition`.
                ? const SizedBox.shrink()
                : MiruMangaViewPort(
                    data: value,
                    epProvider: epProvider,
                    mangaProvider: mangaProvider,
                    meta: meta,
                    name: name,
                    onTapCenter: reader.toggleHud,
                    // A magnified pan is raw pointer tracking: the view pins
                    // its scrollable, so there is no drag for the notification
                    // listener above to see and the view reports the move
                    // itself.
                    onViewMoved: () {
                      if (hudVisible) {
                        logger.fine('HUD hide via onViewMoved');
                        reader.setHudVisible(false);
                      }
                    },
                  ),
          ),
        ),
        // The HUD halves and the status pill cross-fade rather than being swapped
        // by a conditional, so a centre tap animates in both directions. All
        // three stay mounted and are gated by IgnorePointer instead.
        //
        // Each half slides in the direction it belongs to: the top bar drops
        // from above, the control panel rises from below. They are separate
        // layers because one shared layer can only slide one way.
        // Each half is positioned rather than a bare Stack child: the Stack is
        // `StackFit.expand`, so a non-positioned child is given *tight*
        // constraints and the bar's chrome would stretch over the whole screen,
        // swallowing every tap.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: ReaderOverlayLayer(
            visible: hudVisible,
            offset: -8,
            // The bar carries the safe-area inset INSIDE its chrome, so the
            // frosted surface covers the status-bar strip instead of leaving
            // the canvas showing through above it.
            child: ReaderTopBar(
              title: name,
              subtitle: chapterLabel,
              topInset: mediaPadding.top,
              onBack: () => Navigator.of(context).maybePop(),
              onToggleChapters: () => showChapterDrawer(
                context,
                epProvider: epProvider,
                openPosition: page,
                openTotal: totalPage,
              ),
              onOpenSettings: () => showReaderSettingsSheet(
                context,
                mangaProvider: mangaProvider,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: mediaPadding.bottom + 24,
          child: ReaderOverlayLayer(
            visible: hudVisible,
            offset: 24,
            child: Padding(
              // Reference footer: px-4 horizontally, pb-6 at the bottom.
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReaderBottomBar(
                mangaProvider: mangaProvider,
                epProvider: epProvider,
                onOpenChapters: () => showChapterDrawer(
                  context,
                  epProvider: epProvider,
                  openPosition: page,
                  openTotal: totalPage,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: ReaderOverlayLayer(
            visible: !hudVisible,
            offset: 8,
            child: ReaderPositionPill(
              isolated: hudVisible,
              childBuilder: (borderRadius, compact, showGrip) =>
                  ReaderStatusPill(
                    chapterLabel: chapterLabel,
                    page: page,
                    totalPage: totalPage,
                    progress: progress,
                    borderRadius: borderRadius,
                    compact: compact,
                    showGrip: showGrip,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
