import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/provider/detail_page_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Width of the episode-group select trigger. Shared with the loading
/// skeleton's mirror so the skeleton→content swap doesn't reflow the
/// header row.
const double kDetailGroupSelectWidth = 140;

class MobileDetailSilverlist extends HookConsumerWidget {
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  /// Horizontal inset for the episode section — the wide-viewport column
  /// cap from [MobileLoadedPage] so the list shares the hero's column.
  final double horizontalInset;

  const MobileDetailSilverlist({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
    this.horizontalInset = 16,
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
    final groups = detail.episodes!;
    final selectGroup = groups[epGroupIdx].urls;

    return SliverToBoxAdapter(
      child: Padding(
        // Reference rhythm: the episodes section is separated from the
        // block above by `space-y-4` (16) plus the section's own `pt-2`
        // (8) — 24px of air so the large list doesn't crowd the
        // trackers/cast cards. The bottom keeps the smaller 12.
        padding: EdgeInsets.only(
          left: horizontalInset,
          right: horizontalInset,
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
                  // The Expanded is the row's only flex child: it absorbs
                  // the leftover width, pins the group select and the sort
                  // button to the right edge, and ellipsises the heading on
                  // 320 px phones where the fixed-width select plus sort
                  // button crowd the label.
                  Expanded(
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
                  const SizedBox(width: 8),
                  // Native forui select for the episode group — the previous
                  // FPopoverMenu + FButton trigger was a hand-rolled
                  // lookalike. The popover opens above the field, the picked
                  // tile carries the check mark, and autoHide closes it.
                  SizedBox(
                    width: kDetailGroupSelectWidth,
                    child: FSelect<int>.rich(
                      control: .lifted(
                        value: epGroupIdx,
                        onChange: (value) {
                          if (value != null) {
                            ref
                                .read(detailPageProviderProvider.notifier)
                                .setEpGroup(value);
                          }
                        },
                      ),
                      // rich children keep duplicate group titles as
                      // separate rows — the items map would collapse them.
                      format: (value) =>
                          groups.elementAtOrNull(value)?.title ??
                          groups.first.title,
                      children: [
                        for (final (idx, group) in groups.indexed)
                          FSelectItem(title: Text(group.title), value: idx),
                      ],
                    ),
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
                        ? Icon(FLucideIcons.arrowUp10)
                        : Icon(FLucideIcons.arrowDown01),
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
