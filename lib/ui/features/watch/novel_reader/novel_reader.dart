import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
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
  }) : localPath = null;

  const MiruNovelReader.local({
    super.key,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.detailImageUrl,
    required this.localPath,
  }) : value = null;

  final ExtensionFikushonWatch? value;
  final String name;
  final ExtensionMeta meta;
  final EpisodeNotifierProvider epProvider;
  final String detailImageUrl;
  final String? localPath;

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
    final novelProvider = novelReaderProvider(value?.content, localPath);
    final state = container.watch(novelProvider);
    final reader = container.read(novelProvider.notifier);

    // The chapter's flat content list is split into typed blocks once, per
    // chapter, rather than per rebuild of every block.
    final blocks = useMemoized(
      () => parseNovelContent(value?.content ?? const <String>[]),
      [value?.content],
    );

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
    useEffect(() => () => unawaited(releaseReaderScreen()), const []);

    // Snapshots history for the outgoing chapter and re-arms it for the incoming
    // one. Provider identity changes when the selected episode changes, so the
    // provider itself is the effect's key: the cleanup is what detects the
    // switch, and it also runs when the reader leaves the tree.
    final historySave = useRef<Future<void> Function()?>(null);
    void flushHistory() {
      final save = historySave.value;
      historySave.value = null;
      if (save != null) unawaited(save());
    }

    useEffect(() {
      container.listen<NovelReaderState>(novelProvider, (_, next) {
        historySave.value = _prepareHistory(container, epProvider, next);
      });
      if (container.exists(novelProvider)) {
        historySave.value = _prepareHistory(
          container,
          epProvider,
          container.read(novelProvider),
        );
      }
      // Riverpod replaces the listener when this effect re-runs for a new
      // provider, and closes it with the element, so the cleanup is only about
      // snapshotting the outgoing episode.
      return flushHistory;
    }, [novelProvider]);

    final chapterLabel = episodes.isEmpty ? '' : episodes[episodeIndex].name;
    final mediaPadding = MediaQuery.paddingOf(context);
    void openChapters() => showChapterDrawer(
      context,
      epProvider: epProvider,
      bookmarks: state.bookmarks,
      openPosition: state.historyProgress,
      openTotal: state.totalProgress,
      onToggleBookmark: reader.toggleBookmark,
      onOpenSettings: () => showNovelSettingsSheet(
        context,
        novelProvider: novelProvider,
      ),
    );

    void openSettings() => showNovelSettingsSheet(
      context,
      novelProvider: novelProvider,
    );

    return Focus(
      autofocus: true,
      child: CallbackShortcuts(
        bindings: state.volumeKeysTurnPage
            ? {
                // The volume rocker turns pages forward/back, which is why the
                // keys are wired at the reader rather than in the app: they only
                // mean something while a page is on screen.
                const SingleActivator(LogicalKeyboardKey.audioVolumeUp):
                    () => reader.turnPage(1),
                const SingleActivator(LogicalKeyboardKey.audioVolumeDown):
                    () => reader.turnPage(-1),
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
                blocks: blocks,
                chapterTitle: chapterLabel,
                chapterOrdinal: episodeIndex + 1,
                novelProvider: novelProvider,
                onTapZone: (fromStart) => _onTapZone(
                  reader,
                  state.tapToTurnPage,
                  fromStart,
                ),
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
                child: Padding(
                  // The reference header is edge-to-edge, so the bar itself
                  // carries the inset and there is no horizontal margin here.
                  padding: EdgeInsets.only(top: mediaPadding.top),
                  child: ReaderTopBar(
                    title: name,
                    subtitle: chapterLabel,
                    onBack: () => Navigator.of(context).maybePop(),
                    onToggleChapters: openChapters,
                    onOpenSettings: openSettings,
                    bookmarked: reader.isBookmarked(groupIndex, episodeIndex),
                    onToggleBookmark: () =>
                        reader.toggleBookmark(groupIndex, episodeIndex),
                  ),
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
  NovelReaderState state,
) {
  final snapshot = state.historySnapshot;
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
void _onTapZone(
  NovelReader reader,
  bool tapToTurnPage,
  double fromStart,
) {
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
