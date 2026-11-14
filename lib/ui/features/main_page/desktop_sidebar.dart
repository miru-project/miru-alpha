import 'package:material_ui/material_ui.dart' show Tooltip;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/shell/shell_ui_provider.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart' show ExtensionType;
import 'package:miru_alpha/ui/features/extension/widget/text_cover.dart';
import 'package:miru_alpha/ui/features/favorite/widget/favorite_group_sheet.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// The desktop shell's navigation sidebar: connection-aware brand header,
/// the Overview group and the WebDAV footer. Extracted from `main_page.dart`
/// so the shell file keeps only layout; styled exactly like the sidebar it
/// replaced — plain Forui primitives, no bespoke accents.

class FIconNavItem {
  final String text;
  final IconData icon;
  final String? page;
  const FIconNavItem({required this.text, required this.icon, this.page});
}

/// The root nav's destinations (2026-11-12 audit end-state: ONE "Library"
/// group). Search is deliberately NOT here — the audit's Omni-Search
/// consolidation (single source of truth) overrides the earlier mock's
/// re-add: the header command search (Ctrl K) owns all search entry.
/// Settings is also absent: the header gear is the entry, `/settings/*`
/// keeps the root nav dark, and the settings page owns a page-local
/// section sidebar (user directive 2026-11-12).
final List<FIconNavItem> sidebarNavItems = [
  FIconNavItem(text: 'common.home', icon: FLucideIcons.house, page: "/home"),
  FIconNavItem(
    text: 'common.history',
    icon: FLucideIcons.history,
    page: "/home/history",
  ),
  FIconNavItem(
    text: 'favorite.name',
    icon: FLucideIcons.bookHeart,
    page: "/home/favorite",
  ),
  FIconNavItem(
    text: 'download.name',
    icon: FLucideIcons.download,
    page: "/home/download",
  ),
  FIconNavItem(
    text: 'extension.name',
    icon: FLucideIcons.blocks,
    page: "/extension",
  ),
  FIconNavItem(
    text: 'tracking.name',
    icon: FLucideIcons.clipboardClock,
    page: "/tracking",
  ),
];

/// Root-nav selection resolver: the sidebar index whose [FIconNavItem.page]
/// is the current location's prefix. Pure so the route-sync contract is
/// unit-testable; the sidebar derives its highlight from this every build,
/// exactly like Android's bottom nav tracks the back stack. No settings
/// fallback: `/settings/*` is not a root-nav destination (the header gear
/// owns the entry; the settings page carries its own section sidebar).
int? sidebarIndexForLocation(String location, List<FIconNavItem> items) {
  // The router redirects '/' to '/home' (router_util.dart:116), so the bare
  // root location highlights the Home entry.
  if (location == '/') {
    return items.indexWhere((item) => item.page == '/home');
  }
  // Longest prefix wins: '/home/favorite' belongs to the Favorite entry,
  // never to the shorter '/home' prefix.
  int? best;
  var bestLength = -1;
  for (final (i, item) in items.indexed) {
    final page = item.page;
    if (page == null) continue;
    final matches =
        location == page ||
        location.startsWith('$page/') ||
        location.startsWith('$page?');
    if (matches && page.length > bestLength) {
      best = i;
      bestLength = page.length;
    }
  }
  return best;
}

/// Frequent Extensions (mock): the user's favorites grouped by source
/// package, connected-favorite count DESCENDING, capped at 4 — shared by the
/// expanded sidebar group and the collapsed rail (user directive 2026-11-13:
/// the rail keeps the group as single extension icons below a divider).
List<(ExtensionMeta, int)> frequentExtensionsFor(WidgetRef ref) {
  final favs = ref.watch(favoritePageProvider.select((s) => s.favorites));
  final extMeta = ref.watch(extensionPageProvider.select((s) => s.metaData));
  final favCounts = <String, int>{};
  for (final f in favs) {
    favCounts[f.package] = (favCounts[f.package] ?? 0) + 1;
  }
  return [
    for (final m in extMeta)
      if (favCounts[m.packageName] case final n? when n > 0) (m, n),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
}

class DesktopSidebar extends HookConsumerWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The highlight FOLLOWS the route (Android bottom-nav semantics): it is
    // derived from GoRouterState on every build, never parked in a useState
    // that silently drifts after a deep link or a top-bar navigation.
    final location = GoRouterState.of(context).uri.toString();
    final selected = sidebarIndexForLocation(location, sidebarNavItems);
    final colors = context.theme.colors;
    final groups = ref.watch(
      favoritePageProvider.select((s) => s.favoriteGroups),
    );
    // Collapsed icon rail (header toggle / Ctrl+B): 56px, icons only, no
    // labels/counts/shelves — tooltips carry the names.
    final collapsed = ref.watch(sidebarCollapsedProvider);
    // Frequent Extensions (mock): favorites grouped by source package,
    // connected-favorite count DESCENDING — shared with the collapsed rail.
    final frequentExtensions = frequentExtensionsFor(ref);
    // Tags (mock): every group, connected-favorites count DESCENDING,
    // unlimited length — the sidebar column scrolls.
    final sortedGroups = [...groups]
      ..sort((a, b) => b.favorites.length.compareTo(a.favorites.length));

    final expandedRail = SafeFSidebar(
      autofocus: true,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FDivider(
              style: FDividerStyleDelta.delta(
                padding: EdgeInsetsGeometryDelta.value(.only(bottom: 5)),
              ),
            ),
          ],
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact WebDAV pill (mock footer): icon tile + title + status
            // caption. No backing sync state exists yet — no fabricated
            // "Synced" badge; tap surfaces the WIP toast.
            FTappable(
              onPress: () {
                iconsMessageToast(
                  title: 'common.wip'.i18n,
                  icon: FLucideIcons.construction,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.theme.colors.muted.withAlpha(102),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.fromBorderSide(
                    BorderSide(color: context.theme.colors.border),
                  ),
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.theme.colors.muted.withAlpha(120),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.cloud,
                        size: 15,
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'common.webdav'.i18n,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.theme.typography.body.xs2
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // The real state: no WebDAV account is
                              // configured yet — never claim "Synced".
                              SmallBadge(label: 'sidebar.not_synced'.i18n),
                            ],
                          ),
                          Text(
                            'sidebar.webdav_caption'.i18n,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.theme.typography.body.xs2.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        FSidebarGroup(
          label: const SizedBox.shrink(),
          children: [
            // Uppercase micro-label (mock: "Library" group header, same
            // treatment as the Pinned Shelves label below).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'sidebar.library'.i18n.toUpperCase(),
                  style: context.theme.typography.body.xs2.copyWith(
                    color: colors.mutedForeground,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            for (var i = 0; i < sidebarNavItems.length; i++) ...[
              FSidebarItem(
                label: _NavLabel(index: i),
                icon: Icon(sidebarNavItems[i].icon),
                onPress: () {
                  if (sidebarNavItems[i].page != null) {
                    context.go(sidebarNavItems[i].page!);
                  }
                },
                selected: selected == i,
              ),
            ],
          ],
        ),
        // Frequent Extensions (mock): installed sources the user's favorites
        // come from — connected-favorite count descending, max 4. "+"
        // browses the store.
        if (frequentExtensions.isNotEmpty)
          FSidebarGroup(
            label: const SizedBox.shrink(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'sidebar.frequent_extensions'.i18n.toUpperCase(),
                        style: context.theme.typography.body.xs2.copyWith(
                          color: colors.mutedForeground,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: FTappable(
                        onPress: () => context.go('/extension'),
                        child: Center(
                          child: Icon(
                            FLucideIcons.plus,
                            size: 14,
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (final (meta, _) in frequentExtensions)
                FSidebarItem(
                  // The source's real icon — the shared 20px tile (same
                  // treatment as the collapsed rail and the extension list
                  // tiles).
                  icon: _ExtensionIcon20(meta: meta),
                  label: Row(
                    children: [
                      Expanded(
                        child: Text(
                          meta.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.xs2.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SmallBadge(label: searchExtensionTypeLabel(meta.type)),
                    ],
                  ),
                  onPress: () => context.push(
                    '/search/single',
                    extra: SearchPageParam(meta: meta),
                  ),
                ),
            ],
          ),
        // Tags (mock): every favorite group with its connected-favorites
        // count, count DESCENDING, unlimited length — the sidebar column
        // scrolls. "+" opens the tag manager.
        FSidebarGroup(
          label: const SizedBox.shrink(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'sidebar.tags'.i18n.toUpperCase(),
                      style: context.theme.typography.body.xs2.copyWith(
                        color: colors.mutedForeground,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  // 28px hit target around the 14px glyph (Fitts: the bare
                  // icon was a 14x14 tap box), forui's own hover/press states.
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: FTappable(
                      onPress: () => showFavoriteGroupSheet(context),
                      child: Center(
                        child: Icon(
                          FLucideIcons.plus,
                          size: 14,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final (i, group) in sortedGroups.indexed)
              FSidebarItem(
                label: Row(
                  children: [
                    Icon(
                      FLucideIcons.tag,
                      size: 14,
                      color: kShelfDotColors[i % kShelfDotColors.length],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Same badge theme as the nav counts (one trailing
                    // language for every sidebar row).
                    SmallBadge(label: '${group.favorites.length}'),
                  ],
                ),
                onPress: () {
                  final notifier = ref.read(favoritePageProvider.notifier);
                  for (final selected
                      in ref
                          .read(favoritePageProvider)
                          .selectedFavoriteGroups) {
                    notifier.toggleGroupName(selected.name);
                  }
                  notifier.toggleGroupName(group.name);
                  context.go('/home/favorite');
                },
              ),
          ],
        ),
      ],
    );

    // Discrete width switch (user directive 2026-11-13, "snappy"): the width
    // JUMPS instead of animating. Interpolating 240→56 squeezed the expanded
    // rail through intermediate widths and threw RenderFlex overflows every
    // expand; the morphing panel icon in the header carries the motion now.
    return SizedBox(
      width: collapsed ? 56 : 240,
      child: collapsed ? _CollapsedRail(selected: selected) : expandedRail,
    );
  }
}

/// The collapsed 56px icon rail: nav icons (tooltips carry the names, the
/// selected one keeps forui's secondary fill), a divider, then the Frequent
/// Extensions as single extension icons (user directive 2026-11-13) — the
/// same real-icon treatment as the expanded group — and the WebDAV icon with
/// its emerald indicator dot at the bottom. Labels, counts and tags hide.
class _CollapsedRail extends ConsumerWidget {
  const _CollapsedRail({required this.selected});

  final int? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    // Capped at 4: the rail is a fixed-height column (no scroll) — the same
    // cap the mock gave the group.
    final frequent = frequentExtensionsFor(ref).take(4).toList();
    return Column(
      children: [
        const SizedBox(height: 8),
        for (final (i, item) in sidebarNavItems.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Tooltip(
              message: item.text.i18n,
              child: FButton.icon(
                variant: selected == i ? .secondary : .ghost,
                size: .sm,
                onPress: item.page != null
                    ? () => context.go(item.page!)
                    : null,
                child: Icon(item.icon, size: 18),
              ),
            ),
          ),
        if (frequent.isNotEmpty) ...[
          // The divider splits the nav menu from the extension icons.
          FDivider(
            style: FDividerStyleDelta.delta(
              padding: EdgeInsetsGeometryDelta.value(
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            ),
          ),
          for (final (meta, _) in frequent)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Tooltip(
                message: meta.name,
                child: FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: () => context.push(
                    '/search/single',
                    extra: SearchPageParam(meta: meta),
                  ),
                  child: _ExtensionIcon20(meta: meta),
                ),
              ),
            ),
        ],
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Tooltip(
            message: 'common.webdav'.i18n,
            child: GestureDetector(
              onTap: () => iconsMessageToast(
                title: 'common.wip'.i18n,
                icon: FLucideIcons.construction,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.muted.withAlpha(120),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      FLucideIcons.cloud,
                      size: 15,
                      color: colors.mutedForeground,
                    ),
                  ),
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kSidebarEmerald,
                        border: Border.fromBorderSide(
                          BorderSide(color: colors.background, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The 20px source-icon tile — the same real-icon treatment as the expanded
/// Frequent Extensions group and the extension list tiles: muted square, the
/// source's icon with the TextCover glyph fallback.
class _ExtensionIcon20 extends StatelessWidget {
  const _ExtensionIcon20({required this.meta});

  final ExtensionMeta meta;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 20,
        height: 20,
        color: colors.muted,
        alignment: Alignment.center,
        child: ImageWidget(
          imageUrl: meta.icon,
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          borderRadius: 0,
          errChild: TextCover(
            seed: meta.name,
            icon: switch (meta.type) {
              ExtensionType.bangumi => FLucideIcons.play,
              ExtensionType.manga => FLucideIcons.bookOpen,
              ExtensionType.fikushon => FLucideIcons.bookMarked,
              _ => FLucideIcons.package,
            },
            size: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// The mock's shelf dot palette (rose / sky / amber / purple cycle).
const kShelfDotColors = [
  Color(0xFFF43F5E),
  Color(0xFF38BDF8),
  Color(0xFFFBBF24),
  Color(0xFFA855F7),
];

/// The shell's sidebar frame: fixed 160-200px width, sticky header over a
/// scrollable content column over a sticky footer.
class SafeFSidebar extends StatelessWidget {
  final bool? autofocus;
  final Widget? header;
  final Widget? footer;
  final List<Widget>? children;
  final double? width;

  const SafeFSidebar({
    super.key,
    this.autofocus,
    this.header,
    this.footer,
    this.children,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 200,
        maxWidth: width ?? 240,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header ?? const SizedBox(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView(
                padding: EdgeInsets.zero,
                children: children ?? const [],
              ),
            ),
          ),
          footer ?? const SizedBox(),
        ],
      ),
    );
  }
}

/// The nav row's label: text + one right-aligned trailing badge, EVERY row
/// wearing the same theme (user directive 2026-11-13): the shared
/// [SmallBadge] with the neutral muted label — no per-row accent colors.
/// The label row expands inside FSidebarItem, so the badge pins right.
class _NavLabel extends ConsumerWidget {
  const _NavLabel({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = sidebarNavItems[index];
    return Row(
      children: [
        Expanded(child: Text(item.text.i18n)),
        if (item.page == '/home/download') ...[
          const SizedBox(width: 8),
          _NavCountBadge(
            count: ref
                .watch(downloadProvider)
                .whenOrNull(data: (state) => state.active.length),
          ),
        ] else if (item.page == '/home/favorite') ...[
          const SizedBox(width: 8),
          _NavCountBadge(
            count: ref.watch(
              favoritePageProvider.select((s) => s.favorites.length),
            ),
          ),
        ] else if (item.page == '/extension') ...[
          const SizedBox(width: 8),
          _NavCountBadge(
            count: ref.watch(
              extensionPageProvider.select((s) => s.installedPackages.length),
            ),
          ),
        ],
      ],
    );
  }
}

/// Right-aligned nav count chip — the shared [SmallBadge] in the sidebar's
/// ONE badge theme (neutral muted label on the secondary surface); hidden
/// at zero / unresolved (no count noise).
class _NavCountBadge extends StatelessWidget {
  const _NavCountBadge({required this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    if (count == null || count == 0) return const SizedBox.shrink();
    return SmallBadge(
      label: count! > 99 ? '99+' : '$count',
      labelColor: context.theme.colors.mutedForeground,
    );
  }
}

/// The mock's emerald live-dot accent (shared with the banner).
const kSidebarEmerald = Color(0xFF10B981);
