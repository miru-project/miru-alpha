import 'package:miru_alpha/utils/http/request.dart';
import 'package:extended_image/extended_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Handle for an [ImageWidget]'s inner [ExtendedImage], captured from its
/// load-state stream. Pass it to [ImageWidget.controller], then call [retry]
/// to force a reload — e.g. from a retry button shown over the error child:
///
/// ```dart
/// final controller = ImageWidgetController();
/// ImageWidget(imageUrl: url, controller: controller);
/// controller.retry();
/// ```
class ImageWidgetController {
  ExtendedImageState? _state;

  void _attach(ExtendedImageState state) => _state = state;

  /// Forces the image to reload, whether the last load succeeded or failed.
  void retry() => _state?.reLoadImage();
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.errChild = const Icon(FLucideIcons.cloudAlert),
    this.loadingChild = const Center(child: FCircularProgress()),
    this.borderRadius = 10,
    this.clipBehavior = Clip.antiAlias,
    this.retries = 1,
    this.controller,
  }) : title = '';
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget errChild;
  final Widget loadingChild;
  final double borderRadius;
  final Clip clipBehavior;
  final String title;

  /// How many times a failed network load is retried automatically.
  /// Defaults to 1: every retry failure is also reported through the image
  /// stream to the global error handler, and the failed state already renders
  /// [errChild] — more retries means more noise for little extra success.
  final int retries;

  /// Drives the inner [ExtendedImage] — see [ImageWidgetController.retry].
  final ImageWidgetController? controller;

  const ImageWidget.defaultErr({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.loadingChild = const Center(child: FCircularProgress()),
    this.borderRadius = 10,
    this.clipBehavior = Clip.antiAlias,
    this.retries = 1,
    this.controller,
    required this.title,
  }) : errChild = const Placeholder();

  Widget buildErrchild() {
    if (title.isEmpty) return errChild;
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          title,
          softWrap: true,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl?.isEmpty ?? true) return buildErrchild();

    return ExtendedImage.network(
      MiruRequest.proxyUrl(imageUrl!).toString(),
      retries: retries,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
      shape: BoxShape.rectangle,
      width: width,
      height: height,
      fit: fit,
      loadStateChanged: (ExtendedImageState state) {
        controller?._attach(state);
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return loadingChild;
          case LoadState.completed:
            return null;
          case LoadState.failed:
            return buildErrchild();
        }
      },
    );
  }
}
