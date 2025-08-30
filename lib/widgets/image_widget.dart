import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key, required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      borderRadius: BorderRadius.circular(10),
      shape: BoxShape.rectangle,
      cache: true,
      imageUrl,
      loadStateChanged: (ExtendedImageState state) {
        if (state.extendedImageLoadState == LoadState.failed) {
          return const Icon(FIcons.cloudAlert);
        }
        return null;
      },
    );
  }
}
