import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shimmer/shimmer.dart';

class MiruGridTileLoadingBox extends StatelessWidget {
  const MiruGridTileLoadingBox({super.key, this.width, this.height});
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.colors.background.withAlpha(50),
      highlightColor: context.theme.colors.foreground.withAlpha(100),
      child: SizedBox(
        width: width ?? 200,
        height: height,
        child: FCard.raw(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: width ?? 200,
                  height: height,
                  decoration: BoxDecoration(
                    color: context.theme.colors.mutedForeground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: width ?? 200,
                height: 10,
                decoration: BoxDecoration(
                  color: context.theme.colors.mutedForeground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: width ?? 200,
                height: 10,
                decoration: BoxDecoration(
                  color: context.theme.colors.mutedForeground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
