import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

import 'package:miru_alpha/provider/download_provider.dart';

class DownloadProgressCard extends ConsumerWidget {
  final proto.DownloadProgress task;
  const DownloadProgressCard({required this.task, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double progress = task.total > 0 ? task.progress / task.total : 0.0;

    return FCard(
      title: Text(task.title.isNotEmpty ? task.title : "common.unknown".i18n),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${"common.status".i18n}: ${task.status.name}"),
          const SizedBox(height: 8),
          FDeterminateProgress(value: progress),
          const SizedBox(height: 4),
          Text(
            "${(progress * 100).toStringAsFixed(1)}% - ${task.progress}/${task.total}",
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FButton.icon(
            variant: .secondary,
            onPress: () => ref
                .read(downloadProvider.notifier)
                .sendAction(
                  context,
                  task.taskId.toString(),
                  task.status == proto.DownloadStatus.PAUSED
                      ? proto.DownloadAction.RESUME
                      : proto.DownloadAction.PAUSE,
                ),
            child: Icon(
              task.status == proto.DownloadStatus.PAUSED
                  ? Icons.play_arrow
                  : Icons.pause,
            ),
          ),
          const SizedBox(width: 8),
          FButton.icon(
            variant: .destructive,
            onPress: () => ref
                .read(downloadProvider.notifier)
                .sendAction(
                  context,
                  task.taskId.toString(),
                  proto.DownloadAction.CANCEL,
                ),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
