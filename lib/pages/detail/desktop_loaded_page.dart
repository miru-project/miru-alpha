import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/pages/detail/widget/desktop_tracking_box.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/pages/detail/widget/desktop_detail_episode_card.dart';
import 'package:miru_alpha/provider/detial_provider.dart';

import 'package:miru_alpha/widgets/amination/animated_box.dart';
import 'package:miru_alpha/widgets/core/outter_card.dart';
import 'package:miru_alpha/pages/detail/widget/index.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/tracking/anilist_track_page_provider.dart';

class DesktopLoadedPage extends HookConsumerWidget {
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;
  const DesktopLoadedPage({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl = detail.cover ?? '';
    final ep = detail.episodes ?? [];

    final detailState = ref.watch(detailPr);
    final anilistIdStr = detailState.detailInfo?.trackIds['ANILIST'];
    final anilistId = anilistIdStr != null ? int.tryParse(anilistIdStr) : null;
    final anilistTrackState = anilistId != null ? ref.watch(anilistTrackPageProvider(anilistId)) : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth < 1100;
        return MiruListView(
          padding: EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      DetailDesktopBox(
                        isTablet: isTablet,
                        detail: detail,
                        detailPr: detailPr,
                        meta: meta,
                        detailUrl: detailUrl,
                        coverUrl: coverUrl,
                      ),
                      const SizedBox(height: 30),
                      DetailTrackingBox(
                        detailPr: detailPr,
                        mediaTitle: detail.title,
                      ),
                      const SizedBox(height: 30),
                      if (ep.isEmpty)
                        DesktopDetailItemBox(
                          title: 'no_episodes_found'.i18n,
                          padding: 20,
                          child: SizedBox(),
                        )
                      else
                        DesktopDetailEpisodeCard(
                          detail: detail,
                          ep: ep,
                          meta: meta,
                          detailPr: detailPr,
                          detailUrl: detailUrl,
                        ),
                    ],
                  ),
                ),
                // Handle view for screen size that beteen desktop and mobile usually for tablet
                if (!isTablet) ...[
                  Spacer(),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        DetailImageView(detail: detail, coverUrl: coverUrl),
                        const SizedBox(height: 30),
                        AnimatedBox(
                          child: OutterCard(
                            title: 'tracking.name'.i18n,
                            trailing: FButton(
                              variant: .ghost,
                              onPress: () {
                                context.push(
                                  '/anilistSearch',
                                  extra: AnilistSearchParam(
                                    title: detail.title,
                                    type: meta.type,
                                    detailUrl: detailUrl,
                                    package: meta.packageName,
                                  ),
                                );
                              },
                              child: Text('sync'.i18n),
                            ),
                            child: Center(
                              child: anilistTrackState != null && anilistTrackState.entry != null
                                  ? Text(
                                      '${'anilist'.i18n}: ${anilistTrackState.progress} / ${anilistTrackState.score}',
                                      style: context.theme.typography.sm,
                                    )
                                  : Text("anilist".i18n),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 40),
          ],
        );
      },
    );
  }
}
