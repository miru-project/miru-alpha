import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui/widgets/card.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';

class _TextTile extends StatelessWidget {
  const _TextTile({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class MiruGridTile extends HookWidget {
  const MiruGridTile({
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
        width: width ?? 200,
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
                // Use AspectRatio to keep consistent image size and avoid overflow
                AspectRatio(
                  aspectRatio: 9 / 11.5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: ExtendedImage.network(
                      imageUrl!,

                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      cache: true,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
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
              if (stackLabel != null) ...[
                const SizedBox(height: 8),
                // Place the optional stackLabel below the content but inside card bounds
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
