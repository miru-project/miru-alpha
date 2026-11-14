import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:shimmer/shimmer.dart';

import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner.dart';

/// Loading preview of [HomeBannerSection]'s carousel (mock rev 4).
///
/// Mirrors the loaded shell — 16px gutter, lg radius, the same fixed height,
/// the bottom-anchored
/// chip row / title / synopsis / CTA stack and the bottom-right dock — so
/// the skeleton-to-content swap does not reflow. Geometry is pinned by
/// `test/ui/features/home/home_banner_skeleton_test.dart`; any layout change
/// to the loaded slide must land here in the same pass.
class HomeBannerSkeleton extends StatelessWidget {
  const HomeBannerSkeleton({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: const Key('banner-skeleton'),
      borderRadius: context.theme.style.borderRadius.lg,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient canvas: the mock's opaque #151516 charcoal with a soft
            // zinc wash lighter in the middle.
            const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF151516)),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xD909090B),
                    Color(0x3318181B),
                    Color(0xD909090B),
                  ],
                ),
              ),
            ),
            // (The loaded hero's editorial top row was removed 2026-11-12 —
            // static pills + context badge; the skeleton mirrors that: no
            // top-row mirror any more.)
            // Bottom content mirror: chip row, title, synopsis, CTA trio.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    key: const Key('skeleton-chips'),
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _SkeletonBar(width: 96, height: 22, radius: 999),
                      SizedBox(width: 8),
                      _SkeletonBar(width: 52, height: 14, radius: 4),
                      SizedBox(width: 8),
                      _SkeletonBar(width: 88, height: 22, radius: 999),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _SkeletonBar(
                    key: Key('skeleton-title'),
                    width: 384,
                    height: 36,
                    radius: 8,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    key: Key('skeleton-synopsis'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SkeletonBar(width: 520, height: 16),
                      SizedBox(height: 4),
                      _SkeletonBar(width: 400, height: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    key: const Key('skeleton-actions'),
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _SkeletonBar(width: 144, height: 36, radius: 8),
                      SizedBox(width: 10),
                      _SkeletonBar(width: 128, height: 36, radius: 8),
                      SizedBox(width: 10),
                      _SkeletonBar(width: 36, height: 36, radius: 8),
                    ],
                  ),
                ],
              ),
            ),
            // Dock placeholder bottom-right: header bar + two thumbnails.
            const Positioned(right: 12, bottom: 12, child: _SkeletonDock()),
          ],
        ),
      ),
    );
  }
}

/// Dock placeholder bottom-right: a rounded panel with a header bar and two
/// thumbnail bars, mirroring the loaded dock's footprint.
class _SkeletonDock extends StatelessWidget {
  const _SkeletonDock();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('skeleton-dock'),
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x9609090B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3F3F46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const _SkeletonBar(width: 120, height: 10, radius: 4),
          Row(
            children: const [
              _SkeletonBar(width: 94, height: 56, radius: 6),
              SizedBox(width: 8),
              _SkeletonBar(width: 94, height: 56, radius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

/// One shimmering placeholder bar. The banner canvas is always dark (the
/// loaded slide scrims hardcode the 0x09090B base regardless of theme), so
/// the bars use the mock's white-over-dark wash instead of the theme's
/// muted pair.
class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0x24FFFFFF),
      highlightColor: const Color(0x52FFFFFF),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x24FFFFFF),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}
