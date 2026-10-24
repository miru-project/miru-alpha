import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/core/scroll_view/miru_list_view.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/episode_label.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/http/request.dart';

import 'mobile_detail_hero.dart';
import 'skeleton.dart';

/// Desktop skeleton content shown while detail data is loading.
/// Shows partial info (title/img/extension) from MiruCard (/search/single)
/// plus skeleton episodes, then refreshes to full value.
class DesktopDetailSkeletonContent extends StatelessWidget {
  const DesktopDetailSkeletonContent({
    super.key,
    required this.meta,
    required this.items,
    required this.index,
  });
  final ExtensionMeta meta;
  final List<ExtensionListItem>? items;
  final int index;

  String get _title {
    final it = items;
    if (it != null && index >= 0 && index < it.length) {
      return it[index].title.isNotEmpty ? it[index].title : meta.name;
    }
    return meta.name;
  }

  String get _coverUrl {
    final it = items;
    if (it != null && index >= 0 && index < it.length) {
      return it[index].cover;
    }
    return meta.icon ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth < 1100;
        return MiruListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      MiruCard(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Partial info from MiruCard: cover image (if available)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _coverUrl.isNotEmpty
                                    ? Image.network(
                                        MiruRequest.proxyUrl(
                                          _coverUrl,
                                        ).toString(),
                                        width: 120,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, _) =>
                                            const DetailSkeleton(
                                              width: 120,
                                              height: 180,
                                            ),
                                      )
                                    : const DetailSkeleton(
                                        width: 120,
                                        height: 180,
                                      ),
                              ),
                              const SizedBox(width: 25),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title from MiruCard (/search/single)
                                    Text(
                                      _title,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // Extension name
                                    Text(
                                      meta.name,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context
                                            .theme
                                            .colors
                                            .mutedForeground,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Episode section skeleton — matches EpisodeList shape
                      MiruCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'media.episodes'.i18n,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Group selector skeleton
                                  Container(
                                    width: 180,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: context.theme.colors.muted,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Episode buttons skeleton (rounded, wrap)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (int i = 0; i < 6; i++)
                                    Container(
                                      width: 100,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: context.theme.colors.muted,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isTablet) ...[
                  const Spacer(),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        const DetailSkeleton(width: 200, height: 280),
                        const SizedBox(height: 30),
                        const DetailSkeleton(width: 200, height: 120),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}

/// Mobile skeleton page shown while detail data is loading.
///
/// One skeleton covers the whole load:
///
///   * route phase — the extension `GetDetail` round-trip is running, so
///     only the tapped card's partial info (cover, title) is real;
///   * detail-known phase — the fetched [Detail] is in hand but the
///     [Detial] notifier (history, downloads, favorites) is still
///     resolving; pass [detail] and the skeleton renders the real
///     description, episode group title and episode names, keeping this
///     same skeleton's rich shape instead of swapping to a plainer shell.
///
/// In both phases it mirrors the loaded page's own order and geometry
/// (16px gutters, 112x160 cover with the title/meta column beside it, the
/// full-width CTA, tracking and cast accordions, episode group) so
/// the swap to real content doesn't reflow.
class MobileDetailSkeletonPage extends StatelessWidget {
  const MobileDetailSkeletonPage({
    super.key,
    required this.meta,
    this.items,
    this.index = 0,
    this.detail,
    this.controller,
  });
  final ExtensionMeta meta;
  final List<ExtensionListItem>? items;
  final int index;

  /// The fetched detail, once the extension `GetDetail` resolved. Null
  /// during the route-level fetch.
  final Detail? detail;

  /// EasyRefresh's controller when this skeleton stands in for the loaded
  /// body, so pull-to-refresh keeps working while [Detial] resolves.
  final ScrollController? controller;

  String get _title {
    final d = detail?.title.trim();
    if (d != null && d.isNotEmpty) return d;
    final it = items;
    if (it != null &&
        index >= 0 &&
        index < it.length &&
        it[index].title.isNotEmpty) {
      return it[index].title;
    }
    return meta.name;
  }

  String get _coverUrl {
    final d = detail?.cover?.trim();
    if (d != null && d.isNotEmpty) return d;
    final it = items;
    if (it != null &&
        index >= 0 &&
        index < it.length &&
        it[index].cover.isNotEmpty) {
      return it[index].cover;
    }
    return meta.icon ?? '';
  }

  /// Names of the episode group the page starts on (index 0), or null
  /// while no detail is known yet.
  List<String>? get _episodeNames {
    final groups = detail?.episodes;
    if (groups == null || groups.isEmpty) return null;
    return [for (final e in groups.first.urls) e.name];
  }

  /// Title of that same group, null while no detail is known.
  String? get _groupTitle {
    final groups = detail?.episodes;
    if (groups == null || groups.isEmpty) return null;
    return groups.first.title;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _HeroSkeleton(
                  key: const Key('skeleton-hero'),
                  title: _title,
                  meta: meta,
                  coverUrl: _coverUrl,
                  description: detail?.desc?.trim() ?? '',
                ),
                const SizedBox(height: 16),
                const _TrackersCastSectionSkeleton(
                  key: Key('skeleton-trackers-cast'),
                ),
                // Content's episodes section now opens with a 24px top
                // padding (space-y-4 + pt-2); the skeleton gap matches it
                // so the section's top edge doesn't move on the swap.
                const SizedBox(height: 24),
                _EpisodeListSkeleton(
                  key: const Key('skeleton-episodes'),
                  episodeNames: _episodeNames,
                  groupTitle: _groupTitle,
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 300)),
      ],
    );
  }
}

/// Hero skeleton: the real cover beside the real title / merged meta row,
/// then the inert full-width CTA bar and the description with its Read
/// more row below — mirrors `MobileDetailHero`, drawing real text wherever
/// the data already exists (the fetched description at the detail-known
/// phase).
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton({
    super.key,
    required this.title,
    required this.meta,
    required this.coverUrl,
    required this.description,
  });

  final String title;
  final ExtensionMeta meta;
  final String coverUrl;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              key: const Key('skeleton-cover'),
              borderRadius: BorderRadius.circular(10),
              child: coverUrl.isNotEmpty
                  ? Image.network(
                      MiruRequest.proxyUrl(coverUrl).toString(),
                      width: 112,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, _) =>
                          const DetailSkeleton(width: 112, height: 160),
                    )
                  : const DetailSkeleton(width: 112, height: 160),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Same merged secondary row the loaded hero shows —
                  // extension name only; the media type is deliberately
                  // absent, matching content. Favorite-group segments
                  // only exist once [Detial] is up, so they join when
                  // content arrives.
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (meta.icon != null)
                        ExtendedImage.network(
                          MiruRequest.proxyUrl(meta.icon!).toString(),
                          width: 16,
                          height: 16,
                        )
                      else ...[
                        Icon(
                          switch (meta.type) {
                            ExtensionType.manga => FLucideIcons.book,
                            ExtensionType.bangumi => FLucideIcons.film,
                            ExtensionType.fikushon => FLucideIcons.bookText,
                            ExtensionType.all => FLucideIcons.rows3,
                          },
                          size: 14,
                          color: context.theme.colors.mutedForeground,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        meta.name,
                        style: metaStyle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Same reference rhythm as content: 24px above the CTA bar, 16px
        // below it (space-y-4 plus the CTA section's pt-2).
        const SizedBox(height: 24),
        // Inert CTA — a single full-width bar matching content's lone
        // two-line Play/Resume button.
        DetailSkeleton(height: 60, borderRadius: 8),
        const SizedBox(height: 16),
        if (description.isEmpty) ...[
          const DetailSkeleton(width: double.infinity, height: 12),
          const SizedBox(height: 6),
          const DetailSkeleton(width: 220, height: 12),
          // Inert Read more row — keeps the placeholder hero's height
          // aligned with content's description + link block.
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'media.read_more'.i18n,
                  style: context.theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colors.primary,
                  ),
                ),
                Icon(
                  FLucideIcons.chevronDown,
                  size: 14,
                  color: context.theme.colors.primary,
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
              height: 1.45,
            ),
          ),
          // Inert Read more row mirroring content's expand toggle.
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'media.read_more'.i18n,
                  style: context.theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colors.primary,
                  ),
                ),
                Icon(
                  FLucideIcons.chevronDown,
                  size: 14,
                  color: context.theme.colors.primary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Placeholder for the tracker + cast card row
/// (`MobileTrackersCastSection`): the two half-width summary tiles side by
/// side, both inert. The provider stack and the cast count only join once
/// the data arrives, so this matches content's pre-data shape.
class _TrackersCastSectionSkeleton extends StatelessWidget {
  const _TrackersCastSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TrackerCardSkeleton()),
        const SizedBox(width: 8),
        Expanded(child: _CastCardSkeleton()),
      ],
    );
  }
}

/// The tracker half of the row: the accent sync icon, the "Tracking"
/// label and the ratio-pill placeholder — the reference's single-line
/// capsule (no subtitle).
class _TrackerCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return MiruCard(
      child: FTile(
        style: .delta(
          contentStyle: .delta(
            suffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.fromLTRB(12, 12, 10, 12),
            ),
            unsuffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        prefix: Icon(
          FLucideIcons.refreshCw,
          size: 18,
          color: const Color(0xFF02A9FF),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'tracking.name'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const DetailSkeleton(width: 28, height: 10),
          ],
        ),
        suffix: Icon(
          FLucideIcons.chevronDown,
          size: 16,
          color: colors.mutedForeground,
        ),
      ),
    );
  }
}

/// The cast half of the row: the group icon, the "Cast" label and the
/// count placeholder — the reference's single-line capsule (no
/// subtitle).
class _CastCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return MiruCard(
      child: FTile(
        style: .delta(
          contentStyle: .delta(
            suffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.fromLTRB(12, 12, 10, 12),
            ),
            unsuffixedPadding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        prefix: Icon(
          FLucideIcons.users,
          size: 18,
          color: colors.mutedForeground,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'media.cast'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const DetailSkeleton(width: 14, height: 10),
          ],
        ),
        suffix: Icon(
          FLucideIcons.chevronDown,
          size: 16,
          color: colors.mutedForeground,
        ),
      ),
    );
  }
}

/// Placeholder for the episode section (`MobileDetailSilverlist`): the
/// group-selector / count / sort label row over the same [FTileGroup]
/// chrome content uses. With [episodeNames] (detail-known phase) the rows
/// carry the real positions, names and episode count; without it, bars
/// stand in and the count reads as a bar.
class _EpisodeListSkeleton extends StatelessWidget {
  const _EpisodeListSkeleton({super.key, this.episodeNames, this.groupTitle});

  final List<String>? episodeNames;
  final String? groupTitle;

  @override
  Widget build(BuildContext context) {
    final names = episodeNames;
    final count = names?.length;
    final rowCount = names == null
        ? 6
        : names.length < 6
        ? names.length
        : 6;
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FTileGroup.builder(
        physics: const NeverScrollableScrollPhysics(),
        divider: .full,
        label: Row(
          children: [
            // Section heading + plain-text count, mirroring content.
            // Flexible keeps the row overflow-free at 320 px — the
            // heading alone is 112 px wide, and with the selector (106)
            // and sort button (36) the inflexible sum beat the 288 px
            // inner width by 4 px.
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
            count == null
                ? const DetailSkeleton(width: 24, height: 12)
                : Text(
                    '($count)',
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
            const Spacer(),
            // Source selector shaped like the loaded page's compact
            // trigger: source label + real group title (or a bar) +
            // chevron, inert (no onPress).
            FButton(
              onPress: null,
              variant: .outline,
              size: .xs,
              mainAxisAlignment: .start,
              style: .delta(
                contentStyle: .delta(
                  constraints: const BoxConstraints(minHeight: 36),
                ),
              ),
              suffix: Icon(
                FLucideIcons.chevronDown,
                size: 14,
                color: colors.mutedForeground,
              ),
              child: groupTitle != null
                  ? ConstrainedBox(
                      // Same 100 px cap as content's selector — the two
                      // must stay identical for the skeleton swap.
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(
                        groupTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const DetailSkeleton(width: 72, height: 12),
            ),
            const SizedBox(width: 8),
            // 36×36 sort stand-in, pinned right by the lone Spacer
            // exactly like content's sort button.
            FButton.icon(
              onPress: null,
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
              child: Icon(FLucideIcons.arrowDownNarrowWide),
            ),
          ],
        ),
        tileBuilder: (context, i) {
          final name = names == null || i >= names.length ? null : names[i];
          return FTile(
            // Same compact content padding as the loaded episode tile so
            // the skeleton→content swap doesn't change row heights.
            style: .delta(
              contentStyle: .delta(
                suffixedPadding: EdgeInsetsGeometryDelta.value(
                  const EdgeInsets.fromLTRB(15, 8, 13, 8),
                ),
                titleSpacing: 2,
              ),
            ),
            prefix: SizedBox(
              width: 24,
              child: Text(
                // Same plain zero-padded ordinal as the loaded tile.
                (i + 1).toString().padLeft(2, '0'),
                textAlign: TextAlign.center,
                style: context.theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.mutedForeground,
                ),
              ),
            ),
            title: name == null
                ? const DetailSkeleton(width: 160, height: 12)
                : Text(stripEpisodePrefix(name)),
            suffix: Icon(
              FLucideIcons.arrowDownToLine,
              color: colors.mutedForeground,
            ),
          );
        },
        count: rowCount,
      ),
    );
  }
}
