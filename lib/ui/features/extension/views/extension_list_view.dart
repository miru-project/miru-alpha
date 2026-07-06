import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/extension/view_models/extension_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/features/extension/widget/extension_tile.dart';
import 'package:miru_alpha/ui/core/core/search_filter_card.dart';
import 'package:miru_alpha/ui/features/extension/widget/clearable_select.dart';
import 'package:miru_alpha/ui/core/grid_view/index.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';
import 'package:miru_alpha/ui/core/platform_widget.dart';
import 'package:miru_alpha/ui/core/refresh/forui_header.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';

class ExtensionListView extends HookConsumerWidget {
  const ExtensionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(extensionViewModelProvider);
    final notifier = ref.read(extensionViewModelProvider.notifier);

    final scrollController = useScrollController();
    final scrollPosition = useValueNotifier(0.0);
    final searchQuery = useState('');

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.loadRepos();
      });
      return null;
    }, const []);

    final extensionsWithRepo = <Map<String, dynamic>>[];
    for (final repoItem in viewModel.repos) {
      for (final e in repoItem.extensions) {
        extensionsWithRepo.add({
          'ext': e,
          'repoUrl': repoItem.url,
          'repoName': repoItem.name,
        });
      }
    }

    return MiruScaffold.mobile(
      scrollController: scrollController,
      scrollThrottle: ScrollUpdateThrottle.low,
      onScrollChange: (offset, _) {
        scrollPosition.value = offset;
      },
      sliverHeaders: [
        FlexibleHeaderDelegate(
          scrollPosition: scrollPosition,
          maxExtent: 360,
          minExtent: 180,
          builder: (context, shrinkOffset, shrinkProgress) {
            final visibleHeight = 360 - shrinkOffset;
            return SizedBox(
              height: visibleHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SnapSheetHeader(title: 'extension.name'.i18n, suffix: []),
                  SizedBox(height: 12),
                  Opacity(
                    opacity: 1.0 - shrinkProgress,
                    child: Column(
                      children: [
                        FTextField(
                          maxLines: 1,
                          control: FTextFieldControl.managed(
                            onChange: (value) {
                              searchQuery.value = value.text;
                              notifier.filterByQuery(value.text);
                            },
                          ),
                          hint: "extension.search_hint".i18n,
                          prefixBuilder: (context, style, states) => Padding(
                            padding: const EdgeInsets.only(left: 12, right: 10),
                            child: Icon(FLucideIcons.search),
                          ),
                        ),
                        SizedBox(height: 10),
                        _ExtensionFilterBar(
                          selectedRepo: viewModel.selectedRepoName,
                          selectedType: viewModel.typeFilter,
                          selectedInstall: viewModel.installFilter,
                          onRepoChanged: notifier.filterByRepo,
                          onTypeChanged: notifier.filterByType,
                          onInstallChanged: notifier.filterByInstallStatus,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (viewModel.isLoading && extensionsWithRepo.isEmpty) {
            return const LoadingState();
          }

          if (extensionsWithRepo.isEmpty) {
            return EmptyState(
              icon: FLucideIcons.package,
              message: 'extension.no_extensions_installed'.i18n,
            );
          }

          return PlatformWidget(
            desktopWidget: ExtensionGridView(
              extensionsWithRepo: extensionsWithRepo,
              constraints: constraints,
              notifier: notifier,
            ),
            mobileWidget: EasyRefresh(
              header: const ForuiHeader(),
              scrollController: scrollController,
              onRefresh: () async {
                await notifier.loadRepos(force: true);
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemBuilder: (context, index) {
                  final pair = extensionsWithRepo[index];
                  final data = pair['ext'] as GithubExtension;
                  final repoUrl = pair['repoUrl'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ExtensionTile(data: data, repoUrl: repoUrl),
                  );
                },
                itemCount: extensionsWithRepo.length,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExtensionFilterBar extends HookConsumerWidget {
  const _ExtensionFilterBar({
    required this.selectedRepo,
    required this.selectedType,
    required this.selectedInstall,
    required this.onRepoChanged,
    required this.onTypeChanged,
    required this.onInstallChanged,
  });

  final String selectedRepo;
  final String selectedType;
  final String selectedInstall;
  final ValueChanged<String> onRepoChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onInstallChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FButton(
            variant: FButtonVariant.outline,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            prefix: const Icon(FLucideIcons.listFilter),
            suffix: AnimatedRotation(
              turns: expanded.value ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(FLucideIcons.chevronDown, size: 18),
            ),
            onPress: () {
              if (expanded.value) {
                controller.reverse();
              } else {
                controller.forward();
              }
              expanded.value = !expanded.value;
            },
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('common.filters'.i18n),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded.value
                ? Column(
                    children: [
                      const SizedBox(height: 10),
                      _FilterRow(
                        label: 'common.type'.i18n,
                        items: const ['ALL', 'video', 'manga', 'novel'],
                        selected: selectedType,
                        onSelected: onTypeChanged,
                      ),
                      const SizedBox(height: 10),
                      _FilterRow(
                        label: 'common.install_status'.i18n,
                        items: const ['ALL', 'installed', 'not_installed'],
                        selected: selectedInstall,
                        onSelected: onInstallChanged,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FButton(
                        variant: selected == item
                            ? FButtonVariant.primary
                            : FButtonVariant.outline,
                        onPress: () => onSelected(item),
                        child: Text(item.toUpperCase()),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class ExtensionGridView extends HookConsumerWidget {
  const ExtensionGridView({
    super.key,
    required this.extensionsWithRepo,
    required this.constraints,
    required this.notifier,
  });

  final List<Map<String, dynamic>> extensionsWithRepo;
  final BoxConstraints constraints;
  final ExtensionViewModel notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: MiruGridView(
                  paddingHeightOffest: 60,
                  desktopGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 210,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  mobileGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final pair = extensionsWithRepo[index];
                    final data = pair['ext'] as GithubExtension;
                    final repoUrl = pair['repoUrl'] as String;
                    return ExtensionTile(data: data, repoUrl: repoUrl);
                  },
                  itemCount: extensionsWithRepo.length,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 110,
            width: constraints.maxWidth - 30,
            child: SearchFilterCard(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            ClearableSelect(
                              hintText: 'common.all'.i18n.toUpperCase(),
                              title: "common.type".i18n,
                              items: [
                                'media.video'.i18n,
                                'media.manga'.i18n,
                                'media.novel'.i18n,
                              ],
                              onChange: (val) {
                                if (val == 'media.video'.i18n) {
                                  notifier.filterByType('video');
                                } else if (val == 'media.manga'.i18n) {
                                  notifier.filterByType('manga');
                                } else if (val == 'media.novel'.i18n) {
                                  notifier.filterByType('novel');
                                } else {
                                  notifier.filterByType('ALL');
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            ClearableSelect(
                              hintText: 'common.all'.i18n.toUpperCase(),
                              title: "common.install_status".i18n,
                              items: [
                                'common.installed'.i18n,
                                'common.not_installed'.i18n,
                              ],
                              onChange: (val) {
                                if (val == 'common.installed'.i18n) {
                                  notifier.filterByInstallStatus('installed');
                                } else if (val == 'common.not_installed'.i18n) {
                                  notifier.filterByInstallStatus(
                                    'not_installed',
                                  );
                                } else {
                                  notifier.filterByInstallStatus('ALL');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
