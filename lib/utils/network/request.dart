// // import 'package:cookie_jar/cookie_jar.dart';
// import 'package:dio/dio.dart';
// // import 'package:miru_app_new/utils/index.dart';
// // import 'package:flutter_socks_proxy/socks_proxy.dart';
// // import '../../utils/miru_directory.dart';
// // import '../../utils/miru_storage.dart';

// // class MiruRequest {
// //   static bool _isInitialized = false;
// //   static final _cookieJar = PersistCookieJar(
// //     ignoreExpires: true,
// //     storage: FileStorage("${MiruDirectory.getDirectory}/.cookies/"),
// //   );

// //   // static bool _isInitialized = false;

// //   static Future<void> ensureInitialized() async {
// //     dio = Dio();
// //     // refreshProxy();
// //     _isInitialized = true;
// //   }

// //   // static void refreshProxy() {
// //   //   String proxy = "";
// //   //   final type = MiruSettings.getSettingSync<String>(SettingKey.proxyType);
// //   //   if (type == "DIRECT") {
// //   //     proxy = type;
// //   //   } else {
// //   //     proxy = '$type ${MiruSettings.getSettingSync<String>(SettingKey.proxy)}';
// //   //   }

// //   //   if (!_isInitialized) {
// //   //     SocksProxy.initProxy(proxy: proxy);
// //   //     return;
// //   //   }
// //   //   SocksProxy.setProxy(proxy);
// //   // }

// //   static Future<void> cleanCookie(String url) async {
// //     await _cookieJar.delete(Uri.parse(url));
// //   }

// //   static Future<void> setCookie(String cookies, String url) async {
// //     final cookieList = cookies.split(';');
// //     for (final cookie in cookieList) {
// //       await _cookieJar.saveFromResponse(Uri.parse(url), [
// //         Cookie.fromSetCookieValue(cookie),
// //       ]);
// //     }
// //   }

// //   static Future<String> getCookie(String url) async {
// //     final cookies = await _cookieJar.loadForRequest(Uri.parse(url));
// //     return cookies.map((e) => e.toString()).join(';');
// //   }
// // }
