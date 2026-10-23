import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/home/home_dashboard_provider.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_poster_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/watch/history_session.dart';

const _cardWidth = 280.0;
const _coverHeight = 158.0;
// Cover + 12px card padding + title line + 2 + progress line + 12 (mockup
// card has no action button; the whole card is the tap target).
const _railHeight = 220.0;
const _maxCards = 10;

/// "Continue Playing" — zero-tap resume shelf of the newest in-progress
/// history entries, filtered by the dashboard's media type.
class HomeResumeRail extends ConsumerWidget {
  const HomeResumeRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(homeDashboardProvider.select((s) => s.type));
    final history = ref.watch(
      historyPageProvider.select((s) => s.filteredHistory),
    );
    final items =
        (type == ExtensionType.all
                ? history
                : history.where((h) => h.extensionType == type).toList())
            .take(_maxCards)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeSectionHeader(
            title: 'home.continue_playing'.i18n,
            trailing: items.isEmpty
                ? null
                : SearchPill(
                    label: items.length == 1
                        ? 'home.in_progress_one'.i18n
                        : 'home.in_progress'.i18n.fill({
                            'count': '${items.length}',
                          }),
                    selected: false,
                    icon: FLucideIcons.chevronRight,
                    onTap: () => context.push('/home/history'),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          // Empty states are not dead ends (UX-review): no heavy card — the
          // guidance sits directly on the page background with a prominent
          // primary CTA into the catalogue.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Icon(
                  FLucideIcons.circlePlay,
                  size: 40,
                  color: context.theme.colors.mutedForeground,
                ),
                const SizedBox(height: 10),
                Text(
                  'home.resume_empty'.i18n,
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 14),
                FButton(
                  onPress: () => context.push('/search'),
                  prefix: const Icon(FLucideIcons.compass, size: 16),
                  child: Text('home.explore'.i18n),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: _railHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _ResumeCard(
                key: ValueKey(items[index].url),
                item: items[index],
              ),
            ),
          ),
      ],
    );
  }
}

class _ResumeCard extends ConsumerWidget {
  const _ResumeCard({super.key, required this.item});

  final History item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final total = item.totalProgress;
    final progress = total > 0 ? (item.progress / total).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).round();
    final type = item.extensionType;
    final isVideo = type == ExtensionType.bangumi;
    void resume() =>
        openHistoryWatchSession(context: context, ref: ref, history: item);

    return AnimatedBox.nopadding(
      onTap: resume,
      child: SizedBox(
        width: _cardWidth,
        child: MiruCard(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  // Fixed extent: ImageWidget's fallback/loading branches are
                  // not sized, so without this box a missing cover collapses
                  // the Stack and the overlays pile onto the text below.
                  SizedBox(
                    key: const Key('homeResumeCover'),
                    height: _coverHeight,
                    width: double.infinity,
                    child: ImageWidget(
                      imageUrl: item.cover,
                      fit: BoxFit.cover,
                      borderRadius: 0,
                      // Shimmer while the cover fetches (the slot keeps its
                      // 158px extent, so nothing shifts when pixels arrive).
                      loadingChild: const HomeMediaSkeletonBox(borderRadius: 0),
                      errChild: DecoratedBox(
                        decoration: BoxDecoration(color: colors.muted),
                        child: Center(
                          child: Icon(
                            FLucideIcons.image,
                            size: 32,
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            colors.background.withAlpha(190),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: HomeChip(
                      icon: switch (type) {
                        ExtensionType.bangumi => FLucideIcons.play,
                        ExtensionType.manga => FLucideIcons.bookOpen,
                        _ => FLucideIcons.bookMarked,
                      },
                      label: searchExtensionTypeLabel(type),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    // Mockup: remaining time for video ("7m left"), percent
                    // for print media ("82%") — both derivable from history.
                    child: HomeChip(
                      label: isVideo && total > 0
                          ? 'home.time_left'.i18n.fill({
                              'n': '${((total - item.progress) / 60).ceil()}',
                            })
                          : '$percent%',
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ColoredBox(
                      color: colors.border,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(height: 3, color: colors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _episodeLabel(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs2.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    // No per-card action button: the mockup's card body is
                    // title + progress line only, and the whole card is the
                    // tap target — a Play/Read button duplicated it.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Resume line under the title, in the same units the reader saved: clock
  /// time for video, page/chapter position for print media.
  String _episodeLabel(History item) => switch (item.extensionType) {
    ExtensionType.bangumi => 'home.episode_progress'.i18n.fill({
      'n': '${item.episodeId + 1}',
      'pos': _clock(item.progress),
      'dur': _clock(item.totalProgress),
    }),
    ExtensionType.manga => 'home.chapter_progress'.i18n.fill({
      'n': '${item.episodeId + 1}',
      'p': '${item.progress}',
      't': '${item.totalProgress}',
    }),
    _ => 'home.location_progress'.i18n.fill({
      'p': '${item.progress}',
      't': '${item.totalProgress}',
    }),
  };

  String _clock(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}
