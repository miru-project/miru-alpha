import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
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
    final groupName = detail.episodes![epGroupIdx].title;
    final selectGroup = detail.episodes![epGroupIdx].urls;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 20),
        child: Column(
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
                  SizedBox(width: 20),
                  Expanded(
                    child: FButton(
                      style: FButtonStyle.secondary(),
                      onPress: null,
                      prefix: Icon(FIcons.download),
                      child: Text("Download"),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 10),
              child: Consumer(
                builder: (context, ref, _) {
                  final selectedGpIndex = ref.watch(
                    detailPageProviderProvider.select((e) => e.epGroupIdx),
                  );

                  return FTileGroup.builder(
                    divider: .full,
                    // label: FButton(onPress: () {}, child: Text('s')),
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
                              detailUrl: item.url,
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
            ),
          ],
        ),
      ),
    );
  }
}
