import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shimmer/shimmer.dart';

class MiruGridTileLoadingBox extends StatelessWidget {
  const MiruGridTileLoadingBox({super.key, this.width, this.height});
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      // baseColor: context.theme.colors.background.withAlpha(50),
      // highlightColor: context.theme.colors.foreground.withAlpha(100),
      gradient: LinearGradient(
        colors: [
          context.theme.colors.background.withAlpha(50),
          context.theme.colors.foreground.withAlpha(100),
          context.theme.colors.background.withAlpha(50),
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.3),
        stops: const [0.4, 0.5, 0.6],
      ),
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
