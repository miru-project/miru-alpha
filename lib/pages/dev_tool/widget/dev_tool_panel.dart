import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/dev_tool_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'console_view.dart';
import 'network_view.dart';

class DevToolPanel extends ConsumerWidget {
  const DevToolPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devState = ref.watch(devToolProvider);
    final notifier = ref.read(devToolProvider.notifier);

    if (!devState.show) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: .symmetric(horizontal: 10),
      width: 400,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: context.theme.colors.border, width: 1),
        ),
        color: context.theme.colors.background,
      ),
      child: Column(
        children: [
          _buildHeader(context, notifier),
          const _DevToolFilter(),
          const FDivider(),
          FTabs(
            children: [
              FTabEntry(
                label: const Text('Console'),
                child: const ConsoleView(),
              ),
              FTabEntry(
                label: const Text('Network'),
                child: const NetworkView(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DevTool notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                FLucideIcons.terminal,
                size: 16,
                color: context.theme.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Dev Tools',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          FButton.icon(
            variant: FButtonVariant.ghost,
            onPress: () => notifier.setShow(false),
            child: Icon(FLucideIcons.x, size: 16),
          ),
        ],
      ),
    );
  }
}

class _DevToolFilter extends ConsumerWidget {
  const _DevToolFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devState = ref.watch(devToolProvider);
    final notifier = ref.read(devToolProvider.notifier);
    final meta = ref.watch(searchPageProvider.select((e) => e.metaData));
    final pkgs = devState.availablePackages;
    if (pkgs.isEmpty) return const SizedBox.shrink();

    final Map<String, String> items = {
      'all': 'All',
      for (final p in pkgs) p: meta.firstWhere((m) => m.packageName == p).name,
    };
    final initial =
        (devState.filterPackage != null &&
            items.containsKey(devState.filterPackage))
        ? devState.filterPackage!
        : 'all';

    // return FSelect<String>(
    //   items: items.map((key, value) => MapEntry(value, key)),
    //   builder: (context, style, varSet, value) {
    //     return value;
    //   },
    //   control: .managed(
    //     initial: initial,
    //     onChange: (val) => notifier.setFilterPackage(val == 'all' ? null : val),
    //   ),
    // );
    return FSelect<String>.rich(
      hint: 'extension.name'.i18n,
      format: (s) {
        return items[s]!;
      },
      control: .managed(
        initial: initial,
        onChange: (val) => notifier.setFilterPackage(val == 'all' ? null : val),
      ),
      children: items.keys
          .map(
            (e) => FSelectItem(
              // prefix: meta.firstWhere((m) => m.packageName == e).icon == null
              //     ? Icon(FLucideIcons.toyBrick)
              //     : ImageWidget(
              //         imageUrl: meta
              //             .firstWhere((m) => m.packageName == e)
              //             .icon!,
              //       ),
              subtitle: Text(e),
              title: Text(items[e]!),
              value: e,
            ),
          )
          .toList(),
    );
  }
}
