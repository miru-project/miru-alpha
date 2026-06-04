import 'dart:io';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/src/c_library.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

final logger = Logger('Miru Build');
void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      // Collect includes from platform-specific build steps
      List<Uri> includes = [];
      switch (input.config.code.targetOS) {
        case OS.android:
          // Build Android-specific assets and obtain includes, input, and output
          final androidIncludes = await _buildAndroid(input, output);
          includes = androidIncludes;
          break;
        case OS.linux:
          // Build Linux-specific assets and obtain includes
          final linuxIncludes = await _buildLinux(input, output);
          includes = linuxIncludes;
          break;
      }

      // Build the ffmpeg_merge C++ code without linking to ffmpeg statically.
      // Use the collected includes from the platform-specific step.
      await getCLibrary(
        includes: includes.map((uri) => uri.toFilePath()).toList(),
        libraries:
            [], // No static ffmpeg libraries; they are bundled separately.
        libraryDirectories: [],
      ).build(
        input: input,
        output: output,
        linkModePreference: LinkModePreference.dynamic,
      );
    }
  });
}

Future<List<Uri>> _buildAndroid(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  List<Uri> includes = [];
  List<String> libraries = [];
  List<Uri> libraryDirectories = [];
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
    // First decode XZ, then decode Tar
    final tarBytes = XZDecoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(tarBytes);
    final outputDir = input.packageRoot.resolve('.dart_tool/').toFilePath();
    for (final file in archive) {
      // Skip entries with empty names (can happen with some tar archives)
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

  // Map Dart Architecture to Android ABI
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

  // Bundle the prebuilt libffmpeg.so
  final libffmpegSo = ffmpegDir.resolve('lib/$abi/libffmpeg.so');
  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: 'libffmpeg.so',
      file: libffmpegSo,
      linkMode: DynamicLoadingBundled(),
    ),
  );
  // Return a record containing includes, input, and output
  return includes;
}

// Linux build step – mirrors Android but uses Linux FFmpeg archive
Future<List<Uri>> _buildLinux(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  List<Uri> includes = [];
  List<String> libraries = [];
  List<Uri> libraryDirectories = [];

  final ffmpegDir = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-linux-clang-lite-lto/',
  );
  final archiveFile = input.packageRoot.resolve(
    '.dart_tool/ffmpeg-8.0-linux-clang-lite-lto.tar.xz',
  );

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
    // First decode XZ, then decode Tar
    final tarBytes = XZDecoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(tarBytes);
    final outputDir = input.packageRoot.resolve('.dart_tool/').toFilePath();
    for (final file in archive) {
      // Skip entries with empty names (can happen with some tar archives)
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

  // Linux uses standard library locations inside the extracted folder
  includes.add(ffmpegDir.resolve('include/'));
  // Assume libraries are in lib directory
  libraryDirectories.add(ffmpegDir.resolve('lib/'));
  libraries.add('ffmpeg');

  // Bundle the prebuilt libffmpeg.so (first found)
  final libDir = ffmpegDir.resolve('lib/');
  final libFiles = Directory.fromUri(libDir).listSync().whereType<File>().where(
    (f) => p.basename(f.path).startsWith('libffmpeg'),
  );
  if (libFiles.isNotEmpty) {
    final libffmpegSo = Uri.file(libFiles.first.path);
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: p.basename(libffmpegSo.path),
        file: libffmpegSo,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  }

  return includes;
}
