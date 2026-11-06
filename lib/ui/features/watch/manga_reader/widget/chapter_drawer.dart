import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/core/widget/eq_bars.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_sheet.dart';
import 'package:miru_alpha/utils/core/date_format.dart';
import 'package:miru_alpha/utils/core/episode_label.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Opens the chapter list as a FORUI modal sheet and resolves once dismissed.
///
/// The drawer's reader state arrives as plain values and goes back out through
/// a callback, so it holds no reference to a provider that may already have been
/// disposed by the time the sheet builds — a sheet outlives the screen that
/// opened it.
Future<void> showChapterDrawer(
  BuildContext context, {
  required EpisodeNotifierProvider epProvider,

  /// 1-based position within the open chapter, in the unit the reader navigates
  /// (manga pages, novel lines). Zero when nothing has been read yet.
  required int openPosition,

  /// Total units in the open chapter, in the same unit as [openPosition].
  required int openTotal,
}) {
  return showFSheet<void>(
    context: context,
    side: .btt,
    // The sheet's own size cap is out of the picture: the
    // [DraggableScrollableSheet] inside owns grow/collapse so the LIST drags
    // the sheet with it — pulling the list at its top edge collapses and then
    // dismisses the sheet, the way a scrollable material bottom sheet behaves.
    // FORUI's own doc: a scrollable child wants `mainAxisMaxRatio: null`.
    mainAxisMaxRatio: null,
    builder: (context) => _ChapterDrawer(
      epProvider: epProvider,
      openPosition: openPosition,
      openTotal: openTotal,
    ),
  );
}

/// Which direction the chapter list is sorted in.
enum ChapterOrder { ascending, descending }

class _ChapterDrawer extends StatelessWidget {
  const _ChapterDrawer({
    required this.epProvider,
    required this.openPosition,
    required this.openTotal,
  });

  final EpisodeNotifierProvider epProvider;
  final int openPosition;
  final int openTotal;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      // Open at the ~90% cap the sheet used to have. Dragging the list at its
      // top edge collapses toward [minChildSize], where FORUI's sheet closes
      // it (it listens for the sheet's own min-extent notification).
      minChildSize: 0.5,
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      builder: (context, scrollController) => _ChapterSheetBody(
        epProvider: epProvider,
        openPosition: openPosition,
        openTotal: openTotal,
        scrollController: scrollController,
      ),
    );
  }
}

/// The drawer's panel: handle, header, filter field and the chapter list.
///
/// Hooks live here rather than in [_ChapterDrawer] because the list's scroll
/// controller only exists inside the sheet's builder, and the auto-scroll
/// effect needs it.
class _ChapterSheetBody extends HookConsumerWidget {
  const _ChapterSheetBody({
    required this.epProvider,
    required this.openPosition,
    required this.openTotal,
    required this.scrollController,
  });

  final EpisodeNotifierProvider epProvider;
  final int openPosition;
  final int openTotal;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epState = ref.watch(epProvider);
    final epReader = ref.read(epProvider.notifier);
    final groupIndex = epState.selectedGroupIndex.clamp(
      0,
      epState.epGroup.isEmpty ? 0 : epState.epGroup.length - 1,
    );
    final group = epState.epGroup.isEmpty ? null : epState.epGroup[groupIndex];
    final order = useState(ChapterOrder.descending);
    final filter = useState('');

    final episodes = group?.urls ?? const <ExtensionEpisode>[];
    final visible = _filter(episodes, filter.value, order.value);
    final selectedDisplay = visible.indexWhere(
      (entry) => entry.index == epState.selectedEpisodeIndex,
    );

    // The open chapter is brought into view once the list has laid out, and
    // again after every sort flip (the flip reverses the rows under a fixed
    // scroll offset, which would otherwise leave the open chapter off-screen).
    // A row the lazy list never built (far from the top) is jumped to by
    // estimate first and refined on the following frame.
    final selectedKey = useMemoized(GlobalKey.new, const []);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        void reveal() => Scrollable.ensureVisible(
          selectedKey.currentContext!,
          alignment: 0.25,
          duration: const Duration(milliseconds: 250),
        );
        if (selectedKey.currentContext != null) {
          reveal();
        } else if (selectedDisplay > 0 && scrollController.hasClients) {
          final estimate = (selectedDisplay * 72.0).clamp(
            0.0,
            scrollController.position.maxScrollExtent,
          );
          scrollController.jumpTo(estimate);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (selectedKey.currentContext != null) reveal();
          });
        }
      });
      return null;
    }, [order.value]);

    return ReaderSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ReaderSheetHandle(),
          // Header, laid out like the detail page's episode section: a
          // "Chapters (N)" heading, then the volume selector and the sort
          // toggle pinned to the right edge. The heading sits on the CONTENT
          // text grid (the card's inner text line, where the ordinals and the
          // field's hint start — x≈32), inset one step from the card edge
          // below it, instead of hanging on the card's border line.
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 16, 4),
            child: Row(
              children: [
                // Title + count share ONE Expanded slot. A loose Flexible
                // beside a Spacer loses its unused flex share as trailing
                // dead space (RenderFlex never redistributes it), which left
                // the close button ~58px short of the row's end.
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'reader.manga.chapters_title'.i18n,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.theme.colors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${episodes.length})',
                        style: context.theme.typography.body.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (epState.epGroup.length > 1) ...[
                  _GroupSelector(
                    groups: epState.epGroup,
                    selected: groupIndex,
                    onSelect: (index) => epReader.selectEpisode(index, 0),
                  ),
                  const SizedBox(width: 8),
                ],
                // Sort keeps the outline box; the close is a bare ghost glyph
                // in a content-tight box, flush with the row's trailing inset
                // — a full-width hit box around a 16px glyph read as a huge
                // dead zone at the sheet's edge.
                _headerIconButton(
                  context,
                  icon: order.value == ChapterOrder.descending
                      ? const Icon(FLucideIcons.arrowUp10)
                      : const Icon(FLucideIcons.arrowDown01),
                  onPress: () =>
                      order.value = order.value == ChapterOrder.descending
                      ? ChapterOrder.ascending
                      : ChapterOrder.descending,
                ),
                const SizedBox(width: 8),
                _headerIconButton(
                  context,
                  variant: .ghost,
                  // 40 = the touch-target floor: the glyph stays visually
                  // where it was, the hit box stops failing Fitts's Law.
                  box: 40,
                  icon: const Icon(FLucideIcons.x, size: 16),
                  semanticLabel: 'common.close'.i18n,
                  onPress: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            // A plain FORUI field: the hand-prefixed search icon never aligned
            // its baseline with the hint text, and the field carries its own
            // clear affordance.
            child: FTextField(
              hint: 'reader.manga.filter_chapters'.i18n,
              control: FTextFieldControl.lifted(
                value: TextEditingValue(text: filter.value),
                onChange: (value) => filter.value = value.text,
              ),
              clearable: (_) => filter.value.isNotEmpty,
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'reader.manga.no_chapters'.i18n,
                        style: context.theme.typography.body.sm.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  )
                // FORUI's own tile group with full dividers — the same list
                // chrome the detail page's episode section uses. The scroll
                // controller is the sheet's: the two scroll as one. The group
                // is inset to the SAME 16px line as the filter field above it,
                // so the sheet reads one grid instead of a full-bleed list
                // under a padded field.
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FTileGroup.builder(
                      scrollController: scrollController,
                      divider: .full,
                      count: visible.length,
                      tileBuilder: (context, index) {
                        final entry = visible[index];
                        final selected =
                            entry.index == epState.selectedEpisodeIndex;
                        final tile = _ChapterTile(
                          position: entry.index,
                          episode: entry.episode,
                          selected: selected,
                          page: selected ? openPosition : 0,
                          totalPage: openTotal,
                          onPress: () =>
                              _open(context, epReader, groupIndex, entry.index),
                        );
                        return selected
                            ? KeyedSubtree(key: selectedKey, child: tile)
                            : tile;
                      },
                    ),
                  ),
          ),
          // The last row must clear the home indicator: FORUI's bottom sheet
          // keeps the bottom inset in MediaQuery (it only strips the top), so
          // the panel pays it here rather than clipping behind it.
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
        ],
      ),
    );
  }

  /// Opens a chapter and gets the drawer out of the way.
  void _open(
    BuildContext context,
    EpisodeNotifier epReader,
    int groupIndex,
    int episodeIndex,
  ) {
    epReader.selectEpisode(groupIndex, episodeIndex);
    // Picking a chapter navigates, so get out of the way and let the reader take
    // the screen back.
    Navigator.of(context).maybePop();
  }

  List<_ChapterEntry> _filter(
    List<ExtensionEpisode> episodes,
    String query,
    ChapterOrder order,
  ) {
    final needle = query.trim().toLowerCase();
    final matches = episodes.asMap().entries.where(
      (entry) =>
          needle.isEmpty || entry.value.name.toLowerCase().contains(needle),
    );
    // The toggle is a REVERSE, nothing more: ascending is the source's own
    // order, descending is that reversed. No title parsing, no re-sorting.
    final entries = [
      for (final entry in matches) _ChapterEntry(entry.key, entry.value),
    ];
    if (order == ChapterOrder.descending) {
      entries.sort((a, b) => b.index.compareTo(a.index));
    }
    return entries;
  }
}

class _ChapterEntry {
  const _ChapterEntry(this.index, this.episode);

  final int index;
  final ExtensionEpisode episode;
}

/// The header's compact icon button, shared by the sort toggle and the close
/// button so the pair is one control group. [box] sizes the hit box; the
/// glyph stays content-centred inside it with no extra dead space.
Widget _headerIconButton(
  BuildContext context, {
  required Widget icon,
  FButtonVariant variant = .outline,
  double box = 36,
  String? semanticLabel,
  required VoidCallback onPress,
}) => FButton.icon(
  variant: variant,
  size: .xs,
  style: .delta(
    iconContentStyle: .delta(
      constraints: BoxConstraints(minWidth: box, minHeight: box),
      padding: EdgeInsetsGeometryDelta.value(
        EdgeInsets.symmetric(
          horizontal: (box - 16) / 2,
          vertical: (box - 16) / 2,
        ),
      ),
    ),
  ),
  onPress: onPress,
  child: semanticLabel == null
      ? icon
      : Semantics(label: semanticLabel, button: true, child: icon),
);

/// One chapter, laid out like the detail page's episode row: a muted ordinal
/// that pairs with the title's own chapter number, the stripped title as the
/// primary label, and the open chapter as the accent-carded "playing" row with
/// a reading-progress bar. Tapping a row goes straight to that chapter — the
/// extension's `selectedEpisodeIndex` is all the reader needs, so there is no
/// intermediate confirm step.
class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.position,
    required this.episode,
    required this.selected,
    required this.page,
    required this.totalPage,
    required this.onPress,
  });

  /// Zero-based position in the source list, so the number badge stays stable
  /// whichever sort order the list is in.
  final int position;

  final ExtensionEpisode episode;
  final bool selected;
  final int page;
  final int totalPage;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.colors.primary;
    return FTile(
      onPress: onPress,
      selected: selected,
      style: .delta(
        contentDecoration: .delta([
          // Same raised treatment as the detail list's playing row. Emitted
          // UNCONDITIONALLY (no `.match({.selected}, …)`) on purpose: Forui
          // 0.27.6's FItem never adds `selected` to its style variants, so
          // variant-matched selected decorations never paint — the condition
          // lives here in the build.
          if (selected)
            .base(
              DecorationDelta.boxDelta(
                color: accent.withAlpha(26),
                border: Border.all(color: accent.withAlpha(128)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ]),
        contentStyle: .delta(
          suffixedPadding: EdgeInsetsGeometryDelta.value(
            // Leading 16 puts the ordinal on the sheet's content-text grid
            // (x=32, the same line as the heading and the field's text); the
            // forui default's 15 landed it one pixel off.
            const EdgeInsets.fromLTRB(16, 8, 13, 8),
          ),
          titleSpacing: 2,
        ),
      ),
      // Secondary metadata, deliberately quiet: the title is the row's
      // primary label, and a bold ordinal next to a regular title reads
      // inverted (the number used to outweigh the content).
      prefix: SizedBox(
        width: 30,
        child: Text(
          _ordinal(),
          textAlign: TextAlign.center,
          style: context.theme.typography.body.xs.copyWith(
            fontWeight: FontWeight.w500,
            color: selected ? accent : context.theme.colors.mutedForeground,
          ),
        ),
      ),
      // No trailing action: the row itself opens the chapter, and bookmarking
      // lives in the reader top bar for the open chapter only.
      suffix: selected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EqBars(),
                const SizedBox(width: 6),
                FBadge(
                  variant: .primary,
                  style: .delta(
                    padding: EdgeInsetsGeometryDelta.value(
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    ),
                  ),
                  child: Text(
                    'reader.manga.reading'.i18n,
                    style: context.theme.typography.body.xs2.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.theme.colors.primaryForeground,
                    ),
                  ),
                ),
              ],
            )
          : null,
      title: Text(
        _title(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.theme.typography.body.sm.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: context.theme.colors.foreground.withAlpha(216),
        ),
      ),
      subtitle: _subtitle(context),
    );
  }

  /// The prefix box carries the row's source position: a plain, quiet
  /// counter that stays stable whichever way the list is reversed.
  String _ordinal() => '${position + 1}';

  /// The prefix box already carries the ordinal, so an "Episode N - " title
  /// prefix is stripped the same way the detail list strips it. A name that is
  /// itself a bare backend number ("0") renders as a human "Episode N" instead
  /// of "01 | 0".
  String _title() {
    if (isBareEpisodeName(episode.name)) {
      return 'media.episode_number'.fill({'n': '${position + 1}'});
    }
    return stripEpisodePrefix(episode.name);
  }

  /// The open chapter reads like the detail list's in-progress row: a thin
  /// progress bar, then the page position. Other rows show the extension's
  /// update stamp, and nothing at all if there is no stamp. Never falls back to
  /// [ExtensionEpisode.url] or `.description`: several manga sources put the
  /// chapter URL in `description`, and a raw URL is noise in a chapter list.
  Widget _subtitle(BuildContext context) {
    if (selected && totalPage > 0) {
      final frac = (page / totalPage).clamp(0.0, 1.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 4,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(color: context.theme.colors.muted),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: frac,
                  child: ColoredBox(color: context.theme.colors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${'reader.manga.page'.i18n} $page/$totalPage',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      );
    }
    final date = tryFormatTimeAgo(episode.update);
    if (date == null || date.isEmpty) return const SizedBox.shrink();
    return Text(
      date,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.theme.typography.body.xs.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    );
  }
}

/// The detail list's volume picker: an outline button showing the open volume's
/// title, opening a tile menu of every `epGroup` entry. Selecting one switches
/// the group and its first episode, which is what the extension API's
/// `selectEpisode` means.
class _GroupSelector extends HookWidget {
  const _GroupSelector({
    required this.groups,
    required this.selected,
    required this.onSelect,
  });

  final List<ExtensionEpisodeGroup> groups;
  final int selected;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final controller = useFPopoverController();
    return FPopoverMenu.tiles(
      menuAnchor: .topCenter,
      menu: [
        .group(
          children: [
            for (var i = 0; i < groups.length; i++)
              FTile(
                onPress: () {
                  onSelect(i);
                  controller.toggle();
                },
                title: Text(groups[i].title),
              ),
          ],
        ),
      ],
      control: .managed(controller: controller),
      child: FButton(
        variant: .outline,
        size: .xs,
        mainAxisAlignment: .start,
        style: .delta(
          contentStyle: .delta(
            constraints: const BoxConstraints(minHeight: 36),
          ),
        ),
        onPress: () {
          controller.toggle();
        },
        suffix: Icon(
          FLucideIcons.chevronDown,
          size: 14,
          color: context.theme.colors.mutedForeground,
        ),
        // Cap keeps long volume titles from squeezing the sort button on
        // 320 px phones, exactly like the detail list's selector.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            groups[selected].title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.xs.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
