import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/watch/manga_reader_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

//

class MiruMangaReader extends StatefulHookConsumerWidget {
  const MiruMangaReader({
    super.key,
    required this.meta,
    required this.selectedGroupIndex,
    required this.selectedEpisodeIndex,
    required this.name,
    required this.detailUrl,
    required this.detailImageUrl,
    required this.epGroup,
  });
  final ExtensionMeta meta;
  final String detailUrl;
  final String detailImageUrl;
  final List<ExtensionEpisodeGroup>? epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;
  @override
  createState() => _MiruMangaReaderState();
}

class _MiruMangaReaderState extends ConsumerState<MiruMangaReader> {
  @override
  void initState() {
    MangaProvider.initEpisode(
      widget.epGroup ?? [],
      widget.name,
      widget.selectedGroupIndex,
      widget.selectedEpisodeIndex,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final epcontroller = ref.watch(MangaProvider.epProvider);
    final url =
        widget
            .epGroup![epcontroller.selectedGroupIndex]
            .urls[epcontroller.selectedEpisodeIndex]
            .url;
    final snapShot = ref.watch(
      MangaLoadProvider(url, widget.meta.packageName, widget.meta.type),
    );

    return MiruScaffold(
      scrollController:
          ref.read(MangaProvider.epProvider.notifier).scrollController,
      sidebar: <Widget>[
        if (DeviceUtil.getWidth(context) < 800)
          //mobile
          MoonButton(
            height: 50,
            leading: const Icon(MoonIcons.controls_chevron_left_24_regular),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: DeviceUtil.getWidth(context) - 80,
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    epcontroller.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Text(
                  epcontroller.epGroup[epcontroller.selectedGroupIndex].title,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        const SizedBox(height: 10),
        _MobileSilder(),
        MoonTabBar(
          tabs: const [
            MoonTab(label: Text('Chapter')),
            MoonTab(label: Text('Page')),
            MoonTab(label: Text('Alignment')),
            MoonTab(label: Text('Setting')),
          ],
        ),
      ],
      body: snapShot.when(
        data: (data) {
          return _MiruMangaReadView(
            detailUrl: widget.detailUrl,
            meta: widget.meta,
            detailImageUrl: widget.detailImageUrl,
            data: data,
          );
        },
        loading: () {
          return const Center(child: MoonCircularLoader());
        },
        error: (error, stack) {
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }
}

class _MiruMangaReadView extends StatefulHookConsumerWidget {
  const _MiruMangaReadView({
    required this.data,
    required this.meta,
    required this.detailImageUrl,
    required this.detailUrl,
  });
  final ExtensionMangaWatch data;
  final ExtensionMeta meta;
  final String detailImageUrl;
  final String detailUrl;
  @override
  createState() => _MiruMangaReadViewState();
}

class _MiruMangaReadViewState extends ConsumerState<_MiruMangaReadView> {
  @override
  void initState() {
    ref
        .read(MangaProvider.epProvider.notifier)
        .putinformation(
          widget.meta.type,
          widget.meta.packageName,
          widget.detailImageUrl,
          widget.detailUrl,
        );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(MangaProvider.provider.notifier)
        ..setContent(widget.data.urls)
        ..initListener();
      // controller.initListener();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final controller = ref.watch(MangaProvider.provider);
    final item = widget.data.urls;
    final List<int> pointer = [];
    final isZoom = useState(false);
    final c = ref.watch(MangaProvider.provider.notifier);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        pointer.add(event.pointer);
        if (pointer.length == 2) {
          isZoom.value = true;
        }
      },
      onPointerUp: (event) {
        pointer.remove(event.pointer);
        // if (pointer.length == 1) {
        //   isZoom.value = false;
        //   debugPrint('zooming');
        // }
        // debugPrint(pointer.length.toString());
        isZoom.value = false;
      },
      child: InteractiveViewer(
        panAxis: PanAxis.free,
        // transformationController: TransformationController(),
        onInteractionStart: (details) {
          debugPrint('start');
        },
        // panEnabled: false,s
        scaleEnabled: isZoom.value,
        child: ScrollablePositionedList.builder(
          padding: const EdgeInsets.only(bottom: 190),
          physics: isZoom.value ? const NeverScrollableScrollPhysics() : null,
          itemScrollController: c.itemScrollController,
          scrollOffsetController: c.scrollOffsetController,
          scrollOffsetListener: c.scrollOffsetListener,
          itemPositionsListener: c.itemPositionsListener,
          itemCount: item.length,
          itemBuilder: (context, index) {
            return _ImageWidget(imgUrl: item[index]);
          },
        ),
      ),
    );
  }
}

class _MobileSilder extends StatefulHookConsumerWidget {
  // const _MobileSilder();
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
    final controller = ref.watch(
      MangaProvider.provider.select(
        (it) =>
            it
              ..itemPosition
              ..totalPage,
      ),
    );
    final c = ref.watch(MangaProvider.provider.notifier);
    final epcontroller = ref.watch(MangaProvider.epProvider);
    final epNotifier = ref.watch(MangaProvider.epProvider.notifier);
    return Row(
      children: [
        MoonButton.icon(
          icon: const Icon(Icons.skip_previous_rounded),
          onTap:
              epcontroller.selectedEpisodeIndex != 0
                  ? () {
                    epNotifier.prevChapter();
                    // ref.invalidate(MangaProvider.provider);
                    // ref.read(MangaProvider.provider);
                  }
                  : null,
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
                    divisions: controller.totalPage,
                    min: 0,
                    max: controller.totalPage.toDouble(),
                    value:
                        isSliding.value
                            ? sliderValue.value
                            : controller.itemPosition.toDouble(),
                    onChanged: (val) {
                      sliderValue.value = val;
                      c.itemScrollController.jumpTo(index: val.toInt());
                    },
                    label:
                        isSliding.value
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
        MoonButton.icon(
          icon: const Icon(Icons.skip_next_rounded),
          onTap:
              epcontroller.selectedEpisodeIndex <
                      epcontroller
                          .epGroup[epcontroller.selectedGroupIndex]
                          .urls
                          .length
                  ? () {
                    epNotifier.nextChapter();
                  }
                  : null,
        ),
      ],
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({required this.imgUrl});
  final String imgUrl;

  @override
  Widget build(context) {
    final screenHeight = DeviceUtil.getHeight(context);
    final screenWidth = DeviceUtil.getWidth(context);
    return ExtendedImage.network(
      imgUrl,
      fit: BoxFit.contain,
      cache: true,
      loadStateChanged: (state) {
        final totalSize = state.loadingProgress?.expectedTotalBytes;
        final currentSize = state.loadingProgress?.cumulativeBytesLoaded;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            if (totalSize != null && currentSize != null) {
              return SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: Center(
                  child: MoonCircularProgress(value: currentSize / totalSize),
                ),
              );
            }
            return SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: const Center(child: MoonCircularLoader()),
            );
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return const Center(child: Text('Failed to load image'));
        }
      },
    );
  }
}
