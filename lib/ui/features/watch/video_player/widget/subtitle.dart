import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/utils/watch/subtitle_style.dart';

/// The software subtitle cue: the Dart-rendered fallback used when the video
/// engine is not mdk (or the track is a plain VTT parsed in Dart). Style comes
/// from [SubtitleStyle.current] so it matches the native mdk render.
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
    final style = SubtitleStyle.current();
    final align = switch (style.textAlign) {
      0 => TextAlign.left,
      2 => TextAlign.right,
      _ => TextAlign.center,
    };
    final vertical = switch (style.verticalAlign) {
      'top' => Alignment.topCenter,
      'center' => Alignment.center,
      _ => Alignment.bottomCenter,
    };
    final decorations = <TextDecoration>[
      if (style.underline) TextDecoration.underline,
      if (style.strikeout) TextDecoration.lineThrough,
    ];
    final decoration = decorations.isEmpty
        ? TextDecoration.none
        : TextDecoration.combine(decorations);
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
        child: Align(
          alignment: vertical,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: style.backgroundColor.withValues(
                alpha: style.backgroundOpacity,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              currentSubtitle,
              textAlign: align,
              style: TextStyle(
                color: style.fontColor,
                fontSize: style.fontSize,
                fontFamily: style.fontFamily.isEmpty ? null : style.fontFamily,
                fontWeight: style.bold ? FontWeight.bold : FontWeight.normal,
                fontStyle: style.italic ? FontStyle.italic : FontStyle.normal,
                decoration: decoration,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
