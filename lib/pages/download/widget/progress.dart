import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:forui/forui.dart';

import 'package:miru_app_new/provider/download_provider.dart';

class DownloadProgressCard extends ConsumerWidget {
  final proto.DownloadProgress task;
  const DownloadProgressCard({required this.task, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double progress = task.total > 0 ? task.progress / task.total : 0.0;

    return FCard(
      title: Text(task.title.isNotEmpty ? task.title : "Unknown"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Status: ${task.status}"),
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
                  task.status == 'Paused' ? 'resume' : 'pause',
                ),
            child: Icon(
              task.status == 'Paused' ? Icons.play_arrow : Icons.pause,
            ),
          ),
          const SizedBox(width: 8),
          FButton.icon(
            variant: .destructive,
            onPress: () => ref
                .read(downloadProvider.notifier)
                .sendAction(context, task.taskId.toString(), 'cancel'),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
