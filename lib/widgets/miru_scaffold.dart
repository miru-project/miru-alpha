import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/provider/main_controller_provider.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

class MiruScaffold extends StatefulHookWidget {
  const MiruScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.sidebar,
    this.snappingSheetController,
    this.mobileHeader,
    this.scrollController,
  });
  final PreferredSizeWidget? appBar;
  final Widget body;
  final List<Widget>? sidebar;
  final ScrollController? scrollController;
  final SnappingSheetController? snappingSheetController;
  final Widget? mobileHeader;
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

  late final MainController c;
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                blurRadius: 25,
                color: Colors.black.withValues(alpha: .2),
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
                if (widget.mobileHeader != null &&
                    !MiruSettings.getSettingSync<bool>(
                      SettingKey.mobiletitleIsonTop,
                    ))
                  widget.mobileHeader!,
                ...widget.sidebar!,
              ],
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          if (MiruSettings.getSettingSync<bool>(SettingKey.mobiletitleIsonTop))
            const SizedBox(height: 50),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      mobileWidget: FScaffold(
        header:
            MiruSettings.getSettingSync<bool>(SettingKey.mobiletitleIsonTop)
                ? FHeader(title: widget.mobileHeader ?? const SizedBox())
                : null,
        child: widget.sidebar == null ? widget.body : sheet(),
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
