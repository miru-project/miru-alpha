import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/utils/setting_dir_index.dart';

class MobileWebViewPage extends StatefulHookWidget {
  const MobileWebViewPage({
    super.key,
    required this.extMeta,
    required this.path,
  });
  final ExtensionMeta extMeta;
  final String path;

  @override
  State<MobileWebViewPage> createState() => _MobileWebViewPageState();
}

class _MobileWebViewPageState extends State<MobileWebViewPage> {
  final cookieManager = CookieManager.instance();

  late Uri loadUri;
  late Uri websiteUri;

  Future<void> _setCookie() async {
    if (loadUri.host != websiteUri.host) {
      return;
    }
    final cookies = await cookieManager.getCookies(url: WebUri.uri(loadUri));
    final cookieString = cookies
        .map((e) => '${e.name}=${e.value}')
        .toList()
        .join(';');
    debugPrint('$websiteUri $cookieString');
    MiruCoreEndpoint.setCookie(cookieString, websiteUri.toString());
  }

  @override
  void dispose() {
    _setCookie();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    websiteUri = Uri.parse(widget.extMeta.webSite);
    final loadUrl = useState(websiteUri.resolve(widget.path));
    loadUri = loadUrl.value;
    return Scaffold(
      appBar: AppBar(title: Text(loadUrl.value.toString())),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(loadUrl.value)),
        initialSettings: InAppWebViewSettings(
          userAgent: MiruSettings.getUASetting(),
        ),
        onLoadStart: (controller, url) {
          if (url == null) return;
          loadUrl.value = url;
        },
      ),
    );
  }
}
