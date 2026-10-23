import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:shimmer/shimmer.dart';

/// Poster tile + horizontal rail shared by the Dynamic Feed and Trending
/// sections. The card is a bare 2:3 cover with overlaid chips; title and
/// source line sit below it.
const kHomePosterWidth = 130.0;
const kHomePosterRailHeight = 232.0;

class HomePosterRail extends StatelessWidget {
  const HomePosterRail({
    super.key,
    required this.itemCount,
    required this.builder,
  });

  final int itemCount;
  final IndexedWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kHomePosterRailHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: builder,
      ),
    );
  }
}

/// Shimmer placeholder shown while a poster / cover image is in flight —
/// keeps the slot's aspect ratio so the rail doesn't shift when the pixels
/// arrive (an empty URL still renders the permanent muted fallback instead).
class HomeMediaSkeletonBox extends StatelessWidget {
  const HomeMediaSkeletonBox({super.key, this.borderRadius = 10});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.colors.muted,
      highlightColor: context.theme.colors.secondary,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.theme.colors.muted,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class HomePosterCard extends StatelessWidget {
  const HomePosterCard({
    super.key,
    required this.title,
    required this.onTap,
    this.cover,
    this.badge,
    this.overlay,
    this.subtitle,
  });

  final String title;
  final VoidCallback onTap;

  /// Poster URL; empty renders the muted fallback tile.
  final String? cover;

  /// Top-left overlay (tag or rank chip).
  final Widget? badge;

  /// Bottom-right overlay (score chip).
  final Widget? overlay;

  /// Muted line under the title (type · source).
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final height = kHomePosterWidth * 3 / 2;

    return AnimatedBox.nopadding(
      onTap: onTap,
      child: SizedBox(
        width: kHomePosterWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: kHomePosterWidth,
                  height: height,
                  child: (cover == null || cover!.isEmpty)
                      ? DecoratedBox(
                          key: const Key('homePosterFallback'),
                          decoration: BoxDecoration(
                            color: colors.muted,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            FLucideIcons.image,
                            color: colors.mutedForeground,
                          ),
                        )
                      : ImageWidget(
                          imageUrl: cover,
                          width: kHomePosterWidth,
                          height: height,
                          fit: BoxFit.cover,
                          borderRadius: 10,
                          // Shimmer while the pixels load; an empty URL
                          // still takes the permanent muted fallback above.
                          loadingChild: const HomeMediaSkeletonBox(),
                        ),
                ),
                if (badge case final badge?)
                  Positioned(top: 6, left: 6, child: badge),
                if (overlay case final overlay?)
                  Positioned(bottom: 6, right: 6, child: overlay),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs2.copyWith(fontWeight: FontWeight.w600),
            ),
            if (subtitle case final subtitle?) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs3.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
