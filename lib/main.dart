import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Miru',
      home: const MainPage(),
      theme: ThemeData(
        fontFamily: 'HarmonyOS_Sans_SC',
        primaryColor: Colors.blue,
      ),
      defaultTransition: Transition.downToUp,
      debugShowCheckedModeBanner: false,
    );
  }
}
