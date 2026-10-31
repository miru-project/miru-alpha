import 'package:collection/collection.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detail_page_provider.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_tag_chips.dart';
import 'package:miru_alpha/ui/features/detail/widget/desktop_detail_image_view.dart';
import 'package:miru_alpha/ui/features/extension/widget/text_cover.dart';
import 'package:miru_alpha/ui/features/detail/widget/favorite_dialog.dart';
import 'package:miru_alpha/utils/core/episode_label.dart';
import 'package:miru_alpha/utils/core/html_text.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

/// Mobile detail hero, mirroring the reference header block: the cover
/// beside a column holding the title, one merged secondary meta row
/// (extension identity • favourite groups) and the genre tag chips, then
/// the full-width resume-aware Play CTA and the rich-text description
/// with its Read more toggle underneath.
///
/// The media type is deliberately not shown here — it used to appear on
/// the poster badge and in the meta row at once (and could collide with
/// a TMDB genre chip), which read as clutter in a span of a few lines.
class MobileDetailHero extends ConsumerWidget {
  const MobileDetailHero({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });

  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favGrp = ref.watch(detailPr.select((value) => value.favoriateGroup));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cover(detail: detail),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.title,
                    style: context.theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Single merged secondary row — the reference stacks title,
                  // source and badges over several lines; here everything
                  // after the title shares one wrapping line.
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (meta.icon != null && meta.icon!.isNotEmpty)
                        ExtendedImage.network(
                          MiruRequest.proxyUrl(meta.icon!).toString(),
                          retries: 1,
                          width: 16,
                          height: 16,
                          loadStateChanged: (state) {
                            if (state.extendedImageLoadState ==
                                LoadState.failed) {
                              return TextCover(seed: meta.name, size: 16);
                            }
                            return null;
                          },
                        )
                      else
                        TextCover(seed: meta.name, size: 16),
                      Text(
                        meta.name,
                        style: metaStyle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (favGrp != null)
                        for (final e in favGrp) ...[
                          metaDot(context),
                          // Tappable pill (the "#" prefix marks it as a
                          // user tag) so it reads as a chip distinct from
                          // the plain-text extension name; tapping opens
                          // the favorite dialog, same as before.
                          SmallBadge(
                            label: '#${e.name}',
                            variant: .secondary,
                            onPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => FavoriteDialog(
                                  meta: meta,
                                  detailUrl: detailUrl,
                                  detail: detail,
                                  detailPr: detailPr,
                                ),
                              );
                            },
                          ),
                        ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  DetailTagChips(
                    detail: detail,
                    meta: meta,
                    detailPr: detailPr,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Reference rhythm: the CTA and the synopsis are their own
        // sections under `space-y-4` (16px) and the CTA section carries
        // an extra `pt-2` (8px) — 24px above the button, 16px below it.
        const SizedBox(height: 24),
        _PlayCta(
          detail: detail,
          meta: meta,
          detailUrl: detailUrl,
          detailPr: detailPr,
        ),
        const SizedBox(height: 16),
        _DescriptionSection(detail: detail),
      ],
    );
  }
}

/// The primary call to action: a full-width resume-aware button with the
/// episode-number action ("Resume Ep. N" / "Play Ep. N") on top and the
/// episode's own name as a muted second line, plus the remaining time
/// while an episode is partially watched. It is the only action in this
/// row: per-episode downloads live on each episode tile below, so a
/// batch-download button here only duplicated them.
class _PlayCta extends ConsumerWidget {
  const _PlayCta({
    required this.detail,
    required this.meta,
    required this.detailUrl,
    required this.detailPr,
  });

  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;
  final DetialProvider detailPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = _targetIndex(ref);
    final episodeName = target == null ? null : _episodeAt(ref, target)?.name;
    final remaining = _remainingMinutes(ref, target);

    // Two-line CTA: the episode-number action on top, the episode's own
    // name muted underneath (no target renders the bare Play title only).
    final title = target == null
        ? 'common.play'.i18n
        : remaining > 0
        ? 'media.resume_episode'.fill({'ep': '${target + 1}'})
        : 'media.play_episode'.fill({'ep': '${target + 1}'});
    final name = target == null ? null : stripEpisodePrefix(episodeName ?? '');

    // Single full-width CTA — see the class doc: the batch-download icon
    // that used to sit beside it duplicated the per-episode download
    // buttons in the list below.
    return FButton(
      variant: .primary,
      onPress: () => _playNext(context, ref),
      prefix: Icon(FLucideIcons.play, size: 18),
      suffix: remaining > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.theme.colors.primaryForeground.withAlpha(38),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'media.remaining_time'.fill({'minutes': '$remaining'}),
                style: context.theme.typography.body.xs2.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.theme.colors.primaryForeground,
                ),
              ),
            )
          : null,
      // FButton's content row is not flexible, so the two-line column must
      // be wrapped in a Flexible itself — the episode name makes the
      // content far wider than the button's slot.
      builder: _flexChild,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
              color: context.theme.colors.primaryForeground,
            ),
          ),
          if (name != null && name.isNotEmpty)
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs2.copyWith(
                color: context.theme.colors.primaryForeground.withAlpha(190),
              ),
            ),
        ],
      ),
    );
  }

  /// FButton's documented `builder` hook; wrapping the content in [Expanded]
  /// left-aligns the icon + text at the button's start edge and pushes the
  /// remaining-time suffix to the far right, and lets the internal Row shrink
  /// instead of overflowing.
  static Widget _flexChild(
    BuildContext context,
    FButtonStyle style,
    TextStyle textStyle,
    IconThemeData iconStyle,
    FCircularProgressStyle progressStyle,
    Widget? child,
  ) => Expanded(child: child ?? const SizedBox.shrink());

  /// The episode at [index] of the active group.
  ExtensionEpisode? _episodeAt(WidgetRef ref, int index) {
    final episodes = detail.episodes;
    if (episodes == null || episodes.isEmpty) return null;
    final gpIdx = ref.read(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    final items = episodes[gpIdx].urls;
    if (index < 0 || index >= items.length) return null;
    return items[index];
  }

  /// Minutes left in the partially watched episode, or 0 when the target is
  /// unwatched. Only video carries a duration — a manga's "remaining" is a
  /// page count, which the reference does not show.
  int _remainingMinutes(WidgetRef ref, int? target) {
    if (target == null || meta.type != ExtensionType.bangumi) return 0;
    final item = _episodeAt(ref, target);
    if (item == null) return 0;
    final historyList = ref.read(detailPr.select((s) => s.historyList));
    final history = historyList.firstWhereOrNull((el) => el.url == item.url);
    if (history == null || history.totalProgress <= 0) return 0;
    final left = history.totalProgress - history.progress;
    if (left <= 0) return 0;
    return (left / 60).ceil();
  }

  /// Resume-aware target: the first partially watched episode, then the
  /// first unwatched one, then the first episode — mirroring what the tile
  /// would do if tapped. Returns null when nothing is playable.
  int? _targetIndex(WidgetRef ref) {
    final episodes = detail.episodes;
    if (episodes == null || episodes.isEmpty) return null;
    final gpIdx = ref.read(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    final items = episodes[gpIdx].urls;
    if (items.isEmpty) return null;
    final historyList = ref.read(detailPr.select((s) => s.historyList));
    History? byUrl(ExtensionEpisode e) =>
        historyList.firstWhereOrNull((el) => el.url == e.url);

    for (var i = 0; i < items.length; i++) {
      final h = byUrl(items[i]);
      if (h != null &&
          h.totalProgress > 0 &&
          h.progress > 0 &&
          h.progress < h.totalProgress) {
        return i;
      }
    }
    for (var i = 0; i < items.length; i++) {
      if (byUrl(items[i]) == null) return i;
    }
    return 0;
  }

  /// Play action: pushes /watch at the resume target computed above.
  void _playNext(BuildContext context, WidgetRef ref) {
    final episodes = detail.episodes;
    if (episodes == null || episodes.isEmpty) return;
    final gpIdx = ref.read(
      detailPageProviderProvider.select((e) => e.epGroupIdx),
    );
    final group = episodes[gpIdx];
    final items = group.urls;
    final target = _targetIndex(ref);
    if (target == null || target >= items.length) return;

    final item = items[target];
    final savePath = ref
        .read(detailPr.select((v) => v.downloadList))
        .firstWhereOrNull(
          (e) => e.key == "${detail.title}-${group.title}-${item.name}",
        )
        ?.savePath;
    context.push<WatchParams>(
      "/watch",
      extra: WatchParams(
        detailPr: detailPr,
        name: detail.title,
        savePath: savePath,
        detailImageUrl: detail.cover ?? '',
        selectedEpisodeIndex: target,
        selectedGroupIndex: gpIdx,
        epGroup: detail.episodes,
        detailUrl: detailUrl,
        url: item.url,
        meta: meta,
        type: meta.type,
      ),
    );
  }
}

/// Cover art, matching the reference's plain poster treatment — the
/// media-type chip that used to be overlaid at the bottom-left repeated
/// the type also shown in the meta row and genre pills, so it was removed.
class _Cover extends StatelessWidget {
  const _Cover({required this.detail});

  final Detail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 160,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.theme.colors.border),
      ),
      child: DetailImageView(
        detail: detail,
        coverUrl: detail.cover ?? '',
        child: ImageWidget(
          imageUrl: detail.cover ?? '',
          fit: BoxFit.cover,
          errChild: MiruCard(
            child: Center(child: Icon(FLucideIcons.cloudAlert)),
          ),
        ),
      ),
    );
  }
}

/// Muted metadata style shared by every segment of the hero's dot-row.
/// `body.sm` — the row now owns a full line under the poster, so it reads
/// as content rather than caption text.
TextStyle metaStyle(BuildContext context) => context.theme.typography.body.sm
    .copyWith(color: context.theme.colors.mutedForeground);

/// Dot separator of the hero's metadata row — fixed width so ellipsised
/// segments never eat it.
Widget metaDot(BuildContext context) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 3),
  child: Text('•', style: metaStyle(context)),
);

/// Two-line rich-text description parsed from the extension's inline HTML
/// (`<i>`/`<b>`/`<br>` …) with an explicit Read more / Show less toggle;
/// falls back to the "no description" placeholder when none ships.
class _DescriptionSection extends HookWidget {
  const _DescriptionSection({required this.detail});

  final Detail detail;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final desc = detail.desc?.trim() ?? '';
    if (desc.isEmpty) {
      return Text(
        'media.no_description'.i18n,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      );
    }
    final bodyStyle = context.theme.typography.body.sm.copyWith(
      color: context.theme.colors.mutedForeground,
      height: 1.45,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          htmlToSpan(desc, style: bodyStyle),
          maxLines: expanded.value ? null : 2,
          overflow: expanded.value ? null : TextOverflow.ellipsis,
        ),
        FTappable(
          onPress: () => expanded.value = !expanded.value,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expanded.value
                      ? 'media.show_less'.i18n
                      : 'media.read_more'.i18n,
                  style: context.theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colors.primary,
                  ),
                ),
                Icon(
                  expanded.value
                      ? FLucideIcons.chevronUp
                      : FLucideIcons.chevronDown,
                  size: 14,
                  color: context.theme.colors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
