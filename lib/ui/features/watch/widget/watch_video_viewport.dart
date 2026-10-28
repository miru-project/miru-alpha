import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/cast_sheet.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_gesture.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/mobile_landscape_controls.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/seek_bar.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/subtitle.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:video_player/video_player.dart';

/// The top video canvas of the mobile watch page: the [VideoPlayer] surface,
/// subtitle overlay, gesture layer and the auto-hiding controls overlay from
/// the reference mock (back / title / captions, seek ±10 + play cluster,
/// scrubber + timestamps + fullscreen). Reuses the fullscreen player's
/// [MobileGestureOverlay], [SeekBar], [VideoPlayerSubtitle] and
/// [SideSettingsMenu] so both layouts share one behaviour set.
class WatchVideoViewport extends ConsumerWidget {
  const WatchVideoViewport({
    super.key,
    required this.vidPr,
    required this.epProvider,
    required this.meta,
    required this.title,
    required this.episodeName,
    required this.videoType,
    required this.fullscreen,
    required this.onToggleFullscreen,
    required this.onClose,
    this.autoRotate,
    this.onToggleAutoRotate,
  });

  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  final ExtensionMeta meta;
  final String title;
  final String episodeName;
  final String videoType;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onClose;

  /// Auto-rotation state + toggle for the sensor-driven fullscreen switch.
  /// The button renders only when the page passes [onToggleAutoRotate].
  final bool? autoRotate;
  final VoidCallback? onToggleAutoRotate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControls = ref.watch(vidPr.select((s) => s.showControls));
    final showSettings = ref.watch(vidPr.select((s) => s.showSettings));
    final duration = ref.watch(vidPr.select((s) => s.duration));
    final isPlaying = ref.watch(vidPr.select((s) => s.isPlaying));

    final settingsWidth =
        // Same budget both orientations: the docked landscape panel uses the
        // portrait sheet's 72%-width, 300px-max cap.
        (MediaQuery.of(context).size.width * 0.72).clamp(0.0, 300.0);

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          // video surface
          Consumer(
            builder: (context, ref, _) {
              final ratio = ref.watch(vidPr.select((s) => s.ratio));
              return Center(
                child: AspectRatio(
                  aspectRatio: ratio == 0 ? 16 / 9 : ratio,
                  child: VideoPlayer(ref.read(vidPr.notifier).vidController),
                ),
              );
            },
          ),
          // subtitle cue
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            // Only the fullscreen player docks the settings panel; the
            // portrait page opens it as a bottom sheet (see the source
            // pill), so the cue never shifts there.
            right: showSettings && fullscreen ? settingsWidth : 0,
            top: 0,
            bottom: 0,
            child: VideoPlayerSubtitle(vidProvider: vidPr),
          ),
          // buffering hint while nothing has loaded yet
          if (duration == Duration.zero && !isPlaying)
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: FCircularProgress(),
              ),
            ),
          // gestures + auto-hiding controls
          MobileGestureOverlay(
            vidPr: vidPr,
            child: AnimatedOpacity(
              opacity: showControls ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !showControls,
                child: fullscreen && DeviceUtil.isMobileLayout(context)
                    ? MobileLandscapeControls(
                        vidPr: vidPr,
                        epProvider: epProvider,
                        title: title,
                        episodeName: episodeName,
                        videoType: videoType,
                        onToggleFullscreen: onToggleFullscreen,
                        onClose: onClose,
                        autoRotate: autoRotate,
                        onToggleAutoRotate: onToggleAutoRotate,
                      )
                    : _ControlsOverlay(
                        vidPr: vidPr,
                        epProvider: epProvider,
                        meta: meta,
                        title: title,
                        episodeName: episodeName,
                        videoType: videoType,
                        fullscreen: fullscreen,
                        onToggleFullscreen: onToggleFullscreen,
                        onClose: onClose,
                        autoRotate: autoRotate,
                        onToggleAutoRotate: onToggleAutoRotate,
                      ),
              ),
            ),
          ),
          // side settings panel — fullscreen only (the portrait page opens
          // the same content as a bottom sheet from the source pill; the
          // panel could not fit the ~230px 16:9 box).
          if (fullscreen)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: showSettings ? 0 : -settingsWidth,
              width: settingsWidth,
              child: SideSettingsMenu(
                vidPr: vidPr,
                epProvdier: epProvider,
                width: settingsWidth,
                meta: meta,
              ),
            ),
        ],
      ),
    );
  }
}

/// The mock's control rows. Text sits on the raw video canvas, so colours
/// are explicit whites on scrims rather than theme tokens.
class _ControlsOverlay extends ConsumerWidget {
  const _ControlsOverlay({
    required this.vidPr,
    required this.epProvider,
    required this.meta,
    required this.title,
    required this.episodeName,
    required this.videoType,
    required this.fullscreen,
    required this.onToggleFullscreen,
    required this.onClose,
    this.autoRotate,
    this.onToggleAutoRotate,
  });

  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  final ExtensionMeta meta;
  final String title;
  final String episodeName;
  final String videoType;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onClose;
  final bool? autoRotate;
  final VoidCallback? onToggleAutoRotate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(vidPr.select((s) => s.isPlaying));
    final position = ref.watch(vidPr.select((s) => s.position));
    final duration = ref.watch(vidPr.select((s) => s.duration));
    final locked = ref.watch(vidPr.select((s) => s.locked));
    final notifier = ref.read(vidPr.notifier);

    // Sheet tab order: [Mirrors], Resolution, Subtitle, Speed (Episodes tab
    // dropped in portrait — the base page already lists episodes); the
    // shared chips row computes the deep-link indices from baseTab 0.
    void openSettings(int tab) => showPlayerSettingsSheet(
      context,
      vidPr: vidPr,
      epProvider: epProvider,
      meta: meta,
      initialTab: tab,
      showEpisodes: false,
    );

    // While locked the whole chrome collapses to the unlock pill (the same
    // contract the landscape controls follow): the gesture layer swallows
    // playback gestures, and a tap re-shows the chrome — which is just the
    // pill — so there is always a way back.
    if (locked) {
      return _UnlockPill(onUnlock: () => notifier.setLocked(false));
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // The mid-band never reaches absolute 0 (10% floor at stop .5):
          // the disc's circle covers itself, but the video's brightest
          // frames no longer sit fully bare behind the chrome band between
          // the title and the scrubber (review round 4, critical 1).
          stops: [0, 0.18, 0.5, 0.62, 1],
          colors: [
            // Deep enough scrims keep the white chrome crisp over bright
            // keyframes (2026-10-24 UI review) without veiling the video.
            Color(0xB3000000),
            Color(0x73000000),
            Color(0x1A000000),
            Colors.transparent,
            Color(0xE6000000),
          ],
        ),
      ),
      child: SafeArea(
        top: !fullscreen,
        bottom: false,
        // The mock's condensed portrait chrome: top row + seek section =
        // ~107 fixed (the episode-pill row is gone — the header meta below
        // the canvas carries that context), and the center play disc floats
        // as a Stack layer so it can never re-introduce a Column overflow.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasH = constraints.maxHeight;
            // The play disc floats as a Stack layer, never a Column child —
            // an in-flow cluster was the RenderFlex overflow. It is plainly
            // CENTERED: with the pill row gone the chrome is symmetric
            // (top row 54 above, seek section 53 below), so the canvas
            // midpoint sits mid-band on every device. The old fixed 224px
            // threshold hid the disc on Android phones: the status-bar
            // SafeArea inset (~35px) shrinks the LayoutBuilder budget to
            // ~194px even though the canvas itself is ~229px.
            final showDisc = canvasH >= 190;
            final discSize = canvasH >= 206 ? 56.0 : 44.0;
            // StackFit.expand is load-bearing: with a plain Stack, the only
            // non-positioned child (the disc) sizes the Stack — the whole
            // chrome collapsed into a 56x84 corner once before.
            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      // top row: back · centered title stack (Now Playing / show
                      // name) · cast. The mock keeps the chrome left/right actions and
                      // pushes the title to the center, so the episode pill and the
                      // subtitle/lock chips move to the video's own overlay row.
                      Padding(
                        // The page's 16px gutter applies to the player
                        // chrome too (user directive) — the canvas itself
                        // stays full-bleed.
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            PlayerCircleButton(
                              onPress: onClose,
                              semanticLabel: 'common.back'.i18n,
                              icon: const Icon(
                                FLucideIcons.chevronLeft,
                                size: 20,
                              ),
                            ),
                            // Centered title stack: the mock's headline +
                            // second line. Expanded+Center bounds the stack
                            // to the row's free width — a plain Spacer pair
                            // laid the non-flex column out unbounded, which
                            // let the subtitle line stretch and push the
                            // cast button off-screen on wide windows.
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'watch.now_playing'.i18n,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Auto-rotation toggle: arms/disarms the
                            // sensor-driven fullscreen switch (refresh-cw-off
                            // <-> refresh-cw morph, default off).
                            if (onToggleAutoRotate != null)
                              PlayerAutoRotateButton(
                                enabled: autoRotate ?? false,
                                onPress: onToggleAutoRotate!,
                              ),
                            // Cast affordance: opens the DLNA renderer
                            // picker (SSDP search on the local network,
                            // dlna_dart). The portrait mock's trailing
                            // action.
                            PlayerCircleButton(
                              small: true,
                              onPress: () => showDlnaCastSheet(
                                context,
                                vidPr: vidPr,
                                title: title,
                              ),
                              semanticLabel: 'watch.cast'.i18n,
                              icon: const Icon(FLucideIcons.cast, size: 18),
                            ),
                          ],
                        ),
                      ),
                      // The mock's portrait canvas is deliberately spare:
                      // top bar, center disc, bottom scrubber. The group
                      // and mirror chips ride the scrubber row (selection
                      // without leaving the player); subtitle/quality
                      // chips appear when the stream carries them.
                      const Spacer(),
                      Padding(
                        // 16px gutter on the scrubber too: the slider
                        // expands to the page's content width.
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Column(
                          children: [
                            // 16px box: the slider centers inside it, so
                            // the slim line sits ~13px above the meta row
                            // (the mock's tight stack) instead of the
                            // Slider's intrinsic ~48px padding pushing a
                            // large gap. The box keeps the touch area tall
                            // enough to grab the line.
                            SizedBox(height: 16, child: SeekBar(vidPr: vidPr)),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Text(
                                  '${_fmt(position)} / ${_fmt(duration)}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(230),
                                    fontSize: 11,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // The mock's meta row: mirror · subtitle ·
                                // quality · speed chips (shared atom with the
                                // landscape dock), each deep-linking into the
                                // settings sheet, then the fullscreen toggle.
                                PlayerSettingsChips(
                                  vidPr: vidPr,
                                  baseTab: 0,
                                  onOpenTab: openSettings,
                                ),
                                const SizedBox(width: 6),
                                // The mock's meta row is text-height (its
                                // fullscreen affordance is a plain 24px
                                // icon) — a 28px ghost hit-box keeps the row
                                // tight so the slider line sits close above.
                                // The default 10px icon-content inset is
                                // zeroed: with the box constrained to 28px
                                // it shoved the glyph below the row's
                                // centerline (misaligned with the time and
                                // speed chip).
                                FButton.icon(
                                  variant: .ghost,
                                  onPress: onToggleFullscreen,
                                  style: .delta(
                                    iconContentStyle: .delta(
                                      padding: EdgeInsetsGeometryDelta.value(
                                        EdgeInsets.zero,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 28,
                                        minHeight: 28,
                                      ),
                                    ),
                                  ),
                                  child: Semantics(
                                    label: fullscreen
                                        ? 'watch.exit_fullscreen'.i18n
                                        : 'watch.fullscreen'.i18n,
                                    button: true,
                                    child: Icon(
                                      fullscreen
                                          ? FLucideIcons.minimize
                                          : FLucideIcons.maximize,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // The floating center play button: a Stack layer above the
                // chrome column, plainly centered — with the pill row gone
                // the chrome is symmetric (top row 54 / seek section 53), so
                // the canvas midpoint clears both bars on every device
                // (worst case H=194: 25px to the title, 16px to the seek).
                if (showDisc)
                  Align(
                    child: PlayerPlayPauseDisc(
                      isPlaying: isPlaying,
                      onPress: notifier.playOrPause,
                      box: discSize,
                      iconSize: discSize * 0.46,
                    ),
                  ),
              ],
            );
          },
        ),
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

/// The mock's glass episode pill: emerald dot + "Ep N · name" on a dark
/// chip, sitting under the title in the top row.

/// The mock's quick subtitle chip: shows the current track's language and
/// toggles subtitle rendering on the canvas. Hidden entirely when the
/// stream carries no subtitle tracks — a control with nothing to control
/// is dead chrome.

/// Shown instead of the whole chrome while the surface is locked — one
/// tap re-enables every control.
class _UnlockPill extends StatelessWidget {
  const _UnlockPill({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FButton(
        variant: .outline,
        mainAxisSize: .min,
        prefix: const Icon(FLucideIcons.lockOpen, size: 14),
        onPress: onUnlock,
        child: Text('watch.unlock_screen'.i18n),
      ),
    );
  }
}
