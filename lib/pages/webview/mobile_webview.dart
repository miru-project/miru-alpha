import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/utils/setting_dir_index.dart';

class MobileWebViewPage extends StatefulHookConsumerWidget {
  const MobileWebViewPage({
    super.key,
    required this.extMeta,
    required this.path,
  });
  final ExtensionMeta extMeta;
  final String path;

  @override
  createState() => _MobileWebViewPageState();
}

class _MobileWebViewPageState extends ConsumerState<MobileWebViewPage> {
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
    return FTheme(
      data: ref.watch(applicationControllerProvider.select((s) => s.themeData)),
      child: FScaffold(
        header: FHeader.nested(
          title: FLabel(
            axis: .vertical,
            description: Text(loadUrl.value.toString()),
            child: Text(widget.extMeta.name),
          ),
          titleAlignment: .centerLeft,
          prefixes: [
            FHeaderAction.back(
              onPress: () {
                context.pop();
              },
            ),
          ],
        ),
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri.uri(loadUrl.value)),
          initialSettings: InAppWebViewSettings(
            userAgent: MiruSettings.getUASetting(),
          ),
          onLoadStart: (controller, url) {
            if (url == null) return;
            loadUrl.value = url;
          },
        ),
      ),
    );
  }
}
