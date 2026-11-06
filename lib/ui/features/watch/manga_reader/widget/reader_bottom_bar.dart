import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_button.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_segmented.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_settings_sheet.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Reader control panel: chapter paging, page scrubber, reading direction and
/// the brightness toggle. Mirrors the reference's `BottomSheetHUD` row for row.
class ReaderBottomBar extends ConsumerWidget {
  const ReaderBottomBar({
    super.key,
    required this.mangaProvider,
    required this.epProvider,
    required this.onOpenChapters,
  });

  final MangaReaderProvider mangaProvider;
  final EpisodeNotifierProvider epProvider;
  final VoidCallback onOpenChapters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mangaProvider);
    final reader = ref.read(mangaProvider.notifier);
    final epState = ref.watch(epProvider);
    final epReader = ref.read(epProvider.notifier);
    final groupIndex = epState.selectedGroupIndex.clamp(
      0,
      epState.epGroup.isEmpty ? 0 : epState.epGroup.length - 1,
    );
    final episodes = epState.epGroup.isEmpty
        ? const <ExtensionEpisode>[]
        : epState.epGroup[groupIndex].urls;
    final currentEpisode = episodes.isEmpty
        ? null
        : episodes[epState.selectedEpisodeIndex.clamp(0, episodes.length - 1)];
    final isFirstEpisode = epState.selectedEpisodeIndex == 0;
    final isLastEpisode = epState.selectedEpisodeIndex >= episodes.length - 1;
    final colors = context.theme.colors;

    return ReaderChrome(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1 — chapter pagination.
          _ChapterNavRow(
            label: currentEpisode?.name ?? 'reader.manga.chapters'.i18n,
            hasPrevious: !isFirstEpisode,
            hasNext: !isLastEpisode,
            onPrevious: () => epReader.selectEpisode(
              epState.selectedGroupIndex,
              epState.selectedEpisodeIndex - 1,
            ),
            onNext: () => epReader.selectEpisode(
              epState.selectedGroupIndex,
              epState.selectedEpisodeIndex + 1,
            ),
            onSelect: onOpenChapters,
          ),
          const SizedBox(height: 14),
          // Row 2 — page scrubber.
          _PageScrubber(
            page: state.page,
            totalPage: state.totalPage,
            episodeKey:
                '${epState.selectedGroupIndex}:${epState.selectedEpisodeIndex}',
            onScrub: reader.jumpTo,
          ),
          const SizedBox(height: 14),
          // Reference: the direction strip and the shortcuts are separated from
          // the rows above by a hairline.
          Divider(height: 1, thickness: 1, color: colors.border),
          const SizedBox(height: 10),
          // Row 3 — direction strip + the brightness toggle on the trailing edge.
          Row(
            // `spaceBetween`, not a Spacer: a Spacer is a *flex* child, so it
            // would split the row with the strip and squeeze the mode labels
            // down to "L …". Here the strip takes its intrinsic width and the
            // leftover space becomes the gap.
            mainAxisAlignment: .spaceBetween,
            children: [
              Flexible(
                child: ReaderSegmented<MangaReadMode>(
                  value: state.readMode,
                  // Reference order: Webtoon | L to R | R to L.
                  options: kReaderReadModeOrder,
                  onChanged: reader.changeReadMode,
                  labelBuilder: (mode) =>
                      'reader.manga.read_mode.short.${mode.name}'.i18n,
                ),
              ),
              // A toggle, not a menu: auto is the one thing the reader cannot
              // see from the artwork, and it is a single tap. The manual
              // percentage lives in the settings sheet (top bar).
              ReaderIconAction(
                icon: state.brightnessMode == MangaBrightnessMode.auto
                    ? FLucideIcons.sunrise
                    : FLucideIcons.sunMedium,
                tooltip: 'reader.manga.brightness'.i18n,
                selected: state.brightnessMode == MangaBrightnessMode.auto,
                onPress: () => reader.setBrightnessMode(
                  state.brightnessMode == MangaBrightnessMode.auto
                      ? MangaBrightnessMode.manual
                      : MangaBrightnessMode.auto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Caps the Prev/Next labels so an unbroken word (a raw i18n key, or a
/// single-word language) cannot push the chapter selector out of the row.
/// Generous enough for "Zurück" / "Siguiente" / "上一章".
const double _kNavLabelMaxWidth = 96;

/// Prev / chapter selector / next, matching the reference's chapter
/// pagination row.
class _ChapterNavRow extends StatelessWidget {
  const _ChapterNavRow({
    required this.label,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  final String label;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    // Reference: ghost labels are text-zinc-300 (12px).
    final ghostLabel = context.theme.typography.body.xs.copyWith(
      color: colors.mutedForeground,
    );
    return Row(
      children: [
        ReaderButton(
          variant: .ghost,
          height: ReaderControlSize.compact,
          mainAxisSize: .min,
          onPress: hasPrevious ? onPrevious : null,
          icon: const Icon(FLucideIcons.chevronLeft, size: 14),
          child: ReaderLabel(
            'reader.manga.previous'.i18n,
            style: ghostLabel,
            maxWidth: _kNavLabelMaxWidth,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ReaderButton(
            variant: .secondary,
            height: ReaderControlSize.compact,
            onPress: onSelect,
            // The chapter name leads and the chevron is pushed to the trailing
            // edge of the button, as the reference draws it; a `Spacer` between
            // them is what separates the two halves, since the button's own
            // alignment only centres its content as a block.
            child: Row(
              children: [
                Flexible(
                  child: ReaderLabel(
                    label,
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(FLucideIcons.chevronDown, size: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ReaderButton(
          variant: .ghost,
          height: ReaderControlSize.compact,
          mainAxisSize: .min,
          onPress: hasNext ? onNext : null,
          suffix: const Icon(FLucideIcons.chevronRight, size: 14),
          child: ReaderLabel(
            'reader.manga.next'.i18n,
            style: ghostLabel,
            maxWidth: _kNavLabelMaxWidth,
          ),
        ),
      ],
    );
  }
}

/// Current page, [FSlider], total page.
///
/// The slider is a 0..1 fraction; [totalPage] remaps it to a one-based page
/// number so the widget is identical for a 3-page and a 300-page chapter.
///
/// The control is **lifted**, not managed: FORUI's `managedContinuous` only
/// reads its `initial` value once, so a managed slider keeps the page it was
/// built with and never follows the reader. Lifting it lets the page drive the
/// thumb while the thumb drives the page.
///
/// The thumb has exactly two masters, in order: the FINGER while a drag is
/// live, and the reader's page at rest. The raw fraction under the finger is
/// mirrored into local state so the thumb moves with it continuously (no step
/// quantisation between changes — that stutter is what made the thumb feel
/// stuck), while the quantised page is what the reader is told. On release the
/// raw fraction is dropped and the thumb adopts the reader's page —
/// [MangaReader.jumpTo] writes the chosen target into the provider
/// synchronously, so that is the page the drag picked, never the old one.
///
/// The reader's own jump machinery (`isAdjusting` / `jumpSettling`, which
/// suppresses intermediate pages while a jump's 100ms scroll animates) is the
/// provider's business and never reaches this widget; the two logics were
/// coupled before and a jump whose completion never landed locked the thumb
/// on its last target for the rest of the session.
class _PageScrubber extends HookWidget {
  const _PageScrubber({
    required this.page,
    required this.totalPage,
    required this.episodeKey,
    required this.onScrub,
  });

  final int page;
  final int totalPage;

  /// Identity of the open chapter: a switch clears whatever drag state the
  /// previous chapter left behind.
  final String episodeKey;

  /// Scrubs to the zero-based page index.
  final ValueChanged<int> onScrub;

  @override
  Widget build(BuildContext context) {
    // The raw 0..1 fraction under the finger while a drag is live; null at
    // rest, where the thumb follows the reader's page.
    final scrubFraction = useState<double?>(null);

    // One-based page the drag is on — the badge's number while the raw
    // fraction moves the thumb.
    final scrubPage = useState(0);

    // A chapter switch (including one a background refetch re-selects) must
    // not leave the thumb pinned to a dead chapter's fraction.
    useEffect(() {
      scrubFraction.value = null;
      scrubPage.value = 0;
      return null;
    }, [episodeKey]);

    final colors = context.theme.colors;
    final mono = context.theme.typography.body.xs;
    final last = totalPage <= 0 ? 1 : totalPage;
    final span = last - 1;
    final pageFraction = span <= 0 ? 1.0 : (page - 1) / span;
    final scrubbing = scrubFraction.value != null;
    final fraction = scrubFraction.value ?? pageFraction.clamp(0, 1);
    final muted = mono.copyWith(color: colors.mutedForeground);

    // One row, one live label: the leading number IS the current page (the
    // finger's page while a drag is live, the reader's page at rest) and the
    // trailing number is the total. A floating badge above the thumb and
    // FORUI's own drag tooltip stacked on top of that label read as three
    // numbers for one fact.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sized by its own content, not a fixed box: a three-digit total wraps
        // inside a 24px slot and the row grows a second line. `softWrap: false`
        // keeps a long run on one line, and the slider is the flexible part.
        Text(
          '${scrubbing ? scrubPage.value : page}',
          key: const ValueKey('scrub-page-label'),
          maxLines: 1,
          softWrap: false,
          style: muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FSlider(
            control: FSliderControl.liftedContinuous(
              value: FSliderValue(max: fraction),
              onChange: (value) {
                // Quantise only what the reader is told; the thumb keeps
                // the raw fraction so it tracks the finger exactly.
                final index = (value.max * span).round().clamp(0, last - 1);
                scrubFraction.value = value.max.clamp(0.0, 1.0);
                scrubPage.value = index + 1;
                onScrub(index);
              },
            ),
            // Reference metrics: 6px track (FORUI's `crossAxisExtent`
            // already matches), 16px white thumb with a 2px dark ring
            // (FORUI uses a 25px thumb on touch platforms), so the thumb
            // separates from the page instead of taking the app's accent.
            style: FSliderStyleDelta.delta(
              thumbSize: 16,
              thumbStyle: FSliderThumbStyleDelta.delta(
                borderColor: FVariantsValueDelta.delta([
                  FVariantValueDeltaOperation.variants(colors.background),
                ]),
                borderWidth: 2,
              ),
            ),
            // Fires when the drag or the tap ends: the finger's fraction
            // is retired and the thumb falls back to the reader's page.
            onEnd: (_) => scrubFraction.value = null,
            // The drag label rides the thumb in the theme's primary. An empty
            // bubble (the shrink hack) rendered as a textless pill on the
            // thumb — the number is the drag's whole point. The builder gets
            // a tooltip controller, not a context, so the colour comes from
            // the build-scope theme.
            tooltipBuilder: (_, value) => Text(
              '${(value * span).round() + 1}',
              style: mono.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Both callbacks get the raw 0..1 fraction, so both remap it to
            // a one-based page number: the formatter is what the slider
            // *announces* (without it a screen reader says "0%"), and the
            // value formatter is what it announces for a step.
            semanticFormatterCallback: (value) =>
                '${(value.max * span).round() + 1}',
            semanticValueFormatterCallback: (value) =>
                '${(value * span).round() + 1}',
          ),
        ),
        const SizedBox(width: 8),
        Text('$totalPage', maxLines: 1, softWrap: false, style: muted),
      ],
    );
  }
}
