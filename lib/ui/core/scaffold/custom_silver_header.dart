import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Base delegate for all sliver headers.
/// Wraps content in a [SizedBox] to ensure [paintExtent] always matches
/// the expected [layoutExtent], preventing the "layoutExtent exceeds paintExtent"
/// assertion error.
abstract class BaseSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  const BaseSliverHeaderDelegate({
    required this.maxExtent,
    required this.minExtent,
  });

  @override
  final double maxExtent;
  @override
  final double minExtent;

  /// Build the header content based on current shrink offset.
  /// [shrinkOffset] ranges from 0 to (maxExtent - minExtent).
  Widget buildContent(BuildContext context, double shrinkOffset);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: (maxExtent - shrinkOffset).clamp(minExtent, maxExtent),
      child: ClipRect(child: buildContent(context, shrinkOffset)),
    );
  }
}

/// Delegate that adds scroll-position awareness and throttled rebuild logic.
/// Only extend this when you need scroll-driven animations.
abstract class ScrollDrivenHeaderDelegate extends BaseSliverHeaderDelegate {
  ScrollDrivenHeaderDelegate({
    required this.scrollPosition,
    required super.maxExtent,
    required super.minExtent,
    this.throttle = ScrollUpdateThrottle.none,
  });

  final ValueListenable<double> scrollPosition;
  final ScrollUpdateThrottle throttle;

  @override
  bool shouldRebuild(covariant ScrollDrivenHeaderDelegate oldDelegate) {
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

/// Throttle levels for scroll position updates to improve performance.
enum ScrollUpdateThrottle {
  none,
  low, // ~16ms (60fps)
  medium, // ~32ms (30fps)
  high, // ~64ms (15fps)
}

// ---------------------------------------------------------------------------
// Concrete delegates
// ---------------------------------------------------------------------------

/// Delegate for headers that shrink when scrolling up.
class ShrinkableHeaderDelegate extends ScrollDrivenHeaderDelegate {
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

/// Delegate for headers that expand when scrolling down/up.
class ExpandableHeaderDelegate extends ScrollDrivenHeaderDelegate {
  ExpandableHeaderDelegate({
    required super.scrollPosition,
    required super.maxExtent,
    required super.minExtent,
    required this.builder,
  });

  final Widget Function(BuildContext context, double expandOffset) builder;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    final expandOffset = (maxExtent - minExtent) - shrinkOffset;
    return builder(context, expandOffset.clamp(0.0, maxExtent - minExtent));
  }
}

/// Delegate for static headers that wraps child with smooth opacity/clipping
/// transition. Does NOT require a scroll position notifier.
class StaticSliverHeaderDelegate extends BaseSliverHeaderDelegate {
  StaticSliverHeaderDelegate({
    required super.maxExtent,
    super.minExtent = 0.0,
    required this.child,
  });

  final Widget child;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    return SizedBox(
      height: (maxExtent - shrinkOffset).clamp(minExtent, maxExtent),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant StaticSliverHeaderDelegate oldDelegate) {
    // Always rebuild so the SizedBox height is re-evaluated against the
    // current shrinkOffset during scroll. The delegate is a single instance
    // in the widget tree, so comparing fields to itself always yields false.
    return true;
  }
}

/// A sliver header delegate whose [minExtent] and [maxExtent] are supplied as
/// concrete values that may change between rebuilds (e.g. when a filter panel
/// expands or collapses). When either extent changes, [shouldRebuild] returns
/// `true` so the header re-lays out at the new size.
///
/// Both values must satisfy `minExtentValue <= maxExtentValue` (the contract
/// required by [SliverPersistentHeader]). A typical pattern:
///   - collapsed: maxExtent = 200, minExtent = 120 (header can shrink on scroll)
///   - expanded:  both      = 250 (header stays fully open, never shrinks)
class DynamicMinExtentHeaderDelegate extends BaseSliverHeaderDelegate {
  DynamicMinExtentHeaderDelegate({
    required this.maxExtentValue,
    required this.minExtentValue,
    required this.child,
  }) : assert(
         minExtentValue <= maxExtentValue,
         'minExtentValue must be <= maxExtentValue',
       ),
       super(maxExtent: maxExtentValue, minExtent: minExtentValue);

  final double maxExtentValue;
  final double minExtentValue;
  final Widget child;

  @override
  double get maxExtent => maxExtentValue;

  @override
  double get minExtent => minExtentValue;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    return SizedBox(
      height: (maxExtent - shrinkOffset).clamp(minExtent, maxExtent),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant DynamicMinExtentHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.maxExtentValue != maxExtentValue ||
        oldDelegate.minExtentValue != minExtentValue;
  }
}

/// Delegate for headers that can both shrink and expand with different
/// behaviors. Provides [shrinkProgress] (0.0 to 1.0) for animation.
class FlexibleHeaderDelegate extends ScrollDrivenHeaderDelegate {
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

/// Delegate for headers with animated size transitions and scroll-driven
/// callbacks. Supports smooth animations with configurable duration and
/// throttle levels.
class DynamicHeaderDelegate extends ScrollDrivenHeaderDelegate {
  DynamicHeaderDelegate({
    required super.scrollPosition,
    required super.maxExtent,
    required super.minExtent,
    required this.builder,
    this.animationDuration = const Duration(milliseconds: 150),
  }) : super(throttle: ScrollUpdateThrottle.none);

  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    double shrinkProgress,
  )
  builder;
  final Duration animationDuration;

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
  bool shouldRebuild(covariant ScrollDrivenHeaderDelegate oldDelegate) {
    if (oldDelegate is! DynamicHeaderDelegate) return true;
    final delta = (oldDelegate.scrollPosition.value - scrollPosition.value)
        .abs();
    return delta > 0.1;
  }
}

/// Simple delegate that renders a fixed child with no scroll-driven animation.
class SimpleSliverHeaderDelegate extends BaseSliverHeaderDelegate {
  const SimpleSliverHeaderDelegate({
    required this.child,
    required super.maxExtent,
    super.minExtent = 0.0,
  });

  final Widget child;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    return SizedBox(height: maxExtent - shrinkOffset, child: child);
  }

  @override
  bool shouldRebuild(covariant SimpleSliverHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}

/// Generic delegate that accepts a builder function for full control.
///
/// By default the [builder] receives the sliver's own `shrinkOffset` (and a
/// normalized `progress`). That value only changes while the *enclosing*
/// [CustomScrollView] scrolls. When the header lives inside a layout where the
/// body is a separate (nested) scroll view — e.g. a [MiruScaffold] whose
/// `mobileBody` scrolls on its own — the outer sliver never receives a changing
/// `shrinkOffset`, so the header would never update.
///
/// Pass [scrollPosition] (a [ValueListenable] fed by the real scroll, such as
/// the [MiruScaffold.onScrollChange] callback) to drive the header from that
/// scroll position instead. The returned widget then rebuilds on every change
/// via a [ValueListenableBuilder] without requiring the sliver itself to scroll.
class CustomSliverHeaderDelegate extends BaseSliverHeaderDelegate {
  const CustomSliverHeaderDelegate({
    required this.builder,
    required super.maxExtent,
    super.minExtent = 0.0,
    this.scrollPosition,
  });

  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    double progress,
  )
  builder;

  /// Optional external scroll position. When provided, the header is driven by
  /// this value (via a [ValueListenableBuilder]) instead of the sliver's own
  /// `shrinkOffset`. This is required when the header's enclosing scroll view
  /// does not actually scroll (e.g. the body is a nested scroll view).
  final ValueListenable<double>? scrollPosition;

  @override
  Widget buildContent(BuildContext context, double shrinkOffset) {
    if (scrollPosition == null) {
      final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
      return builder(context, shrinkOffset, progress);
    }
    return ValueListenableBuilder<double>(
      valueListenable: scrollPosition!,
      builder: (context, offset, _) {
        final progress = (offset / (maxExtent - minExtent)).clamp(0.0, 1.0);
        return builder(context, offset, progress);
      },
    );
  }

  @override
  bool shouldRebuild(covariant CustomSliverHeaderDelegate oldDelegate) {
    return true;
  }
}
