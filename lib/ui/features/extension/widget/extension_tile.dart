import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/ui/features/extension/widget/extension_list_tile.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/version_util.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/core/index.dart';

class ExtensionTile extends HookConsumerWidget with FTileMixin {
  final DomainExtensionMeta data;
  final String repoUrl;
  const ExtensionTile({super.key, required this.data, required this.repoUrl});

  void oninstall(
    DomainExtensionMeta data,
    String repoUrl,
    ExtensionPageNotifier notifier,
  ) async {
    await notifier.installPackage(data.packageName, repoUrl);
    iconsMessageToast(
      title: "Installed ${data.name}",
      icon: FLucideIcons.blocks,
      duration: 1,
    );
  }

  void onuninstall(
    DomainExtensionMeta data,
    String repoUrl,
    ExtensionPageNotifier notifier,
  ) async {
    await notifier.uninstallPackage(data.packageName);
    iconsMessageToast(
      title: "Uninstalled ${data.name}",
      icon: FLucideIcons.blocks,
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
    final isInstalled = pkg.contains(data.packageName);
    bool needUpdate = isInstalled;
    if (isInstalled) {
      needUpdate = VersionUtil.isVersionGreaterThan(
        data.version,
        meta
                .firstWhereOrNull((e) => e.packageName == data.packageName)
                ?.version ??
            "0.0.0",
      );
    }
    return DeviceUtil.deviceWidget(
      // Mobile widget
      context: context,
      mobile: ExtensionListTile(
        isNSFW: data.nsfw,
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type.name,
        icon: data.icon,
        needUpdate: needUpdate,
        onInstall: () => oninstall(data, repoUrl, notifier),
        onUninstall: () => onuninstall(data, repoUrl, notifier),
      ),
      desktop: ExtensionGridTile(
        package: data.packageName,
        isNSFW: data.nsfw,
        isInstalled: isInstalled,
        name: data.name,
        version: data.version,
        author: data.author,
        type: data.type.name,
        icon: data.icon,
        needUpdate: needUpdate,
        onInstall: () => oninstall(data, repoUrl, notifier),
        onUninstall: () => onuninstall(data, repoUrl, notifier),
      ),
    );
  }
}
