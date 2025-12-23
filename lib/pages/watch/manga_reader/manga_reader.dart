import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/manag_image.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/manga_episodes.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/manga_page_settings.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/mobile_page_slider.dart';
import 'package:miru_app_new/pages/watch/manga_reader/widget/manga_general_settings.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/manga_reader_provider.dart';
import 'package:miru_app_new/utils/core/log.dart';
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
    // required this.detailImageUrl,
  });
  final ExtensionMangaWatch value;
  final String name;
  final ExtensionMeta meta;
  final String url;
  final EpisodeNotifierProvider epProvider;
  // final String detailImageUrl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final scrollController = useScrollController();

    final epcontroller = ref.read(epProvider);
    final currentEpIndex = epcontroller.selectedEpisodeIndex;
    final epurl = epcontroller.epGroup[epcontroller.selectedGroupIndex].urls;

    final mangaProvider = mangaReaderProvider(
      currentEpIndex,
      epurl.length,
      value,
    );
    final controls = [
      MangaMobilePageSlider(
        epProvider: epProvider,
        mangaProvider: mangaProvider,
      ),
      const SizedBox(height: 10),
      FTabs(
        children: [
          FTabEntry(
            label: Icon(FIcons.tableOfContents),
            child: Center(child: MangaEpisodes(epProvider: epProvider)),
          ),
          FTabEntry(
            label: Icon(FIcons.book),
            child: MangaPageSetting(mangaProvider: mangaProvider),
          ),
          FTabEntry(
            label: Icon(FIcons.alignHorizontalJustifyEnd),
            child: const Center(child: Text('Alignment Settings')),
          ),
          FTabEntry(
            label: Icon(FIcons.settings),
            child: MangaSettingGeneral(mangaProvider: mangaProvider),
          ),
        ],
      ),
    ];
    final readView = _MiruMangaReadView(
      data: value,
      // detailImageUrl: detailImageUrl,
      detailUrl: url,
      epProvider: epProvider,
      mangaProvider: mangaProvider,
      meta: meta,
      name: name,
    );
    return MiruScaffold(
      snapSheet: controls,
      mobileHeader: SnapSheetNested.back(title: name),
      mobileBody: readView,
      desktopBody: Row(
        children: [
          Expanded(child: readView),
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: context.theme.colors.border, width: 1),
              ),
            ),
            width: 400,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FButton.icon(
                        onPress: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(FIcons.chevronLeft),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.xl2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: controls,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiruMangaReadView extends StatefulHookConsumerWidget {
  const _MiruMangaReadView({
    required this.data,
    // required this.detailImageUrl,
    required this.detailUrl,
    required this.epProvider,
    required this.mangaProvider,
    required this.meta,
    required this.name,
  });
  final ExtensionMangaWatch data;
  // final String detailImageUrl;
  final String detailUrl;
  final EpisodeNotifierProvider epProvider;
  final MangaReaderProvider mangaProvider;
  final ExtensionMeta meta;
  final String name;
  @override
  createState() => _MiruMangaReadViewState();
}

class _MiruMangaReadViewState extends ConsumerState<_MiruMangaReadView> {
  // late String _coverUrl;
  @override
  void initState() {
    super.initState();
    // _coverUrl = ref.read(widget.epProvider.notifier).imageUrl;
  }

  // Timer? _debounce;

  // void _saveHistory(MangaReaderState next) async {
  //   final epState = ref.read(widget.epProvider);

  //   final history = History(
  //     package: widget.meta.packageName,
  //     url: widget.detailUrl,
  //     cover: _coverUrl,
  //     type: widget.meta.type.toString().split('.').last,
  //     episodeGroupId: epState.selectedGroupIndex,
  //     episodeId: epState.selectedEpisodeIndex,
  //     title: widget.name,
  //     episodeTitle: epState
  //         .epGroup[epState.selectedGroupIndex]
  //         .urls[epState.selectedEpisodeIndex]
  //         .name,
  //     progress: next.itemPosition.toString(),
  //     totalProgress: next.totalPage.toString(),
  //     date: DateTime.now(),
  //   );
  //   await DatabaseService.putHistory(history);
  //   ref.read(mainPageProvider.notifier).refreshHistory();
  // }

  // @override
  // void dispose() {
  //   // _debounce?.cancel();
  //   _saveHistory(ref.read(widget.mangaProvider));
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // ref.listen(widget.mangaProvider, (previous, next) {
    //   if (previous?.itemPosition != next.itemPosition) {
    //     if (_debounce?.isActive ?? false) _debounce?.cancel();
    //     _debounce = Timer(const Duration(seconds: 2), () {
    //       _saveHistory(next);
    //     });
    //   }
    // });

    final item = widget.data.urls;

    final mode = ref.watch(widget.mangaProvider.select((e) => e.readMode));
    final c = ref.read(widget.mangaProvider.notifier);
    switch (mode) {
      case MangaReadMode.rightToLeft || MangaReadMode.standard:
        return ExtendedImageGesturePageView.builder(
          reverse: mode == MangaReadMode.rightToLeft,
          controller: c.pageController,
          itemBuilder: (context, index) => MangaImage(imageUrl: item[index]),
          itemCount: item.length,
          onPageChanged: (index) {
            c.setPageNumber(index);
          },
        );
      case MangaReadMode.webTonn:
        final List<int> pointer = [];
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            pointer.add(event.pointer);
            if (pointer.length == 2) {
              logger.info('zoom');
              ref.read(widget.mangaProvider.notifier).changeZoomMode(true);
            }
          },
          onPointerUp: (event) {
            // if (pointer.length != 1) return;
            ref.read(widget.mangaProvider.notifier).changeZoomMode(false);
            logger.info('end  zoom');
            pointer.remove(event.pointer);
            // if (pointer.length == 1) {}
          },
          child: Consumer(
            builder: (context, ref, child) {
              final isZoom = ref.watch(
                widget.mangaProvider.select((e) => e.isZoom),
              );
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.1,
                    maxScale: 1.6,
                    scaleEnabled: isZoom,
                    child: ScrollablePositionedList.builder(
                      itemPositionsListener: c.itemPositionsListener,
                      scrollOffsetController: c.scrollOffsetController,
                      scrollOffsetListener: c.scrollOffsetListener,
                      itemScrollController: c.itemScrollController,
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      physics: isZoom
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      itemCount: item.length,
                      itemBuilder: (context, index) {
                        return MangaImage(imageUrl: item[index]);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}
