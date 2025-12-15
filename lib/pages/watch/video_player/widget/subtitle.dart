import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';

class VideoPlayerSubtitle extends ConsumerWidget {
  const VideoPlayerSubtitle({super.key, required this.vidProvider});
  final VideoPlayerNotifierProvider vidProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSubtitle = ref.watch(
      vidProvider.select((s) => s.currentSubtitle),
    );
    if (currentSubtitle.isEmpty) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: RichText(
            text: TextSpan(
              text: currentSubtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                decoration: TextDecoration.none, // Remove underline
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
