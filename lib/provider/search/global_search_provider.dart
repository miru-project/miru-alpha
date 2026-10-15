import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';

/// One hit from one source, tagged with the extension that produced it.
class GlobalSearchEntry {
  const GlobalSearchEntry({
    required this.meta,
    required this.item,
    required this.sourcePinned,
    required this.origin,
    this.page = 1,
  });

  final ExtensionMeta meta;
  final ExtensionListItem item;
  final bool sourcePinned;

  /// Position of the item inside its own source's result list — the tie-break
  /// that keeps every ordering stable.
  final int origin;

  /// Page of its source this hit came from; [GlobalSearchAggregate.hasMore]
  /// reads it to decide whether another page is worth asking for.
  final int page;

  /// True when [query] appears verbatim in the title, which is what the card
  /// labels an "exact" hit.
  bool isExactMatch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;
    return item.title.toLowerCase().contains(q);
  }
}

/// Flattened view of every source in the current search scope, plus the
/// progress counters the aggregation bar renders.
///
/// Single source of truth for the result count: the header, the status bar and
/// the card list all read this provider, so they can never disagree (rule #22).
class GlobalSearchAggregate {
  const GlobalSearchAggregate({
    required this.entries,
    required this.done,
    required this.total,
    required this.failed,
    this.failedPackages = const [],
    this.pages = 1,
    this.hasMore = false,
    this.more = const {},
  });

  /// Every hit from every finished source, unfiltered and unsorted.
  final List<GlobalSearchEntry> entries;

  /// Sources that have settled (success or error).
  final int done;

  /// Sources in scope.
  final int total;

  /// Display names of the sources that returned an error.
  final List<String> failed;

  /// Package names behind [failed], so a retry can invalidate the right
  /// providers instead of guessing from the label.
  final List<String> failedPackages;

  /// Deepest page any source has been asked for — drives the skeleton row
  /// (`pages > 1 && isPending` means a fetch beyond page one is out).
  final int pages;

  /// Whether another page is worth requesting: not while anything is still
  /// loading, and not when the last requested page came back empty (that
  /// source has no more).
  final bool hasMore;

  /// Per-source verdict behind [hasMore]: package -> "its last requested page
  /// yielded something, so the next one is worth asking for". Allocation
  /// happens source by source, so this is what the predictor picks from.
  final Map<String, bool> more;

  bool get isPending => done < total;

  /// Whether [pkg]'s next page is worth asking for. Fixtures that pin an
  /// aggregate without the per-source verdict fall back to "it gave anything".
  bool sourceHasMore(String pkg) =>
      more[pkg] ?? entries.any((e) => e.meta.packageName == pkg);

  /// Hit counts per content type, used by the result type tabs.
  Map<ExtensionType, int> get counts {
    final result = <ExtensionType, int>{
      for (final t in kSearchContentTypes) t: 0,
    };
    for (final entry in entries) {
      final type = entry.meta.type;
      result[type] = (result[type] ?? 0) + 1;
    }
    return result;
  }

  /// The source names in scope, for the "N results across …" line.
  List<String> get sourceNames =>
      entries.map((e) => e.meta.name).toSet().toList(growable: false);
}

/// Page depth of the global results list, per source, plus the re-fetch paths.
///
/// A [Notifier] rather than widget state because the header (counts), the
/// status bar (retry) and the predictor (allocation) all have to move the same
/// number (rule #22).
///
/// Pages are tracked **per source**, not as one depth for everyone: page one
/// is asked of every source so the predictor gets an observation from each,
/// and every page after that goes to whichever source the predictor picks.
/// Sources start at page one, so an empty map means "nobody has been paged".
class GlobalSearchPagesNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  /// Pages asked of [pkg] so far (anything unseen is page one).
  int depthOf(String pkg) => state[pkg] ?? 1;

  /// Ask [pkg] — the predictor's winner — for its next page.
  void loadMore(String pkg) => state = {...state, pkg: depthOf(pkg) + 1};

  /// Back to a single page per source — used when the query or scope changes.
  void reset() {
    if (state.isNotEmpty) state = const {};
  }

  /// Re-run only the sources that errored, over the pages they were asked.
  void retryFailed(Iterable<String> packages, String query) {
    for (final pkg in packages) {
      for (var page = 1; page <= depthOf(pkg); page++) {
        ref.invalidate(
          fetchExtensionSearchLatestProvider.call(pkg, page, query: query),
        );
      }
    }
  }

  /// Pull-to-refresh: first page of every source in scope again.
  void refresh(List<String> packages, String query) {
    state = const {};
    for (final pkg in packages) {
      ref.invalidate(
        fetchExtensionSearchLatestProvider.call(pkg, 1, query: query),
      );
    }
  }
}

final globalSearchPagesProvider =
    NotifierProvider<GlobalSearchPagesNotifier, Map<String, int>>(
      GlobalSearchPagesNotifier.new,
    );

final globalSearchAggregateProvider =
    Provider.autoDispose<GlobalSearchAggregate>((ref) {
      final search = ref.watch(searchPageProvider);
      final query = search.query.trim();
      final packages = search.searchScopePackages.toList(growable: false);
      final pinned = search.existedPinnedExtensions;
      final depth = ref.watch(globalSearchPagesProvider);

      final entries = <GlobalSearchEntry>[];
      final failedPackages = <String>[];
      final failedNames = <String>[];
      final more = <String, bool>{};
      var done = 0;
      var maxDepth = 1;

      for (final pkg in packages) {
        final meta = search.metaData
            .where((e) => e.packageName == pkg)
            .firstOrNull;
        final pages = depth[pkg] ?? 1;
        if (pages > maxDepth) maxDepth = pages;

        var settled = true;
        var lastPageYielded = false;

        for (var page = 1; page <= pages; page++) {
          final snapshot = ref.watch(
            fetchExtensionSearchLatestProvider.call(pkg, page, query: query),
          );
          if (snapshot.isLoading) settled = false;

          if (page == 1) {
            snapshot.whenOrNull(
              error: (_, _) {
                if (!failedPackages.contains(pkg)) {
                  failedPackages.add(pkg);
                  failedNames.add(meta?.name ?? pkg);
                }
              },
            );
          }

          final pageItems = snapshot.whenOrNull(data: (items) => items);
          if (page == pages) lastPageYielded = pageItems?.isNotEmpty ?? false;

          if (meta == null) continue;
          snapshot.whenOrNull(
            data: (items) => entries.addAll([
              for (var i = 0; i < items.length; i++)
                GlobalSearchEntry(
                  meta: meta,
                  item: items[i],
                  sourcePinned: pinned.contains(pkg),
                  origin: i,
                  page: page,
                ),
            ]),
          );
        }

        // Page one always offers more; past that, a source only does while its
        // last requested page still contributed something (a source whose
        // first page came back empty — or errored — is done).
        more[pkg] = lastPageYielded;
        if (settled) done++;
      }

      final pending = done < packages.length;

      return GlobalSearchAggregate(
        entries: entries,
        done: done,
        total: packages.length,
        failed: failedNames,
        failedPackages: failedPackages,
        pages: maxDepth,
        more: more,
        hasMore: !pending && entries.isNotEmpty && more.values.any((v) => v),
      );
    });

/// Applies the active content-type tab and [sort] to [entries].
///
/// Pure so it can be unit-tested without a widget tree.
List<GlobalSearchEntry> orderGlobalResults(
  List<GlobalSearchEntry> entries,
  SearchSortMode sort,
  String query,
) {
  // Content-type tab filtering happens at the call site: an `all` extension
  // returns mixed results that cannot be attributed to a single tab.
  final filtered = [...entries];

  switch (sort) {
    case SearchSortMode.relevance:
      final q = query.trim().toLowerCase();
      filtered.sort((a, b) {
        final score = _relevance(a, q).compareTo(_relevance(b, q));
        if (score != 0) return score;
        final pinned = _pinnedRank(a).compareTo(_pinnedRank(b));
        if (pinned != 0) return pinned;
        return a.origin.compareTo(b.origin);
      });
    case SearchSortMode.latest:
      filtered.sort((a, b) {
        final date = _updateDate(b).compareTo(_updateDate(a));
        if (date != 0) return date;
        return a.origin.compareTo(b.origin);
      });
    case SearchSortMode.sourcePriority:
      filtered.sort((a, b) {
        final pinned = _pinnedRank(a).compareTo(_pinnedRank(b));
        if (pinned != 0) return pinned;
        final name = a.meta.name.compareTo(b.meta.name);
        if (name != 0) return name;
        return a.origin.compareTo(b.origin);
      });
  }
  return filtered;
}

int _pinnedRank(GlobalSearchEntry entry) => entry.sourcePinned ? 0 : 1;

/// One hit's contribution to its source's yield: 1 when the title IS the
/// query, 0 when it is not — the cheap per-hit test the predictor is fed.
double matchScore(GlobalSearchEntry entry, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return 0;
  return entry.item.title.trim().toLowerCase() == q ? 1 : 0;
}

/// What one page of one source produced: how many hits arrived, and how well
/// they matched, on the page they arrived on.
class PageYield {
  const PageYield({
    required this.page,
    required this.length,
    required this.avg,
  });

  final int page;
  final int length;
  final double avg;
}

/// [pkg]'s pages in arrival order, each scored against [query].
List<PageYield> pageYields(
  List<GlobalSearchEntry> entries,
  String pkg,
  String query,
) {
  final byPage = <int, List<GlobalSearchEntry>>{};
  for (final entry in entries) {
    if (entry.meta.packageName != pkg) continue;
    byPage.putIfAbsent(entry.page, () => []).add(entry);
  }
  final pages = byPage.keys.toList()..sort();
  return [
    for (final page in pages)
      PageYield(
        page: page,
        length: byPage[page]!.length,
        avg:
            byPage[page]!
                .map((e) => matchScore(e, query))
                .fold<double>(0, (a, b) => a + b) /
            byPage[page]!.length,
      ),
  ];
}

/// Least-squares slope of avg against page length — the "lin_slope" the
/// prediction rides on. One observation (or a flat length) has no slope.
double yieldSlope(List<PageYield> yields) {
  if (yields.length < 2) return 0;
  var sumX = 0.0;
  var sumY = 0.0;
  for (final y in yields) {
    sumX += y.length;
    sumY += y.avg;
  }
  final meanX = sumX / yields.length;
  final meanY = sumY / yields.length;
  var numerator = 0.0;
  var denominator = 0.0;
  for (final y in yields) {
    final dx = y.length - meanX;
    numerator += dx * (y.avg - meanY);
    denominator += dx * dx;
  }
  return denominator == 0 ? 0 : numerator / denominator;
}

/// What this source's next page should average: `prev_avg + slope *
/// prev_content_len`, the predictor the allocation is decided by.
double predictNextAvg(List<PageYield> yields) {
  if (yields.isEmpty) return 0;
  final prev = yields.last;
  return prev.avg + yieldSlope(yields) * prev.length;
}

/// The source the next page is bought from: the biggest predicted avg wins,
/// ties going to the source whose last page was longer (a source that gave
/// nothing can't win — it isn't a candidate).
///
/// Pure over the aggregate, so the whole mechanism is unit-testable without a
/// widget tree or a network.
String? pickNextFetchPackage(GlobalSearchAggregate aggregate, String query) {
  final candidates = aggregate.more.isNotEmpty
      ? [
          for (final e in aggregate.more.entries)
            if (e.value) e.key,
        ]
      : {for (final e in aggregate.entries) e.meta.packageName}.toList();

  String? best;
  var bestPredicted = double.negativeInfinity;
  var bestLength = -1;
  for (final pkg in candidates) {
    final yields = pageYields(aggregate.entries, pkg, query);
    final predicted = predictNextAvg(yields);
    final length = yields.isEmpty ? 0 : yields.last.length;
    if (predicted > bestPredicted ||
        (predicted == bestPredicted && length > bestLength)) {
      best = pkg;
      bestPredicted = predicted;
      bestLength = length;
    }
  }
  return best;
}

int _relevance(GlobalSearchEntry entry, String query) {
  if (query.isEmpty) return 2;
  final title = entry.item.title.toLowerCase();
  if (title == query) return 0;
  if (title.startsWith(query)) return 1;
  if (title.contains(query)) return 2;
  return 3;
}

/// Timestamp of `ExtensionListItem.update`: an absolute one when the source
/// writes one, otherwise a relative one ("3h ago", "2 days ago"). Unparsable
/// entries sort last but keep their source order.
DateTime _updateDate(GlobalSearchEntry entry) {
  final raw = entry.item.update.trim();
  if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
  final normalized = raw.replaceFirst(' ', 'T');
  final parsed = DateTime.tryParse(normalized) ?? DateTime.tryParse(raw);
  return parsed ?? _relativeDate(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

/// Parses the relative timestamps sources publish instead of dates, so
/// "Latest Release" can still order them.
DateTime? _relativeDate(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('just now')) return DateTime.now();

  final match = RegExp(
    r'(\d+)\s*(seconds?|secs?|s|minutes?|mins?|m|hours?|hrs?|h|days?|d|weeks?|w|months?|mo|years?|y)',
  ).firstMatch(lower);
  if (match == null) return null;

  final amount = int.tryParse(match.group(1) ?? '') ?? 0;
  return DateTime.now().subtract(_unitOf(match.group(2) ?? '') * amount);
}

Duration _unitOf(String unit) => switch (unit) {
  's' || 'sec' || 'secs' || 'second' || 'seconds' => const Duration(seconds: 1),
  'm' || 'min' || 'mins' || 'minute' || 'minutes' => const Duration(minutes: 1),
  'h' || 'hr' || 'hrs' || 'hour' || 'hours' => const Duration(hours: 1),
  'd' || 'day' || 'days' => const Duration(days: 1),
  'w' || 'week' || 'weeks' => const Duration(days: 7),
  'mo' || 'month' || 'months' => const Duration(days: 30),
  _ => const Duration(days: 365),
};
