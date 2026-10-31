import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/cast_sheet.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/seek_bar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Landscape (fullscreen) mobile controls: the portrait chrome, widened.
/// Same visual language as the portrait viewport — "Now Playing" header
/// stack, dark-glass play/pause disc, meta chips row — laid out for the
/// wide canvas: header · prev/next episode skip buttons around the disc ·
/// scrubber + meta chips · transport dock. Mounted by [WatchVideoViewport]
/// when the viewport is fullscreen on the mobile layout; the portrait
/// viewport keeps its stacked overlay. While locked the whole chrome
/// collapses to the unlock pill.
class MobileLandscapeControls extends ConsumerWidget {
  const MobileLandscapeControls({
    super.key,
    required this.vidPr,
    required this.epProvider,
    required this.title,
    required this.episodeName,
    required this.videoType,
    required this.onToggleFullscreen,
    required this.onClose,
    this.autoRotate,
    this.onToggleAutoRotate,
  });

  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  final String title;
  final String episodeName;
  final String videoType;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onClose;

  /// Auto-rotation state + toggle (default off) for the header — the same
  /// arming switch the portrait overlay carries.
  final bool? autoRotate;
  final VoidCallback? onToggleAutoRotate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(vidPr.select((s) => s.locked));
    if (locked) return _UnlockPill(vidPr: vidPr);

    // Watched, not read: the dock must rebuild when the episode changes.
    final epState = ref.watch(epProvider);
    final group = epState.epGroup.elementAtOrNull(epState.selectedGroupIndex);
    final epLength = group?.urls.length ?? 0;
    final epIndex = epState.selectedEpisodeIndex;
    final epGroupIndex = epState.selectedGroupIndex;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Landscape-only, stronger than the portrait scrim (reference
          // mock + contrast review): 90%→50% header band for crisp text
          // over bright scenes, 95% dock band.
          stops: [0, 0.22, 0.5, 0.62, 1],
          colors: [
            Color(0xE6000000),
            Color(0x80000000),
            Color(0x1A000000),
            Colors.transparent,
            Color(0xF2000000),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _HeaderRow(
              vidPr: vidPr,
              title: title,
              episodeName: episodeName,
              videoType: videoType,
              onClose: onClose,
              autoRotate: autoRotate,
              onToggleAutoRotate: onToggleAutoRotate,
            ),
            const Spacer(),
            _TransportCluster(
              vidPr: vidPr,
              onPrev: epIndex > 0
                  ? () => ref
                        .read(epProvider.notifier)
                        .selectEpisode(epGroupIndex, epIndex - 1)
                  : null,
              onNext: epIndex < epLength - 1
                  ? () => ref
                        .read(epProvider.notifier)
                        .selectEpisode(epGroupIndex, epIndex + 1)
                  : null,
            ),
            const Spacer(),
            _BottomDock(
              vidPr: vidPr,
              epCount: epLength,
              onToggleFullscreen: onToggleFullscreen,
            ),
          ],
        ),
      ),
    );
  }
}

/// Top row: back · left-anchored title block · auto-rotate · cast.
/// (The lock lives on the portrait overlay only; the Episodes pane entry
/// moved down into the transport dock.)
class _HeaderRow extends ConsumerWidget {
  const _HeaderRow({
    required this.vidPr,
    required this.title,
    required this.episodeName,
    required this.videoType,
    required this.onClose,
    this.autoRotate,
    this.onToggleAutoRotate,
  });

  final VideoPlayerNotifierProvider vidPr;
  final String title;
  final String episodeName;
  final String videoType;
  final VoidCallback onClose;

  /// Auto-rotation state + toggle (default off): the same arming switch the
  /// portrait overlay carries.
  final bool? autoRotate;
  final VoidCallback? onToggleAutoRotate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 0),
      child: Row(
        children: [
          PlayerCircleButton(
            onPress: onClose,
            semanticLabel: 'common.back'.i18n,
            icon: const Icon(FLucideIcons.chevronLeft, size: 20),
          ),
          const SizedBox(width: 10),
          // Left-anchored title block (reference mock): headline over the
          // title · episode · type line; the utility cluster trails right —
          // related controls grouped, nothing scattered across the periphery
          // (top-controls review, Medium 1).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'watch.now_playing'.i18n,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (episodeName.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          episodeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (videoType.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      PlayerTypeBadge(videoType: videoType),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Auto-rotation toggle (default off): arms/disarms the sensor-driven
          // fullscreen switch — the lock button retired from this header. The
          // full 44px circle (not the portrait cluster's small variant) keeps
          // this header's touch-target rhythm.
          if (onToggleAutoRotate != null)
            PlayerAutoRotateButton(
              enabled: autoRotate ?? false,
              onPress: onToggleAutoRotate!,
              small: false,
            ),
          const SizedBox(width: 2),
          PlayerCircleButton(
            small: true,
            onPress: () =>
                showDlnaCastSheet(context, vidPr: vidPr, title: title),
            semanticLabel: 'watch.cast'.i18n,
            icon: const Icon(FLucideIcons.cast, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Center: previous episode · dark-glass play/pause disc · next episode.
/// The ±10 seek buttons retired — double-tap gestures own seeking — and
/// episode nav moved here with the animate-ui skip jog (the skip buttons'
/// triangle x-jogs on press). The portrait disc (MorphIcon morph, hairline
/// border), sized fullscreen. A null callback disables the side (muted, no
/// jog) at the episode list's ends.
class _TransportCluster extends StatelessWidget {
  const _TransportCluster({
    required this.vidPr,
    required this.onPrev,
    required this.onNext,
  });

  final VideoPlayerNotifierProvider vidPr;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isPlaying = ref.watch(vidPr.select((s) => s.isPlaying));
        final notifier = ref.read(vidPr.notifier);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerSkipButton(
              key: const ValueKey('skip-prev'),
              onPress: onPrev,
              forward: false,
              semanticLabel: 'watch.prev_episode'.i18n,
              size: 16,
            ),
            const SizedBox(width: 24),
            PlayerPlayPauseDisc(
              isPlaying: isPlaying,
              onPress: notifier.playOrPause,
              box: 64,
              iconSize: 30,
            ),
            const SizedBox(width: 24),
            PlayerSkipButton(
              key: const ValueKey('skip-next'),
              onPress: onNext,
              forward: true,
              semanticLabel: 'watch.next_episode'.i18n,
              size: 16,
            ),
          ],
        );
      },
    );
  }
}

/// Bottom: scrubber + timestamps + meta chips, then the transport dock.
/// Episode prev/next live in the center cluster now — the dock keeps play,
/// the Episodes pane entry right beside it, the settings chips and exit
/// fullscreen.
class _BottomDock extends ConsumerWidget {
  const _BottomDock({
    required this.vidPr,
    required this.epCount,
    required this.onToggleFullscreen,
  });

  final VideoPlayerNotifierProvider vidPr;
  final int epCount;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(vidPr.select((s) => s.position));
    final duration = ref.watch(vidPr.select((s) => s.duration));
    final notifier = ref.read(vidPr.notifier);

    return Padding(
      // 10px bottom + the 12px row gap keep the dock ≥12px clear of the
      // scrubber band (touch-spacing review, Medium 2).
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Column(
        children: [
          // Scrubber row — timestamps FLANK the track (reference mock).
          Row(
            children: [
              Text(
                _fmt(position),
                style: TextStyle(
                  color: Colors.white.withAlpha(230),
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: SeekBar(vidPr: vidPr)),
              const SizedBox(width: 8),
              Text(
                _fmt(duration),
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PlayerCircleButton(
                onPress: notifier.playOrPause,
                semanticLabel: 'media.video_player.play'.i18n,
                small: true,
                icon: Icon(
                  ref.watch(vidPr.select((s) => s.isPlaying))
                      ? FLucideIcons.pause
                      : FLucideIcons.play,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              // The reference's drawer toggle, docked next to play/pause:
              // opens the docked panel (episodes · mirrors · resolution ·
              // subtitle) with Episodes as its first pane.
              _EpisodesButton(
                onPress: () => notifier.openSettings(0),
                count: epCount,
              ),
              const Spacer(),
              // Reference bottom-right cluster: mirror · subtitle · quality
              // (resolution) · speed indicators, deep-linking into the
              // docked panel (baseTab 1 — Episodes stays its first pane),
              // then exit fullscreen.
              PlayerSettingsChips(
                vidPr: vidPr,
                baseTab: 1,
                onOpenTab: notifier.openSettings,
              ),
              const SizedBox(width: 6),
              PlayerCircleButton(
                onPress: onToggleFullscreen,
                semanticLabel: 'watch.exit_fullscreen'.i18n,
                small: true,
                icon: const Icon(FLucideIcons.minimize, size: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }
}

/// Opens the side settings menu (episodes / mirror / resolution / subtitles).
class _EpisodesButton extends StatelessWidget {
  const _EpisodesButton({required this.onPress, required this.count});

  final VoidCallback onPress;
  final int count;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: .ghost,
      size: .xs,
      style: .delta(
        decoration: .delta([
          .base(
            .boxDelta(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          .match(
            {.hovered, .pressed},
            .boxDelta(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ]),
      ),
      onPress: onPress,
      prefix: IconTheme.merge(
        data: const IconThemeData(color: Colors.white),
        child: const Icon(FLucideIcons.listVideo, size: 14),
      ),
      suffix: FBadge(
        variant: .secondary,
        style: .delta(
          labelTextStyle: TextStyleDelta.delta(
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          ),
        ),
        child: Text('$count'),
      ),
      child: Text(
        'media.episodes'.i18n,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Shown instead of the whole chrome while the surface is locked.
class _UnlockPill extends ConsumerWidget {
  const _UnlockPill({required this.vidPr});

  final VideoPlayerNotifierProvider vidPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: MiruCard(
        style: .delta(
          decoration: .boxDelta(
            color: Colors.black.withAlpha(120),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Blur(
          borderRadius: BorderRadius.circular(999),
          child: FButton(
            variant: .ghost,
            size: .sm,
            style: .delta(
              decoration: .delta([
                .base(
                  .boxDelta(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                .match(
                  {.hovered, .pressed},
                  .boxDelta(
                    color: Colors.white.withAlpha(35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ]),
            ),
            onPress: () => ref.read(vidPr.notifier).setLocked(false),
            prefix: const Icon(FLucideIcons.lockOpen, size: 14),
            child: Text(
              'watch.unlock_screen'.i18n,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
