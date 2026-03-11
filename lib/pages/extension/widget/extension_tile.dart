import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/index.dart';

class ExtensionTile extends HookConsumerWidget with FTileMixin {
  final GithubExtension data;
  final String repoUrl;
  const ExtensionTile({super.key, required this.data, required this.repoUrl});

  bool isVersionGreaterThan(String newVersion, String currentVersion) {
    List<String> currentV = currentVersion.replaceAll("v", "").split(".");
    List<String> newV = newVersion.replaceAll("v", "").split(".");
    bool a = false;
    for (var i = 0; i <= 2; i++) {
      a = int.parse(newV[i]) > int.parse(currentV[i]);
      if (int.parse(newV[i]) != int.parse(currentV[i])) break;
    }
    return a;
  }

  void oninstall(
    GithubExtension data,
    String repoUrl,
    ExtensionPageNotifier notifier,
  ) async {
    await notifier.installPackage(data.package, repoUrl);
    iconsMessageToast(
      title: "Installed ${data.name}",
      icon: FIcons.blocks,
      duration: 1,
    );
  }

  void onuninstall(
    GithubExtension data,
    String repoUrl,
    ExtensionPageNotifier notifier,
  ) async {
    await notifier.uninstallPackage(data.package);
    iconsMessageToast(
      title: "Uninstalled ${data.name}",
      icon: FIcons.blocks,
      duration: 1,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkg = ref.watch(
      extensionPageProvider.select((e) => e.installedPackages),
    );
    final meta = ref.watch(extensionPageProvider.select((e) => e.metaData));
    final notifier = ref.read(extensionPageProvider.notifier);
    final isInstalled = pkg.contains(data.package);
    bool needUpdate = isInstalled;
    if (isInstalled) {
      needUpdate = isVersionGreaterThan(
        data.version,
        meta.where((e) => e.packageName == data.package).first.version,
      );
    }
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
        needUpdate: needUpdate,
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
