import 'dart:async';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/event_service.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/download/download_utils.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/data/repositories/download_repository.dart';
import 'package:miru_alpha/data/services/download_service.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_provider.g.dart';

class DownloadState {
  final List<proto.Download> history;
  final List<proto.DownloadProgress> active;
  final int page;
  final bool hasMore;

  /// Keys of episodes currently being fetched/resolved before download starts.
  final Set<String> preparingKeys;

  /// Per-category storage usage for the configured download path, including
  /// in-progress (temp) downloads. Null until the first stats fetch completes.
  final proto.StorageStats? storageStats;

  /// Actual on-disk size (bytes) of the configured temp download directory,
  /// computed by scanning the filesystem. This is the authoritative temp
  /// measurement for mobile (more accurate than progress-based estimates).
  final int tempStorageBytes;

  /// True while a later page of history is being fetched. Used by the
  /// paginated lists so they can show a spinner and avoid firing duplicate
  /// requests from repeated scroll notifications.
  final bool isLoadingMoreHistory;

  DownloadState({
    this.history = const [],
    this.active = const [],
    this.page = 1,
    this.hasMore = true,
    this.preparingKeys = const {},
    this.storageStats,
    this.tempStorageBytes = 0,
    this.isLoadingMoreHistory = false,
  });

  DownloadState copyWith({
    List<proto.Download>? history,
    List<proto.DownloadProgress>? active,
    int? page,
    bool? hasMore,
    Set<String>? preparingKeys,
    proto.StorageStats? storageStats,
    int? tempStorageBytes,
    bool? isLoadingMoreHistory,
  }) {
    return DownloadState(
      history: history ?? this.history,
      active: active ?? this.active,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      preparingKeys: preparingKeys ?? this.preparingKeys,
      storageStats: storageStats ?? this.storageStats,
      tempStorageBytes: tempStorageBytes ?? this.tempStorageBytes,
      isLoadingMoreHistory: isLoadingMoreHistory ?? this.isLoadingMoreHistory,
    );
  }

  /// Finished downloads only.
  ///
  /// The backend history page mixes every stored row (queued, paused, failed,
  /// cancelled), so lists that show "completed" must filter rather than render
  /// [history] verbatim.
  List<proto.Download> get completed =>
      history.where((d) => d.status == proto.DownloadStatus.COMPLETED).toList();
}

extension DownloadStatusX on proto.DownloadStatus {
  /// Whether the task is still in a pending/active state (not terminal).
  bool get isActive =>
      this == proto.DownloadStatus.DOWNLOADING ||
      this == proto.DownloadStatus.PAUSED ||
      this == proto.DownloadStatus.CONVERTING ||
      this == proto.DownloadStatus.FAILED ||
      this == proto.DownloadStatus.QUEUED;
}

/// Statuses that trigger frontend processing (e.g. FFmpeg conversion for HLS).
bool _isProcessingStatus(proto.DownloadStatus status) {
  return status == proto.DownloadStatus.CONVERTING;
}

@Riverpod(keepAlive: true)
class DownloadNotifier extends _$DownloadNotifier {
  StreamSubscription? _subscription;
  final Set<String> _processedTasks = {};

  /// User-defined task order from drag reordering. Preserved across stream
  /// updates so progress ticks never reset the visual order.
  List<int> _userOrderedTaskIds = [];

  /// When true the user is mid-drag; stream updates must not replace [active]
  /// because that would cancel the ReorderableListView gesture.
  bool _dragInProgress = false;

  Timer? _pollTimer;

  /// Tracks previous status of each task to detect status transitions.
  /// Used to detect torrent/magnet download failures.
  final Map<int, proto.DownloadStatus> _previousStatuses = {};

  @override
  AsyncValue<DownloadState> build() {
    _init();

    ref.onDispose(() {
      _subscription?.cancel();
      _pollTimer?.cancel();
    });

    return const AsyncLoading();
  }

  /// Scans the configured temp-download directory on disk and returns the
  /// total byte size of all files (recursively) — the authoritative mobile
  /// measure for in-progress download space.
  Future<int> _scanTempDownloadDirBytes() async {
    try {
      final dirPath = await MiruDirectory.getTempDownloadDirectory();
      final dir = Directory(dirPath);
      if (!await dir.exists()) return 0;
      var total = 0;
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          // A completed HLS conversion deletes its segments while this scan
          // may be mid-iteration; a file can vanish between listing it and
          // stat-ing it. Skip those instead of aborting the whole scan.
          try {
            total += await entity.length();
          } on FileSystemException {
            continue;
          }
        }
      }
      return total;
    } catch (e) {
      logger.severe('Failed to scan temp download directory: $e');
      return 0;
    }
  }

  /// Fetches per-category storage stats (incl. temp) for [downloadPath].
  /// Returns null when the path is empty or the backend call fails.
  Future<proto.StorageStats?> _fetchStorageStats(String downloadPath) async {
    if (downloadPath.isEmpty) return null;
    try {
      final repository = DownloadRepository(DownloadService());
      return await repository.getStorageStats(downloadPath);
    } catch (e) {
      return null;
    }
  }

  /// Refreshes the cached storage stats from the backend and updates state.
  Future<void> refreshStorageStats() async {
    final currentState = state.value;
    if (currentState == null) return;
    final downloadPath = MiruSettings.getSettingSync<String>(
      SettingKey.downloadPath,
    );
    final stats = await _fetchStorageStats(downloadPath);
    final tempBytes = await _scanTempDownloadDirBytes();
    final updated = currentState.copyWith(
      storageStats: stats,
      tempStorageBytes: tempBytes,
    );
    if (state.value != null) state = AsyncData(updated);
  }

  // ---------------------------------------------------------------------------
  // Drag-order helpers
  // ---------------------------------------------------------------------------

  /// Mark drag start/end so stream updates can skip list replacement.
  void setDragging(bool dragging) {
    _dragInProgress = dragging;
  }

  /// Sort [tasks] by [_userOrderedTaskIds], appending unknowns at the end.
  /// Also syncs [_userOrderedTaskIds] so completed / cancelled tasks drop out.
  List<proto.DownloadProgress> _sortActiveByOrder(
    Iterable<proto.DownloadProgress> tasks,
  ) {
    final activeTasks = tasks.where((e) => e.status.isActive).toList();
    final taskMap = {for (final t in activeTasks) t.taskId: t};
    final ordered = <proto.DownloadProgress>[];

    for (final id in _userOrderedTaskIds) {
      final task = taskMap.remove(id);
      if (task != null) ordered.add(task);
    }

    // New tasks not yet in user order → append
    ordered.addAll(taskMap.values);

    // Sync order list to current active set
    _userOrderedTaskIds = ordered.map((t) => t.taskId).toList();
    return ordered;
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

    final activeTasks = filterActive(allTasks);
    _userOrderedTaskIds = activeTasks.map((t) => t.taskId).toList();

    // Populate previous statuses to avoid showing toasts for tasks
    // that were already in a terminal state when the app started.
    for (final task in allTasks) {
      _previousStatuses[task.taskId] = task.status;
    }

    final downloadPath = MiruSettings.getSettingSync<String>(
      SettingKey.downloadPath,
    );
    final stats = await _fetchStorageStats(downloadPath);
    final tempBytes = await _scanTempDownloadDirBytes();

    state = AsyncData(
      DownloadState(
        history: historyRes.downloads,
        active: activeTasks,
        page: 1,
        hasMore: historyRes.downloads.length >= pageSize,
        storageStats: stats,
        tempStorageBytes: tempBytes,
      ),
    );

    // Process any tasks that need frontend processing (e.g. HLS conversion)
    for (final download in allTasks) {
      if (_isProcessingStatus(download.status)) {
        _processDownload(download);
      }
    }

    // Periodic poll to keep progress fresh — covers gaps where the event
    // stream misses ticks or the backend delays progress updates.
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      refreshActiveStatus();
    });
  }

  void _startStream() {
    _subscription = miruEventService.downloadStream.listen((status) {
      final allTasks = status.values;

      // Merge incoming data with the current state so that the stream never
      // regresses progress (e.g. backend re-sends a stale tick with
      // progress=0 right after the app recovers a task that already had
      // progress=50).  We keep the higher progress value as long as the
      // task's status hasn't moved to a terminal state.
      final merged = _mergeProgress(allTasks);

      // Sort by user drag order (unknown tasks appended at end).
      final sortedActive = _sortActiveByOrder(merged);

      // While the user is dragging, never replace the active list – doing so
      // rebuilds the ReorderableListView and cancels the in-flight gesture.
      // The sorted list is stored so the next non-drag update picks it up.
      if (!_dragInProgress) {
        state.whenData((currentState) {
          state = AsyncData(currentState.copyWith(active: sortedActive));
        });
      }

      // Process tasks needing frontend processing (e.g. HLS conversion)
      for (final download in merged) {
        if (_isProcessingStatus(download.status)) {
          _processDownload(download);
        }
      }

      // Detect download status transitions and show notifications
      _handleStatusTransitions(merged);
    });
  }

  /// Detects download status transitions and shows notifications.
  /// Called from the stream handler to log and show snackbar when a
  /// download fails or completes. Handles ALL media types.
  void _handleStatusTransitions(Iterable<proto.DownloadProgress> tasks) {
    for (final task in tasks) {
      final previousStatus = _previousStatuses[task.taskId];
      _previousStatuses[task.taskId] = task.status;

      // Detect transition to FAILED status
      if (task.status == proto.DownloadStatus.FAILED &&
          previousStatus != null &&
          previousStatus != proto.DownloadStatus.FAILED) {
        final urlInfo = task.url.isNotEmpty ? task.url : 'N/A';
        final errorInfo = task.error.isNotEmpty ? task.error : 'Unknown reason';
        logger.severe(
          'Download failed: ${task.title} '
          '(taskId: ${task.taskId}, mediaType: ${task.mediaType})\n'
          '  URL: $urlInfo\n'
          '  Reason: $errorInfo',
        );
        showSimpleToast(
          'download.failed_toast'.i18n.fill({
            'title': task.title,
            'reason': errorInfo,
          }),
        );
        // Clean up temporary files for failed download
        _cleanupTempFiles(task);
      }

      // Detect transition to COMPLETED status
      if (task.status == proto.DownloadStatus.COMPLETED &&
          previousStatus != null &&
          previousStatus != proto.DownloadStatus.COMPLETED) {
        logger.info(
          'Download completed: ${task.title} '
          '(taskId: ${task.taskId}, mediaType: ${task.mediaType})',
        );
        showSimpleToast(
          'download.finished_toast'.i18n.fill({'title': task.title}),
        );
        // Note: For completed downloads, the temp files should have been cleaned
        // up by the processing logic (e.g., HLS conversion). We do not clean up
        // here to avoid race conditions, but we rely on the processing logic.
      }

      // Detect transition to CANCELLED status
      if (task.status == proto.DownloadStatus.CANCELLED &&
          previousStatus != null &&
          previousStatus != proto.DownloadStatus.CANCELLED) {
        logger.info(
          'Download cancelled: ${task.title} '
          '(taskId: ${task.taskId}, mediaType: ${task.mediaType})',
        );
        // Clean up temporary files for cancelled download
        _cleanupTempFiles(task);
      }
    }

    // Clean up entries for tasks no longer in active list
    final activeIds = tasks.map((t) => t.taskId).toSet();
    _previousStatuses.keys
        .where((id) => !activeIds.contains(id))
        .toList()
        .forEach(_previousStatuses.remove);
  }

  /// Cleans up temporary files associated with a download.
  /// For HLS tasks this removes the whole segment folder in one recursive
  /// delete (the backend keeps every segment of a task in a single dir);
  /// for single-file downloads it removes the file and its emptied parent.
  void _cleanupTempFiles(proto.DownloadProgress download) {
    if (download.mediaType == proto.DownloadMediaType.hls) {
      final dirPath = download.names.isNotEmpty
          ? p.dirname(download.names.first)
          : (download.currentDownloading.isNotEmpty
                ? p.dirname(download.currentDownloading)
                : '');
      if (dirPath.isNotEmpty) {
        DownloadUtils.safeDeletePath(dirPath);
      }
      return;
    }
    // currentDownloading is the single downloaded file for direct/mp4 and
    // torrent tasks; safeDeletePath also prunes the emptied parent dir.
    if (download.currentDownloading.isNotEmpty) {
      DownloadUtils.safeDeletePath(download.currentDownloading);
    }
  }

  /// Merge [incoming] tasks with the current active state, keeping the higher
  /// [DownloadProgress.progress] value when the status hasn't changed. This
  /// prevents the event stream from resetting visible progress to 0 when the
  /// backend re-emits a stale snapshot (e.g. right after app restart).
  Iterable<proto.DownloadProgress> _mergeProgress(
    Iterable<proto.DownloadProgress> incoming,
  ) {
    final currentState = state.value;
    if (currentState == null) return incoming;

    // Build a taskId → existing task lookup.
    final existingMap = <int, proto.DownloadProgress>{};
    for (final t in currentState.active) {
      existingMap[t.taskId] = t;
    }

    return incoming.map((newTask) {
      final existing = existingMap[newTask.taskId];
      if (existing == null) return newTask;

      // If the status is unchanged and the incoming progress is lower,
      // keep the existing (higher) progress value so the UI never regresses.
      if (existing.progress > newTask.progress &&
          existing.status == newTask.status) {
        // Return a copy with the higher progress.
        return proto.DownloadProgress()
          ..mergeFromMessage(newTask)
          ..progress = existing.progress;
      }
      return newTask;
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
          isLoadingMoreHistory: false,
        ),
      );
    } catch (e) {
      logger.severe("Failed to refresh history: $e");
    }
  }

  /// Fetches the next page of download history and appends it.
  ///
  /// Re-entrant calls are ignored while a page is in flight: scroll-end
  /// notifications fire repeatedly, and without the guard every tick would
  /// request the same page and duplicate rows.
  Future<void> loadMoreHistory() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMoreHistory) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMoreHistory: true));
    try {
      const pageSize = 20;
      final nextPage = currentState.page + 1;
      final res = await MiruGrpcClient.downloadClient.getAllDownloads(
        proto.GetAllDownloadsRequest()
          ..page = nextPage
          ..pageSize = pageSize,
      );

      // Re-read: a stream tick or a delete may have replaced the state while
      // this request was in flight, so `currentState` can be stale.
      final latest = state.value;
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          history: [...latest.history, ...res.downloads],
          page: nextPage,
          hasMore: res.downloads.length >= pageSize,
          isLoadingMoreHistory: false,
        ),
      );
    } catch (e) {
      logger.severe("Failed to load more history: $e");
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(isLoadingMoreHistory: false));
      }
    }
  }

  /// Removes [download] from the history.
  ///
  /// The backend `DeleteDownload` RPC only drops its database row (plus any
  /// torrent session) — it never touches files on disk. When [deleteFile] is
  /// set, the artifact is removed here first, and the record is kept if that
  /// fails so a file can not be orphaned without an entry pointing at it.
  ///
  /// Returns `true` when the record was removed.
  Future<bool> removeHistoryEntry(
    proto.Download download, {
    required bool deleteFile,
  }) async {
    if (deleteFile) {
      final removed = await DownloadUtils.deleteSavedFile(download.savePath);
      if (!removed) {
        showSimpleToast(
          'download.delete_file_failed'.i18n.fill({'title': download.title}),
        );
        return false;
      }
    }

    try {
      await MiruGrpcClient.downloadClient.deleteDownload(
        proto.DeleteDownloadRequest()..id = download.id,
      );
    } catch (e) {
      logger.severe('Failed to delete download record ${download.id}: $e');
      showSimpleToast(
        'download.delete_record_failed'.i18n.fill({'title': download.title}),
      );
      return false;
    }

    await _refreshHistory();
    return true;
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
    // Reserve synchronously: the stream keeps emitting CONVERTING ticks
    // until the frontend's terminal update lands, and every await below
    // (segment discovery, validation) is a window where a second tick
    // could otherwise pass the contains-check and start a duplicate merge
    // that races the first one's folder cleanup. The catch block releases
    // the reservation so a failed attempt can still be retried.
    if (!_processedTasks.add(key)) return;

    try {
      final downloadPath = MiruSettings.getSettingSync<String>(
        SettingKey.downloadPath,
      );
      if (downloadPath.isEmpty) {
        logger.warning(
          "Download path not set, skipping processing for ${download.title}",
        );
        // Release the reservation so the task is retried once the user
        // configures a download path.
        _processedTasks.remove(key);
        return;
      }

      // Only HLS downloads need FFmpeg conversion on the frontend
      final isHls = download.mediaType == proto.DownloadMediaType.hls;

      // If names is empty but this is an HLS task, try to rebuild the
      // segment list from the segment directory on disk.  After a backend
      // restart, the Names field is not persisted in the DB, so the
      // frontend receives an empty list.  The segments are still in the
      // savePath directory and can be discovered by scanning for files
      // whose base name is a number (e.g. 0.ts, 1.ts).
      List<String> segments = download.names;
      if (isHls && segments.isEmpty && download.currentDownloading.isNotEmpty) {
        segments = await discoverHlsSegments(download.currentDownloading);
        if (segments.isEmpty) {
          logger.warning(
            "HLS conversion: no segment files found in "
            '${download.currentDownloading}',
          );
        }
      }

      // Guard against converting an incomplete segment list: a short but
      // self-consistent list would "succeed" and mark a truncated video
      // COMPLETED. Fail loudly instead so the user can resume/retry.
      if (isHls) {
        final problem = await DownloadUtils.validateHlsSegments(
          segments,
          download.total,
        );
        if (problem != null) {
          throw Exception(problem);
        }
      }

      await DownloadUtils.processFinishedDownload(
        taskId: download.taskId.toString(),
        segments: segments,
        currentPath: download.currentDownloading,
        targetDir: downloadPath,
        isHls: isHls,
        title: download.title,
        category: download.category,
        package: download.package,
        epKey: download.key,
      );

      showSimpleToast(
        'download.finished_toast'.i18n.fill({'title': download.title}),
      );

      await _refreshHistory();
    } catch (e) {
      logger.severe("Failed to process download: $e");
      // Surface a user-visible error toast so a failed FFmpeg conversion is
      // not silent (previously the process crashed before this point).
      showSimpleToast(
        'download.convert_failed'.i18n.fill({'title': download.title}),
      );
      // Report the failure (with reason) to the backend so the task moves
      // to FAILED instead of being stuck in CONVERTING forever. Propagate
      // reporting errors to the log — if this gRPC call fails the backend
      // stays CONVERTING and the next stream tick will retry the whole
      // flow, which is the intended recovery path.
      try {
        await DownloadUtils.updateStatusOrThrow(
          taskId: download.taskId.toString(),
          status: proto.DownloadStatus.FAILED,
          error: '$e',
        );
      } catch (reportError) {
        logger.severe(
          "Failed to report FAILED for task ${download.taskId}: $reportError",
        );
      }
      // Optimistically update local state too.
      _optimisticallyUpdateStatus(download.taskId, proto.DownloadStatus.FAILED);
      // Remove from _processedTasks so the user can retry by hitting Resume.
      _processedTasks.remove(key);
    }
  }

  /// Scan a segment directory and return sorted absolute paths of segment
  /// files whose base name is a number (e.g. 0.ts, 1.ts).  Returns an empty
  /// list if the directory doesn't exist or has no segments.
  static Future<List<String>> discoverHlsSegments(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return [];

      final segments = <MapEntry<int, String>>[];
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final name = p.basename(entity.path);
        // Strip extension and check if the base is a number.
        final dotIndex = name.lastIndexOf('.');
        final base = dotIndex > 0 ? name.substring(0, dotIndex) : name;
        final index = int.tryParse(base);
        if (index != null) {
          segments.add(MapEntry(index, entity.path));
        }
      }

      // Sort by numeric index for correct FFmpeg concatenation order.
      segments.sort((a, b) => a.key.compareTo(b.key));
      return segments.map((e) => e.value).toList();
    } catch (e) {
      logger.warning("Failed to discover HLS segments: $e");
      return [];
    }
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

  /// Returns the configured max concurrent download count (read from settings,
  /// which mirrors what the backend scheduler uses).
  int get maxConcurrent {
    return MiruSettings.getSettingSync<int>(SettingKey.downloadConcurrent);
  }

  /// Persists and pushes the max concurrent download count to the backend so
  /// the scheduler cap updates immediately.
  Future<void> setMaxConcurrent(int value) async {
    final n = value.clamp(1, 32);
    MiruSettings.setSettingSync(SettingKey.downloadConcurrent, n.toString());
    try {
      await MiruGrpcClient.downloadClient.setDownloadConcurrent(
        proto.SetDownloadConcurrentRequest()..maxConcurrent = n,
      );
    } catch (e) {
      logger.severe('Failed to set max concurrent downloads: $e');
    }
  }

  /// Sends a new desired order for the active tasks to the backend, which
  /// reassigns priorities (front = highest) and re-runs the scheduler.
  Future<void> reorderActive(List<int> orderedTaskIds) async {
    // Preserve locally so the next stream tick maintains this order.
    _userOrderedTaskIds = orderedTaskIds;
    try {
      await MiruGrpcClient.downloadClient.reorderDownloads(
        proto.ReorderDownloadsRequest()..orderedTaskIds.addAll(orderedTaskIds),
      );
    } catch (e) {
      logger.severe('Failed to reorder downloads: $e');
    }
  }

  /// Reorders [filtered] and maps the result back onto the full [full] task
  /// order, so dragging inside a category tab never reshuffles the tasks that
  /// tab is not showing.
  ///
  /// The backend takes one global priority list, which is why the splice has
  /// to happen here rather than sending the visible subset on its own.
  ///
  /// [oldIndex] and [newIndex] follow `SliverReorderableList.onReorderItem`
  /// semantics: [newIndex] is already adjusted for the removed item.
  static List<int> globalOrderAfterReorder({
    required List<proto.DownloadProgress> full,
    required List<proto.DownloadProgress> filtered,
    required int oldIndex,
    required int newIndex,
  }) {
    if (filtered.isEmpty) return const [];

    final moved = List<proto.DownloadProgress>.from(filtered);
    final from = oldIndex.clamp(0, moved.length - 1);
    final dragged = moved.removeAt(from);
    moved.insert(newIndex.clamp(0, moved.length), dragged);

    final visibleIds = filtered.map((t) => t.taskId).toSet();
    final movedIds = moved.map((t) => t.taskId).toList();
    final originalIds = full.map((t) => t.taskId).toList();

    // Splice from a snapshot of the original ids: overwriting in place would
    // otherwise let an already-moved id be re-matched as still "visible".
    final result = List<int>.from(originalIds);
    var slot = 0;
    for (var i = 0; i < originalIds.length; i++) {
      if (visibleIds.contains(originalIds[i])) {
        result[i] = movedIds[slot++];
      }
    }
    return result;
  }

  /// Sets the priority of a single active task and re-runs the scheduler.
  Future<void> setDownloadPriority(int taskId, int priority) async {
    try {
      await MiruGrpcClient.downloadClient.setDownloadPriority(
        proto.SetDownloadPriorityRequest()
          ..taskId = taskId
          ..priority = priority,
      );
    } catch (e) {
      logger.severe('Failed to set download priority: $e');
    }
  }

  /// Whether the download file at [savePath] still exists on disk. An empty
  /// path is treated as existing so we never hide entries without a known path.
  static Future<bool> downloadFileExists(String? savePath) async {
    if (savePath == null || savePath.isEmpty) return true;
    try {
      return await File(savePath).exists();
    } catch (_) {
      return true;
    }
  }

  /// Returns true if the file at [savePath] exists **and** has at least one
  /// byte. An empty or missing file indicates the download did not actually
  /// persist any data (e.g. backend was killed mid-stream).
  static Future<bool> downloadFileHasContent(String? savePath) async {
    if (savePath == null || savePath.isEmpty) return true;
    try {
      final file = File(savePath);
      if (!await file.exists()) return false;
      return (await file.length()) > 0;
    } catch (_) {
      return true;
    }
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
          _optimisticallyUpdateStatus(taskId, proto.DownloadStatus.PAUSED);
        case proto.DownloadAction.RESUME:
          await MiruGrpcClient.downloadClient.resumeDownload(
            proto.ResumeDownloadRequest()..taskId = taskId,
          );
          // Clear processed-tasks entry so a failed Converting task can be
          // retried (e.g. when user resumes after FFmpeg failure).
          final task = state.value?.active.where((t) => t.taskId == taskId);
          if (task != null && task.isNotEmpty) {
            _processedTasks.remove(task.first.key);
          }
          _optimisticallyUpdateStatus(taskId, proto.DownloadStatus.DOWNLOADING);
          // Refresh from backend after short delay to confirm real state.
          Future.delayed(const Duration(seconds: 1), refreshActiveStatus);
          Future.delayed(const Duration(seconds: 3), refreshActiveStatus);
        case proto.DownloadAction.CANCEL:
          // Capture the task before the backend drops it, so we can clean up
          // its temporary files even if the status-transition stream never
          // delivers a terminal event for it.
          final task = state.value?.active.where((t) => t.taskId == taskId);
          await MiruGrpcClient.downloadClient.cancelDownload(
            proto.CancelDownloadRequest()..taskId = taskId,
          );
          if (task != null && task.isNotEmpty) {
            _cleanupTempFiles(task.first);
          }
          // Remove cancelled task from active list.
          state.whenData((currentState) {
            state = AsyncData(
              currentState.copyWith(
                active: currentState.active
                    .where((t) => t.taskId != taskId)
                    .toList(),
              ),
            );
          });
      }
    } catch (e) {
      if (!context.mounted) return;
      showSimpleToast('Failed to ${action.name} download: $e');
    }
  }

  /// Immediately update a task's status in local state so the UI reflects the
  /// action without waiting for the next backend event tick.
  void _optimisticallyUpdateStatus(int taskId, proto.DownloadStatus newStatus) {
    state.whenData((currentState) {
      final updatedActive = currentState.active.map((task) {
        if (task.taskId == taskId) {
          // Create a copy to avoid mutating the original protobuf message,
          // which could corrupt shared references held by the event stream.
          return proto.DownloadProgress()
            ..mergeFromMessage(task)
            ..status = newStatus;
        }
        return task;
      }).toList();
      state = AsyncData(currentState.copyWith(active: updatedActive));
    });
  }

  /// Re-fetch active download status from the backend. Used after resume to
  /// pick up the real state the backend settled on (handles cases where the
  /// event stream is delayed or the backend re-queued the task).
  Future<void> refreshActiveStatus() async {
    try {
      final statusRes = await MiruGrpcClient.downloadClient.getDownloadStatus(
        proto.GetDownloadStatusRequest(),
      );
      final allTasks = statusRes.downloadStatus.values;
      // Merge so the poll never regresses progress either.
      final merged = _mergeProgress(allTasks);
      final sortedActive = _sortActiveByOrder(merged);
      state.whenData((currentState) {
        state = AsyncData(currentState.copyWith(active: sortedActive));
      });

      // Detect status transitions from poll as well, so
      // failure/completion toasts fire even when the event stream misses ticks.
      _handleStatusTransitions(merged);
      // Storage footprint may have changed (temp -> completed file).
      refreshStorageStats();
    } catch (e) {
      // Silently ignore — the event stream will eventually catch up.
    }
  }
}
