import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/download_button.dart';
import 'package:miru_app_new/provider/detail_page_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';

class MobileDetailSilverlist extends ConsumerWidget {
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  const MobileDetailSilverlist({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epGroupIdx = ref.watch(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    if (detail.episodes?.isEmpty ?? true) {
      return SliverToBoxAdapter(child: SizedBox(child: Text('No Episodes')));
    }
    // final groupName = detail.episodes![epGroupIdx].title;
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
                      style: FButtonStyle.secondary(),
                      isIcon: false,
                      detail: detail,
                      meta: meta,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            Consumer(
              builder: (context, ref, _) {
                final selectedGpIndex = ref.watch(
                  detailPageProviderProvider.select((e) => e.epGroupIdx),
                );

                return FTileGroup.builder(
                  physics: NeverScrollableScrollPhysics(),
                  divider: .full,
                  label: Row(
                    children: [
                      HookConsumer(
                        builder: (context, ref, _) {
                          final selectedEpGroup = ref.watch(
                            detailPageProviderProvider.select(
                              (e) => e.epGroupIdx,
                            ),
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
                                          .read(
                                            detailPageProviderProvider.notifier,
                                          )
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
                              style: FButtonStyle.ghost(),
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
                      Icon(FIcons.aArrowDown),
                    ],
                  ),
                  tileBuilder: (context, idx) {
                    final item = selectGroup[idx];
                    return FTile(
                      title: Text(item.name),
                      onPress: () {
                        context.push<WatchParams>(
                          "/watch",
                          extra: WatchParams(
                            name: detail.title,
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
                      subtitle: Text("Unknown page / ${item.url}"),
                    );
                  },
                  count: selectGroup.length,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
