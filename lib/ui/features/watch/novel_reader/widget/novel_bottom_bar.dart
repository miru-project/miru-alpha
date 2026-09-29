import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_button.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_segmented.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Caps the Prev/Next labels so an unbroken word (a raw i18n key, or a
/// single-word language) cannot push the chapter selector out of the row.
/// Generous enough for "Zurück" / "Siguiente" / "上一章".
const double _kNavLabelMaxWidth = 96;

/// Floating reader control capsule: chapter paging, the reading-position
/// scrubber, the turn direction and the brightness shortcut.
///
/// Mirrors the reference's `FloatingHUD` row for row, with the page scrubber
/// driven by whichever unit the active reading mode navigates — lines while
/// scrolling, pages otherwise.
class NovelBottomBar extends ConsumerWidget {
  const NovelBottomBar({
    super.key,
    required this.novelProvider,
    required this.epProvider,
    required this.onOpenChapters,
  });

  final NovelReaderProvider novelProvider;
  final EpisodeNotifierProvider epProvider;
  final VoidCallback onOpenChapters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(novelProvider);
    final reader = ref.read(novelProvider.notifier);
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
            ordinal: epState.selectedEpisodeIndex + 1,
            label: currentEpisode?.name ?? 'reader.novel.chapters'.i18n,
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
          // Row 2 — the reading-position scrubber.
          _PositionScrubber(
            // The scrubber counts in whatever the active mode navigates.
            unit: (state.isPaged
                    ? 'reader.novel.page'
                    : 'reader.novel.line')
                .i18n,
            position: state.historyProgress,
            total: state.totalProgress,
            onScrub: state.isPaged
                ? reader.jumpToPage
                : reader.jumpToLine,
          ),
          const SizedBox(height: 14),
          // The mode strip and the shortcuts are separated from the rows above
          // by a hairline.
          Divider(height: 1, thickness: 1, color: colors.border),
          const SizedBox(height: 10),
          // Row 3 — the reading-mode strip and the brightness shortcut on the
          // trailing edge. This is the *same* control as the settings sheet's,
          // showing the same three modes, rather than a second selector for
          // something else: one reader, one mode, two places to reach it.
          Row(
            // `spaceBetween`, not a Spacer: a Spacer is a *flex* child, so it
            // would split the row with the strip and squeeze the mode labels
            // down to "Pa …". Here the strip takes its intrinsic width and the
            // leftover space becomes the gap.
            mainAxisAlignment: .spaceBetween,
            children: [
              Flexible(
                child: ReaderSegmented<NovelReadMode>(
                  value: state.readMode,
                  options: kNovelReadModeOrder,
                  onChanged: reader.changeReadMode,
                  labelBuilder: (mode) =>
                      'reader.novel.read_mode.short.${mode.name}'.i18n,
                ),
              ),
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

/// Prev / chapter selector / next.
class _ChapterNavRow extends StatelessWidget {
  const _ChapterNavRow({
    required this.ordinal,
    required this.label,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  /// One-based chapter number, shown as a mono prefix in the selector.
  final int ordinal;

  final String label;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final ghostLabel = context.theme.typography.body.xs.copyWith(
      color: colors.mutedForeground,
    );
    final mono = context.theme.typography.body.xs.copyWith(
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
            'reader.novel.previous'.i18n,
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
                Text(
                  '${'reader.novel.short_chapter'.i18n} $ordinal',
                  style: mono,
                ),
                const SizedBox(width: 8),
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
            'reader.novel.next'.i18n,
            style: ghostLabel,
            maxWidth: _kNavLabelMaxWidth,
          ),
        ),
      ],
    );
  }
}

/// Current position, [FSlider] with a floating badge, total position.
///
/// The slider is a 0..1 fraction remapped to a one-based number, so the widget
/// is identical for a 40-line chapter and a 4,000-line one.
///
/// The control is **lifted**, not managed: FORUI's `managedContinuous` only
/// reads its `initial` value once, so a managed slider keeps the position it
/// was built with and never follows the reader. Lifting it lets the position
/// drive the thumb while the thumb drives the position.
class _PositionScrubber extends HookWidget {
  const _PositionScrubber({
    required this.unit,
    required this.position,
    required this.total,
    required this.onScrub,
  });

  /// Name of the unit being scrubbed, e.g. "Line".
  final String unit;

  final int position;
  final int total;
  final ValueChanged<int> onScrub;

  @override
  Widget build(BuildContext context) {
    // True between the first change of a drag and its end, which is the only
    // time the badge is shown: at rest the two numbers at either end of the
    // track already say where the reader is.
    final scrubbing = useState(false);

    // Position the thumb is being dragged to, kept here so the badge and the
    // thumb follow the finger instead of waiting for the change to come back
    // through the provider.
    final scrubPosition = useState(0);

    final colors = context.theme.colors;
    final mono = context.theme.typography.body.xs;
    final last = total <= 0 ? 1 : total;
    final span = last - 1;
    final moving = scrubbing.value && scrubPosition.value > 0;
    final shown = moving ? scrubPosition.value : position;
    final fraction = span <= 0 ? 1.0 : (shown - 1) / span;
    final muted = mono.copyWith(color: colors.mutedForeground);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sized by its own content, not a fixed box: a three-digit total wraps
        // inside a 24px slot and the row grows a second line. `softWrap: false`
        // keeps a long run on one line, and the slider is the flexible part.
        Text('$shown', maxLines: 1, softWrap: false, style: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: .min,
            children: [
              // The badge gets its own row rather than being overlaid, so no
              // overlap offsets have to be tuned. It is only mounted while the
              // thumb moves, so the resting panel stays as quiet as the
              // reference.
              SizedBox(
                height: 18,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 120),
                  child: moving
                      ? Align(
                          key: const ValueKey('position-badge'),
                          // Alignment.x maps -1..1 onto 0..1, so this keeps the
                          // badge over the thumb as it travels.
                          alignment: Alignment(fraction.clamp(0, 1) * 2 - 1, 0),
                          child: FittedBox(
                            child: _PositionBadge(unit: unit, position: shown),
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('position-badge-empty'),
                          height: 18,
                        ),
                ),
              ),
              FSlider(
                control: FSliderControl.liftedContinuous(
                  value: FSliderValue(max: fraction.clamp(0, 1)),
                  stepPercentage: span <= 0 ? 1 : 1 / span,
                  onChange: (value) {
                    final next = (value.max * span).round() + 1;
                    scrubbing.value = true;
                    scrubPosition.value = next;
                    onScrub(next);
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
                // Fires when the drag or the tap ends, i.e. when the badge has
                // served its purpose.
                onEnd: (_) => scrubbing.value = false,
                tooltipBuilder: (_, value) =>
                    Text('${(value * span).round() + 1}'),
                // Both callbacks get the raw 0..1 fraction, so both remap it to
                // a one-based number: the formatter is what the slider
                // *announces* (without it a screen reader says "0%"), and the
                // value formatter is what it announces for a step.
                semanticFormatterCallback: (value) =>
                    '${(value.max * span).round() + 1}',
                semanticValueFormatterCallback: (value) =>
                    '${(value * span).round() + 1}',
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('$total', maxLines: 1, softWrap: false, style: muted),
      ],
    );
  }
}

/// Floating "Line N" badge pinned above the scrubber thumb.
class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.unit, required this.position});

  final String unit;
  final int position;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: .circular(4),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          '$unit $position',
          maxLines: 1,
          style: context.theme.typography.body.xs.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
