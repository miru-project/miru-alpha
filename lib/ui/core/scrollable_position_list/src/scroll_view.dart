// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'wrapping.dart';
import 'viewport.dart';

/// A version of [CustomScrollView] that allows does not constrict the extents
/// to be within 0 and 1. See [CustomScrollView] for more information.
class UnboundedCustomScrollView extends CustomScrollView {
  final bool _shrinkWrap;

  const UnboundedCustomScrollView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    this._shrinkWrap = false,
    super.center,
    this._anchor = 0.0,
    super.scrollCacheExtent,
    super.slivers,
    super.semanticChildCount,
    super.dragStartBehavior,
  }) : super(shrinkWrap: false);

  // [CustomScrollView] enforces constraints on [CustomScrollView.anchor], so
  // we need our own version.
  final double _anchor;

  @override
  double get anchor => _anchor;

  /// Build the viewport.
  @override
  @protected
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    AxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    if (_shrinkWrap) {
      return CustomShrinkWrappingViewport(
        axisDirection: axisDirection,
        offset: offset,
        slivers: slivers,
        scrollCacheExtent: scrollCacheExtent,
        center: center,
        anchor: anchor,
      );
    }
    return UnboundedViewport(
      axisDirection: axisDirection,
      offset: offset,
      slivers: slivers,
      scrollCacheExtent: scrollCacheExtent,
      center: center,
      anchor: anchor,
    );
  }
}
