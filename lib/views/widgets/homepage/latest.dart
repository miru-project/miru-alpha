import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';

class Latest extends StatelessWidget {
  Latest({super.key, required this.extensionService});
  final ExtensionService extensionService;
  final RxBool _leftIsHover = false.obs;
  final RxBool _rightIsHover = false.obs;
  final _colorgradient = [
    Colors.black.withAlpha(80),
    Colors.transparent,
  ];
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: extensionService.latest(1),
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            final data = snapShot.data!;

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(extensionService.extension.name,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  SizedBox(
                      height: 270,
                      child: Stack(children: [
                        ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) => MiruGridTile(
                            title: data[index].title,
                            subtitle: data[index].update ?? "",
                            imageUrl: data[index].cover,
                            onTap: () {},
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
                                  _leftIsHover.value = true;
                                },
                                onExit: (event) {
                                  _leftIsHover.value = false;
                                },
                                cursor: SystemMouseCursors.click,
                                child: Obx(() => AnimatedContainer(
                                      width: _width / 20,
                                      height: double.infinity,
                                      decoration: _leftIsHover.value
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
                                      _rightIsHover.value = true;
                                    },
                                    onExit: (event) {
                                      _rightIsHover.value = false;
                                    },
                                    cursor: SystemMouseCursors.click,
                                    child: Obx(() => AnimatedContainer(
                                          width: _width / 20,
                                          height: double.infinity,
                                          decoration: _rightIsHover.value
                                              ? BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                    colors: _colorgradient,
                                                    end: Alignment.centerLeft,
                                                    begin:
                                                        Alignment.centerRight,
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
                                              MoonIcons
                                                  .arrows_right_32_regular),
                                        )))))
                      ]))
                ]);
          }

          if (snapShot.hasError) {
            return Text(snapShot.error.toString());
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
