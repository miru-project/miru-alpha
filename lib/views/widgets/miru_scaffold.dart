import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

class MiruScaffold extends StatefulHookWidget {
  const MiruScaffold(
      {super.key,
      this.appBar,
      required this.body,
      this.sidebar,
      this.snappingSheetController,
      this.scrollController});
  final PreferredSizeWidget? appBar;
  final Widget body;
  final List<Widget>? sidebar;
  final ScrollController? scrollController;
  final SnappingSheetController? snappingSheetController;
  @override
  State<MiruScaffold> createState() => _MiruScaffoldState();
}

class _MiruScaffoldState extends State<MiruScaffold> {
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

  Widget sheet() {
    return SnappingSheet(
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
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(220),
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
                _GrabbingWidget(),
                ...widget.sidebar!,
              ],
            ),
          ),
        ),
      ),
      child: widget.body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      mobileWidget: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: widget.appBar,
        body: widget.sidebar == null ? widget.body : sheet(),
      ),
      desktopWidget: Scaffold(
        body: Row(
          children: [
            if (widget.sidebar != null)
              SidebarBox(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
