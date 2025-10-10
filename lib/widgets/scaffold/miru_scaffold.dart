import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

class MiruScaffold extends StatefulHookConsumerWidget {
  const MiruScaffold({
    super.key,
    // this.appBar,
    required this.body,
    this.snapSheet = const [],
    this.snappingSheetController,
    this.mobileHeader,
    this.scrollController,
  });
  // final PreferredSizeWidget? appBar;
  final Widget body;
  final List<Widget> snapSheet;
  final ScrollController? scrollController;
  final SnappingSheetController? snappingSheetController;
  final Widget? mobileHeader;
  @override
  ConsumerState<MiruScaffold> createState() => _MiruScaffoldState();
  const MiruScaffold.desktop({
    super.key,
    // this.appBar,
    required this.body,
  }) : snapSheet = const [],
       snappingSheetController = null,
       mobileHeader = null,
       scrollController = null;
  const MiruScaffold.mobile({
    super.key,
    // this.appBar,
    required this.body,
    this.snapSheet = const [],
    this.snappingSheetController,
    this.mobileHeader,
    this.scrollController,
  });
}

class _MiruScaffoldState extends ConsumerState<MiruScaffold> {
  late ScrollController scrollController;
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  initState() {
    scrollController = widget.scrollController ?? ScrollController();

    super.initState();
  }

  Widget sheet(bool isMobileTitleOnTop) {
    return Blur(
      blurDensity: 10,
      child: SnappingSheet(
        lockOverflowDrag: true,
        controller: widget.snappingSheetController,
        snappingPositions: const [
          SnappingPosition.pixels(
            positionPixels: 190,
            snappingCurve: Curves.easeOutExpo,
            snappingDuration: Duration(seconds: 1),
            grabbingContentOffset: GrabbingContentOffset.top,
          ),
          SnappingPosition.factor(
            snappingCurve: Curves.elasticOut,
            snappingDuration: Duration(milliseconds: 1750),
            positionFactor: 0.5,
          ),
          SnappingPosition.factor(
            grabbingContentOffset: GrabbingContentOffset.bottom,
            snappingCurve: Curves.easeInExpo,
            snappingDuration: Duration(seconds: 1),
            positionFactor: 0.9,
          ),
        ],
        sheetBelow: SnappingSheetContent(
          childScrollController: scrollController,
          draggable: (details) => true,
          child: FCard.raw(
            style: (style) =>
                FCardStyle.inherit(
                  colors: context.theme.colors,
                  typography: context.theme.typography,
                  style: context.theme.style,
                ).copyWith(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.theme.colors.border),
                    color: context.theme.colors.background.withAlpha(150),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                // enabled: false,
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                  children: [
                    _GrabbingWidget(),
                    if (!isMobileTitleOnTop) widget.mobileHeader!,
                    if (widget.snapSheet.isNotEmpty) ...widget.snapSheet,
                  ],
                ),
              ),
            ),
          ),
        ),
        child: widget.body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobileTitleOnTop = ref.watch(
      applicationControllerProvider.select((value) => value.isMobileTitleOnTop),
    );
    return PlatformWidget(
      mobileWidget: FScaffold(
        // childPad: false,
        header: isMobileTitleOnTop
            ? widget.mobileHeader ?? const SizedBox()
            : null,
        child: (isMobileTitleOnTop && widget.snapSheet.isEmpty)
            ? widget.body
            : sheet(isMobileTitleOnTop),
      ),
      desktopWidget: widget.body,
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
