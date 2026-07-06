import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/download/download_utils.dart';

class DownloadProcessTile extends ConsumerWidget {
  const DownloadProcessTile({super.key, required this.progress});

  final DownloadProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FTile.raw(
      child: Column(
        children: [
          FLabel(
            layout: .vertical,
            description: Text(
              '${progress.progress}/${progress.total} - ${DownloadUtils.statusToI18N(progress.status).i18n}',
            ),
            child: Row(
              children: [
                FCard.raw(
                  child: const SizedBox.square(
                    dimension: 40,
                    child: Icon(FLucideIcons.filePlay, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    progress.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                FButton.icon(
                  variant: .ghost,
                  onPress: () => ref
                      .read(downloadProvider.notifier)
                      .sendAction(
                        context,
                        progress.taskId.toString(),
                        progress.status == DownloadStatus.PAUSED
                            ? DownloadAction.RESUME
                            : DownloadAction.PAUSE,
                      ),
                  child: Icon(
                    progress.status == DownloadStatus.PAUSED
                        ? Icons.play_arrow
                        : Icons.pause,
                  ),
                ),
                FButton.icon(
                  variant: .ghost,
                  onPress: () => ref
                      .read(downloadProvider.notifier)
                      .sendAction(
                        context,
                        progress.taskId.toString(),
                        DownloadAction.CANCEL,
                      ),
                  child: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FDeterminateProgress(
            value: (progress.progress / progress.total).clamp(0, 1),
          ),
        ],
      ),
    );
  }
}

class DownloadHistoryTile extends ConsumerWidget {
  const DownloadHistoryTile({super.key, required this.download});

  final Download download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FTile.raw(
      child: Column(
        children: [
          FLabel(
            layout: .vertical,
            description: Text(DownloadUtils.statusToI18N(download.status).i18n),
            child: Row(
              children: [
                FCard.raw(
                  child: const SizedBox.square(
                    dimension: 40,
                    child: Icon(FLucideIcons.filePlay, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (download.savePath.isNotEmpty)
                        Text(
                          download.savePath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                    ],
                  ),
                ),
                FButton.icon(
                  variant: .ghost,
                  onPress: () async {
                    await MiruGrpcClient.downloadClient.deleteDownload(
                      DeleteDownloadRequest()..id = download.id,
                    );
                    // Refresh handled by notifier ideally, but here we can invalidate
                    ref.invalidate(downloadProvider);
                  },
                  child: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
