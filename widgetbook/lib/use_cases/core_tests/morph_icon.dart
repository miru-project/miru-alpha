import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/morph.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/core/morph_icon_test.dart states for the catalog.
///
/// skipped: driver flight (`createMorph`/`morphTo`) — controller-level
/// behavior; the flight use-case below shows the same spring visually.
/// skipped: spring crossing-order assertions — behavior of that same flight.
/// skipped: dispose mid-flight — teardown behavior, no visual state.
/// skipped: glyph-extraction geometry assertions (`MorphGlyphs.icon`) —
/// behavior; the play/pause disc use-case shows the runtime-extracted
/// glyphs morphing (the plain-icon fallback is what renders while the
/// extraction is in flight).
///
/// The test paints the morph in the default black on a light scaffold; here
/// the standalone glyphs take the theme's primary so they stay visible on
/// the dark catalog theme. Sizes mirror the test (24 / disc 48 with a 22px
/// glyph).
const _square = 'M2 2H22V22H2Z';
const _twoSub = 'M2 2H10V10H2ZM14 14H22V22H14Z';
const _squareFar = 'M12 12H32V32H12Z';

const _fillA = ShapeIcon([IconEl(_square, fill: 'currentColor')]);
const _fillB = ShapeIcon([IconEl(_twoSub, fill: 'currentColor')]);

WidgetbookComponent buildMorphIconComponent() {
  return WidgetbookComponent(
    name: 'MorphIcon',
    useCases: [
      WidgetbookUseCase(
        name: 'Flight · tap to toggle (square → two subpaths)',
        builder: (context) => catalogFrame(const _MorphTapDemo()),
      ),
      WidgetbookUseCase(
        name: 'Controlled scrub (knobs)',
        builder: (context) {
          final target = context.knobs.object.dropdown<MorphIconInput>(
            label: 'Target',
            initialOption: const SvgD(_twoSub),
            options: const [SvgD(_twoSub), SvgD(_squareFar)],
            labelBuilder: (value) => switch (value) {
              SvgD(d: _twoSub) => 'twoSub (two subpaths)',
              SvgD(d: _squareFar) => 'squareFar (off-grid)',
              _ => 'custom',
            },
          );
          final progress = context.knobs.double.slider(
            label: 'Progress',
            initialValue: 0.5,
            min: 0,
            max: 1,
          );
          return Center(
            child: MorphIcon(
              from: const SvgD(_square),
              to: target,
              progress: progress,
              size: 24,
              color: context.theme.colors.primary,
            ),
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Fill icon · pop fallback (no path morph)',
        builder: (context) => catalogFrame(const _FillPopDemo()),
      ),
      WidgetbookUseCase(
        name: 'Reduced motion · change jumps without flight',
        builder: (context) => catalogFrame(
          const _MorphTapDemo(reducedMotion: ReducedMotionMode.always),
        ),
      ),
      WidgetbookUseCase(
        name: 'Play/pause disc (extracted glyphs)',
        builder: (context) => catalogFrame(
          Padding(
            padding: const EdgeInsets.all(24),
            child: ColoredBox(
              color: const Color(0xFF27272A),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: const _PlayPauseDiscDemo(),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

/// Tap-to-toggle flight between the test's two stroke paths.
class _MorphTapDemo extends StatefulWidget {
  const _MorphTapDemo({this.reducedMotion = ReducedMotionMode.never});

  final ReducedMotionMode reducedMotion;

  @override
  State<_MorphTapDemo> createState() => _MorphTapDemoState();
}

class _MorphTapDemoState extends State<_MorphTapDemo> {
  bool _second = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _second = !_second),
      child: MorphIcon(
        icon: _second ? const SvgD(_twoSub) : const SvgD(_square),
        size: 24,
        color: context.theme.colors.primary,
        reducedMotion: widget.reducedMotion,
      ),
    );
  }
}

/// Tap-to-toggle between the test's two filled shapes — the pop fallback:
/// the icon swaps without a path flight.
class _FillPopDemo extends StatefulWidget {
  const _FillPopDemo();

  @override
  State<_FillPopDemo> createState() => _FillPopDemoState();
}

class _FillPopDemoState extends State<_FillPopDemo> {
  bool _second = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _second = !_second),
      child: MorphIcon(
        icon: _second ? _fillB : _fillA,
        size: 24,
        color: context.theme.colors.primary,
      ),
    );
  }
}

/// The player's play/pause anchor at the test's compact size (48 box, 22
/// glyph): tap the disc, the runtime-extracted play/pause glyphs morph on
/// the snappy spring.
class _PlayPauseDiscDemo extends StatefulWidget {
  const _PlayPauseDiscDemo();

  @override
  State<_PlayPauseDiscDemo> createState() => _PlayPauseDiscDemoState();
}

class _PlayPauseDiscDemoState extends State<_PlayPauseDiscDemo> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return PlayerPlayPauseDisc(
      isPlaying: _playing,
      onPress: () => setState(() => _playing = !_playing),
      box: 48,
      iconSize: 22,
    );
  }
}
