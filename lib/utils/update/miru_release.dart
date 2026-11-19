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
/// The release job attaches one APK per ABI (`app-arm64-v8a-release.apk`,
/// `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`) and one archive
/// per desktop OS (`Miru-Alpha-windows.zip`, `Miru-Alpha-linux.tar.gz`).
///
/// Android is matched against the ABIs the *device* reports
/// (`Build.SUPPORTED_ABIS`, most preferred first) rather than a hardcoded
/// order: a 32-bit-only phone handed the arm64 APK fails to install with
/// `INSTALL_FAILED_NO_MATCHING_ABIS`, and an x86_64 device cannot run either
/// ARM build. An empty [androidAbis] degrades to arm64, then a `universal`
/// APK, then the 32-bit ARM build, then any APK — the safest guesses when the
/// host would not say, in the order that can still install on something.
///
/// Desktop takes an *archive*, never an installer: the updater unpacks the
/// build itself, so an `.exe`/`.msi`/`.deb` would be extracted as if it were
/// the payload and then rejected for having no executable. [desktopArch]
/// (`x64`, `arm64`) breaks the tie when a release carries two architectures.
///
/// Returns null when the release carries nothing this platform can use; the
/// caller then offers the release page in a browser.
MiruReleaseAsset? pickUpdateAsset(
  List<MiruReleaseAsset> assets, {
  required UpdatePlatform platform,
  List<String> androidAbis = const [],
  String? desktopArch,
}) {
  MiruReleaseAsset? firstWhere(bool Function(MiruReleaseAsset) test) {
    for (final asset in assets) {
      if (test(asset)) return asset;
    }
    return null;
  }

  switch (platform) {
    case UpdatePlatform.android:
      bool isApk(MiruReleaseAsset a) => a.name.toLowerCase().endsWith('.apk');

      for (final abi in androidAbis) {
        final hit = firstWhere((a) => isApk(a) && _matchesAbi(a.name, abi));
        if (hit != null) return hit;
      }
      return firstWhere((a) => isApk(a) && a.name.contains('arm64-v8a')) ??
          firstWhere(
            (a) => isApk(a) && a.name.toLowerCase().contains('universal'),
          ) ??
          firstWhere((a) => isApk(a) && a.name.contains('armeabi-v7a')) ??
          firstWhere(isApk);
    case UpdatePlatform.windows:
      return _desktopArchive(assets, 'windows', desktopArch);
    case UpdatePlatform.linux:
      return _desktopArchive(assets, 'linux', desktopArch);
    case UpdatePlatform.macos:
    case UpdatePlatform.other:
      return null;
  }
}

/// The ABIs a `--split-per-abi` build names its APKs after, longest first.
const _knownAbis = ['arm64-v8a', 'armeabi-v7a', 'armeabi', 'x86_64', 'x86'];

/// Whether an asset's name identifies the given ABI.
///
/// `x86` is a prefix of `x86_64` and `armeabi` of `armeabi-v7a`, so a plain
/// substring test hands a 32-bit-only device the 64-bit build of the same
/// family — which then fails to install for want of a matching library.
bool _matchesAbi(String name, String abi) {
  if (!name.contains(abi)) return false;
  return !_knownAbis.any(
    (other) => other != abi && other.startsWith(abi) && name.contains(other),
  );
}

/// The archive a desktop platform should unpack.
///
/// Assets that are not archives are ignored even when their name matches:
/// `Miru-Alpha-linux-amd64.deb` is a package for a package manager, and
/// `Miru-Setup-windows.exe` is an installer — neither is a build this updater
/// can unpack and swap in.
MiruReleaseAsset? _desktopArchive(
  List<MiruReleaseAsset> assets,
  String os,
  String? arch,
) {
  bool isArchive(MiruReleaseAsset a) {
    final name = a.name.toLowerCase();
    return name.endsWith('.zip') ||
        name.endsWith('.tar.gz') ||
        name.endsWith('.tgz');
  }

  final candidates = assets
      .where((a) => isArchive(a) && a.name.toLowerCase().contains(os))
      .toList();
  if (candidates.isEmpty) return null;

  if (arch != null) {
    for (final candidate in candidates) {
      if (candidate.name.toLowerCase().contains(arch)) return candidate;
    }
  }
  return candidates.first;
}
