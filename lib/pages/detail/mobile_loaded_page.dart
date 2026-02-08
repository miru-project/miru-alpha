import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/desktop_detail_image_view.dart';
import 'package:miru_app_new/pages/detail/widget/mobile_detail_silverlist.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/widgets/index.dart';

class MobileLoadedPage extends HookConsumerWidget {
  const MobileLoadedPage({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
  });
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final String detailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final favorite = ref.watch(
      detialProvider.select((value) => value.favorite),
    );
    return EasyRefresh(
      header: const ForuiHeader(),
      onRefresh: () async {
        await ref
            .read(detialProvider.notifier)
            .reloadDetail(meta.packageName, detailUrl);
      },
      scrollController: scrollController,
      child: CustomScrollView(
        controller: scrollController,
        cacheExtent: 20,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      height: 180,
                      child: DetailImageView(
                        detail: detail,
                        coverUrl: detail.cover ?? '',
                        child: ImageWidget(
                          imageUrl: detail.cover ?? '',
                          fit: BoxFit.fitHeight,
                          errChild: FCard.raw(
                            child: Center(child: Icon(FIcons.cloudAlert)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(top: 10),
                        child: Column(
                          mainAxisAlignment: .spaceBetween,
                          crossAxisAlignment: .start,
                          children: [
                            FLabel(
                              axis: Axis.vertical,
                              description: Text(
                                "${meta.name} * ${meta.type.name}",
                                style: TextStyle(height: 1.3),
                              ),
                              child: Text(
                                detail.title,
                                style: TextStyle(
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                maxLines: 3,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (favorite != null)
                              Wrap(spacing: 10, children: []),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MobileDetailSilverlist(
            detail: detail,
            meta: meta,
            detailUrl: detailUrl,
          ),
          SliverToBoxAdapter(child: SizedBox(height: 300)),
        ],
      ),
    );
  }
}
