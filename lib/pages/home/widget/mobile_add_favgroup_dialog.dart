import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/favorite_page_provider.dart';

class MobileAddFAVDialog extends HookConsumerWidget {
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
    final textController = useTextEditingController();
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
              Text(
                'favorite.manage_tags'.i18n,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'favorite.manage_tags_desc'.i18n,
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
                        controller: textController,
                        onChange: (value) {
                          newFavGroupName = value.text;
                        },
                      ),
                      label: Text('favorite.add_new_group'.i18n),
                      hint: 'favorite.enter_group_name'.i18n,
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
                        textController.clear();
                      },
                      child: Icon(FIcons.plus),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'favorite.current_groups'.i18n,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
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
