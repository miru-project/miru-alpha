import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/user_data.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/widgets/core/miru_tabs.dart';

class FavoriteTab extends StatefulHookConsumerWidget {
  const FavoriteTab({super.key, this.onGroupChanged});
  final VoidCallback? onGroupChanged;

  @override
  createState() => _FavoriteTabState();
}

class _FavoriteTabState extends ConsumerState<FavoriteTab> {
  final ValueNotifier<List<FavoriateGroup>> favGroup = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  Future<void> _refreshGroups() async {
    favGroup.value = await DatabaseService.getAllFavoriteGroup();
    widget.onGroupChanged?.call();
  }

  String text = '';
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final errorText = useState<String?>(null);
    final isCreating = useState(false);
    final textFieldKey = useState(UniqueKey());

    textController.addListener(() {
      text = textController.text;
      if (text.isEmpty) {
        errorText.value = 'Name is empty';
        return;
      }
      if (favGroup.value.any((element) => element.name == text)) {
        errorText.value = 'Same name exists';
        return;
      }
      errorText.value = null;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Favorites",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              const Spacer(),
              if (!isCreating.value)
                FButton(
                  style: FButtonStyle.outline(),
                  onPress: () {
                    isCreating.value = true;
                    textController.clear();
                    textFieldKey.value = UniqueKey();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FIcons.plus),
                      SizedBox(width: 4),
                      Text("New Tag"),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              SizedBox(
                width: 400,
                height: 60,
                child: MiruTabs(
                  children: [
                    FTabEntry(label: Text('All'), child: Text('ALL')),
                    FTabEntry(label: Text('Video'), child: Text('Video')),
                    FTabEntry(label: Text('Manga'), child: Text('Manga')),
                    FTabEntry(label: Text('Novel'), child: Text('Novel')),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: FSelect<String>.rich(
                      prefixBuilder: (context, style, states) => Padding(
                        padding: const .only(left: 14, right: 8),
                        child: Text(
                          "Sort:",
                          style: style.emptyTextStyle.copyWith(
                            color: context.theme.colors.foreground,
                          ),
                        ),
                      ),
                      hint: 'Time',
                      format: (s) => s,
                      children: [
                        for (final sort in ['Day', 'Week', 'Month', 'Year'])
                          FSelectItem(title: Text(sort), value: sort),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FButton(
                    onPress: () {},
                    style: FButtonStyle.outline(),
                    prefix: Icon(FIcons.listFilter),
                    child: Text('More filter'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ValueListenableBuilder(
          //   valueListenable: favGroup,
          //   builder: (context, favGroupValue, _) => Wrap(
          //     spacing: 8,
          //     runSpacing: 8,
          //     children: [
          //       // New Tag Input
          //       if (isCreating.value)
          //         SizedBox(
          //           width: 200,
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               Expanded(
          //                 child: FTextField(
          //                   key: textFieldKey.value,
          //                   control: FTextFieldControl.managed(
          //                     initial: TextEditingValue.empty,
          //                     onChange: (val) => textController.text = val.text,
          //                   ),
          //                   hint: "Tag Name",
          //                 ),
          //               ),
          //               const SizedBox(width: 4),
          //               FButton.icon(
          //                 onPress: errorText.value == null
          //                     ? () async {
          //                         if (textController.text.isNotEmpty) {
          //                           await DatabaseService.putFavoriteGroup(
          //                             textController.text,
          //                           );
          //                           await _refreshGroups();
          //                           isCreating.value = false;
          //                           textController.clear();
          //                         }
          //                       }
          //                     : null,
          //                 child: const Icon(FIcons.check),
          //               ),
          //               const SizedBox(width: 4),
          //               FButton.icon(
          //                 style: FButtonStyle.ghost(),
          //                 onPress: () => isCreating.value = false,
          //                 child: const Icon(FIcons.x),
          //               ),
          //             ],
          //           ),
          //         ),

          //       // Existing Tags
          //       ...List.generate(favGroupValue.length, (index) {
          //         final group = favGroupValue[index];
          //         final isSelected = selected.contains(index);

          //         return GestureDetector(
          //           onTap: () {
          //             final update = List<int>.from(selected);
          //             if (selected.contains(index)) {
          //               update.remove(index);
          //             } else {
          //               update.add(index);
          //             }
          //             ref.read(mainProvider.notifier).setSelectedGroups(update);
          //           },
          //           child: FPopover(
          //             popoverBuilder: (context, popController) => IntrinsicWidth(
          //               child: Column(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   const Text(
          //                     'Edit Tag',
          //                     style: TextStyle(fontWeight: FontWeight.bold),
          //                   ),
          //                   const SizedBox(height: 10),
          //                   FTextField(
          //                     control: FTextFieldControl.managed(
          //                       initial: TextEditingValue(text: group.name),
          //                       onChange: (val) =>
          //                           textController.text = val.text,
          //                     ),
          //                     hint: "Name",
          //                   ),
          //                   const SizedBox(height: 10),
          //                   Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       FButton.icon(
          //                         style: FButtonStyle.destructive(),
          //                         onPress: () async {
          //                           await DatabaseService.deleteFavoriteGroup([
          //                             group.name,
          //                           ]);
          //                           ref
          //                               .read(mainProvider.notifier)
          //                               .setSelectedGroups([]);
          //                           await _refreshGroups();
          //                           popController.hide();
          //                         },
          //                         child: const Icon(FIcons.trash),
          //                       ),
          //                       const SizedBox(width: 8),
          //                       FButton.icon(
          //                         onPress: () async {
          //                           if (textController.text.isNotEmpty) {
          //                             await DatabaseService.renameFavoriteGroup(
          //                               group.name,
          //                               textController.text,
          //                             );
          //                             await _refreshGroups();
          //                             popController.hide();
          //                           }
          //                         },
          //                         child: const Icon(FIcons.check),
          //                       ),
          //                     ],
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             child: FBadge(
          //               style: isSelected
          //                   ? FBadgeStyle.primary()
          //                   : FBadgeStyle.outline(),
          //               child: Text(group.name),
          //             ),
          //           ),
          //         );
          //       }),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
