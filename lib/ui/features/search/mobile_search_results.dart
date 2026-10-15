import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/search/global_search_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// Subsystem logger for the relevance prefetch, so a live run can be read off
/// [MiruLog] instead of guessed at.
final _searchFetchLog = Logger('${logger.name}.searchFetch');

/// Aggregation bar: how many hits, from how many sources, and how far along.
class MobileSearchStatusBar extends ConsumerWidget {
  const MobileSearchStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aggregate = ref.watch(globalSearchAggregateProvider);
    final colors = context.theme.colors;

    final sources = aggregate.entries.map((e) => e.meta.name).toSet().length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: colors.secondary.withAlpha(60),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                FLucideIcons.layers,
                size: 15,
                color: colors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            (aggregate.entries.length == 1
                                    ? 'search.result_one'
                                    : 'search.results_count')
                                .i18n
                                .fill({'count': '${aggregate.entries.length}'}),
                        style: context.theme.typography.body.xs2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.foreground,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' · ${'search.across_sources'.i18n.fill({'count': '$sources'})}',
                        style: context.theme.typography.body.xs2.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'search.sources_done'.i18n.fill({
                  'done': '${aggregate.done}',
                  'total': '${aggregate.total}',
                }),
                style: context.theme.typography.body.xs2.copyWith(
                  fontFamily: 'monospace',
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
          // A failed source is the one detail the summary must never ellipsise
          // away, so it owns its own line.
          if (aggregate.failed.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  FLucideIcons.circleAlert,
                  size: 13,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'search.failed_sources'.i18n.fill({
                      'names': aggregate.failed.join(', '),
                    }),
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (aggregate.failedPackages.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  FTappable(
                    onPress: () => ref
                        .read(globalSearchPagesProvider.notifier)
                        .retryFailed(
                          aggregate.failedPackages,
                          ref.read(searchPageProvider).query.trim(),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'search.retry'.i18n,
                        style: context.theme.typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.theme.colors.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Scrollable aggregated results in the mode the header's segmented control
/// picked: one flat grid ordered by relevance, or one shelf per extension.
class MobileSearchResultsBody extends HookConsumerWidget {
  const MobileSearchResultsBody({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageProvider);
    final aggregate = ref.watch(globalSearchAggregateProvider);

    final entries = useMemoized(
      () => orderGlobalResults(aggregate.entries, state.sort, query),
      [aggregate, state.sort, query],
    );

    if (aggregate.total == 0) {
      return _EmptyResults(
        icon: FLucideIcons.puzzle,
        message: state.scopeMode == SearchScopeMode.pinned
            ? 'search.no_pinned'.i18n
            : 'extension.no_extensions_installed'.i18n,
      );
    }

    // Siblings of each hit inside its own source, so the detail page's
    // previous/next navigation stays inside one extension's result list.
    final bySource = <String, List<GlobalSearchEntry>>{};
    for (final entry in entries) {
      bySource.putIfAbsent(entry.meta.packageName, () => []).add(entry);
    }

    // Prefetch, like the single-extension page: no Load-more button, and not a
    // scroll-to-the-bottom trigger either — the next page is bought when fewer
    // than [kPrefetchUnseenThreshold] hits are still below the reader, and the
    // hits on the wire sit behind skeleton cards.
    //
    // `hasMore` deliberately reads false while a request is out (a page that
    // settles empty is what stops a source), so `loadingMore` is what keeps
    // the skeletons painted during the wait — the one state `hasMore` alone
    // cannot describe.
    final loadingMore = aggregate.pages > 1 && aggregate.isPending;
    final showSkeletons =
        state.resultsViewMode == ResultsViewMode.relevance &&
        (aggregate.hasMore || loadingMore);

    // Pages currently on the wire; the allocation latch compares against it.
    final depth = ref.watch(globalSearchPagesProvider);

    // One allocation per settled state: set when a page is bought, dropped
    // once that fetch is visibly under way, once the depth moves under us
    // (pull-to-refresh / reset rewinding it), or once hits arrive without the
    // pending state having been observed (a cached page). Without the latch a
    // scroll tick and the settle check can both ask for the same page.
    final latchedDepth = useRef<Map<String, int>?>(null);
    final latchedEntries = useRef(-1);
    final sawPending = useRef(false);
    useEffect(() {
      void clearLatch() {
        latchedDepth.value = null;
        latchedEntries.value = -1;
      }

      if (aggregate.isPending) {
        sawPending.value = true;
        clearLatch();
        return null;
      }
      if (sawPending.value || latchedEntries.value != entries.length) {
        sawPending.value = false;
        clearLatch();
        return null;
      }
      if (latchedDepth.value != null && !mapEquals(latchedDepth.value, depth)) {
        clearLatch();
      }
      return null;
    }, [aggregate, depth, entries.length]);

    // Width of the grid the reader scrolls: the LayoutBuilder at the bottom
    // writes it during layout, before the post-frame check reads it.
    final gridWidth = useRef(0.0);
    final loggedAt = useRef(DateTime(2000));

    final scrollController = useScrollController();

    void prefetch() {
      if (!context.mounted) return;
      if (latchedDepth.value != null) return;
      if (state.resultsViewMode != ResultsViewMode.relevance) return;
      if (aggregate.isPending || !aggregate.hasMore) return;
      if (entries.isEmpty) return;
      if (!scrollController.hasClients || gridWidth.value <= 0) return;

      // Hits still below the fold: rows on screen (from the scroll offset) ×
      // the grid's two columns, against everything that has arrived.
      final position = scrollController.position;
      final cardWidth = (gridWidth.value - kSearchGridGap) / 2;
      final rowHeight = cardWidth / kSearchCardAspectRatio + kSearchGridGap;
      final rowsShown =
          ((position.pixels + position.viewportDimension) / rowHeight).ceil();
      final seen = math.min(entries.length, rowsShown * 2);
      final unseen = entries.length - seen;
      final now = DateTime.now();
      if (now.difference(loggedAt.value).inMilliseconds > 500) {
        loggedAt.value = now;
        _searchFetchLog.fine(
          'px=${position.pixels.toStringAsFixed(0)} '
          'vp=${position.viewportDimension.toStringAsFixed(0)} '
          'rows=$rowsShown seen=$seen unseen=$unseen '
          'latched=${latchedDepth.value} pending=${aggregate.isPending} '
          'more=${aggregate.hasMore}',
        );
      }
      if (unseen >= kPrefetchUnseenThreshold) return;

      // Buffer is running dry: the predictor picks who refills it.
      final pkg = pickNextFetchPackage(aggregate, query);
      if (pkg == null) return;
      ref.read(globalSearchPagesProvider.notifier).loadMore(pkg);
      latchedDepth.value = ref.read(globalSearchPagesProvider);
      latchedEntries.value = entries.length;
      _searchFetchLog.info(
        'fire winner=$pkg depth=${latchedDepth.value} unseen=$unseen '
        'px=${position.pixels.toStringAsFixed(0)}',
      );
    }

    // Always-latest closure for the two listeners below: they are registered
    // once, but the state they read is rebuilt every frame.
    final runPrefetch = useRef<void Function()>(() {});
    runPrefetch.value = prefetch;

    useEffect(() {
      void onScroll() => runPrefetch.value();
      scrollController.addListener(onScroll);
      // Microtasks run after this frame's layout, so the grid width and the
      // scroll extents are real — the case where the grid is shorter than the
      // viewport and no scroll event will ever fire.
      Future.microtask(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    // A page landing has to re-check too: the reader may be sitting still.
    useEffect(() {
      Future.microtask(() => runPrefetch.value());
      return null;
    }, [aggregate, entries.length]);

    final List<Widget> content;
    if (state.resultsViewMode == ResultsViewMode.byExtension) {
      content = _byExtensionSlivers(
        context,
        entries,
        bySource,
        state,
        aggregate,
      );
    } else {
      content = [
        SliverPadding(
          padding: const EdgeInsets.only(top: kSearchHeaderGap),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: kSearchGridGap,
              mainAxisSpacing: kSearchGridGap,
              childAspectRatio: kSearchCardAspectRatio,
            ),
            itemCount:
                entries.length + (showSkeletons ? kSearchSkeletonCount : 0),
            itemBuilder: (context, index) {
              if (index >= entries.length) {
                return const MobileTileLoadingBox();
              }
              return _PosterCard(
                entry: entries[index],
                siblings: bySource[entries[index].meta.packageName]!,
              );
            },
          ),
        ),
      ];
    }

    final list = CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverToBoxAdapter(child: MobileSearchStatusBar()),
        const SliverToBoxAdapter(child: SizedBox(height: kSearchLabelGap)),
        ...content,
        if (entries.isEmpty && !aggregate.isPending)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: _EmptyInlineMessage(),
            ),
          ),
        // Skeletons already say "more is coming"; the spinner is the first
        // page's own loading state and would only duplicate them.
        if (aggregate.isPending && !showSkeletons) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: Center(child: FCircularProgress())),
        ],
      ],
    );

    // The layout width is what turns "how many hits are still below the
    // reader" into rows: written here, during layout, before the post-frame
    // prefetch check reads it.
    return LayoutBuilder(
      builder: (context, constraints) {
        gridWidth.value = constraints.maxWidth;

        // Pull-to-refresh wraps the vertical list. In By-Extension mode the
        // body nests horizontal rails, and EasyRefresh's indicator can't tell
        // the two scroll axes apart (its OverflowBox goes infinite), so that
        // mode refreshes from the field instead.
        if (state.resultsViewMode == ResultsViewMode.byExtension) return list;

        return EasyRefresh(
          header: const ForuiHeader(),
          onRefresh: () async {
            _searchFetchLog.info('pull-to-refresh');
            ref
                .read(globalSearchPagesProvider.notifier)
                .refresh(
                  ref.read(searchPageProvider).searchScopePackages.toList(),
                  query,
                );
          },
          child: list,
        );
      },
    );
  }

  /// One shelf per source that returned something, plus a muted footer for the
  /// sources that returned nothing (the mockup's "86 queried extensions
  /// returned empty" row).
  List<Widget> _byExtensionSlivers(
    BuildContext context,
    List<GlobalSearchEntry> entries,
    Map<String, List<GlobalSearchEntry>> bySource,
    SearchPageState state,
    GlobalSearchAggregate aggregate,
  ) {
    final settledWithHits = {
      for (final entry in entries) entry.meta.packageName,
    };
    final emptyNames = [
      for (final meta in state.filteredMetaData)
        if (state.searchScopePackages.contains(meta.packageName) &&
            !settledWithHits.contains(meta.packageName))
          meta.name,
    ];

    return [
      for (final sourceEntries in bySource.values)
        SliverToBoxAdapter(
          child: _ExtensionShelf(
            meta: sourceEntries.first.meta,
            entries: sourceEntries,
            siblings: sourceEntries,
            query: query,
          ),
        ),
      if (emptyNames.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: kSearchSectionGap),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.theme.colors.secondary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.theme.colors.border.withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.inbox,
                    size: 16,
                    color: context.theme.colors.mutedForeground,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'search.empty_shelves'.i18n,
                          style: context.theme.typography.body.xs2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'search.empty_shelves_desc'.i18n.fill({
                            'count': '${emptyNames.length}',
                          }),
                          style: context.theme.typography.body.xs.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }
}

/// The poster card: 3:4 cover, optional source tag on the image, title and
/// action below — the mockup's media card.
///
/// `showSource` is on in the flat grid (the source is not visible anywhere
/// else there) and off on the By-Extension rail, where the shelf header
/// already names the source and repeating it on every poster is redundant.
class _PosterCard extends StatelessWidget {
  const _PosterCard({
    required this.entry,
    required this.siblings,
    this.showSource = true,
  });

  final GlobalSearchEntry entry;
  final List<GlobalSearchEntry> siblings;
  final bool showSource;

  DetailParam get _detail => DetailParam(
    meta: entry.meta,
    url: entry.item.url,
    items: [for (final sibling in siblings) sibling.item],
    index: siblings.indexOf(entry),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final meta = entry.meta;
    final item = entry.item;

    // Card ratio == image ratio (0.65): the cover is the card, full bleed,
    // with title + description overlaid on a bottom gradient — the same
    // language as the single-extension grid's `MiruMobileTile`.
    return FTappable(
      onPress: () => context.push('/search/single/detail', extra: _detail),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageWidget(imageUrl: item.cover, fit: BoxFit.cover),
            // Bottom gradient: the overlay text's legibility layer.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 96,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: context.theme.typography.body.xs2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // The extension's own @description, not the raw update
                  // string — the informative line the API already provides.
                  if (meta.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta.description!,
                      style: context.theme.typography.body.xs.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (showSource)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background.withAlpha(230),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: kSearchStatusDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meta.name,
                        style: context.theme.typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One source's results as a shelf: a tappable header (icon, name, count —
/// pushes the extension's own search page with the keyword), then a
/// horizontal poster rail.
class _ExtensionShelf extends HookConsumerWidget {
  const _ExtensionShelf({
    required this.meta,
    required this.entries,
    required this.siblings,
    required this.query,
  });

  final ExtensionMeta meta;
  final List<GlobalSearchEntry> entries;
  final List<GlobalSearchEntry> siblings;

  /// The keyword being searched, handed to the extension's own page when the
  /// header is tapped.
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.only(top: kSearchSectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tapping the header opens the extension's own search page with the
          // same keyword — the shelf is a preview, the source is one tap away.
          FTappable(
            onPress: () => context.push(
              '/search/single',
              extra: SearchPageParam(meta: meta, query: query),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, kSearchLabelGap),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: meta.icon == null || meta.icon!.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              meta.name.isEmpty
                                  ? '?'
                                  : meta.name[0].toUpperCase(),
                              style: context.theme.typography.body.xs.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageWidget(
                              imageUrl: meta.icon,
                              width: 24,
                              height: 24,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meta.name,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    (entries.length == 1
                            ? 'search.result_one'
                            : 'search.results_count')
                        .i18n
                        .fill({'count': '${entries.length}'}),
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Horizontal rail: one card per hit, scrolling sideways. The rail
          // height is the card's own: width 118 at the 0.65 image ratio.
          // The source name stays in the shelf header — repeating it on every
          // poster is redundant.
          SizedBox(
            height: 118 / kSearchCardAspectRatio,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => SizedBox(
                width: 118,
                child: _PosterCard(
                  entry: entries[index],
                  siblings: siblings,
                  showSource: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInlineMessage extends StatelessWidget {
  const _EmptyInlineMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'search.no_results'.i18n.fill({'query': ''}),
      textAlign: TextAlign.center,
      style: context.theme.typography.body.xs2.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(icon, size: 32, color: context.theme.colors.mutedForeground),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs2.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How few hits may still be below the reader before the next page is bought:
/// the prefetch trigger, measured in items rather than pixels, so a long list
/// and a short one keep the same runway ahead of the reader.
const int kPrefetchUnseenThreshold = 10;

/// The gap the two-column relevance grid leaves between cards. Row maths and
/// the grid delegate both read it, so "how much is still unseen" can never
/// drift away from the layout it is computed from.
const double kSearchGridGap = 10;
