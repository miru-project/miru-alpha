import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/home/home_view_model.dart';
import 'package:miru_alpha/ui/features/download/widget/download_tiles.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class LibraryBentoCards extends ConsumerWidget {
  const LibraryBentoCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    // Get the most recent history item
    final recentHistory = homeState.history.isNotEmpty
        ? homeState.history.first
        : null;
    final historySubtitle = recentHistory != null
        ? _formatTimeAgo(recentHistory.date)
        : 'common.no_history'.i18n;

    // The download card grows a row per active status while the history card
    // stays a single line, so the two would otherwise render at different
    // heights. IntrinsicHeight bounds the row (it sits in a SliverToBoxAdapter,
    // where a bare `stretch` would hit an unbounded cross axis) and `stretch`
    // then evens the cards out.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _BentoCard(
              icon: FLucideIcons.history,
              title: 'common.history'.i18n,
              subtitle: historySubtitle,
              onTap: () => context.push('/home/history'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DownloadBentoCard(
              onTap: () => context.push('/home/download'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'common.just_now'.i18n;
    } else if (difference.inHours < 1) {
      return 'common.minutes_ago'.fill({
        'minutes': difference.inMinutes.toString(),
      });
    } else if (difference.inDays < 1) {
      return 'common.hours_ago'.fill({'hours': difference.inHours.toString()});
    } else if (difference.inDays == 1) {
      return 'common.yesterday'.i18n;
    } else if (difference.inDays < 7) {
      return 'common.days_ago'.fill({'days': difference.inDays.toString()});
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'common.weeks_ago'.fill({'weeks': weeks.toString()});
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'common.months_ago'.fill({'months': months.toString()});
    } else {
      final years = (difference.inDays / 365).floor();
      return 'common.years_ago'.fill({'years': years.toString()});
    }
  }
}

/// The download card summarises work by status rather than quoting a running
/// total of stored entries: a total grows without bound and says nothing about
/// what actually needs attention, whereas "3 downloading, 1 failed" does.
class _DownloadBentoCard extends ConsumerWidget {
  const _DownloadBentoCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(downloadProvider).value?.active ?? const [];

    // Collapse the seven backend statuses into the three that mean something
    // on a summary card: actively working, waiting to run, and needs attention.
    var working = 0;
    var waiting = 0;
    var failed = 0;
    for (final task in active) {
      switch (task.status) {
        case proto.DownloadStatus.DOWNLOADING ||
            proto.DownloadStatus.CONVERTING:
          working++;
        case proto.DownloadStatus.PAUSED || proto.DownloadStatus.QUEUED:
          waiting++;
        case proto.DownloadStatus.FAILED:
          failed++;
        default:
          break;
      }
    }

    final rows = <(String, int, Color)>[
      (
        'download.status.downloading'.i18n,
        working,
        downloadStatusColor(proto.DownloadStatus.DOWNLOADING, context.theme),
      ),
      (
        'download.status.paused'.i18n,
        waiting,
        downloadStatusColor(proto.DownloadStatus.PAUSED, context.theme),
      ),
      (
        'download.status.failed'.i18n,
        failed,
        downloadStatusColor(proto.DownloadStatus.FAILED, context.theme),
      ),
    ].where(((String _, int count, Color _) row) => row.$2 > 0).toList();

    return _BentoCard(
      icon: FLucideIcons.download,
      title: 'download.name'.i18n,
      onTap: onTap,
      detail: rows.isEmpty
          ? Text(
              'download.no_active_downloads'.i18n,
              style: TextStyle(
                fontSize: 12,
                color: context.theme.colors.mutedForeground.withAlpha(180),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  _StatusCountRow(
                    label: rows[i].$1,
                    count: rows[i].$2,
                    color: rows[i].$3,
                  ),
                ],
              ],
            ),
    );
  }
}

/// One "● 3 Downloading" line of the download card's status breakdown.
class _StatusCountRow extends StatelessWidget {
  const _StatusCountRow({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colors.mutedForeground.withAlpha(180),
            ),
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.detail,
  }) : assert(
         subtitle != null || detail != null,
         'Provide a subtitle or a detail body, otherwise the card has no content.',
       );

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Rich body shown instead of [subtitle] (used by the download card for its
  /// per-status counts).
  final Widget? detail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MiruCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: context.theme.colors.primary.withAlpha(200),
                  ),
                  Icon(
                    FLucideIcons.arrowRight,
                    size: 16,
                    color: context.theme.colors.mutedForeground.withAlpha(120),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              if (detail case final rich?)
                rich
              else
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.theme.colors.mutedForeground.withAlpha(180),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
