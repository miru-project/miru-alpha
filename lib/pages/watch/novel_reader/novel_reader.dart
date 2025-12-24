import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/watch/novel_reader/widget/novel_page_setting.dart';
import 'package:miru_app_new/pages/watch/novel_reader/widget/novel_page_slider.dart';
import 'package:miru_app_new/pages/watch/novel_reader/widget/novel_setting_general.dart';
import 'package:miru_app_new/pages/watch/widget/episodes_select.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/novel_reader_provider.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MiruNovelReader extends StatefulHookConsumerWidget {
  const MiruNovelReader({
    super.key,
    required this.value,
    required this.name,
    required this.meta,
    required this.url,
    required this.epProvider,
    required this.detailImageUrl,
  });
  final ExtensionFikushonWatch value;
  final String name;
  final ExtensionMeta meta;
  final String url;
  final EpisodeNotifierProvider epProvider;
  final String detailImageUrl;
  @override
  createState() => _MiruNovelReaderState();
}

class _MiruNovelReaderState extends ConsumerState<MiruNovelReader> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = novelReaderProvider(widget.value.content);
    return MiruScaffold(
      scrollController: scrollController,
      mobileHeader: SnapSheetNested.back(title: widget.name),
      snapSheet: <Widget>[
        NovelPageSlider(
          epProvider: widget.epProvider,
          novelProvider: novelProvider,
        ),
        FTabs(
          children: [
            FTabEntry(
              label: Icon(FIcons.tableOfContents),
              child: Center(
                child: EpisodeSelect(epProvider: widget.epProvider),
              ),
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
      body: _MiruNovelReadView(
        data: widget.value,
        meta: widget.meta,
        imgUrl: widget.detailImageUrl,
        detailUrl: widget.url,
        epProvider: widget.epProvider,
        novelProvider: novelProvider,
      ),
    );
  }
}

class _MiruNovelReadView extends StatefulHookConsumerWidget {
  const _MiruNovelReadView({
    required this.data,
    required this.meta,
    required this.imgUrl,
    required this.detailUrl,
    required this.epProvider,
    required this.novelProvider,
  });
  final ExtensionFikushonWatch data;
  final ExtensionMeta meta;
  final String imgUrl;
  final String detailUrl;
  final EpisodeNotifierProvider epProvider;
  final NovelReaderProvider novelProvider;

  @override
  createState() => _MiruNovelReadViewState();
}

class _MiruNovelReadViewState extends ConsumerState<_MiruNovelReadView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(widget.novelProvider.notifier)
        ..setContent(widget.data.content)
        ..initListener();

      ref
          .read(widget.epProvider.notifier)
          .putInformation(
            widget.meta.type,
            widget.meta.packageName,
            widget.imgUrl,
            widget.detailUrl,
          );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.data.content;
    final c = ref.watch(widget.novelProvider.notifier);
    return ScrollablePositionedList.builder(
      scrollOffsetController: c.scrollOffsetController,
      itemScrollController: c.itemScrollController,
      itemPositionsListener: c.itemPositionsListener,
      scrollOffsetListener: c.scrollOffsetListener,
      itemCount: item.length,
      itemBuilder: (context, index) {
        return SelectableText.rich(
          TextSpan(
            text: item[index],
            style: const TextStyle(fontSize: 20, height: 1.5),
          ),
        );
      },
    );
  }
}
