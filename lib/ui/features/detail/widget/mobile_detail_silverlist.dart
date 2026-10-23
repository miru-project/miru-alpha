import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/provider/detail_page_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class MobileDetailSilverlist extends HookConsumerWidget {
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;
  const MobileDetailSilverlist({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReverse = useState(false);
    final epGroupIdx = ref.watch(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    final selectedGpIndex = ref.watch(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    final historyList = ref.watch(detailPr.select((s) => s.historyList));
    if (detail.episodes?.isEmpty ?? true) {
      return SliverToBoxAdapter(
        child: Center(child: Text('media.no_episodes'.i18n)),
      );
    }
    final selectGroup = detail.episodes![epGroupIdx].urls;

    return SliverToBoxAdapter(
      child: Padding(
        // Reference rhythm: the episodes section is separated from the
        // block above by `space-y-4` (16) plus the section's own `pt-2`
        // (8) — 24px of air so the large list doesn't crowd the
        // trackers/cast cards. The bottom keeps the smaller 12.
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            FTileGroup.builder(
              physics: NeverScrollableScrollPhysics(),
              divider: .full,
              label: Row(
                children: [
                  // Section heading with a plain-text count, matching the
                  // reference: "Episodes (18)" instead of a bordered chip.
                  // Flexible keeps the header row overflow-free at 320 px
                  // (the heading is 112 px; with the selector and sort
                  // button the inflexible sum exceeded the inner width).
                  Flexible(
                    child: Text(
                      'media.episodes'.i18n,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${selectGroup.length})',
                    style: context.theme.typography.body.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                  // The Spacer is the row's ONLY flex child: it absorbs
                  // the leftover width and pins the source selector and
                  // the sort button to the right edge.
                  const Spacer(),
                  HookConsumer(
                    builder: (context, ref, _) {
                      final selectedEpGroup = ref.watch(
                        detailPageProviderProvider.select((e) => e.epGroupIdx),
                      );
                      final controller = useFPopoverController();

                      return FPopoverMenu.tiles(
                        menuAnchor: .topCenter,
                        menu: [
                          .group(
                            children: List.generate(
                              detail.episodes?.length ?? 0,
                              (idx) {
                                return FTile(
                                  onPress: () {
                                    ref
                                        .read(
                                          detailPageProviderProvider.notifier,
                                        )
                                        .setEpGroup(idx);
                                    controller.toggle();
                                  },
                                  title: Text(detail.episodes![idx].title),
                                );
                              },
                            ),
                          ),
                        ],
                        control: .managed(controller: controller),
                        child: FButton(
                          variant: .outline,
                          size: .xs,
                          mainAxisAlignment: .start,
                          style: .delta(
                            contentStyle: .delta(
                              constraints: const BoxConstraints(minHeight: 36),
                            ),
                          ),
                          onPress: () {
                            controller.toggle();
                          },
                          suffix: Icon(
                            FLucideIcons.chevronDown,
                            size: 14,
                            color: context.theme.colors.mutedForeground,
                          ),
                          // Cap keeps long group titles from squeezing
                          // the sort button on 320 px phones. 100 leaves
                          // headroom below the header row's 288 px inner
                          // width at the narrowest supported phone (112
                          // overflowed the row by 4 px at 320).
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: Text(
                              detail.episodes?[selectedEpGroup].title ??
                                  'media.no_episodes'.i18n,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.theme.typography.body.xs.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // 36×36 sort toggle — the reference's compact button
                  // (iconContentStyle drives FButton.icon's box; a
                  // contentStyle delta would silently not apply).
                  FButton.icon(
                    variant: .outline,
                    size: .xs,
                    style: .delta(
                      iconContentStyle: .delta(
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                    onPress: () {
                      isReverse.value = !isReverse.value;
                    },
                    child: isReverse.value
                        ? Icon(FLucideIcons.arrowUpNarrowWide)
                        : Icon(FLucideIcons.arrowDownNarrowWide),
                  ),
                ],
              ),
              tileBuilder: (context, idx) {
                final reverseIdx = isReverse.value
                    ? selectGroup.length - 1 - idx
                    : idx;
                final item = selectGroup[reverseIdx];
                final h = historyList.firstWhereOrNull(
                  (element) => element.url == item.url,
                );
                final key =
                    "${meta.packageName}_${detail.episodes?[selectedGpIndex].title}_${item.name}";
                final isDownloaded = ref.watch(
                  downloadProvider.select((s) {
                    final history = s.value?.history ?? [];
                    return history.any((e) => e.key == key);
                  }),
                );
                return MobileDetailTile(
                  item: item,
                  idx: idx,
                  position: reverseIdx + 1,
                  selectedGpIndex: selectedGpIndex,
                  detail: detail,
                  meta: meta,
                  detailUrl: detailUrl,
                  detailPr: detailPr,
                  history: h,
                  isDownloaded: isDownloaded,
                );
              },
              count: selectGroup.length,
            ),
          ],
        ),
      ),
    );
  }
}
