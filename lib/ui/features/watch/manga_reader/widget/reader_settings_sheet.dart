import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_sheet.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_segmented.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Opens the reader display settings as a FORUI modal sheet and resolves once
/// it is dismissed.
Future<void> showReaderSettingsSheet(
  BuildContext context, {
  required MangaReaderProvider mangaProvider,
}) {
  return showFSheet<void>(
    context: context,
    side: .btt,
    mainAxisMaxRatio: 0.85,
    builder: (context) => _SettingsSheet(mangaProvider: mangaProvider),
  );
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet({required this.mangaProvider});

  final MangaReaderProvider mangaProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mangaProvider);
    final reader = ref.read(mangaProvider.notifier);
    return ReaderSheetPanel(
      maxHeightFactor: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The reference closes the sheet from its grabber.
          ReaderSheetHandle(onPress: () => Navigator.of(context).maybePop()),
          _SheetHeader(
            title: 'reader.manga.settings'.i18n,
            onReset: reader.resetDisplaySettings,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionLabel('reader.manga.read_mode.name'.i18n),
                  const SizedBox(height: 8),
                  ReaderSegmented<MangaReadMode>(
                    value: state.readMode,
                    options: MangaReadMode.values,
                    onChanged: reader.changeReadMode,
                    expand: true,
                    labelBuilder: (mode) =>
                        'reader.manga.read_mode.${mode.name}'.i18n,
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('reader.manga.canvas_background'.i18n),
                  const SizedBox(height: 8),
                  ReaderSegmented<MangaCanvasBackground>(
                    value: state.canvasBackground,
                    options: MangaCanvasBackground.values,
                    onChanged: reader.setCanvasBackground,
                    expand: true,
                    labelBuilder: (background) =>
                        'reader.manga.canvas_options.${background.name}'.i18n,
                  ),
                  const SizedBox(height: 20),
                  // Brightness is two modes, not one slider: auto leaves the
                  // screen to the system, manual hands the reader the value
                  // below. The slider is inert in auto, because its value is
                  // not what the screen is showing then.
                  _SectionLabel('reader.manga.brightness'.i18n),
                  const SizedBox(height: 8),
                  ReaderSegmented<MangaBrightnessMode>(
                    value: state.brightnessMode,
                    options: MangaBrightnessMode.values,
                    onChanged: reader.setBrightnessMode,
                    expand: true,
                    labelBuilder: (mode) =>
                        'reader.manga.brightness_options.${mode.name}'.i18n,
                  ),
                  const SizedBox(height: 12),
                  _SliderSection(
                    label: 'reader.manga.brightness'.i18n,
                    valueLabel: '${state.brightness}%',
                    icon: FLucideIcons.sunMedium,
                    min: kMangaBrightnessMin,
                    max: kMangaBrightnessMax,
                    value: state.brightness,
                    // The slider stays live in auto. A disabled control reads as
                    // "the value is gone", so it stays draggable and the
                    // provider decides what that means (moving it takes the
                    // screen over from auto).
                    onChanged: reader.setBrightness,
                  ),
                  const SizedBox(height: 16),
                  _SliderSection(
                    label: 'reader.manga.page_gap'.i18n,
                    valueLabel: '${state.pageGap}px',
                    icon: FLucideIcons.moveVertical,
                    min: kMangaPageGapMin,
                    max: kMangaPageGapMax,
                    value: state.pageGap,
                    onChanged: reader.setPageGap,
                  ),
                  const SizedBox(height: 12),
                  FDivider(),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    title: 'reader.manga.invert_colors.name'.i18n,
                    description: 'reader.manga.invert_colors.hint'.i18n,
                    value: state.invertColors,
                    onChange: reader.setInvertColors,
                  ),
                  _ToggleRow(
                    title: 'reader.manga.keep_screen_on.name'.i18n,
                    description: 'reader.manga.keep_screen_on.hint'.i18n,
                    value: state.keepScreenOn,
                    onChange: reader.setKeepScreenOn,
                  ),
                  _ToggleRow(
                    title: 'reader.manga.tap_to_turn_page.name'.i18n,
                    description: 'reader.manga.tap_to_turn_page.hint'.i18n,
                    value: state.tapToTurnPage,
                    onChange: reader.setTapToTurnPage,
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

/// Reference display order for the reading-direction controls, shared by the
/// HUD strip and the settings sheet.
const List<MangaReadMode> kReaderReadModeOrder = [
  MangaReadMode.webToon,
  MangaReadMode.standard,
  MangaReadMode.rightToLeft,
];

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w600,
        color: context.theme.colors.foreground,
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection({
    required this.label,
    required this.valueLabel,
    required this.icon,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final IconData icon;
  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final span = max - min;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: context.theme.colors.mutedForeground),
            const SizedBox(width: 6),
            Expanded(child: _SectionLabel(label)),
            // Flexible, because the badge holds a value that can be a long
            // localised string ("Auto", or a raw key in a partially translated
            // locale) and must never push the label out of the row.
            Flexible(
              child: FBadge(
                variant: .secondary,
                child: Text(valueLabel, maxLines: 1, overflow: .ellipsis),
              ),
            ),
          ],
        ),
        FSlider(
          // Lifted, not managed: a managed control only reads `initial` once,
          // so a slider rebuilt with a new value would keep the old thumb.
          control: FSliderControl.liftedContinuous(
            value: FSliderValue(max: span <= 0 ? 0 : (value - min) / span),
            stepPercentage: span <= 0 ? 1 : 1 / span,
            onChange: (newValue) =>
                onChanged(min + (newValue.max * span).round()),
          ),
          tooltipBuilder: (_, newValue) =>
              Text(span <= 0 ? '$value' : '${min + (newValue * span).round()}'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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

/// Sheet header. Its single action is **apply defaults**, where the close button
/// used to be: the sheet needs no confirm button and the reference keeps one
/// action in the corner, so the reset lives there and the sheet is dismissed by
/// its grabber or the barrier.
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
            tipBuilder: (_, _) => Text('reader.manga.apply_defaults'.i18n),
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
