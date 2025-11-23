import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class MobileMangaLoading extends StatelessWidget {
  const MobileMangaLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colors.background,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: const FCircularProgress(),
    );
  }
}

class MangaImage extends StatelessWidget {
  const MangaImage({super.key, required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return ImageWidget(
      imageUrl: imageUrl,
      loadingChild: MobileMangaLoading(),
      borderRadius: 0,
    );
  }
}
