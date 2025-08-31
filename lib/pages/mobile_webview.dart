import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/utils/index.dart';
// import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.extensionRuntime,
    required this.url,
  });
  final ExtensionMeta extensionRuntime;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late String url = widget.extensionRuntime.webSite + widget.url;
  // final cookieManager = WebviewCookieManager();
  late Uri loadUrl = Uri.parse(url);

  Future<void> _setCookie() async {
    if (loadUrl.host != Uri.parse(url).host) {
      return;
    }
    // final cookies = await cookieManager.getCookies(loadUrl.toString());
    // final cookieString =
    //     cookies.map((e) => '${e.name}=${e.value}').toList().join(';');
    // debugPrint('$url $cookieString');
    // widget.extensionRuntime.setcookie(
    //   cookieString,
    // );
  }

  @override
  void dispose() {
    _setCookie();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(loadUrl.toString())),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          userAgent: MiruStorage.getUASetting(),
        ),
        onLoadStart: (controller, url) {
          setState(() {
            loadUrl = url!;
          });
        },
      ),
    );
  }
}
