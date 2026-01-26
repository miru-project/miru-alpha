import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/main_controller_provider.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DesktopSettingDialog extends HookConsumerWidget {
  const DesktopSettingDialog({
    this.initialIndex = 0,
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
  final int initialIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(initialIndex);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final epController = ref.watch(epProvdier);
    final epNotifier = ref.read(epProvdier.notifier);
    // final subController = ref.watch(subtitleProvider);
    // final subNotifier = ref.read(subtitleProvider.notifier);
    final controller = ref.read(vidPr);
    final notifer = ref.read(vidPr.notifier);
    final dialogContent = [
      // episodes
      ListView.builder(
        itemBuilder: (context, index) => Column(
          children: [
            FAccordion(
              children: List.generate(
                epController.epGroup[index].urls.length,
                (i) => FButton(
                  mainAxisAlignment: MainAxisAlignment.start,
                  style: FButtonStyle.ghost(),
                  child: Text(
                    epController.epGroup[index].urls[i].name,
                    style: TextStyle(),
                  ),
                  onPress: () {
                    epNotifier.selectEpisode(index, i);
                    context.pop();
                  },
                ),
              ),
            ),
          ],
        ),
        itemCount: epController.epGroup.length,
      ),
      ListView.builder(
        itemBuilder: (context, index) {
          final item = controller.qualityMap.keys.toList()[index];
          return FButton(
            style: FButtonStyle.ghost(),
            mainAxisAlignment: MainAxisAlignment.start,
            onPress: () {
              notifer.changeVideoQuality(controller.qualityMap[item]!);
              context.pop();
            },
            child: Text(item),
          );
        },
        itemCount: controller.qualityMap.length,
      ),
      // subtitle
      ListView.builder(
        itemCount: controller.subtitlesRaw.length,
        itemBuilder: (context, int index) => FButton(
          onPress: () {
            notifer.setSubSelectedIndex(index);
            context.pop();
          },
          suffix: Text('${controller.subtitlesRaw[index].language}'),
          child: Text(controller.subtitlesRaw[index].title),
        ),
      ),
      // settings
      Container(),
    ];
    final dialogFactor = DeviceUtil.isMobileLayout(context) ? 0.8 : .5;
    return Center(
      child: SizedBox(
        height: height * dialogFactor,
        width: width * dialogFactor,
        child: FCard.raw(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 15),
            child: FScaffold(
              sidebar: SizedBox(
                width: 160,
                child: FSidebarGroup(
                  children: List.generate(_navItems.length, (index) {
                    return FSidebarItem(
                      onPress: () {
                        selectedIndex.value = index;
                      },
                      icon: Icon(_navItems[index].icon),
                      label: Text(_navItems[index].text),
                    );
                  }),
                ),
              ),
              child: Container(
                height: height * dialogFactor,
                decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                ),
                child: dialogContent[selectedIndex.value],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
