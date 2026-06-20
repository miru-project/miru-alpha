import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class MiruScaffold extends StatefulHookConsumerWidget {
  const MiruScaffold.desktop({super.key, this.desktopBody, this.body})
    : assert(desktopBody != null || body != null),
      mobileBody = null,
      snapSheet = const [],
      sheetController = null,
      mobileHeader = null,
      mobilePinnedHeader = null,
      scrollController = null,
      snappingOffsets = null,
      childPad = true,
      resizeToAvoidBottomInset = false,
      onHeaderScroll = null;

  const MiruScaffold.mobile({
    super.key,
    this.mobileBody,
    this.body,
    this.desktopBody,
    this.snapSheet = const [],
    this.sheetController,
    this.mobileHeader,
    this.mobilePinnedHeader,
    this.scrollController,
    this.snappingOffsets,
    this.childPad = true,
    this.resizeToAvoidBottomInset = false,
    this.onHeaderScroll,
  }) : assert(mobileBody != null || body != null);

  final Widget? desktopBody;
  final Widget? mobileBody;
  final Widget? body;
  final List<Widget> snapSheet;
  final SheetController? sheetController;
  final Widget? mobileHeader;
  final Widget? mobilePinnedHeader;
  final ScrollController? scrollController;
  final List<SheetOffset>? snappingOffsets;
  final bool childPad;
  final bool resizeToAvoidBottomInset;

  /// Called on every scroll update in non-snapSheet mode.
  /// Allows the parent to customize/replace the collapsible header widget.
  /// Parameters: context, header widget, current scroll offset, measured header height
  /// Returns: custom widget to render as the collapsible header, or null for default
  final Widget? Function(
    BuildContext context,
    Widget header,
    double scrollOffset,
    double headerHeight,
  )?
  onHeaderScroll;

  @override
  ConsumerState<MiruScaffold> createState() => _MiruScaffoldState();
}

class _MiruScaffoldState extends ConsumerState<MiruScaffold> {
  late ScrollController scrollController;
  late SheetController _sheetController;

  /// Measured natural height of the collapsible mobileHeader.
  double _headerHeight = 50;

  final GlobalKey _headerKey = GlobalKey();

  /// Current scroll offset of the body in non-snapsheet mode.
  double _nonSnapScrollOffset = 0;

  @override
  void dispose() {
    scrollController.dispose();
    if (widget.sheetController == null) {
      _sheetController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    scrollController = widget.scrollController ?? ScrollController();
    _sheetController = widget.sheetController ?? SheetController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureHeaderHeight();
    });
  }

  void _measureHeaderHeight() {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      final measured = box.size.height;
      if (measured > 0 && measured != _headerHeight) {
        setState(() {
          _headerHeight = measured;
        });
      }
    }
  }

  List<SheetOffset> get _defaultSnappingOffsets => const [
    AbsoluteSheetOffset(190),
    ProportionalToViewportSheetOffset(0.5),
    ProportionalToViewportSheetOffset(1.0),
  ];

  // ---------------------------------------------------------------------------
  // SnapSheet mode
  // Composition: mobileHeader (above sheet when isMobileTitleOnTop) + snapSheet
  // ---------------------------------------------------------------------------
  Widget _buildSnapSheetMode(bool isMobileTitleOnTop) {
    return Stack(
      children: [
        _buildBodyBackground(isMobileTitleOnTop: isMobileTitleOnTop),
        if (isMobileTitleOnTop && widget.mobileHeader != null)
          _buildExternalHeader(),
        Positioned.fill(
          child: _buildSnapSheetContent(isMobileTitleOnTop: isMobileTitleOnTop),
        ),
      ],
    );
  }

  Widget _buildExternalHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 5),
      child: widget.mobileHeader,
    );
  }

  // ---------------------------------------------------------------------------
  // Non-snapSheet mode
  // Composition: mobileHeader (collapsible) + mobilePinnedHeader (fixed) + body
  // ---------------------------------------------------------------------------
  Widget _buildNonSnapSheetMode() {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return FScaffold(
          childPad: widget.childPad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.mobileHeader != null)
                _buildManualCollapsibleHeader(_nonSnapScrollOffset)!,
              if (widget.mobilePinnedHeader != null) widget.mobilePinnedHeader!,
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    final newOffset = notification.metrics.pixels;
                    if ((newOffset - _nonSnapScrollOffset).abs() > 0.5) {
                      _nonSnapScrollOffset = newOffset;
                      setInnerState(() {});
                    }
                    return false;
                  },
                  child: widget.mobileBody ?? widget.body!,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Snap sheet content widget (the draggable sheet itself)
  // ---------------------------------------------------------------------------
  Widget _buildSnapSheetContent({required bool isMobileTitleOnTop}) {
    final snaps = widget.snappingOffsets ?? _defaultSnappingOffsets;

    final sheetSlivers = <Widget>[
      _buildGrabHandle(),
      if (!isMobileTitleOnTop && _buildHeaderSliver() != null)
        _buildHeaderSliver()!,
      const SliverToBoxAdapter(child: SizedBox(height: 10)),
      ..._buildSnapSheetItems(),
    ];

    return SheetViewport(
      child: Sheet(
        controller: _sheetController,
        initialOffset: snaps.first,
        snapGrid: MultiSnapGrid(snaps: snaps),
        physics: const BouncingSheetPhysics(),
        child: SheetKeyboardDismissible(
          dismissBehavior: const DragDownSheetKeyboardDismissBehavior(),
          child: _buildSheetDecorated(
            child: CustomScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const NeverScrollableScrollPhysics(),
              slivers: sheetSlivers,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------
  Widget _buildBodyBackground({required bool isMobileTitleOnTop}) {
    return Positioned.fill(
      child: FScaffold(
        childPad: widget.childPad,
        child: widget.mobileBody ?? widget.body!,
      ),
    );
  }

  Widget _buildGrabHandle() {
    return const SliverToBoxAdapter(child: _GrabbingWidget());
  }

  Widget? _buildHeaderSliver() {
    if (widget.mobileHeader == null) return null;
    return SliverToBoxAdapter(child: widget.mobileHeader);
  }

  List<Widget> _buildSnapSheetItems() {
    return widget.snapSheet.map((e) => SliverToBoxAdapter(child: e)).toList();
  }

  Widget? _buildManualCollapsibleHeader(double scrollOffset) {
    if (widget.mobileHeader == null) return null;

    // If custom callback provided, use it (callback controls height/visuals)
    if (widget.onHeaderScroll != null) {
      final content = widget.onHeaderScroll!(
        context,
        widget.mobileHeader!,
        scrollOffset,
        _headerHeight,
      );
      final availableHeight = (_headerHeight - scrollOffset).clamp(
        0.0,
        _headerHeight,
      );
      if (availableHeight <= 0) return const SizedBox.shrink();

      return SizedBox(
        height: availableHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: _headerHeight,
            minHeight: _headerHeight,
            child: KeyedSubtree(key: _headerKey, child: content!),
          ),
        ),
      );
    }

    // Default: header stays at full height, no shrinking
    return KeyedSubtree(key: _headerKey, child: widget.mobileHeader!);
  }

  Widget _buildSheetDecorated({required Widget child}) {
    return Blur(
      blurDensity: 10,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: FCard.raw(
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
      desktopWidget: widget.desktopBody ?? widget.body!,
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
