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
  const MobileMangaLoading({super.key, this.progress, this.aspectRatio});

  /// Fraction of the page image already received (0..1), straight from the
  /// network image's chunk events. Null when the server did not report a total
  /// size — then the spinner stands alone rather than showing a made-up value.
  final double? progress;

  /// Aspect the placeholder reserves its size from. Every page of a chapter
  /// shares the artist's paper, so once any page of the chapter has decoded
  /// the rest can reserve exactly that height — the strip never reflows when
  /// the pages below land.
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ColoredBox(
      color: colors.background,
      child: Center(
        child: AspectRatio(
          aspectRatio: aspectRatio ?? 2 / 3,
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

/// Decoded page aspects, keyed by chapter url.
///
/// Every page of a chapter shares the artist's paper, so the moment one page
/// of a chapter is decoded the surrounding loading pages can reserve the
/// identical height and the list never reflows. Bounded so a long binge
/// session does not accumulate it without limit.
///
/// Values are **width / height**, matching [AspectRatio.aspectRatio]: a page
/// that is twice as tall as it is wide stores `0.5`, so a 200-wide placeholder
/// reserves 400px — the decoded page's own height. Storing `height / width`
/// here would invert it and make every placeholder half-height.
final Map<String, double> _decodedAspect = <String, double>{};
const _maxAspectCacheEntries = 64;

/// Width / height of the fallback placeholder: the 2:3 manga page.
const double _fallbackPageAspect = 2 / 3;

double aspectRatioFor(String? chapterUrl) {
  final direct = chapterUrl == null ? null : _decodedAspect[chapterUrl];
  if (direct != null) return direct;
  // No measurement for this chapter yet — reuse the most recently decoded
  // aspect from a sibling chapter; manga from the same source shares paper.
  return _decodedAspect.isEmpty
      ? _fallbackPageAspect
      : _decodedAspect.values.last;
}

/// Test-only: wipe the chapter aspect cache between tests.
@visibleForTesting
void clearDecodedAspectCacheForTest() => _decodedAspect.clear();

void _rememberDecodedAspect(String chapterUrl, Size size) {
  if (size.width <= 0 || size.height <= 0) return;
  _decodedAspect.remove(chapterUrl);
  // width / height, so [MobileMangaLoading] can hand it straight to
  // [AspectRatio] and reserve the same height the decoded page will take.
  _decodedAspect[chapterUrl] = size.width / size.height;
  while (_decodedAspect.length > _maxAspectCacheEntries) {
    _decodedAspect.remove(_decodedAspect.keys.first);
  }
}

/// Test-only: write through the same path the decoded-page callback uses.
///
/// The real write lives in `_rememberDecodedAspect`, which is reached from
/// [MangaImage]'s `onCompletedSize`. A test that asserted on a hand-computed
/// ratio would restate the production formula instead of exercising it, so
/// this seam lets the test drive the actual write and then read the store
/// back through the public [aspectRatioFor].
@visibleForTesting
void rememberDecodedAspectForTest(String chapterUrl, Size size) =>
    _rememberDecodedAspect(chapterUrl, size);

class MangaImage extends StatelessWidget {
  const MangaImage({
    super.key,
    required this.imageUrl,
    this.chapterUrl,
    this.fit = .fitHeight,
    this.invertColors = false,
  });

  final String imageUrl;

  /// Stable identifier of the chapter this page belongs to (the segment's
  /// watch URL). The aspect ratio of every page in a chapter matches, so a
  /// decoded sibling propagates the reserved height to the rest of the strip.
  final String? chapterUrl;

  final BoxFit fit;

  /// Night-reading inversion, applied as a colour matrix rather than a filter
  /// so the page keeps its alpha and stays composable with the canvas.
  final bool invertColors;

  @override
  Widget build(BuildContext context) {
    final image = ImageWidget(
      fit: fit,
      imageUrl: imageUrl,
      loadingProgressBuilder: (progress) => MobileMangaLoading(
        progress: progress,
        aspectRatio: aspectRatioFor(chapterUrl),
      ),
      onCompletedSize: chapterUrl == null
          ? null
          : (size) => _rememberDecodedAspect(chapterUrl!, size),
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
