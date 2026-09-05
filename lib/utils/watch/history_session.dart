import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// Where a history row points inside its detail: an episode index and the
/// episode group that contains it.
typedef HistoryEpisodeRef = ({int episodeIndex, int groupIndex});

/// Resolves a [history] row to concrete episode coordinates inside [detail].
///
/// The indices stored on the row are positional, so an extension that re-orders
/// its episode list between two runs would otherwise resume the wrong episode.
/// The saved watch URL is matched first, and the stored indices are only
/// trusted while they still point at that URL.
///
/// Returns null when the episode can no longer be found.
HistoryEpisodeRef? resolveHistoryEpisode({
  required Detail detail,
  required History history,
}) {
  final groups = detail.episodes;
  if (groups == null || groups.isEmpty) return null;

  // Bounds-checked on purpose: the stored indices come from the database and
  // may describe an episode list that has since shrunk. Indexing straight into
  // the lists threw RangeError instead of reporting "gone".
  if (_urlAt(groups, history.episodeGroupId, history.episodeId) ==
      history.url) {
    return (
      episodeIndex: history.episodeId,
      groupIndex: history.episodeGroupId,
    );
  }

  for (var g = 0; g < groups.length; g++) {
    final urls = groups[g].urls;
    for (var e = 0; e < urls.length; e++) {
      if (urls[e].url == history.url) {
        return (episodeIndex: e, groupIndex: g);
      }
    }
  }
  return null;
}

String? _urlAt(
  List<ExtensionEpisodeGroup> groups,
  int groupIndex,
  int epIndex,
) {
  if (groupIndex < 0 || groupIndex >= groups.length) return null;
  final urls = groups[groupIndex].urls;
  if (epIndex < 0 || epIndex >= urls.length) return null;
  return urls[epIndex].url;
}

/// Opens the watch session for [history], resuming at its stored episode.
///
/// `/watch` serves all three media types (video player, manga reader, novel
/// reader), so this is the single "keep watching" entry point. Shared with the
/// home continue-watching strip so both resolve episodes identically.
///
/// Every failure mode tells the user why nothing happened; previously a missing
/// package or a vanished episode silently returned.
Future<void> openHistoryWatchSession({
  required BuildContext context,
  required WidgetRef ref,
  required History history,
}) async {
  final meta = findMeta(ref, history.package);
  if (meta == null) {
    showSimpleToast('common.package_not_found'.i18n);
    return;
  }

  final detail = await fetchDetailFromDb(history.package, history.detailUrl);
  if (!context.mounted) return;
  if (detail == null) {
    showSimpleToast('history_tools.detail_missing'.i18n);
    return;
  }

  final episode = resolveHistoryEpisode(detail: detail, history: history);
  if (episode == null) {
    if (!context.mounted) return;
    showSimpleToast('history_tools.episode_unavailable'.i18n);
    return;
  }

  context.push<WatchParams>(
    '/watch',
    extra: WatchParams(
      savePath: null,
      name: history.title,
      detailImageUrl: history.cover ?? '',
      selectedEpisodeIndex: episode.episodeIndex,
      selectedGroupIndex: episode.groupIndex,
      epGroup: detail.episodes,
      detailUrl: history.detailUrl,
      url: history.url,
      meta: meta,
      type: meta.type,
    ),
  );
}
