import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

class MiruScaffold extends StatefulWidget {
  const MiruScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.sidebar,
  });
  final PreferredSizeWidget appBar;
  final Widget body;
  final List<Widget>? sidebar;

  @override
  State<MiruScaffold> createState() => _MiruScaffoldState();
}

class _MiruScaffoldState extends State<MiruScaffold> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late Widget body;
    if (widget.sidebar != null) {
      body = SnappingSheet(
        lockOverflowDrag: true,
        snappingPositions: const [
          SnappingPosition.pixels(
            positionPixels: 100,
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
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor.withAlpha(220),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 25,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Blur(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                children: [
                  const _GrabbingWidget(),
                  ...widget.sidebar!,
                ],
              ),
            ),
          ),
        ),
        child: widget.body,
      );
    } else {
      body = widget.body;
    }

    return PlatformWidget(
      mobileWidget: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: widget.appBar,
        body: body,
      ),
      desktopWidget: Scaffold(
        body: Row(
          children: [
            if (widget.sidebar != null)
              SidebarBox(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                  children: widget.sidebar!,
                ),
              ),
            Expanded(
              child: widget.body,
            )
          ],
        ),
      ),
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
