import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/watch_result.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_content_body.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_error_state.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_state.dart';
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
    // The page is portrait-first like its loaded state: lock upright for
    // the whole session (loading included), fullscreen re-locks to the
    // landscape pair, dispose restores.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    // The chosen fallback mirror (error state's "Switch Mirror") re-keys
    // the watch family; a new episode drops the override.
    final mirrorOverride = useState<String?>(null);
    final watchedUrl = useState(url);
    if (watchedUrl.value != url) {
      watchedUrl.value = url;
      mirrorOverride.value = null;
    }
    final watchPr = watchProvider(
      url,
      widget.param.detailUrl,
      meta,
      mirrorUrl: mirrorOverride.value,
    );
    final snapshot = ref.watch(watchPr);

    return snapshot.when(
      loading: () => WatchLoadingState(
        param: widget.param,
        epProvider: epProvider,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      error: (error, trace) => WatchErrorState(
        param: widget.param,
        epProvider: epProvider,
        error: error,
        trace: trace,
        onBack: () => Navigator.of(context).maybePop(),
        onRetry: () => ref.invalidate(watchPr),
        onSelectMirror: (mirrorUrl) => mirrorOverride.value = mirrorUrl,
      ),
      data: (value) => _MobileWatchLoaded(param: widget.param, result: value),
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
                  child: WatchContentBody(param: param, epProvider: epProvider),
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
