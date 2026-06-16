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
      ).build(
        input: input,
        output: output,
        linkModePreference: LinkModePreference.dynamic,
      );
    }
  });
}

Future<FFmpegBuildResult> _buildAndroid(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  final includes = <Uri>[];
  final libraries = <String>[];
  final libraryDirectories = <Uri>[];
  final ffmpegDir = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-android-lite-lto/',
  );
  final archiveFile = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-android-lite-lto.tar.xz',
  );

  if (!Directory.fromUri(ffmpegDir).existsSync()) {
    logger.info('Downloading FFmpeg prebuilt binaries for Android...');
    final dio = Dio();
    final response = await dio.download(
      'https://sourceforge.net/projects/avbuild/files/android/ffmpeg-8.0-android-lite-lto.tar.xz/download',
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

  String abi;
  switch (input.config.code.targetArchitecture) {
    case Architecture.arm64:
      abi = 'arm64-v8a';
      break;
    case Architecture.arm:
      abi = 'armeabi-v7a';
      break;
    case Architecture.x64:
      abi = 'x86_64';
      break;
    case Architecture.ia32:
      abi = 'x86';
      break;
    default:
      throw Exception(
        'Unsupported architecture: ${input.config.code.targetArchitecture}',
      );
  }

  includes.add(ffmpegDir.resolve('include/'));
  libraryDirectories.add(ffmpegDir.resolve('lib/$abi/'));
  libraries.add('ffmpeg');

  final libffmpegSo = ffmpegDir.resolve('lib/$abi/libffmpeg.so');
  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: 'libffmpeg.so',
      file: libffmpegSo,
      linkMode: DynamicLoadingBundled(),
    ),
  );
  return FFmpegBuildResult(
    includes: includes,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
  );
}

/// Linux build step – mirrors Android but uses Linux FFmpeg archive.
Future<FFmpegBuildResult> _buildLinux(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  final includes = <Uri>[];
  final libraries = <String>[];
  final libraryDirectories = <Uri>[];

  final includeDir = input.packageRoot.resolve('.dart_tool/ffmpeg-include/');
  final archiveFile = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-linux-clang-lite-lto.tar.xz',
  );
  final fullArchiveDir = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-linux-clang-lite-lto/',
  );

  // Extract only FFmpeg C headers from avbuild archive.
  if (!Directory.fromUri(includeDir).existsSync()) {
    if (!Directory.fromUri(fullArchiveDir).existsSync()) {
      logger.info('Downloading FFmpeg headers for Linux...');
      final dio = Dio();
      final response = await dio.download(
        'https://sourceforge.net/projects/avbuild/files/linux/ffmpeg-8.0-linux-clang-lite-lto.tar.xz/download',
        archiveFile.toFilePath(),
        options: Options(
          followRedirects: true,
          responseType: ResponseType.bytes,
        ),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download FFmpeg: HTTP ${response.statusCode}',
        );
      }

      logger.info('Extracting FFmpeg headers...');
      final bytes = await File(archiveFile.toFilePath()).readAsBytes();
      final tarBytes = XZDecoder().decodeBytes(bytes);
      final archive = TarDecoder().decodeBytes(tarBytes);
      final outputDir = input.packageRoot.resolve('.dart_tool/').toFilePath();
      for (final file in archive) {
        // Only extract files under include/ – we only need the C headers.
        if (file.name.isEmpty) continue;
        if (!file.name.startsWith('ffmpeg-8.0-linux-clang-lite-lto/include/')) {
          continue;
        }
        final filePath = p.join(outputDir, file.name);
        if (file.isFile) {
          await File(filePath).create(recursive: true);
          await File(filePath).writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }
    }

    // Rename/move the include tree to a shorter path so we don't carry the
    // full original directory tree.
    final extracted = fullArchiveDir.resolve('include/');
    if (Directory.fromUri(extracted).existsSync()) {
      await Directory.fromUri(extracted).rename(includeDir.toFilePath());
    }
    // Clean up the extracted full archive (only needed for its headers).
    if (Directory.fromUri(fullArchiveDir).existsSync()) {
      await Directory.fromUri(fullArchiveDir).delete(recursive: true);
    }
  }

  includes.add(includeDir);
  libraryDirectories.add(
    input.packageRoot.resolve(
      'linux/flutter/ephemeral/.plugin_symlinks/fvp/linux/mdk-sdk/lib/amd64/',
    ),
  );
  // Use -l:libffmpeg.so.8 to link against the exact versioned file.
  libraries.add(':libffmpeg.so.8');

  return FFmpegBuildResult(
    includes: includes,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
  );
}

/// Windows build step – downloads the FFmpeg mingw archive from sourceforge
/// and fully extracts it (headers, DLLs, and import libs). Uses the downloaded
/// ffmpeg-8.dll for both linking and bundling, so there is no dependency on
/// fvp's FFmpeg. Only ffmpeg-8.dll is bundled (not the individual av* DLLs)
/// since it re-exports all the symbols needed by ffmpeg_merge.
Future<FFmpegBuildResult> _buildWindows(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  final includes = <Uri>[];
  final libraries = <String>[];
  final libraryDirectories = <Uri>[];

  // Download and fully extract FFmpeg mingw archive to .dart_tool/
  final archiveName = 'ffmpeg-master-mingw-gcc-lite';
  final ffmpegDir = input.packageRoot.resolve('.dart_tool/$archiveName/');
  final downloadUrl =
      'https://sourceforge.net/projects/avbuild/files/windows-desktop/$archiveName.tar.xz/download';
  final archiveFile = input.packageRoot.resolve(
    '.dart_tool/$archiveName.tar.xz',
  );

  if (!Directory.fromUri(ffmpegDir).existsSync()) {
    logger.info('Downloading FFmpeg for Windows...');
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
        await Directory(filePath).create(recursive: true);
      }
    }
    logger.info('FFmpeg extracted to $ffmpegDir');
  }

  final includeDir = ffmpegDir.resolve('include/');
  final libDir = ffmpegDir.resolve('lib/x86_64/');
  final binDir = ffmpegDir.resolve('bin/x86_64/');
  final ffmpegDll = binDir.resolve('ffmpeg-8.dll');

  if (!File.fromUri(ffmpegDll).existsSync()) {
    throw Exception(
      'Downloaded FFmpeg build is incomplete: ffmpeg-8.dll not found at $ffmpegDll.',
    );
  }
  if (!Directory.fromUri(libDir).existsSync()) {
    throw Exception(
      'Downloaded FFmpeg build is incomplete: lib/x86_64/ not found at $libDir.',
    );
  }

  includes.add(includeDir);
  libraryDirectories.add(libDir);
  // Link against ffmpeg.lib (import library from the downloaded archive).
  // native_toolchain_c appends .lib automatically on Windows.
  libraries.add('ffmpeg');

  // Register only ffmpeg-8.dll as a bundled code asset.
  // ffmpeg-8.dll re-exports all the avcodec/avformat/avutil symbols, so the
  // individual av* DLLs are not needed at link time or runtime.
  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: 'ffmpeg-8.dll',
      file: ffmpegDll,
      linkMode: DynamicLoadingBundled(),
    ),
  );
  logger.info('Registered ffmpeg-8.dll as bundled code asset.');

  return FFmpegBuildResult(
    includes: includes,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
  );
}
