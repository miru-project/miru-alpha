import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';

class SideSettingsMenu extends HookConsumerWidget {
  const SideSettingsMenu({
    super.key,
    required this.vidPr,
    required this.epProvdier,
    required this.width,
  });

  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvdier;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epController = ref.watch(epProvdier);
    final epNotifier = ref.read(epProvdier.notifier);
    final controller = ref.read(vidPr);
    final notifier = ref.read(vidPr.notifier);

    final tabs = [
      (icon: FIcons.tv, text: 'Episode'),
      (icon: FIcons.ratio, text: 'Resolution'),
      (icon: FIcons.captions, text: 'Subtitle'),
    ];

    final dialogContent = [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: epController.epGroup.length,
              itemBuilder: (context, index) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: FAccordion(
                      style: (style) =>
                          style.copyWith(childPadding: EdgeInsets.zero),
                      children: [
                        FAccordionItem(
                          title: Text(epController.epGroup[index].title),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(
                              epController.epGroup[index].urls.length,
                              (i) => FTile(
                                title: Text(
                                  epController.epGroup[index].urls[i].name,
                                ),
                                onPress: () {
                                  epNotifier.selectEpisode(index, i);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // episodes
      // FTileGroup.builder(
      //   count: epController.epGroup.length,
      //   tileBuilder: (context, index) => Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      //         child: FAccordion(
      //           style: (style) => style.copyWith(childPadding: EdgeInsets.zero),
      //           children: [
      //             FAccordionItem(
      //               title: Text(epController.epGroup[index].title),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.stretch,
      //                 children: List.generate(
      //                   epController.epGroup[index].urls.length,
      //                   (i) => FTile(
      //                     title: Text(epController.epGroup[index].urls[i].name),
      //                     onPress: () {
      //                       epNotifier.selectEpisode(index, i);
      //                     },
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      // resolution
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: FTileGroup.builder(
            count: controller.qualityMap.length,
            tileBuilder: (context, index) {
              final item = controller.qualityMap.keys.toList()[index];
              return FTile(
                title: Text(item),
                onPress: () {
                  notifier.changeVideoQuality(controller.qualityMap[item]!);
                  notifier.toggleSettings();
                },
              );
            },
          ),
        ),
      ),
      // subtitle
      FTileGroup.builder(
        // padding: EdgeInsets.zero,
        count: controller.subtitlesRaw.length,
        tileBuilder: (context, index) {
          return FTile(
            title: Text(controller.subtitlesRaw[index].title),
            subtitle: Text('${controller.subtitlesRaw[index].language}'),
            onPress: () {
              notifier.setSubSelectedIndex(index);
              notifier.toggleSettings();
            },
          );
        },
      ),
    ];

    return Container(
      width: width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: context.theme.colors.background.withAlpha(240),
        border: Border(
          left: BorderSide(color: context.theme.colors.border, width: 1),
        ),
      ),
      child: FTabs(
        children: List.generate(
          tabs.length,
          (index) => FTabEntry(
            label: Icon(tabs[index].icon),
            child: dialogContent[index],
          ),
        ),
      ),

      // Column(
      //   children: [
      //     Container(
      //       decoration: BoxDecoration(
      //         border: Border(
      //           bottom: BorderSide(color: context.theme.colors.border),
      //         ),
      //       ),
      //       child: Row(
      //         children: List.generate(tabs.length, (index) {
      //           final isSelected = selectedIndex.value == index;
      //           return Expanded(
      //             child: GestureDetector(
      //               onTap: () => selectedIndex.value = index,
      //               behavior: HitTestBehavior.opaque,
      //               child: Container(
      //                 padding: const EdgeInsets.symmetric(vertical: 12),
      //                 decoration: BoxDecoration(
      //                   border: isSelected
      //                       ? Border(
      //                           bottom: BorderSide(
      //                             color: context.theme.colors.primary,
      //                             width: 2,
      //                           ),
      //                         )
      //                       : null,
      //                 ),
      //                 child: Icon(
      //                   tabs[index].icon,
      //                   color: isSelected
      //                       ? context.theme.colors.primary
      //                       : context.theme.colors.primary.withAlpha(128),
      //                   size: 20,
      //                 ),
      //               ),
      //             ),
      //           );
      //         }),
      //       ),
      //     ),
      //     Expanded(child: dialogContent[selectedIndex.value]),
      //   ],
      // ),
    );
  }
}
