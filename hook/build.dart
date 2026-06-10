import 'dart:io';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/src/c_library.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

/// Fix broken symlinks in extracted FFmpeg directory.
/// The tar archive sometimes stores symlinks as empty files.
/// This recreates proper symlinks for 0-byte .so files.
void _fixBrokenSymlinks(Directory dir) {
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.existsSync() && entity.lengthSync() == 0) {
      final name = p.basename(entity.path);
      if (!name.endsWith('.so')) continue;

      final parent = entity.parent;
      final matches = parent.listSync().whereType<File>().where((f) {
        final bn = p.basename(f.path);
        return bn.startsWith(name) && bn != name && f.lengthSync() > 0;
      }).toList();

      if (matches.isNotEmpty) {
        matches.sort(
          (a, b) =>
              p.basename(b.path).length.compareTo(p.basename(a.path).length),
        );
        entity.deleteSync();
        Link(entity.path).createSync(p.basename(matches.first.path));
      }
    }
  }
}

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

/// Map Dart Architecture to Linux architecture subdirectory name.
String _linuxArchName(Architecture arch) {
  switch (arch) {
    case Architecture.x64:
      return 'amd64';
    case Architecture.arm64:
      return 'arm64';
    case Architecture.arm:
      return 'armhf';
    default:
      throw Exception('Unsupported Linux architecture: $arch');
  }
}

/// Linux build step – mirrors Android but uses Linux FFmpeg archive.
Future<FFmpegBuildResult> _buildLinux(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  final includes = <Uri>[];
  final libraries = <String>[];
  final libraryDirectories = <Uri>[];

  final ffmpegDir = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-linux-clang-lite-lto/',
  );
  final archiveFile = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-linux-clang-lite-lto.tar.xz',
  );
  final archName = _linuxArchName(input.config.code.targetArchitecture);

  // Download and extract FFmpeg if not already present
  if (!Directory.fromUri(ffmpegDir).existsSync()) {
    logger.info('Downloading FFmpeg prebuilt binaries for Linux...');
    final dio = Dio();
    final response = await dio.download(
      'https://sourceforge.net/projects/avbuild/files/linux/ffmpeg-8.0-linux-clang-lite-lto.tar.xz/download',
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

  includes.add(ffmpegDir.resolve('include/'));
  final libArchDir = ffmpegDir.resolve('lib/$archName/');
  libraryDirectories.add(libArchDir);
  libraries.add('ffmpeg');

  // Fix broken symlinks that may result from tar extraction
  _fixBrokenSymlinks(Directory.fromUri(libArchDir));

  // No need to manually bundle libffmpeg here – native_toolchain_c
  // automatically bundles all shared libraries that libffmpeg_merge.so
  // links against (e.g. libffmpeg.so.8 via its NEEDED entry).
  return FFmpegBuildResult(
    includes: includes,
    libraries: libraries,
    libraryDirectories: libraryDirectories,
  );
}
