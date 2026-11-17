import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart' show Tooltip;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/features/favorite/widget/favorite_group_sheet.dart';
import 'package:miru_alpha/provider/home/home_dashboard_provider.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/core/widget/small_badge.dart';
import 'package:miru_alpha/utils/core/date_format.dart';
import 'package:miru_alpha/ui/features/main_page/desktop_sidebar.dart'
    show kShelfDotColors;
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_cover_fallback.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/display_title.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_tag_strip.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// Mock accents shared with the banner (user-endorsed palette).
const kShelfEmerald = Color(0xFF10B981);

/// The mock's "Shelves:" control row + "Favorites: {tag}" poster grid —
/// desktop-exclusive: the shelves strip scopes the grid below it through the
/// SAME [favoritePageProvider] selection the mobile feed reads (rule #22).
class HomeDesktopFeed extends ConsumerWidget {
  const HomeDesktopFeed({super.key});

  /// Test seam for the poster-grid tile-size contract (the resolver lives
  /// on the private [_FavoritesSection]).
  @visibleForTesting
  static int columnsFor(double width) => _FavoritesSection.columnsFor(width);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(
      favoritePageProvider.select((s) => s.favorites),
    );
    final hidden = watchHiddenExtensions(ref);
    final visibleFavorites = hidden.isEmpty
        ? favorites
        : favorites.where((f) => !hidden.contains(f.package)).toList();
    final groups = ref.watch(
      favoritePageProvider.select((s) => s.favoriteGroups),
    );
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShelvesRow(groups: groups, favorites: visibleFavorites),
        const SizedBox(height: 20),
        if (visibleFavorites.isEmpty)
          // Mock library-empty invite (2026-11-12): full-width DASHED-border
          // panel, 56px heart chip, title + subtitle + Browse Extensions —
          // the whole-library empty (filters not involved).
          CustomPaint(
            foregroundPainter: _DashedRoundedBorderPainter(
              color: colors.border,
              radius: context.theme.style.borderRadius.md.topLeft,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: colors.background.withAlpha(77),
                borderRadius: context.theme.style.borderRadius.md,
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.muted.withAlpha(153),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: colors.border),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      FLucideIcons.heart,
                      size: 26,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'home.library_empty_title'.i18n,
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Text(
                      'home.library_empty_subtitle'.i18n,
                      textAlign: .center,
                      style: context.theme.typography.body.xs2.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FButton(
                    variant: .secondary,
                    mainAxisSize: .min,
                    onPress: () => context.push('/extension'),
                    prefix: const Icon(FLucideIcons.blocks, size: 16),
                    child: Text('home.favorites_empty_cta'.i18n),
                  ),
                ],
              ),
            ),
          )
        else
          const _FavoritesSection(),
      ],
    );
  }
}

/// The mock's dashed empty-invite border (Flutter ships no dashed Border).
class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final Radius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));
    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final end = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// The mock's segmented shelf tablist (All + group pills + New Shelf inside
/// one bordered track) with the Manage Tags / View All baseline actions on
/// the row's right edge.
class _ShelvesRow extends ConsumerWidget {
  const _ShelvesRow({required this.groups, required this.favorites});

  final List<FavoriteGroup> groups;
  final List<Favorite> favorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final selected = ref.watch(
      favoritePageProvider.select((s) => s.selectedFavoriteGroups),
    );
    final hidden = watchHiddenExtensions(ref);
    final filterActive = selected.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background.withAlpha(230),
                border: Border.fromBorderSide(BorderSide(color: colors.border)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Row(
                  spacing: 2,
                  children: [
                    FButton(
                      variant: filterActive ? .ghost : .primary,
                      mainAxisSize: .min,
                      onPress: filterActive
                          ? () {
                              final notifier = ref.read(
                                favoritePageProvider.notifier,
                              );
                              for (final group in selected) {
                                notifier.toggleGroupName(group.name);
                              }
                            }
                          : null,
                      style: .delta(
                        contentStyle: FButtonContentStyleDelta.delta(
                          constraints: const BoxConstraints(minHeight: 28),
                          padding: EdgeInsetsGeometryDelta.value(
                            const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      child: Text('${'common.all'.i18n} (${favorites.length})'),
                    ),
                    // Empty collections stay hidden (progressive
                    // disclosure) — and so does a shelf whose every
                    // favorite belongs to a hidden extension.
                    for (final group in groups.where(
                      (g) =>
                          g.favorites.isNotEmpty &&
                          visibleGroupFavorites(g, hidden).isNotEmpty,
                    ))
                      FButton(
                        variant: selected.any((g) => g.name == group.name)
                            ? .primary
                            : .ghost,
                        mainAxisSize: .min,
                        onPress: () => ref
                            .read(favoritePageProvider.notifier)
                            .toggleGroupName(group.name),
                        style: .delta(
                          contentStyle: FButtonContentStyleDelta.delta(
                            constraints: const BoxConstraints(minHeight: 28),
                            padding: EdgeInsetsGeometryDelta.value(
                              const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                        child: Text(
                          '${group.name} (${visibleGroupFavorites(group, hidden).length})',
                        ),
                      ),
                    FButton(
                      variant: .ghost,
                      mainAxisSize: .min,
                      onPress: () =>
                          showCreateFavoriteGroupDialog(context, ref),
                      prefix: const Icon(FLucideIcons.plus, size: 14),
                      style: .delta(
                        contentStyle: FButtonContentStyleDelta.delta(
                          constraints: const BoxConstraints(minHeight: 28),
                          padding: EdgeInsetsGeometryDelta.value(
                            const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      child: Text('home.new_shelf'.i18n),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => showFavoriteGroupSheet(context),
          prefix: const Icon(FLucideIcons.tags, size: 14),
          style: .delta(
            contentStyle: FButtonContentStyleDelta.delta(
              constraints: const BoxConstraints(minHeight: 32),
              padding: EdgeInsetsGeometryDelta.value(
                const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          child: Text('home.manage_tags'.i18n),
        ),
        const SizedBox(width: 8),
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => context.push('/home/favorite'),
          suffix: const Icon(FLucideIcons.chevronRight, size: 14),
          style: .delta(
            contentStyle: FButtonContentStyleDelta.delta(
              constraints: const BoxConstraints(minHeight: 32),
              padding: EdgeInsetsGeometryDelta.value(
                const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          child: Text('home.view_all'.i18n),
        ),
      ],
    );
  }
}

/// "Favorites: {tag}" header + the mock's poster grid (3:4 covers, type chip,
/// emerald heart, source footer line).
class _FavoritesSection extends ConsumerWidget {
  const _FavoritesSection();

  static const _maxCards = 10;
  static const _gap = 20.0;

  /// Mock standard layout (2026-11-12): fixed breakpoint ladder — 2 → 4 →
  /// 5 (lg, the working default) → 7 (2xl). No fluid density scaling.
  static int _columnsFor(double width) {
    if (width >= 1536) return 7;
    if (width >= 1024) return 5;
    if (width >= 768) return 4;
    return 2;
  }

  /// Test seam for the tile-size contract (see the main_page shell tests).
  @visibleForTesting
  static int columnsFor(double width) => _columnsFor(width);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final groups = ref.watch(
      favoritePageProvider.select((s) => s.favoriteGroups),
    );
    final favorites = ref.watch(
      favoritePageProvider.select((s) => s.favorites),
    );
    final hidden = watchHiddenExtensions(ref);
    final visibleFavorites = hidden.isEmpty
        ? favorites
        : favorites.where((f) => !hidden.contains(f.package)).toList();
    final selected = ref.watch(
      favoritePageProvider.select((s) => s.selectedFavoriteGroups),
    );
    final selectedGroups = selected
        .map((g) => groups.where((e) => e.name == g.name).firstOrNull)
        .whereType<FavoriteGroup>()
        .toList();
    final scoped = selectedGroups.isEmpty
        ? visibleFavorites
        : ref
              .read(favoritePageProvider.notifier)
              .favoritesInGroups(selectedGroups);
    final items = scoped
        .where(
          (f) =>
              !state.filtersByType ||
              stringToExtensionType(f.type) == state.type,
        )
        .take(_maxCards)
        .toList();
    if (items.isEmpty) {
      // A scoped shelf (or type filter) matched nothing — say so instead of
      // dropping a blank gap between the strip and the next section.
      return HomeEmpty(
        icon: FLucideIcons.imageOff,
        text: 'home.shelf_empty'.i18n,
        action: FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () {
            final notifier = ref.read(favoritePageProvider.notifier);
            for (final group in selected) {
              notifier.toggleGroupName(group.name);
            }
          },
          child: Text('home.shelf_empty_cta'.i18n),
        ),
      );
    }

    // Mock rev 3: the shelves tablist above IS this section's header — no
    // separate "Favorites: tag" row.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = _columnsFor(constraints.maxWidth);
            final width =
                (constraints.maxWidth - _gap * (columns - 1)) / columns;
            // Transient layouts (route transitions) can hand down a
            // near-zero width — never pass a negative tile width on.
            if (width < 0) return const SizedBox.shrink();
            return Wrap(
              spacing: _gap,
              runSpacing: _gap,
              children: [
                for (final item in items)
                  _FavoriteCard(
                    key: ValueKey(item.url),
                    item: item,
                    width: width,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// One shelf card (mock standard layout, 2026-11-12): 2:3 poster with a
/// type chip + colored source badge on hover-scale art, a hover scrim with a
/// type-based action button, then a 14px-padded footer with a 2-line title
/// and an `updated <timeAgo>` meta line. The mock's score, airing and
/// progress fields have no backing data in [Favorite] and are intentionally
/// absent.
class _FavoriteCard extends HookConsumerWidget {
  const _FavoriteCard({super.key, required this.item, required this.width});

  final Favorite item;
  final double width;

  /// The mock's cycling source-badge accent palette (emerald/amber/purple/
  /// sky), picked by a stable FNV-1a hash of the package name — not
  /// [String.hashCode], which varies run to run.
  static const _sourceAccents = [
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFA855F7),
    Color(0xFF38BDF8),
  ];

  static int _fnv(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final type = stringToExtensionType(item.type);
    final hovering = useState(false);
    final sourceName = ref
        .watch(extensionPageProvider.select((s) => s.metaData))
        .where((e) => e.packageName == item.package)
        .firstOrNull
        ?.name;
    return SizedBox(
      key: const Key('desktopShelfCard'),
      // Constrains the AnimatedBox from OUTSIDE: RenderBounce sizes itself to
      // the biggest available constraints, so a Wrap child must be pre-sized.
      width: width,
      child: DecoratedBox(
        // The mock's `shadow-sm` lift under the rounded card.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors.foreground.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBox.nopadding(
          onTap: () => pushFavoriteDetail(context, ref, item),
          child: MiruCard(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MouseRegion(
                  onEnter: (_) => hovering.value = true,
                  onExit: (_) => hovering.value = false,
                  child: Stack(
                    children: [
                      // Artwork hover-drifts to 1.05 (mock hover:scale-105);
                      // the Stack's hard clip + MiruCard's antiAlias keep the
                      // scaled image inside the card's rounded frame.
                      AnimatedScale(
                        scale: hovering.value ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: AspectRatio(
                          // The mock's 2:3 poster ratio (aspect-[2/3]).
                          aspectRatio: 2 / 3,
                          child: ImageWidget(
                            imageUrl: item.cover ?? '',
                            fit: BoxFit.cover,
                            borderRadius: 0,
                            errChild: const HomeCoverFallback(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          children: [
                            HomeChip(
                              icon: switch (type) {
                                ExtensionType.bangumi => FLucideIcons.play,
                                ExtensionType.manga => FLucideIcons.bookOpen,
                                _ => FLucideIcons.bookMarked,
                              },
                              label: searchExtensionTypeLabel(type),
                            ),
                            const SizedBox(width: 6),
                            SmallBadge(
                              label: sourceName ?? item.package,
                              labelColor:
                                  _sourceAccents[_fnv(item.package) %
                                      _sourceAccents.length],
                            ),
                          ],
                        ),
                      ),
                      // Always-visible favorite heart (mock rev 4: posters
                      // carry their state permanently — no hover overlay).
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.background.withAlpha(179),
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: colors.border),
                            ),
                          ),
                          child: Icon(
                            FLucideIcons.heart,
                            size: 15,
                            color: kShelfDotColors.first,
                          ),
                        ),
                      ),
                      // Hover scrim + type-based action button (mock: the
                      // gradient overlay with the full-width primary CTA).
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: !hovering.value,
                          child: AnimatedOpacity(
                            opacity: hovering.value ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  stops: const [0, 0.4],
                                  colors: [
                                    colors.background.withAlpha(230),
                                    colors.background.withAlpha(0),
                                  ],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: FButton(
                                      variant: .primary,
                                      size: .sm,
                                      onPress: () => pushFavoriteDetail(
                                        context,
                                        ref,
                                        item,
                                      ),
                                      prefix: Icon(
                                        type == ExtensionType.bangumi
                                            ? FLucideIcons.play
                                            : FLucideIcons.bookOpen,
                                        size: 14,
                                      ),
                                      child: Text(
                                        (type == ExtensionType.bangumi
                                                ? 'home.watch'
                                                : 'home.read')
                                            .i18n,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: displayTitle(item.title),
                        child: Text(
                          displayTitle(item.title),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTimeAgo(item.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.body.xs2.copyWith(
                          color: colors.mutedForeground,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Detail push with the uninstalled-source guard: a favorite whose extension
/// is gone is not tappable.
void pushFavoriteDetail(BuildContext context, WidgetRef ref, Favorite item) {
  final meta = ref.read(extensionPageProvider).metaData;
  final extMeta = meta.where((e) => e.packageName == item.package).firstOrNull;
  if (extMeta == null) return;
  context.push(
    '/search/single/detail',
    extra: DetailParam(meta: extMeta, url: item.url),
  );
}
