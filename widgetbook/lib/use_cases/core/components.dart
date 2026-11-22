import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/icon_input.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/morph_icon.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/core/widget/miru_segmented_control.dart';
import 'package:miru_alpha/ui/core/widget/small_badge.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

/// Play/pause silhouettes on the 24 grid (MorphIcon's coordinate space).
const _playPath = 'M8 5v14l11-7z';
const _pausePath = 'M6 19h4V5H6v14zm8-14v14h4V5h-4z';

/// The hand-curated design-system components (pre-dating the test-mirror
/// sweep). The mirrored-from-tests folders live beside this file.
WidgetbookFolder buildDesignSystemFolder() {
  return WidgetbookFolder(
    name: 'Design system',
    children: [
      _badgeComponent(),
      _cardComponent(),
      _segmentedComponent(),
      _morphComponent(),
    ],
  );
}

/// The app's real theme factory, exported for area files that need a theme
/// entry of their own (the catalog ThemeAddon already applies it globally).
///
/// Uses the `.touch` (mobile) variant so phone-framed stories render with
/// mobile tokens (touch targets, mobile typography) instead of desktop ones.
/// LIGHT is first so the catalog defaults to it — `main.dart` also pins it as
/// the `initialTheme`, so no story accidentally renders dark. Dark stays
/// available as a toggle for contrast checks.
List<WidgetbookTheme<FThemeData>> miruThemeEntries() => [
  WidgetbookTheme(
    name: 'Light (zinc · mobile)',
    data: ThemeUtils.resolveTheme('zinc', 'none').touch,
  ),
  WidgetbookTheme(
    name: 'Dark (zinc · mobile)',
    data: ThemeUtils.resolveDarkTheme('zinc', 'none').touch,
  ),
];

WidgetbookComponent _badgeComponent() {
  return WidgetbookComponent(
    name: 'SmallBadge',
    useCases: [
      WidgetbookUseCase(
        name: 'Variants',
        builder: (context) {
          final label = context.knobs.string(
            label: 'Label',
            initialValue: 'Binge',
          );
          return Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SmallBadge(label: label, variant: FBadgeVariant.secondary),
                SmallBadge(label: label, variant: FBadgeVariant.primary),
                SmallBadge(label: label, variant: FBadgeVariant.outline),
                SmallBadge(label: label, variant: FBadgeVariant.destructive),
              ],
            ),
          );
        },
      ),
    ],
  );
}

WidgetbookComponent _cardComponent() {
  return WidgetbookComponent(
    name: 'MiruCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Rich (title / subtitle / actions)',
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: MiruCard(
              title: const Text('Continue watching'),
              subtitle: const Text('Ep 12 · 18 min left'),
              body: const Text("Frieren: Beyond Journey's End"),
              actions: [FButton(onPress: () {}, child: const Text('Resume'))],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Plain container (no padding)',
        builder: (context) => Center(
          child: MiruCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Raw child — mirrors the old FCard.raw'),
            ),
          ),
        ),
      ),
    ],
  );
}

WidgetbookComponent _segmentedComponent() {
  return WidgetbookComponent(
    name: 'MiruSegmentedControl',
    useCases: [
      WidgetbookUseCase(
        name: 'Dashboard tabs (42px track)',
        builder: (context) => const Center(child: _SegmentedDemo()),
      ),
      WidgetbookUseCase(
        name: 'Dense header tab bar',
        builder: (context) => const Center(child: _SegmentedDemo(dense: true)),
      ),
      WidgetbookUseCase(
        name: 'Radio markers',
        builder: (context) => const Center(
          child: _SegmentedDemo(markers: true, dimUnselectedText: true),
        ),
      ),
    ],
  );
}

WidgetbookComponent _morphComponent() {
  return WidgetbookComponent(
    name: 'MorphIcon',
    useCases: [
      WidgetbookUseCase(
        name: 'Flight (tap to toggle)',
        builder: (context) => const Center(child: _MorphFlightDemo()),
      ),
      WidgetbookUseCase(
        name: 'Controlled scrub',
        builder: (context) {
          final progress = context.knobs.double.slider(
            label: 'Progress',
            initialValue: 0.5,
            min: 0,
            max: 1,
          );
          return Center(
            child: MorphIcon(
              from: const SvgD(_playPath),
              to: const SvgD(_pausePath),
              progress: progress,
              size: 48,
              color: context.theme.colors.primary,
            ),
          );
        },
      ),
    ],
  );
}

/// Interactive segmented-control state for the catalog demos.
class _SegmentedDemo extends StatefulWidget {
  const _SegmentedDemo({
    this.dense = false,
    this.markers = false,
    this.dimUnselectedText = false,
  });

  final bool dense;
  final bool markers;
  final bool dimUnselectedText;

  @override
  State<_SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<_SegmentedDemo> {
  String _selected = 'anime';

  @override
  Widget build(BuildContext context) {
    return MiruSegmentedControl<String>(
      segments: const [
        MiruSegment(value: 'all', label: 'All'),
        MiruSegment(value: 'manga', label: 'Manga'),
        MiruSegment(value: 'anime', label: 'Anime'),
        MiruSegment(value: 'novel', label: 'Novel'),
      ],
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
      dense: widget.dense,
      selectionMarkers: widget.markers,
      dimUnselectedText: widget.dimUnselectedText,
    );
  }
}

/// Tap-to-toggle play/pause morph for the catalog.
class _MorphFlightDemo extends StatefulWidget {
  const _MorphFlightDemo();

  @override
  State<_MorphFlightDemo> createState() => _MorphFlightDemoState();
}

class _MorphFlightDemoState extends State<_MorphFlightDemo> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _playing = !_playing),
      child: MorphIcon(
        icon: _playing ? const SvgD(_pausePath) : const SvgD(_playPath),
        size: 48,
        color: context.theme.colors.primary,
      ),
    );
  }
}
