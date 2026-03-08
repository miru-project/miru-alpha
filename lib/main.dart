import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:fvp/fvp.dart';
import 'package:macos_window_utils/macos/ns_window_button_type.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/miru_core/event_service.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/error.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await MiruDirectory.ensureInitialized();
      MiruLog.ensureInitialized();

      bool errPrint(Object error, StackTrace stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSimpleToast(error.toString());
        });
        logger.severe('Uncaught error: $error');
        logger.severe(stack.toString());
        return false;
      }

      Widget errFunc(FlutterErrorDetails details) {
        errPrint(details.exception, details.stack ?? StackTrace.empty);
        return ErrorDisplay(
          err: details.exception,
          stack: details.stack ?? StackTrace.current,
        );
      }

      void bindErrorWidget() {
        ErrorWidget.builder = errFunc;
        FlutterError.onError = errFunc;
        PlatformDispatcher.instance.onError = errPrint;
      }

      bindErrorWidget();
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
      SystemChrome.setEnabledSystemUIMode(.immersive);

      runApp(
        ProviderScope(
          retry: (retryCount, error) => null,
          child: EntryLoadingState(),
        ),
      );
    },
    (error, stack) {
      if (!MiruLog.hasInit) {
        MiruLog.defaultError(error, stack);
      }
      showSimpleToast(error.toString());
      logger.severe('Uncaught error: $error');
      logger.severe(stack.toString());
    },
  );
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
                _initialized
                    ? "initializing_miru_core".i18n
                    : "Initializing Miru core...",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 5),
              FCircularProgress.pinwheel(
                style: context.theme.circularProgressStyle.copyWith(
                  iconStyle: IconThemeDataDelta.delta(size: 20),
                ),
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
    VolumeController.instance.showSystemUI = false;
    super.initState();
    registerWith(
      options: {
        'platforms': ['windows', 'linux', 'macos', 'android', 'ios'],
        'video.decoders': ['D3D11', 'NVDEC', 'FFmpeg'],
        'player': {'buffer': '2000+600000'},
      },
    );

    miruEventService.start();
    miruEventService.extensionStream.listen((data) {
      ref
          .read(extensionPageProvider.notifier)
          .setMetaData(data.map((e) => ExtensionMeta.fromProto(e)).toList());
    });
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
      child: FToaster(
        child: MaterialApp.router(
          key: ValueKey(c.language),
          theme: ThemeData(
            useMaterial3: true,
            // pageTransitionsTheme: const PageTransitionsTheme(
            //   builders: <TargetPlatform, PageTransitionsBuilder>{
            //     .android: SlideRightPageTransitionsBuilder(),
            //     .iOS: SlideRightPageTransitionsBuilder(),
            //     .linux: OpenUpwardsPageTransitionsBuilder(),
            //     .macOS: FadeUpwardsPageTransitionsBuilder(),
            //   },
            // ),
          ),
          themeMode: c.themeMode,
          title: 'Miru Alpha',
          localizationsDelegates: [
            I18nUtils.flutterI18nDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: RouterUtil.appRouter,
          supportedLocales: const [Locale('en'), Locale('zh')],
          // debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
