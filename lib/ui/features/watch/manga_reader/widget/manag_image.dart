import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';

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
                ? const FCircularProgress()
                : Column(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        '${(progress! * 100).round()}%',
                        style: context.theme.typography.body.xs.copyWith(
                          color: colors.mutedForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // A determinate bar in FProgress's own tokens (6px pill,
                      // muted track, primary fill) — forui's FProgress is
                      // indeterminate-only, so this is the smallest native
                      // primitive that can hold a real value.
                      SizedBox(
                        width: 96,
                        height: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: colors.muted,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FractionallySizedBox(
                              widthFactor: progress!.clamp(0.0, 1.0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: colors.primary,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
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
