import 'dart:async';
import 'package:flutter/material.dart';
import 'package:miru_app_new/miru_core/event_service.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:miru_app_new/utils/download/download_utils.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:miru_app_new/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_provider.g.dart';

class DownloadState {
  final List<proto.Download> history;
  final List<proto.DownloadProgress> active;

  DownloadState({this.history = const [], this.active = const []});

  DownloadState copyWith({
    List<proto.Download>? history,
    List<proto.DownloadProgress>? active,
  }) {
    return DownloadState(
      history: history ?? this.history,
      active: active ?? this.active,
    );
  }
}

@riverpod
class DownloadNotifier extends _$DownloadNotifier {
  StreamSubscription? _subscription;
  final Set<String> _processedTasks = {};

  @override
  AsyncValue<DownloadState> build() {
    _init();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const AsyncLoading();
  }

  Future<void> _init() async {
    try {
      await _fetchInitialData();
      _startStream();
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> _fetchInitialData() async {
    final historyFuture = MiruGrpcClient.downloadClient.getAllDownloads(
      proto.GetAllDownloadsRequest(),
    );
    final statusFuture = MiruGrpcClient.downloadClient.getDownloadStatus(
      proto.GetDownloadStatusRequest(),
    );

    final results = await Future.wait([historyFuture, statusFuture]);
    final historyRes = results[0] as proto.GetAllDownloadsResponse;
    final statusRes = results[1] as proto.GetDownloadStatusResponse;

    state = AsyncData(
      DownloadState(
        history: historyRes.downloads,
        active: statusRes.downloadStatus.values
            .where((e) => e.status == 'Downloading' || e.status == 'Paused')
            .toList(),
      ),
    );

    // Check for completed tasks in initial status
    for (final download in statusRes.downloadStatus.values) {
      if (download.status == 'Completed') {
        _handleCompletion(download);
      }
    }
  }

  void _startStream() {
    _subscription = miruEventService.downloadStream.listen((status) {
      final activeList = status.values.toList();
      final uiList = activeList
          .where((e) => e.status == 'Downloading' || e.status == 'Paused')
          .toList();

      // Update state with new active list
      state.whenData((currentState) {
        state = AsyncData(currentState.copyWith(active: uiList));
      });

      // Handle completions
      for (final download in activeList) {
        if (download.status == 'Completed') {
          _handleCompletion(download);
        }
      }
    });
  }

  Future<void> _refreshHistory() async {
    try {
      final res = await MiruGrpcClient.downloadClient.getAllDownloads(
        proto.GetAllDownloadsRequest(),
      );
      state.whenData((currentState) {
        state = AsyncData(currentState.copyWith(history: res.downloads));
      });
    } catch (e) {
      logger.severe("Failed to refresh history: $e");
    }
  }

  Future<void> _handleCompletion(proto.DownloadProgress download) async {
    final key = download.key;
    if (_processedTasks.contains(key)) return;
    _processedTasks.add(key);

    try {
      final downloadPath = MiruSettings.getSettingSync<String>(
        SettingKey.downloadPath,
      );
      if (downloadPath.isEmpty) {
        logger.warning(
          "Download path not set, skipping move for ${download.title}",
        );
        return;
      }

      await DownloadUtils.processFinishedDownload(
        taskId: download.taskId.toString(),
        segments: download.names,
        currentPath: download.currentDownloading,
        targetDir: downloadPath,
        isHls: download.mediaType == 'hls',
        title: download.title,
      );

      showSimpleToast("Finished downloading ${download.title}");

      await _refreshHistory();
    } catch (e) {
      logger.severe("Failed to process finished download: $e");
    } finally {}
  }

  Future<void> sendAction(
    BuildContext context,
    String id,
    String action,
  ) async {
    final taskId = int.tryParse(id);
    if (taskId == null) return;

    try {
      switch (action) {
        case 'pause':
          await MiruGrpcClient.downloadClient.pauseDownload(
            proto.PauseDownloadRequest()..taskId = taskId,
          );
          break;
        case 'continue':
        case 'resume':
          await MiruGrpcClient.downloadClient.resumeDownload(
            proto.ResumeDownloadRequest()..taskId = taskId,
          );
          break;
        case 'cancel':
          await MiruGrpcClient.downloadClient.cancelDownload(
            proto.CancelDownloadRequest()..taskId = taskId,
          );
          break;
        default:
          return;
      }
      // Re-fetch status to update UI immediately for actions like pause/resume
      // Although stream should handle it, explicit fetch ensures immediate feedback
      final statusRes = await MiruGrpcClient.downloadClient.getDownloadStatus(
        proto.GetDownloadStatusRequest(),
      );
      state.whenData((currentState) {
        state = AsyncData(
          currentState.copyWith(
            active: statusRes.downloadStatus.values.toList(),
          ),
        );
      });
    } catch (e) {
      if (!context.mounted) return;
      showSimpleToast('Failed to $action download: $e');
    }
  }
}
