import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/morph.dart';

/// Shared atoms for the player control overlays (portrait viewport, landscape
/// mobile viewport, fullscreen desktop chrome). One definition per control so
/// the two mobile overlays can never drift apart.

/// Round translucent icon button used across the player overlays; 44px touch
/// box (36px for the small dock variant) per the 44pt HIG minimum. Hover and
/// press paint a faint white veil — the forui ghost hover (`colors.secondary`)
/// reads as a grey slab over video.
class PlayerCircleButton extends StatelessWidget {
  const PlayerCircleButton({
    super.key,
    required this.onPress,
    required this.semanticLabel,
    required this.icon,
    this.small = false,
  });

  final VoidCallback? onPress;
  final String semanticLabel;
  final Widget icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final box = small ? 36.0 : 44.0;
    return Semantics(
      label: semanticLabel,
      button: true,
      child: FButton.icon(
        variant: .ghost,
        onPress: onPress,
        style: .delta(
          decoration: .delta([
            .base(
              .boxDelta(
                color: Colors.black.withAlpha(90),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            .match(
              {.hovered, .pressed},
              .boxDelta(
                color: Colors.white.withAlpha(35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ]),
          iconContentStyle: .delta(
            constraints: BoxConstraints(minWidth: box, minHeight: box),
          ),
        ),
        child: IconTheme.merge(
          data: const IconThemeData(color: Colors.white),
          child: icon,
        ),
      ),
    );
  }
}

/// Seek ±10s button (icon with the "10" counter under it).
class PlayerSeekButton extends StatefulWidget {
  const PlayerSeekButton({
    super.key,
    required this.onPress,
    required this.forward,
    this.small = false,
  });

  final VoidCallback onPress;
  final bool forward;
  final bool small;

  @override
  State<PlayerSeekButton> createState() => _PlayerSeekButtonState();
}

/// The ±10s seek control: the mock's two-triangle fast-forward/rewind glyph
/// with the skip amount under it. On press the glyph does a small bounce in
/// the seek direction (the animate-ui FastForward x-oscillation) while the
/// "+10s" time pops above the button and fades — the user asked for the
/// animated icon ALONG WITH the skipped time, so both play per tap.
class _PlayerSeekButtonState extends State<PlayerSeekButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _handlePress() {
    widget.onPress();
    _burst.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final forward = widget.forward;
    return Semantics(
      label: forward ? 'watch.seek_forward'.i18n : 'watch.seek_back'.i18n,
      button: true,
      child: Stack(
        // The "+10s" burst floats ABOVE the button, outside its bounds —
        // the default hard clip would shear it.
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // The skipped-time feedback: plain fade-in / fade-out (user
          // directive — no bounce, no rise).
          Positioned(
            top: -26,
            child: AnimatedBuilder(
              animation: _burst,
              builder: (context, _) {
                if (_burst.isCompleted) return const SizedBox.shrink();
                final t = _burst.value;
                final opacity = (t < 0.3 ? t / 0.3 : (1 - t) / 0.7).clamp(
                  0.0,
                  1.0,
                );
                return Opacity(
                  opacity: opacity,
                  child: Text(
                    forward ? '+10s' : '-10s',
                    style: TextStyle(
                      color: Colors.white.withAlpha(235),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                );
              },
            ),
          ),
          FButton.icon(
            variant: .ghost,
            onPress: _handlePress,
            style: .delta(
              decoration: .delta([
                .base(
                  .boxDelta(
                    color: Colors.black.withAlpha(90),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                .match(
                  {.hovered, .pressed},
                  .boxDelta(
                    color: Colors.white.withAlpha(35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ]),
              // icon + "10" stack must fit the 44px circle: shrink the ghost
              // padding, or the box grows to 44x56 and the pill goes oval.
              iconContentStyle: .delta(
                constraints: BoxConstraints(
                  minWidth: widget.small ? 36 : 44,
                  minHeight: widget.small ? 36 : 44,
                ),
                padding: EdgeInsetsGeometryDelta.value(
                  EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                ),
              ),
            ),
            child: IconTheme.merge(
              data: const IconThemeData(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    forward ? FLucideIcons.fastForward : FLucideIcons.rewind,
                    size: widget.small ? 14 : 16,
                  ),
                  Text(
                    '10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.small ? 6 : 7,
                      fontWeight: FontWeight.w700,
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

/// The skip prev/next control (lucide skip-back/forward): on press the icon
/// x-jogs 2 grid-px toward the skip direction and settles — the animate-ui
/// SkipForward/SkipBack choreography (`x: [0,±2,0]`, 500ms easeInOut),
/// rendered as a font-[Icon] translate so the glyph stays as crisp as the
/// rest of the chrome icons. A null [onPress] disables: muted paint, no jog.
class PlayerSkipButton extends HookWidget {
  const PlayerSkipButton({
    super.key,
    required this.onPress,
    required this.forward,
    required this.semanticLabel,
    this.small = false,
    this.size = 14,
  });

  final VoidCallback? onPress;
  final bool forward;
  final String semanticLabel;
  final bool small;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = forward ? FLucideIcons.skipForward : FLucideIcons.skipBack;
    final jog = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final enabled = onPress != null;
    final box = small ? 36.0 : 44.0;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: FButton.icon(
        variant: .ghost,
        onPress: onPress == null
            ? null
            : () {
                onPress!();
                jog.forward(from: 0);
              },
        // The circle-button deltas verbatim (hover/press faint-white veil,
        // never the forui ghost's grey slab).
        style: .delta(
          decoration: .delta([
            .base(
              .boxDelta(
                color: Colors.black.withAlpha(90),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            .match(
              {.hovered, .pressed},
              .boxDelta(
                color: Colors.white.withAlpha(35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ]),
          iconContentStyle: .delta(
            constraints: BoxConstraints(minWidth: box, minHeight: box),
          ),
        ),
        child: AnimatedBuilder(
          animation: jog,
          builder: (context, _) {
            // 2 of the 24-grid units, scaled to the rendered icon.
            final dx =
                _pulse(jog.value, 2.0) / 24 * size * (forward ? 1.0 : -1.0);
            return IconTheme.merge(
              data: IconThemeData(
                color: enabled ? Colors.white : Colors.white.withAlpha(99),
              ),
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Icon(icon, size: size),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The double-tap seek feedback (YouTube-style): the lucide
/// fast-forward/rewind glyph with the skipped time under it, fading in and
/// out in place while the glyph's two triangles do a small x-jog toward the
/// seek direction — the animate-ui FastForward choreography (back arm
/// 1.5 grid-px, front arm 0.6 starting 50ms late, 500ms easeInOut).
/// Plays ONCE per mount — the gesture overlay re-keys it on every
/// double-tap so each tap replays.
class PlayerSeekBurst extends HookWidget {
  const PlayerSeekBurst({super.key, required this.forward});

  final bool forward;

  /// Total feedback: 200ms fade in, hold, fade out through the tail while
  /// the icon jog (plain 500ms like animate-ui) settles inside it.
  static const _fade = Duration(milliseconds: 700);

  @override
  Widget build(BuildContext context) {
    final icon = forward ? FLucideIcons.fastForward : FLucideIcons.rewind;
    final fade = useAnimationController(duration: _fade);
    useEffect(() {
      fade.forward();
      return null;
    }, const []);
    final glyph = useFuture(useMemoized(() => MorphGlyphs.icon(icon), [icon]));
    final glyphData = glyph.data;
    final loops = useMemoized(
      () => glyphData == null ? null : _loops(glyphData.d),
      [glyphData],
    );

    // Plain fade in / fade out — no bounce, no rise (user directive). The
    // two lucide triangles ALONE do the animate-ui x-jog inside the burst.
    return AnimatedBuilder(
      animation: fade,
      builder: (context, _) {
        // Unmount once the fade completes — the burst leaves the tree
        // instead of lingering at opacity 0.
        if (fade.isCompleted) return const SizedBox.shrink();
        final t = fade.value;
        final mobileMs = t * _fade.inMilliseconds;
        final forwardDx = forward ? 1.0 : -1.0;
        final shadow = [
          Shadow(blurRadius: 10, color: Colors.black.withAlpha(190)),
        ];
        return Opacity(
          opacity: _fadeOpacity(t),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loops == null)
                // Glyph extraction pending or failed — the plain icon is the
                // identical look while waiting.
                Icon(icon, size: 36, color: Colors.white, shadows: shadow)
              else
                SizedBox.square(
                  dimension: 36,
                  child: CustomPaint(
                    painter: _SeekJigglePainter(
                      loops: loops,
                      dxs: [
                        _pulse(mobileMs / _kJogMs, _kJogBack) * forwardDx,
                        _pulse((mobileMs - 50) / (_kJogMs - 50), _kJogFront) *
                            forwardDx,
                      ],
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 3),
              Text(
                forward ? '+10s' : '-10s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  shadows: shadow,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// animate-ui FastForward x-shift timing, on the 24 grid.
const _kJogMs = 500.0;
const _kJogBack = 1.5;
const _kJogFront = 0.6;

/// Burst icon stroke on the 24 grid — well below lucide's 2 default
/// (thinned on user request, twice: 2 -> 1.5 -> 1.2).
const _kStroke = 1.2;

/// animate-ui keyframe ping `[0, amp, 0]` under easeInOut; 0 outside (0,1).
double _pulse(double phase, double amp) {
  final t = phase.clamp(0.0, 1.0);
  if (t <= 0.0 || t >= 1.0) return 0.0;
  final e = Curves.easeInOut.transform(t < 0.5 ? t * 2 : 2 - t * 2);
  return amp * e;
}

/// Burst opacity: rise through the first ~200ms, fall through the ~250ms
/// tail — plain fade in, fade out, no drift.
double _fadeOpacity(double t) {
  const rise = 2 / 7;
  const fallStart = .5;
  final i = Curves.easeOut.transform((t / rise).clamp(0.0, 1.0));
  final o =
      1 -
      Curves.easeIn.transform(
        ((t - fallStart) / (1 - fallStart)).clamp(0.0, 1.0),
      );
  return math.min(i, o);
}

/// The extracted glyph's `M..L..Z` midlines as 24-grid polygon loops.
List<List<Offset>> _loops(String d) => [
  for (final chunk in d.split('M'))
    if (chunk.trim().isNotEmpty)
      [
        for (final m in RegExp(
          r'(-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)',
        ).allMatches(chunk))
          Offset(double.parse(m.group(1)!), double.parse(m.group(2)!)),
      ],
];

/// Paints the glyph's polygon loops as a lucide stroke, each translated by
/// its x-jog (24-grid). Under it a soft black halo keeps white over bright
/// video readable (the shadow the plain `Icon` carries).
class _SeekJigglePainter extends CustomPainter {
  const _SeekJigglePainter({
    required this.loops,
    required this.dxs,
    required this.size,
    required this.color,
  });

  final List<List<Offset>> loops;
  final List<double> dxs;
  final double size;
  final Color color;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final scale = size / 24;
    for (var i = 0; i < loops.length; i++) {
      final path = Path()
        ..moveTo(loops[i][0].dx * scale, loops[i][0].dy * scale);
      for (final p in loops[i].skip(1)) {
        path.lineTo(p.dx * scale, p.dy * scale);
      }
      path.close();
      canvas.save();
      canvas.translate(dxs[i] * scale, 0);
      // Black outline pass first, white centerline over it — the viewer's
      // readable-over-video look. The stroke sits a step BELOW the lucide
      // 2-grid default so the 36px burst stays airy, not chunky.
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black.withAlpha(190)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _kStroke * scale + 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _kStroke * scale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SeekJigglePainter oldDelegate) {
    final dy =
        !identical(loops, oldDelegate.loops) ||
        color != oldDelegate.color ||
        size != oldDelegate.size;
    final odx = oldDelegate.dxs;
    return dy ||
        dxs.length != odx.length ||
        [for (var i = 0; i < dxs.length; i++) dxs[i] != odx[i]].any((d) => d);
  }
}

/// The primary play/pause anchor on the video — the mock's dark glass
/// disc: near-black fill, white glyph, hairline white border that
/// brightens on hover/press. Sized per surface — 64px in fullscreen,
/// 48px in the compact portrait viewport. The glyph is the lucide font's
/// own svg geometry (runtime-extracted from the packed forui_lucide font,
/// see MorphGlyphs) morphing play<->pause on a snappy spring; while the
/// extraction is in flight the plain icon renders (same look, cached
/// after the first resolve).
class PlayerPlayPauseDisc extends HookWidget {
  const PlayerPlayPauseDisc({
    super.key,
    required this.isPlaying,
    required this.onPress,
    this.box = 64,
    this.iconSize = 30,
  });

  final bool isPlaying;
  final VoidCallback onPress;
  final double box;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final glyphs = useFuture(
      useMemoized(
        () => Future.wait([
          MorphGlyphs.icon(FLucideIcons.play),
          MorphGlyphs.icon(FLucideIcons.pause),
        ]),
      ),
    );
    final extracted = glyphs.data;
    final glyph = extracted == null
        ? null
        : isPlaying
        ? extracted[1]
        : extracted[0];
    return Semantics(
      label: 'media.video_player.play'.i18n,
      button: true,
      child: FButton.icon(
        variant: .ghost,
        onPress: onPress,
        style: .delta(
          decoration: .delta([
            .base(
              .boxDelta(
                color: Colors.black.withAlpha(217),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withAlpha(51)),
              ),
            ),
            .match(
              {.hovered, .pressed},
              .boxDelta(
                color: Colors.black.withAlpha(242),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withAlpha(102)),
              ),
            ),
          ]),
          iconContentStyle: .delta(
            constraints: BoxConstraints(minWidth: box, minHeight: box),
          ),
        ),
        child: glyph == null
            ? Icon(
                isPlaying ? FLucideIcons.pause : FLucideIcons.play,
                size: iconSize,
                color: Colors.white,
              )
            : MorphIcon(
                icon: glyph,
                size: iconSize,
                color: Colors.white,
                spring: SpringPreset.snappy,
              ),
      ),
    );
  }
}

/// Auto-rotation toggle for the player chrome: lucide's refresh-cw-off
/// (off) morphs into refresh-cw (on) through [MorphIcon] — the same
/// runtime-extracted font geometry + snappy spring as the play/pause disc,
/// so the two arrows of the off glyph flow into the on glyph's circle.
/// While the glyph extraction is in flight the plain off icon renders
/// (the default state).
class PlayerAutoRotateButton extends HookWidget {
  const PlayerAutoRotateButton({
    super.key,
    required this.enabled,
    required this.onPress,
    this.small = true,
  });

  final bool enabled;
  final VoidCallback onPress;

  /// Small (36px) in the portrait overlay's tight cluster; the landscape
  /// header passes false for its 44px circle-button rhythm.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final glyphs = useFuture(
      useMemoized(
        () => Future.wait([
          MorphGlyphs.icon(FLucideIcons.refreshCwOff),
          MorphGlyphs.icon(FLucideIcons.refreshCw),
        ]),
      ),
    );
    final extracted = glyphs.data;
    final glyph = extracted == null
        ? null
        : enabled
        ? extracted[1]
        : extracted[0];
    return PlayerCircleButton(
      small: small,
      onPress: onPress,
      semanticLabel:
          (enabled ? 'watch.auto_rotation_on' : 'watch.auto_rotation_off').i18n,
      icon: glyph == null
          ? Icon(
              enabled ? FLucideIcons.refreshCw : FLucideIcons.refreshCwOff,
              size: 18,
            )
          : MorphIcon(
              icon: glyph,
              size: 18,
              color: Colors.white,
              spring: SpringPreset.snappy,
            ),
    );
  }
}

/// Tiny stream-type badge ("HLS" / "MP4") beside the episode label — an
/// [FBadge] with an emerald overlay delta.
class PlayerTypeBadge extends StatelessWidget {
  const PlayerTypeBadge({super.key, required this.videoType});

  final String videoType;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: .secondary,
      style: .delta(
        decoration: .boxDelta(
          color: const Color(0x1400FF88),
          border: Border.all(color: const Color(0x5310B981)),
          borderRadius: BorderRadius.circular(4),
        ),
        labelTextStyle: TextStyleDelta.delta(
          color: const Color(0xFF6EE7B7),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        padding: EdgeInsetsGeometryDelta.value(
          const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        ),
      ),
      child: Text(videoType),
    );
  }
}

/// Tiny Forui badge on the video canvas — the meta-row affordance
/// ("1080p", subtitle language, mirror name): an [FBadge] with an overlay
/// delta (white on white/10, hairline border). One definition shared by
/// the portrait and landscape overlays so the chip look cannot drift apart.
class PlayerMetaChip extends StatelessWidget {
  const PlayerMetaChip({super.key, required this.label, required this.onPress});

  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      // Normal FBadge metrics (default padding + label) — only the overlay
      // decoration is delta'd for contrast on the raw canvas.
      child: FBadge(
        variant: .secondary,
        style: .delta(
          decoration: .boxDelta(
            color: Colors.white.withAlpha(26),
            border: Border.all(color: Colors.white.withAlpha(26)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// The meta row's settings chips — mirror · subtitle · quality · speed —
/// rendered by BOTH mobile overlays through this one atom. Each chip hides
/// when the stream carries no such data, and every chip deep-links into the
/// settings surface on its own pane (the portrait bottom sheet, the
/// landscape docked panel).
class PlayerSettingsChips extends ConsumerWidget {
  const PlayerSettingsChips({
    super.key,
    required this.vidPr,
    required this.baseTab,
    required this.onOpenTab,
  });

  final VideoPlayerNotifierProvider vidPr;

  /// Tab index of the first non-Episodes pane: 0 on the portrait sheet
  /// (Episodes dropped), 1 on the docked fullscreen panel (Episodes first).
  final int baseTab;

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qualityMap = ref.watch(vidPr.select((s) => s.qualityMap));
    final subtitles = ref.watch(vidPr.select((s) => s.subtitlesRaw));
    final subIndex = ref.watch(vidPr.select((s) => s.selectedSubtitleIndex));
    final v2watch = ref.watch(vidPr.select((s) => s.v2watch));
    final speed = ref.watch(vidPr.select((s) => s.speed));
    final playingUrl = ref.read(vidPr.notifier).vidController.dataSource;

    final hasMirrors = v2watch != null && v2watch.groups.isNotEmpty;
    final mirrorTab = hasMirrors ? baseTab : null;
    final resolutionTab = hasMirrors ? baseTab + 1 : baseTab;
    final subtitleTab = resolutionTab + 1;
    final speedTab = subtitleTab + 1;

    // The active stream's labels, matched the same way the settings panes
    // mark their selected tiles (by controller URL).
    String? qualityLabel;
    for (final entry in qualityMap.entries) {
      if (entry.value == playingUrl) qualityLabel = entry.key;
    }
    String? subtitleLabel;
    if (subtitles.isNotEmpty) {
      final lang = subtitles[subIndex.clamp(0, subtitles.length - 1)].language;
      subtitleLabel = lang.length > 2 ? lang.substring(0, 2) : lang;
    }
    String? mirrorLabel;
    if (hasMirrors) {
      for (final group in v2watch.groups) {
        for (final mirror in group.mirrors) {
          if (mirror.url == playingUrl) mirrorLabel = mirror.name;
        }
      }
      // v2 sources always surface a mirror chip — the playing group's title.
      mirrorLabel ??= v2watch.groups.first.title;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mirrorLabel != null) ...[
          PlayerMetaChip(
            label: mirrorLabel,
            onPress: () => onOpenTab(mirrorTab!),
          ),
          const SizedBox(width: 6),
        ],
        if (subtitleLabel != null) ...[
          PlayerMetaChip(
            label: subtitleLabel,
            onPress: () => onOpenTab(subtitleTab),
          ),
          const SizedBox(width: 6),
        ],
        if (qualityLabel != null) ...[
          PlayerMetaChip(
            label: qualityLabel,
            onPress: () => onOpenTab(resolutionTab),
          ),
          const SizedBox(width: 6),
        ],
        PlayerMetaChip(
          label: _speedLabel(speed),
          onPress: () => onOpenTab(speedTab),
        ),
      ],
    );
  }

  static String _speedLabel(double speed) =>
      '${speed % 1 == 0 ? speed.toStringAsFixed(1) : speed}x';
}
