import 'package:miru_alpha/data/services/download_service.dart';
import 'package:miru_alpha/domain/models/download.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/common.pbenum.dart'
    as pb;

class DownloadRepository {
  final DownloadService _downloadService;

  DownloadRepository(this._downloadService);

  Future<List<DomainDownload>> getDownloads() async {
    final downloads = await _downloadService.getDownloads();
    return downloads
        .map(
          (download) => DomainDownload(
            id: download.id.toString(),
            package: download.package,
            detailUrl: download.detailUrl,
            title: download.title,
            episode: download.key,
            cover: null,
            progress:
                (download.progress.isNotEmpty
                    ? download.progress.first.toDouble()
                    : 0.0) /
                100.0,
            status: _mapDownloadStatus(download.status),
            speed: 0,
            size: 0,
            downloadedBytes: 0,
            error: null,
            createdAt: DateTime.tryParse(download.date),
            updatedAt: null,
          ),
        )
        .toList();
  }

  Future<void> startDownload(
    String package,
    String detailUrl,
    String episode,
  ) async {
    await _downloadService.startDownload(package, detailUrl, episode);
  }

  Future<void> pauseDownload(String downloadId) async {
    await _downloadService.pauseDownload(downloadId);
  }

  Future<void> resumeDownload(String downloadId) async {
    await _downloadService.resumeDownload(downloadId);
  }

  Future<void> cancelDownload(String downloadId) async {
    await _downloadService.cancelDownload(downloadId);
  }

  Future<void> deleteDownload(
    String downloadId, {
    bool deleteFile = true,
  }) async {
    await _downloadService.deleteDownload(downloadId, deleteFile: deleteFile);
  }

  DownloadStatus _mapDownloadStatus(pb.DownloadStatus? status) {
    switch (status) {
      case pb.DownloadStatus.DOWNLOADING:
        return DownloadStatus.downloading;
      case pb.DownloadStatus.PAUSED:
        return DownloadStatus.paused;
      case pb.DownloadStatus.COMPLETED:
        return DownloadStatus.completed;
      case pb.DownloadStatus.FAILED:
        return DownloadStatus.failed;
      case pb.DownloadStatus.CANCELLED:
        return DownloadStatus.cancelled;
      case pb.DownloadStatus.QUEUED:
      case pb.DownloadStatus.CONVERTING:
      default:
        return DownloadStatus.pending;
    }
  }
}
