import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/mobile_detail_tabs.dart';
import 'package:miru_app_new/provider/detail_page_provider.dart';
import 'package:miru_app_new/utils/router/router_util.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
import 'package:miru_app_new/widgets/index.dart';

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
      return SliverToBoxAdapter(child: Container(child: Text('No Episodes')));
    }
    final groupName = detail.episodes![epGroupIdx].title;
    final selectGroup = detail.episodes![epGroupIdx].urls;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 10),
        child: Column(
          children: [
            FButton(onPress: () {}, child: Text(groupName)),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 10),
              child: FTileGroup.builder(
                tileBuilder: (context, idx) {
                  final item = selectGroup[idx];
                  return FTile(title: Text(item.name), onPress: () {});
                },

                count: selectGroup.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
