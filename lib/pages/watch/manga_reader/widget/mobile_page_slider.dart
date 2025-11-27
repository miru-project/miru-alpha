import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/seek_bar_thumb.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/manga_reader_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';

class MangaMobilePageSlider extends StatefulHookConsumerWidget {
  const MangaMobilePageSlider({
    super.key,
    required this.epProvider,
    required this.mangaProvider,
  });
  final EpisodeNotifierProvider epProvider;
  final MangaReaderProvider mangaProvider;
  @override
  createState() => MangaMobileSliderState();
}

class MangaMobileSliderState extends ConsumerState<MangaMobilePageSlider> {
  late ValueNotifier<double> sliderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSliding = useState(false);
    sliderValue = useState(0.0);
    final readerState = ref.watch(widget.mangaProvider);
    final c = ref.watch(widget.mangaProvider.notifier);
    final epState = ref.watch(widget.epProvider);
    final epNotifier = ref.watch(widget.epProvider.notifier);

    return Row(
      children: [
        FButton.icon(
          style: FButtonStyle.ghost(),
          onPress: epState.selectedEpisodeIndex != 0
              ? () {
                  epNotifier.selectEpisode(
                    epState.selectedGroupIndex,
                    epState.selectedEpisodeIndex - 1,
                  );
                }
              : null,
          child: const Icon(FIcons.skipBack),
        ),
        const SizedBox(width: 10),
        Text(
          isSliding.value
              ? sliderValue.value.toInt().toString()
              : readerState.itemPosition.toString(),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              thumbShape: SliderThumb.circular(
                mainColor: context.theme.colors.primary,
              ),
              trackHeight: DeviceUtil.isMobile ? 5 : 7,
              activeTrackColor: context.theme.colors.primary,
              inactiveTrackColor: context.theme.colors.background,
              overlayColor: Colors.transparent,
            ),
            child: Material(
              color: Colors.transparent,
              child:
                  ((
                  // c.itemScrollController.isAttached &&
                  readerState.totalPage >= 0)
                  ? Slider(
                      divisions: readerState.totalPage > 0
                          ? readerState.totalPage
                          : 1,
                      min: 0,
                      max: readerState.totalPage.toDouble(),
                      value: isSliding.value
                          ? sliderValue.value
                          : readerState.itemPosition.toDouble(),
                      onChanged: (val) {
                        sliderValue.value = val;
                        c.jumpTo(val.toInt());
                      },
                      label: isSliding.value
                          ? '${sliderValue.value.toInt()}'
                          : '${readerState.itemPosition}',
                      onChangeStart: (value) {
                        isSliding.value = true;
                      },
                      onChangeEnd: (value) {
                        isSliding.value = false;
                      },
                    )
                  : Slider(value: 0, onChanged: null)),
            ),
          ),
        ),
        Text(readerState.totalPage.toString()),
        const SizedBox(width: 10),
        FButton.icon(
          style: FButtonStyle.ghost(),
          onPress:
              epState.selectedEpisodeIndex <
                  epState.epGroup[epState.selectedGroupIndex].urls.length - 1
              ? () {
                  epNotifier.selectEpisode(
                    epState.selectedGroupIndex,
                    epState.selectedEpisodeIndex + 1,
                  );
                }
              : null,
          child: const Icon(FIcons.skipForward),
        ),
      ],
    );
  }
}
