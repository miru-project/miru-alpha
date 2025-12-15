import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/widgets/core/outline_text.dart';
import 'package:screen_brightness/screen_brightness.dart';
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
    final currentBrightness = useState(0.0);
    final currentVolume = useState(0.0);
    final isSeeking = useState(false);
    final isBrightness = useState(false);

    final dragDuration = useState(Duration.zero);
    final dragPosition = useState(Duration.zero);
    final c = ref.read(vidPr.notifier);
    final duration = ref.watch(vidPr.select((s) => s.duration));
    final position = ref.watch(vidPr.select((s) => s.position));
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
            // 如果左边点击快退，中间暂停，右边快进
            final dx = details.localPosition.dx;
            final width = MediaQuery.of(context).size.width / 3;
            if (dx < width) {
              c.seek(position - const Duration(seconds: 10));
            } else if (dx > width * 2) {
              c.seek(position + const Duration(seconds: 10));
            } else {
              c.playOrPause();
            }
          },
          onVerticalDragStart: (details) {
            isBrightness.value =
                details.localPosition.dx <
                MediaQuery.of(context).size.width / 2;
          },
          // 左右两边上下滑动
          onVerticalDragUpdate: (details) {
            final add = details.delta.dy / 500;
            // 如果是左边调节亮度
            if (isBrightness.value) {
              currentBrightness.value = (currentBrightness.value - add).clamp(
                0,
                1,
              );
              ScreenBrightness().setApplicationScreenBrightness(
                currentBrightness.value,
              );
            }
            // 如果是右边调节音量
            else {
              currentVolume.value = (currentVolume.value - add).clamp(0, 1);
              // VolumeController.setVolume(_currentVolume);
              VolumeController.instance.setVolume(currentVolume.value);
            }
            // _isAdjusting = true;
            // setState(() {});
          },
          onHorizontalDragStart: (details) {
            dragPosition.value = position;
          },
          onVerticalDragEnd: (details) {
            // _isAdjusting = false;
            // setState(() {});
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
            // setState(() {});
          },
          onLongPressStart: (details) {
            // _isLongPress = true;
            c.setSpeed(3);
            // setState(() {});
          },
          onLongPressEnd: (details) {
            c.setSpeed(ref.read(vidPr.select((s) => s.speed)));
            // _isLongPress = false;
            // setState(() {});
          },
          child: child,
        ),
      ],
    );
  }
}
