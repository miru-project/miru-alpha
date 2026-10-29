import 'dart:io';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/src/c_library.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

/// Result of a platform-specific FFmpeg build step.
class FFmpegBuildResult {
  final List<Uri> includes;
  final List<String> libraries;
  final List<Uri> libraryDirectories;

  FFmpegBuildResult({
    required this.includes,
    required this.libraries,
    required this.libraryDirectories,
  });
}

final logger = Logger('Miru Build');
void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      // Collect includes, libraries, and library directories from
      // platform-specific build steps.
      List<Uri> includes = [];
      List<String> libraries = [];
      List<Uri> libraryDirectories = [];
      switch (input.config.code.targetOS) {
        case OS.android:
          final androidResult = await _buildAndroid(input, output);
          includes = androidResult.includes;
          libraries = androidResult.libraries;
          libraryDirectories = androidResult.libraryDirectories;
          break;
        case OS.linux:
          final linuxResult = await _buildLinux(input, output);
          includes = linuxResult.includes;
          libraries = linuxResult.libraries;
          libraryDirectories = linuxResult.libraryDirectories;
          break;
        case OS.windows:
          final windowsResult = await _buildWindows(input, output);
          includes = windowsResult.includes;
          libraries = windowsResult.libraries;
          libraryDirectories = windowsResult.libraryDirectories;
          break;
      }

      // Build the ffmpeg_merge C++ code, linking against the bundled
      // FFmpeg shared libraries. native_toolchain_c automatically sets
      // -Wl,-rpath,$ORIGIN so the runtime linker finds FFmpeg libs
      // in the same bundle/lib directory.
      await getCLibrary(
        includes: includes.map((uri) => uri.toFilePath()).toList(),
        libraries: libraries,
        libraryDirectories: libraryDirectories
            .map((uri) => uri.toFilePath())
            .toList(),
        flags: input.config.code.targetOS == OS.windows
            // MSVC-only: the engine relies on C++ unwinding (try/catch around
            // the session-thread handshake) and native_toolchain_c never adds
            // /EHsc itself — without it MSVC skips destructor unwinding
            // (C4530). /utf-8 stops the CP932-locale C4819 misreads of the
            // SDK headers' UTF-8 comments.
            ? const ['/EHsc', '/utf-8']
            : const [],
      ).build(
        input: input,
        output: output,
        linkModePreference: LinkModePreference.dynamic,
      );

      // The C++ sources must retrigger this hook: without them the build
      // system caches the result and native edits appear to do nothing.
      output.dependencies.addAll([
        for (final f in [
          'merge.cpp',
          'dlna_stream.cpp',
          'dlna_libass.cpp',
          'common.h',
          'dlna_stream.h',
          'dlna_libass.h',
        ])
          input.packageRoot.resolve('src/ffmpeg_merge/cpp/$f'),
      ]);
    }
  });
}

Future<FFmpegBuildResult> _buildAndroid(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  // Build the Go miru_core native library (c-shared) for this ABI and register
  // it as a bundled code asset.
  await _buildMiruCore(input, output);

  final includes = <Uri>[];
  final libraryDirectories = <Uri>[];

  // arm64-v8a: avbuild 9.1 GPL (x264/x265 + MediaCodec codecs). Its archive
  // is SINGLE-ABI with the split libs directly under lib/. Every other ABI
  // keeps the 8.0 lite-lto archive, which has lib/<abi>/ split libs. Both
  // ship unversioned real files whose sonames (libavformat.so ...) collide
  // with nothing mdk/fvp bundle into the APK — unlike the old merged
  // libffmpeg.so asset, which gradle's one-file-per-name dedupe silently
  // dropped in favour of mdk's copy.
  final isArm64 = input.config.code.targetArchitecture == Architecture.arm64;
  final dirName = isArm64
      ? 'ffmpeg-9.1-android-gpl-lite'
      : 'ffmpeg-8.0-android-lite-lto';
  final ffmpegDir = input.packageRoot.resolve('.dart_tool/$dirName/');
  final archiveFile = input.packageRoot.resolve('.dart_tool/$dirName.tar.xz');

  if (!Directory.fromUri(ffmpegDir).existsSync()) {
    logger.info(
      'Downloading FFmpeg prebuilt binaries for Android ($dirName)...',
    );
    final dio = Dio();
    final downloadUrl = isArm64
        ? 'https://sourceforge.net/projects/avbuild/files/android/ffmpeg-9.1-android-gpl-lite.tar.xz/download'
        : 'https://sourceforge.net/projects/avbuild/files/android/ffmpeg-8.0-android-lite-lto.tar.xz/download';
    final response = await dio.download(
      downloadUrl,
      archiveFile.toFilePath(),
      options: Options(followRedirects: true, responseType: ResponseType.bytes),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to download FFmpeg: HTTP ${response.statusCode}');
    }

    logger.info('Extracting FFmpeg...');
    final bytes = await File(archiveFile.toFilePath()).readAsBytes();
    final tarBytes = XZDecoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(tarBytes);
    final outputDir = input.packageRoot.resolve('.dart_tool/').toFilePath();
    for (final file in archive) {
      if (file.name.isEmpty) continue;
      final filePath = p.join(outputDir, file.name);
      if (file.isFile) {
        await File(filePath).create(recursive: true);
        await File(filePath).writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }
  }
  // Re-run this hook when the archive or extraction changes.
  output.dependencies.add(archiveFile);

  // The 9.1 gpl archive is single-ABI (arm64): its libs sit directly in lib/.
  final String abiSubdir;
  switch (input.config.code.targetArchitecture) {
    case Architecture.arm64:
      abiSubdir = 'lib';
      break;
    case Architecture.arm:
      abiSubdir = 'lib/armeabi-v7a';
      break;
    case Architecture.x64:
      abiSubdir = 'lib/x86_64';
      break;
    case Architecture.ia32:
      abiSubdir = 'lib/x86';
      break;
    default:
      throw Exception(
        'Unsupported architecture: ${input.config.code.targetArchitecture}',
      );
  }

  includes.add(ffmpegDir.resolve('include/'));
  final libDir = ffmpegDir.resolve('$abiSubdir/');
  libraryDirectories.add(libDir);
  // Link the SPLIT libs. The merged libffmpeg.so would collide with mdk's
  // copy in the APK; these names never do. avfilter + swscale are REQUIRED:
  // the subtitle-burn transcode path references the filter-graph API, and a
  // merge lib with unresolved avfilter symbols would fail to load on device.
  final splitLibs = [
    'libavformat.so',
    'libavcodec.so',
    'libavutil.so',
    'libswresample.so',
    'libswscale.so',
    'libavfilter.so',
  ];

  for (final lib in splitLibs) {
    final file = libDir.resolve(lib);
    if (!File.fromUri(file).existsSync()) {
      throw Exception('FFmpeg split lib missing: $file');
    }
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: lib,
        file: file,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  }
  return FFmpegBuildResult(
    includes: includes,
    libraries: [
      'avformat',
      'avcodec',
      'avutil',
      'swresample',
      'swscale',
      'avfilter',
    ],
    libraryDirectories: libraryDirectories,
  );
}

/// Every file that affects the Go build: all `.go` sources plus the module
/// manifest.
///
/// These must be declared as hook output dependencies, otherwise the build
/// system caches the hook result indefinitely and never re-runs it, so backend
/// edits silently never reach the shipped library (the bug the old Linux CMake
/// target had with its dependency-less custom command). The scan is cheap (a
/// few hundred files, no vendor directory) next to the c-shared build it guards.
List<Uri> _goBuildInputs(Uri dir) {
  final root = Directory.fromUri(dir);
  if (!root.existsSync()) return const [];

  final inputs = <Uri>[];
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (path.endsWith('.go') ||
        path.endsWith('go.mod') ||
        path.endsWith('go.sum')) {
      inputs.add(entity.uri);
    }
  }
  return inputs;
}

/// Builds libmiru_core.so for the current target using Go's c-shared mode and
/// registers it as a bundled native code asset.
///
/// Android cross-compiles with the NDK clang toolchain; Linux uses the host C
/// compiler. Both share the same staleness check so an edit anywhere under the
/// Go module rebuilds the library — the gap that let the old Linux CMake target
/// ship a stale `.so` forever.
Future<void> _buildMiruCore(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  final arch = input.config.code.targetArchitecture;
  // Trailing slash matters: Uri.resolve treats the last segment of a
  // slash-less path as a file name and replaces it, which would resolve
  // 'go.mod' to src/miru_core/go.mod instead of inside the module.
  final goModuleDir = input.packageRoot.resolve('src/miru_core/miru-core/');

  // Without go.mod, `go` walks up to the repository root and reports a
  // confusing "cannot find main module" error that points at the Flutter
  // project instead of the missing submodule. That is exactly what CI hits
  // when `actions/checkout` runs without `submodules: true`.
  if (!File.fromUri(goModuleDir.resolve('go.mod')).existsSync()) {
    throw Exception(
      'Go module not found at $goModuleDir (go.mod is missing). The '
      'miru-core submodule is not checked out. Run '
      '`git submodule update --init --recursive`, and make sure CI uses '
      '`actions/checkout` with `submodules: true`.',
    );
  }

  final String outDirPath;
  final String ldflags;
  final Map<String, String> env;

  switch (os) {
    case OS.android:
      final sdkRoot =
          Platform.environment['ANDROID_HOME'] ?? '/home/noonecare/Android/Sdk';
      final ndkPath = _resolveNdkPath(sdkRoot);
      final toolchain = '$ndkPath/toolchains/llvm/prebuilt/linux-x86_64/bin';
      final (ccName, cxxName, goArch, abi) = _abiToolchain(arch);
      outDirPath = 'build/android/lib/$abi/';
      ldflags = '-s -w -checklinkname=0';
      env = {
        'ANDROID_HOME': sdkRoot,
        'ANDROID_SDK_ROOT': sdkRoot,
        'ANDROID_NDK_HOME': ndkPath,
        'PATH': '${Platform.environment['PATH'] ?? ''}:$toolchain',
        'CC': '$toolchain/$ccName',
        'CXX': '$toolchain/$cxxName',
        'CGO_ENABLED': '1',
        'GOOS': 'android',
        'GOARCH': goArch,
      };
    case OS.linux:
      final goArch = switch (arch) {
        Architecture.x64 => 'amd64',
        Architecture.arm64 => 'arm64',
        Architecture.ia32 => '386',
        Architecture.arm => 'arm',
        _ => throw Exception('Unsupported Linux architecture: $arch'),
      };
      outDirPath = 'build/linux/lib/$goArch/';
      ldflags = '-s -w';
      // Host C toolchain (cc/gcc) and the inherited Go environment; only the
      // cross-compile target needs to be pinned.
      env = {'CGO_ENABLED': '1', 'GOOS': 'linux', 'GOARCH': goArch};
    default:
      throw Exception('libmiru_core.so is not built for target OS: $os');
  }

  // Output into a per-target subdirectory named libmiru_core.so. The
  // native-assets bundler copies the file using its basename, so the bundled
  // library must be named exactly `libmiru_core.so` (what Dart opens via
  // DynamicLibrary.open). The subdirectory keeps the per-ABI/per-arch
  // intermediate files from overwriting each other across build-hook
  // invocations.
  final outDir = input.packageRoot.resolve(outDirPath);
  await Directory.fromUri(outDir).create(recursive: true);
  final outSo = outDir.resolve('libmiru_core.so');

  // Rebuild when any Go input is newer than the .so. Comparing only main.go
  // silently skipped every edit under pkg/, so backend fixes never reached the
  // shipped binary and the change looked like it had no effect at all.
  final soFile = File.fromUri(outSo);
  final buildInputs = _goBuildInputs(goModuleDir);
  // Declare what this hook consumed so the build system re-runs it when any of
  // those files change.
  output.dependencies.addAll(buildInputs);

  DateTime? newestChange;
  for (final uri in buildInputs) {
    final modified = File.fromUri(uri).lastModifiedSync();
    if (newestChange == null || modified.isAfter(newestChange)) {
      newestChange = modified;
    }
  }
  if (!soFile.existsSync() ||
      (newestChange != null &&
          newestChange.isAfter(soFile.lastModifiedSync()))) {
    logger.info(
      'Building libmiru_core.so for ${os.name}/$arch (Go c-shared)...',
    );
    final result = await Process.run(
      'go',
      [
        'build',
        '-tags',
        'nosqlite',
        '-buildmode=c-shared',
        '-ldflags=$ldflags',
        '-trimpath',
        '-o',
        outSo.toFilePath(),
        p.join(goModuleDir.toFilePath(), 'main.go'),
      ],
      environment: env,
      // The Go module lives in src/miru_core/miru-core; cwd must be inside it
      // so `go` can resolve go.mod and the internal `binary` package.
      workingDirectory: goModuleDir.toFilePath(),
    );
    if (result.exitCode != 0) {
      throw Exception(
        'Failed to build libmiru_core.so for ${os.name}/$arch '
        '(exit ${result.exitCode}):\n${result.stdout}\n${result.stderr}',
      );
    }
  }

  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: 'libmiru_core.so',
      file: outSo,
      linkMode: DynamicLoadingBundled(),
    ),
  );
}

/// Resolves the Android NDK directory, preferring an installed 28.x NDK so the
/// Go c-shared build matches the app's [android.app.build.gradle.kts] NDK.
/// Falls back to ANDROID_NDK_HOME, then the highest installed NDK; CI runners
/// (ubuntu-latest) preinstall 27.x/28.x/29.x under $ANDROID_HOME, so no NDK
/// download step is needed there.
String _resolveNdkPath(String sdkRoot) {
  final ndkDir = Directory('$sdkRoot/ndk');
  if (ndkDir.existsSync()) {
    final versions =
        ndkDir
            .listSync()
            .whereType<Directory>()
            .map((d) => d.path.split('/').last)
            .toList()
          ..sort();
    final v28 = versions.where((n) => n.startsWith('28.')).toList();
    if (v28.isNotEmpty) return '$sdkRoot/ndk/${v28.last}';
  }
  final fromEnv = Platform.environment['ANDROID_NDK_HOME'];
  if (fromEnv != null && Directory(fromEnv).existsSync()) return fromEnv;
  if (ndkDir.existsSync()) {
    final versions =
        ndkDir
            .listSync()
            .whereType<Directory>()
            .map((d) => d.path.split('/').last)
            .toList()
          ..sort();
    if (versions.isNotEmpty) return '$sdkRoot/ndk/${versions.last}';
  }
  throw Exception(
    'Android NDK not found. Install it via Android Studio or '
    '`sdkmanager "ndk;28.2.13676358"`, or set ANDROID_NDK_HOME.',
  );
}

/// Maps a [Architecture] to the NDK clang toolchain names, the Go [GOARCH],
/// and the Android ABI folder name.
(String, String, String, String) _abiToolchain(Architecture arch) {
  switch (arch) {
    case Architecture.arm64:
      return (
        'aarch64-linux-android21-clang',
        'aarch64-linux-android21-clang++',
        'arm64',
        'arm64-v8a',
      );
    case Architecture.arm:
      return (
        'armv7a-linux-androideabi21-clang',
        'armv7a-linux-androideabi21-clang++',
        'arm',
        'armeabi-v7a',
      );
    case Architecture.x64:
      return (
        'x86_64-linux-android21-clang',
        'x86_64-linux-android21-clang++',
        'amd64',
        'x86_64',
      );
    case Architecture.ia32:
      return (
        'i686-linux-android21-clang',
        'i686-linux-android21-clang++',
        '386',
        'x86',
      );
    default:
      throw Exception('Unsupported architecture: $arch');
  }
}

/// Linux build step — links the merge/DLNA engine against the avbuild 9.1
/// GPL split libs (x264/x265/aac embedded). Their sonames
/// (libavformat.so.63 ...) never collide with fvp's mdk-sdk libffmpeg.so.9,
/// so both ffmpeg copies coexist in one process.
Future<FFmpegBuildResult> _buildLinux(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  // Build the Go miru_core native library (c-shared) for this Linux arch and
  // register it as a bundled code asset. Replaces the old
  // src/miru_core/linux/CMakeLists.txt target, which never rebuilt the .so on
  // Go source changes because it declared no dependencies.
  await _buildMiruCore(input, output);

  final includes = <Uri>[];
  final libraries = <String>[];
  final libraryDirectories = <Uri>[];

  // Linux engine: BtbN's full GPL shared build on x64 — the ONLY prebuilt
  // shipping libass (ass/subtitles filters) TOGETHER with libx264, so the
  // subtitle-burn path gets true libass rendering. Everything (libass,
  // x264, fontconfig…) is statically linked inside the ffmpeg libs (only
  // system libc/libm in NEEDED), and the sonames never collide with fvp's
  // mdk-sdk libffmpeg.so.9. arm64 linux keeps the avbuild gpl-lite archive.
  final bool isX64 = input.config.code.targetArchitecture == Architecture.x64;
  final String dirName;
  final String downloadUrl;
  if (isX64) {
    // Keep dirName == the archive's own root so extraction lands where the
    // hook looks; the BtbN 'latest' artifact name is version-stable.
    dirName = 'ffmpeg-master-latest-linux64-gpl-shared';
    downloadUrl =
        'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/'
        'ffmpeg-master-latest-linux64-gpl-shared.tar.xz';
  } else {
    dirName = 'ffmpeg-9.1-linux-clang-gpl-lite';
    downloadUrl =
        'https://sourceforge.net/projects/avbuild/files/linux/$dirName.tar.xz/download';
  }
  final ffmpegDir = input.packageRoot.resolve('.dart_tool/$dirName/');
  final archiveFile = input.packageRoot.resolve('.dart_tool/$dirName.tar.xz');

  if (!Directory.fromUri(ffmpegDir).existsSync()) {
    logger.info('Downloading FFmpeg ($dirName) for Linux...');
    final dio = Dio();
    final response = await dio.download(
      downloadUrl,
      archiveFile.toFilePath(),
      options: Options(followRedirects: true, responseType: ResponseType.bytes),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to download FFmpeg: HTTP ${response.statusCode}');
    }

    logger.info('Extracting FFmpeg...');
    final bytes = await File(archiveFile.toFilePath()).readAsBytes();
    final tarBytes = XZDecoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(tarBytes);
    final outputDir = input.packageRoot.resolve('.dart_tool/').toFilePath();
    for (final file in archive) {
      if (file.name.isEmpty) continue;
      final filePath = p.join(outputDir, file.name);
      if (file.isFile) {
        await File(filePath).create(recursive: true);
        await File(filePath).writeAsBytes(file.content as List<int>);
      } else {
        // Symlink entries also land here as 0-byte files — the fix-up below
        // turns the ones the linker needs into real links.
        await Directory(filePath).create(recursive: true);
      }
    }
  }
  // Re-run this hook when the archive or extraction changes.
  output.dependencies.add(archiveFile);

  final String libSubdir;
  if (isX64) {
    libSubdir = 'lib'; // BtbN ships a single-arch (x64) layout
  } else {
    libSubdir = input.config.code.targetArchitecture == Architecture.arm64
        ? 'lib/arm64'
        : 'lib/amd64';
  }
  final libDir = Directory.fromUri(ffmpegDir.resolve('$libSubdir/'));
  // The transcode path (subtitle burn) additionally needs avfilter + swscale.
  final splitLibs = isX64
      ? [
          'libavformat',
          'libavcodec',
          'libavutil',
          'libswresample',
          'libswscale',
          'libavfilter',
        ]
      : _ffmpegSplitLibNames;

  // The linker resolves -lavformat via an unversioned symlink onto the real
  // versioned file; repair every split lib's entry (the extraction leaves
  // 0-byte files in their place).
  for (final name in splitLibs) {
    await _ensureSplitLibLink(libDir, name);
  }

  includes.add(ffmpegDir.resolve('include/'));
  libraryDirectories.add(libDir.uri);
  libraries.addAll(
    splitLibs.map((name) => name.replaceFirst('lib', '').toLowerCase()),
  );

  // DT_NEEDED records the soname (libavformat.so.63) but the archive's real
  // file is libavformat.so.63.16.100 and the bundler copies by file name —
  // stage a copy under the exact soname name or the runtime loader will not
  // find the bundled library.
  final stagingDir = input.packageRoot
      .resolve('.dart_tool/ffmpeg-soname-staging/')
      .toFilePath();
  await Directory(stagingDir).create(recursive: true);
  for (final name in splitLibs) {
    final real = _realSplitLibFile(libDir, name);
    final soname = p.basename(real.path).split('.').take(3).join('.');
    final staged = File(p.join(stagingDir, soname));
    if (!staged.existsSync()) {
      await real.copy(staged.path);
    }
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: soname,
        file: staged.uri,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  }

  return FFmpegBuildResult(
    includes: includes,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
  );
}

const _ffmpegSplitLibNames = [
  'libavformat',
  'libavcodec',
  'libavutil',
  'libswresample',
];

/// The versioned real file behind [name] (libavformat.so.63.16.100).
File _realSplitLibFile(Directory libDir, String name) {
  final pattern = RegExp('^$name\\.so\\.\\d+\\.\\d+\\.\\d+\$');
  final matches =
      libDir
          .listSync()
          .whereType<File>()
          .map((f) => p.basename(f.path))
          .where(pattern.hasMatch)
          .toList()
        ..sort();
  if (matches.isEmpty) {
    throw Exception('No versioned $name.so.x.y.z found in ${libDir.path}');
  }
  return File(p.join(libDir.path, matches.last));
}

/// Creates the unversioned linker symlink [name].so -> versioned real file.
/// The archive extraction materialises the tarball's symlink entries as
/// 0-byte files, so anything that is not already the correct link gets
/// replaced.
Future<void> _ensureSplitLibLink(Directory libDir, String name) async {
  final linkPath = p.join(libDir.path, '$name.so');
  final target = p.basename(_realSplitLibFile(libDir, name).path);
  final type = FileSystemEntity.typeSync(linkPath, followLinks: false);
  if (type == FileSystemEntityType.link &&
      Link(linkPath).targetSync() == target) {
    return;
  }
  if (type == FileSystemEntityType.directory) {
    await Directory(linkPath).delete(recursive: true);
  } else if (type != FileSystemEntityType.notFound) {
    // 0-byte file (symlink entry) or a stale link.
    await File(linkPath).delete();
  }
  await Link(linkPath).create(target);
}

/// Windows build step – downloads the avbuild 9.1 GPL MSVC archive and links
/// the split import libs (avformat/avcodec/avutil/swresample.lib), bundling
/// the matching split DLLs. The archive is .7z (Dart's archive package cannot
/// read it): Windows 10+ bundles bsdtar as tar.exe, which reads 7z, with the
/// preinstalled 7z.exe as fallback.
Future<FFmpegBuildResult> _buildWindows(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  final includes = <Uri>[];
  final libraries = <String>[];
  final libraryDirectories = <Uri>[];

  final archiveName = 'ffmpeg-9.1-windows-desktop-vs2026-gpl-lite';
  final ffmpegDir = input.packageRoot.resolve('.dart_tool/$archiveName/');
  final downloadUrl =
      'https://sourceforge.net/projects/avbuild/files/windows-desktop/$archiveName.7z/download';
  final archiveFile = input.packageRoot.resolve('.dart_tool/$archiveName.7z');

  if (!Directory.fromUri(ffmpegDir).existsSync()) {
    logger.info('Downloading FFmpeg for Windows ($archiveName)...');
    final dio = Dio();
    final response = await dio.download(
      downloadUrl,
      archiveFile.toFilePath(),
      options: Options(followRedirects: true, responseType: ResponseType.bytes),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to download FFmpeg: HTTP ${response.statusCode}');
    }

    final outputDir = input.packageRoot.resolve('.dart_tool/').toFilePath();
    logger.info('Extracting FFmpeg (tar)...');
    var result = await Process.run('tar', [
      '-xf',
      archiveFile.toFilePath(),
      '-C',
      outputDir,
    ]);
    if (result.exitCode != 0) {
      logger.warning('tar extraction failed: ${result.stderr}');
      logger.info('Extracting FFmpeg (7z fallback)...');
      result = await Process.run('7z', [
        'x',
        '-y',
        '-o$outputDir',
        archiveFile.toFilePath(),
      ]);
    }
    if (result.exitCode != 0) {
      throw Exception('Failed to extract $archiveName.7z: ${result.stderr}');
    }
    logger.info('FFmpeg extracted to $ffmpegDir');
  }
  // Re-run this hook when the archive or extraction changes.
  output.dependencies.add(archiveFile);

  final includeDir = ffmpegDir.resolve('include/');
  final libDir = ffmpegDir.resolve('lib/');
  final binDir = ffmpegDir.resolve('bin/');

  if (!Directory.fromUri(libDir).existsSync()) {
    throw Exception(
      'Downloaded FFmpeg build is incomplete: lib/ not found at $libDir.',
    );
  }

  includes.add(includeDir);
  libraryDirectories.add(libDir);
  // Link the split import libs; native_toolchain_c appends .lib on Windows.
  // avfilter is REQUIRED: the DLNA subtitle-burn transcode path references
  // the filter-graph API (the Android/Linux link lists already include it).
  libraries.addAll(
    ['avformat', 'avcodec', 'avutil', 'swresample', 'avfilter'],
  );

  // Bundle the split DLLs the merge engine's imports resolve to. avfilter-12
  // serves the DLNA transcode path and itself loads swscale-10 (swscale ships
  // even though nothing references it directly yet). If fvp's mdk bundle
  // ships same-named DLLs into the app dir, one copy wins the dedupe —
  // remux works with either build; only x264 transcode would be lost.
  final dlls = [
    'avformat-63.dll',
    'avcodec-63.dll',
    'avutil-61.dll',
    'swresample-7.dll',
    'swscale-10.dll',
    'avfilter-12.dll',
  ];
  for (final dll in dlls) {
    final file = binDir.resolve(dll);
    if (!File.fromUri(file).existsSync()) {
      throw Exception(
        'Downloaded FFmpeg build is incomplete: $dll not found at $binDir.',
      );
    }
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: dll,
        file: file,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  }
  logger.info('Registered ${dlls.length} FFmpeg DLLs as bundled code assets.');

  return FFmpegBuildResult(
    includes: includes,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
  );
}
