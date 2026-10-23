import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/core/widget/miru_segmented_control.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Opens the tag manager as a low-height bottom sheet.
///
/// Every edit commits straight to [favoritePageProvider], so the feed behind
/// the sheet updates live while it is open — there is no Apply/Done step; a
/// barrier tap, back gesture or drag dismisses. The barrier is tinted lighter
/// than forui's default so the live update stays readable behind it
/// (UX-review: real-time preview, top half of the screen visible).
Future<void> showFavoriteGroupSheet(BuildContext context) {
  return showFSheet<void>(
    context: context,
    side: .btt,
    style: .delta(
      barrierFilter: (context, animation) => ColorFilter.mode(
        Color.lerp(
          const Color(0x00000000),
          context.theme.colors.barrier.withValues(alpha: 0.25),
          animation,
        )!,
        .srcOver,
      ),
    ),
    builder: (context) => const FavoriteGroupSheet(),
  );
}

class FavoriteGroupSheet extends HookConsumerWidget {
  const FavoriteGroupSheet({super.key});

  /// Height of everything in the sheet except the chip CONTENT: paddings +
  /// 48px handle + title + desc + three section labels + add row + segmented
  /// control. Measured against the live widget tree (test surface 400x900:
  /// fixed 338 + one 44px chip = 382), not guessed.
  static const _fixedHeight = 338.0;

  /// The sheet must not pass mid-screen: the feed above stays visible for
  /// the live preview.
  static const _maxSheetRatio = 0.45;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteGrp = ref.watch(
      favoritePageProvider.select((e) => e.favoriteGroups),
    );
    final selectedFavGrp = ref.watch(
      favoritePageProvider.select((e) => e.selectedFavoriteGroups),
    );
    final filterMode = ref.watch(
      favoritePageProvider.select((e) => e.filterMode),
    );
    final textController = useTextEditingController();

    // The chip area takes whatever is left of the sheet's height budget.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final chipViewport = ((screenHeight * _maxSheetRatio) - _fixedHeight).clamp(
      44.0,
      120.0,
    );

    void addGroup() {
      final name = textController.text.trim();
      if (name.isEmpty) return;
      ref.read(favoritePageProvider.notifier).addFavoriteGroupbyName(name);
      textController.clear();
    }

    void toggleGroup(FavoriteGroup group) =>
        // By name: the strip and this sheet toggle the SAME selection, so
        // picking a group here updates the homepage's strip and feed live.
        ref.read(favoritePageProvider.notifier).toggleGroupName(group.name);

    void deleteGroup(FavoriteGroup group) {
      ref.read(favoritePageProvider.notifier).deleteFavoriteGroup(group);
      // A deleted group cannot stay selected.
      if (selectedFavGrp.any((g) => g.name == group.name)) {
        ref
            .read(favoritePageProvider.notifier)
            .filterFavoriteGroups(
              selectedFavGrp.where((g) => g.name != group.name).toList(),
            );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      // Low-height sheet: the feed above stays visible for live preview, so
      // the body is kept dense (UX-review: sheet must not pass mid-screen).
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle in a 48x48 touch container — the bar itself is 4px,
          // but the target around it is thumb-sized (the sheet's own drag
          // detector covers it).
          SizedBox(
            height: 48,
            width: 48,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.theme.colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Text(
            'favorite.select_groups'.i18n,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'favorite.select_groups_desc'.i18n,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('favorite.add_new_group'.i18n),
          // Gestalt proximity: the label sits close to the field it owns
          // (8px) and far from the section above (16px).
          const SizedBox(height: 8),
          // Label lives in the section header, not the field (rules.md #23),
          // so field and button share one centered row instead of the button
          // floating beside a label-offset field. The row is locked to 48dp
          // so field and button are flush.
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FTextField(
                    control: .managed(controller: textController),
                    hint: 'favorite.enter_group_name'.i18n,
                    onSubmit: (_) => addGroup(),
                    // Explicit stroke: the default 10%-white border disappears
                    // against the card fill on a dark surface.
                    style: .delta(
                      border: FVariantsValueDelta.delta([
                        FVariantValueDeltaOperation.base(
                          OutlineInputBorder(
                            borderSide: BorderSide(
                              color: context.theme.colors.mutedForeground
                                  .withValues(alpha: 0.35),
                              width: context.theme.style.borderWidth,
                            ),
                            borderRadius: context.theme.style.borderRadius.md,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Labelled action, not a bare square +: the row's purpose is
                // readable and the button is a full 48dp target.
                FButton(
                  mainAxisSize: .min,
                  prefix: const Icon(FLucideIcons.plus, size: 16),
                  onPress: addGroup,
                  style: .delta(
                    contentStyle: FButtonContentStyleDelta.delta(
                      constraints: const BoxConstraints(minHeight: 48),
                    ),
                  ),
                  child: Text('common.add'.i18n),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('favorite.filter_mode'.i18n),
          const SizedBox(height: 8),
          // Radio-segment pattern: the active mode is a solid primary fill
          // with a filled dot; the inactive one is a muted outline with an
          // empty ring and dimmed label. The track takes `colors.card` —
          // the default inset (`colors.background`) vanishes on a sheet that
          // is itself `colors.background`.
          MiruSegmentedControl<FavoriteFilterMode>(
            segments: [
              MiruSegment(value: .and, label: 'favorite.and'.i18n),
              MiruSegment(value: .or, label: 'favorite.or'.i18n),
            ],
            selected: filterMode,
            selectedVariant: .primary,
            unselectedVariant: .outline,
            selectionMarkers: true,
            dimUnselectedText: true,
            trackColor: context.theme.colors.card,
            onSelected: (mode) =>
                ref.read(favoritePageProvider.notifier).setFilterMode(mode),
          ),
          const SizedBox(height: 16),
          _SectionLabel('favorite.current_groups'.i18n),
          const SizedBox(height: 8),
          // Chips flow directly on the sheet background — wrapping short
          // chips in a second box added an unnecessary layer (UX-review).
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: chipViewport),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final group in favoriteGrp)
                    _GroupChip(
                      group: group,
                      selected: selectedFavGrp.any((g) => g.name == group.name),
                      onToggle: () => toggleGroup(group),
                      onDelete: () => deleteGroup(group),
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

/// Label of a BROWSING chip (the dashboard's favorite-tag strip).
///
/// The count is informative while browsing but noise in a selection sheet —
/// [FavoriteGroupSheet] chips show the bare name (UX-review: hide secondary
/// counters during selection). Zeros are suppressed either way: an empty
/// group reads as `anime1`, a populated one as `test (3)`.
String favoriteGroupLabel(FavoriteGroup group) {
  final count = group.favorites.length;
  return count == 0 ? group.name : '${group.name} ($count)';
}

/// A group chip with the removal trigger INSIDE the chip boundary.
///
/// The chip is an [FButton] (forui's own pill + selected/unselected
/// variants); the ✕ rides in the button's `suffix` slot as its own 44×44
/// tap target, 12px from the label. The inner target wins the gesture arena,
/// so tapping ✕ deletes while tapping the label toggles selection.
class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.group,
    required this.selected,
    required this.onToggle,
    required this.onDelete,
  });
  final FavoriteGroup group;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: selected ? .primary : .outline,
      mainAxisSize: .min,
      size: .sm,
      onPress: onToggle,
      // The ✓ gets its own 6px margin — the row's spacing is 0 (the ✕ gap
      // is hand-tuned below), which otherwise sat the check flush against
      // the label.
      prefix: selected
          ? const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(FLucideIcons.check, size: 13),
            )
          : null,
      style: .delta(
        contentStyle: FButtonContentStyleDelta.delta(
          // The suffix target is 44 tall, so the chip itself is 44 tall and
          // the vertical padding goes to zero.
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.only(left: 14, right: 8),
          ),
          spacing: 0,
        ),
      ),
      suffix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: FTappable(
          onPress: onDelete,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              FLucideIcons.x,
              size: 18,
              color: selected
                  ? context.theme.colors.primaryForeground
                  : context.theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
      child: Text(group.name),
    );
  }
}

/// Section label — one casing for every section in the sheet.
///
/// Same micro-label treatment as the search filter panel
/// (`filter_dialog_panel.dart`): uppercase, small, muted.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: context.theme.colors.mutedForeground,
      ),
    );
  }
}
