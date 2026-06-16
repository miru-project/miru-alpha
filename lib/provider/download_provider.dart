import 'dart:async';
import 'package:flutter/material.dart';
import 'package:miru_alpha/miru_core/event_service.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/download/download_utils.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_provider.g.dart';

class DownloadState {
  final List<proto.Download> history;
  final List<proto.DownloadProgress> active;
  final int page;
  final bool hasMore;

  /// Keys of episodes currently being fetched/resolved before download starts.
  final Set<String> preparingKeys;

  DownloadState({
    this.history = const [],
    this.active = const [],
    this.page = 1,
    this.hasMore = true,
    this.preparingKeys = const {},
  });

  DownloadState copyWith({
    List<proto.Download>? history,
    List<proto.DownloadProgress>? active,
    int? page,
    bool? hasMore,
    Set<String>? preparingKeys,
  }) {
    return DownloadState(
      history: history ?? this.history,
      active: active ?? this.active,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      preparingKeys: preparingKeys ?? this.preparingKeys,
    );
  }
}

extension DownloadStatusX on proto.DownloadStatus {
  /// Whether the task is still in a pending/active state (not terminal).
  bool get isActive =>
      this == proto.DownloadStatus.DOWNLOADING ||
      this == proto.DownloadStatus.PAUSED ||
      this == proto.DownloadStatus.CONVERTING;
}

/// Statuses that trigger frontend processing (e.g. FFmpeg conversion for HLS).
bool _isProcessingStatus(proto.DownloadStatus status) {
  return status == proto.DownloadStatus.CONVERTING;
}

@Riverpod(keepAlive: true)
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

  static List<proto.DownloadProgress> filterActive(
    Iterable<proto.DownloadProgress> tasks,
  ) {
    return tasks.where((e) => e.status.isActive).toList();
  }

  Future<void> _fetchInitialData() async {
    const pageSize = 20;
    final historyFuture = MiruGrpcClient.downloadClient.getAllDownloads(
      proto.GetAllDownloadsRequest()
        ..page = 1
        ..pageSize = pageSize,
    );
    final statusFuture = MiruGrpcClient.downloadClient.getDownloadStatus(
      proto.GetDownloadStatusRequest(),
    );

    final results = await Future.wait([historyFuture, statusFuture]);
    final historyRes = results[0] as proto.GetAllDownloadsResponse;
    final statusRes = results[1] as proto.GetDownloadStatusResponse;

    final allTasks = statusRes.downloadStatus.values;

    state = AsyncData(
      DownloadState(
        history: historyRes.downloads,
        active: filterActive(allTasks),
        page: 1,
        hasMore: historyRes.downloads.length >= pageSize,
      ),
    );

    // Process any tasks that need frontend processing (e.g. HLS conversion)
    for (final download in allTasks) {
      if (_isProcessingStatus(download.status)) {
        _processDownload(download);
      }
    }
  }

  void _startStream() {
    _subscription = miruEventService.downloadStream.listen((status) {
      final allTasks = status.values;
      final activeTasks = filterActive(allTasks);

      state.whenData((currentState) {
        state = AsyncData(currentState.copyWith(active: activeTasks));
      });

      // Process tasks needing frontend processing (e.g. HLS conversion)
      for (final download in allTasks) {
        if (_isProcessingStatus(download.status)) {
          _processDownload(download);
        }
      }
    });
  }

  Future<void> _refreshHistory() async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      const pageSize = 20;
      final res = await MiruGrpcClient.downloadClient.getAllDownloads(
        proto.GetAllDownloadsRequest()
          ..page = 1
          ..pageSize = pageSize,
      );
      state = AsyncData(
        currentState.copyWith(
          history: res.downloads,
          page: 1,
          hasMore: res.downloads.length >= pageSize,
        ),
      );
    } catch (e) {
      logger.severe("Failed to refresh history: $e");
    }
  }

  Future<void> loadMoreHistory() async {
    try {
      final currentState = state.value;
      if (currentState == null || !currentState.hasMore) return;

      const pageSize = 20;
      final nextPage = currentState.page + 1;
      final res = await MiruGrpcClient.downloadClient.getAllDownloads(
        proto.GetAllDownloadsRequest()
          ..page = nextPage
          ..pageSize = pageSize,
      );

      state = AsyncData(
        currentState.copyWith(
          history: [...currentState.history, ...res.downloads],
          page: nextPage,
          hasMore: res.downloads.length >= pageSize,
        ),
      );
    } catch (e) {
      logger.severe("Failed to load more history: $e");
    }
  }

  Future<List<proto.Download>> getDownloadsByPackageAndDetailUrl(
    String package,
    String detailUrl,
  ) async {
    try {
      final res = await MiruGrpcClient.downloadClient
          .getDownloadsByPackageAndDetailUrl(
            proto.GetDownloadsByPackageAndDetailUrlRequest()
              ..package = package
              ..detailUrl = detailUrl,
          );
      return res.downloads;
    } catch (e) {
      logger.severe("Failed to get downloads by package and detail url: $e");
      return [];
    }
  }

  Future<void> _processDownload(proto.DownloadProgress download) async {
    final key = download.key;
    if (_processedTasks.contains(key)) return;
    _processedTasks.add(key);

    try {
      final downloadPath = MiruSettings.getSettingSync<String>(
        SettingKey.downloadPath,
      );
      if (downloadPath.isEmpty) {
        logger.warning(
          "Download path not set, skipping processing for ${download.title}",
        );
        return;
      }

      // Only HLS downloads need FFmpeg conversion on the frontend
      final isHls = download.mediaType == 'hls';
      await DownloadUtils.processFinishedDownload(
        taskId: download.taskId.toString(),
        segments: download.names,
        currentPath: download.currentDownloading,
        targetDir: downloadPath,
        isHls: isHls,
        title: download.title,
      );

      showSimpleToast("Finished downloading ${download.title}");

      await _refreshHistory();
    } catch (e) {
      logger.severe("Failed to process download: $e");
    } finally {}
  }

  /// Mark an episode key as "preparing" (fetching watch URL before download).
  void startPreparing(String key) {
    state.whenData((currentState) {
      state = AsyncData(
        currentState.copyWith(
          preparingKeys: {...currentState.preparingKeys, key},
        ),
      );
    });
  }

  /// Mark an episode key as no longer preparing.
  void finishPreparing(String key) {
    state.whenData((currentState) {
      final updated = {...currentState.preparingKeys}..remove(key);
      state = AsyncData(currentState.copyWith(preparingKeys: updated));
    });
  }

  Future<void> sendAction(
    BuildContext context,
    String id,
    proto.DownloadAction action,
  ) async {
    final taskId = int.tryParse(id);
    if (taskId == null) return;

    try {
      switch (action) {
        case proto.DownloadAction.PAUSE:
          await MiruGrpcClient.downloadClient.pauseDownload(
            proto.PauseDownloadRequest()..taskId = taskId,
          );
        case proto.DownloadAction.RESUME:
          await MiruGrpcClient.downloadClient.resumeDownload(
            proto.ResumeDownloadRequest()..taskId = taskId,
          );
        case proto.DownloadAction.CANCEL:
          await MiruGrpcClient.downloadClient.cancelDownload(
            proto.CancelDownloadRequest()..taskId = taskId,
          );
      }
    } catch (e) {
      if (!context.mounted) return;
      showSimpleToast('Failed to ${action.name} download: $e');
    }
  }
}
