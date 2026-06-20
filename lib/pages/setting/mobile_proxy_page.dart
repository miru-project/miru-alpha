import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/widgets/dialog/dialog.dart';

class MobileProxyPage extends HookWidget {
  const MobileProxyPage({super.key});
  @override
  Widget build(BuildContext context) {
    final selectType = useState('http');
    final inputLink = useState('');
    final proxyList = useState(
      MiruSettings.getSetting<Set<String>>(SettingKey.proxyList) ?? {},
    );
    final isDelete = useState(false);
    final selectedProxy = useState<String>(
      MiruSettings.getSetting<String>(SettingKey.proxy) ?? '',
    );
    final selectToRemove = useState<Set<String>>({});
    return MiruScaffold.mobile(
      resizeToAvoidBottomInset: false,
      mobileHeader: SnapSheetNested.back(
        title: 'settings.proxy.name'.i18n,
        suffix: Row(
          children: [
            FButton.icon(
              variant: .ghost,
              onPress: () {
                showMiruDialog(
                  context: context,
                  builder: (context, style, animation) => FDialog(
                    style: style,
                    animation: animation,
                    title: Text('settings.proxy.add_proxy'.i18n),
                    body: Form(
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          SizedBox(height: 10),
                          FSelect<String>(
                            label: Text('common.type'.i18n),
                            control: .managed(
                              toggleable: true,
                              onChange: (value) {
                                selectType.value = value ?? '';
                              },
                              initial: selectType.value,
                            ),
                            enabled: true,
                            contentScrollHandles: true,
                            items: const {
                              'HTTP': 'http',
                              'HTTPS': 'https',
                              'SOCKS5': 'socks5',
                              'SOCKS4': 'socks4',
                            },
                          ),
                          SizedBox(height: 10),
                          FTextField(
                            label: Text('common.url'.i18n),
                            clearable: (value) => value.text.isNotEmpty,
                            hint: '127.0.0.1:3000',
                            control: .managed(
                              onChange: (value) {
                                inputLink.value = value.text;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      FButton(
                        size: .sm,
                        child: Text('common.continue_text'.i18n),
                        onPress: () {
                          final link = Uri.parse(
                            '${selectType.value}://${inputLink.value}',
                          );
                          proxyList.value = {
                            ...proxyList.value,
                            link.toString(),
                          };
                          MiruSettings.setSetting(
                            SettingKey.proxyList,
                            proxyList.value,
                          );
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
                  ),
                );
              },
              child: Icon(FLucideIcons.plus, size: 24),
            ),
            FButton.icon(
              variant: isDelete.value ? .destructive : .ghost,
              onPress: () {
                if (!isDelete.value) {
                  isDelete.value = true;
                  return;
                }
                isDelete.value = false;
                if (selectToRemove.value.isEmpty) return;
                showMiruDialog(
                  context: context,
                  builder: (context, style, animation) => FDialog(
                    style: style,
                    animation: animation,
                    title: Text(
                      'settings.proxy.remove_proxy_count'.fill({
                        "count": selectToRemove.value.length.toString(),
                      }),
                    ),
                    actions: [
                      FButton(
                        size: .sm,
                        child: Text('common.continue_text'.i18n),
                        onPress: () {
                          proxyList.value = proxyList.value.difference(
                            selectToRemove.value,
                          );
                          MiruSettings.setSetting(
                            SettingKey.proxyList,
                            proxyList.value,
                          );
                          if (selectToRemove.value.contains(
                            selectedProxy.value,
                          )) {
                            selectedProxy.value = '';
                            MiruSettings.setSetting(SettingKey.proxy, '');
                          }
                          selectToRemove.value = {};
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
                  ),
                );
                isDelete.value = !isDelete.value;
              },
              child: Icon(FLucideIcons.trash, size: 20),
            ),
          ],
        ),
      ),

      snapSheet: [],
      body: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: constraints.maxHeight / 2,
          child: ListView(
            children: [
              if (proxyList.value.isNotEmpty) ...[
                if (isDelete.value)
                  FSelectTileGroup<String>.builder(
                    control: .managed(
                      onChange: (value) {
                        selectToRemove.value = value;
                      },
                      initial: selectToRemove.value,
                    ),
                    tileBuilder: (context, index) {
                      final proxy = proxyList.value.elementAt(index);
                      final uri = Uri.parse(proxy);
                      return FSelectTile.tile(
                        checkedIcon: Icon(FLucideIcons.trash),
                        value: proxy,
                        title: Text(uri.host),
                        subtitle: Text('${'common.port'.i18n} : ${uri.port}'),
                        suffix: Text(uri.scheme.toUpperCase()),
                      );
                    },
                    count: proxyList.value.length,
                  )
                else
                  FSelectTileGroup<String>.builder(
                    control: .managedRadio(
                      onChange: (value) {
                        if (isDelete.value) {
                          proxyList.value = {
                            ...proxyList.value,
                            value.firstOrNull ?? '',
                          };
                          MiruSettings.setSetting(
                            SettingKey.proxyList,
                            proxyList.value,
                          );
                          return;
                        }
                        selectedProxy.value = value.firstOrNull ?? '';
                        MiruSettings.setSetting(
                          SettingKey.proxy,
                          selectedProxy.value,
                        );
                      },
                      initial: selectedProxy.value,
                    ),
                    tileBuilder: (context, index) {
                      final proxy = proxyList.value.elementAt(index);
                      final uri = Uri.parse(proxy);
                      return FSelectTile.tile(
                        value: proxy,
                        title: Text(uri.host),
                        subtitle: Text('${'common.port'.i18n} : ${uri.port}'),
                        suffix: selectToRemove.value.contains(proxy)
                            ? Icon(FLucideIcons.trash)
                            : Text(uri.scheme.toUpperCase()),
                      );
                    },
                    count: proxyList.value.length,
                  ),
              ] else
                Center(
                  child: Text(
                    'settings.proxy.no_proxy'.i18n,
                    style: TextStyle(fontWeight: .bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
