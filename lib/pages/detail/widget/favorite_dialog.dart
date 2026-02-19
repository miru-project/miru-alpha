import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/provider/favorite_page_provider.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/widgets/core/toast.dart';

class FavoriteDialog extends HookConsumerWidget {
  const FavoriteDialog({
    super.key,
    required this.meta,
    required this.detailUrl,
    required this.detail,
    required this.detailPr,
  });

  final String detailUrl;
  final Detail detail;
  final ExtensionMeta meta;
  final DetialProvider detailPr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGroups = ref.watch(
      favoritePageProvider.select((e) => e.favoriteGroups),
    );
    final groupsWithFav = ref.watch(
      favoritePageProvider.select(
        (e) => e.favoriteGroups
            .where((e) => e.favorites.any((e) => e.url == detailUrl))
            .toList(),
      ),
    );
    final selectedGroups = useState<Set<String>>(
      groupsWithFav.map((e) => e.name).toSet(),
    );
    // final isLoading = useState(true);
    final isCreatingGroup = useState(false);
    final newGroupNameController = useTextEditingController();
    final textFieldKey = useState(UniqueKey());

    Future<void> handleSave() async {
      try {
        // 1. Put Favorite Item first (ensure it exists)
        final fav = await DatabaseService.putFavorite(
          detailUrl,
          detail,
          meta.packageName,
          meta.type,
        );

        // 2. Update Groups
        final groupsToUpdate = <FavoriteGroup>[];

        for (final group in allGroups) {
          bool isSelected = selectedGroups.value.contains(group.name);
          bool hasFav = group.favorites.any((f) => f.id == fav.id);

          if (isSelected && !hasFav) {
            // Add
            group.favorites.add(fav);
            groupsToUpdate.add(group);
          } else if (!isSelected && hasFav) {
            // Remove
            group.favorites.removeWhere((f) => f.id == fav.id);
            groupsToUpdate.add(group);
          }
        }

        if (groupsToUpdate.isNotEmpty) {
          await DatabaseService.putFavoriteByIndex(groupsToUpdate);
        }
        ref.read(detailPr.notifier).putFavorite(fav);
        ref.read(detailPr.notifier).putFavoriteGroup(groupsToUpdate);
        ref.read(favoritePageProvider.notifier).refreshFavoritesAndGroup();
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) showSimpleToast("Favorites updated");
      } catch (e) {
        debugPrint("Error saving favorite: $e");
        if (context.mounted) showSimpleToast("Error saving: $e");
      } finally {
        // isLoading.value = false;
      }
    }

    Future<void> handleCreateGroup() async {
      final text = newGroupNameController.text;
      if (text.isEmpty) return;
      try {
        ref.read(favoritePageProvider.notifier).createFavoriteGroup(text);
        selectedGroups.value = {...selectedGroups.value, text};

        // Clear text
        newGroupNameController.clear();
        textFieldKey.value = UniqueKey();

        isCreatingGroup.value = false;
      } catch (e) {
        if (context.mounted) showSimpleToast("Error creating group: $e");
      }
    }

    return FDialog(
      title: const Text("Add to Favorites"),
      body: Padding(
        padding: EdgeInsetsGeometry.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select tags/groups for this item:"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 3,
              runSpacing: 3,
              children: allGroups.map((group) {
                final isSelected = selectedGroups.value.contains(group.name);
                return FTappable(
                  onPress: () {
                    if (isSelected) {
                      selectedGroups.value = selectedGroups.value
                          .where((name) => name != group.name)
                          .toSet();
                    } else {
                      selectedGroups.value = {
                        ...selectedGroups.value,
                        group.name,
                      };
                    }
                  },
                  child: FBadge(
                    variant: isSelected ? .android : .outline,
                    child: Text(group.name),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            if (isCreatingGroup.value)
              Row(
                children: [
                  Expanded(
                    child: FTextField(
                      key: textFieldKey.value,
                      control: FTextFieldControl.managed(
                        initial: TextEditingValue.empty,
                        onChange: (val) =>
                            newGroupNameController.text = val.text,
                      ),
                      hint: "Group Name",
                    ),
                  ),
                  const SizedBox(width: 8),
                  FButton(onPress: handleCreateGroup, child: const Text("Add")),
                  const SizedBox(width: 8),
                  FButton(
                    variant: .ghost,
                    onPress: () => isCreatingGroup.value = false,
                    child: const Icon(FIcons.x),
                  ),
                ],
              )
            else
              FButton(
                variant: .outline,
                onPress: () => isCreatingGroup.value = true,
                child: const Text("Create New Tag"),
              ),
          ],
        ),
      ),
      actions: [
        FButton(
          variant: .ghost,
          onPress: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FButton(onPress: handleSave, child: const Text("Save")),
      ],
    );
  }
}
