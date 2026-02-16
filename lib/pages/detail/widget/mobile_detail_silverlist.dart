import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/download_button.dart';
import 'package:miru_app_new/provider/detail_page_provider.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';

class MobileDetailSilverlist extends HookConsumerWidget {
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;
  const MobileDetailSilverlist({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReverse = useState(false);
    final epGroupIdx = ref.watch(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    final selectedGpIndex = ref.watch(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    final historyList = ref.watch(detailPr.select((s) => s.historyList));

    if (detail.episodes?.isEmpty ?? true) {
      return SliverToBoxAdapter(child: SizedBox(child: Text('No Episodes')));
    }
    final selectGroup = detail.episodes![epGroupIdx].urls;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: .max,
                children: [
                  Expanded(
                    child: FButton(
                      mainAxisAlignment: .center,
                      onPress: () {},
                      prefix: Icon(FIcons.play),
                      child: Text("Play"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DownloadButton(
                      varient: .secondary,
                      isIcon: false,
                      detail: detail,
                      meta: meta,
                      detailUrl: detailUrl,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            FTileGroup.builder(
              physics: NeverScrollableScrollPhysics(),
              divider: .full,
              label: Row(
                children: [
                  HookConsumer(
                    builder: (context, ref, _) {
                      final selectedEpGroup = ref.watch(
                        detailPageProviderProvider.select((e) => e.epGroupIdx),
                      );
                      final controller = useFPopoverController();

                      return FPopoverMenu.tiles(
                        menuAnchor: .topCenter,
                        menu: [
                          FTileGroup.builder(
                            tileBuilder: (context, idx) {
                              return FTile(
                                onPress: () {
                                  ref
                                      .read(detailPageProviderProvider.notifier)
                                      .setEpGroup(idx);
                                  controller.toggle();
                                },
                                title: Text(detail.episodes![idx].title),
                              );
                            },
                            count: detail.episodes?.length ?? 0,
                          ),
                        ],
                        control: .managed(controller: controller),
                        child: FButton(
                          suffix: Icon(
                            FIcons.chevronsUpDown,
                            color: context.theme.colors.primary,
                          ),
                          mainAxisAlignment: .start,
                          variant: .ghost,
                          onPress: () {
                            controller.toggle();
                          },
                          child: Text(
                            detail.episodes?[selectedEpGroup].title ??
                                "No Episode ",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  FButton.icon(
                    variant: .ghost,
                    onPress: () {
                      isReverse.value = !isReverse.value;
                    },
                    child: isReverse.value
                        ? Icon(FIcons.arrowUpNarrowWide)
                        : Icon(FIcons.arrowDownNarrowWide),
                  ),
                ],
              ),
              tileBuilder: (context, idx) {
                final reverseIdx = isReverse.value
                    ? selectGroup.length - 1 - idx
                    : idx;
                final item = selectGroup[reverseIdx];
                final h = historyList.firstWhereOrNull(
                  (element) => element.url == item.url,
                );
                return FTile(
                  suffix: FButton.icon(
                    variant: .ghost,
                    onPress: () {},
                    child: Icon(FIcons.arrowDownToLine),
                  ),
                  title: Text(item.name),
                  onPress: () {
                    final donwloadList = ref.watch(
                      detailPr.select((value) => value.downloadList),
                    );
                    final savePath = donwloadList
                        .firstWhereOrNull(
                          (element) =>
                              element.key ==
                              "${detail.title}-${detail.episodes?[selectedGpIndex].title}-${item.name}",
                        )
                        ?.savePath;
                    context.push<WatchParams>(
                      "/watch",
                      extra: WatchParams(
                        detailPr: detailPr,
                        name: detail.title,
                        savePath: savePath,
                        detailImageUrl: detail.cover ?? '',
                        selectedEpisodeIndex: idx,
                        selectedGroupIndex: selectedGpIndex,
                        epGroup: detail.episodes,
                        detailUrl: detailUrl,
                        url: item.url,
                        meta: meta,
                        type: meta.type,
                      ),
                    );
                  },
                  subtitle: h != null
                      ? Row(children: [Text(progressIndicator(h))])
                      : SizedBox(),
                );
              },
              count: selectGroup.length,
            ),
          ],
        ),
      ),
    );
  }

  String progressIndicator(History h) {
    final type =
        ExtensionType.values.firstWhereOrNull(
          (e) => e.name == h.type || e.toString() == h.type,
        ) ??
        ExtensionType.unknown;
    switch (type) {
      case ExtensionType.manga:
        return "${h.progress}/${h.totalProgress}";
      case ExtensionType.bangumi:
        final dur = Duration(seconds: h.progress);
        final totalDur = Duration(seconds: h.totalProgress);
        return "${formatDuration(dur)} / ${formatDuration(totalDur)}";
      case ExtensionType.fikushon:
        return "${h.progress}/${h.totalProgress}";
      default:
        return "";
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
