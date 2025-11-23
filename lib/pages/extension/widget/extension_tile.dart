import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:miru_app_new/widgets/index.dart';

class ExtensionTile extends HookConsumerWidget with FTileMixin {
  final GithubExtension data;
  final String repoUrl;
  const ExtensionTile({super.key, required this.data, required this.repoUrl});

  void oninstall(
    GithubExtension data,
    String repoUrl,
    ExtensionPageNotifier notifier,
  ) async {
    await notifier.installPackage(data.package, repoUrl);
    iconsMessageToast("Installed ${data.name}", FIcons.blocks, 1);
  }

  void onuninstall(
    GithubExtension data,
    String repoUrl,
    ExtensionPageNotifier notifier,
  ) async {
    await notifier.uninstallPackage(data.package);
    iconsMessageToast("Uninstalled ${data.name}", FIcons.blocks, 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(extensionPageProvider);
    final notifier = ref.read(extensionPageProvider.notifier);
    final isInstalled = state.installedPackages.contains(data.package);

    return DeviceUtil.deviceWidget(
      // Mobile widget
      context: context,
      mobile: ExtensionListTile(
        isNSFW: data.isNsfw,
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type,
        icon: data.icon,
        onInstall: () => oninstall(data, repoUrl, notifier),
        onUninstall: () => onuninstall(data, repoUrl, notifier),
      ),
      desktop: ExtensionGridTile(
        isNSFW: data.isNsfw,
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type,
        icon: data.icon,
        onInstall: () => oninstall(data, repoUrl, notifier),
        onUninstall: () => onuninstall(data, repoUrl, notifier),
      ),
    );
  }
}
