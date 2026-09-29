import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;

class DownloadUtils {
  static String filter(String path) {
    return path.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '').trim();
  }

  /// Maps a content category to its top-level folder name under the download
  /// root, matching the user-facing labels (Bangumi / Manga / Fikushon).
  static const Map<proto.DownloadCategory, String> _categoryFolderName = {
    proto.DownloadCategory.video: 'Bangumi',
    proto.DownloadCategory.manga: 'Manga',
    proto.DownloadCategory.novel: 'Fikushon',
    proto.DownloadCategory.unspecified: 'Other',
  };

  /// Returns the sanitized top-level folder name for [category].
  static String categoryFolder(proto.DownloadCategory category) =>
      _categoryFolderName[category] ?? 'Other';

  /// Builds the on-disk path for a completed download following the layout:
  /// `$root/<Category>/<package>/<title>/<epGroup>/<epName><ext>`.
  ///
  /// [epGroup] is optional; when empty it is omitted so the episode file sits
  /// directly under the title folder. Every produced segment is sanitized via
  /// [filter] so it is a safe, filesystem-friendly name.
  static String buildTargetPath({
    required String root,
    required proto.DownloadCategory category,
    required String package,
    required String title,
    String? epGroup,
    required String epKey,
    required String extension,
  }) {
    final parts = <String>[
      root,
      categoryFolder(category),
      filter(package),
      filter(title),
    ];
    if (epGroup != null && epGroup.trim().isNotEmpty) {
      parts.add(filter(epGroup));
    }
    final epName = filter(epKey).isNotEmpty ? filter(epKey) : 'episode';
    parts.add('$epName$extension');
    return p.joinAll(parts);
  }

  /// Deletes [path], which may be a regular file or a directory (recursively).
  /// Safe to call on a missing path. Used for best-effort cleanup of temporary
  /// download artifacts so a directory (e.g. the HLS segment folder) is not
  /// silently skipped the way [File.deleteSync] would on a directory.
  static void safeDeletePath(String path) {
    if (path.isEmpty) return;
    try {
      final type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        final dir = Directory(path);
        if (dir.existsSync()) dir.deleteSync(recursive: true);
      } else if (type == FileSystemEntityType.file) {
        final file = File(path);
        if (file.existsSync()) {
          final parent = file.parent;
          file.deleteSync();
          // Remove the parent only if it is now empty.
          if (parent.existsSync() && parent.listSync().isEmpty) {
            parent.deleteSync();
          }
        }
      }
    } catch (e) {
      logger.warning('Failed to clean up temp path $path: $e');
    }
  }

  /// Whether [path] points at something that still exists on disk.
  ///
  /// Used to tell a genuinely missing file apart from a record whose path was
  /// never filled in, so the UI can offer the right delete options.
  static bool existsOnDisk(String path) {
    if (path.isEmpty) return false;
    try {
      return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
    } catch (e) {
      logger.warning('Failed to stat $path: $e');
      return false;
    }
  }

  /// Deletes the on-disk artifact of a finished download at [savePath].
  ///
  /// Unlike [safeDeletePath] this reports the outcome, because the caller must
  /// not drop the backend record when the file is still there — that would
  /// orphan bytes the user can no longer reach from the app. Returns `true`
  /// only when something was actually removed.
  static Future<bool> deleteSavedFile(String savePath) async {
    if (savePath.isEmpty) return false;
    try {
      final type = FileSystemEntity.typeSync(savePath);
      if (type == FileSystemEntityType.directory) {
        await Directory(savePath).delete(recursive: true);
      } else if (type == FileSystemEntityType.file) {
        await File(savePath).delete();
      } else {
        return false;
      }
      return true;
    } catch (e) {
      logger.warning('Failed to delete download file $savePath: $e');
      return false;
    }
  }

  /// Verifies the HLS segment list is complete before FFmpeg conversion.
  ///
  /// Returns a failure reason when segments are missing, truncated, or
  /// fewer than the backend's [total] were recorded; returns null when the
  /// list is safe to convert. Without this check a short-but-consistent
  /// segment list would "succeed" and mark a truncated video COMPLETED.
  static Future<String?> validateHlsSegments(
    List<String> segments,
    int total,
  ) async {
    if (segments.isEmpty) return 'no segment files found for conversion';
    if (total > 0 && segments.length < total) {
      return 'missing segments: ${segments.length}/$total present on disk';
    }
    for (final segment in segments) {
      final file = File(segment);
      if (!await file.exists()) return 'segment missing on disk: $segment';
      if (await file.length() == 0) return 'segment is empty: $segment';
    }
    return null;
  }

  static Future<void> processHLS({
    required String taskId,
    required List<String> segments,
    required String targetPath,
    required String title,
  }) async {
    logger.info("Converting HLS segments to MP4: $targetPath");

    // Off the UI isolate: a 100+ segment merge takes seconds and a frozen
    // tile invites cancel taps that race this method's cleanup.
    await FFMpegUtils.combineToMp4Async(segments, targetPath);

    // The status update MUST succeed before we delete the source segments.
    // If this call fails and we proceed to delete, the DB stays "Converting"
    // while segments are gone — on restart the task would be stuck at
    // "Paused with zero progress" because Init() cannot recover it.
    await updateStatusOrThrow(
      taskId: taskId,
      status: proto.DownloadStatus.COMPLETED,
      savePath: targetPath,
    );

    // Only remove segments after the backend confirmed the Completed status.
    // The backend writes every segment into a single folder, so drop the
    // whole directory in one shot instead of deleting file by file.
    // Best-effort: a concurrent cancel (backend RemoveAll) may have removed
    // it already — "not found" is the desired end state. Any error must NOT
    // propagate: the task is genuinely complete and a throw here would flip
    // COMPLETED to FAILED in the caller's catch block.
    if (segments.isNotEmpty) {
      final dirPath = p.dirname(segments.first);
      try {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } on PathNotFoundException {
        // Already gone — cleanup goal achieved.
      } catch (e) {
        logger.warning('Failed to remove segment directory $dirPath: $e');
      }
    }
  }

  static Future<String> handleFile({
    required String taskId,
    required String currentPath,
    required String targetDir,
    required bool isHls,
    required String title,
    required proto.DownloadCategory category,
    required String package,
    required String epKey,
    String? epGroup,
  }) async {
    if (targetDir.isEmpty) {
      throw Exception("Target directory is not set");
    }

    String extension = isHls ? ".mp4" : p.extension(currentPath);
    if (extension.isEmpty && !isHls) extension = ".mp4";

    final targetPath = buildTargetPath(
      root: targetDir,
      category: category,
      package: package,
      title: title,
      epGroup: epGroup,
      epKey: epKey,
      extension: extension,
    );

    // Ensure the (possibly nested) parent directory exists.
    final parent = Directory(p.dirname(targetPath));
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    return targetPath;
  }

  static Future<void> updateStatus({
    required String taskId,
    required proto.DownloadStatus status,
    String? savePath,
    String? error,
  }) async {
    try {
      await updateStatusOrThrow(
        taskId: taskId,
        status: status,
        savePath: savePath,
        error: error,
      );
    } catch (e) {
      logger.severe("Failed to update status to $status: $e");
    }
  }

  /// Like [updateStatus] but propagates errors instead of swallowing them.
  /// Use this when the caller MUST know whether the update succeeded (e.g.
  /// before deleting source segments after FFmpeg conversion).
  static Future<void> updateStatusOrThrow({
    required String taskId,
    required proto.DownloadStatus status,
    String? savePath,
    String? error,
  }) async {
    await MiruGrpcClient.downloadClient.updateDownloadStatus(
      proto.UpdateDownloadStatusRequest(
        taskId: int.parse(taskId),
        status: status,
        savePath: savePath,
        error: error,
      ),
    );
  }

  static Future<String> processFinishedDownload({
    required String taskId,
    required List<String> segments,
    required String currentPath,
    required String targetDir,
    required bool isHls,
    required String title,
    required proto.DownloadCategory category,
    required String package,
    required String epKey,
    String? epGroup,
  }) async {
    try {
      final targetPath = await handleFile(
        taskId: taskId,
        currentPath: currentPath,
        targetDir: targetDir,
        isHls: isHls,
        title: title,
        category: category,
        package: package,
        epKey: epKey,
        epGroup: epGroup,
      );

      if (isHls) {
        await processHLS(
          taskId: taskId,
          segments: segments,
          targetPath: targetPath,
          title: title,
        );
      } else {
        logger.info("Moving file to host: $currentPath -> $targetPath");
        final sourceFile = File(currentPath);
        if (!await sourceFile.exists()) {
          // The downloaded file vanished — reporting COMPLETED here would
          // hide a real failure behind a missing output file.
          throw Exception("downloaded file missing: $currentPath");
        }
        await sourceFile.copy(targetPath);
        // Best-effort cleanup: the copy already succeeded, so a failing
        // delete (raced removal, permissions) must not flip the task to
        // FAILED via the caller's catch block.
        try {
          await sourceFile.delete();
          final dir = sourceFile.parent;
          if (await dir.exists() && (await dir.list().isEmpty)) {
            await dir.delete();
          }
        } catch (e) {
          logger.warning('Failed to clean up $currentPath: $e');
        }

        await updateStatusOrThrow(
          taskId: taskId,
          status: proto.DownloadStatus.COMPLETED,
          savePath: targetPath,
        );
      }

      return targetPath;
    } catch (e) {
      // Logged (and reported to the backend) by the caller in
      // DownloadNotifier._processDownload — rethrow without duplicating
      // the SEVERE entry.
      rethrow;
    }
  }

  static String statusToI18N(proto.DownloadStatus status) {
    switch (status) {
      case proto.DownloadStatus.QUEUED:
        return 'download.status.queued';
      case proto.DownloadStatus.DOWNLOADING:
        return 'download.status.downloading';
      case proto.DownloadStatus.PAUSED:
        return 'download.status.paused';
      case proto.DownloadStatus.COMPLETED:
        return 'download.status.completed';
      case proto.DownloadStatus.FAILED:
        return 'download.status.failed';
      case proto.DownloadStatus.CANCELLED:
        return 'download.status.cancelled';
      case proto.DownloadStatus.CONVERTING:
        return 'download.status.converting';
      default:
        return 'download.status.unknown';
    }
  }
}
