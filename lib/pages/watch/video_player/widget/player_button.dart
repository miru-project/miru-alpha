import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';

class PlayerButton extends StatelessWidget {
  const PlayerButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size,
  });
  final VoidCallback? onPressed;
  final IconData icon;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      style: FButtonStyle.ghost(),
      onPress: onPressed,
      child: Icon(icon, size: size),
    );
  }
}

class MainPlayerButton extends ConsumerWidget {
  const MainPlayerButton({super.key, this.size, required this.vidPr});
  final double? size;
  final VideoPlayerNotifierProvider vidPr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(vidPr.select((s) => s.isPlaying));
    return Expanded(
      child: (!isPlaying)
          ? Center(
              child: FButton.icon(
                onPress: () {
                  ref.read(vidPr.notifier).play();
                },
                child: Icon(FIcons.play, size: size),
              ),
            )
          : Container(color: Colors.transparent),
    );
  }
}
