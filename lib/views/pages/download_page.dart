import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_app_new/utils/download/download_utils.dart';
import 'package:miru_app_new/utils/download/ffmpeg_util.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'package:miru_app_new/views/widgets/snackbar.dart';
import 'package:moon_design/moon_design.dart';

final downloadsProvider =
    StateNotifierProvider<_DownloadsNotifier, AsyncValue<List<dynamic>>>((ref) {
      return _DownloadsNotifier();
    });

class _DownloadsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  Timer? _timer;
  _DownloadsNotifier() : super(const AsyncLoading()) {
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchStatus());
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await dio.get("http://127.127.127.127:12777/download/status");
      final data = res.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        final downloads =
            data.entries.map((e) {
              final value = e.value as Map<String, dynamic>;
              value['id'] = e.key;
              return value;
            }).toList();
        state = AsyncData(downloads);
      } else {
        state = const AsyncData([]);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      logger.warning('Failed to fetch status: $e');
    }
  }

  Future<void> sendAction(
    BuildContext context,
    String id,
    String action,
  ) async {
    String url;
    switch (action) {
      case 'pause':
        url = 'http://127.127.127.127:12777/download/pause/$id';
        break;
      case 'continue':
      case 'resume':
        url = 'http://127.127.127.127:12777/download/resume/$id';
        break;
      case 'cancel':
        url = 'http://127.127.127.127:12777/download/cancel/$id';
        break;
      default:
        url = '';
    }
    if (url.isEmpty) return;
    final res = await dio.post(url);
    if (!context.mounted) {
      return;
    }
    if (res.statusCode != 200) {
      showSnackBar(
        context: context,
        content: Text('Failed to $action download: ${res.data}'),
      );
    } else {
      await _fetchStatus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class DownloadPage extends ConsumerWidget {
  DownloadPage({super.key});

  final finishedList = <String>[];
  void onComplete(
    List<String> list,
    bool isHls,
    String outputName,
    String taskId,
  ) {
    if (isHls && !finishedList.contains(taskId)) {
      FFMpegUtils.combineTsToMp4(list, outputName);
      finishedList.add(taskId);
    }
    return;
  }

  Widget _buildDownloadItem(
    BuildContext context,
    WidgetRef ref,
    dynamic item,
    bool loading,
  ) {
    final status = item['status'] ?? 'Unknown';
    final progressRaw = item['progress'];
    final totalRaw = item['total'];
    final List<String> names = (item['names'] as List?)?.cast<String>() ?? [];
    double progress = 0.0;

    if (progressRaw is num && totalRaw is num && totalRaw > 0) {
      progress = (progressRaw / totalRaw).clamp(0.0, 1.0);
    }

    final id = item['id']!.toString();
    String buttonLabel;
    String action;
    Color buttonColor = Colors.blue;
    final name = MiruCoreDownload.tasks[id]?.name ?? 'Download';
    switch (status) {
      case 'Downloading':
        buttonLabel = 'Pause';
        action = 'pause';
        break;
      case 'Paused':
        buttonLabel = 'Continue';
        action = 'continue';
        break;
      case 'Completed':
        buttonLabel = 'Delete';
        action = 'delete';
        buttonColor = Colors.red;
        onComplete(
          names,
          (item['media_type'] ?? "") == "hls",
          "/storage/emulated/0/Movies/${MiruCoreDownload.tasks[id]?.name ?? 'Download'}.mp4",
          id,
        );
        break;
      case 'Failed':
      case 'Canceled':
        buttonLabel = 'Retry';
        action = 'continue';
        break;
      default:
        buttonLabel = 'Cancel';
        action = 'cancel';
        buttonColor = Colors.red;
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
        trailing: MoonButton(
          label: Text(buttonLabel),
          backgroundColor: buttonColor,
          onTap:
              () => ref
                  .read(downloadsProvider.notifier)
                  .sendAction(context, id, action),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadsProvider);
    final loading = downloadsAsync is AsyncLoading;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: downloadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (downloads) {
          final filtered = downloads.where((d) => d['status'] != null).toList();
          return filtered.isEmpty
              ? const Center(child: Text('No Download Task '))
              : ListView.builder(
                itemCount: filtered.length,
                itemBuilder:
                    (context, index) => _buildDownloadItem(
                      context,
                      ref,
                      filtered[index],
                      loading,
                    ),
              );
        },
      ),
    );
  }
}
