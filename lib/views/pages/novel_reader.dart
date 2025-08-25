import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/watch/novel_reader_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/miru_core/extension/extension_service.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

//

class MiruNovelReader extends StatefulHookConsumerWidget {
  const MiruNovelReader({
    super.key,
    required this.service,
    required this.selectedGroupIndex,
    required this.selectedEpisodeIndex,
    required this.name,
    required this.detailImageUrl,
    required this.detailUrl,
    required this.epGroup,
  });
  final ExtensionApi service;
  final String detailImageUrl;
  final String detailUrl;
  final List<ExtensionEpisodeGroup>? epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;
  @override
  createState() => _MiruNovelReaderState();
}

class _MiruNovelReaderState extends ConsumerState<MiruNovelReader> {
  @override
  void initState() {
    NovelProvider.initEpisode(
      widget.epGroup ?? [],
      widget.name,
      widget.selectedGroupIndex,
      widget.selectedEpisodeIndex,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final epcontroller = ref.watch(NovelProvider.epProvider);
    final url =
        widget
            .epGroup![epcontroller.selectedGroupIndex]
            .urls[epcontroller.selectedEpisodeIndex]
            .url;
    final snapShot = ref.watch(FikushonLoadProvider(url, widget.service));

    return MiruScaffold(
      scrollController:
          ref.read(NovelProvider.epProvider.notifier).scrollController,
      sidebar: <Widget>[
        if (DeviceUtil.getWidth(context) < 800)
          //mobile
          MoonButton(
            height: 50,
            leading: const Icon(MoonIcons.controls_chevron_left_24_regular),
            label: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
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
                    epcontroller
                        .epGroup[epcontroller.selectedGroupIndex]
                        .urls[epcontroller.selectedEpisodeIndex]
                        .name,
                  ),
                ],
              ),
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
          return _MiruNovelReadView(
            detailUrl: widget.detailUrl,
            service: widget.service,
            imgUrl: widget.detailImageUrl,
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

class _MiruNovelReadView extends StatefulHookConsumerWidget {
  const _MiruNovelReadView({
    required this.data,
    required this.service,
    required this.imgUrl,
    required this.detailUrl,
  });
  final ExtensionFikushonWatch data;
  final ExtensionApi service;
  final String imgUrl;
  final String detailUrl;

  // final ExtensionApiV1 service;
  @override
  createState() => _MiruNovelReadViewState();
}

class _MiruNovelReadViewState extends ConsumerState<_MiruNovelReadView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(NovelProvider.provider.notifier)
        ..setContent(widget.data.content)
        ..initListener();

      // controller.initListener();
      ref
          .read(NovelProvider.epProvider.notifier)
          .putinformation(
            widget.service.meta.type,
            widget.service.meta.packageName,
            widget.imgUrl,
            widget.detailUrl,
          );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.data.content;
    final c = ref.watch(NovelProvider.provider.notifier);
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
    // Listener(
    //     behavior: HitTestBehavior.opaque,
    //     onPointerDown: (event) {
    //       pointer.add(event.pointer);
    //       if (pointer.length == 2) {
    //         isZoom.value = true;
    //       }
    //     },
    //     onPointerUp: (event) {
    //       pointer.remove(event.pointer);
    //       // if (pointer.length == 1) {
    //       //   isZoom.value = false;
    //       //   debugPrint('zooming');
    //       // }
    //       // debugPrint(pointer.length.toString());
    //       isZoom.value = false;
    //     },
    //     child: InteractiveViewer(
    //         panAxis: PanAxis.free,
    //         // transformationController: TransformationController(),
    //         onInteractionStart: (details) {
    //           debugPrint('start');
    //         },
    //         // panEnabled: false,s
    //         scaleEnabled: isZoom.value,
    //         child: ScrollablePositionedList.builder(
    //             padding: const EdgeInsets.only(bottom: 190),
    //             physics:
    //                 isZoom.value ? const NeverScrollableScrollPhysics() : null,
    //             itemScrollController: c.itemScrollController,
    //             scrollOffsetController: c.scrollOffsetController,
    //             scrollOffsetListener: c.scrollOffsetListener,
    //             itemPositionsListener: c.itemPositionsListener,
    //             itemCount: item.length,
    //             itemBuilder: (context, index) {
    //               return _ImageWidget(imgUrl: item[index]);
    //             })));
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
      NovelProvider.provider.select(
        (it) =>
            it
              ..itemPosition
              ..totalPage,
      ),
    );
    final c = ref.watch(NovelProvider.provider.notifier);
    final epcontroller = ref.watch(NovelProvider.epProvider);
    final epNotifier = ref.watch(NovelProvider.epProvider.notifier);
    return Row(
      children: [
        MoonButton.icon(
          icon: const Icon(Icons.skip_previous_rounded),
          onTap:
              epcontroller.selectedEpisodeIndex != 0
                  ? () {
                    epNotifier.prevChapter();
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

// class _ImageWidget extends StatelessWidget {
//   const _ImageWidget({required this.imgUrl});
//   final String imgUrl;

//   @override
//   Widget build(context) {
//     final screenHeight = DeviceUtil.getHeight(context);
//     final screenWidth = DeviceUtil.getWidth(context);
//     return ExtendedImage.network(
//       imgUrl,
//       fit: BoxFit.contain,
//       cache: true,
//       loadStateChanged: (state) {
//         final totalSize = state.loadingProgress?.expectedTotalBytes;
//         final currentSize = state.loadingProgress?.cumulativeBytesLoaded;
//         switch (state.extendedImageLoadState) {
//           case LoadState.loading:
//             if (totalSize != null && currentSize != null) {
//               return SizedBox(
//                   width: screenWidth,
//                   height: screenHeight,
//                   child: Center(
//                     child: MoonCircularProgress(
//                       value: currentSize / totalSize,
//                     ),
//                   ));
//             }
//             return SizedBox(
//                 width: screenWidth,
//                 height: screenHeight,
//                 child: const Center(
//                   child: MoonCircularLoader(),
//                 ));
//           case LoadState.completed:
//             return state.completedWidget;
//           case LoadState.failed:
//             return const Center(
//               child: Text('Failed to load image'),
//             );
//         }
//       },
//     );
//   }
// }
