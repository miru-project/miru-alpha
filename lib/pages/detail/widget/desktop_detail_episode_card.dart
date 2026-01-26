import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';

import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';

class DesktopDetailEpisodeCard extends HookWidget {
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final List<ExtensionEpisodeGroup> ep;
  const DesktopDetailEpisodeCard({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.ep,
  });
  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
    return OutterCard(
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
              items: {for (int i = 0; i < ep.length; i++) ep[i].title: i},
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
                    selectedEpisodeIndex: detail.episodes![selected.value].urls
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
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Text(item.name),
              ),
            ),
        ],
      ),
    );
  }
}
