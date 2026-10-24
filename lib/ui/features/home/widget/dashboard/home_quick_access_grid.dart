import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/extension/widget/text_cover.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Gap between the bento tiles (mock `gap-2`).
const _gap = 8.0;

/// Mockup tile `min-h-[76px]` — the caption row keeps its distance from the
/// label row on every font scale.
const _tileMinHeight = 76.0;

/// The mockup's emerald status dot; the same constant the detail page uses
/// for its emerald ratio pill.
const _statusGreen = Color(0xFF34D399);

/// "Quick Access" — the mock's `grid-cols-3` shortcut row: three equal
/// bento tiles on ONE line. The first tile is recency-driven: the most
/// recently accessed extension (label = the source's own name, tap dives
/// straight into it), or the generic browse-sources entry on a fresh
/// install. Then Downloads (live active-task count + progress ring) and the
/// tracker state. There is no Favorites tile — the Favorite Tags section
/// below owns the local-collection entry (UX audit round 2: the 2×2 variant
/// ate vertical viewport and duplicated the tags section's pathway), and no
/// Tags tile for the same reason.
class HomeQuickAccessGrid extends ConsumerWidget {
  const HomeQuickAccessGrid({super.key});

  /// The most recent source shown before the stable entries.
  static const _maxRecent = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(extensionPageProvider.select((s) => s.metaData));
    // Most-recent-first package names, resolved against the installed
    // catalogue — a since-uninstalled source drops out.
    final recents = [
      for (final pkg in MiruSettings.getRecentExtensions())
        meta.where((m) => m.packageName == pkg).firstOrNull,
    ].nonNulls.take(_maxRecent).toList();

    // Exactly three tiles on one row: the first slot carries the recent
    // source, or the browse-sources entry while there is no recency yet.
    final tiles = <Widget>[
      recents.isEmpty
          ? const _ExtensionCard()
          : _RecentSourceCard(meta: recents.first),
      const _DownloadsCard(),
      const _TrackersCard(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeSectionHeader(
            title: 'home.quick_access'.i18n,
            // Mockup: a plain muted "Shortcuts" label, not an action.
            trailing: Text(
              'home.shortcuts'.i18n,
              style: context.theme.typography.body.xs3.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final (i, tile) in tiles.indexed) ...[
                Expanded(child: tile),
                if (i != tiles.length - 1) const SizedBox(width: _gap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Visuals only — the tap lives on [AnimatedBox] in each tile subclass, so
/// there is exactly one gesture handler per tile.
///
/// Revised-mock tile anatomy: a left-aligned label row (28px chip + semibold
/// label) over a bottom status row (muted caption + trailing), the whole
/// tile `min-h-[76px]` with `justify-between` pinning the rows to its edges.
class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.icon,
    required this.label,
    required this.caption,
    this.trailing,
  });

  /// Content of the 28px chip: a glyph for the stable tiles, the source's
  /// own icon for the recent-extension tile.
  final Widget icon;
  final String label;

  /// The bottom row's status line (count, version, tracker state).
  final Widget caption;

  /// Bottom-row trailing control; defaults to the mock's chevron. The
  /// downloads tile replaces it with the live progress ring.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return MiruCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _tileMinHeight),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    key: const Key('homeGridIconChip'),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.background,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(child: icon),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: caption),
                  // Non-flex trailing after the Expanded caption: pinned to
                  // the tile's right edge (same pattern as
                  // HomeSectionHeader's trailing).
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Center(
                      child:
                          trailing ??
                          Icon(
                            FLucideIcons.chevronRight,
                            size: 12,
                            color: colors.mutedForeground,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The bottom row's caption: the 10px touch token, muted unless overridden.
TextStyle _captionStyle(BuildContext context, {Color? color}) => context
    .theme
    .typography
    .body
    .xs3
    .copyWith(color: color ?? context.theme.colors.mutedForeground);

/// A recently accessed extension: the source's own icon in the chip, its
/// name as the label, tap enters its catalogue directly.
class _RecentSourceCard extends StatelessWidget {
  const _RecentSourceCard({required this.meta});

  final ExtensionMeta meta;

  @override
  Widget build(BuildContext context) {
    return AnimatedBox.nopadding(
      onTap: () =>
          context.push('/search/single', extra: SearchPageParam(meta: meta)),
      child: _CommandCard(
        icon: _sourceIcon(meta),
        label: meta.name,
        caption: Text(
          searchVersionLabel(meta.version),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _captionStyle(context),
        ),
      ),
    );
  }
}

/// The source's icon, or the stable text-cover when it has none / fails.
Widget _sourceIcon(ExtensionMeta meta) {
  if (meta.icon != null && meta.icon!.isNotEmpty) {
    return ExtendedImage.network(
      MiruRequest.proxyUrl(meta.icon!).toString(),
      width: 16,
      height: 16,
      fit: BoxFit.contain,
      loadStateChanged: (state) =>
          state.extendedImageLoadState == LoadState.failed
          ? TextCover(seed: meta.name, size: 16)
          : null,
    );
  }
  return TextCover(seed: meta.name, size: 16);
}

/// No recent source yet: the generic browse-sources entry. The mock's
/// emerald status dot marks installed sources.
class _ExtensionCard extends ConsumerWidget {
  const _ExtensionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(extensionPageProvider.select((s) => s.metaData));

    return AnimatedBox.nopadding(
      onTap: () => context.push('/extension'),
      child: _CommandCard(
        icon: Icon(
          FLucideIcons.puzzle,
          size: 15,
          color: context.theme.colors.primary,
        ),
        label: 'extension.name'.i18n,
        caption: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (meta.isNotEmpty) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _statusGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                'home.sources_value'.i18n.fill({'count': '${meta.length}'}),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _captionStyle(
                  context,
                  color: context.theme.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live downloads shortcut: the active-task count in the caption and, while
/// tasks run, the mock's progress donut in the trailing slot. Tap opens the
/// download manager — the mobile bottom nav has no downloads tab, so this
/// tile is the dashboard's entry to it.
class _DownloadsCard extends ConsumerWidget {
  const _DownloadsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(
      downloadProvider.select((s) => s.value?.active ?? const []),
    );
    final count = active.length;

    // Mean fraction across the active tasks — the same progress/total
    // arithmetic the download page's tiles use.
    var sum = 0.0;
    for (final task in active) {
      final total = task.total;
      if (total > 0) {
        sum += (task.progress / total).clamp(0.0, 1.0);
      }
    }
    final ratio = count == 0 ? 0.0 : sum / count;

    return AnimatedBox.nopadding(
      onTap: () => context.push('/home/download'),
      child: _CommandCard(
        icon: Icon(
          FLucideIcons.download,
          size: 15,
          color: context.theme.colors.primary,
        ),
        label: 'download.name'.i18n,
        caption: Text(
          'download.active_count'.i18n.fill({'count': '$count'}),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _captionStyle(
            context,
            color: count > 0 ? context.theme.colors.primary : null,
          ),
        ),
        // Mock: with tasks running the ring replaces the chevron.
        trailing: count > 0
            ? _ProgressRing(
                progress: ratio,
                track: context.theme.colors.border,
                fill: context.theme.colors.primary,
              )
            : null,
      ),
    );
  }
}

/// The mockup's 14px progress donut: a `border`-coloured track under a
/// primary arc starting at 12 o'clock (mock `-rotate-90`), round-capped.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.track,
    required this.fill,
  });

  /// Mean completion across the active tasks, 0..1.
  final double progress;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: const Key('homeDownloadsProgressRing'),
      size: const Size(14, 14),
      painter: _ProgressRingPainter(
        progress: progress,
        track: track,
        fill: fill,
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = track,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill;
}

/// Compact metric for the trackers caption (UX audit round 2: the full
/// "N Watched · M Read" string truncates inside a 1/3-width tile): 2891 ->
/// "2.9k", 940 -> "940".
String compactCount(int value) =>
    value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value';

class _TrackersCard extends ConsumerWidget {
  const _TrackersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(anilistAccountProvider);
    final value = account.maybeWhen(
      data: (user) => user == null
          ? 'home.not_linked'.i18n
          : 'home.synced_count'.i18n.fill({
              'count': compactCount(
                user.statistics.anime.episodesWatched +
                    user.statistics.manga.chaptersRead,
              ),
            }),
      orElse: () => 'home.not_linked'.i18n,
    );

    return AnimatedBox.nopadding(
      onTap: () => context.push('/tracking'),
      child: _CommandCard(
        icon: Icon(
          FLucideIcons.refreshCw,
          size: 15,
          color: context.theme.colors.primary,
        ),
        label: 'home.trackers'.i18n,
        caption: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _captionStyle(context),
        ),
      ),
    );
  }
}
