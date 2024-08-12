import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:macos_window_utils/macos/ns_window_button_type.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:media_kit/media_kit.dart';
import 'package:miru_app_new/controllers/application_controller.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'package:miru_app_new/utils/router/router_util.dart';
import 'package:miru_app_new/views/pages/main_page.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!GetPlatform.isMobile && !GetPlatform.isWeb) {
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

  if (GetPlatform.isMacOS) {
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
  MediaKit.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  createState() => _App();
}

class _App extends State<App> {
  late ApplicationController c;
  @override
  void initState() {
    super.initState();
    c = Get.put(ApplicationController());
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp.router(
    //   title: 'Miru',
    //   routerConfig: RouterUtil.appRouter,
    //   theme: c.currentThemeData,
    // );
    return GetMaterialApp(
      title: 'Miru',
      home: const MainPage(),
      theme: c.currentThemeData,
      defaultTransition: Transition.downToUp,
      debugShowCheckedModeBanner: false,
    );
  }
}
