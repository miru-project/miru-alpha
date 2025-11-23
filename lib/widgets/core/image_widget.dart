// import 'dart:convert';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.errChild = const Icon(FIcons.cloudAlert),
    this.loadingChild = const Center(child: FCircularProgress()),
    this.borderRadius = 10,
  });
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget errChild;
  final Widget loadingChild;
  final double borderRadius;
  @override
  Widget build(BuildContext context) {
    if (imageUrl?.isEmpty ?? true) return errChild;
    // Fallback: treat as network image
    return ExtendedImage.network(
      imageUrl!,
      borderRadius: BorderRadius.circular(borderRadius),
      shape: BoxShape.rectangle,
      width: width,
      height: height,
      fit: fit,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return loadingChild;
          case LoadState.completed:
            return null;
          case LoadState.failed:
            return errChild;
        }
      },
    );
  }
}
