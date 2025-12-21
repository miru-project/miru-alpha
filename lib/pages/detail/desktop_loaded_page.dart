import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/desktop_detail_item_box.dart';

import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';
import 'package:miru_app_new/widgets/core/inner_card.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';
import 'package:miru_app_new/pages/detail/widget/detail_desktop_box.dart';
import 'package:miru_app_new/widgets/index.dart';

class DesktopLoadedPage extends HookWidget {
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  const DesktopLoadedPage({
    super.key,
    required this.detail,
    required this.meta,
  });
  @override
  Widget build(BuildContext context) {
    final url = detail.cover ?? '';
    final ep = detail.episodes ?? [];
    final selected = useState(0);
    return FScaffold(
      // snapSheet: [],
      child: MiruListView(
        padding: EdgeInsets.all(20),
        children: [
          Flex(
            crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.horizontal,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    DetailDesktopBox(detail: detail, meta: meta, url: url),
                    const SizedBox(height: 30),
                    if (ep.isEmpty)
                      DesktopDetailItemBox(
                        title: 'No Episode',
                        padding: 20,
                        child: SizedBox.expand(),
                      )
                    else
                      OutterCard(
                        title: 'Episodes',
                        trailing: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: FSelect<int>(
                                control: .lifted(
                                  value: selected.value,
                                  onChange: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    selected.value = value;
                                  },
                                ),
                                // initialValue: selected.value,
                                // onChange: (value) {
                                //   if (value == null) {
                                //     return;
                                //   }
                                //   selected.value = value;
                                // },
                                items: {
                                  for (int i = 0; i < ep.length; i++)
                                    ep[i].title: i,
                                },
                              ),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in ep[selected.value].urls)
                              FButton.icon(
                                onPress: () {
                                  context.push(
                                    '/watch',
                                    extra: WatchParams(
                                      name: detail.title,
                                      detailImageUrl: detail.cover ?? '',
                                      selectedEpisodeIndex: detail
                                          .episodes![selected.value]
                                          .urls
                                          .indexOf(item),
                                      selectedGroupIndex: selected.value,
                                      epGroup: detail.episodes,
                                      detailUrl: item.url,
                                      url: item.url,
                                      meta: meta,
                                      type: meta.type,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsetsGeometry.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(item.name),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Spacer(),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    AnimatedBox(
                      child: FCard.raw(
                        child: ClipRRect(
                          // borderRadius: BorderRadius.circular(),
                          child: ImageWidget(imageUrl: url),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedBox(
                      child: InnerCard(
                        title: 'Tracking',
                        child: Center(child: Text("anilist")),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
