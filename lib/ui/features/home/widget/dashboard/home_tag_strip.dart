import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/core/dialog/dialog.dart';
import 'package:miru_alpha/ui/features/favorite/widget/favorite_group_sheet.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// "Favorite Tags" — the favorite-group chip strip. The selected chip
/// scopes the Dynamic Feed below it; Manage opens the tag manager and the
/// trailing "Favorites (N)" pill enters the favorites page. This header is
/// the dashboard's local-collection hub: the Quick Access Favorites tile was
/// consolidated here (UX audit round 2 — duplicate pathway). The strip's
/// right edge fades out (mockup `mask-image`) to hint at the scrollable
/// overflow.
class HomeTagStrip extends ConsumerWidget {
  const HomeTagStrip({super.key, this.horizontalPadding = 16});

  /// The page gutter the header and chip rail align to; the desktop dashboard
  /// passes its wider 28px edge, mobile keeps the default 16.
  final double horizontalPadding;

  static const _chipHeight = 34.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(
      favoritePageProvider.select((s) => s.favoriteGroups),
    );
    final hidden = watchHiddenExtensions(ref);
    // Tags whose every favorite belongs to a hidden extension disappear;
    // empty tags are the user's own and stay.
    final visibleGroups = groups.where((g) => tagVisible(g, hidden)).toList();
    final selectedFavGrp = ref.watch(
      favoritePageProvider.select((s) => s.selectedFavoriteGroups),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: HomeSectionHeader(
            // No leading glyph: the hash read as noise next to the title
            // (UX-review) — the strip's chips carry the tag identity.
            title: 'home.favorite_tags'.i18n,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 4),
                FButton(
                  variant: .ghost,
                  mainAxisSize: .min,
                  // "Manage" opens the SAME tag manager the favorites page
                  // uses (showFavoriteGroupSheet) — one surface, no route
                  // jump and no second implementation.
                  onPress: () => showFavoriteGroupSheet(context),
                  suffix: const Icon(FLucideIcons.penLine, size: 14),
                  style: .delta(
                    contentStyle: FButtonContentStyleDelta.delta(
                      constraints: const BoxConstraints(minHeight: 28),
                      padding: EdgeInsetsGeometryDelta.value(
                        const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  child: Text('common.manage'.i18n),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0, 0.85, 1],
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00000000)],
          ).createShader(bounds),
          child: SizedBox(
            height: _chipHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: visibleGroups.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => index == visibleGroups.length
                  ? _NewTagChip(onAdd: () => _showNewTagDialog(context, ref))
                  : _GroupChip(
                      group: visibleGroups[index],
                      hidden: hidden,
                      selected: selectedFavGrp.any(
                        (g) =>
                            favoriteGroupKey(g.name) ==
                            favoriteGroupKey(visibleGroups[index].name),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupChip extends ConsumerWidget {
  const _GroupChip({
    required this.group,
    required this.hidden,
    required this.selected,
  });

  final FavoriteGroup group;
  final Set<String> hidden;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FButton(
      variant: selected ? .primary : .outline,
      mainAxisSize: .min,
      onPress: () =>
          ref.read(favoritePageProvider.notifier).toggleGroupName(group.name),
      prefix: selected ? const Icon(FLucideIcons.check, size: 13) : null,
      style: .delta(
        contentStyle: FButtonContentStyleDelta.delta(
          constraints: const BoxConstraints(minHeight: 34),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 14),
          ),
        ),
      ),
      child: Text(favoriteGroupLabel(group, hidden)),
    );
  }
}

class _NewTagChip extends StatelessWidget {
  const _NewTagChip({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: .ghost,
      mainAxisSize: .min,
      onPress: onAdd,
      prefix: const Icon(FLucideIcons.plus, size: 14),
      style: .delta(
        contentStyle: FButtonContentStyleDelta.delta(
          constraints: const BoxConstraints(minHeight: 34),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ),
      child: Text('common.new_tag'.i18n),
    );
  }
}

/// Inline group creation — the strip's own add flow, persisted through the
/// favorites provider (unlike the legacy dialog's state-only add). Public so
/// the desktop shelves row reuses the same dialog instead of a second one.
Future<void> showCreateFavoriteGroupDialog(
  BuildContext context,
  WidgetRef ref,
) => _showNewTagDialog(context, ref);

Future<void> _showNewTagDialog(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  try {
    final name = await showMiruDialog<String>(
      context: context,
      title: Text('common.new_tag'.i18n),
      body: FTextField(
        control: .managed(controller: controller),
        label: Text('favorite.add_new_group'.i18n),
        hint: 'favorite.enter_group_name'.i18n,
        onSubmit: (value) => Navigator.of(context).pop(controller.text.trim()),
      ),
      actions: [
        FButton(
          variant: .ghost,
          onPress: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.i18n),
        ),
        FButton(
          onPress: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text('common.confirm'.i18n),
        ),
      ],
    );
    if (name == null || name.isEmpty) return;
    await ref.read(favoritePageProvider.notifier).createFavoriteGroup(name);
  } finally {
    controller.dispose();
  }
}
