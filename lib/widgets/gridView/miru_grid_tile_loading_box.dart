import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shimmer/shimmer.dart';

class MiruGridTileLoadingBox extends StatelessWidget {
  const MiruGridTileLoadingBox({super.key, this.width, this.height});
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: context.theme.colors.background,
            highlightColor: context.theme.colors.secondary,
            child: SizedBox(
              width: width ?? 200,
              height: height,
              child: Container(
                width: width ?? 200,
                height: height,
                decoration: BoxDecoration(
                  color: context.theme.colors.mutedForeground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: context.theme.colors.background,
          highlightColor: context.theme.colors.secondary,
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5,
              ),
              child: Container(
                // width: width ?? 200,
                height: 10,
                decoration: BoxDecoration(
                  color: context.theme.colors.mutedForeground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
