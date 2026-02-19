import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/desktop_detail_image_view.dart';
import 'package:miru_app_new/pages/detail/widget/mobile_detail_silverlist.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/widgets/index.dart';

class MobileLoadedPage extends HookConsumerWidget {
  const MobileLoadedPage({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final favGrp = ref.watch(detailPr.select((value) => value.favoriateGroup));
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    return EasyRefresh(
      header: const ForuiHeader(),
      onRefresh: () async {
        ref.invalidate(fetchDetailProvider);
        ref.read(fetchDetailProvider(meta.packageName, detailUrl, force: true));
      },
      scrollController: scrollController,
      child: CustomScrollView(
        controller: scrollController,
        cacheExtent: 20,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(8, (8 + padding.top), 8, 0),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    SizedBox(
                      width: 130,
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
                              description: Row(
                                children: [
                                  Icon(switch (meta.type) {
                                    ExtensionType.manga => FIcons.book,
                                    ExtensionType.bangumi => FIcons.film,
                                    ExtensionType.fikushon => FIcons.bookText,
                                    ExtensionType.all => FIcons.rows3,
                                  }),
                                  Text(' • '),
                                  FTappable(
                                    onPress: () {},
                                    child: Row(
                                      children: [
                                        if (meta.icon != null)
                                          ExtendedImage.network(
                                            meta.icon!,
                                            width: 20,
                                            height: 20,
                                          ),
                                        SizedBox(width: 4),
                                        Text(meta.name),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              child: FTappable(
                                onPress: () {},
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
                            ),
                            SizedBox(height: 10),
                            if (favGrp != null)
                              Wrap(
                                spacing: 10,
                                children: favGrp
                                    .map((e) => FBadge(child: Text(e.name)))
                                    .toList(),
                              ),
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
            detailPr: detailPr,
          ),
          SliverToBoxAdapter(child: SizedBox(height: 300)),
        ],
      ),
    );
  }
}
