import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Base delegate for animated headers that support shrink/expand behavior
abstract class AnimatedHeaderDelegate extends SliverPersistentHeaderDelegate {
  AnimatedHeaderDelegate({
    required this.scrollPosition,
    required this.maxExtent,
    required this.minExtent,
  });

  final ValueListenable<double> scrollPosition;

  @override
  final double maxExtent;
  @override
  final double minExtent;

  /// Build the header content based on current shrink/expand offset
  /// [shrinkOffset] ranges from 0 to (maxExtent - minExtent)
  Widget buildContent(BuildContext context, double shrinkOffset);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return buildContent(context, shrinkOffset);
  }

  @override
  bool shouldRebuild(covariant AnimatedHeaderDelegate oldDelegate) {
    // Optimize: only rebuild if scroll position meaningfully changed (> 1 pixel)
    return (oldDelegate.scrollPosition.value - scrollPosition.value).abs() >
        1.0;
  }
}

/// Delegate for headers that shrink when scrolling up
class ShrinkableHeaderDelegate extends AnimatedHeaderDelegate {
  ShrinkableHeaderDelegate({
    required super.scrollPosition,
    required super.maxExtent,
    required super.minExtent,
    required this.builder,
  });

  final Widget Function(BuildContext context, double shrinkOffset) builder;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    return builder(context, shrinkOffset);
  }
}

/// Delegate for headers that expand when scrolling down/up
class ExpandableHeaderDelegate extends AnimatedHeaderDelegate {
  ExpandableHeaderDelegate({
    required super.scrollPosition,
    required super.maxExtent,
    required super.minExtent,
    required this.builder,
  });

  final Widget Function(BuildContext context, double expandOffset) builder;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    // For expandable, we calculate how much extra space is available
    final expandOffset = (maxExtent - minExtent) - shrinkOffset;
    return builder(context, expandOffset.clamp(0.0, maxExtent - minExtent));
  }
}

/// Delegate for static headers that wraps child with smooth opacity/clipping transition
class StaticSliverHeaderDelegate extends ShrinkableHeaderDelegate {
  StaticSliverHeaderDelegate({
    required super.maxExtent,
    super.minExtent = 0.0,
    required Widget child,
  }) : super(
         scrollPosition: ValueNotifier<double>(0.0),
         builder: (context, shrinkOffset) {
           final progress = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
           return SizedBox(
             height: maxExtent - shrinkOffset,
             child: Opacity(
               opacity: 1.0 - progress,
               child: SingleChildScrollView(
                 physics: const NeverScrollableScrollPhysics(),
                 child: child,
               ),
             ),
           );
         },
       );
}

/// Delegate for headers that can both shrink and expand with different behaviors
class FlexibleHeaderDelegate extends AnimatedHeaderDelegate {
  FlexibleHeaderDelegate({
    required super.scrollPosition,
    required super.maxExtent,
    required super.minExtent,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    double shrinkProgress, // 0.0 to 1.0
  )
  builder;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    final shrinkProgress =
        shrinkOffset / (maxExtent - minExtent).clamp(1.0, double.infinity);
    return builder(context, shrinkOffset, shrinkProgress.clamp(0.0, 1.0));
  }
}

/// Throttle levels for scroll position updates to improve performance
enum ScrollUpdateThrottle {
  none,
  low, // ~16ms (60fps)
  medium, // ~32ms (30fps)
  high, // ~64ms (15fps)
}

/// Delegate for headers with animated size transitions and scroll-driven callbacks
/// Supports smooth animations with configurable duration and throttle levels
class DynamicHeaderDelegate extends AnimatedHeaderDelegate {
  DynamicHeaderDelegate({
    required super.scrollPosition,
    required super.maxExtent,
    required super.minExtent,
    required this.builder,
    this.animationDuration = const Duration(milliseconds: 150),
    this.throttle = ScrollUpdateThrottle.none,
  });

  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    double shrinkProgress,
  )
  builder;
  final Duration animationDuration;
  final ScrollUpdateThrottle throttle;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    final shrinkProgress =
        shrinkOffset / (maxExtent - minExtent).clamp(1.0, double.infinity);
    final clampedProgress = shrinkProgress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: clampedProgress),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return builder(context, shrinkOffset, animatedProgress);
      },
    );
  }

  @override
  bool shouldRebuild(covariant AnimatedHeaderDelegate oldDelegate) {
    if (oldDelegate is! DynamicHeaderDelegate) return true;
    // Apply throttle-based rebuild logic
    final delta = (oldDelegate.scrollPosition.value - scrollPosition.value)
        .abs();
    switch (throttle) {
      case ScrollUpdateThrottle.none:
        return delta > 0.1;
      case ScrollUpdateThrottle.low:
        return delta > 1.0;
      case ScrollUpdateThrottle.medium:
        return delta > 2.0;
      case ScrollUpdateThrottle.high:
        return delta > 4.0;
    }
  }
}

class SimpleSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SimpleSliverHeaderDelegate({
    required this.child,
    required this.maxExtent,
    this.minExtent = 0.0,
  });

  final Widget child;
  @override
  final double maxExtent;
  @override
  final double minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxExtent - shrinkOffset, child: child);
  }

  @override
  bool shouldRebuild(covariant SimpleSliverHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}

class CustomSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  const CustomSliverHeaderDelegate({
    required this.builder,
    required this.maxExtent,
    this.minExtent = 0.0,
  });

  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    double progress,
  )
  builder;
  @override
  final double maxExtent;
  @override
  final double minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return builder(context, shrinkOffset, progress);
  }

  @override
  bool shouldRebuild(covariant CustomSliverHeaderDelegate oldDelegate) {
    return true;
  }
}
