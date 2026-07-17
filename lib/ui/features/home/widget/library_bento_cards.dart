import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/home/home_view_model.dart';
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

    // Get download counts
    final downloadHistoryCount = homeState.downloads.length;
    final activeDownloads =
        ref.watch(downloadProvider).value?.active.length ?? 0;
    final downloadSubtitle = activeDownloads > 0
        ? '$activeDownloads active, $downloadHistoryCount total'
        : '$downloadHistoryCount downloads';

    return Row(
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
          child: _BentoCard(
            icon: FLucideIcons.download,
            title: 'download.name'.i18n,
            subtitle: downloadSubtitle,
            onTap: () => context.push('/home/download'),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'common.just_now'.i18n;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${'common.minutes_ago'.i18n}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${'common.hours_ago'.i18n}';
    } else if (difference.inDays == 1) {
      return 'common.yesterday'.i18n;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'common.days_ago'.i18n}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${'common.weeks_ago'.i18n}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${'common.months_ago'.i18n}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${'common.years_ago'.i18n}';
    }
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
