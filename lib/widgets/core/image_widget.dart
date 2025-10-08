import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      borderRadius: BorderRadius.circular(10),
      shape: BoxShape.rectangle,
      width: width,
      height: height,
      cache: true,
      fit: fit,
      imageUrl,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const Center(child: CircularProgressIndicator());
          case LoadState.completed:
            return null;
          case LoadState.failed:
            return const Icon(FIcons.cloudAlert);
        }
      },
    );
  }
}
