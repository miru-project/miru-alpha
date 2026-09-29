import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/data/repositories/download_repository.dart';
import 'package:miru_alpha/data/services/download_service.dart';
import 'package:miru_alpha/domain/models/download.dart';

part 'download_view_model.g.dart';

@riverpod
class DownloadViewModel extends _$DownloadViewModel {
  @override
  Future<List<DomainDownload>> build() async {
    final repository = DownloadRepository(DownloadService());
    return await repository.getDownloads();
  }

  Future<void> startDownload(
    String package,
    String detailUrl,
    String episode,
  ) async {
    final repository = DownloadRepository(DownloadService());
    await repository.startDownload(package, detailUrl, episode);
    ref.invalidateSelf();
  }

  Future<void> pauseDownload(String downloadId) async {
    final repository = DownloadRepository(DownloadService());
    await repository.pauseDownload(downloadId);
    ref.invalidateSelf();
  }

  Future<void> resumeDownload(String downloadId) async {
    final repository = DownloadRepository(DownloadService());
    await repository.resumeDownload(downloadId);
    ref.invalidateSelf();
  }

  Future<void> cancelDownload(String downloadId) async {
    final repository = DownloadRepository(DownloadService());
    await repository.cancelDownload(downloadId);
    ref.invalidateSelf();
  }

  Future<void> deleteDownload(String downloadId) async {
    final repository = DownloadRepository(DownloadService());
    await repository.deleteDownload(downloadId);
    ref.invalidateSelf();
  }
}
