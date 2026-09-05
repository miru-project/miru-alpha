import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Detail Skeleton', size: Size(200, 100))
Widget detailSkeletonPreview() {
  return const _ShimmerBlock();
}

class _ShimmerBlock extends StatefulWidget {
  const _ShimmerBlock();

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: Color.lerp(
              base,
              Theme.of(context).colorScheme.surface,
              t * 0.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
