import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/utils/core/log.dart';

Future<void> openWebview(ExtensionMeta ext, [String? url]) async {
  final webview =
      await WebviewWindow.create(
          configuration: CreateConfiguration(
            windowHeight: 1280,
            windowWidth: 720,
            title: "ExampleTestWindow",
            titleBarTopPadding: Platform.isMacOS ? 20 : 0,
            // userDataFolderWindows: await _getWebViewPath(),
          ),
        )
        ..launch(url ?? ext.webSite);
  final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    try {
      final cookies = await webview.getAllCookies();

      if (cookies.isEmpty) {
        logger.info('⚠️ no cookies found');
      }
      String cookie = "";
      for (final c in cookies) {
        cookie += "${c.name}=${c.value}; ";
      }
      // logger.info('Cookies: $cookie');
      await MiruCoreEndpoint.setCookie(cookie, url ?? ext.webSite);
    } catch (e, stack) {
      logger.info('getAllCookies error: $e');
      logger.info(stack);
    }
  });
  webview.onClose.whenComplete(() async {
    logger.info("on close");
    timer.cancel();

    // timer.cancel();
  });
}
