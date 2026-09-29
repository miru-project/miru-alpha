import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_button.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_segmented.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_sheet.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_typography.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Opens the novel reader settings as a FORUI modal sheet and resolves once it
/// is dismissed.
///
/// Structured like the manga reader's settings sheet — an opaque rounded panel
/// dismissed from its grab handle, a header carrying the reset, then the display
/// sections — with the novel's own controls: reading mode, typography, the paper
/// palette and the reading-experience toggles. Every control writes through to
/// the provider, so the page behind the sheet reflows live rather than waiting
/// for a confirm button.
Future<void> showNovelSettingsSheet(
  BuildContext context, {
  required NovelReaderProvider novelProvider,
}) {
  return showFSheet<void>(
    context: context,
    side: .btt,
    mainAxisMaxRatio: 0.88,
    builder: (context) => _NovelSettingsSheet(novelProvider: novelProvider),
  );
}

class _NovelSettingsSheet extends ConsumerWidget {
  const _NovelSettingsSheet({required this.novelProvider});

  final NovelReaderProvider novelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(novelProvider);
    final reader = ref.read(novelProvider.notifier);
    return ReaderSheetPanel(
      maxHeightFactor: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The sheet closes from its grabber, exactly as the manga reader's
          // does; the only action in the header is the reset.
          ReaderSheetHandle(onPress: () => Navigator.of(context).maybePop()),
          _SheetHeader(
            title: 'reader.novel.settings'.i18n,
            onReset: reader.resetDisplaySettings,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Reading mode.
                  _SectionLabel('reader.novel.read_mode.name'.i18n),
                  const SizedBox(height: 8),
                  ReaderSegmented<NovelReadMode>(
                    value: state.readMode,
                    options: kNovelReadModeOrder,
                    onChanged: reader.changeReadMode,
                    expand: true,
                    labelBuilder: (mode) =>
                        'reader.novel.read_mode.short.${mode.name}'.i18n,
                  ),
                  const SizedBox(height: 20),
                  // Typography: face, then the three sliders.
                  _SectionLabel('reader.novel.typography'.i18n),
                  const SizedBox(height: 8),
                  _FontFamilyGrid(
                    value: state.fontFamily,
                    fontSize: state.fontSize,
                    onChanged: reader.setFontFamily,
                  ),
                  const SizedBox(height: 16),
                  _SliderSection(
                    label: 'reader.novel.font_size.name'.i18n,
                    valueLabel: '${state.fontSize.round()}px',
                    icon: FLucideIcons.type,
                    min: kNovelFontSizeMin,
                    max: kNovelFontSizeMax,
                    step: 1,
                    value: state.fontSize,
                    onChanged: reader.setFontSize,
                  ),
                  const SizedBox(height: 16),
                  _SliderSection(
                    label: 'reader.novel.line_height.name'.i18n,
                    valueLabel: '${state.lineHeight.toStringAsFixed(1)}x',
                    icon: FLucideIcons.arrowUpDown,
                    min: kNovelLineHeightMin,
                    max: kNovelLineHeightMax,
                    step: kNovelLineHeightStep,
                    value: state.lineHeight,
                    onChanged: reader.setLineHeight,
                  ),
                  const SizedBox(height: 16),
                  _SliderSection(
                    label: 'reader.novel.margin.name'.i18n,
                    valueLabel: '${state.margin.round()}px',
                    icon: FLucideIcons.moveHorizontal,
                    min: kNovelMarginMin,
                    max: kNovelMarginMax,
                    step: kNovelMarginStep,
                    value: state.margin,
                    onChanged: reader.setMargin,
                  ),
                  const SizedBox(height: 20),
                  // Paper palette.
                  _SectionLabel('reader.novel.theme.name'.i18n),
                  const SizedBox(height: 8),
                  _PaperPalette(
                    value: state.theme,
                    onChanged: reader.setTheme,
                  ),
                  const SizedBox(height: 20),
                  // Reading experience.
                  _SectionLabel('reader.novel.experience'.i18n),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.theme.colors.muted.withValues(alpha: 0.4),
                      borderRadius: .circular(12),
                      border: Border.all(color: context.theme.colors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          _ToggleRow(
                            title:
                                'reader.novel.keep_screen_on.name'.i18n,
                            description:
                                'reader.novel.keep_screen_on.hint'.i18n,
                            value: state.keepScreenOn,
                            onChange: reader.setKeepScreenOn,
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: context.theme.colors.border,
                          ),
                          _ToggleRow(
                            title:
                                'reader.novel.tap_to_turn_page.name'.i18n,
                            description:
                                'reader.novel.tap_to_turn_page.hint'.i18n,
                            value: state.tapToTurnPage,
                            onChange: reader.setTapToTurnPage,
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: context.theme.colors.border,
                          ),
                          _ToggleRow(
                            title:
                                'reader.novel.volume_keys.name'.i18n,
                            description:
                                'reader.novel.volume_keys.hint'.i18n,
                            value: state.volumeKeysTurnPage,
                            onChange: reader.setVolumeKeysTurnPage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three face buttons, each previewed in its own typeface.
///
/// The app bundles no font files, so a face is a stack the platform resolves:
/// the button shows the stack's first name and previews with the same stack, so
/// what the reader sees is what the page will use.
class _FontFamilyGrid extends StatelessWidget {
  const _FontFamilyGrid({
    required this.value,
    required this.fontSize,
    required this.onChanged,
  });

  final NovelFontFamily value;
  final double fontSize;
  final ValueChanged<NovelFontFamily> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      children: [
        for (final family in NovelFontFamily.values) ...[
          if (family != NovelFontFamily.values.first)
            const SizedBox(width: 8),
          Expanded(
            child: _FontFamilyTile(
              family: family,
              selected: family == value,
              fontSize: fontSize,
              onPress: () => onChanged(family),
              colors: colors,
            ),
          ),
        ],
      ],
    );
  }
}

class _FontFamilyTile extends StatelessWidget {
  const _FontFamilyTile({
    required this.family,
    required this.selected,
    required this.fontSize,
    required this.onPress,
    required this.colors,
  });

  final NovelFontFamily family;
  final bool selected;
  final double fontSize;
  final VoidCallback onPress;
  final FColors colors;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      selected: selected,
      selectable: true,
      onPress: onPress,
      semanticsLabel: 'reader.novel.font_family.name'.i18n,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.background : colors.muted.withValues(
            alpha: 0.4,
          ),
          borderRadius: .circular(8),
          border: Border.all(
            color: selected ? colors.border : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontFamilyFallback: novelFontFamilyFallback[family],
                  fontSize: fontSize * 0.95,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? colors.foreground : colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              ReaderLabel(
                novelFontFamilyName[family]!,
                style: context.theme.typography.body.xs.copyWith(
                  color: selected ? colors.foreground : colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Four paper swatches, the selected one ringed and ticked.
class _PaperPalette extends StatelessWidget {
  const _PaperPalette({required this.value, required this.onChanged});

  final NovelTheme value;
  final ValueChanged<NovelTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      children: [
        for (final theme in NovelTheme.values) ...[
          if (theme != NovelTheme.values.first) const SizedBox(width: 10),
          Expanded(
            child: _PaperTile(
              theme: theme,
              selected: theme == value,
              onPress: () => onChanged(theme),
              colors: colors,
            ),
          ),
        ],
      ],
    );
  }
}

class _PaperTile extends StatelessWidget {
  const _PaperTile({
    required this.theme,
    required this.selected,
    required this.onPress,
    required this.colors,
  });

  final NovelTheme theme;
  final bool selected;
  final VoidCallback onPress;
  final FColors colors;

  @override
  Widget build(BuildContext context) {
    final paper = NovelPaper.of(theme);
    return FTappable(
      selected: selected,
      selectable: true,
      onPress: onPress,
      semanticsLabel: 'reader.novel.theme.${theme.name}'.i18n,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.muted.withValues(alpha: 0.4),
          borderRadius: .circular(12),
          border: Border.all(
            // The selected swatch is ringed in ink, not in the app's accent, so
            // the row reads the same whichever paper the reader picks.
            color: selected ? colors.foreground : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: paper.background,
                  shape: .circle,
                  border: Border.all(color: paper.border),
                ),
                child: selected
                    ? Icon(
                        FLucideIcons.check,
                        size: 14,
                        color: paper.foreground,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              ReaderLabel(
                'reader.novel.theme.${theme.name}'.i18n,
                style: context.theme.typography.body.xs.copyWith(
                  color: selected ? colors.foreground : colors.mutedForeground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.theme.typography.body.xs.copyWith(
        fontWeight: FontWeight.w600,
        color: context.theme.colors.mutedForeground,
      ),
    );
  }
}

/// A labelled slider with its value shown in a badge beside the label.
class _SliderSection extends StatelessWidget {
  const _SliderSection({
    required this.label,
    required this.valueLabel,
    required this.icon,
    required this.min,
    required this.max,
    required this.step,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final IconData icon;
  final double min;
  final double max;
  final double step;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final span = max - min;
    final steps = span <= 0 ? 0 : (span / step).round();
    final fraction = span <= 0 ? 0.0 : (value - min) / span;
    double resolve(double raw) {
      final stepped = min + (raw * steps).round() * step;
      return stepped.clamp(min, max);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: context.theme.colors.mutedForeground),
            const SizedBox(width: 6),
            Expanded(child: _SectionLabel(label)),
            // Flexible, because the badge holds a value that can be a long
            // localised string and must never push the label out of the row.
            Flexible(
              child: FBadge(
                variant: .secondary,
                child: Text(valueLabel, maxLines: 1, overflow: .ellipsis),
              ),
            ),
          ],
        ),
        FSlider(
          // Lifted, not managed: a managed control only reads `initial` once, so
          // a slider rebuilt with a new value would keep the old thumb.
          control: FSliderControl.liftedContinuous(
            value: FSliderValue(max: fraction.clamp(0, 1)),
            stepPercentage: steps <= 0 ? 1 : 1 / steps,
            onChange: (newValue) => onChanged(resolve(newValue.max)),
          ),
          tooltipBuilder: (_, newValue) =>
              Text(steps <= 0 ? '$value' : resolve(newValue).toStringAsFixed(
                step < 1 ? 1 : 0,
              )),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChange,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FSwitch(value: value, onChange: onChange),
        ],
      ),
    );
  }
}

/// Sheet header, with the reset as its single action.
///
/// The same shape as the manga reader's sheet header — a settings glyph, the
/// title, and a ghost icon button in the corner — so the two readers' settings
/// look and behave alike. The sheet is dismissed from its grab handle; there is
/// no confirm button because there is nothing to confirm, every control above
/// already applies.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onReset});

  final String title;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Icon(
            FLucideIcons.settings,
            size: 18,
            color: context.theme.colors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.colors.foreground,
              ),
            ),
          ),
          FTooltip(
            tipBuilder: (_, _) => Text('reader.novel.apply_defaults'.i18n),
            child: FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: onReset,
              child: const Icon(FLucideIcons.rotateCcw, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
