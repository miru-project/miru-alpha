import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:webview_all/webview_all.dart';

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
  final cookieManager = WebViewCookieManager();

  late Uri loadUri;
  late Uri websiteUri;

  Future<void> _setCookie() async {
    final cookies = await cookieManager.getCookies(domain: loadUri);
    final cookieString = cookies
        .map((e) => '${e.name}=${e.value}')
        .join(';');
    debugPrint('$websiteUri $cookieString');
    MiruCoreEndpoint.setCookie(cookieString, loadUri.toString());
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
    final controller = useMemoized(() {
      return WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              final uri = Uri.tryParse(url);
              if (uri == null) return;
              loadUrl.value = uri;
            },
          ),
        )..loadRequest(loadUrl.value);
    }, const []);
    return FTheme(
      data: ref.watch(applicationControllerProvider.select((s) => s.themeData)),
      child: FScaffold(
        childPad: false,
        header: FHeader.nested(
          title: FLabel(
            layout: .vertical,
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
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
