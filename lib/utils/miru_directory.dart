import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class MiruDirectory {
  static late final Directory _appDocDir;
  static late final Directory _cacheDir;
  static late final Directory _mirDonwloadDir;
  static late final Directory _moviesDir;

  static ensureInitialized() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _cacheDir = await getTemporaryDirectory();
    _mirDonwloadDir = await getDownloadsDirectory() ?? _cacheDir;
    if (Platform.isAndroid) {
      await _requestMediaPermissions();
      if (await requestMediaAccess(MediaType.videos)) {
        await createMoviesFolder('Miru');
      }
      _moviesDir = Directory(path.join('/storage/emulated/0/Movies', 'Miru'));
      return;
    }

    _moviesDir = _mirDonwloadDir;
  }

  static Future<bool> _requestMediaPermissions() async {
    if (!Platform.isAndroid) return true;

    // For Android 13+ (API level 33+)
    if (await Permission.photos.request().isGranted &&
        await Permission.videos.request().isGranted) {
      return true;
    }

    // For Android 10-12 (API level 29-32)
    if (await Permission.storage.request().isGranted) {
      return true;
    }

    return false;
  }

  static Future<bool> requestMediaAccess(MediaType type) async {
    if (!Platform.isAndroid) return true;

    switch (type) {
      case MediaType.images:
        return await Permission.photos.request().isGranted;
      case MediaType.videos:
        return await Permission.videos.request().isGranted;
      case MediaType.audio:
        return await Permission.audio.request().isGranted;
      case MediaType.all:
        final photos = await Permission.photos.request().isGranted;
        final videos = await Permission.videos.request().isGranted;
        final audio = await Permission.audio.request().isGranted;
        return photos && videos && audio;
    }
  }

  static String get getDirectory => _miruDir(_appDocDir);

  static String get getCacheDirectory => _miruDir(_cacheDir);

  static String get getDownloadDirectory => _miruDir(_mirDonwloadDir);

  static String get getMoviesDirectory => _miruDir(_moviesDir);

  static String _miruDir(Directory directory) {
    final dir = path.join(directory.path, 'miru');
    Directory(dir).createSync(recursive: true);
    return dir;
  }

  static Future<String?> createMoviesFolder(String folderName) async {
    // Check permissions first
    if (Platform.isAndroid) {
      final hasPermission = await requestMediaAccess(MediaType.videos);
      if (!hasPermission) {
        logger.info("No permission to access movies directory");
        return null;
      }
    }

    try {
      // Create the Movies/folderName directory
      final targetDir = Directory(
        path.join('/storage/emulated/0/Movies', folderName),
      );
      await targetDir.create(recursive: true);

      return targetDir.path;
    } catch (e) {
      logger.info("Failed to create folder in Movies directory: $e");
      return null;
    }
  }
}

enum MediaType { images, videos, audio, all }
