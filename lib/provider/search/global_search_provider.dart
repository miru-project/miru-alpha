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

  /// Page depth every source has been asked for.
  final int pages;

  /// Whether another page is worth requesting: not while anything is still
  /// loading, and not when the last requested page came back empty (that
  /// source has no more).
  final bool hasMore;

  bool get isPending => done < total;

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

/// Page depth of the global results list, plus the two ways to re-fetch.
///
/// A [Notifier] rather than widget state because the header (counts), the
/// status bar (retry) and the body (load more) all have to move the same
/// number (rule #22).
class GlobalSearchPagesNotifier extends Notifier<int> {
  @override
  int build() => 1;

  /// Ask every source for one more page.
  void loadMore() => state++;

  /// Back to a single page — used when the query or scope changes.
  void reset() {
    if (state != 1) state = 1;
  }

  /// Re-run only the sources that errored.
  void retryFailed(Iterable<String> packages, String query) {
    for (final pkg in packages) {
      for (var page = 1; page <= state; page++) {
        ref.invalidate(
          fetchExtensionSearchLatestProvider.call(pkg, page, query: query),
        );
      }
    }
  }

  /// Pull-to-refresh: first page of every source in scope again.
  void refresh(List<String> packages, String query) {
    state = 1;
    for (final pkg in packages) {
      ref.invalidate(
        fetchExtensionSearchLatestProvider.call(pkg, 1, query: query),
      );
    }
  }
}

final globalSearchPagesProvider =
    NotifierProvider<GlobalSearchPagesNotifier, int>(
      GlobalSearchPagesNotifier.new,
    );

final globalSearchAggregateProvider =
    Provider.autoDispose<GlobalSearchAggregate>((ref) {
      final search = ref.watch(searchPageProvider);
      final query = search.query.trim();
      final packages = search.searchScopePackages.toList(growable: false);
      final pinned = search.existedPinnedExtensions;
      final pages = ref.watch(globalSearchPagesProvider);

      final entries = <GlobalSearchEntry>[];
      final failedPackages = <String>[];
      final failedNames = <String>[];
      var done = 0;

      for (final pkg in packages) {
        final meta = search.metaData
            .where((e) => e.packageName == pkg)
            .firstOrNull;
        var settled = true;

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

        if (settled) done++;
      }

      // The first page always offers more; after that, stop as soon as a
      // source contributes nothing new instead of growing depth forever.
      final lastPageYielded = pages == 1 || entries.any((e) => e.page == pages);
      final pending = done < packages.length;

      return GlobalSearchAggregate(
        entries: entries,
        done: done,
        total: packages.length,
        failed: failedNames,
        failedPackages: failedPackages,
        pages: pages,
        hasMore: !pending && entries.isNotEmpty && lastPageYielded,
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
