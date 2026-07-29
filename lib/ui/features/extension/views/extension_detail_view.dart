import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/ui/features/extension/view_models/extension_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';

class ExtensionDetailView extends HookConsumerWidget {
  const ExtensionDetailView({
    super.key,
    required this.extension,
    required this.repoUrl,
  });

  final DomainExtension extension;
  final String repoUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(extensionViewModelProvider.notifier);
    final isInstalled = useState(notifier.isInstalled(extension.package));

    return MiruScaffold.mobile(
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: useValueNotifier(0.0),
          maxExtent: 180,
          minExtent: 120,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(
              title: extension.name,
              description: extension.description ?? '',
              suffix: [
                FButton(
                  variant: FButtonVariant.primary,
                  onPress: () async {
                    if (isInstalled.value) {
                      await notifier.uninstallPackage(extension.package);
                    } else {
                      await notifier.installPackage(extension.package, repoUrl);
                    }
                    isInstalled.value = !isInstalled.value;
                  },
                  child: Text(
                    isInstalled.value
                        ? 'common.uninstall'.i18n
                        : 'common.install'.i18n,
                  ),
                ),
              ],
            );
          },
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (extension.icon != null)
                Center(
                  child: Image.network(
                    MiruRequest.proxyUrl(extension.icon!).toString(),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                extension.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                extension.version,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                extension.description ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                '${'extension.author'.i18n}: ${extension.author}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
