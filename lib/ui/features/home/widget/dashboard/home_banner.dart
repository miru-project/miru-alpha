import 'dart:math' as math;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/home_banner_model.dart';
import 'package:miru_alpha/provider/home/home_banner_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_cover_fallback.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner_skeleton.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';

/// How long the skeleton stays up after data arrives, so a fast catalogue
/// fetch (~100-300ms) is still perceivable as a loading state instead of a
/// content flash.
const kBannerSkeletonMinVisible = Duration(milliseconds: 600);

/// True while the banner should render its skeleton: the fetch is in flight,
/// or it just completed and the minimum-visible window is still open.
bool _useSkeletonVisible(bool isLoading) {
  final show = useState(isLoading);
  useEffect(() {
    if (isLoading) {
      show.value = true;
      return null;
    }
    final timer = Timer(kBannerSkeletonMinVisible, () => show.value = false);
    return timer.cancel;
  }, [isLoading]);
  return show.value;
}

/// Home hero banner section: a PageView carousel over the selected catalogue
/// slice (TMDB new-on-streaming movie/show, AniList trending anime/manga).
///
/// Layout follows the desktop command-center mock: full-bleed artwork, left +
/// bottom scrims, and a badge row that CARRIES the selection UI — rank/score
/// chips, a format picker chip and the "Source: {name}" dropdown button
/// (mock 2026-11-04 rev 2) — then title + synopsis, the CTA row and the glass
/// carousel cluster (dots, counter, prev/next). Manual navigation only — the
/// mock carries no autoplay. Desktop-layout exclusive.
class HomeBannerSection extends HookConsumerWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(homeBannerSelectionProvider);
    final banner = ref.watch(homeBannerProvider);
    final skeletonVisible = _useSkeletonVisible(banner.isLoading);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed hero height (2026-11-12, user directive): the mock's
        // `min-h-[340px]` — constant across window sizes, no responsive
        // 280/300 swap.
        const height = 340.0;
        // Skeleton first — including the linger after a fast failure — so
        // every phase swap reads as skeleton → outcome, never empty-box.
        if (skeletonVisible) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeBannerSkeleton(height: height),
          );
        }
        if (banner.hasError) {
          return _bannerFramed(
            selection: selection,
            child: _BannerError(height: height, error: banner.error),
          );
        }
        final items = banner.value ?? const [];
        if (items.isEmpty) {
          return _bannerFramed(
            selection: selection,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: height,
                child: HomeEmpty(text: 'home.banner.empty'.i18n),
              ),
            ),
          );
        }
        return _bannerFramed(
          selection: selection,
          child: _BannerCarousel(
            key: ValueKey((selection.source, selection.format)),
            items: items,
            height: height,
            selection: selection,
          ),
        );
      },
    );
  }

  /// Overlays the catalogue picker on a non-skeleton state. The CHILD owns
  /// its own 16px gutter (carousel/error both carry one) — the frame adds no
  /// padding, or the parity contract with the skeleton shifts. Visible on
  /// error/empty too, so a missing TMDB key never traps the user on a dead
  /// banner (switch back to AniList right there).
  Widget _bannerFramed({
    required HomeBannerSelectionState selection,
    required Widget child,
  }) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 28,
          top: 12,
          child: _BannerCataloguePicker(
            key: const Key('bannerCataloguePicker'),
            selection: selection,
          ),
        ),
      ],
    );
  }
}

class _BannerCarousel extends HookConsumerWidget {
  const _BannerCarousel({
    super.key,
    required this.items,
    required this.height,
    required this.selection,
  });

  final List<HomeBannerItem> items;
  final double height;
  final HomeBannerSelectionState selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Recreated per catalogue switch: a stale page index can outlive the old
    // item count.
    final controller = usePageController(
      keys: [selection.source, selection.format],
    );
    final index = useState(0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: context.theme.style.borderRadius.lg,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: controller,
                itemCount: items.length,
                onPageChanged: (page) => index.value = page,
                itemBuilder: (context, page) => _BannerSlide(
                  item: items[page],
                  formatLabel: selection.format.i18nKey.i18n,
                  selection: selection,
                ),
              ),
              Positioned(
                left: 16,
                right: 12,
                bottom: 12,
                child: _BannerDock(
                  controller: controller,
                  items: items,
                  index: index.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The catalogue picker docked at the banner's top-left (the mock's
/// editorial top row, now functional): the source tabs (AniList | TMDB) and
/// the selected source's format chips (Movie/TV Show, Anime/Manga) on the
/// dock's frosted glass. Switching the source resets the format and the
/// provider refetches (the banner watches the selection); switching to TMDB
/// without a configured key lands on the key-hint error state, where this
/// picker stays reachable.
class _BannerCataloguePicker extends ConsumerWidget {
  const _BannerCataloguePicker({super.key, required this.selection});

  final HomeBannerSelectionState selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background.withAlpha(204),
            borderRadius: BorderRadius.circular(10),
            border: Border.fromBorderSide(BorderSide(color: colors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                for (final source in HomeBannerSource.values)
                  _PickerChip(
                    label: source.label,
                    selected: selection.source == source,
                    onTap: () => ref
                        .read(homeBannerSelectionProvider.notifier)
                        .setSource(source),
                  ),
                if (selection.source.formats.length > 1) ...[
                  Container(width: 1, height: 16, color: colors.border),
                  for (final format in selection.source.formats)
                    _PickerChip(
                      label: format.i18nKey.i18n,
                      selected: selection.format == format,
                      onTap: () => ref
                          .read(homeBannerSelectionProvider.notifier)
                          .setFormat(format),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One picker tab: forui's own secondary fill when active, ghost otherwise.
class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: selected ? .secondary : .ghost,
      mainAxisSize: .min,
      onPress: onTap,
      style: .delta(
        contentStyle: FButtonContentStyleDelta.delta(
          constraints: const BoxConstraints(minHeight: 24),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
      // The label keeps forui's own style; the selected state reads through
      // the secondary fill alone (a base TextStyle override would drop the
      // variant's label colour).
      child: Text(label),
    );
  }
}

/// The mock's accent pair (emerald rank/dots, amber star) — mock-specified
/// accents, not theme-primary, per the desktop command-center reference.
const kBannerEmerald = Color(0xFF10B981);
const kBannerAmber = Color(0xFFFBBF24);

/// Bottom-right interactive dock (mock rev 4): the trending-queue header
/// ("n / N" + prev/next) over a strip of mini thumbnails — tapping one
/// animates the carousel to that page; the active thumbnail carries the
/// foreground border and the emerald progress hairline. Adaptive: the
/// thumbnail count shrinks with the available width (1..4).
class _BannerDock extends StatelessWidget {
  const _BannerDock({
    required this.controller,
    required this.items,
    required this.index,
  });

  final PageController controller;
  final List<HomeBannerItem> items;
  final int index;

  static const _slotCost = 72.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Align(
      alignment: Alignment.bottomRight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxThumbs =
              ((constraints.maxWidth - 20 - 130) ~/ _BannerDock._slotCost)
                  .clamp(1, 4);
          return ClipRRect(
            key: const Key('bannerCarouselCluster'),
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.background.withAlpha(204),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.fromBorderSide(
                    BorderSide(color: colors.border),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'home.dock_queue'.i18n.fill({
                              'count': '${index + 1} / ${items.length}',
                            }),
                            style: typography.body.xs2.copyWith(
                              color: colors.mutedForeground,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ClusterArrow(
                            icon: FLucideIcons.chevronLeft,
                            enabled: index > 0,
                            onTap: () => controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          _ClusterArrow(
                            icon: FLucideIcons.chevronRight,
                            enabled: index < items.length - 1,
                            onTap: () => controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final (i, item) in items.take(maxThumbs).indexed)
                            GestureDetector(
                              onTap: () => controller.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              ),
                              child: Opacity(
                                opacity: i == index ? 1 : 0.75,
                                child: Container(
                                  width: 64,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 8),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: i == index
                                          ? colors.foreground
                                          : colors.border,
                                      width: i == index ? 2 : 1,
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ImageWidget(
                                        imageUrl: item.backdrop,
                                        fit: BoxFit.cover,
                                        borderRadius: 0,
                                        errChild: const HomeCoverFallback(
                                          showLabel: false,
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          height: i == index ? 2 : 0,
                                          color: i == index
                                              ? kBannerEmerald
                                              : const Color(0x00000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The mock's hover drift: the artwork scales to 1.02 over 700ms while the
/// pointer is over the slide.
class _HoverScale extends StatefulWidget {
  const _HoverScale({required this.child});

  final Widget child;

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// One slide: hover-drifting artwork, WCAG scrims and the bottom-anchored
/// eyebrow → title → synopsis → CTA stack (mock rev 3: the badge chips and
/// the source/format pickers are gone — the eyebrow line carries rank,
/// format and score).
class _BannerSlide extends StatelessWidget {
  const _BannerSlide({
    required this.item,
    required this.formatLabel,
    required this.selection,
  });

  final HomeBannerItem item;

  /// The selection's format label, uppercased in the eyebrow (mock:
  /// "BANGUMI MOVIE").
  final String formatLabel;
  final HomeBannerSelectionState selection;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _HoverScale(
          child: ImageWidget(
            imageUrl: item.backdrop,
            fit: BoxFit.cover,
            borderRadius: 0,
            errChild: const HomeCoverFallback(showLabel: false),
          ),
        ),
        // Multi-directional scrim: left rail for text, bottom for the cluster
        // (mock: via-75% left, via-85% bottom — AA contrast over bright art).
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF09090B), Color(0xBF09090B), Color(0x0009090B)],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF09090B), Color(0xD909090B), Color(0x3309090B)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // (The mock's editorial top row — For You / Trending / Upcoming /
        // Top Rated pills + the "source · Trending Popularity" badge — was
        // removed 2026-11-12: static decoration, no backed modes, no tap
        // targets; the eyebrow line under it already carries the context.)
        // The mock scopes the hero's text stack to max-w-xl (576px) so it
        // never runs underneath the bottom-right thumbnail dock; below the
        // mock's 1280 canvas the cap shrinks by the dock's actual footprint
        // (4 thumbnails + header + gutters ≈ 452px) minus a 16px gutter.
        Padding(
          padding: const EdgeInsets.all(16),
          // Align loosens the StackFit.expand tight constraints so the cap
          // can actually bind; bottomLeft keeps the hero anchored.
          child: Align(
            alignment: Alignment.bottomLeft,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textWidth = math.min(
                  576.0,
                  math.max(300.0, constraints.maxWidth - 344),
                );
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: textWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ChipRow(
                        item: item,
                        formatLabel: formatLabel,
                        selection: selection,
                      ),
                      const SizedBox(height: 8),
                      _Title(item: item),
                      const SizedBox(height: 8),
                      if (item.description?.isNotEmpty ?? false)
                        Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.xs2.copyWith(
                            color: const Color(0xD4FFFFFF),
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 12),
                      _BannerActions(item: item),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// The mock's chip row: rank pill (emerald), format label, score pill and
/// the episode pill. Hard-coded light values — the canvas is always dark
/// (the loaded slide scrims hardcode the 0x09090B base regardless of theme).
class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.item,
    required this.formatLabel,
    required this.selection,
  });

  final HomeBannerItem item;
  final String formatLabel;
  final HomeBannerSelectionState selection;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: kBannerEmerald.withAlpha(26),
            border: Border.all(color: kBannerEmerald.withAlpha(77)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '#${item.rank} Trending',
            style: context.theme.typography.body.xs2.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: kBannerEmerald,
            ),
          ),
        ),
        Text(
          formatLabel,
          style: context.theme.typography.body.xs2.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xA3FFFFFF),
          ),
        ),
        const Text('•', style: TextStyle(color: Color(0x66FFFFFF))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0x1418181B),
            border: Border.all(color: const Color(0xFF3F3F46)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FLucideIcons.star, size: 12, color: kBannerAmber),
              const SizedBox(width: 4),
              if (item.score case final score?)
                Text(
                  '${score.toStringAsFixed(1)} / 10',
                  style: context.theme.typography.body.xs2.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xF2FFFFFF),
                  ),
                ),
            ],
          ),
        ),
        if (item.episodeCount != null) ...[
          const Text('•', style: TextStyle(color: Color(0x66FFFFFF))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x1418181B),
              border: Border.all(color: const Color(0xFF3F3F46)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'home.episode_chip'.i18n.fill({'n': '${item.episodeCount}'}),
              style: context.theme.typography.body.xs2.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xD4FFFFFF),
              ),
            ),
          ),
        ],
        const Text('•', style: TextStyle(color: Color(0x66FFFFFF))),
        // The catalogue anchor (mock: "AniList #4") — which source ranks
        // this entry and at what position.
        Text(
          '${selection.source.label} #${item.rank}',
          style: context.theme.typography.body.xs2.copyWith(
            color: const Color(0xFF8E9192),
          ),
        ),
      ],
    );
  }
}

/// Title + secondary title; the mock's 2xl heading, scaled to the banner.
class _Title extends StatelessWidget {
  const _Title({required this.item});

  final HomeBannerItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xl3.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.2,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        if (item.subtitle case final subtitle?
            when subtitle.isNotEmpty && subtitle != item.title)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs2.copyWith(
                color: const Color(0xA3FFFFFF),
              ),
            ),
          ),
      ],
    );
  }
}

/// The mock's CTA row: "Start Watching" (searches the title across installed
/// extensions), "Bookmark to Shelf" (AniList Planning — AniList items with a
/// linked account only) and the spec tag (ep/ch count when reported).
class _BannerActions extends ConsumerWidget {
  const _BannerActions({required this.item});

  final HomeBannerItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linked =
        ref.watch(anilistAccountProvider.select((a) => a.value != null)) &&
        item.anilistMediaId != null;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FButton(
          variant: .primary,
          mainAxisSize: .min,
          onPress: () => context.push('/search/input', extra: item.title),
          prefix: const Icon(FLucideIcons.play, size: 14),
          child: Text('home.banner.watch'.i18n),
        ),
        if (linked)
          FButton(
            variant: .outline,
            mainAxisSize: .min,
            onPress: () => _bookmark(context),
            prefix: const Icon(FLucideIcons.plus, size: 14),
            child: Text('home.banner.bookmark'.i18n),
          ),
        FButton.icon(
          variant: .outline,
          onPress: item.externalUrl == null ? null : () => _openDetails(),
          child: const Icon(FLucideIcons.info, size: 16),
        ),
      ],
    );
  }

  /// The mock's "Media Details" square: opens the catalogue entry's source
  /// page (AniList / TMDB) — a banner item has no extension package to push
  /// the in-app detail route with.
  Future<void> _openDetails() async {
    final url = item.externalUrl;
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _bookmark(BuildContext context) async {
    try {
      await AniListProvider.editList(
        status: AnilistMediaListStatus.planning,
        mediaId: item.anilistMediaId,
      );
      showSimpleToast('home.banner.bookmarked'.i18n);
    } catch (_) {
      showSimpleToast('common.error'.i18n);
    }
  }
}

class _ClusterArrow extends StatelessWidget {
  const _ClusterArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      variant: .ghost,
      size: .sm,
      onPress: enabled ? onTap : null,
      child: Icon(icon, size: 18),
    );
  }
}

/// Error state: a TMDB key hint when that is the cause, generic offline text
/// otherwise, plus retry.
class _BannerError extends ConsumerWidget {
  const _BannerError({required this.height, required this.error});

  final double height;
  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noKey = error is TmdbApiKeyMissingException;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: height,
        child: HomeEmpty(
          text: noKey ? 'home.banner.no_key'.i18n : 'home.banner.offline'.i18n,
          icon: noKey ? FLucideIcons.keyRound : FLucideIcons.cloudAlert,
          action: FButton(
            variant: .outline,
            mainAxisSize: .min,
            onPress: () => ref.read(homeBannerProvider.notifier).refresh(),
            child: Text('search.retry'.i18n),
          ),
        ),
      ),
    );
  }
}
