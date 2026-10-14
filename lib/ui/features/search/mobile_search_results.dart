import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/search/global_search_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

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

    // Infinite scroll, like the single-extension page: no Load-more button —
    // the next page is asked for when the reader reaches the grid's end, and
    // the hits still on the wire sit behind skeleton cards.
    //
    // `hasMore` deliberately reads false while a request is out (a page that
    // settles empty is what stops the depth), so `loadingMore` is what keeps
    // the skeletons painted during the wait — the one state `hasMore` alone
    // cannot describe.
    final loadingMore = aggregate.pages > 1 && aggregate.isPending;
    final canLoadMore =
        aggregate.hasMore &&
        !loadingMore &&
        state.resultsViewMode == ResultsViewMode.relevance;
    final showSkeletons =
        state.resultsViewMode == ResultsViewMode.relevance &&
        (aggregate.hasMore || loadingMore);

    // Page depth the body last asked for; lets the scroll listener and the
    // post-frame check below agree on one request per settled page.
    final requestedFor = useRef(-1);

    // The depth actually on the wire, watched directly: a pull-to-refresh (or
    // a query change) rewinds it to one, which makes every page fair game
    // again — without forgetting the last ask here, the trigger would treat
    // the next settled page as a duplicate and stop paging for good.
    final depth = ref.watch(globalSearchPagesProvider);
    if (requestedFor.value >= depth) requestedFor.value = -1;

    final scrollController = useScrollController();
    useEffect(() {
      void maybeLoadMore() {
        if (!canLoadMore || !context.mounted) return;
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        // Content still overflows and the reader is nowhere near the end:
        // paging is theirs to trigger.
        if (position.pixels < position.maxScrollExtent - kLoadMoreTriggerGap) {
          return;
        }
        // One request per settled page depth, so a scroll tick and the
        // post-frame check below can never both ask for the same page.
        if (requestedFor.value == aggregate.pages) return;
        requestedFor.value = aggregate.pages;
        ref.read(globalSearchPagesProvider.notifier).loadMore();
      }

      scrollController.addListener(maybeLoadMore);
      // Runs once this frame's layout is done, when maxScrollExtent is known —
      // the case where the grid is shorter than the viewport and no scroll
      // event will ever fire to ask for more.
      Future.microtask(maybeLoadMore);
      return () => scrollController.removeListener(maybeLoadMore);
    }, [canLoadMore, scrollController]);

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
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
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

    // Pull-to-refresh wraps the vertical list. In By-Extension mode the body
    // nests horizontal rails, and EasyRefresh's indicator can't tell the two
    // scroll axes apart (its OverflowBox goes infinite), so that mode refreshes
    // from the field instead.
    if (state.resultsViewMode == ResultsViewMode.byExtension) return list;

    return EasyRefresh(
      header: const ForuiHeader(),
      onRefresh: () async {
        ref
            .read(globalSearchPagesProvider.notifier)
            .refresh(
              ref.read(searchPageProvider).searchScopePackages.toList(),
              query,
            );
      },
      child: list,
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

/// Gap, in logical pixels, between the grid's end and the point where the
/// next page is requested: about one card row, so the fetch starts before the
/// skeleton row is fully on screen instead of after the reader hits bottom.
const double kLoadMoreTriggerGap = 300;
