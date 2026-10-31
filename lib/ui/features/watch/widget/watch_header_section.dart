import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_favorite_button.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The mock's streamlined header: show title + "S{n} · Ep {n} "name"" meta,
/// bookmark/share quick actions, and the "Up Next" quick trigger that
/// replaces the old Prev/Next button pair — the full episode list sits one
/// glance below, so reciprocal nav became a single forward affordance.
class WatchHeaderSection extends ConsumerWidget {
  const WatchHeaderSection({
    super.key,
    required this.showTitle,
    required this.groupTitle,
    required this.episodeIndex,
    required this.episodeName,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.epProvider,
    required this.favorited,
    this.statusMeta,
  });

  final String showTitle;
  final String groupTitle;
  final int episodeIndex;
  final String episodeName;
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final EpisodeNotifierProvider epProvider;
  final bool favorited;

  /// Overrides the default "S{n} · Episode n" meta line — the loading and
  /// error shells replace it with their own status ("Now Loading · Ep 1",
  /// "Episode 1 · Stream unavailable"). `null` keeps the default line.
  final Widget? statusMeta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ep = ref.watch(epProvider);
    final group = ep.epGroup.elementAtOrNull(ep.selectedGroupIndex);
    final next = group?.urls.elementAtOrNull(ep.selectedEpisodeIndex + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.theme.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // The loading / error shells override the meta line with
                  // their own status; the default reads "S1 · Episode 3".
                  statusMeta ??
                      Text(
                        '$groupTitle · ${_episodeMeta(ep.selectedEpisodeIndex)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.body.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            WatchFavoriteButton(
              favorited: favorited,
              detail: detail,
              meta: meta,
              detailUrl: detailUrl,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 44,
              height: 44,
              child: FButton.icon(
                variant: .ghost,
                onPress: () => SharePlus.instance.share(
                  ShareParams(text: detailUrl, title: showTitle),
                ),
                child: Icon(
                  FLucideIcons.share,
                  size: 18,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        if (next != null) ...[
          const SizedBox(height: 12),
          _UpNextCard(
            next: next,
            groupIndex: ep.selectedGroupIndex,
            nextIndex: ep.selectedEpisodeIndex + 1,
            epProvider: epProvider,
          ),
        ],
      ],
    );
  }

  String _episodeMeta(int index) {
    final n = index + 1;
    final name = episodeName.trim();
    // A bare backend number or a self-labelling "Episode N" reads clean
    // without quotes; anything else gets the mock's quoted title form.
    final bare = name.isEmpty || int.tryParse(name) != null;
    final selfLabelling = name == 'Episode $n';
    if (bare || selfLabelling) {
      return 'media.episode_number'.i18n.fill({'n': '$n'});
    }
    return 'Episode $n "$name"';
  }
}

/// "Up Next" quick trigger: badge + the next episode's title + a Play
/// affordance that advances without opening the episode list.
class _UpNextCard extends ConsumerWidget {
  const _UpNextCard({
    required this.next,
    required this.groupIndex,
    required this.nextIndex,
    required this.epProvider,
  });

  final ExtensionEpisode next;
  final int groupIndex;
  final int nextIndex;
  final EpisodeNotifierProvider epProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.muted.withAlpha(120),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'watch.up_next'.i18n.toUpperCase(),
                style: context.theme.typography.body.xs2.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: colors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ep ${nextIndex + 1} · ${next.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FButton(
              // Review round 6, critical 1: the banner's Play was a filled
              // secondary button competing with the player's own controls as
              // a second primary CTA. Ghost keeps the affordance while the
              // video viewport stays the absolute primary element.
              variant: .ghost,
              size: .xs,
              mainAxisSize: .min,
              onPress: () => ref
                  .read(epProvider.notifier)
                  .selectEpisode(groupIndex, nextIndex),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('media.video_player.play'.i18n),
                  const SizedBox(width: 4),
                  const Icon(FLucideIcons.skipForward, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
