import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/desktop_detail_episode_card.dart';
import 'package:miru_app_new/provider/detial_provider.dart';

import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';
import 'package:miru_app_new/pages/detail/widget/index.dart';
import 'package:miru_app_new/widgets/index.dart';

class DesktopLoadedPage extends HookWidget {
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
  Widget build(BuildContext context) {
    final coverUrl = detail.cover ?? '';
    final ep = detail.episodes ?? [];

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
                      if (ep.isEmpty)
                        DesktopDetailItemBox(
                          title: 'No Episode',
                          padding: 20,
                          child: SizedBox.expand(),
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
                            title: 'Tracking',
                            trailing: FButton(
                              variant: .ghost,
                              onPress: () {},
                              child: Text('Sync'),
                            ),
                            child: Center(child: Text("anilist")),
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
