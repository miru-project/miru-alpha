import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// A slim strip that only renders when at least one tracker is linked:
/// emerald dot + "Synced (N)". Everything else it used to carry is gone as
/// clutter — the "Ep x/y" counter duplicates the episodes header badge, the
/// "Not synced" label states an absence, and the bookmark lives in the
/// episodes header ([WatchFavoriteButton]). The caller hides the bar
/// entirely when nothing is linked.
class WatchTrackerBar extends StatelessWidget {
  const WatchTrackerBar({
    super.key,
    required this.trackers,
    this.episodeNumber,
    this.episodeCount,
  });

  final List<proto.Tracker> trackers;

  /// Current episode ordinal (1-based) the design's "Ep x/y" reads from.
  final int? episodeNumber;

  /// Total episode count the design's "Ep x/y" reads from.
  final int? episodeCount;

  @override
  Widget build(BuildContext context) {
    final linked = trackers.where((t) => t.trackerId.isNotEmpty).length;

    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const _SyncMark(),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'watch.synced_count'.fill({'count': '$linked'}),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ),
            if (episodeNumber != null && episodeCount != null) ...[
              const SizedBox(width: 10),
              _EpisodeCount(current: episodeNumber!, total: episodeCount!),
            ],
          ],
        ),
      ),
    );
  }
}

/// The reference's "AniList: Ep 3/18" indicator — tracker brand dot +
/// episode counter — rendered only when a tracker is actually linked (the
/// bar mounts then) and the episode list has a known length.
class _EpisodeCount extends StatelessWidget {
  const _EpisodeCount({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1E96FF),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'watch.ep_indicator'.fill({'current': '$current', 'total': '$total'}),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs2.copyWith(
            fontWeight: FontWeight.w600,
            color: context.theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Emerald dot: at least one tracker is linked (the bar only mounts then).
class _SyncMark extends StatelessWidget {
  const _SyncMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF10B981),
      ),
    );
  }
}
