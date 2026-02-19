import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/favorite_page_provider.dart';

class MobileAddFAVDialog extends ConsumerWidget {
  final Animation<double> animation;
  final BuildContext context;
  final FDialogStyle style;
  const MobileAddFAVDialog({
    super.key,
    required this.animation,
    required this.context,
    required this.style,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteGrp = ref.watch(
      favoritePageProvider.select((e) => e.favoriteGroups),
    );
    final selectedFavGrp = ref.watch(
      favoritePageProvider.select((e) => e.selectedFavoriteGroups),
    );
    String newFavGroupName = '';
    return Container(
      alignment: .topStart,
      child: FDialog.raw(
        animation: animation,
        builder: (context, style) => Padding(
          padding: .symmetric(vertical: 20, horizontal: 25),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              const Text(
                'Manage Tags',
                style: TextStyle(fontWeight: .bold, fontSize: 19),
              ),
              SizedBox(height: 5),
              Text(
                'Organize your group by creating and managing favorite groups.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: FTextField(
                      control: .managed(
                        onChange: (value) {
                          newFavGroupName = value.text;
                        },
                      ),
                      label: Text('Add a new favorite group'),
                      hint: 'Enter group name...',
                    ),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: .only(top: 20),
                    child: FButton.icon(
                      variant: .android,
                      onPress: () {
                        ref
                            .read(favoritePageProvider.notifier)
                            .addFavoriteGroupbyName(newFavGroupName);
                      },
                      child: Icon(FIcons.plus),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'CURRENT GROUPS',
                style: TextStyle(
                  fontWeight: .w500,
                  fontSize: 15,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: SingleChildScrollView(
                  child: Wrap(
                    children: favoriteGrp
                        .map(
                          (e) => FTappable(
                            onPress: () {
                              if (selectedFavGrp.contains(e)) {
                                final newSelectGrp = selectedFavGrp
                                    .where((element) => element != e)
                                    .toList();
                                ref
                                    .read(favoritePageProvider.notifier)
                                    .filterFavoriteGroups(newSelectGrp);
                              } else {
                                final newSelectGrp = [...selectedFavGrp, e];
                                ref
                                    .read(favoritePageProvider.notifier)
                                    .filterFavoriteGroups(newSelectGrp);
                              }
                            },
                            child: FBadge(
                              variant: selectedFavGrp.contains(e)
                                  ? .android
                                  : .secondary,
                              child: Text(e.name),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
