import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Block-sized shimmer placeholder used by section skeletons. The base color
/// animates between two values so it reads as "loading" at a glance.
class DetailSkeleton extends HookWidget {
  const DetailSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final ctrl = useAnimationController(
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    final base = context.theme.colors.muted;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final t = ctrl.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(base, context.theme.colors.background, t * 0.5),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}
