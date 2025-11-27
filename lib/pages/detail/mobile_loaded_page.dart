import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/mobile_detail_silverlist.dart';
import 'package:miru_app_new/pages/detail/widget/mobile_detail_tabs.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
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
    return MiruScaffold(
      snapSheet: [
        MobileDetailTabs(detail: detail, meta: meta, detailUrl: detailUrl),
      ],
      mobileHeader: Padding(
        padding: EdgeInsetsGeometry.only(right: 10, left: 5, bottom: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 4),
                child: Icon(
                  FIcons.chevronLeft,
                  size: 28,
                  color: context.theme.colors.primary,
                ),
              ),
            ),
            // FSelectMenuTile(title: Text(detail.episodes.toString()), menu: []),
            Spacer(),
            FButton.icon(
              style: FButtonStyle.ghost(),
              onPress: () {
                context.push(
                  '/mobileWebView',
                  extra: WebviewParam(meta: meta, url: detailUrl),
                );
              },
              child: Icon(
                FIcons.globe,
                size: 28,
                color: context.theme.colors.primary,
              ),
            ),
            FButton.icon(
              style: FButtonStyle.ghost(),
              onPress: () {
                // MobileWebViewPage(url:,)
              },
              child: Icon(
                FIcons.heart,
                size: 28,
                color: context.theme.colors.primary,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
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
                      child: ImageWidget(
                        imageUrl: detail.cover,
                        fit: BoxFit.fitHeight,
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
                            Wrap(
                              spacing: 10,
                              children: [
                                FBadge(child: Text('Favgroup 1')),
                                FBadge(
                                  style: FBadgeStyle.secondary(),
                                  child: Text('Favgroup 2'),
                                ),
                              ],
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
          ),
          SliverToBoxAdapter(child: SizedBox(height: 300)),
        ],
      ),
    );
  }
}
