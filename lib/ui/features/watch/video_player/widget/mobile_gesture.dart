import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:fvp/fvp.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/ui/core/core/outline_text.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:volume_controller/volume_controller.dart';

class MobileGestureOverlay extends HookConsumerWidget {
  const MobileGestureOverlay({
    super.key,
    required this.vidPr,
    required this.child,
  });

  final VideoPlayerNotifierProvider vidPr;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVolume = useState(0.0);
    // fvp brightness is a video-effect offset: 0 = default, -1..1 range.
    // It only shades the video surface, never the system.
    final currentBrightness = useState(0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VolumeController.instance.getVolume().then((value) {
        currentVolume.value = value;
      });
    });
    final isSeeking = useState(false);
    final isBrightness = useState(false);
    final isVolume = useState(false);

    final dragDuration = useState(Duration.zero);
    final dragPosition = useState(Duration.zero);
    // The double-tap seek feedback: (direction, stamp) — the stamp keys the
    // [PlayerSeekBurst] so every double-tap replays the animation even in
    // the same direction.
    final seekBurst = useState<({bool forward, int stamp})?>(null);
    final c = ref.read(vidPr.notifier);
    final duration = ref.watch(vidPr.select((s) => s.duration));
    final position = ref.watch(vidPr.select((s) => s.position));

    // A quality / mirror switch builds a fresh player starting at the mdk
    // default (0). Re-apply the tracked offset once the new stream reports a
    // duration, so the picture keeps the shade the user last set.
    useEffect(() {
      if (duration <= Duration.zero) return null;
      ref
          .read(vidPr.notifier)
          .videoPlayerController
          .setBrightness(currentBrightness.value);
      return null;
    }, [vidPr, duration]);
    return Stack(
      children: [
        if (isSeeking.value)
          OutlineText(
            text:
                '${dragDuration.value.inMinutes}:${(dragDuration.value.inSeconds % 60).toString().padLeft(2, '0')} / ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
            color: context.theme.colors.foreground,
            fontSize: 40,
            fontWeight: .bold,
            strokeWidth: 2,
            outlineColor: context.theme.colors.background,
          ),
        if (isBrightness.value)
          OutlineText(
            text: '${(currentBrightness.value * 100).round()}%',
            color: context.theme.colors.foreground,
            fontSize: 40,
            fontWeight: .bold,
            strokeWidth: 2,
            outlineColor: context.theme.colors.background,
          ),
        if (isVolume.value)
          OutlineText(
            text: '${(currentVolume.value * 100).round()}%',
            color: context.theme.colors.foreground,
            fontSize: 40,
            fontWeight: .bold,
            strokeWidth: 2,
            outlineColor: context.theme.colors.background,
          ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final isshowControll = ref.read(
              vidPr.select((s) => s.showControls),
            );
            if (isshowControll) {
              ref.read(vidPr.notifier).setShowControls(false);
              return;
            }
            ref.read(vidPr.notifier).setShowControls(true);
          },
          onDoubleTapDown: (details) {
            // A locked surface swallows playback gestures (tap only toggles
            // the chrome, which renders just the unlock pill while locked).
            if (ref.read(vidPr).locked) return;
            // 如果左边点击快退，中间暂停，右边快进 — with the animated
            // fast-forward glyph + skipped time bursting at the tapped side.
            final dx = details.localPosition.dx;
            final width = MediaQuery.of(context).size.width / 3;
            if (dx < width) {
              c.seek(position - const Duration(seconds: 10));
              seekBurst.value = (
                forward: false,
                stamp: DateTime.now().microsecondsSinceEpoch,
              );
            } else if (dx > width * 2) {
              c.seek(position + const Duration(seconds: 10));
              seekBurst.value = (
                forward: true,
                stamp: DateTime.now().microsecondsSinceEpoch,
              );
            } else {
              c.playOrPause();
            }
          },
          onVerticalDragStart: (details) {
            if (ref.read(vidPr).locked) return;
            isBrightness.value =
                details.localPosition.dx <
                MediaQuery.of(context).size.width / 5;
            isVolume.value =
                details.localPosition.dx >
                MediaQuery.of(context).size.width * 4 / 5;
          },
          // 左右两边上下滑动
          onVerticalDragUpdate: (details) {
            final add = details.delta.dy / 500;
            // 如果是左边调节亮度 — fvp video-effect offset, -1..1
            if (isBrightness.value) {
              currentBrightness.value = (currentBrightness.value - add).clamp(
                -1,
                1,
              );
              ref
                  .read(vidPr.notifier)
                  .videoPlayerController
                  .setBrightness(currentBrightness.value);
              return;
            }
            // 如果是右边调节音量
            if (isVolume.value) {
              currentVolume.value = (currentVolume.value - add).clamp(0, 1);
              VolumeController.instance.setVolume(currentVolume.value);
              return;
            }
          },
          onHorizontalDragStart: (details) {
            if (ref.read(vidPr).locked) return;
            dragPosition.value = position;
          },
          onVerticalDragEnd: (details) {
            isBrightness.value = false;
            isVolume.value = false;
          },
          // 左右滑动
          onHorizontalDragUpdate: (details) {
            final duration = ref.read(vidPr.select((s) => s.duration));
            double scale = 200000 / MediaQuery.of(context).size.width;
            Duration pos =
                dragPosition.value +
                Duration(milliseconds: (details.delta.dx * scale).round());
            dragPosition.value = Duration(
              milliseconds: pos.inMilliseconds.clamp(
                0,
                duration.inMilliseconds,
              ),
            );
            isSeeking.value = true;
            dragDuration.value = dragPosition.value;
            logger.info(dragPosition);
          },
          onHorizontalDragEnd: (details) {
            c.seek(dragPosition.value);
            isSeeking.value = false;
            dragDuration.value = Duration.zero;
          },
          onLongPressStart: (details) {
            if (ref.read(vidPr).locked) return;
            c.setSpeed(3);
          },
          onLongPressEnd: (details) {
            if (ref.read(vidPr).locked) return;
            c.setSpeed(1);
          },
          child: child,
        ),
        // The double-tap seek burst rides ABOVE the video: the animated
        // two-triangle glyph + skipped time at the tapped side. Re-keyed per
        // tap so the animation replays; the OverlayGesture area keeps every
        // gesture it had.
        if (seekBurst.value != null)
          Align(
            alignment: Alignment(seekBurst.value!.forward ? 0.62 : -0.62, 0),
            child: PlayerSeekBurst(
              key: ValueKey(seekBurst.value!.stamp),
              forward: seekBurst.value!.forward,
            ),
          ),
      ],
    );
  }
}
