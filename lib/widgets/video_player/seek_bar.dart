import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
// removed unused import
import 'dart:ui' show lerpDouble;

class SeekBar extends HookConsumerWidget {
  const SeekBar({super.key, required this.vidPr});
  final VideoPlayerNotifierProvider vidPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Move mutable state into hooks to keep this widget immutable
    final timerRef = useRef<Timer?>(null);
    // previous-timer throttle value removed (unused)
    final isSliderDraggingRef = useRef<bool>(false);
    final rawExtentRef = useRef<double>(0);

    // helper to debounce slider updates (kept commented for future use)
    // void updateSliderTimer(VoidFunction callback) {
    //   timerRef.value?.cancel();
    //   timerRef.value = Timer(const Duration(milliseconds: 300), () {
    //     callback();
    //   });
    // }

    // Cancel timer on dispose
    useEffect(() {
      return () {
        timerRef.value?.cancel();
        timerRef.value = null;
      };
    }, const []);
    final duration = ref.watch(vidPr.select((s) => s.duration));
    final pos = ref.watch(vidPr.select((s) => s.position));
    final vidLen = duration.inMilliseconds;
    final double playerPos = vidLen == 0 ? 0 : pos.inMilliseconds / vidLen;
    final sliderSelection = FSliderSelection(max: 1);
    final fcontroller = useFContinuousSliderController(
      stepPercentage: .00001,
      selection: sliderSelection,
    );

    {
      if (!isSliderDraggingRef.value) {
        fcontroller.slide(playerPos * rawExtentRef.value, min: false);
      }
      return Material(
        color: Colors.transparent,
        child: SliderTheme(
          data: SliderThemeData(
            year2023: true,
            thumbShape: HandleThumbShape(),
            trackHeight: 4,
            thumbColor: Colors.white,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.5),
            overlayColor: Colors.transparent,
            thumbSize: WidgetStatePropertyAll(Size(12, 12)),
          ),
          child: Theme(
            // Disable splash/ripple from InkWell for this subtree.
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Slider(
              value: playerPos.isNaN ? 0 : playerPos,
              onChanged: (value) {
                isSliderDraggingRef.value = true;
                ref.read(vidPr.notifier).updateTimer();
              },
              onChangeEnd: (value) {
                final seekVal = value * vidLen;
                ref
                    .read(vidPr.notifier)
                    .seek(Duration(milliseconds: seekVal.toInt()));
                isSliderDraggingRef.value = false;
              },
            ),
          ),
        ),
      );
      // SizedBox(
      //   height: 50,
      //   child: FSlider(
      //     enabled: duration.inMilliseconds > 0,
      //     layout: FLayout.ltr,
      //     tooltipBuilder: (tip, val) {
      //       return Text(
      //         Duration(
      //           milliseconds: (vidLen * val).toInt(),
      //         ).toString().split('.').first.substring(2),
      //       );
      //     },
      //     controller: fcontroller,
      //     semanticFormatterCallback: (val) {
      //       rawExtentRef.value = val.rawExtent.max;
      //       isSliderDraggingRef.value = false;
      //       return "";
      //     },

      //     // onChange: (value) {
      //     //   isSliderDraggingRef.value = true;

      //     //   ref.read(vidPr.notifier).updateTimer();
      //     //   final time = DateTime.now().millisecondsSinceEpoch;
      //     //   logger.info("playerpos on change ");
      //     //   if (time - prevTimeRef.value > 300) {
      //     //     logger.info(sliderSelection.rawExtent);
      //     //     prevTimeRef.value = time;
      //     //     updateSliderTimer(() {
      //     //       final seekVal = value.offset.max * vidLen;
      //     //       ref
      //     //           .read(vidPr.notifier)
      //     //           .seek(Duration(milliseconds: seekVal.toInt()));
      //     //       isSliderDraggingRef.value = false;
      //     //     });
      //     //   }
      //     // },
      //   ),
      // );
    }
  }
}

// Custom thumb shape that animates its size using the slider's activationAnimation.
class HandleThumbShape extends SliderComponentShape {
  final double minRadius;
  final double maxRadius;

  const HandleThumbShape({this.minRadius = 10.0, this.maxRadius = 12.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final d = maxRadius * 2.0;
    return Size(d, d);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // activationAnimation goes from 0.0 -> 1.0 when the thumb is pressed/active.
    final t = Curves.easeOut.transform(activationAnimation.value);

    // Interpolate radius between min and max.
    final radius = lerpDouble(minRadius, maxRadius, t)!;

    // Draw subtle shadow that grows with the animation.
    if (t > 0.01) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.12 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center.translate(0, 1.0 * t), radius, shadowPaint);
    }

    // Draw concentric thumb using filled circles so the white ring fits
    // perfectly around the black center. We draw a white filled circle
    // (outer) and then a smaller black filled circle (inner) on top.
    final outerColor = Colors.white;
    final innerColor = Colors.black;

    // Determine ring thickness as a proportion of the animated radius.
    // Clamp so it never disappears or becomes too large.
    final ringThickness = (radius * 0.22).clamp(1.0, radius * 0.45);

    // Outer (white) radius is the animated radius.
    final outerRadius = radius;
    // Inner (black) radius sits exactly inside the white ring.
    final innerRadius = (outerRadius - ringThickness).clamp(
      1.0,
      outerRadius - 1.0,
    );

    final outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw the white outer circle and then the black inner circle to form
    // a perfectly fitting ring.
    canvas.drawCircle(center, outerRadius, outerPaint);
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
}
