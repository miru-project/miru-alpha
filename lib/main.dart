import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/fvp.dart';

import 'package:macos_window_utils/macos/ns_window_button_type.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:miru_app_new/controllers/application_controller.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'package:miru_app_new/utils/router/router_util.dart';

import 'package:window_manager/window_manager.dart';

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
  await MiruDirectory.ensureInitialized();
  await MiruStorage.ensureInitialized();
  await MiruRequest.ensureInitialized();
  await ExtensionUtils.ensureInitialized();
  // MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: App()));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
    registerWith(options: {
      'platforms': ['windows', 'linux'],
      'video.decoders': ['D3D11', 'NVDEC', 'FFmpeg'],
      'player': {'buffer': '2000+600000'}
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(applicationControllerProvider);
    return MaterialApp.router(
      title: 'Miru',
      routerConfig: RouterUtil.appRouter,
      theme: c.themeData,
    );
  }
}
