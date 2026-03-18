import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';

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
    final selectedProxy = useState<String>('');
    return FDialog(
      style: style,
      animation: animation,
      title: const Text('Proxy Settings'),
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
                    onChange: (value) {
                      inputLink.value = value.text;
                    },
                  ),
                  suffixBuilder: (context, style, _) => FButton.icon(
                    variant: .ghost,
                    onPress: () {
                      final link = Uri.parse(
                        '${selectType.value}://${inputLink.value}',
                      );
                      proxyList.value = {...proxyList.value, link.toString()};
                      MiruSettings.setSetting(
                        SettingKey.proxyList,
                        proxyList.value,
                      );
                    },
                    child: Icon(FIcons.plus),
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
                                  child: Icon(FIcons.trash),
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
                                Text('Port:  '),
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
            Center(child: Text('No proxy')),
        ],
      ),
      actions: [
        FButton(
          size: .sm,
          child: const Text('Save'),
          onPress: () {
            MiruSettings.setSetting(SettingKey.proxy, selectedProxy.value);
            Navigator.of(context).pop();
          },
        ),
        FButton(
          size: .sm,
          variant: .outline,
          child: const Text('Cancel'),
          onPress: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
