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
    this.desktopBody,
    this.mobileBody,
    this.body,
    this.snapSheet = const [],
    this.snappingSheetController,
    this.mobileHeader,
    this.scrollController,
    this.resizeToAvoidBottomInset = false,
    this.snappingPositions,
    this.childPad = true,
  }) : assert(desktopBody != null || mobileBody != null || body != null);
  final List<Widget> snapSheet;
  final ScrollController? scrollController;
  final SnappingSheetController? snappingSheetController;
  final Widget? mobileHeader;
  final bool resizeToAvoidBottomInset;
  final Widget? mobileBody;
  final Widget? desktopBody;
  final Widget? body;
  final bool childPad;
  final List<SnappingPosition>? snappingPositions;
  @override
  ConsumerState<MiruScaffold> createState() => _MiruScaffoldState();
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

  List<SnappingPosition> get _defaultSheetPosition => const [
    SnappingPosition.pixels(
      positionPixels: 190,
      snappingCurve: Curves.easeOutExpo,
      snappingDuration: Duration(milliseconds: 50),
      grabbingContentOffset: GrabbingContentOffset.top,
    ),
    SnappingPosition.factor(
      snappingCurve: Curves.elasticOut,
      snappingDuration: Duration(milliseconds: 50),
      positionFactor: 0.5,
    ),
    SnappingPosition.factor(
      grabbingContentOffset: GrabbingContentOffset.bottom,
      snappingCurve: Curves.easeInExpo,
      snappingDuration: Duration(milliseconds: 50),
      positionFactor: 0.9,
    ),
  ];
  // mobile sheet
  Widget sheet(bool isMobileTitleOnTop) {
    return Blur(
      blurDensity: 10,
      child: SnappingSheet(
        lockOverflowDrag: true,
        controller: widget.snappingSheetController,
        snappingPositions: widget.snappingPositions ?? _defaultSheetPosition,
        sheetBelow: SnappingSheetContent(
          childScrollController: scrollController,
          draggable: (details) => true,
          child: FCard.raw(
            style: .delta(
              decoration: .delta(
                color: context.theme.colors.background.withAlpha(150),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                // enabled: false,
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                  tileMode: TileMode.mirror,
                ),
                child: ListView(
                  shrinkWrap: true,
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                  children: [
                    _GrabbingWidget(),
                    if (!isMobileTitleOnTop && widget.mobileHeader != null)
                      widget.mobileHeader!,
                    SizedBox(height: 10),
                    if (widget.snapSheet.isNotEmpty) ...widget.snapSheet,
                  ],
                ),
              ),
            ),
          ),
        ),
        child: FScaffold(
          childPad: widget.childPad,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          child: widget.mobileBody ?? widget.body!,
        ),
      ),
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
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewInsets.top + 20,
                  left: 12,
                  right: 12,
                ),
                child: widget.mobileHeader,
              ),
            Expanded(
              child: (isMobileTitleOnTop && widget.snapSheet.isEmpty)
                  ? FScaffold(
                      childPad: widget.childPad,
                      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                      child: widget.mobileBody ?? widget.body!,
                    )
                  : sheet(isMobileTitleOnTop),
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
