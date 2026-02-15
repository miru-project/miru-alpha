import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/widgets/core/toast.dart';

class FavoriteDialog extends HookConsumerWidget {
  const FavoriteDialog({
    super.key,
    required this.meta,
    required this.detailUrl,
    required this.detail,
    required this.onSuccess,
  });

  final String detailUrl;
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  final void Function(Favorite, List<FavoriateGroup>) onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGroups = useState<List<FavoriateGroup>>([]);
    final selectedGroups = useState<List<int>>([]);
    final isLoading = useState(true);
    final isCreatingGroup = useState(false);
    final newGroupNameController = useTextEditingController();
    final textFieldKey = useState(UniqueKey());

    // Initial Load
    useEffect(() {
      Future.microtask(() async {
        try {
          // 1. Fetch Key Data
          final groups = await DatabaseService.getAllFavoriteGroup();
          allGroups.value = groups;

          // 2. Check current status
          final groupsWithFav =
              await DatabaseService.getFavoriteGroupsByFavorite(
                meta.packageName,
                detailUrl,
              );

          // 3. Mark selected
          final selectedIds = <int>[];
          for (var g in groupsWithFav) {
            final match = groups.indexWhere((element) => element.id == g.id);
            if (match != -1) {
              selectedIds.add(groups[match].id);
            }
          }
          selectedGroups.value = selectedIds;
        } catch (e) {
          debugPrint("Error loading favorites: $e");
          if (context.mounted) showSimpleToast("Error loading favorites: $e");
        } finally {
          isLoading.value = false;
        }
      });
      return null;
    }, []);

    Future<void> handleSave() async {
      try {
        isLoading.value = true;
        // 1. Put Favorite Item first (ensure it exists)
        final fav = await DatabaseService.putFavorite(
          detailUrl,
          detail,
          meta.packageName,
          meta.type,
        );

        // 2. Update Groups
        final groupsToUpdate = <FavoriateGroup>[];

        for (final group in allGroups.value) {
          bool isSelected = selectedGroups.value.contains(group.id);
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

        onSuccess(fav, groupsToUpdate);
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) showSimpleToast("Favorites updated");
      } catch (e) {
        debugPrint("Error saving favorite: $e");
        if (context.mounted) showSimpleToast("Error saving: $e");
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleCreateGroup() async {
      final text = newGroupNameController.text;
      if (text.isEmpty) return;
      try {
        final newGroup = await DatabaseService.putFavoriteGroup(text);
        allGroups.value = [...allGroups.value, newGroup];
        selectedGroups.value = [...selectedGroups.value, newGroup.id];

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
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsetsGeometry.only(top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select tags/groups for this item:"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allGroups.value.map((group) {
                      final isSelected = selectedGroups.value.contains(
                        group.id,
                      );
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            selectedGroups.value = selectedGroups.value
                                .where((id) => id != group.id)
                                .toList();
                          } else {
                            selectedGroups.value = [
                              ...selectedGroups.value,
                              group.id,
                            ];
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
                        FButton(
                          onPress: handleCreateGroup,
                          child: const Text("Add"),
                        ),
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
