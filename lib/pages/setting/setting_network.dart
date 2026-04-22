import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/pages/setting/desktop_proxy_dialog.dart';
import 'package:miru_alpha/pages/setting/mobile_proxy_page.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingNetwork extends HookConsumerWidget {
  const SettingNetwork({super.key, this.isMobileLayout = false});
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActivateProxy = useState(
      MiruSettings.getSetting<bool>(SettingKey.proxyActivate) ?? false,
    );
    return MiruListView(
      children: [
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings.network.name',
          children: [
            SettingBaseTile(
              isMobileLayout: isMobileLayout,
              title: 'common.address'.i18n,
              child: Text(
                Core.host,
                style: TextStyle(fontWeight: .bold, letterSpacing: .5),
              ),
            ),
            SettingBaseTile(
              isMobileLayout: isMobileLayout,
              title: 'common.port'.i18n,
              child: Text(
                Core.port,
                style: TextStyle(letterSpacing: .5, fontWeight: .bold),
              ),
            ),
          ],
        ),
        if (!isMobileLayout)
          SettingGroup(
            isMobileLayout: isMobileLayout,
            title: 'settings.proxy.name',
            children: [
              SettingBaseTile(
                isMobileLayout: isMobileLayout,
                title: 'common.address'.i18n,
                child: Row(
                  children: [
                    Spacer(),
                    FButton(
                      onPress: () {
                        showFDialog(
                          context: context,
                          routeStyle: .delta(
                            barrierFilter: () =>
                                (animation) => ImageFilter.compose(
                                  outer: ImageFilter.blur(
                                    sigmaX: animation * 5,
                                    sigmaY: animation * 5,
                                  ),
                                  inner: ColorFilter.mode(
                                    context.theme.colors.barrier,
                                    .srcOver,
                                  ),
                                ),
                          ),
                          builder: (context, style, animation) =>
                              DesktopProxyDialog(
                                style: style,
                                animation: animation,
                              ),
                        );
                      },
                      child: Text('settings.proxy.select'.i18n),
                    ),
                    FSwitch(
                      value: isActivateProxy.value,
                      onChange: (value) {
                        isActivateProxy.value = value;
                        MiruSettings.setSetting(
                          SettingKey.proxyActivate,
                          value.toString(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          FTileGroup(
            label: Text('settings.proxy.name'.i18n),
            children: [
              FTile(
                title: Text('settings.proxy.name'.i18n),
                subtitle: Text('settings.proxy.information'.i18n),
                onPress: () {
                  Navigator.of(
                    context,
                  ).push(RouterUtil.createRoute(MobileProxyPage()));
                },
              ),
              FTile(
                title: Text('settings.proxy.enable'.i18n),
                suffix: FSwitch(
                  value: isActivateProxy.value,
                  onChange: (value) {
                    isActivateProxy.value = value;
                    MiruSettings.setSetting(
                      SettingKey.proxyActivate,
                      value.toString(),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
