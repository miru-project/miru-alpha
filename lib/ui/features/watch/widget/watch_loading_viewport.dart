import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:miru_alpha/ui/features/watch/widget/player_chrome_standins.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/http/request.dart';

/// The 16:9 loading canvas of the mobile watch page — the mock's
/// "extension loading state" (>3s), rebuilt 2026-10-30: dual contrast
/// scrims, an ambient shimmer sweep, a glass resolver disc carrying the
/// EXTENSION'S OWN IDENTITY (logo + "Resolving stream via {ext}"), and a
/// muted minimalist indeterminate track at the bottom — the time row and
/// settings chips are gone (zero-state clutter removed). forui carries the
/// progress track and the chip-free chrome; the spin/shimmer are homebrew
/// (forui has no primitives for them).
class WatchLoadingViewport extends HookWidget {
  const WatchLoadingViewport({
    super.key,
    required this.title,
    required this.onBack,
    this.extensionName = '',
    this.extensionIcon,
  });

  final String title;
  final VoidCallback onBack;

  /// The resolving extension's display name — the subtitle names it
  /// ("Resolving stream via {extensionName}") and its logo sits in the
  /// resolver disc.
  final String extensionName;
  final String? extensionIcon;

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colors.primary;
    // LayoutBuilder, not MediaQuery.sizeOf: branch on the REAL canvas
    // constraints (the test harness resizes via setSurfaceSize, which does
    // not refresh view metrics — rule 27).
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF111215)),
              // Ambient accent glow (radial, subtle presence).
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.9,
                      colors: [primary.withAlpha(31), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // The ambient shimmer sweep over the whole canvas.
              const IgnorePointer(child: _ShimmerSweep()),
              // Top + bottom contrast scrims (the mock's h-28 / h-24 bands)
              // — separate bands, not the loaded player's full-column
              // gradient: the loading canvas has no video behind them.
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 112,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xD9000000),
                        Color(0x80000000),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 96,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xF2000000),
                        Color(0x99000000),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: !landscape,
                bottom: false,
                child: Column(
                  children: [
                    // Top bar: back · centered title · dimmed shuffle/cast
                    // shells (no stream to act on yet — visibly inert).
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          PlayerCircleButton(
                            onPress: onBack,
                            semanticLabel: 'common.back'.i18n,
                            icon: const Icon(
                              FLucideIcons.chevronLeft,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(204),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          PlayerInertShell(
                            child: PlayerCircleButton(
                              onPress: null,
                              semanticLabel: '',
                              icon: const Icon(FLucideIcons.shuffle, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PlayerInertShell(
                            child: PlayerCircleButton(
                              onPress: null,
                              semanticLabel: '',
                              icon: const Icon(FLucideIcons.cast, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Center telemetry: the glass resolver disc + identity
                    // copy — exactly where the play disc lands when the
                    // stream resolves.
                    Expanded(
                      child: Center(
                        child: _ResolverIdentity(
                          primary: primary,
                          extensionName: extensionName,
                          extensionIcon: extensionIcon,
                        ),
                      ),
                    ),
                    // The muted minimalist ambient loading track — the mock's
                    // zero-clutter bottom band, as a forui indeterminate
                    // FProgress.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        height: 4,
                        width: double.infinity,
                        child: FProgress(
                          style: .delta(
                            trackDecoration: DecorationDelta.boxDelta(
                              color: Colors.white.withAlpha(13),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            fillDecoration: DecorationDelta.boxDelta(
                              color: primary.withAlpha(77),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The resolver identity block: a 48px glass disc whose spinning accent arc
/// circles the EXTENSION'S OWN logo (or the play glyph when the icon is
/// missing/failed), with "Loading video…" and the extension-named subtitle
/// under it.
class _ResolverIdentity extends StatelessWidget {
  const _ResolverIdentity({
    required this.primary,
    required this.extensionName,
    required this.extensionIcon,
  });

  final Color primary;
  final String extensionName;
  final String? extensionIcon;

  @override
  Widget build(BuildContext context) {
    // scaleDown: short canvases (320-wide phones -> 180px viewports)
    // shrink the block instead of overflowing — the state is transient,
    // readability scales with it.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResolverDisc(primary: primary, iconUrl: extensionIcon),
            const SizedBox(height: 14),
            Text(
              'watch.loading_video'.i18n,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              extensionName.isEmpty
                  ? 'watch.resolving_stream'.i18n
                  : '${'watch.resolving_stream_via'.i18n} $extensionName',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 48px glass resolver disc: the spinning accent arc over a faint full
/// ring, with the extension logo (proxy-loaded, play-glyph fallback)
/// centered inside.
class _ResolverDisc extends HookWidget {
  const _ResolverDisc({required this.primary, required this.iconUrl});

  final Color primary;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final spin = useAnimationController(duration: const Duration(seconds: 3))
      ..repeat();
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The glass body.
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
          ),
          // The spinning accent arc (the mock's border-t ring).
          AnimatedBuilder(
            animation: spin,
            builder: (context, _) => CustomPaint(
              size: const Size(48, 48),
              painter: _RingPainter(turns: spin.value, color: primary),
            ),
          ),
          // The extension's own logo, or the play glyph fallback.
          SizedBox(
            width: 24,
            height: 24,
            child: iconUrl == null || iconUrl!.isEmpty
                ? Icon(FLucideIcons.play, size: 12, color: primary)
                : ClipOval(
                    child: Image.network(
                      MiruRequest.proxyUrl(iconUrl!).toString(),
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Icon(FLucideIcons.play, size: 12, color: primary),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The mock's ring painter: a faint full ring with one bright accent arc
/// (a border-t-only spinning ring, hand-drawn) plus its soft glow.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.turns, required this.color});

  final double turns;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    // Faint full ring.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withAlpha(51),
    );
    // Rotating bright arc + its soft glow (the mock's stepper-glow).
    final start = -math.pi / 2 + 2 * math.pi * turns;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color.withAlpha(89)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, start, math.pi / 2, false, glow);
    canvas.drawArc(
      rect,
      start,
      math.pi / 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      turns != oldDelegate.turns || color != oldDelegate.color;
}

/// The ambient shimmer sweep: a soft white band translating across the
/// canvas on a 2s loop (the mock's shimmer-mask), clipped to the canvas.
class _ShimmerSweep extends HookWidget {
  const _ShimmerSweep();

  @override
  Widget build(BuildContext context) {
    final ctrl = useAnimationController(duration: const Duration(seconds: 2))
      ..repeat();
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final band = w * 0.5;
          final x = -band + (w + band) * ctrl.value;
          return Stack(
            children: [
              Positioned(
                left: x,
                top: 0,
                bottom: 0,
                width: band,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x0AFFFFFF),
                        Color(0x14FFFFFF),
                        Color(0x0AFFFFFF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
