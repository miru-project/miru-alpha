import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

/// The "playing" equalizer: three bars bouncing on offset phases — the active
/// row's trailing indicator in episode lists (detail page, chapter drawer).
class EqBars extends HookWidget {
  const EqBars({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.colors.primary;
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 900),
    )..repeat();

    Widget bar(double phase, double min, double max) {
      final t = Curves.easeInOut.transform(controller.value);
      final height = min + (max - min) * (t < 0.5 ? t * 2 : 2 - t * 2);
      return Container(
        width: 2.5,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    return SizedBox(
      width: 20,
      height: 16,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [bar(0.00, 4, 15), bar(0.35, 4, 15), bar(0.65, 4, 15)],
        ),
      ),
    );
  }
}
