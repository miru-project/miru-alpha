import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_button.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_sheet.dart';
import 'package:miru_alpha/utils/core/date_format.dart';
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

  /// Bookmarked chapters, keyed `"<groupIndex>:<episodeIndex>"`.
  required Set<String> bookmarks,

  /// 1-based position within the open chapter, in the unit the reader navigates
  /// (manga pages, novel lines). Zero when nothing has been read yet.
  required int openPosition,

  /// Total units in the open chapter, in the same unit as [openPosition].
  required int openTotal,

  /// Adds or removes the bookmark for one chapter, leaving the rest alone.
  required void Function(int groupIndex, int episodeIndex) onToggleBookmark,

  /// Opens the reader's own settings sheet, after the drawer steps aside.
  required VoidCallback onOpenSettings,
}) {
  return showFSheet<void>(
    context: context,
    side: .btt,
    mainAxisMaxRatio: 0.9,
    builder: (context) => _ChapterDrawer(
      epProvider: epProvider,
      bookmarks: bookmarks,
      openPosition: openPosition,
      openTotal: openTotal,
      onToggleBookmark: onToggleBookmark,
      onOpenSettings: onOpenSettings,
    ),
  );
}

/// Which direction the chapter list is sorted in.
enum ChapterOrder { ascending, descending }

/// Fixed height of a chapter row, so the list reads as one rhythm rather than a
/// column of differently sized rows.
const kChapterTileHeight = 64.0;

class _ChapterDrawer extends HookConsumerWidget {
  const _ChapterDrawer({
    required this.epProvider,
    required this.bookmarks,
    required this.openPosition,
    required this.openTotal,
    required this.onToggleBookmark,
    required this.onOpenSettings,
  });

  final EpisodeNotifierProvider epProvider;
  final Set<String> bookmarks;
  final int openPosition;
  final int openTotal;
  final void Function(int groupIndex, int episodeIndex) onToggleBookmark;
  final VoidCallback onOpenSettings;

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

    // The bookmark set is mirrored locally rather than watched from a provider:
    // the drawer is a separate route, so the reader's state is not the thing
    // that repaints it. Every toggle is written straight through, so a reopened
    // drawer shows the same ticks.
    final localBookmarks = useState(bookmarks);
    void toggle(int group, int episode) {
      onToggleBookmark(group, episode);
      final next = {...localBookmarks.value};
      if (!next.remove('$group:$episode')) next.add('$group:$episode');
      localBookmarks.value = next;
    }

    final listController = useMemoized(ScrollController.new, const []);
    useEffect(
      () =>
          () => listController.dispose(),
      const [],
    );

    final episodes = group?.urls ?? const <ExtensionEpisode>[];
    final visible = _filter(episodes, filter.value, order.value);

    return ReaderSheetPanel(
      maxHeightFactor: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ReaderSheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'reader.manga.chapters_title'.i18n,
                        style: context.theme.typography.body.lg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.theme.colors.foreground,
                        ),
                      ),
                      // Reference: the manga name, a bullet, and how many
                      // chapters are on offer.
                      Text(
                        group == null
                            ? 'reader.manga.no_chapters'.i18n
                            : '${group.title} · '
                                  '${'reader.manga.chapters_available'.i18n.replaceFirst('{count}', '${episodes.length}')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.body.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: () => Navigator.of(context).maybePop(),
                  child: const Icon(FLucideIcons.x, size: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: FTextField(
              hint: 'reader.manga.filter_chapters'.i18n,
              control: FTextFieldControl.lifted(
                value: TextEditingValue(text: filter.value),
                onChange: (value) => filter.value = value.text,
              ),
              prefixBuilder: (context, style, variants) => Icon(
                FLucideIcons.search,
                size: 16,
                color: context.theme.colors.mutedForeground,
              ),
              clearable: (_) => filter.value.isNotEmpty,
            ),
          ),
          // Reference: a single arrow that flips the order. A two-option strip
          // put both labels in a column the panel could not afford, and the
          // state is already obvious from the list itself.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Row(
              children: [
                // Icon only: the arrow says which order the list is in, and
                // `FTappable` lays its child out unconstrained, so a label with
                // an ellipsis inside one has nothing to ellipsise against.
                _GhostControl(
                  icon: order.value == ChapterOrder.descending
                      ? FLucideIcons.arrowDown
                      : FLucideIcons.arrowUp,
                  semanticsLabel: 'reader.manga.order.${order.value.name}'.i18n,
                  onPress: () =>
                      order.value = order.value == ChapterOrder.descending
                      ? ChapterOrder.ascending
                      : ChapterOrder.descending,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GhostControl(
                    icon: FLucideIcons.navigation,
                    semanticsLabel: 'reader.manga.jump'.i18n,
                    label: 'reader.manga.jump'.i18n,
                    onPress: () => _jump(context, ref, episodes, order.value),
                  ),
                ),
              ],
            ),
          ),
          // The reference's horizontal carousel of volumes, mirrored from the
          // extension's `epGroup` and drawn with FORUI's own tile so the
          // selected volume gets the same focused outline a selected chapter
          // does. Tapping one selects the group and its first episode, which is
          // what the extension API's `selectEpisode` means.
          if (epState.epGroup.length > 1)
            SizedBox(
              // Tall enough for a tile (56) plus the carousel's own padding.
              height: 72,
              child: ListView.separated(
                scrollDirection: .horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: epState.epGroup.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => _GroupTile(
                  label: epState.epGroup[index].title,
                  chapters: epState.epGroup[index].urls.length,
                  selected: index == groupIndex,
                  onPress: () => epReader.selectEpisode(index, 0),
                ),
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
                // FORUI's own tile group, so the chapter list gets its
                // dividers, spacing and selection styling — and its scroll
                // view — instead of a hand-rolled box per row.
                : FTileGroup.builder(
                    count: visible.length,
                    tileBuilder: (context, index) {
                      final entry = visible[index];
                      return _ChapterTile(
                        position: entry.index,
                        episode: entry.episode,
                        selected: entry.index == epState.selectedEpisodeIndex,
                        isLatest: entry.index == episodes.length - 1,
                        bookmarked: localBookmarks.value.contains(
                          '$groupIndex:${entry.index}',
                        ),
                        page: entry.index == epState.selectedEpisodeIndex
                            ? openPosition
                            : 0,
                        totalPage: openTotal,
                        onBookmark: () => toggle(groupIndex, entry.index),
                        onPress: () =>
                            _open(context, epReader, groupIndex, entry.index),
                      );
                    },
                  ),
          ),
          // Reference: the drawer closes on a sticky two-action bar.
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.theme.colors.border),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ReaderButton(
                    variant: .secondary,
                    onPress: () =>
                        toggle(groupIndex, epState.selectedEpisodeIndex),
                    child: Row(
                      mainAxisSize: .min,
                      spacing: 4,
                      children: [
                        Icon(
                          localBookmarks.value.contains(
                                '$groupIndex:${epState.selectedEpisodeIndex}',
                              )
                              ? FLucideIcons.bookmarkCheck
                              : FLucideIcons.bookmark,
                          size: 16,
                        ),
                        ReaderLabel(
                          localBookmarks.value.contains(
                                '$groupIndex:${epState.selectedEpisodeIndex}',
                              )
                              ? 'reader.manga.add_bookmark_added'.i18n
                              : 'reader.manga.add_bookmark'.i18n,
                          style: context.theme.typography.body.xs,
                          maxWidth: 120,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ReaderButton(
                    variant: .primary,
                    onPress: () {
                      // Settings are a sheet of their own, so the drawer steps
                      // aside for it.
                      Navigator.of(context).maybePop();
                      onOpenSettings();
                    },
                    child: Row(
                      mainAxisSize: .min,
                      spacing: 4,
                      children: [
                        const Icon(FLucideIcons.slidersHorizontal, size: 16),
                        ReaderLabel(
                          'reader.manga.settings'.i18n,
                          style: context.theme.typography.body.xs,
                          maxWidth: 120,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  /// The reference's fast-jump: ask for a number and open that chapter.
  Future<void> _jump(
    BuildContext context,
    WidgetRef ref,
    List<ExtensionEpisode> episodes,
    ChapterOrder order,
  ) async {
    final controller = TextEditingController();
    final groupIndex = ref.read(epProvider).selectedGroupIndex;
    final input = await showFSheet<String>(
      context: context,
      side: .btt,
      builder: (context) => ReaderSheetPanel(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ReaderSheetHandle(),
              FTextField(
                autofocus: true,
                hint: 'reader.manga.jump_hint'.i18n,
                keyboardType: TextInputType.number,
                control: FTextFieldControl.managed(controller: controller),
              ),
              const SizedBox(height: 12),
              ReaderButton(
                variant: .primary,
                onPress: () =>
                    Navigator.of(context).pop(controller.text.trim()),
                child: ReaderLabel('reader.manga.jump'.i18n),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    final number = int.tryParse(input ?? '');
    if (number == null || episodes.isEmpty) return;
    // The list is a filtered, sorted view, so the number is matched against the
    // source order: "chapter 3" means the third one the extension listed.
    final index = number.clamp(1, episodes.length) - 1;
    ref.read(epProvider.notifier).selectEpisode(groupIndex, index);
    if (context.mounted) Navigator.of(context).maybePop();
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
    final ordered = matches.toList();
    if (order == ChapterOrder.descending) {
      ordered.sort((a, b) => b.key.compareTo(a.key));
    }
    return [for (final entry in ordered) _ChapterEntry(entry.key, entry.value)];
  }
}

class _ChapterEntry {
  const _ChapterEntry(this.index, this.episode);

  final int index;
  final ExtensionEpisode episode;
}

/// One chapter, as FORUI's own [FTile].
///
/// The open chapter is `selected`, so its focus outline is FORUI's rather than
/// a border drawn here, and tapping a row goes straight to that chapter: the
/// extension's `selectedEpisodeIndex` is all the reader needs, so there is no
/// intermediate confirm step.
class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.position,
    required this.episode,
    required this.selected,
    required this.isLatest,
    required this.bookmarked,
    required this.page,
    required this.totalPage,
    required this.onBookmark,
    required this.onPress,
  });

  /// Zero-based position in the source list, so the number badge stays stable
  /// whichever sort order the list is in.
  final int position;

  final ExtensionEpisode episode;
  final bool selected;

  /// Whether this is the newest chapter in the source list.
  final bool isLatest;

  final bool bookmarked;
  final int page;
  final int totalPage;
  final VoidCallback onBookmark;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FTile(
      onPress: onPress,
      selected: selected,
      prefix: _badge(context),
      title: ReaderLabel(episode.name, style: context.theme.typography.body.sm),
      subtitle: ReaderLabel(
        _subtitle(),
        softWrap: true,
        style: context.theme.typography.body.xs.copyWith(
          color: selected
              ? context.theme.colors.foreground
              : context.theme.colors.mutedForeground,
        ),
      ),
      suffix: selected
          // The open chapter gets the reference's Resume action rather than the
          // bookmark it shares with every other row.
          ? ReaderButton(
              variant: .primary,
              height: ReaderControlSize.compact,
              onPress: onPress,
              child: ReaderLabel(
                'reader.manga.resume'.i18n,
                style: context.theme.typography.body.xs,
                maxWidth: 90,
              ),
            )
          : ReaderIconAction(
              icon: bookmarked
                  ? FLucideIcons.bookmarkCheck
                  : FLucideIcons.bookmark,
              tooltip: 'reader.manga.add_bookmark'.i18n,
              height: ReaderControlSize.compact,
              onPress: onBookmark,
            ),
    );
  }

  /// Reference states: a "Reading" pill for the open chapter, a "New" pill for
  /// the newest release, the position number otherwise.
  Widget _badge(BuildContext context) {
    if (selected) {
      return FBadge(
        variant: .primary,
        child: Text('reader.manga.reading'.i18n),
      );
    }
    if (isLatest) {
      return FBadge(variant: .secondary, child: Text('reader.manga.new'.i18n));
    }
    return FBadge(variant: .secondary, child: Text('${position + 1}'));
  }

  /// Never falls back to [ExtensionEpisode.url] or `.description`: several manga
  /// sources put the chapter URL in `description`, and a raw URL is noise in a
  /// list of chapter names. Reading progress, then the extension's update
  /// stamp, and nothing at all if there is no stamp.
  String _subtitle() {
    if (selected && totalPage > 0) {
      return '${'reader.manga.page'.i18n} $page/$totalPage';
    }
    return tryFormatTimeAgo(episode.update) ?? '';
  }
}

/// A borderless control for the drawer's filter row.
///
/// An `FButton` cannot be laid out here: the drawer's column passes an unbounded
/// width down, and FORUI's button content row then has a flexible child with no
/// width to fill. `FTappable` plus a box keeps the row shrink-wrapping.
class _GhostControl extends StatelessWidget {
  const _GhostControl({
    required this.icon,
    required this.semanticsLabel,
    required this.onPress,
    this.label,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onPress;

  /// Visible text. Omitted for an icon-only control.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final text = label;
    return FTappable(
      onPress: onPress,
      semanticsLabel: semanticsLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: text == null
            ? Icon(icon, size: 16, color: colors.mutedForeground)
            : Row(
                // `max` with a flexible label: this control is given a bounded
                // width by an `Expanded`, and a long translation has to
                // ellipsise rather than overflow the row.
                mainAxisSize: .max,
                spacing: 4,
                children: [
                  Icon(icon, size: 16, color: colors.mutedForeground),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.xs.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// One volume from the extension's `epGroup`.
///
/// An [FTile], like a chapter row, so both halves of the drawer share FORUI's
/// selection styling. It deliberately avoids [FButton]: this lives in a
/// horizontally scrolling list, where a button's content row has no width to
/// work with.
class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.label,
    required this.chapters,
    required this.selected,
    required this.onPress,
  });

  final String label;
  final int chapters;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ConstrainedBox(
      // A tile lays out to the width it is given, and a horizontal carousel
      // gives it none, so the width is bounded here — the reference's pills are
      // a fixed-ish size anyway.
      constraints: const BoxConstraints(minWidth: 108, maxWidth: 190),
      child: FTile(
        onPress: onPress,
        selected: selected,
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colors.foreground : colors.mutedForeground,
          ),
        ),
        subtitle: Text(
          '$chapters',
          style: context.theme.typography.body.xs.copyWith(
            color: colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
