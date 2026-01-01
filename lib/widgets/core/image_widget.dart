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
    this.clipBehavior = Clip.antiAlias,
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

  const ImageWidget.defaultErr({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.loadingChild = const Center(child: FCircularProgress()),
    this.borderRadius = 10,
    this.clipBehavior = Clip.antiAlias,
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
    // Fallback: treat as network image
    return ExtendedImage.network(
      imageUrl!,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
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
            return buildErrchild();
        }
      },
    );
  }
}
