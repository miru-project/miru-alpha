import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';

/// One asset per line: `name|url`.
MiruReleaseAsset _asset(String name) =>
    MiruReleaseAsset(name: name, size: 1, downloadUrl: 'https://e.test/$name');

/// The three APKs CI publishes, plus the desktop archives a release carries.
List<MiruReleaseAsset> get _feed => [
  _asset('app-armeabi-v7a-release.apk'),
  _asset('app-arm64-v8a-release.apk'),
  _asset('app-x86_64-release.apk'),
  _asset('Miru-Alpha-windows.zip'),
  _asset('Miru-Alpha-linux.tar.gz'),
];

void main() {
  group('Android picks the APK the device can actually install', () {
    test('prefers the device\'s own ABI order over a hardcoded one', () {
      // A 64-bit ARM phone reports arm64 first, then the 32-bit ARM ABIs.
      final asset = pickUpdateAsset(
        _feed,
        platform: UpdatePlatform.android,
        androidAbis: ['arm64-v8a', 'armeabi-v7a', 'armeabi'],
      );
      expect(asset?.name, 'app-arm64-v8a-release.apk');
    });

    test('hands an x86_64 device the x86_64 build, not an ARM one', () {
      // Emulators and a few Chromebooks: either ARM APK would refuse to
      // install here, which is the bug this ordering exists to prevent.
      final asset = pickUpdateAsset(
        _feed,
        platform: UpdatePlatform.android,
        androidAbis: ['x86_64', 'x86'],
      );
      expect(asset?.name, 'app-x86_64-release.apk');
    });

    test('survives a 32-bit-only device', () {
      final asset = pickUpdateAsset(
        _feed,
        platform: UpdatePlatform.android,
        androidAbis: ['armeabi-v7a', 'armeabi'],
      );
      expect(asset?.name, 'app-armeabi-v7a-release.apk');
    });

    test('a 32-bit x86 device is not given the x86_64 build', () {
      // `x86` is a prefix of `x86_64`, so a substring test would hand this
      // device an APK it cannot install.
      final asset = pickUpdateAsset(
        _feed,
        platform: UpdatePlatform.android,
        androidAbis: ['x86'],
      );
      expect(asset?.name, isNot('app-x86_64-release.apk'));
    });

    test('an unknown ABI order still lands on a 64-bit build', () {
      // The device would not answer (older app, shim missing): arm64 is the
      // right guess for anything from the last decade.
      final asset = pickUpdateAsset(_feed, platform: UpdatePlatform.android);
      expect(asset?.name, 'app-arm64-v8a-release.apk');
    });

    test('takes a universal APK before an unrelated one', () {
      final asset = pickUpdateAsset([
        _asset('app-armeabi-v7a-release.apk'),
        _asset('miru-2.1.0-universal.apk'),
      ], platform: UpdatePlatform.android);
      expect(asset?.name, 'miru-2.1.0-universal.apk');
    });
  });

  group('Desktop only ever takes an archive it can unpack', () {
    test('Windows skips installers that carry the OS name', () {
      // The updater unpacks the build itself; `tar` would read the .exe as
      // the payload and then fail the "has an executable" check.
      final asset = pickUpdateAsset([
        _asset('Miru-Setup-2.1.0-windows.exe'),
        _asset('Miru-Alpha-windows.msi'),
        _asset('Miru-Alpha-windows.zip'),
      ], platform: UpdatePlatform.windows);
      expect(asset?.name, 'Miru-Alpha-windows.zip');
    });

    test('Linux skips packages meant for a package manager', () {
      final asset = pickUpdateAsset([
        _asset('miru-alpha_2.1.0_amd64.deb'),
        _asset('Miru-Alpha-linux.tar.gz'),
      ], platform: UpdatePlatform.linux);
      expect(asset?.name, 'Miru-Alpha-linux.tar.gz');
    });

    test(
      'a release with no archive for this OS offers the browser instead',
      () {
        expect(
          pickUpdateAsset(_feed, platform: UpdatePlatform.windows) != null,
          isTrue,
        );
        expect(
          pickUpdateAsset([
            _asset('Miru-Alpha-windows.zip'),
          ], platform: UpdatePlatform.linux),
          isNull,
        );
      },
    );

    test('breaks an architecture tie with the host arch', () {
      final feed = [
        _asset('Miru-Alpha-linux-x64.tar.gz'),
        _asset('Miru-Alpha-linux-arm64.tar.gz'),
      ];
      expect(
        pickUpdateAsset(
          feed,
          platform: UpdatePlatform.linux,
          desktopArch: 'arm64',
        )?.name,
        'Miru-Alpha-linux-arm64.tar.gz',
      );
      expect(
        pickUpdateAsset(
          feed,
          platform: UpdatePlatform.linux,
          desktopArch: 'x64',
        )?.name,
        'Miru-Alpha-linux-x64.tar.gz',
      );
      // Unknown arch: the first one, which is what the old matcher did.
      expect(
        pickUpdateAsset(feed, platform: UpdatePlatform.linux)?.name,
        'Miru-Alpha-linux-x64.tar.gz',
      );
    });
  });

  test('a platform with no builds of its own gets no asset', () {
    expect(pickUpdateAsset(_feed, platform: UpdatePlatform.macos), isNull);
    expect(pickUpdateAsset([], platform: UpdatePlatform.linux), isNull);
  });
}
