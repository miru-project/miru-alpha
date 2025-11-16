import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class _TextTile extends StatelessWidget {
  const _TextTile({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Expanded(
            child: FCard.raw(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: FLabel(
              description: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              axis: Axis.vertical,
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }
}

class MiruDesktopGridTile extends HookWidget {
  const MiruDesktopGridTile({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    this.stackLabel,
    this.width,
    this.onTap,
    this.height,
  });
  final String? imageUrl;
  final String title;
  final String subtitle;
  final void Function()? onTap;
  final double? height;
  final double? width;
  final Widget? stackLabel;
  @override
  Widget build(BuildContext context) {
    // no local hover state required for this simplified tile
    return AnimatedBox(
      onTap: onTap,
      child: SizedBox(
        // width: width ?? 200,
        height: height,
        child: FCard.raw(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Constrain the image's height so it cannot overflow the tile.
              if (imageUrl == null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _TextTile(title: title, subtitle: subtitle),
                )
              else
                // Use a Stack so we can add a bottom gradient "shadow" over the image.
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image fills the area
                      ImageWidget(imageUrl: imageUrl!, fit: BoxFit.cover),
                      // Bottom gradient shadow
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 60,
                        child: IgnorePointer(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: FLabel(
                    description: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    axis: Axis.vertical,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              if (stackLabel != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: stackLabel!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MiruMobileTile extends StatelessWidget {
  const MiruMobileTile({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    this.stackLabel,
    this.width,
    this.onTap,
    this.height,
  });
  final String? imageUrl;
  final String title;
  final String subtitle;
  final void Function()? onTap;
  final double? height;
  final double? width;
  final Widget? stackLabel;

  @override
  Widget build(BuildContext context) {
    // if (imageUrl == null) {
    //   return _TextTile(title: title, subtitle: subtitle);
    // }
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image fills the area
          if (imageUrl == null)
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: context.theme.cardStyle.decoration.borderRadius,
              ),

              child: Center(
                child: Text(
                  title,
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
            )
          else
            ImageWidget(imageUrl: imageUrl!, fit: BoxFit.cover),

          // Bottom gradient shadow
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(200)],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentGeometry.bottomLeft,
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: subtitle.isEmpty
                  ? Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    )
                  : FLabel(
                      description: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      axis: Axis.vertical,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
