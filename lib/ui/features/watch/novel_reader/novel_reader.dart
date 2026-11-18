import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/chapter_drawer.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_overlay.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_status_pill.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/widget/novel_bottom_bar.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/widget/novel_reading_view.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/widget/novel_settings_sheet.dart';
import 'package:miru_alpha/utils/watch/history_session.dart';

/// Full-screen novel (fiction) reader.
///
/// Structured exactly like [MiruMangaReader]: one widget owns the whole surface
/// — the chapter canvas, the floating HUD (top bar + control capsule) and the
/// two modal sheets — and all of it reads the same [NovelReaderState], so the
/// settings sheet, the chapter drawer and the page cannot disagree about where
/// the reader is or how the page is set.
class MiruNovelReader extends HookConsumerWidget {
  const MiruNovelReader({
    super.key,
    required this.value,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.detailImageUrl,
    this.detailUrl,
  }) : localPath = null;

  const MiruNovelReader.local({
    super.key,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.detailImageUrl,
    required this.localPath,
    this.detailUrl,
  }) : value = null;

  final ExtensionFikushonWatch? value;
  final String name;
  final ExtensionMeta meta;
  final EpisodeNotifierProvider epProvider;
  final String detailImageUrl;
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
    final novelProvider = novelReaderProvider;
    final state = container.watch(novelProvider);
    final reader = container.read(novelProvider.notifier);

    // The flat, chained list of blocks: this chapter plus every loaded
    // adjacent chapter, threaded with junction and boundary tiles. The provider
    // owns the window; the canvas renders it as-is.
    final anchorBlocks = useMemoized(
      () => parseNovelContent(value?.content ?? const <String>[]),
      [value?.content],
    );
    final segmentVersion = container.watch(
      novelReaderProvider.select((s) => s.segments),
    );
    final blocks = useMemoized(
      () => container.read(novelReaderProvider.notifier).currentBlocks(),
      [segmentVersion],
    );

    // Session injection on entry: the single reader state opens the selected
    // chapter fresh — position zero, display preferences re-read — the way a
    // per-chapter element used to. Deferred per the build-phase rule: a
    // provider mutation inside a build lifecycle throws, so the open lands in
    // the first microtask after it. Re-opening the same chapter is a no-op
    // inside [NovelReader.open].
    //
    // A chapter history has a reported position for re-opens there. The saved
    // unit (pages or lines) only maps onto the chapter once the canvas has
    // measured it, so the pair rides into [NovelReader.setLayout] instead of
    // being jumped from here.
    //
    // Declared before the open effect because its completion callback clears
    // the armed save (see `onChapterCompleted` below).
    final historySave = useRef<Future<void> Function()?>(null);
    void flushHistory() {
      final save = historySave.value;
      historySave.value = null;
      if (save != null) unawaited(save());
    }

    useEffect(() {
      final reader = container.read(novelReaderProvider.notifier);
      // A chapter flip initiated by the infinite webtoon itself must not
      // reset the canvas — the effect would otherwise jump the scroller
      // back to the top and reload the chapter.
      if (reader.consumeChapterFlip()) return null;
      // The window already tracks this chapter (a chain flip landed here):
      // the session refresh that follows re-runs this effect with a new
      // block count, and re-opening would jump to the chapter's history
      // position (see the manga reader's note).
      if (reader.tracksEpisode(episodeIndex)) return null;
      final episodeUrl = episodes.isEmpty ? '' : episodes[episodeIndex].url;
      final saved = findSavedReadingProgress(
        history: container.read(historyPageProvider).history,
        package: meta.packageName,
        episodeUrl: episodeUrl,
      );
      Future.microtask(
        () => reader.open(
          groupIndex: groupIndex,
          episodeIndex: episodeIndex,
          resume: saved,
          episodes: episodes,
          blocks: anchorBlocks,
          meta: meta,
          detailUrl: detailUrl,
          onTrackedEpisodeChanged: (flipGroup, flipEpisode) => container
              .read(epProvider.notifier)
              .selectEpisode(flipGroup, flipEpisode),
          // Crossing forward finishes the outgoing chapter: its completion
          // write supersedes the armed snapshot (see the manga reader).
          onChapterCompleted: (flipGroup, flipEpisode, totalFlipped) {
            historySave.value = null;
            container
                .read(epProvider.notifier)
                .saveHistory(
                  progress: totalFlipped,
                  totalProgress: totalFlipped,
                );
          },
        ),
      );
      return null;
    }, [groupIndex, episodeIndex]);

    // Screen preferences are a side effect of the settings, so they are an
    // effect rather than a build side effect: the applied values are remembered
    // in a ref so a rebuild does not re-issue a platform call every frame, and
    // the release is the effect's cleanup.
    final applied = useRef<ReaderScreenApplied?>(null);
    useEffect(() {
      applyReaderScreenPreferences(
        applied,
        state.brightnessMode,
        state.brightness,
        state.keepScreenOn,
      );
      return null;
    }, [state.brightnessMode, state.brightness, state.keepScreenOn]);
    useEffect(
      () =>
          () => unawaited(releaseReaderScreen()),
      const [],
    );

    // Snapshots history for the outgoing chapter and re-arms it for the
    // incoming one. The chapter identity is the effect's key: the cleanup is
    // what detects the switch, and it also runs when the reader leaves the
    // tree. listenManual — not listen — because plain ref.listen subscriptions
    // close at the start of every rebuild, which would leave the save armed
    // with the entry snapshot forever.
    useEffect(() {
      // Re-arm only when the saved quantities change — the snapshot record
      // has value equality, so HUD toggles, jump flags and window growth
      // never re-read the providers. listenManual fires once on subscribe,
      // which covers the initial arm (see the manga reader's note).
      container.listenManual(novelProvider.select((s) => s.historySnapshot), (
        _,
        next,
      ) {
        historySave.value = _prepareHistory(container, epProvider, next);
      });
      // The manual listener lives until the element unmounts; the cleanup is
      // only about snapshotting the outgoing chapter.
      return flushHistory;
    }, [groupIndex, episodeIndex]);

    final chapterLabel = episodes.isEmpty ? '' : episodes[episodeIndex].name;
    final mediaPadding = MediaQuery.paddingOf(context);
    void openChapters() => showChapterDrawer(
      context,
      epProvider: epProvider,
      openPosition: state.historyProgress,
      openTotal: state.totalProgress,
    );

    void openSettings() =>
        showNovelSettingsSheet(context, novelProvider: novelProvider);

    return Focus(
      autofocus: true,
      child: CallbackShortcuts(
        bindings: state.volumeKeysTurnPage
            ? {
                // The volume rocker turns pages forward/back, which is why the
                // keys are wired at the reader rather than in the app: they only
                // mean something while a page is on screen.
                const SingleActivator(LogicalKeyboardKey.audioVolumeUp): () =>
                    reader.turnPage(1),
                const SingleActivator(LogicalKeyboardKey.audioVolumeDown): () =>
                    reader.turnPage(-1),
              }
            : const {},
        child: Stack(
          fit: .expand,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Reading dismisses the overlay too, not just a centre tap:
                // once the reader starts scrolling the page the HUD is in the
                // way.
                //
                // Only a finger-driven **vertical** scroll counts. A horizontal
                // drag is page navigation — the thing the HUD is for — and a
                // programmatic jump (the scrubber, a chapter change) must not
                // slam the overlay shut either. `ScrollStartNotification` carries
                // the drag details; later updates in the same drag do not, so
                // this is also the only place a drag is acted on.
                final isDrag =
                    notification is ScrollStartNotification &&
                    notification.dragDetails != null &&
                    notification.metrics.axis == Axis.vertical;
                if (isDrag && state.hudVisible) reader.setHudVisible(false);
                return false;
              },
              child: NovelReadingView(
                // Keyed per group: a chapter flip inside the window must not
                // tear down the canvas — the window keeps scrolling.
                key: ValueKey('novel-canvas-$groupIndex'),
                blocks: blocks,
                novelProvider: novelProvider,
                onTapZone: (fromStart) =>
                    _onTapZone(reader, state.tapToTurnPage, fromStart),
              ),
            ),
            // The HUD halves and the status pill cross-fade rather than being
            // swapped by a conditional, so a centre tap animates in both
            // directions. All three stay mounted and are gated by IgnorePointer
            // instead.
            //
            // Each half slides in the direction it belongs to: the top bar drops
            // from above, the control capsule rises from below. They are separate
            // layers because one shared layer can only slide one way.
            //
            // Each half is positioned rather than a bare Stack child: the Stack
            // is `StackFit.expand`, so a non-positioned child is given *tight*
            // constraints and the bar's chrome would stretch over the whole
            // screen, swallowing every tap.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ReaderOverlayLayer(
                visible: state.hudVisible,
                offset: -8,
                // The chrome carries the safe-area inset so it covers the
                // status-bar strip (same as the manga reader).
                child: ReaderTopBar(
                  title: name,
                  subtitle: chapterLabel,
                  topInset: mediaPadding.top,
                  onBack: () => Navigator.of(context).maybePop(),
                  onToggleChapters: openChapters,
                  onOpenSettings: openSettings,
                  bookmarked: reader.isBookmarked(groupIndex, episodeIndex),
                  onToggleBookmark: () =>
                      reader.toggleBookmark(groupIndex, episodeIndex),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: mediaPadding.bottom + 24,
              child: ReaderOverlayLayer(
                visible: state.hudVisible,
                offset: 24,
                child: Padding(
                  // Reference footer: px-4 horizontally, pb-6 at the bottom.
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NovelBottomBar(
                    novelProvider: novelProvider,
                    epProvider: epProvider,
                    onOpenChapters: openChapters,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: mediaPadding.bottom + 24,
              child: ReaderOverlayLayer(
                visible: !state.hudVisible,
                offset: 8,
                child: ReaderStatusPill(
                  chapterLabel: chapterLabel,
                  page: state.historyProgress,
                  totalPage: state.totalProgress,
                  progress: state.progress,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Captures the history writer for the chapter currently on screen.
Future<void> Function() _prepareHistory(
  WidgetRef container,
  EpisodeNotifierProvider epProvider,
  ({int progress, int totalProgress}) snapshot,
) {
  return container
      .read(epProvider.notifier)
      .prepareHistorySave(
        progress: snapshot.progress,
        totalProgress: snapshot.totalProgress,
      );
}

/// Edge zones page, the middle toggles the HUD.
///
/// The centre tap is unconditional; only the edges obey `tapToTurnPage`, so
/// switching edge paging off still leaves a way to bring the overlay back.
void _onTapZone(NovelReader reader, bool tapToTurnPage, double fromStart) {
  if (!tapToTurnPage) {
    reader.toggleHud();
    return;
  }
  if (fromStart < kNovelTapZoneExtent) {
    reader.turnPage(-1);
  } else if (fromStart > 1 - kNovelTapZoneExtent) {
    reader.turnPage(1);
  } else {
    reader.toggleHud();
  }
}
