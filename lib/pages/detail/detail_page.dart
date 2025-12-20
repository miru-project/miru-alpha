import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/detail/widget/desktop_detail_item_box.dart';
import 'package:miru_app_new/provider/detial_provider.dart';

import 'package:miru_app_new/widgets/index.dart';
import 'package:path/path.dart' as p;
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart'
    as proto;
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/utils/download/download_utils.dart';
import 'package:miru_app_new/utils/core/miru_directory.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
// import 'package:moon_design/moon_design.dart';

// class DetailEpButton extends HookWidget {
//   const DetailEpButton({
//     super.key,
//     required this.detail,
//     required this.notifier,
//     required this.onTap,
//     required this.spacing,
//     required this.runSpacing,
//   });
//   final ExtensionDetail detail;
//   final ValueNotifier<int> notifier;
//   final Function(int) onTap;
//   final double spacing;
//   final double runSpacing;
//   @override
//   Widget build(BuildContext context) {
//     if (detail.episodes == null) {
//       return const Text('No Episode');
//     }
//     return LayoutBuilder(
//       builder: (context, constraint) => ValueListenableBuilder(
//         valueListenable: notifier,
//         builder: (context, selectedValue, child) => (detail.episodes!.isEmpty)
//             ? const Text('No Episode')
//             : Wrap(
//                 spacing: spacing,
//                 runSpacing: runSpacing,
//                 children: [
//                   ...List.generate(
//                     detail.episodes![selectedValue].urls.length,
//                     (index) {
//                       return MoonButton(
//                         onTap: () => onTap(index),
//                         label: PlatformWidget(
//                           mobileWidget: ConstrainedBox(
//                             constraints: BoxConstraints(
//                               maxWidth: constraint.maxWidth - 50,
//                             ),
//                             child: Text(
//                               overflow: TextOverflow.ellipsis,
//                               detail.episodes![selectedValue].urls[index].name,
//                             ),
//                           ),
//                           desktopWidget: Text(
//                             detail.episodes![selectedValue].urls[index].name,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

class DesktopDetail extends ConsumerWidget {
  const DesktopDetail({
    super.key,
    this.data,
    this.detailUrl,
    required this.season,
    required this.desc,
    required this.isLoading,
    required this.ep,
    required this.extensionMeta,
    // required this.cast,
  });
  final Widget desc;
  final bool isLoading;
  final Widget ep;
  final Widget season;
  // final Widget cast;
  final ExtensionMeta extensionMeta;
  final String? detailUrl;
  final ExtensionDetail? data;

  static const _gloablDesktopPadding = 30.0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapShot =
        ref.watch(detialProvider).detailState ?? const AsyncValue.loading();
    return CustomScrollView(
      slivers: [
        // SliverPersistentHeader(
        //   pinned: true,
        //   delegate: DetailHeaderDelegate(
        //     detailUrl: detailUrl,
        //     maxExt: _maxExtDesktop,
        //     minExt: _minExtDesktop,
        //     clampMax: _clampMaxDesktop,
        //     meta: extensionMeta,
        //     isLoading: isLoading,
        //     detail: data,
        //   ),
        // ),
        SliverList.list(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(_gloablDesktopPadding),
              child: MaxWidth(
                maxWidth: 1500,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          DesktopDetailItemBox(
                            title: 'Season',
                            padding: _gloablDesktopPadding,
                            child: season,
                          ),
                          const SizedBox(height: 20),
                          DesktopDetailItemBox(
                            needExpand: false,
                            title: 'Description',
                            padding: _gloablDesktopPadding,
                            child: desc,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          if (snapShot.hasValue &&
                              snapShot.value?.episodes != null)
                            FTabs(
                              children: snapShot.value!.episodes!
                                  .map(
                                    (e) => FTabEntry(
                                      label: Text(e.title),
                                      child: DesktopDetailItemBox(
                                        title: 'Episode',
                                        padding: _gloablDesktopPadding,
                                        child: ep,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                          const SizedBox(height: 20),
                          // DetailItemBox(
                          //   padding: _gloablDesktopPadding,
                          //   title: 'Cast & Rating',
                          //   child: cast,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MobileDetail extends StatelessWidget {
  const MobileDetail({
    super.key,
    this.data,
    this.addition = _default,
    this.detailUrl,
    required this.desc,
    required this.isLoading,
    required this.ep,
    required this.meta,
  });
  final Widget desc;
  final bool isLoading;
  final Widget ep;
  final ExtensionMeta meta;
  final ExtensionDetail? data;
  final Widget Function(Widget child) addition;
  final String? detailUrl;
  static const _globalMobilePadding = 20.0;
  static Widget _default(Widget child) => child;
  @override
  Widget build(context) {
    return CustomScrollView(
      slivers: [
        // SliverPersistentHeader(
        //   pinned: true,
        //   delegate: DetailHeaderDelegate(
        //     maxExt: _maxExtMobile,
        //     minExt: _minExtMobile,
        //     clampMax: _clampMaxMobile,
        //     detailUrl: detailUrl,
        //     meta: meta,
        //     isLoading: false,
        //     detail: data,
        //   ),
        // ),
        SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.all(_globalMobilePadding),
              child: addition(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesktopDetailItemBox(
                      title: 'Description',
                      isMobile: true,
                      needExpand: false,
                      padding: _globalMobilePadding,
                      child: desc,
                    ),
                    const SizedBox(height: 20),
                    DesktopDetailItemBox(
                      title: 'Episode',
                      isMobile: true,
                      padding: _globalMobilePadding,
                      child: ep,
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.header,
    required this.lineCount,
    this.lineSeperate,
    this.lineheight,
    this.padding,
  });
  final Widget? header;
  final int lineCount;
  final double? lineheight;
  final double? lineSeperate;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) header!,
          // Shimmer.fromColors(
          //   // baseColor: context
          //   //     .moonTheme!
          //   //     .segmentedControlTheme
          //   //     .colors
          //   //     .backgroundColor
          //   //     .withAlpha(50),
          //   // highlightColor: context
          //   //     .moonTheme!
          //   //     .segmentedControlTheme
          //   //     .colors
          //   //     .backgroundColor
          //   //     .withAlpha(100),
          //   child: ,
          // ),
          Column(
            children: List.generate(
              lineCount,
              (index) => Column(
                children: [
                  SizedBox(height: lineSeperate ?? 20),
                  Container(
                    height: lineheight ?? 10,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(90),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class _DetailSideWidgetMobile extends ConsumerWidget {
//   const _DetailSideWidgetMobile({
//     required this.constraint,
//     required this.meta,
//   });
//   final ExtensionDetail? detail;
//   final String? detailUrl;
//   final ExtensionMeta meta;
//   final BoxConstraints constraint;
//   @override
//   Widget build(BuildContext context, ref) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         const SizedBox(width: 30),
//         Container(
//           width: 100,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: ExtendedImage.network(
//             detail?.cover ?? '',
//             width: 100,
//             height: 160,
//             fit: BoxFit.cover,
//           ),
//         ),
//         const SizedBox(width: 15),
//         SizedBox(
//           width: constraint.maxWidth - 145,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 detail?.title ?? '',
//                 softWrap: true,
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   // fontFamily: "HarmonyOS_Sans",
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 20,
//                 child: Row(
//                   children: [
//                     ExtendedImage.network(
//                       width: 20,
//                       height: 20,
//                       meta.icon ?? '',
//                       loadStateChanged: (state) {
//                         if (state.extendedImageLoadState == LoadState.failed) {
//                           return const Icon(Icons.error);
//                         }
//                         return null;
//                       },
//                       cache: true,
//                       shape: BoxShape.rectangle,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(meta.name, style: const TextStyle(fontSize: 12)),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Row(
//                 children: [
//                   FButton(
//                     // borderColor: context
//                     //     .moonTheme
//                     //     ?.segmentedControlTheme
//                     //     .colors
//                     //     .backgroundColor,
//                     // textColor: context
//                     //     .moonTheme
//                     //     ?.segmentedControlTheme
//                     //     .colors
//                     //     .textColor,
//                     // backgroundColor: context
//                     //     .moonTheme
//                     //     ?.segmentedControlTheme
//                     //     .colors
//                     //     .backgroundColor,
//                     onPress: null,
//                     child: const Text('Play'),
//                   ),
//                   const SizedBox(width: 10),
//                   Consumer(
//                     builder: (context, ref, _) {
//                       final fav = ref.watch(detialProvider).favorite;
//                       return Text("WIP");
//                       // return MoonChip(
//                       //   isActive: fav != null,
//                       //   activeColor: context
//                       //       .moonTheme
//                       //       ?.segmentedControlTheme
//                       //       .colors
//                       //       .textColor,
//                       //   borderColor: context
//                       //       .moonTheme
//                       //       ?.segmentedControlTheme
//                       //       .colors
//                       //       .backgroundColor,
//                       //   textColor:
//                       //       context.moonTheme?.textInputTheme.colors.textColor,
//                       //   backgroundColor: context
//                       //       .moonTheme
//                       //       ?.textInputTheme
//                       //       .colors
//                       //       .backgroundColor,
//                       //   label: Text(
//                       //     fav != null ? 'Favorited' : 'Favorite',
//                       //     style: const TextStyle(fontWeight: FontWeight.bold),
//                       //   ),
//                       //   leading: const Icon(MoonIcons.generic_star_24_regular),
//                       //   onTap: () {
//                       //     if (detail == null || detailUrl == null) {
//                       //       return;
//                       //     }
//                       //     showMoonModal(
//                       //       context: context,
//                       //       builder: (context) => _FavoriteDialog(
//                       //         meta: meta,
//                       //         detail: detail!,
//                       //         detailUrl: detailUrl!,
//                       //       ),
//                       //     );
//                       //   },
//                       // );
//                     },
//                   ),
//                   // DownloadButton(isIcon: true, detail: detail!, meta: meta),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _FavoriteDialog extends ConsumerStatefulWidget {
//   const _FavoriteDialog({
//     required this.meta,
//     required this.detailUrl,
//     required this.detail,
//   });
//   final String detailUrl;
//   final ExtensionDetail detail;
//   final ExtensionMeta meta;

//   @override
//   createState() => _FavoriteDialogState();
// }

// class _FavoriteDialogState extends ConsumerState<_FavoriteDialog> {
//   final ValueNotifier<List<FavoriateGroup>> group = ValueNotifier([]);
//   final ValueNotifier<List<int>> selected = ValueNotifier([]);
//   final ValueNotifier<List<int>> selectedToDelete = ValueNotifier([]);
//   final ValueNotifier<List<int>> setLongPress = ValueNotifier([]);
//   final ValueNotifier<List<int>> setSelected = ValueNotifier([]);
//   final List<int> initSelected = [];
//   @override
//   void initState() {
//     Future.microtask(() async {
//       group.value = await DatabaseService.getAllFavoriteGroup();
//       final fav = ref.read(detialProvider).favorite;
//       if (fav != null) {
//         final result = await DatabaseService.getFavoriteGroupsByFavorite(
//           fav.package,
//           fav.url,
//         );
//         final nameList = group.value.map((e) => e.name).toList();
//         for (final item in result) {
//           initSelected.add(nameList.indexOf(item.name));
//         }
//         selected.value = initSelected;
//         debugPrint(initSelected.toString());
//       }
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final factor = DeviceUtil.isMobileLayout(context) ? 0.8 : .5;
//     final width = DeviceUtil.getWidth(context);
//     final height = DeviceUtil.getHeight(context);

//     return MoonModal(
//       decoration: BoxDecoration(
//         color: MoonColors.dark.goku,
//         borderRadius: const BorderRadius.all(Radius.circular(20)),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 10,
//             color: MediaQuery.of(context).platformBrightness == Brightness.light
//                 ? MoonColors.light.goku.withValues(alpha: .2)
//                 : MoonColors.dark.goku.withValues(alpha: .2),
//           ),
//         ],
//       ),
//       child: ValueListenableBuilder(
//         valueListenable: group,
//         builder: (context, value, _) => SizedBox(
//           width: width * factor,
//           height: height * factor,
//           child: Padding(
//             padding: const EdgeInsets.all(30),
//             child: DefaultTextStyle(
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 // fontFamily: "HarmonyOS_Sans",
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Favorite ?', style: TextStyle(fontSize: 25)),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Selected Group',
//                         style: TextStyle(fontSize: 15),
//                       ),
//                       ValueListenableBuilder(
//                         valueListenable: selectedToDelete,
//                         builder: (context, delete, _) => delete.isEmpty
//                             ? Text(
//                                 DeviceUtil.device(
//                                   mobile: 'Long Press To Delete Group',
//                                   desktop: 'Right Click To Delete Group',
//                                   context: context,
//                                 ),
//                                 style: TextStyle(
//                                   color: Colors.grey[500],
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 10,
//                                 ),
//                               )
//                             : MoonButton(
//                                 label: const Icon(
//                                   MoonIcons.generic_delete_24_regular,
//                                 ),
//                                 onTap: () {
//                                   showMoonModal(
//                                     context: context,
//                                     builder: (context) => FavoriteWarningDialog(
//                                       setLongPress: setLongPress,
//                                       setSelected: setSelected,
//                                       selectedToDelete: selectedToDelete,
//                                       selected: selected,
//                                       group: group,
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: CatergoryGroupChip(
//                         setLongPress: setLongPress,
//                         setSelected: setSelected,
//                         onLongPress: (p0) {
//                           selectedToDelete.value = p0;
//                         },
//                         minSelected: 0,
//                         trailing: MoonButton(
//                           leading: const Icon(
//                             MoonIcons.controls_plus_24_regular,
//                           ),
//                           width: width * factor - 100,
//                           onTap: () {
//                             showMoonModal(
//                               context: context,
//                               builder: (context) => FavoriteAddGroupDialog(
//                                 onComplete: (p0) {
//                                   DatabaseService.putFavoriteGroup(p0);
//                                 },
//                               ),
//                             );
//                           },
//                           label: const Text(
//                             'Add Group',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               // fontFamily: "HarmonyOS_Sans",
//                             ),
//                           ),
//                         ),
//                         items: group.value.map((val) => val.name).toList(),
//                         onpress: (val) {
//                           selected.value = val;
//                         },
//                         initSelected: initSelected,
//                       ),
//                     ),
//                   ),
//                   (Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       MoonButton(
//                         buttonSize: MoonButtonSize.lg,
//                         label: const Text('Cancel'),
//                         onTap: () {
//                           context.pop();
//                         },
//                       ),
//                       Row(
//                         children: [
//                           MoonButton(
//                             buttonSize: MoonButtonSize.lg,
//                             label: const Text('Delete'),
//                             onTap: ref.read(detialProvider).favorite == null
//                                 ? null
//                                 : () {
//                                     //remove from favorite
//                                     DatabaseService.deleteFavorite(
//                                       widget.meta.packageName,
//                                       widget.detailUrl,
//                                     ).then((_) {
//                                       if (!context.mounted) return;
//                                       ref
//                                           .read(detialProvider.notifier)
//                                           .putFavorite(null);
//                                       context.pop();
//                                     });
//                                   },
//                           ),
//                           MoonButton(
//                             buttonSize: MoonButtonSize.lg,
//                             label: Text('Confirm'),
//                             onTap: () {
//                               Future.microtask(() async {
//                                 final package = widget.meta.packageName;
//                                 final url = widget.detailUrl;
//                                 final fav = await DatabaseService.putFavorite(
//                                   url,
//                                   widget.detail,
//                                   package,
//                                   widget.meta.type,
//                                 );
//                                 ref
//                                     .read(detialProvider.notifier)
//                                     .putFavorite(fav);

//                                 final result =
//                                     await DatabaseService.getFavoriteGroupsByFavorite(
//                                       package,
//                                       url,
//                                     );
//                                 for (final item in result) {
//                                   final List<Favorite> itemList = item.favorites
//                                       .where((element) => element.id == fav.id)
//                                       .toList();
//                                   // remove every fav id from the group
//                                   itemList.removeWhere(
//                                     (element) => element.id == fav.id,
//                                   );
//                                   // add the fav id to the group if selected
//                                   if (selected.value.contains(
//                                     group.value.indexOf(item),
//                                   )) {
//                                     itemList.add(fav);
//                                   }
//                                   item.favorites.clear();
//                                   item.favorites.addAll(itemList);
//                                 }

//                                 await DatabaseService.putFavoriteByIndex(
//                                   result,
//                                 );
//                                 if (!context.mounted) return;
//                                 context.pop();
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   )),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DetailHeaderDelegate extends SliverPersistentHeaderDelegate {
//   double _mapRange(
//     double value,
//     double inMin,
//     double inMax,
//     double outMin,
//     double outMax,
//   ) {
//     return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
//   }

//   const DetailHeaderDelegate({
//     required this.isLoading,
//     required this.meta,
//     required this.minExt,
//     required this.maxExt,
//     required this.clampMax,
//     this.detailUrl,
//     this.detail,
//   });
//   final double maxExt;
//   final double minExt;
//   final double clampMax;
//   final bool isLoading;
//   final ExtensionDetail? detail;
//   final ExtensionMeta meta;
//   final String? detailUrl;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     debugPrint('shrinkOffset: $shrinkOffset');
//     int alpha = _mapRange(
//       shrinkOffset,
//       minExt,
//       maxExt,
//       0,
//       255,
//     ).clamp(0, clampMax).toInt();

//     return (Container(
//       decoration: BoxDecoration(
//         color: Colors.grey,
//         image: (isLoading || detail?.cover == null)
//             ? null
//             : DecorationImage(
//                 image: ExtendedNetworkImageProvider(detail?.cover ?? ''),
//                 fit: BoxFit.cover,
//               ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: Theme.of(context).brightness == Brightness.dark
//                 ? [
//                     MoonColors.dark.gohan.withAlpha(
//                       alpha,
//                     ), // Dark theme gradient colors
//                     MoonColors.dark.gohan.withAlpha(128 + (alpha ~/ 2)),
//                     MoonColors.dark.gohan,
//                   ]
//                 : [
//                     MoonColors.light.gohan.withAlpha(alpha),
//                     MoonColors.light.gohan.withAlpha(128 + (alpha ~/ 2)),
//                     MoonColors.light.gohan,
//                   ],
//           ),
//         ),
//         child: PlatformWidget(
//           mobileWidget: LayoutBuilder(
//             builder: (context, constraint) {
//               if (shrinkOffset > 60) {
//                 return MaxWidth(
//                   maxWidth: constraint.maxWidth - 20.0,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               MoonChip(
//                                 chipSize: MoonChipSize.sm,
//                                 label: const Icon(
//                                   MoonIcons.sport_featured_24_regular,
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: constraint.maxWidth * .6,
//                                 child: Text(
//                                   detail?.title ?? 'Title Not Found',
//                                   style: const TextStyle(
//                                     // fontFamily: "HarmonyOS_Sans",
//                                     overflow: TextOverflow.ellipsis,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 20,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Text(meta.name, style: const TextStyle()),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Container(
//                     child: (isLoading)
//                         ? Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               const SizedBox(width: 20),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color:
//                                       Theme.of(context).brightness ==
//                                           Brightness.dark
//                                       ? MoonColors.dark.gohan
//                                       : MoonColors.light.gohan,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Shimmer.fromColors(
//                                   baseColor: context
//                                       .moonTheme!
//                                       .segmentedControlTheme
//                                       .colors
//                                       .backgroundColor
//                                       .withAlpha(50),
//                                   highlightColor: context
//                                       .moonTheme!
//                                       .segmentedControlTheme
//                                       .colors
//                                       .backgroundColor
//                                       .withAlpha(100),
//                                   child: Container(
//                                     width: 150,
//                                     height: 200,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               const LoadingWidget(
//                                 padding: EdgeInsets.all(0),
//                                 lineCount: 2,
//                                 lineheight: 20,
//                               ),
//                             ],
//                           )
//                         : LayoutBuilder(
//                             builder: (context, contraint) =>
//                                 _DetailSideWidgetMobile(
//                                   constraint: constraint,
//                                   detail: detail,
//                                   detailUrl: detailUrl,
//                                   meta: meta,
//                                 ),
//                           ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               );
//             },
//           ),
//           desktopWidget: shrinkOffset > 250
//               ? MaxWidth(
//                   maxWidth: 1500,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 10),
//                       LayoutBuilder(
//                         builder: (context, constraint) => Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 if (detail != null)
//                                   DownloadButton(
//                                     meta: meta,
//                                     // detailUrl: detailUrl,
//                                     detail: detail!,
//                                     isIcon: true,
//                                   ),
//                                 const SizedBox(width: 10),
//                                 ConstrainedBox(
//                                   constraints: BoxConstraints(
//                                     maxWidth: constraint.maxWidth * .5,
//                                   ),
//                                   child: Text(
//                                     overflow: TextOverflow.ellipsis,
//                                     detail?.title ?? 'Title Not Found',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 25,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(meta.name, style: const TextStyle()),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 MoonButton(
//                                   leading: const Icon(
//                                     MoonIcons.media_play_24_regular,
//                                   ),
//                                   backgroundColor: context
//                                       .moonTheme
//                                       ?.segmentedControlTheme
//                                       .colors
//                                       .backgroundColor,
//                                   textColor: context
//                                       .moonTheme
//                                       ?.segmentedControlTheme
//                                       .colors
//                                       .textColor,
//                                   onTap: isLoading ? null : () {},
//                                   label: const Text('Play'),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 _FavButton(
//                                   meta: meta,
//                                   detailUrl: detailUrl,
//                                   detail: detail,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Container(
//                       constraints: const BoxConstraints(maxWidth: 1500),
//                       child: (isLoading)
//                           ? _DesktopLoadingWidgetExtended()
//                           : DesktopWebView(
//                               meta: meta,
//                               detailUrl: detailUrl,
//                               detail: detail,
//                             ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//         ),
//       ),
//     ));
//   }

//   @override
//   double get maxExtent => maxExt;

//   @override
//   double get minExtent => minExt;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
//       true;
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.isIcon,
    required this.detail,
    required this.meta,
  });

  final bool isIcon;
  final ExtensionDetail detail;
  final ExtensionMeta meta;

  @override
  Widget build(BuildContext context) {
    if (isIcon) {
      return FButton.icon(
        onPress: () => onTap(context),
        child: Icon(FIcons.download),
      );
    }
    return FButton(
      prefix: Icon(FIcons.download),
      onPress: () => onTap(context),
      child: const Text('Download'),
    );
  }

  void onTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DownloadDialog(detail, meta),
    );
  }
}

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog(this.detail, this.meta);
  final ExtensionDetail detail;
  final ExtensionMeta meta;
  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Download',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (widget.detail.episodes == null || widget.detail.episodes!.isEmpty)
            const Text('No episodes available')
          else ...[
            FTabs(
              children: widget.detail.episodes!.map((group) {
                return FTabEntry(
                  label: Text(group.title),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: group.urls.length,
                    itemBuilder: (context, index) {
                      final url = group.urls[index];
                      return ListTile(
                        title: Text(url.name),
                        onTap: () async {
                          final videoWatch =
                              await MiruCoreEndpoint.watch(
                                    url.url,
                                    widget.meta.packageName,
                                    widget.meta.type,
                                  )
                                  as ExtensionBangumiWatch?;

                          if (videoWatch == null) return;
                          await MiruDirectory.createMoviesFolder(
                            widget.detail.title,
                          );

                          try {
                            final res = await MiruGrpcClient.client
                                .downloadBangumi(
                                  proto.DownloadBangumiRequest()
                                    ..url = videoWatch.url
                                    ..downloadPath = p.join(
                                      MiruDirectory.getMoviesDirectory,
                                      widget.detail.title,
                                    )
                                    ..isHls = true,
                                );

                            MiruCoreDownload.addTask(
                              MiruDownloadTask(
                                id: res.taskId.toString(),
                                name: widget.detail.title,
                              ),
                            );
                            showSimpleToast('Download started');
                          } catch (e) {
                            logger.severe('Failed to start download: $e');
                            showSimpleToast('Failed to start download: $e');
                          }

                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     final epGroup = widget.detail.episodes;
//     return MoonModal(
//       decoration: BoxDecoration(
//         color: MoonColors.dark.goku,
//         borderRadius: const BorderRadius.all(Radius.circular(20)),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 10,
//             color: MediaQuery.of(context).platformBrightness == Brightness.light
//                 ? MoonColors.light.goku.withValues(alpha: .2)
//                 : MoonColors.dark.goku.withValues(alpha: .2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: LayoutBuilder(
//           builder: (context, constraints) => DeviceUtil.deviceWidgetFunction(
//             context: context,
//             child: MoonModal(
//               child: (epGroup == null)
//                   ? Center(child: Text("No Episodes found"))
//                   : Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Column(
//                         children: [
//                           // tabBar(),
//                           const SizedBox(height: 10),
//                           Expanded(child: tabView(epGroup, context)),
//                         ],
//                       ),
//                     ),
//             ),
//             desktop: (buildchild) => SizedBox(
//               width: constraints.maxWidth * .4,
//               height: constraints.maxHeight * .5,
//               child: buildchild,
//             ),
//             mobile: (buildchild) => SizedBox(
//               width: constraints.maxWidth * .8,
//               height: constraints.maxHeight * .8,
//               child: buildchild,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class DesktopWebView extends StatelessWidget {
  const DesktopWebView({
    super.key,
    required this.meta,
    this.detailUrl,
    this.detail,
  });
  final String? detailUrl;
  final ExtensionDetail? detail;
  final ExtensionMeta meta;
  void onTap() async {
    final url = meta.webSite + detailUrl!;
    final webview =
        await WebviewWindow.create(
            configuration: CreateConfiguration(
              windowHeight: 1280,
              windowWidth: 720,
              title: "ExampleTestWindow",
              titleBarTopPadding: Platform.isMacOS ? 20 : 0,
              // userDataFolderWindows: await _getWebViewPath(),
            ),
          )
          ..launch(url);
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final cookies = await webview.getAllCookies();

        if (cookies.isEmpty) {
          debugPrint('⚠️ no cookies found');
        }

        // final cookieString = cookies.map((e) => '${e.name}=${e.value}').toList().join(';');
        // extensionService.setcookie(cookieString);
      } catch (e, stack) {
        debugPrint('getAllCookies error: $e');
        debugPrintStack(stackTrace: stack);
      }
    });
    webview.onClose.whenComplete(() async {
      debugPrint("on close");
      timer.cancel();

      // timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: PlatformWidget(
              mobileWidget: ExtendedImage.network(
                detail?.cover ?? '',
                width: 150,
                height: 200,
                fit: BoxFit.cover,
              ),
              desktopWidget: ExtendedImage.network(
                detail?.cover ?? '',
                width: 200,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// class _DesktopLoadingWidgetExtended extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         const SizedBox(width: 20),
//         Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? MoonColors.dark.gohan
//                 : MoonColors.light.gohan,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Shimmer.fromColors(
//             baseColor: context
//                 .moonTheme!
//                 .segmentedControlTheme
//                 .colors
//                 .backgroundColor
//                 .withAlpha(50),
//             highlightColor: context
//                 .moonTheme!
//                 .segmentedControlTheme
//                 .colors
//                 .backgroundColor
//                 .withAlpha(100),
//             child: Container(
//               width: 200,
//               height: 300,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 20),
//         const LoadingWidget(
//           padding: EdgeInsets.all(0),
//           lineCount: 2,
//           lineheight: 20,
//         ),
//       ],
//     );
//   }
// }

// class _FavButton extends StatelessWidget {
//   const _FavButton({required this.meta, this.detailUrl, this.detail});
//   final String? detailUrl;
//   final ExtensionDetail? detail;
//   final ExtensionMeta meta;
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, _) {
//         final fav = ref.watch(detialProvider).favorite;
//         return MoonChip(
//           isActive: fav != null,
//           label: Text(
//             fav != null ? 'Favorited' : 'Favorite',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           leading: const Icon(MoonIcons.generic_star_24_regular),
//           onTap: () {
//             if (detail == null || detailUrl == null) {
//               return;
//             }
//             // showMoonModal(
//             //   context: context,
//             //   builder: (context) => _FavoriteDialog(
//             //     meta: meta,
//             //     detail: detail!,
//             //     detailUrl: detailUrl!,
//             //   ),
//             // );
//           },
//         );
//       },
//     );
//   }
// }
