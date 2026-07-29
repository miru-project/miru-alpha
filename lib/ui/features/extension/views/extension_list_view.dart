import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/ui/features/extension/view_models/extension_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/features/extension/widget/extension_tile.dart';
import 'package:miru_alpha/ui/features/extension/widget/clearable_select.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:path/path.dart' as p;

class ExtensionListView extends HookConsumerWidget {
  const ExtensionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(extensionViewModelProvider);
    final notifier = ref.read(extensionViewModelProvider.notifier);

    final scrollController = useScrollController();
    final scrollPosition = useValueNotifier(0.0);
    final searchQuery = useState('');
    final filterExpanded = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.loadRepos();
      });
      return null;
    }, const []);

    final extensionsWithRepo = <Map<String, dynamic>>[];
    for (final repoItem in viewModel.extensions) {
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
          maxExtent: 50,
          minExtent: 0,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(
              title: 'extension.name'.i18n,
              suffix: [
                FButton.icon(
                  variant: .ghost,
                  onPress: () {
                    String? editValue;
                    showMiruDialog(
                      context: context,
                      title: Text('extension.import.title'.i18n),
                      actions: [
                        FButton(
                          variant: .secondary,
                          onPress: () {
                            if (editValue == null) return;
                          },
                          child: Text('extension.import.import_by_url'.i18n),
                        ),
                        FButton(
                          onPress: () async {
                            Navigator.of(context).pop();
                            try {
                              final result = await FilePicker.pickFiles(
                                type: .custom,
                                allowedExtensions: ['js', 'go'],
                              );
                              if (result != null &&
                                  result.files.single.path != null) {
                                final pickedPath = result.files.single.path!;
                                final filename = p.basename(pickedPath);
                                final reg = RegExp(r'^\w.+\.\w+\.(js|go)$');
                                if (!reg.hasMatch(filename)) {
                                  showSimpleToast('Invalid extension name');
                                  return;
                                }
                                final targetPath = p.join(
                                  Core.extensionPath,
                                  filename,
                                );
                                final targetDir = Directory(Core.extensionPath);
                                if (!targetDir.existsSync()) {
                                  await targetDir.create(recursive: true);
                                }
                                await File(pickedPath).copy(targetPath);
                                showSimpleToast('Install Success');
                              }
                            } catch (e) {
                              showSimpleToast('Install Failed: $e');
                            }
                          },
                          child: Text('extension.import.import_by_local'.i18n),
                        ),
                      ],
                      body: Form(
                        child: Column(
                          mainAxisSize: .min,
                          children: [
                            Text('extension.import.tips'.i18n),
                            SizedBox(height: 10),
                            FTextFormField(
                              autovalidateMode: .onUserInteraction,
                              validator: (value) =>
                                  ((value?.startsWith('https') ?? false) ||
                                          (value?.startsWith('http') ??
                                              false)) &&
                                      ((value?.endsWith('.js') ?? false) ||
                                          (value?.endsWith('.go') ?? false))
                                  ? null
                                  : 'extension.import.invalid_url'.i18n,
                              hint: 'https://example.com/ext.js',
                              control: .managed(
                                onChange: (value) {
                                  editValue = value.text;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Icon(FLucideIcons.plus, size: 24),
                ),
              ],
            );
          },
          scrollPosition: scrollPosition,
        ),
        DynamicMinExtentHeaderDelegate(
          maxExtentValue: filterExpanded.value ? 210 : 200,
          minExtentValue: filterExpanded.value ? 210 : 120,
          child: FScaffold(
            childPad: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                Column(
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
                      expanded: filterExpanded.value,
                      onExpandedChanged: (val) => filterExpanded.value = val,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      slivers: [
        if (viewModel.isLoading && extensionsWithRepo.isEmpty)
          const SliverFillRemaining(child: LoadingState())
        else if (extensionsWithRepo.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: FLucideIcons.package,
              message: 'extension.no_extensions_installed'.i18n,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final pair = extensionsWithRepo[index];
                final data = pair['ext'] as DomainExtensionMeta;
                final repoUrl = pair['repoUrl'] as String;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ExtensionTile(data: data, repoUrl: repoUrl),
                );
              }, childCount: extensionsWithRepo.length),
            ),
          ),
      ],
      // Desktop uses the body (grid) while mobile uses the slivers above.
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
          return ExtensionGridView(
            extensionsWithRepo: extensionsWithRepo,
            constraints: constraints,
            notifier: notifier,
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
    required this.expanded,
    required this.onExpandedChanged,
  });

  final String selectedRepo;
  final ExtensionType selectedType;
  final ExtensionInstallStatus selectedInstall;
  final ValueChanged<String> onRepoChanged;
  final ValueChanged<ExtensionType> onTypeChanged;
  final ValueChanged<String> onInstallChanged;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final repoItems = ref.watch(extensionViewModelProvider).repos;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FButton(
            variant: .outline,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            prefix: Icon(FLucideIcons.listFilter),
            suffix: AnimatedRotation(
              turns: expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(FLucideIcons.chevronDown, size: 18),
            ),
            onPress: () {
              if (expanded) {
                controller.reverse();
              } else {
                controller.forward();
              }
              onExpandedChanged(!expanded);
            },
            child: Expanded(
              child: Padding(
                padding: .symmetric(horizontal: 10),
                child: Text('common.filters'.i18n),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: .only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: FSelect<ExtensionType>.rich(
                          label: Text('common.type'.i18n),
                          hint: 'common.all'.i18n,
                          control: FSelectManagedControl<ExtensionType>(
                            onChange: (val) => onTypeChanged(val ?? .all),
                          ),
                          children: [
                            FSelectItem<ExtensionType>(
                              value: .all,
                              title: Text('common.all'.i18n),
                            ),
                            FSelectItem<ExtensionType>(
                              value: .bangumi,
                              title: Text('media.video'.i18n),
                            ),
                            FSelectItem<ExtensionType>(
                              value: .manga,
                              title: Text('media.manga'.i18n),
                            ),
                            FSelectItem<ExtensionType>(
                              value: .fikushon,
                              title: Text('media.novel'.i18n),
                            ),
                          ],
                          format: (value) => switch (value) {
                            .all => 'common.all'.i18n,
                            .bangumi => 'media.video'.i18n,
                            .manga => 'media.manga'.i18n,
                            .fikushon => 'media.novel'.i18n,
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: (FSelect<String>.rich(
                          label: Text('extension.repo.repository'.i18n),
                          hint: 'common.all'.i18n,
                          control: FSelectManagedControl<String>(
                            onChange: (val) => onRepoChanged(
                              val == 'common.all' ? '' : val ?? '',
                            ),
                          ),
                          children: [
                            FSelectItem<String>(
                              value: 'common.all',
                              title: Text('common.all'.i18n),
                            ),
                            ...repoItems.map(
                              (e) => FSelectItem<String>(
                                value: e.name,
                                title: Text(e.name),
                              ),
                            ),
                          ],
                          format: (value) =>
                              value == 'common.all' ? 'common.all'.i18n : value,
                        )),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
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
                    final data = pair['ext'] as DomainExtensionMeta;
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
              trailing: const SearchFilterImportButton(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
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
                            notifier.filterByType(.bangumi);
                          } else if (val == 'media.manga'.i18n) {
                            notifier.filterByType(.manga);
                          } else if (val == 'media.novel'.i18n) {
                            notifier.filterByType(.fikushon);
                          } else {
                            notifier.filterByType(.all);
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      ClearableSelect(
                        hintText: 'common.all'.i18n.toUpperCase(),
                        title: "common.status".i18n,
                        items: [
                          'common.installed'.i18n,
                          'common.not_installed'.i18n,
                        ],
                        onChange: (val) {
                          if (val == 'common.installed'.i18n) {
                            notifier.filterByInstallStatus(
                              'extension.installed',
                            );
                          } else if (val == 'common.not_installed'.i18n) {
                            notifier.filterByInstallStatus(
                              'extension.not_installed',
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
          ),
        ],
      ),
    );
  }
}
