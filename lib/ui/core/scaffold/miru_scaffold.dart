import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class MiruScaffold extends StatefulHookConsumerWidget {
  const MiruScaffold.desktop({
    super.key,
    this.desktopBody,
    this.body,
    this.scrollController,
    this.snappingOffsets,
    this.onScrollChange,
    this.scrollThrottle = ScrollUpdateThrottle.none,
    this.headerHeight = 50,
    this.sliverHeaders = const [],
    this.slivers,
  }) : assert(desktopBody != null || body != null || slivers != null),
       mobileBody = null,
       snapSheet = const [],
       sheetController = null,
       childPad = true,
       resizeToAvoidBottomInset = false;

  const MiruScaffold.mobile({
    super.key,
    this.mobileBody,
    this.body,
    this.desktopBody,
    this.snapSheet = const [],
    this.sheetController,
    this.scrollController,
    this.headerHeight = 50,
    this.sliverHeaders = const [],
    this.snappingOffsets,
    this.childPad = true,
    this.resizeToAvoidBottomInset = false,
    this.onScrollChange,
    this.scrollThrottle = ScrollUpdateThrottle.none,
    this.slivers,
  }) : assert(mobileBody != null || body != null || slivers != null);

  final Widget? desktopBody;
  final Widget? mobileBody;
  final Widget? body;
  final List<Widget> snapSheet;
  final SheetController? sheetController;
  final double headerHeight;

  /// List of sliver persistent header delegates for animated/shrinkable headers
  final List<SliverPersistentHeaderDelegate> sliverHeaders;

  /// Content slivers injected directly into the CustomScrollView, replacing the
  /// default [body]. Use this to share the same scroll context as the headers
  /// so scrolling feels unified instead of nested.
  final List<Widget>? slivers;

  /// Snapping offsets for snap sheet mode
  final List<SheetOffset>? snappingOffsets;

  final bool childPad;
  final bool resizeToAvoidBottomInset;
  final ScrollController? scrollController;

  /// Callback for scroll position changes with normalized progress (0.0 to 1.0)
  /// Provides both raw offset and progress for dynamic header animations
  final void Function(double offset, double progress)? onScrollChange;

  /// Throttle level for scroll position updates to improve performance
  final ScrollUpdateThrottle scrollThrottle;

  @override
  ConsumerState<MiruScaffold> createState() => _MiruScaffoldState();
}

class _MiruScaffoldState extends ConsumerState<MiruScaffold> {
  late ScrollController scrollController;
  late SheetController _sheetController;

  /// ValueNotifier for passive scroll position listening
  final ValueNotifier<double> _scrollPositionNotifier = ValueNotifier<double>(
    0,
  );

  /// Public getter for external scroll position listeners
  ValueListenable<double> get scrollPosition => _scrollPositionNotifier;

  double _nonSnapScrollOffset = 0;

  @override
  void dispose() {
    scrollController.dispose();
    if (widget.sheetController == null) {
      _sheetController.dispose();
    }
    _scrollPositionNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    scrollController = widget.scrollController ?? ScrollController();
    _sheetController = widget.sheetController ?? SheetController();
    super.initState();
  }

  List<SheetOffset> get _defaultSnappingOffsets => const [
    AbsoluteSheetOffset(190),
    ProportionalToViewportSheetOffset(0.5),
    ProportionalToViewportSheetOffset(1.0),
  ];

  // ---------------------------------------------------------------------------
  // SnapSheet mode
  // Composition: header slivers + snapSheet items in a CustomScrollView
  // ---------------------------------------------------------------------------
  Widget _buildSnapSheetMode(bool isMobileTitleOnTop) {
    final slivers = <Widget>[
      // Add all sliver headers wrapped in SliverPersistentHeader
      // Only include in slivers if not showing externally (when isMobileTitleOnTop is true)
      if (!isMobileTitleOnTop)
        ...widget.sliverHeaders.map(
          (delegate) =>
              SliverPersistentHeader(delegate: delegate, pinned: true),
        ),
      _buildGrabHandle(),
      const SliverToBoxAdapter(child: SizedBox(height: 10)),
      ..._buildSnapSheetItems(),
    ];

    return Stack(
      children: [
        _buildBodyBackground(),
        if (isMobileTitleOnTop && widget.sliverHeaders.isNotEmpty)
          _buildExternalSliverHeaders(),
        Positioned.fill(child: _buildSnapSheetContent(slivers: slivers)),
      ],
    );
  }

  Widget _buildExternalSliverHeaders() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 5),
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: widget.sliverHeaders
            .map(
              (delegate) =>
                  SliverPersistentHeader(delegate: delegate, pinned: true),
            )
            .toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Non-snapSheet mode
  // Composition: sliver headers + body in a CustomScrollView
  // ---------------------------------------------------------------------------
  Widget _buildNonSnapSheetMode() {
    final slivers = <Widget>[
      ...widget.sliverHeaders.map(
        (delegate) => SliverPersistentHeader(delegate: delegate, pinned: true),
      ),
    ];

    if (widget.slivers != null) {
      // Content provided as slivers shares the same CustomScrollView as the
      // headers, giving a single unified scroll context.
      slivers.addAll(widget.slivers!);
    } else {
      slivers.add(
        SliverFillRemaining(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: widget.mobileBody ?? widget.body ?? const SizedBox.shrink(),
          ),
        ),
      );
    }

    return FScaffold(
      childPad: widget.childPad,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      child: CustomScrollView(
        controller: scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: slivers,
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!notification.metrics.hasPixels) return false;
    final newOffset = notification.metrics.pixels;
    final delta = (newOffset - _nonSnapScrollOffset).abs();

    // Apply throttle threshold
    final threshold = switch (widget.scrollThrottle) {
      ScrollUpdateThrottle.none => 0.1,
      ScrollUpdateThrottle.low => 1.0,
      ScrollUpdateThrottle.medium => 2.0,
      ScrollUpdateThrottle.high => 4.0,
    };

    if (delta > threshold) {
      _nonSnapScrollOffset = newOffset;
      _scrollPositionNotifier.value = newOffset;
      if (widget.onScrollChange != null) {
        // Calculate progress based on maxExtent from sliver headers
        final maxExtent = widget.sliverHeaders.isNotEmpty
            ? widget.sliverHeaders.first.maxExtent
            : widget.headerHeight;
        final progress = (newOffset / maxExtent).clamp(0.0, 1.0);
        widget.onScrollChange!(newOffset, progress);
      }
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Snap sheet content widget (the draggable sheet itself)
  // ---------------------------------------------------------------------------
  Widget _buildSnapSheetContent({required List<Widget> slivers}) {
    final snaps = widget.snappingOffsets ?? _defaultSnappingOffsets;

    return SheetViewport(
      child: Sheet(
        controller: _sheetController,
        initialOffset: snaps.first,
        snapGrid: MultiSnapGrid(snaps: snaps),
        physics: const BouncingSheetPhysics(),
        child: SheetKeyboardDismissible(
          dismissBehavior: const DragDownSheetKeyboardDismissBehavior(),
          child: _buildSheetDecorated(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: CustomScrollView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const NeverScrollableScrollPhysics(),
                slivers: slivers,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------
  Widget _buildBodyBackground() {
    return Positioned.fill(
      child: FScaffold(
        childPad: widget.childPad,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        child: widget.mobileBody ?? widget.body ?? const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildGrabHandle() {
    return const SliverToBoxAdapter(child: _GrabbingWidget());
  }

  List<Widget> _buildSnapSheetItems() {
    return widget.snapSheet.map((e) => SliverToBoxAdapter(child: e)).toList();
  }

  Widget _buildSheetDecorated({required Widget child}) {
    return Blur(
      blurDensity: 10,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: MiruCard(
        style: .delta(
          decoration: .boxDelta(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            color: context.theme.colors.background.withAlpha(150),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: BackdropFilter(
            filter: ImageFilter.compose(
              outer: ColorFilter.mode(
                context.theme.colors.barrier,
                BlendMode.srcOver,
              ),
              inner: ImageFilter.compose(
                outer: ColorFilter.mode(
                  context.theme.colors.primary.withAlpha(25),
                  BlendMode.srcOver,
                ),
                inner: ColorFilter.mode(
                  context.theme.colors.primary.withAlpha(25),
                  BlendMode.srcOver,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobileTitleOnTop = ref.watch(
      applicationControllerProvider.select((value) => value.isMobileTitleOnTop),
    );
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PlatformWidget(
      mobileWidget: Padding(
        padding: .only(top: MediaQuery.of(context).padding.top),
        child: PopScope(
          canPop: bottomInset == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (bottomInset > 0) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: FTheme(
            data: ref.watch(applicationControllerProvider).themeData,
            child: SizedBox.expand(
              child: widget.snapSheet.isNotEmpty && !isMobileTitleOnTop
                  ? _buildSnapSheetMode(isMobileTitleOnTop)
                  : _buildNonSnapSheetMode(),
            ),
          ),
        ),
      ),
      desktopWidget: _buildDesktopWidget(),
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop mode
  // Composition: sliver headers + body/slivers in a CustomScrollView.
  // Mirrors the mobile non-snapSheet path so callers may pass content via
  // [slivers] (a list of slivers) instead of a box [body] on desktop too.
  // ---------------------------------------------------------------------------
  Widget _buildDesktopWidget() {
    if (widget.desktopBody != null || widget.body != null) {
      return widget.desktopBody ?? widget.body!;
    }

    final slivers = <Widget>[
      ...widget.sliverHeaders.map(
        (delegate) => SliverPersistentHeader(delegate: delegate, pinned: true),
      ),
      if (widget.slivers != null)
        ...widget.slivers!
      else
        const SliverFillRemaining(child: SizedBox.shrink()),
    ];

    // On desktop, we don't use FScaffold when slivers are provided because
    // FScaffold expects a RenderBox child, but CustomScrollView with slivers
    // produces a RenderSliverPadding child which is incompatible.
    return CustomScrollView(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: slivers,
    );
  }
}

class _GrabbingWidget extends StatelessWidget {
  const _GrabbingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          width: 100,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}
