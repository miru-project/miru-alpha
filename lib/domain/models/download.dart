import 'package:freezed_annotation/freezed_annotation.dart';

part 'download.freezed.dart';
part 'download.g.dart';

@freezed
abstract class DomainDownload with _$DomainDownload {
  const factory DomainDownload({
    required String id,
    required String package,
    required String detailUrl,
    required String title,
    required String episode,
    String? cover,
    required double progress,
    required DownloadStatus status,
    required int speed,
    required int size,
    int? downloadedBytes,
    String? error,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DomainDownload;

  factory DomainDownload.fromJson(Map<String, dynamic> json) =>
      _$DomainDownloadFromJson(json);
}

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled;

  String get label {
    switch (this) {
      case DownloadStatus.pending:
        return 'Pending';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }
}

@freezed
abstract class DomainDownloadProgress with _$DomainDownloadProgress {
  const factory DomainDownloadProgress({
    required String downloadId,
    required double progress,
    required int speed,
    required int downloadedBytes,
    required int totalBytes,
    DownloadStatus? status,
    String? error,
  }) = _DomainDownloadProgress;

  factory DomainDownloadProgress.fromJson(Map<String, dynamic> json) =>
      _$DomainDownloadProgressFromJson(json);
}
