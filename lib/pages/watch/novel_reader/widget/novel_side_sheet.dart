import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/pages/watch/novel_reader/widget/novel_page_setting.dart';
import 'package:miru_app_new/pages/watch/novel_reader/widget/novel_page_slider.dart';
import 'package:miru_app_new/pages/watch/novel_reader/widget/novel_setting_general.dart';
import 'package:miru_app_new/pages/watch/widget/episodes_select.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/novel_reader_provider.dart';

class NovelSideSheet extends StatelessWidget {
  const NovelSideSheet({
    super.key,
    required this.novelProvider,
    required this.epProvider,
  });
  final NovelReaderProvider novelProvider;
  final EpisodeNotifierProvider epProvider;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        NovelPageSlider(epProvider: epProvider, novelProvider: novelProvider),
        FTabs(
          children: [
            FTabEntry(
              label: Icon(FIcons.tableOfContents),
              child: Center(child: EpisodeSelect(epProvider: epProvider)),
            ),
            FTabEntry(label: Icon(FIcons.book), child: NovelPageSetting()),
            FTabEntry(
              label: Icon(FIcons.alignHorizontalJustifyEnd),
              child: const Center(child: Text('Alignment Settings')),
            ),
            FTabEntry(
              label: Icon(FIcons.settings),
              child: NovelSettingGeneral(),
            ),
          ],
        ),
      ],
    );
  }
}
