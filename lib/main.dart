import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/fvp.dart';

import 'package:macos_window_utils/macos/ns_window_button_type.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:miru_app_new/controllers/application_controller.dart';
import 'package:miru_app_new/generated_bindings.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/download/download_utils.dart';
import 'package:miru_app_new/utils/download/ffmpeg_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/i18n.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'package:miru_app_new/utils/router/router_util.dart';
import 'package:window_manager/window_manager.dart';

// Miru Core ffi definitions
typedef InitDyLibNative = ffi.Void Function(ffi.Pointer<ffi.Char>);
typedef InitDyLib = void Function(ffi.Pointer<ffi.Char>);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!(Platform.isAndroid || Platform.isIOS) && !kIsWeb) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1300, 700),
      center: true,
      skipTaskbar: false,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  if (Platform.isAndroid || Platform.isLinux) {
    FFMpegUtils.ensureInitialized();
  }
  if (Platform.isMacOS) {
    await WindowManipulator.initialize(enableWindowDelegate: true);
    await WindowManipulator.addToolbar();
    await WindowManipulator.overrideStandardWindowButtonPosition(
      buttonType: NSWindowButtonType.closeButton,
      offset: const Offset(15, 18),
    );
    await WindowManipulator.overrideStandardWindowButtonPosition(
      buttonType: NSWindowButtonType.miniaturizeButton,
      offset: const Offset(35, 18),
    );
    await WindowManipulator.overrideStandardWindowButtonPosition(
      buttonType: NSWindowButtonType.zoomButton,
      offset: const Offset(55, 18),
    );
  }
  await DeviceUtil.ensureInitialized();
  await MiruDirectory.ensureInitialized();
  await MiruStorage.ensureInitialized();
  await MiruRequest.ensureInitialized();
  await DownloadUtils.ensureInitialized();
  await ExtensionUtils.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  MiruLog.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  WidgetsFlutterBinding.ensureInitialized();
  // Init config for miru_core
  await loadMiruCore();
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  createState() => _App();
}

class _App extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    registerWith(
      options: {
        'platforms': ['windows', 'linux'],
        'video.decoders': ['D3D11', 'NVDEC', 'FFmpeg'],
        'player': {'buffer': '2000+600000'},
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(applicationControllerProvider);
    return MaterialApp.router(
      key: navigatorKey,
      title: 'Miru',
      routerConfig: RouterUtil.appRouter,
      theme: c.themeData,
    );
  }
}

void startNativeMiruCore(String configPath) async {
  final lib = ffi.DynamicLibrary.open("libmiru_core.so");

  using((Arena arena) {
    final configPathPointer =
        configPath.toNativeUtf8(allocator: arena).cast<ffi.Char>();
    final core = MiruCore(lib);
    core.initDyLib(configPathPointer);
  });
}

Future<void> loadMiruCore() async {
  final appSupportDir = MiruDirectory.getDirectory;
  final configPath = '$appSupportDir/config.json';
  if (File(configPath).existsSync()) {
    logger.info('Config file exists: $configPath');
  } else {
    logger.info('Config file does not exist, creating: $configPath');
    final configDir = Directory(appSupportDir);
    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }
    final configData = '''{
        "database": {
          "driver": "sqlite3",
          "host": "localhost",
          "port": 5432,
          "user": "miru",
          "password": "",
          "dbname": "$appSupportDir/miru.db",
          "sslmode": "disable"
        },
        "extensionPath": "$appSupportDir/extensions",
        "debug": false
      }''';

    File(configPath).writeAsStringSync(configData);
    logger.info('Default configuration written to config file');
    logger.info('Config file created: $configPath');
  }
  // startMiruCore(configPath);

  if (Platform.isAndroid) {
    final platform = MethodChannel('com.example.miru_new/miru_core');
    await platform.invokeMethod('InitAAR', configPath);
    return;
  }
  await Isolate.run(() => startNativeMiruCore(configPath));
  return;
}
