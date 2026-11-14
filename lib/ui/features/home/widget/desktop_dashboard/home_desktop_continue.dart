import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart' show Tooltip;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/home/home_dashboard_provider.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_poster_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_cover_fallback.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/display_title.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/watch/history_session.dart';

/// "Continue Progress" — the newest in-progress history entries as a
/// responsive 16:9 card grid (the mockup's `lg:grid-cols-4`), driven by the
/// same [historyPageProvider] + type filter as the mobile resume rail.
class HomeDesktopContinue extends ConsumerWidget {
  const HomeDesktopContinue({super.key});

  static const _gap = 14.0;

  /// Column count by content width — 4 at the mock's `lg` canvas, then it
  /// keeps growing with the window (ceil(width / 340), capped at 6) so the
  /// 16:9 tiles never balloon past ~320px on large monitors. A fixed 4-col
  /// grid made every tile ~395px wide at 1920.
  static int _columnsFor(double width) => (width / 250).ceil().clamp(2, 7);

  /// Test seam for the tile-size contract (see the main_page shell tests).
  @visibleForTesting
  static int columnsFor(double width) => _columnsFor(width);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(homeDashboardProvider.select((s) => s.type));
    final history = ref.watch(
      historyPageProvider.select((s) => s.filteredHistory),
    );
    // One card per show: history keeps an entry per episode, so the same
    // series can appear twice side by side. Dedupe by title keeping the
    // NEWEST entry (the list is date-desc), then cap.
    final seenTitles = <String>{};
    final deduped =
        (type == ExtensionType.all
                ? history
                : history.where((h) => h.extensionType == type).toList())
            .where((h) => seenTitles.add(h.title))
            .toList();
    // The count chip reports EVERYTHING in progress (the section is a
    // single-row strip now); the grid itself renders only the first row.
    final items = deduped;
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          leading: FLucideIcons.circlePlay,
          title: 'home.continue_reading'.i18n,
          // The mock's count chip hugs the title; the View-all action pins to
          // the row's right edge.
          titleTrailing: items.isEmpty
              ? null
              : FBadge(
                  variant: .outline,
                  style: .delta(
                    labelTextStyle: .delta(fontSize: 12, height: 1),
                    padding: EdgeInsetsGeometryDelta.value(
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    ),
                  ),
                  child: Text(
                    items.length == 1
                        ? 'home.in_progress_one'.i18n
                        : 'home.in_progress'.i18n.fill({
                            'count': '${items.length}',
                          }),
                  ),
                ),
          trailing: items.isEmpty
              ? null
              : SearchPill(
                  label: 'home.view_history'.i18n,
                  selected: false,
                  icon: FLucideIcons.chevronRight,
                  onTap: () => context.push('/home/history'),
                ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          // Mock empty card (2026-11-12): bordered inset panel, 48px icon
          // chip, title + subtitle, secondary Explore CTA — not a bare
          // column on the canvas.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colors.background.withAlpha(102),
              borderRadius: context.theme.style.borderRadius.md,
              border: Border.fromBorderSide(
                BorderSide(color: colors.border.withAlpha(153)),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.muted.withAlpha(153),
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: colors.border),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    FLucideIcons.history,
                    size: 24,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'home.resume_empty_title'.i18n,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Text(
                    'home.resume_empty_subtitle'.i18n,
                    textAlign: .center,
                    style: context.theme.typography.body.xs2.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FButton(
                  variant: .secondary,
                  mainAxisSize: .min,
                  onPress: () => context.push('/search'),
                  prefix: const Icon(FLucideIcons.compass, size: 15),
                  child: Text('home.explore'.i18n),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              var columns = _columnsFor(constraints.maxWidth);
              // Degenerate-width guard: during route transitions the grid can
              // receive a near-zero width where the fixed gaps alone exceed
              // it — that drives Expandeds negative (w=-7 crash). Shrink the
              // column count so tiles never go below 160px and the gaps
              // always fit.
              columns = math.max(
                1,
                math.min(
                  columns,
                  ((constraints.maxWidth + _gap) / (160 + _gap)).floor(),
                ),
              );
              // Single row only (user directive): the bottom row was pure
              // space consumption on the dashboard.
              final firstRow = items.take(columns).toList();
              return Column(
                spacing: _gap,
                children: [
                  for (final row in firstRow.slices(columns))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slots are always the full column width — a partial
                        // row keeps empty Expandeds instead of stretching the
                        // remaining cards (the mock's grid behavior).
                        for (final (i, item) in row.indexed) ...[
                          Expanded(
                            child: _ContinueCard(
                              key: ValueKey(item.url),
                              item: item,
                              widthOverride: math.max(
                                0.0,
                                (constraints.maxWidth - _gap * (columns - 1)) /
                                    columns,
                              ),
                            ),
                          ),
                          if (i != row.length - 1) const SizedBox(width: _gap),
                        ],
                        // Empty trailing slots (single row, fewer items than
                        // columns) hold the grid's column width.
                        for (var e = row.length; e < columns; e++) ...[
                          const Expanded(child: SizedBox()),
                          if (e != columns - 1) const SizedBox(width: _gap),
                        ],
                      ],
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Desktop-native continue card — element-wise its own layout, not the
/// mobile rail's: 16:9 cover with type + episode chips and a progress
/// hairline; the footer carries title + remaining/position text on one line
/// and the episode-title x source line under it.
class _ContinueCard extends HookConsumerWidget {
  const _ContinueCard({super.key, required this.item, this.widthOverride});

  final History item;

  /// Card width; the grid passes its per-row column share so the 16:9 cover
  /// scales with the slot.
  final double? widthOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final hovering = useState(false);
    final width = widthOverride ?? 280.0;
    final coverHeight = width * 9 / 16;
    final total = item.totalProgress;
    final progress = total > 0 ? (item.progress / total).clamp(0.0, 1.0) : 0.0;
    final type = item.extensionType;

    return AnimatedBox.nopadding(
      onTap: () =>
          openHistoryWatchSession(context: context, ref: ref, history: item),
      // Long-press offers removal, mirroring the history list's sheet.
      onLongPress: () => showRemoveSheet(
        context: context,
        title: item.title,
        actionLabel: 'home.remove_from_continue'.i18n,
        actionIcon: FLucideIcons.trash2,
        destructive: true,
        onRemove: () =>
            ref.read(historyPageProvider.notifier).deleteHistory(item),
      ),
      child: SizedBox(
        width: width,
        child: MiruCard(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hover region scoped to the cover: the mock's play circle
              // fades in over a 50% black scrim.
              MouseRegion(
                onEnter: (_) => hovering.value = true,
                onExit: (_) => hovering.value = false,
                child: Stack(
                  children: [
                    // Cover chips (2026-11-12 audit: type chip stripped —
                    // the secondary metadata line under the title owns the
                    // source/type context): episode top-left, remaining-time
                    // pill bottom-right. Artwork hover-drifts to 1.05.
                    AnimatedScale(
                      scale: hovering.value ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: SizedBox(
                        key: const Key('desktopContinueCover'),
                        height: coverHeight,
                        width: double.infinity,
                        child: ImageWidget(
                          imageUrl: item.cover,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                          loadingChild: const HomeMediaSkeletonBox(
                            borderRadius: 0,
                          ),
                          // Structured placeholder for a missing cover: gradient
                          // tile + type glyph + "no preview" hint, framed by a
                          // hairline so dark artwork never bleeds into the
                          // canvas.
                          // Glyph-only fallback (no raw "No cover" text on
                          // dense tiles — the gradient ramp + type glyph read
                          // as a standby state, not a broken image).
                          errChild: HomeCoverFallback(
                            icon: switch (type) {
                              ExtensionType.bangumi => FLucideIcons.play,
                              ExtensionType.manga => FLucideIcons.bookOpen,
                              _ => FLucideIcons.bookMarked,
                            },
                            showLabel: false,
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
                              colors.background.withAlpha(120),
                              const Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Cover chips (mock rev 4): source/type + episode
                    // top-left, remaining-time pill bottom-right.
                    Positioned(
                      top: 8,
                      left: 8,
                      child: HomeChip(label: _episodeChipLabel()),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.background.withAlpha(204),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.fromBorderSide(
                            BorderSide(color: colors.border),
                          ),
                        ),
                        child: Text(
                          _positionLabel(),
                          style: typography.body.xs2.copyWith(
                            color: colors.foreground,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    // Hover-only play affordance (one centered circle).
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: hovering.value ? 1 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: Color(0x80000000),
                            ),
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.foreground,
                                ),
                                child: Icon(
                                  FLucideIcons.play,
                                  size: 18,
                                  color: colors.background,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Neutral progress hairline on the cover's bottom edge.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: colors.muted),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.foreground,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Truncated titles keep the full name reachable (hover
                    // tooltip) — the footer line alone ellipsizes.
                    Tooltip(
                      message: displayTitle(item.title),
                      child: Text(
                        displayTitle(item.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // The mock's single metadata line: source package (the
                    // cover pill owns duration/position — no duplication).
                    Text(
                      item.package,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs2.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cover chip 2: where the viewer is — Ep/Ch/Vol from the saved episode
  /// slot, one prefix per media type.
  String _episodeChipLabel() => switch (item.extensionType) {
    ExtensionType.bangumi => 'home.episode_chip'.i18n.fill({
      'n': '${item.episodeId + 1}',
    }),
    ExtensionType.manga => 'home.chapter_chip'.i18n.fill({
      'n': '${item.episodeId + 1}',
    }),
    _ => 'home.volume_chip'.i18n.fill({'n': '${item.episodeId + 1}'}),
  };

  /// Footer-right: remaining minutes for video, saved position for print
  /// media (same units the reader/watcher stored).
  String _positionLabel() {
    final total = item.totalProgress;
    if (item.extensionType == ExtensionType.bangumi) {
      if (total > 0) {
        return 'home.time_left'.i18n.fill({
          'n': '${((total - item.progress) / 60).ceil()}',
        });
      }
      return '${(item.progress / math.max(total, 1) * 100).round()}%';
    }
    return 'home.location_progress'.i18n.fill({
      'p': '${item.progress}',
      't': '${item.totalProgress}',
    });
  }
}
