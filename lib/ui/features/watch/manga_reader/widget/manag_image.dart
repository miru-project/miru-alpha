import 'dart:math' as math;

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';

/// Both loading indicators render at one shared diameter: the indeterminate
/// spinner and the determinate ring are the same size.
const _loadingIndicatorSize = 36.0;

/// Shown while a page is still loading.
///
/// The placeholder carries the **manga page's own 2:3 aspect ratio**, so the
/// slot it occupies is the shape the finished page will take. In the webtoon
/// strip that means a loading page already reserves the height its artwork
/// will need — the pages below it no longer jump when the image lands. In
/// paged mode the viewport is the whole screen, so the ratio is honoured
/// inside it and the placeholder sits centred on the canvas like a page.
class MobileMangaLoading extends StatelessWidget {
  const MobileMangaLoading({super.key, this.progress});

  /// Fraction of the page image already received (0..1), straight from the
  /// network image's chunk events. Null when the server did not report a total
  /// size — then the spinner stands alone rather than showing a made-up value.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ColoredBox(
      color: colors.background,
      child: Center(
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Center(
            child: progress == null
                // The forui spinner's icon slot carries the ring's own painter
                // (quarter arc), so spinner and ring share track, fill, stroke
                // and diameter by construction while forui keeps the rotation
                // motion and its reduced-motion handling.
                ? const FCircularProgress(icon: _SpinnerArc())
                // forui ships no determinate circular progress (0.27: linear
                // FDeterminateProgress, spinning FCircularProgress), so the
                // ring is the smallest native-token primitive that holds a
                // real value.
                : _DeterminateRing(progress: progress!),
          ),
        ),
      ),
    );
  }
}

/// The determinate loading ring: forui's own tokens (muted track, primary
/// fill) painted as a circle, standing alone without a percent label.
class _DeterminateRing extends StatelessWidget {
  const _DeterminateRing({required this.progress});

  /// Fraction of the page image already received (0..1).
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return SizedBox.square(
      dimension: _loadingIndicatorSize,
      child: CustomPaint(
        painter: _RingPainter(
          track: colors.muted,
          fill: colors.primary,
          progress: progress.clamp(0.0, 1.0),
        ),
      ),
    );
  }
}

/// The indeterminate state: the ring's own painter showing a quarter arc,
/// rotated by [FCircularProgress]'s motion, so spinner and ring differ only
/// in what the arc shows.
class _SpinnerArc implements FIcon {
  const _SpinnerArc();

  @override
  Widget call(BuildContext context, {String? semanticsLabel}) {
    final colors = context.theme.colors;
    return Semantics(
      label: semanticsLabel,
      child: CustomPaint(
        size: const Size.square(_loadingIndicatorSize),
        painter: _RingPainter(
          track: colors.muted,
          fill: colors.primary,
          progress: 0.75,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.track,
    required this.fill,
    required this.progress,
  });

  final Color track;
  final Color fill;
  final double progress;

  /// One stroke weight for every state of the indicator.
  double get strokeWidth => 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth / 2;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = track;
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = fill;
    canvas.drawCircle(center, radius, trackPaint);
    if (progress <= 0) return;
    // From 12 o'clock, clockwise.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill;
}

class MangaImage extends StatelessWidget {
  const MangaImage({
    super.key,
    required this.imageUrl,
    this.fit = .fitHeight,
    this.invertColors = false,
  });

  final String imageUrl;
  final BoxFit fit;

  /// Night-reading inversion, applied as a colour matrix rather than a filter
  /// so the page keeps its alpha and stays composable with the canvas.
  final bool invertColors;

  @override
  Widget build(BuildContext context) {
    final image = ImageWidget(
      fit: fit,
      imageUrl: imageUrl,
      loadingProgressBuilder: (progress) =>
          MobileMangaLoading(progress: progress),
      borderRadius: 0,
    );
    if (!invertColors) return image;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -1, 0, 0, 0, 255, //
        0, -1, 0, 0, 255, //
        0, 0, -1, 0, 255, //
        0, 0, 0, 1, 0, //
      ]),
      child: image,
    );
  }
}
