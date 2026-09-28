import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/chapter_drawer.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manga_viewport.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_bottom_bar.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_overlay.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_settings_sheet.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_status_pill.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';

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
  }) : localPath = null;

  const MiruMangaReader.local({
    super.key,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.localPath,
  }) : url = null,
       value = null;

  final ExtensionMangaWatch? value;
  final String name;
  final ExtensionMeta meta;
  final String? url;
  final EpisodeNotifierProvider epProvider;
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
    final mangaProvider = mangaReaderProvider(
      epState.selectedEpisodeIndex,
      episodes.length,
      value,
    );
    final state = container.watch(mangaProvider);

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

    // Snapshots history for the outgoing episode and re-arms it for the incoming
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
      container.listen<MangaReaderState>(mangaProvider, (_, next) {
        historySave.value = container
            .read(epProvider.notifier)
            .prepareHistorySave(
              progress: next.historyProgress,
              totalProgress: next.totalPage,
            );
      });
      if (container.exists(mangaProvider)) {
        historySave.value = container
            .read(epProvider.notifier)
            .prepareHistorySave(
              progress: container.read(mangaProvider).historyProgress,
              totalProgress: container.read(mangaProvider).totalPage,
            );
      }
      // Riverpod replaces the listener when this effect re-runs for a new
      // provider, and closes it with the element, so the cleanup is only about
      // snapshotting the outgoing episode.
      return flushHistory;
    }, [mangaProvider]);

    final chapterLabel = episodes.isEmpty ? '' : episodes[episodeIndex].name;
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
            if (isDrag && state.hudVisible) reader.setHudVisible(false);
            return false;
          },
          child: MiruMangaViewPort(
            data: value,
            epProvider: epProvider,
            mangaProvider: mangaProvider,
            meta: meta,
            name: name,
            onTapCenter: reader.toggleHud,
            // A magnified pan is raw pointer tracking: the view pins its
            // scrollable, so there is no drag for the notification listener
            // above to see and the view reports the move itself.
            onViewMoved: () {
              if (container.read(mangaProvider).hudVisible) {
                reader.setHudVisible(false);
              }
            },
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
            visible: state.hudVisible,
            offset: -8,
            child: Padding(
              // The reference header is edge-to-edge, so the bar itself carries
              // the inset and there is no horizontal margin here.
              padding: EdgeInsets.only(top: mediaPadding.top),
              child: ReaderTopBar(
                title: name,
                subtitle: chapterLabel,
                onBack: () => Navigator.of(context).maybePop(),
                onToggleChapters: () => showChapterDrawer(
                  context,
                  epProvider: epProvider,
                  bookmarks: state.bookmarks,
                  openPosition: state.page,
                  openTotal: state.totalPage,
                  onToggleBookmark: reader.toggleBookmark,
                  onOpenSettings: () => showReaderSettingsSheet(
                    context,
                    mangaProvider: mangaProvider,
                  ),
                ),
                onOpenSettings: () => showReaderSettingsSheet(
                  context,
                  mangaProvider: mangaProvider,
                ),
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
              child: ReaderBottomBar(
                mangaProvider: mangaProvider,
                epProvider: epProvider,
                onOpenChapters: () => showChapterDrawer(
                  context,
                  epProvider: epProvider,
                  bookmarks: state.bookmarks,
                  openPosition: state.page,
                  openTotal: state.totalPage,
                  onToggleBookmark: reader.toggleBookmark,
                  onOpenSettings: () => showReaderSettingsSheet(
                    context,
                    mangaProvider: mangaProvider,
                  ),
                ),
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
              page: state.page,
              totalPage: state.totalPage,
              progress: state.progress,
            ),
          ),
        ),
      ],
    );
  }
}
