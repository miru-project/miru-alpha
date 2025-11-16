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
  });
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    // Support data URLs (base64) and network URLs.
    // final trimmed = imageUrl.trim();
    // final isDataUri = trimmed.startsWith('data:image/');

    // if (isDataUri) {
    //   try {
    //     // data:[<mediatype>][;base64],<data>
    //     final comma = trimmed.indexOf(',');
    //     final base64Str = (comma >= 0) ? trimmed.substring(comma + 1) : trimmed;
    //     final bytes = base64Decode(base64Str);

    //     return ExtendedImage.memory(
    //       bytes,
    //       borderRadius: BorderRadius.circular(10),
    //       shape: BoxShape.rectangle,
    //       width: width,
    //       height: height,
    //       fit: fit,
    //       loadStateChanged: (ExtendedImageState state) {
    //         switch (state.extendedImageLoadState) {
    //           case LoadState.loading:
    //             return const Center(child: CircularProgressIndicator());
    //           case LoadState.completed:
    //             return null;
    //           case LoadState.failed:
    //             return const Icon(FIcons.cloudAlert);
    //         }
    //       },
    //     );
    //   } catch (e) {
    //     return SizedBox(
    //       width: width,
    //       height: height,
    //       child: const Icon(FIcons.cloudAlert),
    //     );
    //   }
    // }

    if (imageUrl?.isEmpty ?? true) return const Icon(FIcons.cloudAlert);
    // Fallback: treat as network image
    return ExtendedImage.network(
      imageUrl!,
      borderRadius: BorderRadius.circular(10),
      shape: BoxShape.rectangle,
      width: width,
      height: height,
      fit: fit,
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
