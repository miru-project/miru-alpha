import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';

/// Shown while a page is still loading.
///
/// It deliberately imposes **no height of its own**: it fills whatever box it is
/// given. A paged page is given the whole screen, which is right. A webtoon page
/// is given an unbounded height, where a screenful-sized placeholder punches a
/// screenful of black into the strip — a black void under the last page that
/// becomes an obvious block at the page boundary once the reader magnifies it.
/// The [kMangaLoadingSlotHeight] minimum is there so a still-loading page is at
/// least a visible slot with a spinner in it rather than nothing at all.
const kMangaLoadingSlotHeight = 120.0;

class MobileMangaLoading extends StatelessWidget {
  const MobileMangaLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.theme.colors.background,
      child: const SizedBox(
        height: kMangaLoadingSlotHeight,
        child: Center(child: FCircularProgress()),
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
      loadingChild: const MobileMangaLoading(),
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
