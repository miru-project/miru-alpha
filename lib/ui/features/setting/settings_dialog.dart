import 'package:material_ui/material_ui.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/setting_items.dart';
import 'package:miru_alpha/ui/core/dialog/dialog.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/main_page/desktop_sidebar.dart'
    show SafeFSidebar;
import 'package:miru_alpha/ui/features/setting/settings_page.dart'
    show SettingsSectionBody, settingsSections;
import 'package:miru_alpha/utils/core/i18n.dart';

/// VSCode-style desktop settings modal (user directive 2026-11-12): the
/// header gear opens this dialog — title + X + section nav beside the content
/// pane — instead of routing to a settings page. The `/settings/<name>` routes
/// remain as deep-link fallbacks (mobile keeps its page flow).
Future<void> showSettingsDialog(BuildContext context) => showMiruDialog(
  context: context,
  builder: (context, style, animation) => FTheme(
    data: context.theme,
    child: FDialog(
      constraints: const BoxConstraints(maxWidth: 980, maxHeight: 680),
      builder: (context, dialogStyle) => const _SettingsDialogBody(),
    ),
  ),
);

class _SettingsDialogBody extends HookConsumerWidget {
  const _SettingsDialogBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(SideBarName.general);
    final colors = context.theme.colors;
    return SizedBox(
      width: 940,
      height: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title bar: Settings + close X (the dialog's only chrome).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                Text(
                  'common.settings'.i18n,
                  style: context.theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: () => Navigator.of(context).pop(),
                  child: Icon(FLucideIcons.x, size: 18),
                ),
              ],
            ),
          ),
          FDivider(
            style: FDividerStyleDelta.delta(
              padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: .stretch,
              children: [
                SafeFSidebar(
                  width: 200,
                  children: [
                    FSidebarGroup(
                      label: const SizedBox.shrink(),
                      children: [
                        for (final (name, labelKey, icon) in settingsSections)
                          FSidebarItem(
                            // forui's inherited item fill is colors.background —
                            // invisible on the page (bg-on-bg) but a dark slab on the
                            // dialog's card surface (theme seam). Base goes
                            // transparent so the dialog surface shows through;
                            // selected/hover keep forui's secondary fill.
                            style: .delta(
                              backgroundColor:
                                  FVariantsValueDelta<
                                    FTappableVariantConstraint,
                                    FTappableVariant,
                                    Color,
                                    Delta
                                  >.delta([
                                    FVariantValueDeltaOperation.base(
                                      Colors.transparent,
                                    ),
                                  ]),
                            ),
                            selected: selected.value == name,
                            icon: Icon(icon),
                            label: Text(labelKey.i18n),
                            onPress: () => selected.value = name,
                          ),
                      ],
                    ),
                  ],
                ),
                Container(width: 1, color: colors.border),
                Expanded(child: SettingsSectionBody(name: selected.value)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
