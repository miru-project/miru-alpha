import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';

class DesktopDetailEpisodeCard extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(0);
    final historyList = ref.watch(
      detialProvider.select((value) => value.historyList),
    );

    return OutterCard(
      title: 'Episodes',
      trailing: Row(
        children: [
          SizedBox(
            width: 180,
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
            Builder(
              builder: (context) {
                final h = historyList.firstWhereOrNull(
                  (element) => element.url == item.url,
                );
                final isWatched =
                    h != null && (h.progress / h.totalProgress) >= 0.95;
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.theme.colors.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FButton.raw(
                    variant: .outline,
                    onPress: () {
                      final donwloadList = ref.watch(
                        detialProvider.select((value) => value.downloadList),
                      );
                      final savePath = donwloadList
                          .firstWhereOrNull(
                            (element) =>
                                element.key ==
                                "${detail.title}-${ep[selected.value].title}-${item.name}",
                          )
                          ?.savePath;
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
                          detailUrl: detailUrl,
                          url: item.url,
                          savePath: savePath,
                          meta: meta,
                          type: meta.type,
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isWatched
                                  ? context.theme.colors.mutedForeground
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SizedBox(
                            height: 3,
                            child: FDeterminateProgress(
                              value:
                                  (h?.progress ?? 0).toDouble() /
                                  (h?.totalProgress ?? 1).toDouble(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
