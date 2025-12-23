import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class FavoriteCard extends ConsumerWidget {
  const FavoriteCard({
    super.key,
    required this.item,
    required this.aspectRatio,
  });

  final History item;
  final double aspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBox(
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .max,

        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FCard.raw(
                child: ImageWidget(
                  width: 210,
                  height: 280,
                  fit: BoxFit.cover,
                  imageUrl: item.cover ?? '',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            item.episodeTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
