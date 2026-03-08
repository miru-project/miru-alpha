import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AnilistWebViewPage extends StatefulWidget {
  const AnilistWebViewPage({super.key, required this.url});
  final String url;

  @override
  State<AnilistWebViewPage> createState() => _AnilistWebViewPageState();
}

class _AnilistWebViewPageState extends State<AnilistWebViewPage> {
  late String url = widget.url;

  @override
  void dispose() {
    CookieManager.instance().deleteCookies(url: WebUri(widget.url));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("anilist_login".i18n)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onLoadStart: (controller, url) async {
          if (url != null && url.toString().contains("access_token")) {
            debugPrint(url.host);
            Navigator.pop(context, url.toString());
          }
        },
      ),
    );
  }
}
