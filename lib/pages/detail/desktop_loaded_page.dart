import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

import 'package:miru_alpha/widgets/amination/animated_box.dart';
import 'package:miru_alpha/pages/detail/widget/index.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    final detialState = ref.watch(detailPr);
    final anilistTracker = detialState.detailInfo?.trackers
        .where((t) => t.provider.toLowerCase() == 'anilist')
        .firstOrNull;

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

                      AnimatedBox(
                        child: DetailTrackingBox(
                          detailPr: detailPr,
                          mediaTitle: detail.title,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (ep.isEmpty)
                        DesktopDetailItemBox(
                          title: 'media.no_episodes_found'.i18n,
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
                          child: FTileGroup(
                            label: Padding(
                              padding: .only(left: 5, bottom: 10),
                              child: Text(
                                'tracking.name'.i18n,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            children: [
                              FTile(
                                prefix: SvgPicture.asset(
                                  'assets/svg/anilist.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: .mode(
                                    context.theme.colors.foreground,
                                    .srcIn,
                                  ),
                                ),
                                title: Text('tracking.anilist.name'.i18n),
                                suffix: Text(
                                  anilistTracker != null
                                      ? '${AniListProvider.mediaListStatusToTranslate(AniListProvider.stringToMediaListStatus(anilistTracker.status), meta.type == ExtensionType.bangumi ? AnilistType.anime : AnilistType.manga)} • ${anilistTracker.progress}${anilistTracker.hasTotalProgress() && anilistTracker.totalProgress != 0 ? ' / ${anilistTracker.totalProgress}' : ''}'
                                      : 'None',
                                  style: TextStyle(
                                    color: context.theme.colors.mutedForeground,
                                    fontSize: 12,
                                  ),
                                ),
                                onPress: () {
                                  if (anilistTracker != null) {
                                    showFDialog(
                                      context: context,
                                      builder: (context, style, animation) =>
                                          AnilistTrackingDialog(
                                            param: AnilistProgressParam(
                                              mediaId: int.parse(
                                                anilistTracker.trackerId,
                                              ),
                                              detailUrl: detailUrl,
                                              package: meta.packageName,
                                              isLinked: true,
                                            ),
                                            detailPr: detailPr,
                                            style: style,
                                            animation: animation,
                                          ),
                                    );
                                    return;
                                  }
                                  showFDialog(
                                    context: context,
                                    builder: (context, style, animation) =>
                                        AnilistSearchDialog(
                                          title: detail.title,
                                          type: meta.type,
                                          detailUrl: detailUrl,
                                          package: meta.packageName,
                                          detailPr: detailPr,
                                          animation: animation,
                                          style: style,
                                        ),
                                  );
                                },
                              ),
                            ],
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
