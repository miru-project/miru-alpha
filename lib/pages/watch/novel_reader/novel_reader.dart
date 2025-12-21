import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/novel_reader_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MiruNovelReader extends StatefulHookConsumerWidget {
  const MiruNovelReader({
    super.key,
    required this.value,
    required this.name,
    required this.meta,
    required this.url,
    required this.epProvider,
    required this.detailImageUrl,
  });
  final ExtensionFikushonWatch value;
  final String name;
  final ExtensionMeta meta;
  final String url;
  final EpisodeNotifierProvider epProvider;
  final String detailImageUrl;
  @override
  createState() => _MiruNovelReaderState();
}

class _MiruNovelReaderState extends ConsumerState<MiruNovelReader> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('');
    return MiruScaffold(
      scrollController: scrollController,
      // snapSheet: <Widget>[
      //   if (DeviceUtil.getWidth(context) < 800) const SizedBox(height: 10),
      //   _MobileSilder(epProvider: widget.epProvider),
      // ],
      body: _MiruNovelReadView(
        data: widget.value,
        meta: widget.meta,
        imgUrl: widget.detailImageUrl,
        detailUrl: widget.url,
        epProvider: widget.epProvider,
      ),
    );
  }
}

class _MiruNovelReadView extends StatefulHookConsumerWidget {
  const _MiruNovelReadView({
    required this.data,
    required this.meta,
    required this.imgUrl,
    required this.detailUrl,
    required this.epProvider,
  });
  final ExtensionFikushonWatch data;
  final ExtensionMeta meta;
  final String imgUrl;
  final String detailUrl;
  final EpisodeNotifierProvider epProvider;

  @override
  createState() => _MiruNovelReadViewState();
}

class _MiruNovelReadViewState extends ConsumerState<_MiruNovelReadView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(novelReaderProvider.notifier)
        ..setContent(widget.data.content)
        ..initListener();

      ref
          .read(widget.epProvider.notifier)
          .putInformation(
            widget.meta.type,
            widget.meta.packageName,
            widget.imgUrl,
            widget.detailUrl,
          );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.data.content;
    final c = ref.watch(novelReaderProvider.notifier);
    return ScrollablePositionedList.builder(
      scrollOffsetController: c.scrollOffsetController,
      itemScrollController: c.itemScrollController,
      itemPositionsListener: c.itemPositionsListener,
      scrollOffsetListener: c.scrollOffsetListener,
      itemCount: item.length,
      itemBuilder: (context, index) {
        return SelectableText.rich(
          TextSpan(
            text: item[index],
            style: const TextStyle(fontSize: 20, height: 1.5),
          ),
        );
      },
    );
  }
}

class _MobileSilder extends StatefulHookConsumerWidget {
  const _MobileSilder({required this.epProvider});
  final EpisodeNotifierProvider epProvider;
  @override
  createState() => _MobileSilderState();
}

class _MobileSilderState extends ConsumerState<_MobileSilder> {
  late ValueNotifier<double> sliderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSliding = useState(false);
    sliderValue = useState(0.0);
    final controller = ref.watch(novelReaderProvider);
    final c = ref.watch(novelReaderProvider.notifier);
    final epcontroller = ref.watch(widget.epProvider);
    final epNotifier = ref.watch(widget.epProvider.notifier);
    return Row(
      children: [
        FButton.icon(
          onPress: epcontroller.selectedEpisodeIndex != 0
              ? () {
                  epNotifier.selectEpisode(
                    epcontroller.selectedGroupIndex,
                    epcontroller.selectedEpisodeIndex - 1,
                  );
                }
              : null,
          child: const Icon(Icons.skip_previous_rounded),
        ),
        const SizedBox(width: 10),
        Text(
          isSliding.value
              ? sliderValue.value.toInt().toString()
              : controller.itemPosition.toString(),
        ),
        Expanded(
          child:
              (c.itemScrollController.isAttached && controller.totalPage >= 0)
              ? Slider(
                  divisions: controller.totalPage > 0
                      ? controller.totalPage
                      : 1,
                  min: 0,
                  max: controller.totalPage.toDouble(),
                  value: isSliding.value
                      ? sliderValue.value
                      : controller.itemPosition.toDouble(),
                  onChanged: (val) {
                    sliderValue.value = val;
                    c.itemScrollController.jumpTo(index: val.toInt());
                  },
                  label: isSliding.value
                      ? '${sliderValue.value.toInt()}'
                      : '${controller.itemPosition}',
                  onChangeStart: (value) {
                    isSliding.value = true;
                  },
                  onChangeEnd: (value) {
                    isSliding.value = false;
                  },
                )
              : const Slider(value: 0, onChanged: null),
        ),
        Text(controller.totalPage.toString()),
        const SizedBox(width: 10),
        FButton.icon(
          onPress:
              epcontroller.selectedEpisodeIndex <
                  epcontroller
                          .epGroup[epcontroller.selectedGroupIndex]
                          .urls
                          .length -
                      1
              ? () {
                  epNotifier.selectEpisode(
                    epcontroller.selectedGroupIndex,
                    epcontroller.selectedEpisodeIndex + 1,
                  );
                }
              : null,
          child: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}
