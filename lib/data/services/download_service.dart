import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';

class DownloadService {
  Future<List<Download>> getDownloads() async {
    try {
      final response = await MiruGrpcClient.downloadClient.getAllDownloads(
        GetAllDownloadsRequest(),
      );
      return response.downloads;
    } catch (e) {
      return [];
    }
  }

  Future<void> startDownload(
    String package,
    String detailUrl,
    String episode,
  ) async {
    try {
      await MiruGrpcClient.downloadClient.download(
        DownloadRequest(package: package, detailUrl: detailUrl, key: episode),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pauseDownload(String downloadId) async {
    try {
      await MiruGrpcClient.downloadClient.pauseDownload(
        PauseDownloadRequest(taskId: int.parse(downloadId)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resumeDownload(String downloadId) async {
    try {
      await MiruGrpcClient.downloadClient.resumeDownload(
        ResumeDownloadRequest(taskId: int.parse(downloadId)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelDownload(String downloadId) async {
    try {
      await MiruGrpcClient.downloadClient.cancelDownload(
        CancelDownloadRequest(taskId: int.parse(downloadId)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDownload(
    String downloadId, {
    bool deleteFile = true,
  }) async {
    try {
      await MiruGrpcClient.downloadClient.deleteDownload(
        DeleteDownloadRequest(id: int.parse(downloadId)),
      );
    } catch (e) {
      rethrow;
    }
  }
}
