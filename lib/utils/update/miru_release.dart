import 'package:flutter/foundation.dart';

/// A downloadable file attached to a GitHub release.
class MiruReleaseAsset {
  const MiruReleaseAsset({
    required this.name,
    required this.size,
    required this.downloadUrl,
  });

  final String name;
  final int size;
  final String downloadUrl;

  factory MiruReleaseAsset.fromJson(Map<String, dynamic> json) {
    return MiruReleaseAsset(
      name: json['name'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      downloadUrl: json['browser_download_url'] as String? ?? '',
    );
  }
}

/// One GitHub release of the app.
class MiruRelease {
  const MiruRelease({
    required this.tagName,
    required this.name,
    required this.htmlUrl,
    required this.body,
    required this.publishedAt,
    required this.assets,
  });

  final String tagName;
  final String name;
  final String htmlUrl;
  final String body;
  final DateTime? publishedAt;
  final List<MiruReleaseAsset> assets;

  /// The release version with any leading `v` stripped (`v2.0.3-alpha` ->
  /// `2.0.3-alpha`).
  String get version => tagName.replaceFirst(RegExp(r'^[vV]'), '');

  factory MiruRelease.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as List<dynamic>? ?? const [];
    return MiruRelease(
      tagName: json['tag_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      body: json['body'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      assets: assets
          .whereType<Map<String, dynamic>>()
          .map(MiruReleaseAsset.fromJson)
          .where((a) => a.downloadUrl.isNotEmpty)
          .toList(),
    );
  }
}

/// The platform families Miru ships installable builds for.
enum UpdatePlatform { android, windows, linux, macos, other }

/// Test-only platform override. Null in every real build.
///
/// The updater's behaviour forks on the platform (an APK hand-over versus a
/// desktop swap), and `flutter_test` reports `android` while the host is
/// Linux — without this the desktop path could not be tested at all, and the
/// two notions of "platform" in one test run would disagree.
@visibleForTesting
UpdatePlatform? debugUpdatePlatform;

/// Resolves the platform the running build belongs to.
UpdatePlatform get currentUpdatePlatform {
  final override = debugUpdatePlatform;
  if (override != null) return override;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return UpdatePlatform.android;
    case TargetPlatform.windows:
      return UpdatePlatform.windows;
    case TargetPlatform.linux:
      return UpdatePlatform.linux;
    case TargetPlatform.macOS:
      return UpdatePlatform.macos;
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      return UpdatePlatform.other;
  }
}

/// Picks the asset a platform should install.
///
/// Android prefers the arm64 APK (every current device), then the 32-bit ARM
/// build, then whatever `.apk` is attached. Desktop picks the archive the
/// installers produce (`Miru-Alpha-linux.tar.gz`, `Miru-Alpha-windows.zip`).
/// Returns null when the release carries no asset for this platform, in which
/// case the caller falls back to the release page in a browser.
MiruReleaseAsset? pickUpdateAsset(
  List<MiruReleaseAsset> assets, {
  required UpdatePlatform platform,
}) {
  if (assets.isEmpty) return null;

  MiruReleaseAsset? firstWhere(bool Function(MiruReleaseAsset) test) {
    for (final asset in assets) {
      if (test(asset)) return asset;
    }
    return null;
  }

  switch (platform) {
    case UpdatePlatform.android:
      return firstWhere(
            (a) => a.name.endsWith('.apk') && a.name.contains('arm64-v8a'),
          ) ??
          firstWhere(
            (a) => a.name.endsWith('.apk') && a.name.contains('armeabi-v7a'),
          ) ??
          firstWhere((a) => a.name.endsWith('.apk'));
    case UpdatePlatform.windows:
      return firstWhere((a) => a.name.toLowerCase().contains('windows')) ??
          firstWhere((a) => a.name.endsWith('.zip'));
    case UpdatePlatform.linux:
      return firstWhere((a) => a.name.toLowerCase().contains('linux')) ??
          firstWhere((a) => a.name.endsWith('.deb'));
    case UpdatePlatform.macos:
    case UpdatePlatform.other:
      return null;
  }
}
