import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class DesktopProxyDialog extends HookWidget {
  const DesktopProxyDialog({
    super.key,
    required this.style,
    required this.animation,
  });
  final FDialogStyle style;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) {
    final selectType = useState('http');
    final inputLink = useState('');
    final proxyList = useState(
      MiruSettings.getSetting<Set<String>>(SettingKey.proxyList) ?? {},
    );
    final textController = useTextEditingController();
    final selectedProxy = useState<String>(
      MiruSettings.getSetting<String>(SettingKey.proxy) ?? '',
    );
    return FDialog(
      style: style,
      animation: animation,
      title: Text('settings.proxy.proxy_settings'.i18n),
      body: ListView(
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: FSelect<String>(
                  control: .managed(
                    onChange: (value) {
                      selectType.value = value ?? '';
                    },
                    initial: selectType.value,
                  ),
                  style: const .delta(emptyTextStyle: .delta()),
                  enabled: true,
                  contentScrollHandles: true,
                  items: const {
                    'HTTP': 'http',
                    'HTTPS': 'https',
                    'SOCKS5': 'socks5',
                    'SOCKS4': 'socks4',
                  },
                ),
              ),
              Expanded(
                child: FTextField(
                  control: .managed(
                    controller: textController,
                    onChange: (value) {
                      inputLink.value = value.text;
                    },
                  ),
                  suffixBuilder: (context, style, _) => FButton.icon(
                    variant: .ghost,
                    onPress: () {
                      late final Uri link;
                      try {
                        link = Uri.parse(inputLink.value);
                      } catch (e) {
                        link = Uri.parse(
                          '${selectType.value}://${inputLink.value}',
                        );
                      }
                      proxyList.value = {...proxyList.value, link.toString()};
                      MiruSettings.setSetting(
                        SettingKey.proxyList,
                        proxyList.value,
                      );
                      textController.clear();
                    },
                    child: Icon(FLucideIcons.plus),
                  ),
                ),
              ),
            ],
          ),
          FDivider(),
          if (proxyList.value.isNotEmpty)
            ...proxyList.value.map((proxy) {
              final uri = Uri.parse(proxy);

              return Padding(
                padding: .only(bottom: 5),
                child: FTappable(
                  onPress: () {
                    selectedProxy.value = proxy;
                  },
                  child: FFocusedOutline(
                    focused: selectedProxy.value == proxy,
                    child: FCard.raw(
                      child: Padding(
                        padding: const .symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  uri.host,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: context.theme.colors.foreground,
                                  ),
                                ),
                                Spacer(),
                                FButton.icon(
                                  variant: .ghost,
                                  onPress: () {
                                    proxyList.value.remove(proxy);
                                    proxyList.value = {...proxyList.value};
                                    MiruSettings.setSetting(
                                      SettingKey.proxyList,
                                      proxyList.value,
                                    );
                                  },
                                  child: Icon(FLucideIcons.trash),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  uri.scheme.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: .w500,
                                    // fontSize: 16,
                                    // color: context.theme.colors.foreground,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('${'common.port'.i18n}:  '),
                                Text(
                                  uri.port.toString(),
                                  style: TextStyle(
                                    color: context.theme.colors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
          else
            Center(child: Text('settings.proxy.no_proxy'.i18n)),
        ],
      ),
      actions: [
        FButton(
          size: .sm,
          child: Text('common.save'.i18n),
          onPress: () {
            MiruSettings.setSetting(SettingKey.proxy, selectedProxy.value);
            Navigator.of(context).pop();
          },
        ),
        FButton(
          size: .sm,
          variant: .outline,
          child: Text('common.cancel'.i18n),
          onPress: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
