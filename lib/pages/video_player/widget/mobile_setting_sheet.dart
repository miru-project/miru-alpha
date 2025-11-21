import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/widgets/index.dart';

class MobileVideoSheet extends HookConsumerWidget {
  const MobileVideoSheet({
    super.key,
    required this.vidPr,
    required this.epProvdier,
  });

  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvdier;

  static const _navItems = [
    NavItem(text: 'Episode', icon: FIcons.tv),
    NavItem(text: 'Resolution', icon: FIcons.ratio),
    NavItem(text: 'Subtitle', icon: FIcons.captions),
    NavItem(text: 'Settings', icon: FIcons.bolt),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);
    final epController = ref.watch(epProvdier);
    final epNotifier = ref.read(epProvdier.notifier);
    final controller = ref.read(vidPr);
    final notifer = ref.read(vidPr.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        final dialogContent = [
          // episodes
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: List.generate(
                epController.epGroup.length,
                (index) => Column(
                  children: [
                    FCard.raw(
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                        child: FAccordion(
                          style: (style) => style.copyWith(childPadding: .zero),
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
                                      context.pop();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // resolution
          SingleChildScrollView(
            controller: scrollController,
            child: FTileGroup.builder(
              count: controller.qualityMap.length,
              tileBuilder: (context, index) {
                final item = controller.qualityMap.keys.toList()[index];
                return FTile(
                  title: Text(item),
                  onPress: () {
                    notifer.changeVideoQuality(controller.qualityMap[item]!);
                    context.pop();
                  },
                );
              },
            ),
          ),
          // subtitle
          SingleChildScrollView(
            controller: scrollController,
            child: FTileGroup.builder(
              count: controller.subtitlesRaw.length,
              tileBuilder: (context, index) {
                return FTile(
                  title: Text(controller.subtitlesRaw[index].title),
                  subtitle: Text('${controller.subtitlesRaw[index].language}'),
                  onPress: () {
                    notifer.setSelectedIndex(index);
                    context.pop();
                  },
                );
              },
            ),
          ),
          // settings
          SingleChildScrollView(
            controller: scrollController,
            child: Container(),
          ),
        ];

        return Blur(
          child: FCard.raw(
            style: (style) => style.copyWith(
              decoration: BoxDecoration(
                color: context.theme.colors.background.withAlpha(150),
                borderRadius: style.decoration.borderRadius,
                border: style.decoration.border,
                shape: style.decoration.shape,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.theme.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Custom Tab Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_navItems.length, (index) {
                      final isSelected = selectedIndex.value == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FButton(
                          style: isSelected
                              ? FButtonStyle.primary()
                              : FButtonStyle.ghost(),
                          onPress: () => selectedIndex.value = index,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_navItems[index].icon, size: 16),
                              const SizedBox(width: 8),
                              Text(_navItems[index].text),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: dialogContent[selectedIndex.value],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NavItem {
  final String text;
  final IconData icon;
  const NavItem({required this.text, required this.icon});
}
