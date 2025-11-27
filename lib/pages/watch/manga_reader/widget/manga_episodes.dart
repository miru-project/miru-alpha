import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';

class MangaEpisodes extends HookConsumerWidget {
  const MangaEpisodes({super.key, required this.epProvider});
  final EpisodeNotifierProvider epProvider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectGroupIdx = useState(0);
    final controller = useFPopoverController();
    final epGroup = ref.watch(epProvider.select((value) => value.epGroup));
    return Column(
      children: [
        FPopoverMenu.tiles(
          menuAnchor: .topCenter,
          menu: [
            FTileGroup.builder(
              tileBuilder: (context, idx) {
                return FTile(
                  onPress: () {
                    selectGroupIdx.value = idx;
                  },
                  title: Text(epGroup[idx].title),
                );
              },
              count: epGroup.length,
            ),
          ],
          popoverController: controller,
          child: FButton(
            suffix: Icon(
              FIcons.chevronsUpDown,
              color: context.theme.colors.primary,
            ),
            mainAxisAlignment: .start,
            style: FButtonStyle.ghost(),
            onPress: () {
              controller.toggle();
            },
            child: Text(
              epGroup[selectGroupIdx.value].title,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),

        FTileGroup.builder(
          tileBuilder: (context, idx) {
            return FTile(
              onPress: () {
                ref
                    .read(epProvider.notifier)
                    .selectEpisode(selectGroupIdx.value, idx);
              },
              title: Text(epGroup[selectGroupIdx.value].urls[idx].name),
            );
          },
          count: epGroup[selectGroupIdx.value].urls.length,
        ),
      ],
    );
  }
}
