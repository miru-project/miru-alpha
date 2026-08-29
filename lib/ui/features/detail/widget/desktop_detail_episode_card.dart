import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/core/outter_card.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_section.dart';

/// `proto.Detail.episodes` is stored as JSON, unlike the proto field that
/// `Detail.fromExtensionDetail` takes directly. Decode it for the selectors.
List<ExtensionEpisodeGroup> _episodesFromState(DetialState s) {
  final proto = s.detailInfo;
  if (proto != null && proto.hasEpisodes()) {
    return (jsonDecode(proto.episodes) as List)
        .map((e) => ExtensionEpisodeGroup()..mergeFromProto3Json(e))
        .toList();
  }
  return const <ExtensionEpisodeGroup>[];
}

class DesktopDetailEpisodeCard extends HookConsumerWidget {
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final List<ExtensionEpisodeGroup> ep;
  final DetialProvider detailPr;
  const DesktopDetailEpisodeCard({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.ep,
    required this.detailPr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(0);
    final historyList = ref.watch(
      detailPr.select((value) => value.historyList),
    );

    return AnimatedBox(
      child: OutterCard(
        title: 'media.episodes'.i18n,
        trailing: Row(
          children: [
            DetailSection<List<ExtensionEpisodeGroup>>(
              detailPr: detailPr,
              selector: _episodesFromState,
              skeletonBuilder: (_) => const SizedBox(
                width: 180,
                height: 40,
                child: DetailSkeleton(),
              ),
              content: (_, episodes) => SizedBox(
                width: 180,
                child: FSelect<int>(
                  control: FSelectControl.lifted(
                    value: selected.value,
                    onChange: (value) {
                      if (value == null) {
                        return;
                      }
                      selected.value = value;
                    },
                  ),
                  items: {
                    for (int i = 0; i < episodes.length; i++)
                      episodes[i].title: i,
                  },
                ),
              ),
            ),
          ],
        ),
        child: DetailSection<List<ExtensionEpisodeGroup>>(
          detailPr: detailPr,
          selector: _episodesFromState,
          skeletonBuilder: (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DetailSkeleton(width: 120, height: 36, borderRadius: 18),
                DetailSkeleton(width: 140, height: 36, borderRadius: 18),
                DetailSkeleton(width: 110, height: 36, borderRadius: 18),
                DetailSkeleton(width: 130, height: 36, borderRadius: 18),
              ],
            ),
          ),
          content: (_, episodes) {
            if (episodes.isEmpty) {
              return const SizedBox(height: 60);
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in episodes[selected.value].urls)
                  Builder(
                    builder: (context) {
                      final h = historyList.firstWhereOrNull(
                        (element) => element.url == item.url,
                      );
                      final isWatched =
                          h != null && (h.progress / h.totalProgress) >= 0.95;
                      return FButton.raw(
                        variant: FButtonVariant.outline,
                        onPress: () {
                          final donwloadList = ref.watch(
                            detailPr.select((value) => value.downloadList),
                          );
                          final savePath = donwloadList
                              .firstWhereOrNull(
                                (element) =>
                                    element.key ==
                                    "${detail.title}-${episodes[selected.value].title}-${item.name}",
                              )
                              ?.savePath;
                          context.push(
                            '/watch',
                            extra: WatchParams(
                              detailPr: detailPr,
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
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
