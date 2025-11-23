import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/manag_image.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/mobile_page_slider.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/settings.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/manga_reader_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MiruMangaReader extends HookConsumerWidget {
  const MiruMangaReader({
    super.key,
    required this.value,
    required this.name,
    required this.meta,
    required this.url,
    required this.epProvider,
    required this.detailImageUrl,
  });
  final ExtensionMangaWatch value;
  final String name;
  final ExtensionMeta meta;
  final String url;
  final EpisodeNotifierProvider epProvider;
  final String detailImageUrl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final List<int> pointer = [];
    final isZoom = useState(false);
    final epcontroller = ref.read(epProvider);
    final currentEpIndex = epcontroller.selectedEpisodeIndex;
    final epurl = epcontroller.epGroup[epcontroller.selectedGroupIndex].urls;

    final managaProvider = mangaReaderProvider(
      currentEpIndex,
      epurl.length,
      value,
    );
    return MiruScaffold(
      scrollController: scrollController,
      mobileHeader: SnapSheetNested.back(title: name),
      snapSheet: <Widget>[
        if (DeviceUtil.getWidth(context) < 800)
          //mobile
          // Text(
          //   epState.name,
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          // ),
          // FButton(
          //   style: FButtonStyle.ghost(),
          //   onPress: () {
          //     Navigator.of(context).pop();
          //   },
          //   child: Row(
          //     children: [
          //       const Icon(FIcons.chevronLeft),
          //       const SizedBox(width: 10),
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               epState.name,
          //               maxLines: 1,
          //               overflow: TextOverflow.ellipsis,
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 20,
          //               ),
          //             ),
          //             Text(epState.epGroup[epState.selectedGroupIndex].title),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 10),
        MangaMobilePageSlider(
          epProvider: epProvider,
          mangaProvider: managaProvider,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: FTabs(
            children: [
              FTabEntry(
                label: Icon(FIcons.tableOfContents),
                child: const Center(child: Text('Chapter Settings')),
              ),
              FTabEntry(
                label: Icon(FIcons.book),
                child: const Center(child: Text('Page Settings')),
              ),
              FTabEntry(
                label: Icon(FIcons.alignHorizontalJustifyEnd),
                child: const Center(child: Text('Alignment Settings')),
              ),
              FTabEntry(
                label: Icon(FIcons.settings),
                child: MangaSettingGeneral(mangaProvider: managaProvider),
              ),
            ],
          ),
        ),
      ],
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          pointer.add(event.pointer);
          if (pointer.length == 2) {
            isZoom.value = true;
          }
        },
        onPointerUp: (event) {
          pointer.remove(event.pointer);
          isZoom.value = false;
        },
        child: _MiruMangaReadView(
          data: value,
          detailImageUrl: detailImageUrl,
          detailUrl: url,
          epProvider: epProvider,
          mangaProvider: managaProvider,
        ),
      ),
    );
  }
}

class _MiruMangaReadView extends StatefulHookConsumerWidget {
  const _MiruMangaReadView({
    required this.data,
    required this.detailImageUrl,
    required this.detailUrl,
    required this.epProvider,
    required this.mangaProvider,
  });
  final ExtensionMangaWatch data;
  final String detailImageUrl;
  final String detailUrl;
  final EpisodeNotifierProvider epProvider;
  final MangaReaderProvider mangaProvider;
  @override
  createState() => _MiruMangaReadViewState();
}

class _MiruMangaReadViewState extends ConsumerState<_MiruMangaReadView> {
  @override
  Widget build(BuildContext context) {
    final item = widget.data.urls;
    final List<int> pointer = [];
    final isZoom = useState(false);
    final c = ref.read(widget.mangaProvider.notifier);
    final mode = ref.watch(widget.mangaProvider.select((e) => e.readMode));
    // Future.microtask(() {
    //   c.reattach();
    // });

    switch (mode) {
      case MangaReadMode.rightToLeft || MangaReadMode.standard:
        return PageView.builder(
          controller: c.pageController,
          itemBuilder: (context, index) => InteractiveViewer(
            panAxis: PanAxis.free,
            onInteractionStart: (details) {
              debugPrint('start');
            },
            scaleEnabled: isZoom.value,
            child: MangaImage(imageUrl: item[index]),
          ),
        );
      case MangaReadMode.webTonn:
        return InteractiveViewer(
          panAxis: PanAxis.free,
          onInteractionStart: (details) {
            debugPrint('start');
          },
          scaleEnabled: isZoom.value,
          child: ScrollablePositionedList.builder(
            padding: const EdgeInsets.only(bottom: 190),
            physics: isZoom.value ? const NeverScrollableScrollPhysics() : null,
            itemScrollController: c.itemScrollController,
            scrollOffsetController: c.scrollOffsetController,
            scrollOffsetListener: c.scrollOffsetListener,
            itemPositionsListener: c.itemPositionsListener,
            itemCount: item.length,
            itemBuilder: (context, index) {
              return MangaImage(imageUrl: item[index]);
            },
          ),
        );
    }
  }
}
