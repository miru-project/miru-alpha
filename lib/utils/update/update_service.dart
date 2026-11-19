import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:miru_alpha/utils/update/version_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Looks the running build's version up once per process.
///
/// [PackageInfo] is only available after a platform channel round-trip, so
/// every caller goes through [resolveCurrentVersion] instead of touching the
/// plugin directly — that also gives tests a seam (they pin the version).
PackageInfo? _packageInfoCache;

/// Test seam: a version that wins over the plugin.
String? _versionOverride;

/// Reads Miru's published releases from GitHub.
///
/// The call goes straight to `api.github.com` (not through the app's proxy
/// layer): a proxy is for extension media hosts, and a user behind a blocked
/// GitHub is better served by the raw failure the alert reports.
class UpdateService {
  UpdateService({Dio? client}) : _client = client ?? _defaultClient();

  /// The releases feed Miru publishes its alpha builds to.
  static const releasesApi =
      'https://api.github.com/repos/miru-project/miru-alpha/releases?per_page=10';

  final Dio _client;

  static Dio _defaultClient() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ),
    );
  }

  /// The installed build's version (`2.0.3-alpha`), or an empty string when
  /// the plugin cannot answer (tests, an unbundled run).
  static Future<String> resolveCurrentVersion() async {
    final override = _versionOverride;
    if (override != null) return override;
    final cached = _packageInfoCache;
    if (cached != null) return cached.version;
    try {
      final info = await PackageInfo.fromPlatform();
      _packageInfoCache = info;
      return info.version;
    } catch (error, stackTrace) {
      logger.warning('Package info unavailable', error, stackTrace);
      return '';
    }
  }

  /// Test seam: pins the installed version the check compares against.
  @visibleForTesting
  static void debugSetCurrentVersion(String? version) {
    _versionOverride = version;
  }

  /// Every published release, newest first.
  Future<List<MiruRelease>> fetchReleases({CancelToken? cancelToken}) async {
    final response = await _client.get<List<dynamic>>(
      releasesApi,
      cancelToken: cancelToken,
    );
    final data = response.data ?? const [];
    final releases = data
        .whereType<Map<String, dynamic>>()
        .map(MiruRelease.fromJson)
        .where((r) => r.tagName.isNotEmpty && r.version.isNotEmpty)
        .toList();

    releases.sort((a, b) {
      final byVersion = compareVersions(b.version, a.version);
      if (byVersion != 0) return byVersion;
      return (b.publishedAt ?? DateTime(0)).compareTo(
        a.publishedAt ?? DateTime(0),
      );
    });
    return releases;
  }

  /// The release a client should move to, or null when none is published.
  ///
  /// Drafts never appear in the JSON; every remaining release competes on
  /// version, not on publish order — a patch published after a beta must not
  /// win over that beta.
  Future<MiruRelease?> fetchLatestRelease({CancelToken? cancelToken}) async {
    final releases = await fetchReleases(cancelToken: cancelToken);
    return releases.isEmpty ? null : releases.first;
  }

  /// Downloads [asset] into [directory], reporting 0.0-1.0 progress.
  Future<File> downloadAsset(
    MiruReleaseAsset asset, {
    required String directory,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
  }) async {
    final dir = Directory(directory);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File(
      '$directory${Platform.pathSeparator}${asset.name.isEmpty ? 'miru-update' : asset.name}',
    );

    await _client.download(
      asset.downloadUrl,
      file.path,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total <= 0) return;
        onProgress?.call((received / total).clamp(0.0, 1.0));
      },
    );
    return file;
  }
}

/// Where downloaded installers are kept (inside the app's private support
/// directory, so the Android package installer can be handed a content:// URI
/// through the app's FileProvider).
String updateDownloadDirectory(String supportDirectory) =>
    '$supportDirectory${Platform.pathSeparator}updates';
