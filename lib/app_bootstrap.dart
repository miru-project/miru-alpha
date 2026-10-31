import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
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
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/miru_core/event_service.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/utils/core/system_ui.dart';
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/core/error.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:window_manager/window_manager.dart';

/// Runs the whole app: widget-binding init, window setup, core services and
/// the router.
///
/// The widget binding is INJECTED via [ensureBinding] so this file carries no
/// marionette imports: the release entry (`lib/main.dart`) passes
/// `WidgetsFlutterBinding.ensureInitialized`, and the debug-only entry
/// (`lib/main_debug.dart`, the only file allowed to import
/// `marionette_flutter`/`marionette_logging`) passes the marionette binding.
/// That keeps both packages out of the release compile graph entirely —
/// a `if (kDebugMode)` conditional import does NOT do this: only
/// `dart.library.*` conditions are honoured, everything else resolves to the
/// default branch, so the previous self-referencing conditional imported the
/// real packages into every build.

/// Errors that reach the global handlers but must never toast — they are
/// still logged/recorded below. The noisy ones are `StateError`s, rendered
/// "Bad state: ...": extended_image pushes a failed network load through the
/// image stream as `StateError('Failed to load <url>.')` once per retry
/// (and [ImageWidget] already renders that failure as its error child), and
/// Riverpod's "Using ref when a widget is about to or has been unmounted"
/// spams the same signature. Any "Bad state:" error is framework noise of
/// that kind, so the whole signature is silenced for the toast.
bool _isNoisyBadStateError(Object error) {
  if (error.toString().contains('Bad state:')) return true;
  if (error is StateError) {
    final message = error.message.toString();
    return message.startsWith('Failed to load') ||
        message.contains('is an empty file') ||
        message.startsWith('User cancel request');
  }
  return false;
}

Future<void> runMiruApp({required void Function() ensureBinding}) async {
  runZonedGuarded<void>(
    () async {
      ensureBinding();
      await MiruDirectory.ensureInitialized();
      MiruLog.ensureInitialized();

      bool errPrint(
        Object error,
        StackTrace stack, [
        String source = 'platform-dispatcher',
      ]) {
        if (!_isNoisyBadStateError(error)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSimpleToast(error.toString());
          });
        }
        MiruLog.recordCrash(error, stack, source: source);
        logger.severe('Uncaught error [$source]: $error');
        logger.severe(stack.toString());
        return false;
      }

      Widget errFunc(FlutterErrorDetails details) {
        errPrint(
          details.exception,
          details.stack ?? StackTrace.empty,
          'flutter-error',
        );
        return ErrorDisplay(
          err: details.exception,
          stack: details.stack ?? StackTrace.current,
        );
      }

      void bindErrorWidget() {
        if (kDebugMode) return;
        ErrorWidget.builder = errFunc;
        FlutterError.onError = errFunc;
        PlatformDispatcher.instance.onError = errPrint;
      }

      bindErrorWidget();
      if (!(Platform.isAndroid || Platform.isIOS || kIsWeb)) {
        await windowManager.ensureInitialized();
        WindowOptions windowOptions = WindowOptions(
          // Desktop launches start desktop-sized (the original default) in
          // every mode — the window is breakpoint-driven (forui `sm` 640 /
          // `lg` 1024) and freely resizable down to the phone-ish floor, so
          // the mobile layout is one drag away; the launch size never fakes
          // a phone viewport.
          size: const Size(1300, 800),
          minimumSize: Size(400, 480),
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
      MiruRequest.ensureInitalized(host: Core.baseUrl);
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
      }

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // Status bar hidden app-wide; the bottom system navigation bar stays.
      // Video fullscreen temporarily hides both (immersiveSticky) and every
      // exit path restores this exact mode (mobile_watch_page.dart) so the
      // status bar never comes back on other pages.
      AppSystemUi.restore();
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
      if (!_isNoisyBadStateError(error)) {
        showSimpleToast(error.toString());
      }
      MiruLog.recordCrash(error, stack, source: 'run-zoned');
      logger.severe('Uncaught error [run-zoned]: $error');
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
      // The phone frame is a DEBUG development presentation (user directive,
      // like the MCP/marionette debug binding): debug builds on desktop
      // render the mobile UI in the 412×915 frame; release/profile builds
      // render the app natively — the frame never ships. Touch builds
      // (Android/iOS) always render natively.
      if (kDebugMode && !(Platform.isAndroid || Platform.isIOS)) {
        return MiruMobilePreviewShell(child: const App());
      }
      return const App();
    }

    return FTheme(
      data: MediaQuery.of(context).platformBrightness == .dark
          ? MiruThemes.neutral.dark.desktop
          : MiruThemes.neutral.light.desktop,
      child: FScaffold(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _initialized
                    ? "common.initializing_miru_core".i18n
                    : "Initializing Miru core...",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 5),
              FCircularProgress.pinwheel(
                style: .delta(iconStyle: .delta(size: 20)),
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

class _App extends ConsumerState<App> with WidgetsBindingObserver {
  Timer? _statusBarRehideTimer;

  @override
  void initState() {
    VolumeController.instance.showSystemUI = false;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    registerWith(
      options: {
        'platforms': ['windows', 'linux', 'macos', 'android', 'ios'],
        'video.decoders': ['D3D11', 'NVDEC', 'FFmpeg'],
        'player': {'buffer': '2000+600000'},
        // mdk's own verbosity: 'all' (fvp's default) emits a per-frame
        // "VideoFrame@… to be destroyed is not rendered" FINEST line while a
        // hidden surface plays — ~15 lines/s into miru.log. 'debug' keeps
        // the FFmpeg/hls diagnostics (fvp maps them to FINE) and drops only
        // the per-frame spam. fvp applies the 'global' options AFTER its
        // own hardcoded log:"all", so this wins.
        'global': {'log': 'debug'},
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
  void didChangePlatformBrightness() {
    // Re-derive the Forui theme so that, in 'system' mode, an OS light/dark
    // switch updates every colour-dependent widget style, not just Material's.
    ref
        .read(applicationControllerProvider.notifier)
        .onPlatformBrightnessChanged();
    super.didChangePlatformBrightness();
  }

  @override
  void didChangeMetrics() {
    // Android: pulling down the notification shade (or any inset change —
    // keyboard, rotation) re-shows the status bar and the app's hidden state
    // is NOT re-asserted when the shade closes, so the bar stays on every
    // page. Re-apply the hidden mode once things settle: restarting the timer
    // on every change dismisses the bar one second after the last one.
    if (AppSystemUi.surfaceOwned) return;
    _statusBarRehideTimer?.cancel();
    _statusBarRehideTimer = Timer(const Duration(seconds: 1), () {
      AppSystemUi.restore();
    });
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    _statusBarRehideTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(applicationControllerProvider);
    return MaterialApp.router(
      showPerformanceOverlay: kProfileMode,
      supportedLocales: FLocalizations.supportedLocales,
      key: ValueKey(c.language),
      // FToaster hosts every showFToast(...); without it a toast throws, and
      // one fired from the error handler re-enters that handler every frame.
      builder: (context, child) => FTheme(
        data: c.themeData,
        child: FToaster(child: child!),
      ),
      themeMode: c.themeMode,
      title: 'Miru Alpha',
      localizationsDelegates: [
        I18nUtils.flutterI18nDelegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: RouterUtil.appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// The DEBUG desktop presentation (user directive, like the MCP debug
/// binding): the PHONE UI, centered in a 412×915 frame — an
/// Android-emulator-style window inside the real desktop window, which
/// itself is never resized or re-initialized. **Ctrl+Shift+P**
/// swaps portrait (412x915) <-> landscape (915x412). **Ctrl+Shift+D**
/// bypasses the frame: the child renders full-bleed at the real
/// window size, so the width-based breakpoints (forui `lg` 1024) reach the
/// superseded desktop layouts (sidebar shell, desktop player) for
/// development. RELEASE/PROFILE BUILDS NEVER WRAP: the bootstrap only
/// mounts this shell under `kDebugMode`, so shipped desktop/touch builds
/// render the app natively with window/platform-resolved theming. The
/// handler
/// only OBSERVES the combos (always returns false), so it never consumes
/// events a real keyboard owner needs; plain typing never matches them. The
/// theme resolves its FORUI MOBILE (touch) variant against the frame width —
/// the desktop window's size must not leak desktop design tokens into the
/// phone frame; the desktop passthrough restores real-window resolution
/// (`setMobilePreviewWidth(null)`).
class MiruMobilePreviewShell extends ConsumerStatefulWidget {
  const MiruMobilePreviewShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MiruMobilePreviewShell> createState() =>
      _MiruMobilePreviewShellState();
}

class _MiruMobilePreviewShellState
    extends ConsumerState<MiruMobilePreviewShell> {
  static const _modes = [Size(412, 915), Size(915, 412)];

  int _mode = 0;

  /// Debug-only desktop passthrough: bypass the phone frame and render the
  /// child full-bleed at the real window size (desktop layouts reachable).
  bool _desktop = false;

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final combo =
        HardwareKeyboard.instance.isControlPressed &&
        HardwareKeyboard.instance.isShiftPressed;
    if (combo && event.logicalKey == LogicalKeyboardKey.keyP) {
      setState(() => _mode = (_mode + 1) % _modes.length);
      _syncPreviewWidth();
    }
    if (combo && kDebugMode && event.logicalKey == LogicalKeyboardKey.keyD) {
      setState(() => _desktop = !_desktop);
      _syncPreviewWidth();
    }
    return false;
  }

  /// Theme width follows the mode: the frame's width in the phone preview
  /// (touch tokens), `null` in the desktop passthrough (real-window
  /// resolution -> desktop tokens at the 1300px launch window).
  void _syncPreviewWidth() {
    ref
        .read(applicationControllerProvider.notifier)
        .setMobilePreviewWidth(_desktop ? null : _modes[_mode].width);
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    // The frame is the DEFAULT desktop UI: resolve the theme against the
    // frame width from the first build (deferred — provider writes during
    // the tree build phase are rejected).
    ThemeUtils.mobilePreviewWidth = _modes[_mode].width;
    Future.microtask(() {
      ref
          .read(applicationControllerProvider.notifier)
          .setMobilePreviewWidth(_modes[_mode].width);
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final real = MediaQuery.of(context);
    // The structure NEVER changes across mode switches: the child stays at
    // the same tree position behind the same widget chain, so toggling does
    // not unmount/remount it (an App remount re-runs initState and fires its
    // stream listeners against a disposed element). The frame takes a BOUNDED
    // height (label space subtracted) so the FittedBox actually scales the
    // phone down instead of overflowing a shorter window — Column children
    // get unbounded main-axis constraints, which is why the bare FittedBox
    // never scaled.
    return LayoutBuilder(
      builder: (context, window) {
        final labelSpace = 24.0;
        final frameH = (window.maxHeight - labelSpace).clamp(
          0.0,
          double.infinity,
        );
        // Desktop passthrough: the frame IS the real window — full-bleed
        // 1:1, so the width breakpoints (forui `lg` 1024) see the desktop
        // size and the desktop layouts render.
        final frameSize = _desktop
            ? Size(window.maxWidth, window.maxHeight)
            : _modes[_mode];
        return ColoredBox(
          color: const Color(0xFF09090B),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Above MaterialApp there is no Directionality — the label
              // brings its own. Empty placeholder slots in desktop mode so
              // the frame slot (and the child's element chain) never moves.
              if (_desktop)
                const SizedBox.shrink()
              else
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'MIRU MOBILE ${frameSize.width.toInt()}x'
                    '${frameSize.height.toInt()} (Ctrl+Shift+P: swap'
                    '${kDebugMode ? ', Ctrl+Shift+D: desktop' : ''})',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              if (_desktop)
                const SizedBox.shrink()
              else
                const SizedBox(height: 6),
              SizedBox(
                width: window.maxWidth,
                height: _desktop ? window.maxHeight : frameH,
                child: FittedBox(
                  // scaleDown, never contain: a frame smaller than the
                  // window renders 1:1 (true phone sizes) — only a frame
                  // taller than the window is scaled DOWN to fit. The
                  // desktop frame equals the window, so it is also 1:1.
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: frameSize.width,
                    height: frameSize.height,
                    child: MediaQuery(
                      data: real.copyWith(
                        size: frameSize,
                        padding: EdgeInsets.zero,
                        viewInsets: EdgeInsets.zero,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
