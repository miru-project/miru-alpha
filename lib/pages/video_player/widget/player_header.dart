import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/video_player/video_player.dart';
import 'package:miru_app_new/pages/video_player/widget/mobile_setting_sheet.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:window_manager/window_manager.dart';

class PlayerHeader extends ConsumerStatefulWidget {
  const PlayerHeader({
    required this.onClose,
    this.titleSize = 20,
    this.subTitleSize = 18,
    this.iconSize = 24,
    required this.episodeProvider,
    required this.vidPr,
    super.key,
  });
  final VoidCallback onClose;
  final double titleSize;
  final double subTitleSize;
  final double iconSize;
  final EpisodeNotifierProvider episodeProvider;
  final VideoPlayerNotifierProvider vidPr;
  @override
  ConsumerState<PlayerHeader> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<PlayerHeader> {
  bool _isAlwaysOnTop = false;

  @override
  void initState() {
    super.initState();
    if (!DeviceUtil.isMobile) {
      WindowManager.instance.isAlwaysOnTop().then((value) {
        _isAlwaysOnTop = value;
      });
    }
  }

  Widget buildcontent(EpisodeNotifierState epNotifier) {
    return FLabel(
      axis: Axis.vertical,
      description: Text(
        '${epNotifier.epGroup[epNotifier.selectedGroupIndex].title}-${epNotifier.epGroup[epNotifier.selectedGroupIndex].urls[epNotifier.selectedEpisodeIndex].name}',
        style: TextStyle(
          fontSize: widget.subTitleSize,
          fontWeight: FontWeight.w300,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: Text(
        epNotifier.name,
        style: TextStyle(
          fontSize: widget.titleSize,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final epNotifier = ref.watch(widget.episodeProvider);
    return FCard.raw(
      style: FCardStyle.inherit(
        colors: context.theme.colors.copyWith(
          background: context.theme.colors.background.withAlpha(200),
        ),
        typography: context.theme.typography,
        style: context.theme.style,
      ).call,
      child: Blur(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            children: [
              if (DeviceUtil.isMobile) HeaderBack(),
              const SizedBox(width: 10),
              Expanded(
                child: DeviceUtil.isMobile
                    ? buildcontent(epNotifier)
                    : DragToMoveArea(child: buildcontent(epNotifier)),
              ),
              // 置顶
              if (!DeviceUtil.isMobile) ...[
                PlayerButton(
                  onPressed: () async {
                    WindowManager.instance.setAlwaysOnTop(!_isAlwaysOnTop);
                    setState(() {
                      _isAlwaysOnTop = !_isAlwaysOnTop;
                    });
                  },
                  icon: _isAlwaysOnTop
                      ? Icons.push_pin_outlined
                      : Icons.push_pin,
                ),
                const SizedBox(width: 10),
                PlayerButton(
                  onPressed: () {
                    WindowManager.instance.minimize();
                  },
                  icon: FIcons.minus,
                ),
              ],
              const SizedBox(width: 10),
              if (!DeviceUtil.isMobile)
                PlayerButton(onPressed: widget.onClose, icon: FIcons.x)
              else ...[
                PlayerButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => MobileVideoSheet(
                        vidPr: widget.vidPr,
                        epProvdier: widget.episodeProvider,
                      ),
                    );
                  },
                  icon: FIcons.settings,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
