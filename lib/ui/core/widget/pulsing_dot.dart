import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A small dot that pulses its opacity on a fixed cycle — the "still alive"
/// signal of loading states (connecting pills, resolving episode rows).
class PulsingDot extends HookWidget {
  const PulsingDot({
    super.key,
    required this.color,
    this.size = 6,
    this.period = const Duration(milliseconds: 1400),
  });

  final Color color;
  final double size;
  final Duration period;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: period)..repeat();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.value);
        final opacity = (1.0 - 0.7 * t).clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withAlpha((255 * opacity).round()),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
