import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class MiruScaffold extends StatefulHookConsumerWidget {
  const MiruScaffold({
    super.key,
    this.desktopBody,
    this.mobileBody,
    this.body,
    this.snapSheet = const [],
    this.sheetController,
    this.mobileHeader,
    this.scrollController,
    this.resizeToAvoidBottomInset = false,
    this.snappingOffsets,
    this.childPad = true,
  }) : assert(desktopBody != null || mobileBody != null || body != null);

  final List<Widget> snapSheet;
  final ScrollController? scrollController;
  final SheetController? sheetController;
  final Widget? mobileHeader;
  final bool resizeToAvoidBottomInset;
  final Widget? mobileBody;
  final Widget? desktopBody;
  final Widget? body;
  final bool childPad;

  /// Custom snap offsets. Defaults to [190px, 50%, 100%].
  final List<SheetOffset>? snappingOffsets;

  @override
  ConsumerState<MiruScaffold> createState() => _MiruScaffoldState();
}

class _MiruScaffoldState extends ConsumerState<MiruScaffold> {
  late ScrollController scrollController;
  late SheetController _sheetController;

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

  List<SheetOffset> get _defaultSnappingOffsets => const [
    AbsoluteSheetOffset(190),
    ProportionalToViewportSheetOffset(0.5),
    ProportionalToViewportSheetOffset(1.0),
  ];

  // mobile sheet
  Widget _buildSheet(bool isMobileTitleOnTop) {
    final snaps = widget.snappingOffsets ?? _defaultSnappingOffsets;
    return Stack(
      children: [
        // Background body fills all available space
        Positioned.fill(
          child: FScaffold(
            childPad: widget.childPad,
            child: widget.mobileBody ?? widget.body!,
          ),
        ),
        SheetViewport(
          child: Sheet(
            controller: _sheetController,
            initialOffset: snaps.first,
            snapGrid: MultiSnapGrid(snaps: snaps),
            physics: const BouncingSheetPhysics(),
            shrinkChildToAvoidDynamicOverlap: true,
            child: SheetKeyboardDismissible(
              dismissBehavior: const DragDownSheetKeyboardDismissBehavior(),
              child: Blur(
                blurDensity: 10,
                child: FCard.raw(
                  style: .delta(
                    decoration: .delta(
                      color: context.theme.colors.background.withAlpha(150),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.compose(
                        outer: ColorFilter.mode(
                          context.theme.colors.barrier,
                          BlendMode.srcOver,
                        ),
                        inner: ImageFilter.compose(
                          outer: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          inner: ColorFilter.mode(
                            context.theme.colors.primary.withAlpha(25),
                            BlendMode.srcOver,
                          ),
                        ),
                      ),
                      child: CustomScrollView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const NeverScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _GrabbingWidget()),
                          if (!isMobileTitleOnTop &&
                              widget.mobileHeader != null)
                            SliverToBoxAdapter(child: widget.mobileHeader!),
                          const SliverToBoxAdapter(child: SizedBox(height: 10)),
                          if (widget.snapSheet.isNotEmpty)
                            ...widget.snapSheet.map(
                              (e) => SliverToBoxAdapter(child: e),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobileTitleOnTop = ref.watch(
      applicationControllerProvider.select((value) => value.isMobileTitleOnTop),
    );
    return PlatformWidget(
      mobileWidget: FTheme(
        data: ref.watch(applicationControllerProvider).themeData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobileTitleOnTop)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: widget.mobileHeader,
              ),
            Expanded(
              child: (isMobileTitleOnTop && widget.snapSheet.isEmpty)
                  ? FScaffold(
                      childPad: widget.childPad,
                      child: widget.mobileBody ?? widget.body!,
                    )
                  : _buildSheet(isMobileTitleOnTop),
            ),
          ],
        ),
      ),
      desktopWidget: widget.desktopBody ?? widget.body!,
    );
  }
}

class _GrabbingWidget extends StatelessWidget {
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
