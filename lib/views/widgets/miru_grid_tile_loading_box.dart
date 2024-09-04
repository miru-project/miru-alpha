import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moon_design/moon_design.dart';

class MiruGridTileLoadingBox extends StatelessWidget {
  const MiruGridTileLoadingBox({super.key, this.width, this.height});
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.moonTheme!.segmentedControlTheme.colors.backgroundColor
          .withAlpha(50),
      highlightColor: context
          .moonTheme!.segmentedControlTheme.colors.backgroundColor
          .withAlpha(100),
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Expanded(
                child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            )),
            const SizedBox(height: 8),
            Container(
              width: width,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: width,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          ])),
    );
  }
}
