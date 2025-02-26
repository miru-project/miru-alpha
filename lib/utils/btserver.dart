import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'package:miru_app_new/views/widgets/snackbar.dart';
import 'package:path/path.dart' as path;

final btServerNotifier = BTDialogController();

class BTServerUtils {
  static Timer? timer;
  static Process? _process;

  // 下载 bt-server
  static downloadLatestBTServer({Function(int, int)? onReceiveProgress}) async {
    debugPrint("检测最新版本");
    // 获取最新版本
    final url =
        "${MiruStorage.getSettingSync(SettingKey.btServerLink, String)}/releases/latest";

    final res = await dio.get(url);
    final result = RegExp(r'app-argument=.+tag\/(.+?)"').firstMatch(res.data);
    if (result == null) {
      throw Exception("Cannot get remote version");
    }
    final remoteVersion = result.group(1);
    // final remoteVersion = res.data["tag_name"] as String;
    debugPrint("最新版本: $remoteVersion");
    late String arch;
    late String platform;
    if (Platform.isAndroid) {
      final supportedAbis = androidDeviceInfo.supportedAbis;
      if (supportedAbis.contains("armeabi-v7a")) {
        arch = "armv7a ";
      }
      if (supportedAbis.contains("x86_64")) {
        arch = "amd64";
      }
      if (supportedAbis.contains("arm64-v8a")) {
        arch = "arm64";
      }
      platform = "android";
    }
    if (Platform.isWindows) {
      arch = "amd64.exe";
      platform = "windows";
    }
    if (Platform.isLinux) {
      platform = "linux";
      final architecture = await Process.run('uname', ['-m']);
      if (architecture.stdout.toString().contains("x86_64")) {
        arch = "amd64";
      }
      if (architecture.stdout.toString().contains("arm64") ||
          architecture.stdout.toString().contains("aarch64")) {
        arch = "arm64";
      }
    }

    debugPrint("下载 bt-server $remoteVersion $platform $arch");
    final downloadUrl =
        "${MiruStorage.getSettingSync(SettingKey.btServerLink, String)}/releases/download/$remoteVersion/bt-server-$remoteVersion-$platform-$arch";
    final savePath = MiruDirectory.getDirectory;
    await dio.download(
      downloadUrl,
      path.join(savePath, _getBTServerFilename()),
      onReceiveProgress: onReceiveProgress,
    );
  }

  // 启动服务器
  static startServer() async {
    // final mainController = Get.find<MainController>();
    final isRunner = btServerNotifier.btServerisRunning.value;

    if (isRunner) {
      return;
    }

    final savePath = MiruDirectory.getDirectory;
    final btServerPath = path.join(savePath, _getBTServerFilename());

    try {
      if (Platform.isWindows) {
        _process = await Process.start(
          btServerPath,
          [],
          workingDirectory: savePath,
        );
      } else {
        // 添加运行权限
        await Process.run("chmod", ["+x", btServerPath]);
        _process = await Process.start(btServerPath, [
          "&",
        ], workingDirectory: savePath);
        logger.info("bt-server started");
      }
    } catch (e) {
      final error = e.toString();
      if (error.contains("cannot find the file") ||
          error.contains("No such file or directory")) {
        btServerNotifier._isInstalled = false;
      }
      throw StartServerException('Start bt-server failed');
    }
    checkServer();
  }

  static stopServer() async {
    _process?.kill();
  }

  // 定时检测服务器是否运行的方法
  static Future<void> checkServer() async {
    final isRunner = btServerNotifier.btServerisRunning;
    // final version = btServerNotifier.btServerVersion;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        btServerNotifier.updateVersion(await BTServerApi.getVersion());
        isRunner.value = true;
      } catch (e) {
        isRunner.value = false;
      }
    });
  }

  // 检查更新
  // static Future<String> getRemoteVersion() async {
  //   try {
  //     const url =
  //         "https://api.github.com/repos/miru-project/bt-server/releases/latest";
  //     final res = dio.get(url);
  //     final remoteVersion = (await res).data["tag_name"] as String;
  //     return remoteVersion.replaceFirst("v", '');
  //   } catch (e) {
  //     return btServerNotifier.btServerVersion;
  //   }
  // }

  // 卸载 bt-server
  static Future<void> uninstall() async {
    stopServer();
    final savePath = MiruDirectory.getDirectory;
    final btServerPath = path.join(savePath, _getBTServerFilename());
    await File(btServerPath).delete();
  }

  static Future<bool> isInstalled() async {
    final savePath = MiruDirectory.getDirectory;
    final btServerPath = path.join(savePath, _getBTServerFilename());
    return File(btServerPath).existsSync();
  }

  // 获取 bt-server 可执行文件名
  static String _getBTServerFilename() {
    if (Platform.isWindows) {
      return "btserver.exe";
    }
    return "btserver";
  }
}

class StartServerException implements Exception {
  final String message;
  StartServerException(this.message);
  @override
  String toString() {
    return message;
  }
}

class BTServerApi {
  static const baseApi = "http://localhost:3000";
  static final dio = Dio(BaseOptions(baseUrl: baseApi));
  static Future<String> getVersion() async {
    return (await dio.get<String>("/version")).data!;
  }

  static Future<String> addTorrent(Uint8List torrent) async {
    return (await dio.post<Map<String, dynamic>>(
      "/torrent",
      data: torrent,
      options: Options(
        headers: {
          "Content-Type": "application/x-bittorrent",
          "Content-Length": torrent.length,
        },
      ),
    )).data!["infoHash"];
  }

  static Future<String> removeTorrent(String infoHash) async {
    return (await dio.delete<String>("/torrent/$infoHash")).data!;
  }

  static Future<List<String>> getFileList(String infoHash) async {
    final fileList =
        (await dio.get<Map<String, dynamic>>(
          "/torrent/$infoHash",
        )).data!['files'];
    return List<String>.from(fileList);
  }
}

class BTDialogController with ChangeNotifier {
  bool _isInstalled = false;
  bool _isDownloading = false;
  double _progress = 0.0;
  bool _hasUpdate = false;
  final String _remoteVersion = "";

  String btServerVersion = "";
  final btServerisRunning = ValueNotifier(false);
  String get version => btServerVersion;
  // ValueNotifier<bool> get isRunning => btServerisRunning;
  bool get isInstalled => _isInstalled;
  bool get isDownloading => _isDownloading;
  double get progress => _progress;
  bool get hasUpdate => _hasUpdate;
  String get remoteVersion => _remoteVersion;
  void updateVersion(String value) {
    btServerVersion = value;
    notifyListeners();
  }

  BTDialogController() {
    btServerisRunning.addListener(_checkForUpdate);
    Future.microtask(() async {
      _isInstalled = await BTServerUtils.isInstalled();
      // _remoteVersion = await BTServerUtils.getRemoteVersion();
      _checkForUpdate();
      notifyListeners();
    });
  }
  void updateInstalled(bool value) {
    _isInstalled = value;
    notifyListeners();
  }

  void uninstallServer() async {
    await BTServerUtils.uninstall();
    _isInstalled = false;
    notifyListeners();
  }

  void startServer() async {
    await BTServerUtils.startServer();
    _isInstalled = true;
    notifyListeners();
  }

  void _checkForUpdate() async {
    // _remoteVersion = await BTServerUtils.getRemoteVersion();
    _hasUpdate = btServerVersion != _remoteVersion;
    notifyListeners();
  }

  void updateProgress(double value) {
    _progress = value;
    debugPrint("下载进度: $value");
    notifyListeners();
  }

  Future<void> downloadOrUpgradeServer(BuildContext context) async {
    _progress = 0;
    BTServerUtils.stopServer();
    _isInstalled = false;
    _isDownloading = true;
    notifyListeners();

    try {
      await BTServerUtils.downloadLatestBTServer(
        onReceiveProgress: (p0, p1) {
          updateProgress(p0 * 100 / p1);
        },
      );
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(
          context: context,
          errorText: "Failed to Download Bt-server",
          detailErrortext: e.toString(),
        );
      }
    } finally {
      _isDownloading = false;
      notifyListeners();
    }

    _isInstalled = await BTServerUtils.isInstalled();

    notifyListeners();
  }

  @override
  void dispose() {
    btServerisRunning.removeListener(_checkForUpdate);
    super.dispose();
  }
}
