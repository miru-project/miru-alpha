import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/core/widget/pulsing_dot.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_header_section.dart';
import 'package:miru_alpha/utils/core/html_text.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// The scrollable content under the watch viewport, in the detail page's
/// section language: header → [headerExtra] → tabbed Episodes / Overview.
/// ONE composition shared by the page's three states (loaded / loading /
/// error) so the episode list, tab switcher and header can never drift:
/// the state deltas arrive as params ([statusMeta], [activeStatus],
/// [headerExtra], [listFooter], [listActivity]).
class WatchContentBody extends ConsumerWidget {
  const WatchContentBody({
    super.key,
    required this.param,
    required this.epProvider,
    this.statusMeta,
    this.listActivity = false,
    this.activeStatus,
    this.activeStatusDetail,
    this.onActiveRetry,
    this.headerExtra,
    this.listFooter,
  });

  final WatchParams param;
  final EpisodeNotifierProvider epProvider;

  /// Replaces the header's default "S{n} · Episode n" meta line.
  final Widget? statusMeta;

  /// Puts the pulsing activity dot inside the Episodes tab label — the
  /// loading state's "work happening behind this tab" mark.
  final bool listActivity;

  /// Status pinned onto the active episode's row (resolving / failed);
  /// `null` keeps the loaded page's selected-row behaviour.
  final EpisodeTileStatus? activeStatus;

  /// One-line reason under a failed active row.
  final String? activeStatusDetail;

  /// Retry callback handed to a failed active row.
  final VoidCallback? onActiveRetry;

  /// Panel between the header and the tabs — the error state's
  /// diagnostics accordion. Nothing renders when absent.
  final Widget? headerExtra;

  /// Footnote under the episode list — the loading state's slow-bridge
  /// hint. Nothing renders when absent.
  final Widget? listFooter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = param.meta;
    final detailPr = param.detailPr;
    final detailState = detailPr == null ? null : ref.watch(detailPr);
    final detail = _resolveDetail(detailState);

    final histories = ref
        .watch(historyPageProvider)
        .history
        .where(
          (h) =>
              h.package == meta.packageName && h.detailUrl == param.detailUrl,
        )
        .toList();

    final ep = ref.watch(epProvider);
    final groupIndex = ep.selectedGroupIndex;
    final group = ep.epGroup.elementAtOrNull(groupIndex);
    final episodes = group?.urls ?? <ExtensionEpisode>[];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            WatchHeaderSection(
              showTitle: param.name,
              groupTitle: group?.title ?? '',
              episodeIndex: ep.selectedEpisodeIndex,
              episodeName:
                  episodes.elementAtOrNull(ep.selectedEpisodeIndex)?.name ?? '',
              detail: detail,
              meta: meta,
              detailUrl: param.detailUrl,
              epProvider: epProvider,
              favorited: detailState?.favorite != null,
              statusMeta: statusMeta,
            ),
            if (headerExtra != null) ...[
              const SizedBox(height: 12),
              headerExtra!,
            ],
            const SizedBox(height: 16),
            // The mock's tabbed episode architecture: the list stays here,
            // the description/tracking metadata moves into the Overview
            // pane instead of trailing the list.
            FTabs(
              expands: false,
              children: [
                FTabEntry(
                  label: listActivity
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '${'media.episodes'.i18n} (${episodes.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            PulsingDot(
                              color: context.theme.colors.primary,
                              size: 5,
                            ),
                          ],
                        )
                      : Text('${'media.episodes'.i18n} (${episodes.length})'),
                  child: EpisodeList(
                    param: param,
                    detail: detail,
                    epProvider: epProvider,
                    histories: histories,
                    groupIndex: groupIndex,
                    episodes: episodes,
                    favorited: detailState?.favorite != null,
                    activeStatus: activeStatus,
                    activeStatusDetail: activeStatusDetail,
                    onActiveRetry: onActiveRetry,
                  ),
                ),
                FTabEntry(
                  label: Text('media.overview'.i18n),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // The pane is the detail's description, pasted as-is
                      // (user directive) — no tracker strip, no metadata
                      // chrome around it.
                      if ((detail.desc?.trim() ?? '').isNotEmpty)
                        _OverviewDesc(desc: detail.desc!),
                      // The detail flow may never have loaded (deep link /
                      // error path) — the pane still has the series basics
                      // instead of rendering empty.
                      if ((detail.desc?.trim() ?? '').isEmpty)
                        _OverviewFallback(
                          meta: meta,
                          episodeCount: episodes.length,
                          groupName: group?.title ?? '',
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (listFooter != null) ...[const SizedBox(height: 8), listFooter!],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// The detail page's [Detail]; falls back to a shell built from the watch
  /// params when the watch flow was entered without a detail provider
  /// (e.g. continue-watching deep link) so episode rows still compute their
  /// download keys.
  Detail _resolveDetail(DetialState? state) {
    final info = state?.detailInfo;
    if (info != null) return MiruCoreEndpoint.detailFromProto(info);
    return Detail(
      title: param.name,
      cover: param.detailImageUrl.isEmpty ? null : param.detailImageUrl,
      episodes: param.epGroup,
      detailUrl: param.detailUrl,
      package: param.meta.packageName,
    );
  }
}

class EpisodeList extends HookConsumerWidget {
  const EpisodeList({
    super.key,
    required this.param,
    required this.detail,
    required this.epProvider,
    required this.histories,
    required this.groupIndex,
    required this.episodes,
    required this.favorited,
    this.activeStatus,
    this.activeStatusDetail,
    this.onActiveRetry,
  });

  final WatchParams param;
  final Detail detail;
  final EpisodeNotifierProvider epProvider;
  final List<History> histories;
  final int groupIndex;
  final List<ExtensionEpisode> episodes;
  final bool favorited;

  /// Status for the active row — see [WatchContentBody.activeStatus].
  final EpisodeTileStatus? activeStatus;
  final String? activeStatusDetail;
  final VoidCallback? onActiveRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReverse = useState(false);
    final groupPopover = useFPopoverController();
    final epNotifier = ref.read(epProvider.notifier);
    final selectedIndex = ref.watch(
      epProvider.select((s) => s.selectedEpisodeIndex),
    );
    final groups = ref.watch(epProvider.select((s) => s.epGroup));

    // Browse state: the group whose episodes the list shows. Picking another
    // group in the selector re-lists that group WITHOUT switching the player
    // — nothing in it is playing yet, so no row carries the selection mark.
    // The player only moves when an episode row is tapped. The list starts
    // on (and follows) the playing group.
    final displayedGroup = useState(groupIndex);
    useEffect(() {
      displayedGroup.value = groupIndex;
      return null;
    }, [groupIndex]);
    final displayedEpisodes =
        groups.elementAtOrNull(displayedGroup.value)?.urls ?? episodes;
    // Same completed-download lookup the detail list uses, so a "Saved"
    // mark never disagrees between the two surfaces.
    final downloadedUrls = ref.watch(
      downloadProvider.select(
        (s) => (s.value?.history ?? const [])
            .where((d) => d.status == proto.DownloadStatus.COMPLETED)
            .map((d) => d.url)
            .toList(),
      ),
    );

    final order = List<int>.generate(displayedEpisodes.length, (i) => i);
    if (isReverse.value) {
      order.sort((a, b) => b.compareTo(a));
    }

    // The detail page's silverlist shape: ONE grouped forui list — rows
    // share the group card and its full dividers. The label row carries the
    // list's own heading ("Episodes (n)") LEFT and its controls (group
    // selector, order) RIGHT on one line: the user wants the count label
    // kept, and sharing the row with the controls satisfies the review's
    // proximity point instead of stacking a second filter band.
    return FTileGroup.builder(
      physics: const NeverScrollableScrollPhysics(),
      divider: .full,
      label: Row(
        children: [
          Text(
            'media.episodes'.i18n,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(${displayedEpisodes.length})',
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const Spacer(),
          // Bookmark/share live in the page header now; the list header
          // keeps only the list's own controls (group selector, order).
          if (groups.length > 1) ...[
            // 10px gaps; the controls match the detail header's floor (36px)
            // so the two surfaces' dropdowns read as one family — the user
            // flagged the watch header's taller 44px buttons as inconsistent.
            const SizedBox(width: 10),
            // Group switcher, the detail header's selector: a popover of
            // the episode groups. Picking one only re-lists that group's
            // episodes (browse); the player switches when an episode row
            // is tapped — never on the group pick itself.
            FPopoverMenu.tiles(
              menuAnchor: .topCenter,
              menu: [
                .group(
                  children: [
                    for (var g = 0; g < groups.length; g++)
                      FTile(
                        selected: g == displayedGroup.value,
                        onPress: () {
                          displayedGroup.value = g;
                          groupPopover.toggle();
                        },
                        title: Text(groups[g].title),
                      ),
                  ],
                ),
              ],
              control: .managed(controller: groupPopover),
              child: FButton(
                variant: .outline,
                size: .xs,
                style: .delta(
                  contentStyle: .delta(
                    constraints: const BoxConstraints(minHeight: 36),
                  ),
                ),
                onPress: groupPopover.toggle,
                suffix: Icon(
                  FLucideIcons.chevronDown,
                  size: 14,
                  color: context.theme.colors.mutedForeground,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    groups.elementAtOrNull(displayedGroup.value)?.title ??
                        'media.no_episodes'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 10),
          FButton.icon(
            variant: .outline,
            size: .xs,
            style: .delta(
              iconContentStyle: .delta(
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
            onPress: () => isReverse.value = !isReverse.value,
            child: isReverse.value
                ? const Icon(FLucideIcons.arrowUp10)
                : const Icon(FLucideIcons.arrowDown01),
          ),
        ],
      ),
      tileBuilder: (context, idx) {
        final realIndex = order[idx];
        // The selection mark only exists in the group that is actually
        // playing — a browsed-but-not-playing group shows plain rows.
        final isPlayingGroup = displayedGroup.value == groupIndex;
        final isActive = isPlayingGroup && realIndex == selectedIndex;
        // The loading / error shells pin a status onto the active row in
        // place of the playing mark (nothing is playing yet).
        final status = isActive ? activeStatus : null;
        return MobileDetailTile(
          key: ValueKey('watch-ep-${displayedGroup.value}-$realIndex'),
          item: displayedEpisodes[realIndex],
          idx: realIndex,
          position: realIndex + 1,
          selectedGpIndex: displayedGroup.value,
          detail: detail,
          meta: param.meta,
          detailUrl: param.detailUrl,
          detailPr: param.detailPr,
          history: histories.firstWhereOrNull(
            (h) => h.url == displayedEpisodes[realIndex].url,
          ),
          isDownloaded: downloadedUrls.any(
            (urls) => urls.contains(displayedEpisodes[realIndex].url),
          ),
          selected: status == null && isActive,
          status: status,
          statusDetail: isActive ? activeStatusDetail : null,
          onRetry: onActiveRetry,
          onPress: () =>
              epNotifier.selectEpisode(displayedGroup.value, realIndex),
        );
      },
      count: order.length,
    );
  }
}

/// The Overview pane's content: the detail's description pasted as-is,
/// rendered with the same HTML-decoding the detail hero uses.
class _OverviewDesc extends StatelessWidget {
  const _OverviewDesc({required this.desc});

  final String desc;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.typography.body.md.copyWith(height: 1.55);
    return Text.rich(htmlToSpan(desc, style: style));
  }
}

/// The Overview pane's fallback when the detail flow never delivered
/// content (deep link / error path): the series basics from the watch
/// params instead of an empty pane.
class _OverviewFallback extends StatelessWidget {
  const _OverviewFallback({
    required this.meta,
    required this.episodeCount,
    required this.groupName,
  });

  final ExtensionMeta meta;
  final int episodeCount;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    final muted = context.theme.colors.mutedForeground;
    final label = context.theme.typography.body.xs.copyWith(color: muted);
    final value = context.theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
    );
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  groupName.isEmpty ? meta.name : groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('media.episodes'.i18n, style: label),
              const Spacer(),
              Text('$episodeCount', style: value),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Extension', style: label),
              const Spacer(),
              Flexible(
                child: Text(
                  meta.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
