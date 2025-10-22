import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:fvp/fvp.dart';

import 'package:macos_window_utils/macos/ns_window_button_type.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/core/miru_directory.dart';
import 'package:miru_app_new/utils/download/ffmpeg_util.dart';
import 'package:miru_app_new/utils/router/router_util.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      if (!(Platform.isAndroid || Platform.isIOS || kIsWeb)) {
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

      FFMpegUtils.ensureInitialized();
      await MiruDirectory.ensureInitialized();
      MiruLog.ensureInitialized();
      Core.loadConfig();
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

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (kReleaseMode) _bindErrorWidget();

      runApp(ProviderScope(child: EntryLoadingState()));
    },
    (error, stack) {
      debugger();
      debugPrint('Uncaught error: $error');
      debugPrint(stack.toString());
    },
  );
}

Widget _func(FlutterErrorDetails details) {
  return ErrorDisplay(
    err: details.exception,
    stack: details.stack ?? StackTrace.current,
  );
}

void _bindErrorWidget() {
  ErrorWidget.builder = _func;
  FlutterError.onError = _func;
}

class EntryLoadingState extends StatefulHookWidget {
  const EntryLoadingState({super.key});
  @override
  createState() => _EntryLoadingState();
}

class _EntryLoadingState extends State<EntryLoadingState> {
  bool _initialized = false;

  @override
  void initState() {
    Core.ensureInitialized().then((_) {
      setState(() {
        _initialized = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return const App();
    }

    return FTheme(
      data: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? FThemes.zinc.dark
          : FThemes.zinc.light,
      child: FScaffold(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Initializing Miru core",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 5),
              FCircularProgress.pinwheel(
                style: context.theme.circularProgressStyle
                    .copyWith(iconStyle: IconThemeData(size: 20))
                    .call,
              ),
              Text("Address: ${Core.host}:${Core.port}"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
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

    CoreNetwork.startPollRootInIsolate(
      poll,
      interval: const Duration(milliseconds: 200),
    );
  }

  void poll(dynamic data) {
    if (data is List<ExtensionMeta>) {
      ref.read(extensionPageProvider.notifier).setMetaData(data);
    } else if (data is String) {
      logger.info('Error received: $data');
    } else {
      logger.info('Unknown data type received: $data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(applicationControllerProvider);
    return FTheme(
      data: c.themeData,
      child: FScaffold(
        child: MaterialApp.router(
          themeMode: c.themeMode,
          title: 'Miru',
          routerConfig: RouterUtil.appRouter,
          // debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
