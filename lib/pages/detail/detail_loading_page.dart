import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/pages/detail/desktop_loaded_page.dart';
import 'package:miru_app_new/pages/detail/mobile_loaded_page.dart';
import 'package:miru_app_new/provider/detial_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/store/database_service.dart';

import 'package:miru_app_new/widgets/error.dart';

class DetailLoadingPage extends StatefulHookConsumerWidget {
  const DetailLoadingPage({super.key, required this.meta, required this.url});
  final ExtensionMeta meta;
  final String url;

  @override
  createState() => _DetailLoadPageState();
}

class _DetailLoadPageState extends ConsumerState<DetailLoadingPage> {
  @override
  void initState() {
    Future.microtask(() async {
      final history = await DatabaseService.getHistoryByPackageAndUrl(
        widget.meta.packageName,
        widget.url,
      );
      ref.read(detialProvider.notifier).putHistory(history);
    });
    // Trigger detail fetch via DetialProvider so UI doesn't depend directly on the fetch provider
    Future.microtask(
      () => ref
          .read(detialProvider.notifier)
          .fetchDetail(widget.meta.packageName, widget.url),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final detial =
        ref.watch(detialProvider).detailState ?? const AsyncValue.loading();
    return detial.when(
      data: (detial) => DeviceUtil.platformWidget(
        mobile: MobileLoadedPage(
          detail: detial,
          meta: widget.meta,
          detailUrl: widget.url,
        ),
        desktop: DesktopLoadedPage(
          detail: detial,
          meta: widget.meta,
          detailUrl: widget.url,
        ),
      ),
      error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
      loading: () => Center(child: FCircularProgress()),
    );
  }
  // {
  //   final tancontroller = useTabController(initialLength: _trackingTab.length);
  //   final snapShot =
  //       ref.watch(detialProvider).detailState ?? const AsyncValue.loading();
  //   final isdropDown = useState(false);
  //   final epGroup = useState(<ExtensionEpisodeGroup>[]);
  //   return MiruScaffold(
  //     mobileHeader: Align(
  //       alignment: Alignment.centerLeft,
  //       child: MoonButton(
  //         label: const Text(
  //           'Detail',
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //         ),
  //         onTap: () {
  //           context.pop();
  //         },
  //         leading: const Icon(MoonIcons.controls_chevron_left_16_regular),
  //       ),
  //     ),
  //     sidebar:
  //         DeviceUtil.isMobileLayout(context)
  //             ? <Widget>[
  //               const SizedBox(height: 10),
  //               Row(
  //                 children: <Widget>[
  //                   Consumer(
  //                     builder: (context, ref, _) {
  //                       final hist = ref.watch(detialProvider).history;
  //                       return MoonButton(
  //                         onTap:
  //                             hist == null
  //                                 ? null
  //                                 : () {
  //                                   final state =
  //                                       ref.watch(detialProvider).detailState;
  //                                   state?.whenData((data) {
  //                                     if (data.episodes == null ||
  //                                         data.episodes!.isEmpty) {
  //                                       return;
  //                                     }
  //                                     context.push(
  //                                       '/watch',
  //                                       extra: WatchParams(
  //                                         name: hist.title,
  //                                         detailImageUrl: data.cover ?? '',
  //                                         selectedEpisodeIndex: hist.episodeId,
  //                                         selectedGroupIndex:
  //                                             hist.episodeGroupId,
  //                                         epGroup: data.episodes,
  //                                         detailUrl: widget.url,
  //                                         url:
  //                                             data
  //                                                 .episodes![hist
  //                                                     .episodeGroupId]
  //                                                 .urls[hist.episodeId]
  //                                                 .url,
  //                                         meta: widget.meta,
  //                                         type: widget.meta.type,
  //                                       ),
  //                                     );
  //                                   });
  //                                 },
  //                         label: const Text('play'),
  //                         leading: const Icon(MoonIcons.media_play_24_regular),
  //                       );
  //                     },
  //                   ),
  //                   SizedBox(
  //                     width: DeviceUtil.getWidth(context) / 3,
  //                     child: MoonDropdown(
  //                       dropdownAnchorPosition: MoonDropdownAnchorPosition.top,
  //                       show: isdropDown.value,
  //                       content: Column(
  //                         children: List.generate(
  //                           epGroup.value.length,
  //                           (index) => MoonMenuItem(
  //                             label: Text(
  //                               overflow: TextOverflow.ellipsis,
  //                               epGroup.value[index].title,
  //                               style: TextStyle(),
  //                             ),
  //                             onTap: () {
  //                               ref
  //                                   .read(detialProvider)
  //                                   .setSelectedGroup(index);
  //                               isdropDown.value = false;
  //                             },
  //                           ),
  //                         ),
  //                       ),
  //                       child: Consumer(
  //                         builder: (context, ref, _) {
  //                           final sel =
  //                               ref.watch(detialProvider).selectedGroup.value;
  //                           return MoonButton(
  //                             label: Text(
  //                               overflow: TextOverflow.ellipsis,
  //                               epGroup.value.isEmpty
  //                                   ? 'No Season'
  //                                   : epGroup.value[sel].title,
  //                             ),
  //                             onTap: () {
  //                               isdropDown.value = !isdropDown.value;
  //                             },
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //                   MoonButton(
  //                     label: const Text('WebView'),
  //                     onTap: () {
  //                       context.push(
  //                         '/mobileWebView',
  //                         extra: WebviewParam(
  //                           url: widget.url,
  //                           meta: widget.meta,
  //                         ),
  //                       );
  //                     },
  //                     leading: const Icon(MoonIcons.generic_globe_24_regular),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 10),
  //               MoonTabBar(
  //                 tabController: tancontroller,
  //                 tabs: List.generate(
  //                   _trackingTab.length,
  //                   (index) => MoonTab(label: Text(_trackingTab[index])),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               SizedBox(
  //                 height: 200,
  //                 child: TabBarView(
  //                   controller: tancontroller,
  //                   children: [Container(), Container()],
  //                 ),
  //               ),
  //             ]
  //             : null,
  //     body: snapShot.when(
  //       data: (data) {
  //         epGroup.value = data.episodes ?? [];
  //         return MediaQuery.removePadding(
  //           context: context,
  //           child: PlatformWidget(
  //             mobileWidget: MobileDetail(
  //               detailUrl: widget.url,
  //               isLoading: false,
  //               data: data,
  //               meta: widget.meta,
  //               ep: DetailEpButton(
  //                 detail: data,
  //                 notifier: ref.watch(detialProvider).selectedGroup,
  //                 onTap: (value) {
  //                   context.push(
  //                     '/watch',
  //                     extra: WatchParams(
  //                       detailUrl: widget.url,
  //                       detailImageUrl: data.cover ?? '',
  //                       name: data.title,
  //                       selectedEpisodeIndex: value,
  //                       selectedGroupIndex:
  //                           ref.watch(detialProvider).selectedGroup.value,
  //                       epGroup: data.episodes,
  //                       url:
  //                           data
  //                               .episodes![ref
  //                                   .watch(detialProvider)
  //                                   .selectedGroup
  //                                   .value]
  //                               .urls[value]
  //                               .url,
  //                       meta: widget.meta,
  //                       type: widget.meta.type,
  //                     ),
  //                   );
  //                 },
  //                 spacing: 8,
  //                 runSpacing: 10,
  //               ),
  //               desc: Text(
  //                 maxLines: 3,
  //                 overflow: TextOverflow.ellipsis,
  //                 data.desc ?? 'No Description',
  //                 style: const TextStyle(fontSize: 12),
  //               ),
  //             ),
  //             desktopWidget: DesktopDetail(
  //               isLoading: false,
  //               detailUrl: widget.url,
  //               data: data,
  //               extensionMeta: widget.meta,
  //               ep: DetailEpButton(
  //                 notifier: ref.watch(detialProvider).selectedGroup,
  //                 detail: data,
  //                 onTap: (value) {
  //                   context.push(
  //                     '/watch',
  //                     extra: WatchParams(
  //                       name: data.title,
  //                       detailImageUrl: data.cover ?? '',
  //                       selectedEpisodeIndex: value,
  //                       selectedGroupIndex:
  //                           ref.watch(detialProvider).selectedGroup.value,
  //                       epGroup: data.episodes,
  //                       detailUrl: widget.url,
  //                       url:
  //                           data
  //                               .episodes![ref
  //                                   .watch(detialProvider)
  //                                   .selectedGroup
  //                                   .value]
  //                               .urls[value]
  //                               .url,
  //                       meta: widget.meta,
  //                       type: widget.meta.type,
  //                     ),
  //                   );
  //                 },
  //                 spacing: 20,
  //                 runSpacing: 10,
  //               ),
  //               season: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: List.generate(
  //                   (data.episodes ?? []).length,
  //                   (index) => MoonChip(
  //                     width: double.infinity,
  //                     height: 30,
  //                     isActive: false,

  //                     label: Expanded(child: Text(data.episodes![index].title)),
  //                     onTap: () {
  //                       ref.read(detialProvider).setSelectedGroup(index);
  //                     },
  //                     // backgroundColor: Theme.of(context).primaryColor,
  //                   ),
  //                 ),
  //               ),
  //               desc: Text(
  //                 data.desc ?? 'No Description',
  //                 style: const TextStyle(fontSize: 16),
  //               ),
  //               // cast: _DetailCast(),
  //             ),
  //           ),
  //         );
  //       },
  //       loading:
  //           () => PlatformWidget(
  //             mobileWidget: MobileDetail(
  //               isLoading: true,
  //               meta: widget.meta,
  //               desc: const LoadingWidget(
  //                 lineCount: 3,
  //                 lineheight: 8,
  //                 lineSeperate: 8,
  //                 padding: EdgeInsets.all(5),
  //               ),
  //               ep: const LoadingWidget(
  //                 lineCount: 3,
  //                 lineheight: 20,
  //                 lineSeperate: 15,
  //                 padding: EdgeInsets.all(5),
  //               ),
  //             ),
  //             desktopWidget: DesktopDetail(
  //               isLoading: true,
  //               // cast: const LoadingWidget(lineCount: 8, lineheight: 20),
  //               ep: const LoadingWidget(lineCount: 8, lineheight: 20),
  //               season: const LoadingWidget(lineCount: 4, lineheight: 20),
  //               desc: const LoadingWidget(lineCount: 8, lineheight: 20),
  //               extensionMeta: widget.meta,
  //             ),
  //           ),
  //       error: (err, stack) => ErrorDisplay.network(err: err, stack: stack),
  //     ),
  //   );
  // }
}
