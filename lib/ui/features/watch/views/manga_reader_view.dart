import 'package:extended_image/extended_image.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manag_image.dart';
import 'package:miru_alpha/ui/features/watch/widget/episodes_select.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manga_page_settings.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manga_page_slider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MangaReaderView extends HookConsumerWidget {
  const MangaReaderView({
    super.key,
    required this.value,
    required this.name,
    required this.meta,
    required this.url,
    required this.epProvider,
  }) : localPath = null;

  const MangaReaderView.local({
    super.key,
    required this.name,
    required this.meta,
    required this.epProvider,
    required this.localPath,
  }) : url = null,
       value = null;

  final ExtensionMangaWatch? value;
  final String name;
  final ExtensionMeta meta;
  final String? url;
  final EpisodeNotifierProvider epProvider;
  final String? localPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epcontroller = ref.watch(epProvider);
    final currentEpIndex = epcontroller.selectedEpisodeIndex;
    final epurl = epcontroller.epGroup[epcontroller.selectedGroupIndex].urls;

    final mangaProvider = mangaReaderProvider(
      currentEpIndex,
      epurl.length,
      value,
    );
    final controls = [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: MangaPageSlider(
          epProvider: epProvider,
          mangaProvider: mangaProvider,
        ),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: FTabs(
          children: [
            FTabEntry(
              label: Icon(FLucideIcons.tableOfContents),
              child: EpisodeSelect(epProvider: epProvider),
            ),
            FTabEntry(
              label: Icon(FLucideIcons.book),
              child: MangaPageSetting(mangaProvider: mangaProvider),
            ),
            FTabEntry(
              label: Icon(FLucideIcons.alignHorizontalJustifyEnd),
              child: Center(
                child: Text('reader.manga.alignment_settings.name'.i18n),
              ),
            ),
          ],
        ),
      ),
    ];
    final readView = _MangaReadView(
      data: value,
      epProvider: epProvider,
      mangaProvider: mangaProvider,
      meta: meta,
      name: name,
    );
    return MiruScaffold.mobile(
      childPad: false,
      snapSheet: controls,
      sliverHeaders: [
        StaticSliverHeaderDelegate(
          maxExtent: 50,
          child: SnapSheetNested.back(title: name),
        ),
      ],
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
                        child: Icon(FLucideIcons.chevronLeft),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.xl2.copyWith(
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

class _MangaReadView extends HookConsumerWidget {
  const _MangaReadView({
    required this.data,
    required this.epProvider,
    required this.mangaProvider,
    required this.meta,
    required this.name,
  });
  final ExtensionMangaWatch? data;
  final EpisodeNotifierProvider epProvider;
  final MangaReaderProvider mangaProvider;
  final ExtensionMeta meta;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = data?.urls;
    final mangaState = ref.watch(mangaProvider);
    final mangaNotifier = ref.read(mangaProvider.notifier);
    final mode = mangaState.readMode;

    switch (mode) {
      case MangaReadMode.rightToLeft || MangaReadMode.standard:
        return ExtendedImageGesturePageView.builder(
          reverse: mode == MangaReadMode.rightToLeft,
          controller: mangaNotifier.pageController,
          itemBuilder: (context, index) =>
              MangaImage(imageUrl: item?[index] ?? ''),
          itemCount: item?.length,
          onPageChanged: (index) {
            mangaNotifier.setPageNumber(index);
          },
        );
      case MangaReadMode.webToon:
        final List<int> pointer = [];
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            pointer.add(event.pointer);
            if (pointer.length == 2) {
              logger.info('zoom');
              mangaNotifier.changeZoomMode(true);
            }
          },
          onPointerUp: (event) {
            mangaNotifier.changeZoomMode(false);
            logger.info('end  zoom');
            pointer.remove(event.pointer);
          },
          child: Consumer(
            builder: (context, ref, child) {
              final isZoom = mangaState.isZoom;
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.1,
                    maxScale: 1.6,
                    scaleEnabled: isZoom,
                    child: ScrollablePositionedList.builder(
                      itemPositionsListener:
                          mangaNotifier.itemPositionsListener,
                      scrollOffsetController:
                          mangaNotifier.scrollOffsetController,
                      scrollOffsetListener: mangaNotifier.scrollOffsetListener,
                      itemScrollController: mangaNotifier.itemScrollController,
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      physics: isZoom
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      itemCount: item?.length ?? 0,
                      itemBuilder: (context, index) {
                        return MangaImage(imageUrl: item?[index] ?? '');
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
