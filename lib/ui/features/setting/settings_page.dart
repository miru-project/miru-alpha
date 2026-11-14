import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/ui/features/setting/setting_network.dart';
import 'package:miru_alpha/ui/features/setting/setting_general.dart';
import 'package:miru_alpha/ui/features/main_page/desktop_sidebar.dart'
    show SafeFSidebar;
import 'package:miru_alpha/utils/router/router_util.dart';
import 'setting_extension.dart';
import 'setting_log.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/provider/dev_tool_provider.dart';
import 'package:miru_alpha/model/setting_items.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final select = useState(SideBarName.general);
    return MiruScaffold.mobile(
      sliverHeaders: [
        SimpleSliverHeaderDelegate(
          maxExtent: 56,
          child: SnapSheetHeader(title: 'common.settings'.i18n),
        ),
      ],
      body: SettingPage(selected: select.value),
    );
  }
}

/// The desktop settings sections that render real content — shared by the
/// settings dialog nav and the deep-link page sidebar. Sections still rendering
/// empty stubs (player, reader, about, tracking, download) stay out until they
/// have something to show.
const settingsSections = <(SideBarName, String, IconData)>[
  (SideBarName.general, 'common.general', FLucideIcons.menu),
  (SideBarName.extension, 'settings.extension.name', FLucideIcons.blocks),
  (SideBarName.network, 'settings.miru_core.name', FLucideIcons.serverCog),
  (SideBarName.advanced, 'settings.logging.name', FLucideIcons.scrollText),
  (SideBarName.developer, 'common.developer', FLucideIcons.code),
];

/// One settings section's content pane (desktop dialog + deep-link page).
class SettingsSectionBody extends ConsumerWidget {
  const SettingsSectionBody({super.key, required this.name});

  final SideBarName name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (name) {
      case SideBarName.general:
        return SettingScaffold(
          title: 'common.general'.i18n,
          child: SettingGeneral(),
        );
      case SideBarName.extension:
        return SettingScaffold(
          title: 'settings.extension.name'.i18n,
          child: SettingExtension(),
        );
      case SideBarName.player:
        // return SettingPlayer();
        return const Center();
      case SideBarName.network:
        return SettingNetwork();
      case SideBarName.reader:
        // return SettingReader();
        return const Center();
      case SideBarName.advanced:
        return SettingScaffold(
          title: 'settings.logging.name'.i18n,
          child: SettingLog(),
        );
      case SideBarName.about:
        return const Center();
      case SideBarName.tracking:
        return const Center();
      case SideBarName.download:
        // return SettingDownload();
        return const Center();
      case SideBarName.developer:
        return SettingScaffold(
          title: 'common.developer'.i18n,
          child: Column(
            children: [
              OutterCard(
                title: 'common.developer'.i18n,
                child: SettingPressTile(
                  isMobileLayout: false,
                  title: 'common.developer'.i18n,
                  subtitle: 'Open DevTools for JS extensions',
                  prefix: Icon(FLucideIcons.terminal),
                  onPress: () => ref.read(devToolProvider.notifier).toggle(),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key, required this.selected});
  final SideBarName selected;
  @override
  createState() => _SettingItemsState();
}

class _SettingItemsState extends ConsumerState<SettingPage> {
  void _pushtoPage(BuildContext context, Widget page) =>
      Navigator.of(context).push(RouterUtil.createRoute(page));
  @override
  Widget build(BuildContext context) {
    return MiruScaffold.mobile(
      sliverHeaders: [
        SimpleSliverHeaderDelegate(
          maxExtent: 56,
          child: SnapSheetHeader(title: 'common.settings'.i18n),
        ),
      ],
      desktopBody: _DesktopSettingsBody(selected: widget.selected),
      slivers: [
        SliverPadding(
          padding: .only(bottom: 80),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              FTileGroup(
                label: Text("settings.general.name".i18n),
                description: Text('settings.general.information'.i18n),
                children: [
                  FTile(
                    prefix: Icon(FLucideIcons.menu),
                    title: Text('common.general'.i18n),
                    suffix: Icon(FLucideIcons.chevronRight),
                    subtitle: Text('settings.general.information'.i18n),
                    onPress: () {
                      _pushtoPage(
                        context,
                        SettingScaffold(
                          title: 'common.general'.i18n,
                          child: SettingGeneral(isMobileLayout: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FTileGroup(
                label: Text('settings.extension.name'.i18n),
                description: Text('settings.extension.information'.i18n),
                children: [
                  FTile(
                    prefix: Icon(FLucideIcons.blocks),
                    title: Text('extension.name'.i18n),
                    subtitle: Text('settings.extension.information'.i18n),
                    // details: const Text('Forus Labs (5G)'),
                    suffix: Icon(FLucideIcons.chevronRight),
                    onPress: () {
                      _pushtoPage(
                        context,
                        SettingScaffold(
                          title: 'settings.extension.name'.i18n,
                          child: SettingExtension(isMobile: true),
                        ),
                      );
                    },
                  ),
                  FTile(
                    prefix: Icon(FLucideIcons.serverCog),
                    title: Text('settings.miru_core.name'.i18n),
                    subtitle: Text('settings.miru_core.information'.i18n),
                    // details: const Text('Forus Labs (5G)'),
                    suffix: Icon(FLucideIcons.chevronRight),
                    onPress: () {
                      _pushtoPage(
                        context,
                        SettingScaffold(
                          title: 'settings.miru_core.name'.i18n,
                          child: SettingNetwork(isMobileLayout: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FTileGroup(
                label: Text("settings.watch.name".i18n),
                description: Text('settings.watch.information'.i18n),
                children: [
                  FTile(
                    prefix: Icon(FLucideIcons.tv),
                    title: Text('common.player'.i18n),
                    subtitle: Text('settings.watch.information'.i18n),
                    // details: const Text('Forus Labs (5G)'),
                    suffix: Icon(FLucideIcons.chevronRight),
                    onPress: () {},
                  ),
                  FTile(
                    prefix: Icon(FLucideIcons.bookOpen),
                    title: Text('common.reader'.i18n),
                    subtitle: Text('settings.watch.information'.i18n),
                    // details: const Text('Forus Labs (5G)'),
                    suffix: Icon(FLucideIcons.chevronRight),
                    onPress: () {},
                  ),
                ],
              ),
              FTileGroup(
                label: Text("settings.about.name".i18n),
                // description: const Text('Personalize your experience'),
                children: [
                  FTile(
                    prefix: Icon(FLucideIcons.scrollText),
                    title: Text('settings.logging.name'.i18n),
                    subtitle: Text('settings.logging.information'.i18n),
                    suffix: Icon(FLucideIcons.chevronRight),
                    onPress: () {
                      _pushtoPage(
                        context,
                        SettingScaffold(
                          title: 'settings.logging.name'.i18n,
                          child: SettingLog(isMobileLayout: true),
                        ),
                      );
                    },
                  ),
                  FTile(
                    prefix: Icon(FLucideIcons.code),
                    title: Text('common.licenses'.i18n),
                    // details: const Text('Forus Labs (5G)'),
                    suffix: Icon(FLucideIcons.chevronRight),
                    onPress: () {
                      context.push('/license');
                    },
                  ),
                  FTile(
                    prefix: Icon(FLucideIcons.terminal),
                    title: const Text('Developer Tool'),
                    suffix: Icon(FLucideIcons.chevronRight),
                    onPress: () {
                      context.push('/devTool');
                    },
                  ),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Desktop settings shell for the deep-link routes: the header gear opens the
/// settings DIALOG (primary UX); this page remains the `/settings/<name>`
/// fallback with its own section sidebar + content pane.
class _DesktopSettingsBody extends StatelessWidget {
  const _DesktopSettingsBody({required this.selected});

  final SideBarName selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      crossAxisAlignment: .stretch,
      children: [
        SafeFSidebar(
          width: 200,
          header: Padding(
            padding: .symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'common.settings'.i18n,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FDivider(
                  style: FDividerStyleDelta.delta(
                    padding: EdgeInsetsGeometryDelta.value(.only(bottom: 5)),
                  ),
                ),
              ],
            ),
          ),
          children: [
            FSidebarGroup(
              label: const SizedBox.shrink(),
              children: [
                for (final (name, labelKey, icon) in settingsSections)
                  FSidebarItem(
                    selected: selected == name,
                    icon: Icon(icon),
                    label: Text(labelKey.i18n),
                    onPress: () => context.go('/settings/${name.name}'),
                  ),
              ],
            ),
          ],
        ),
        Container(width: 1, color: colors.border),
        Expanded(child: SettingsSectionBody(name: selected)),
      ],
    );
  }
}
