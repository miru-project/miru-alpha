import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/watch_result.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/ui/core/error.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_metadata_card.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_header_section.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_tracker_bar.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_video_viewport.dart';
import 'package:miru_alpha/ui/features/watch/watch_data.dart' as watch_data;
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/episode_label.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/system_ui.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/watch/device_orientation.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:wakelock_plus/wakelock_plus.dart';

/// Portrait mobile watch page for bangumi content: a 16:9 video viewport on
/// top and the detail-page's content language below it — specs pills, prev /
/// next episode, tracker status, the episode list ([MobileDetailTile]) and
/// the metadata card. The desktop / reader paths keep using [WatchLoadEntry].
class MobileWatchPage extends StatefulHookConsumerWidget {
  const MobileWatchPage({super.key, required this.param});

  final WatchParams param;

  @override
  ConsumerState<MobileWatchPage> createState() => _MobileWatchPageState();
}

class _MobileWatchPageState extends ConsumerState<MobileWatchPage> {
  late final EpisodeNotifierProvider epProvider;

  @override
  void initState() {
    super.initState();
    epProvider = episodeProvider(widget.param);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    AppSystemUi.surfaceOwned = false;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Restore the app-wide mode: status bar hidden, bottom bar kept
    // (mirrors app_bootstrap.dart so the bar never reappears elsewhere).
    AppSystemUi.restore();
    // The DLNA cast experience is scoped to this watch session: source
    // switches (episode, quality, mirror) never touch it, but leaving the
    // page drops the renderer session and the discovered list.
    ref.read(dlnaCastProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epNotifier = ref.watch(epProvider);
    if (epNotifier.epGroup.isEmpty) {
      return FScaffold(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('media.no_episodes_found'.i18n),
              const SizedBox(height: 12),
              FButton(
                variant: .outline,
                onPress: () => Navigator.of(context).maybePop(),
                child: Text('common.back'.i18n),
              ),
            ],
          ),
        ),
      );
    }

    final url = epNotifier
        .epGroup[epNotifier.selectedGroupIndex]
        .urls[epNotifier.selectedEpisodeIndex]
        .url;
    final meta = widget.param.meta;
    final snapshot = ref.watch(
      watchProvider(url, widget.param.detailUrl, meta),
    );

    return snapshot.when(
      loading: () => _WatchLoadingShell(param: widget.param),
      error: (error, trace) => FScaffold(
        child: Center(
          child: ErrorDisplay.grpc(
            err: error,
            stack: trace,
            prefix: FButton(
              variant: .ghost,
              prefix: const Icon(FLucideIcons.undo2),
              onPress: () => Navigator.of(context).maybePop(),
              child: Text('common.return_text'.i18n),
            ),
          ),
        ),
      ),
      data: (value) => _MobileWatchLoaded(param: widget.param, result: value),
    );
  }
}

/// Black 16:9 placeholder while the watch request resolves; keeps the back
/// affordance so a hung fetch is always dismissible.
class _WatchLoadingShell extends StatelessWidget {
  const _WatchLoadingShell({required this.param});

  final WatchParams param;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: width,
          height: width * 9 / 16,
          color: Colors.black,
          child: Stack(
            children: [
              const Center(child: FCircularProgress()),
              Positioned(
                top: MediaQuery.of(context).padding.top + 4,
                left: 10,
                child: FButton.icon(
                  variant: .ghost,
                  onPress: () => Navigator.of(context).maybePop(),
                  style: .delta(
                    decoration: .delta([
                      .base(
                        .boxDelta(
                          color: Colors.black.withAlpha(90),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ]),
                    iconContentStyle: .delta(
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                  child: const Icon(
                    FLucideIcons.chevronLeft,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileWatchLoaded extends HookConsumerWidget {
  const _MobileWatchLoaded({required this.param, required this.result});

  final WatchParams param;
  final WatchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = param.meta;
    final epProvider = episodeProvider(param);
    final isDownload = result.data is proto.Download;
    final downloadData = isDownload ? result.data as proto.Download : null;
    final bangumi = isDownload
        ? null
        : watch_data.toBangumiWatch(
            watch_data.unwrapAll(result.data, param.type),
          );

    final vidProvider = videoPlayerProvider(
      bangumi?.url,
      subtitlesRaw: bangumi?.subtitles,
      headers: bangumi?.headers,
      torrent: bangumi?.torrent,
      localPath: downloadData?.savePath,
      v2watch: result.v2watch,
    );

    final fullscreen = useState(false);
    final hasEnteredFullscreen = useState(false);
    // Auto-rotation is OFF by default: the sensor-driven fullscreen switch
    // only arms when the user turns the viewport's refresh toggle on.
    final autoRotate = useState(false);

    // Fullscreen mode: landscape + immersive chrome; the viewport then owns
    // the whole screen and the content below is dropped from the tree.
    useEffect(() {
      if (fullscreen.value) {
        hasEnteredFullscreen.value = true;
        // Fullscreen owns the system-UI mode: the app-wide auto-rehide
        // (app_bootstrap didChangeMetrics) must stand down while the
        // immersiveSticky bars are wanted.
        AppSystemUi.surfaceOwned = true;
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        if (hasEnteredFullscreen.value) {
          AppSystemUi.surfaceOwned = false;
          // Same app-wide mode as app_bootstrap.dart: status bar hidden,
          // bottom bar kept.
          AppSystemUi.restore();
        }
        // Portrait state locks the window upright: the sensor below drives
        // the fullscreen switch, so the page never renders its content
        // Column sideways during the rotation gesture.
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
      return null;
    }, [fullscreen.value]);

    // Rotating the device switches fullscreen by itself — but only while
    // the user's auto-rotation toggle (viewport chrome, default off) has
    // armed the sensor. Sensor-based (see listenDeviceOrientation): the
    // fullscreen window lock stops window-rotation events, so
    // MediaQuery.orientation cannot drive the switch back.
    useEffect(() {
      if (!DeviceUtil.isMobile) return null;
      if (!autoRotate.value) return null;
      final sub = listenDeviceOrientation((landscape) {
        if (fullscreen.value != landscape) {
          fullscreen.value = landscape;
        }
      });
      return () => sub.cancel();
    }, [autoRotate.value]);

    // Desktop windows have no orientation sensor: the window shape IS the
    // orientation. Mirror it so a landscape window gets the fullscreen-style
    // landscape layout (video fills the window, docked panel) instead of the
    // portrait content column — the same switch the sensor drives on mobile.
    final landscapeNow =
        MediaQuery.widthOf(context) > MediaQuery.heightOf(context);
    useEffect(() {
      if (DeviceUtil.isMobile) return null;
      if (fullscreen.value != landscapeNow) {
        fullscreen.value = landscapeNow;
      }
      return null;
    }, [landscapeNow]);

    final videoType = (bangumi?.type ?? '').toUpperCase();
    final epState = ref.watch(epProvider);

    return ColoredBox(
      color: context.theme.colors.background,
      child: fullscreen.value
          ? WatchVideoViewport(
              vidPr: vidProvider,
              epProvider: epProvider,
              meta: meta,
              title: param.name,
              episodeName: _episodeLabel(epState),
              videoType: videoType,
              fullscreen: true,
              onToggleFullscreen: () => fullscreen.value = false,
              onClose: () => _close(context, ref, vidProvider),
              autoRotate: autoRotate.value,
              onToggleAutoRotate: () => autoRotate.value = !autoRotate.value,
            )
          : Column(
              children: [
                // No page app bar: the reference mock keeps all chrome inside
                // the video canvas — the viewport's own top row (back ·
                // "Now Playing" + show name · cast) IS the header. A page bar
                // above it duplicated the title stack.
                // 16:9 canvas — but in a landscape window (wide + short) the
                // pure width ratio is TALLER than the window, pushing the
                // whole body off-screen. Cap at 72% of the window height;
                // the inner AspectRatio letterboxes the video.
                SizedBox(
                  width: MediaQuery.widthOf(context),
                  height: min(
                    MediaQuery.widthOf(context) * 9 / 16,
                    MediaQuery.heightOf(context) * 0.72,
                  ),
                  child: WatchVideoViewport(
                    vidPr: vidProvider,
                    epProvider: epProvider,
                    meta: meta,
                    title: param.name,
                    episodeName: _episodeLabel(epState),
                    videoType: videoType,
                    fullscreen: false,
                    onToggleFullscreen: () => fullscreen.value = true,
                    onClose: () => _close(context, ref, vidProvider),
                    autoRotate: autoRotate.value,
                    onToggleAutoRotate: () =>
                        autoRotate.value = !autoRotate.value,
                  ),
                ),
                Expanded(
                  child: _WatchBody(
                    param: param,
                    vidPr: vidProvider,
                    epProvider: epProvider,
                  ),
                ),
              ],
            ),
    );
  }

  /// "Ep N · name" style second line for the viewport header. Bare backend
  /// names ("0", "") drop the "· name" half — the same rule the episode
  /// tiles follow ([isBareEpisodeName]), so the pill never reads "Ep 1 · 0"
  /// next to a tile that says "Episode 1".
  String _episodeLabel(EpisodeNotifierState ep) {
    final group = ep.epGroup.elementAtOrNull(ep.selectedGroupIndex);
    final episode = group?.urls.elementAtOrNull(ep.selectedEpisodeIndex);
    if (episode == null) return '';
    final n = ep.selectedEpisodeIndex + 1;
    final name = stripEpisodePrefix(episode.name);
    return isBareEpisodeName(episode.name) ? 'Ep $n' : 'Ep $n · $name';
  }

  /// Saves playback progress into history before leaving, mirroring the
  /// fullscreen player's close path.
  void _close(
    BuildContext context,
    WidgetRef ref,
    VideoPlayerNotifierProvider vidPr,
  ) {
    final playback = ref.read(vidPr);
    ref
        .read(episodeProvider(param).notifier)
        .saveHistory(
          progress: playback.position.inSeconds,
          totalProgress: playback.duration.inSeconds,
        );
    Navigator.of(context).maybePop();
  }
}

/// The scrollable content under the viewport, in the detail page's section
/// language: specs strip → tracker bar → episode list → metadata card.
class _WatchBody extends ConsumerWidget {
  const _WatchBody({
    required this.param,
    required this.vidPr,
    required this.epProvider,
  });

  final WatchParams param;
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = param.meta;
    final detailPr = param.detailPr;
    final detailState = detailPr == null ? null : ref.watch(detailPr);
    final detail = _resolveDetail(detailState);

    final histories = ref
        .watch(historyPageProvider)
        .history
        .where(
          (h) =>
              h.package == meta.packageName && h.detailUrl == param.detailUrl,
        )
        .toList();

    final ep = ref.watch(epProvider);
    final groupIndex = ep.selectedGroupIndex;
    final group = ep.epGroup.elementAtOrNull(groupIndex);
    final episodes = group?.urls ?? <ExtensionEpisode>[];
    final trackers =
        detailState?.detailInfo?.trackers ?? const <proto.Tracker>[];
    final linked = trackers.where((t) => t.trackerId.isNotEmpty).length;
    final episodesTotal = group?.urls.length;
    final episodesCurrent = ep.selectedEpisodeIndex + 1;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // The mock's streamlined header: show title + "S{n} · Ep n"
            // meta, bookmark/share, and the "Up Next" quick trigger.
            WatchHeaderSection(
              showTitle: param.name,
              groupTitle: group?.title ?? '',
              episodeIndex: ep.selectedEpisodeIndex,
              episodeName:
                  episodes.elementAtOrNull(ep.selectedEpisodeIndex)?.name ?? '',
              detail: detail,
              meta: meta,
              detailUrl: param.detailUrl,
              epProvider: epProvider,
              favorited: detailState?.favorite != null,
            ),
            const SizedBox(height: 16),
            // The mock's tabbed episode architecture: the list stays here,
            // the description/tracking metadata moves into the Overview
            // pane instead of trailing the list.
            FTabs(
              expands: false,
              children: [
                FTabEntry(
                  label: Text('${'media.episodes'.i18n} (${episodes.length})'),
                  child: EpisodeList(
                    param: param,
                    detail: detail,
                    epProvider: epProvider,
                    histories: histories,
                    groupIndex: groupIndex,
                    episodes: episodes,
                    favorited: detailState?.favorite != null,
                  ),
                ),
                FTabEntry(
                  label: Text('media.overview'.i18n),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // The sync strip lives in the Overview pane now — it
                      // is metadata, not playback chrome.
                      if (linked > 0)
                        WatchTrackerBar(
                          trackers: trackers,
                          episodeNumber: episodesTotal == null
                              ? null
                              : episodesCurrent,
                          episodeCount: episodesTotal,
                        ),
                      WatchMetadataCard(detail: detail),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// The detail page's [Detail]; falls back to a shell built from the watch
  /// params when the watch flow was entered without a detail provider
  /// (e.g. continue-watching deep link) so episode rows still compute their
  /// download keys.
  Detail _resolveDetail(DetialState? state) {
    final info = state?.detailInfo;
    if (info != null) return MiruCoreEndpoint.detailFromProto(info);
    return Detail(
      title: param.name,
      cover: param.detailImageUrl.isEmpty ? null : param.detailImageUrl,
      episodes: param.epGroup,
      detailUrl: param.detailUrl,
      package: param.meta.packageName,
    );
  }
}

class EpisodeList extends HookConsumerWidget {
  const EpisodeList({
    super.key,
    required this.param,
    required this.detail,
    required this.epProvider,
    required this.histories,
    required this.groupIndex,
    required this.episodes,
    required this.favorited,
  });

  final WatchParams param;
  final Detail detail;
  final EpisodeNotifierProvider epProvider;
  final List<History> histories;
  final int groupIndex;
  final List<ExtensionEpisode> episodes;
  final bool favorited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReverse = useState(false);
    final groupPopover = useFPopoverController();
    final epNotifier = ref.read(epProvider.notifier);
    final selectedIndex = ref.watch(
      epProvider.select((s) => s.selectedEpisodeIndex),
    );
    final groups = ref.watch(epProvider.select((s) => s.epGroup));

    // Browse state: the group whose episodes the list shows. Picking another
    // group in the selector re-lists that group WITHOUT switching the player
    // — nothing in it is playing yet, so no row carries the selection mark.
    // The player only moves when an episode row is tapped. The list starts
    // on (and follows) the playing group.
    final displayedGroup = useState(groupIndex);
    useEffect(() {
      displayedGroup.value = groupIndex;
      return null;
    }, [groupIndex]);
    final displayedEpisodes =
        groups.elementAtOrNull(displayedGroup.value)?.urls ?? episodes;
    // Same completed-download lookup the detail list uses, so a "Saved"
    // mark never disagrees between the two surfaces.
    final downloadedUrls = ref.watch(
      downloadProvider.select(
        (s) => (s.value?.history ?? const [])
            .where((d) => d.status == proto.DownloadStatus.COMPLETED)
            .map((d) => d.url)
            .toList(),
      ),
    );

    final order = List<int>.generate(displayedEpisodes.length, (i) => i);
    if (isReverse.value) {
      order.sort((a, b) => b.compareTo(a));
    }

    // The detail page's silverlist shape: ONE grouped forui list — rows
    // share the group card and its full dividers. The label row carries the
    // list's own heading ("Episodes (n)") LEFT and its controls (group
    // selector, order) RIGHT on one line: the user wants the count label
    // kept, and sharing the row with the controls satisfies the review's
    // proximity point instead of stacking a second filter band.
    return FTileGroup.builder(
      physics: const NeverScrollableScrollPhysics(),
      divider: .full,
      label: Row(
        children: [
          Text(
            'media.episodes'.i18n,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(${displayedEpisodes.length})',
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const Spacer(),
          // Bookmark/share live in the page header now; the list header
          // keeps only the list's own controls (group selector, order).
          if (groups.length > 1) ...[
            // 10px gaps; the controls match the detail header's floor (36px)
            // so the two surfaces' dropdowns read as one family — the user
            // flagged the watch header's taller 44px buttons as inconsistent.
            const SizedBox(width: 10),
            // Group switcher, the detail header's selector: a popover of
            // the episode groups. Picking one only re-lists that group's
            // episodes (browse); the player switches when an episode row
            // is tapped — never on the group pick itself.
            FPopoverMenu.tiles(
              menuAnchor: .topCenter,
              menu: [
                .group(
                  children: [
                    for (var g = 0; g < groups.length; g++)
                      FTile(
                        selected: g == displayedGroup.value,
                        onPress: () {
                          displayedGroup.value = g;
                          groupPopover.toggle();
                        },
                        title: Text(groups[g].title),
                      ),
                  ],
                ),
              ],
              control: .managed(controller: groupPopover),
              child: FButton(
                variant: .outline,
                size: .xs,
                style: .delta(
                  contentStyle: .delta(
                    constraints: const BoxConstraints(minHeight: 36),
                  ),
                ),
                onPress: groupPopover.toggle,
                suffix: Icon(
                  FLucideIcons.chevronDown,
                  size: 14,
                  color: context.theme.colors.mutedForeground,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    groups.elementAtOrNull(displayedGroup.value)?.title ??
                        'media.no_episodes'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 10),
          FButton.icon(
            variant: .outline,
            size: .xs,
            style: .delta(
              iconContentStyle: .delta(
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
            onPress: () => isReverse.value = !isReverse.value,
            child: isReverse.value
                ? const Icon(FLucideIcons.arrowUp10)
                : const Icon(FLucideIcons.arrowDown01),
          ),
        ],
      ),
      tileBuilder: (context, idx) {
        final realIndex = order[idx];
        // The selection mark only exists in the group that is actually
        // playing — a browsed-but-not-playing group shows plain rows.
        final isPlayingGroup = displayedGroup.value == groupIndex;
        return MobileDetailTile(
          key: ValueKey('watch-ep-${displayedGroup.value}-$realIndex'),
          item: displayedEpisodes[realIndex],
          idx: realIndex,
          position: realIndex + 1,
          selectedGpIndex: displayedGroup.value,
          detail: detail,
          meta: param.meta,
          detailUrl: param.detailUrl,
          detailPr: param.detailPr,
          history: histories.firstWhereOrNull(
            (h) => h.url == displayedEpisodes[realIndex].url,
          ),
          isDownloaded: downloadedUrls.any(
            (urls) => urls.contains(displayedEpisodes[realIndex].url),
          ),
          selected: isPlayingGroup && realIndex == selectedIndex,
          onPress: () =>
              epNotifier.selectEpisode(displayedGroup.value, realIndex),
        );
      },
      count: order.length,
    );
  }
}
