import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/core/dialog/extension_import_dialog.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/features/extension/view_models/extension_view_model.dart';
import 'package:miru_alpha/ui/features/extension/widget/clearable_select.dart';
import 'package:miru_alpha/ui/features/extension/widget/extension_import_button.dart';
import 'package:miru_alpha/ui/features/extension/widget/extension_tile.dart';
import 'package:miru_alpha/ui/features/search/widget/search_field.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/ui/features/search/widget/search_page_header.dart';
import 'package:miru_alpha/ui/features/setting/setting_extension.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Confirms a pull-to-refresh actually reached the repo loader, mirroring the
/// search page's log so a silent refresh is distinguishable from a broken one.
final _refreshLog = Logger('${logger.name}.extensionRefresh');

class ExtensionListView extends HookConsumerWidget {
  const ExtensionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(extensionViewModelProvider);
    final notifier = ref.read(extensionViewModelProvider.notifier);

    final scrollController = useScrollController();
    final scrollPosition = useValueNotifier(0.0);
    final searchController = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        notifier.loadRepos();
        // Store-first, like the reference card page: the mobile layout opens
        // on "Available" while desktop keeps `all` so its status select still
        // reads as "ALL".
        if (DeviceUtil.isMobileLayout(context) &&
            ref.read(extensionViewModelProvider).installFilter ==
                ExtensionInstallStatus.all) {
          notifier.filterByInstallStatus('extension.not_installed');
        }
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

    final counts = notifier.statusCounts;

    return MiruScaffold.mobile(
      scrollController: scrollController,
      scrollThrottle: ScrollUpdateThrottle.low,
      onRefresh: () async {
        _refreshLog.info('pull-to-refresh');
        await notifier.loadRepos(force: true);
      },
      onScrollChange: (offset, _) {
        scrollPosition.value = offset;
      },
      sliverHeaders: [
        FlexibleHeaderDelegate(
          // h-14 title bar of the reference, collapsing like the search tab.
          maxExtent: 56,
          minExtent: 0,
          scrollPosition: scrollPosition,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(
              title: 'extension.name'.i18n,
              // A tighter bottom pad than the sibling pages' default 15 so
              // the 44dp action targets fit the 56px bar; the title only
              // shifts ~2px against them.
              padding: const EdgeInsets.only(left: 0, bottom: 10, right: 4),
              suffix: const [_ExtensionHeaderActions()],
            );
          },
        ),
        // The search field and the filter row stay pinned under the title
        // bar: one fixed-extent header block (the same opaque
        // searchHeaderSliver the search tab uses) so the controls remain
        // reachable at any scroll depth while the list moves beneath them.
        // Pinned, not collapsing — the user asked for these to stay put.
        searchHeaderSliver(
          context,
          extent: kSearchFieldExtent + _extensionControlsExtent(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchFieldRow(
                field: searchField(
                  controller: searchController,
                  onChange: notifier.filterByQuery,
                  onSubmit: (_) {},
                ),
              ),
              _ExtensionControls(
                installFilter: viewModel.installFilter,
                onInstallChanged: notifier.filterByInstallStatus,
                available: counts.available,
                installed: counts.installed,
                updates: counts.updates,
                typeFilter: viewModel.typeFilter,
                onTypeChanged: notifier.filterByType,
                enableNsfw: MiruSettings.getSettingSync<bool>(
                  SettingKey.enableNSFW,
                ),
                onToggleNsfw: () => _toggleNsfw(ref),
                repos: viewModel.repos,
                selectedRepo: viewModel.selectedRepoName,
                onRepoChanged: notifier.filterByRepo,
              ),
            ],
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

  /// Mirror of Settings → General: persist the flag, then refilter every
  /// surface over the already-cached repos — never refetch.
  static void _toggleNsfw(WidgetRef ref) {
    final next = !MiruSettings.getSettingSync<bool>(SettingKey.enableNSFW);
    MiruSettings.setSettingSync(SettingKey.enableNSFW, next.toString());
    ref.read(extensionPageProvider.notifier).filter();
    ref.read(extensionViewModelProvider.notifier).refilter();
    ref.read(searchPageProvider.notifier).refilter();
  }
}

/// Extent of the pinned controls row (the consolidated status + category
/// filter row), with slack so the pinned header never renders the overflow
/// banner. One row now, so this is roughly half the old two-row extent.
double _extensionControlsExtent(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
  return 50 * scale;
}

/// Display label for the domain type filter — the search feature's
/// `searchContentTypeLabel` serves that feature's own `ExtensionType`, not
/// the domain enum used here.
String _typeFilterLabel(ExtensionType type) => switch (type) {
  ExtensionType.bangumi => 'search.type_anime'.i18n,
  ExtensionType.manga => 'search.type_manga'.i18n,
  ExtensionType.fikushon => 'search.type_novel'.i18n,
  ExtensionType.all => 'common.all'.i18n,
};

/// The reference store page's filter section, pinned under the search
/// field: status segmented control on top, scrollable pill strip below.
class _ExtensionControls extends StatelessWidget {
  const _ExtensionControls({
    required this.installFilter,
    required this.onInstallChanged,
    required this.available,
    required this.installed,
    required this.updates,
    required this.typeFilter,
    required this.onTypeChanged,
    required this.enableNsfw,
    required this.onToggleNsfw,
    required this.repos,
    required this.selectedRepo,
    required this.onRepoChanged,
  });

  final ExtensionInstallStatus installFilter;
  final ValueChanged<String> onInstallChanged;
  final int available;
  final int installed;
  final int updates;
  final ExtensionType typeFilter;
  final ValueChanged<ExtensionType> onTypeChanged;
  final bool enableNsfw;
  final VoidCallback onToggleNsfw;
  final List<DomainExtensionRepo> repos;
  final String selectedRepo;
  final ValueChanged<String> onRepoChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: SizedBox(
        height: 28,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 6,
            children: [
              _StatusPill(
                value: installFilter,
                available: available,
                installed: installed,
                updates: updates,
                onPicked: onInstallChanged,
              ),
              // Hairline divider: install status is a different concern
              // from the category pills, exactly like the reference bar.
              Container(width: 1, height: 16, color: colors.border),
              for (final type in const [
                ExtensionType.all,
                ExtensionType.bangumi,
                ExtensionType.manga,
                ExtensionType.fikushon,
              ])
                SearchPill(
                  label: _typeFilterLabel(type),
                  selected: typeFilter == type,
                  leading: typeFilter == type
                      ? const Icon(FLucideIcons.check, size: 13)
                      : null,
                  onTap: () => onTypeChanged(type),
                ),
              SearchPill(
                label: '18+ ${'extension.nsfw'.i18n}',
                selected: enableNsfw,
                onTap: onToggleNsfw,
              ),
              SearchPickerPill<String>(
                label: 'extension.repo.repository'.i18n,
                currentLabel: selectedRepo.isEmpty
                    ? 'common.all'.i18n
                    : selectedRepo,
                narrowed: selectedRepo.isNotEmpty,
                sheetTitle: 'extension.repo.repository'.i18n,
                options: [
                  SearchOption(value: '', label: 'common.all'.i18n),
                  for (final repo in repos)
                    SearchOption(value: repo.name, label: repo.name),
                ],
                current: selectedRepo,
                // The picker hands back the option's value; '' is the
                // "all repos" sentinel filterByRepo expects.
                onPicked: onRepoChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The status half of the consolidated filter row: the active status with
/// its count — the reference's "Available 18" chip — opening the shared
/// option sheet to switch or clear it (All). Replaces the old three-way
/// segmented row so status and category share one line.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.value,
    required this.available,
    required this.installed,
    required this.updates,
    required this.onPicked,
  });

  final ExtensionInstallStatus value;
  final int available;
  final int installed;
  final int updates;
  final ValueChanged<String> onPicked;

  int? get _count => switch (value) {
    ExtensionInstallStatus.notInstalled => available,
    ExtensionInstallStatus.installed => installed,
    ExtensionInstallStatus.updates => updates,
    ExtensionInstallStatus.all => null,
  };

  @override
  Widget build(BuildContext context) {
    return SearchPill(
      key: const ValueKey('extension-status-pill'),
      label: _statusFilterLabel(value),
      count: _count,
      icon: FLucideIcons.chevronDown,
      selected: value != ExtensionInstallStatus.all,
      onTap: () async {
        final picked = await showSearchOptionSheet<String>(
          context: context,
          title: 'common.status'.i18n,
          selected: _installStatusKey(value),
          options: [
            SearchOption(
              value: 'extension.all',
              label: 'common.all'.i18n,
              icon: FLucideIcons.layers,
            ),
            SearchOption(
              value: 'extension.not_installed',
              label: '${'extension.available'.i18n} ($available)',
              icon: FLucideIcons.download,
            ),
            SearchOption(
              value: 'extension.installed',
              label: '${'extension.installed'.i18n} ($installed)',
              icon: FLucideIcons.check,
            ),
            SearchOption(
              value: 'extension.updates',
              label: '${'extension.updates'.i18n} ($updates)',
              icon: FLucideIcons.circleFadingArrowUp,
            ),
          ],
        );
        // The sheet resolves to null on dismiss — only a real pick refilters.
        if (picked != null) onPicked(picked.value);
      },
    );
  }
}

/// The raw status key [filterByInstallStatus] parses.
String _installStatusKey(ExtensionInstallStatus status) => switch (status) {
  ExtensionInstallStatus.notInstalled => 'extension.not_installed',
  ExtensionInstallStatus.installed => 'extension.installed',
  ExtensionInstallStatus.updates => 'extension.updates',
  ExtensionInstallStatus.all => 'extension.all',
};

/// Display label for the install-status filter.
String _statusFilterLabel(ExtensionInstallStatus status) => switch (status) {
  ExtensionInstallStatus.notInstalled => 'extension.available'.i18n,
  ExtensionInstallStatus.installed => 'extension.installed'.i18n,
  ExtensionInstallStatus.updates => 'extension.updates'.i18n,
  ExtensionInstallStatus.all => 'common.all'.i18n,
};

/// The reference store bar's trailing actions: Repos (jump to repo
/// management) and add/import. Refresh moved to pull-to-refresh on the list.
class _ExtensionHeaderActions extends StatelessWidget {
  const _ExtensionHeaderActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchPill(
          key: const ValueKey('extension-header-repos'),
          label: 'extension.repos'.i18n,
          selected: false,
          leading: const Icon(FLucideIcons.folders, size: 14),
          // 44dp content box: the header pill meets the touch minimum the
          // strip pills deliberately skip.
          minHeight: 44,
          onTap: () => _openRepoSettings(context),
        ),
        const SizedBox(width: 6),
        _HeaderIconButton(
          key: const ValueKey('extension-header-import'),
          icon: FLucideIcons.plus,
          label: 'extension.import.title'.i18n,
          onTap: () => showExtensionImportDialog(context),
        ),
      ],
    );
  }
}

/// Opens the extension repo settings page.
///
/// On mobile the page is pushed onto the current tab's navigator — the
/// same mechanism the settings hub uses for its section tiles — so the
/// shell's tab state and back stack stay intact. Pushing the
/// `/settings/extension` route instead would stack a page from another
/// shell branch on top of `/extension`, leaving the bottom nav out of
/// sync. Desktop keeps the routed navigation to highlight the settings
/// sidebar item.
void _openRepoSettings(BuildContext context) {
  if (DeviceUtil.isMobileLayout(context)) {
    Navigator.of(context).push(
      RouterUtil.createRoute(
        SettingScaffold(
          title: 'settings.extension.name'.i18n,
          child: const SettingExtension(isMobile: true),
        ),
      ),
    );
    return;
  }
  context.go('/settings/extension');
}

/// 44x44 header tap target (the mobile touch minimum) around a 20px glyph;
/// FORUI's [FTappable] supplies the press affordance.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = Icon(
      icon,
      size: 20,
      color: context.theme.colors.mutedForeground,
    );
    return FTappable(
      onPress: onTap,
      semanticsLabel: label,
      child: SizedBox(width: 44, height: 44, child: child),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: context.theme.colors.background.withAlpha(200),
                borderRadius: context.theme.style.borderRadius.md,
                border: Border.all(
                  color: context.theme.colors.border.withAlpha(80),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                  const ExtensionImportButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
