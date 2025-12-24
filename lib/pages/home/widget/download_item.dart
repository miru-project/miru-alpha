import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class DownloadItem extends ConsumerWidget {
  const DownloadItem({super.key, required this.item, required this.index});

  final History item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock download progress
    final progress = index == 3 ? 0.6 : 1.0;
    final isDownloading = index == 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageWidget(
                  errChild: Container(
                    width: 60,
                    height: 60,
                    color: context.theme.colors.muted,
                    child: const Icon(FIcons.cloudAlert, size: 20),
                  ),
                  imageUrl: item.cover,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(1.2 + index * 0.3).toStringAsFixed(1)} GB • ${item.episodeTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    if (isDownloading) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FDeterminateProgress(value: progress),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action button
              FButton.icon(
                onPress: () {},
                style: FButtonStyle.outline(),
                child: Icon(
                  isDownloading ? Icons.pause : Icons.check,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
