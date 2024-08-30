import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';

class Latest extends ConsumerStatefulWidget {
  const Latest({super.key, required this.extensionService});
  final ExtensionApiV1 extensionService;
  @override
  createState() => _LatestState();
}

class _LatestState extends ConsumerState<Latest> {
  late final ValueNotifier<bool> leftIsHover;
  late final ValueNotifier<bool> rightIsHover;
  final _colorgradient = [
    Colors.black.withAlpha(80),
    Colors.transparent,
  ];
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    leftIsHover = ValueNotifier(false);
    rightIsHover = ValueNotifier(false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final snapShot =
        ref.watch(fetchExtensionLatestProvider(widget.extensionService, 1));
    if (width > 800) {
      //desktop
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.extensionService.extension.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(
          height: 10,
        ),
        snapShot.when(
          data: (data) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                height: 270,
                child: Stack(children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, index) => MiruGridTile(
                      title: data[index].title,
                      subtitle: data[index].update ?? "",
                      imageUrl: data[index].cover,
                      onTap: () {
                        context.go('/search/detail', extra: {
                          'service': widget.extensionService,
                          'url': data[index].url,
                        });
                      },
                      width: 160,
                      height: 200,
                    ),
                    itemCount: data.length,
                    scrollDirection: Axis.horizontal,
                  ),
                  GestureDetector(
                      onTapDown: (_) {
                        _scrollController.animateTo(
                            _scrollController.offset - 100,
                            duration: Durations.short1,
                            curve: Curves.ease);
                      },
                      child: MouseRegion(
                          onHover: (event) {
                            leftIsHover.value = true;
                          },
                          onExit: (event) {
                            leftIsHover.value = false;
                          },
                          cursor: SystemMouseCursors.click,
                          child: ValueListenableBuilder(
                              valueListenable: rightIsHover,
                              builder: (context, lvalue, child) =>
                                  AnimatedContainer(
                                    width: width / 20,
                                    height: double.infinity,
                                    decoration: lvalue
                                        ? BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            gradient: LinearGradient(
                                              colors: _colorgradient,
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          )
                                        : null,
                                    duration: Durations.short1,
                                    child: const Icon(
                                        color: Colors.white,
                                        MoonIcons.arrows_left_32_regular),
                                  )))),
                  Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                          onTapDown: (_) {
                            _scrollController.animateTo(
                                _scrollController.offset + 100,
                                duration: Durations.short1,
                                curve: Curves.ease);
                          },
                          child: MouseRegion(
                              onHover: (event) {
                                rightIsHover.value = true;
                              },
                              onExit: (event) {
                                rightIsHover.value = false;
                              },
                              cursor: SystemMouseCursors.click,
                              child: ValueListenableBuilder(
                                  valueListenable: rightIsHover,
                                  builder: (context, rvalue, child) =>
                                      AnimatedContainer(
                                        width: width / 20,
                                        height: double.infinity,
                                        decoration: rvalue
                                            ? BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                  colors: _colorgradient,
                                                  end: Alignment.centerLeft,
                                                  begin: Alignment.centerRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              )
                                            : null,
                                        duration: Durations.short1,
                                        child: const Icon(
                                            color: Colors.white,
                                            MoonIcons.arrows_right_32_regular),
                                      )))))
                ])),
            const SizedBox(
              height: 20,
            )
          ]),
          error: (error, stack) => Text(snapShot.error.toString()),
          loading: () => const SizedBox(
              height: 170,
              child: Center(
                child: CircularProgressIndicator(),
              )),
        )
      ]);
    }
    //mobile
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.extensionService.extension.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(
        height: 10,
      ),
      snapShot.when(
        data: (data) =>
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              height: 200,
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) => MiruGridTile(
                  title: data[index].title,
                  subtitle: data[index].update ?? "",
                  imageUrl: data[index].cover,
                  onTap: () {
                    context.go('/search/detail', extra: {
                      'service': widget.extensionService,
                      'url': data[index].url,
                    });
                  },
                  width: 100,
                  // height: 200,
                ),
                itemCount: data.length,
                scrollDirection: Axis.horizontal,
              )),
          const SizedBox(
            height: 20,
          )
        ]),
        error: (error, stackTrace) => Text(snapShot.error.toString()),
        loading: () => const SizedBox(
            height: 270,
            child: Center(
              child: CircularProgressIndicator(),
            )),
      )
    ]);
  }
}
