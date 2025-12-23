import 'package:collection/collection.dart';
// trigger refresh
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/core/device_util.dart';

export 'library_page.dart';

class MainPageState {
  int selectedIndex;
  List<int> selectedGroups;
  String searchText;
  List<History> history;

  MainPageState({
    this.selectedIndex = 0,
    this.selectedGroups = const [],
    this.searchText = '',
    this.history = const [],
  });

  MainPageState copyWith({
    int? selectedIndex,
    List<int>? selectedGroups,
    String? searchText,
    List<History>? history,
  }) {
    return MainPageState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      searchText: searchText ?? this.searchText,
      history: history ?? this.history,
    );
  }
}

class MainPageNotifier extends Notifier<MainPageState> {
  @override
  MainPageState build() {
    Future.microtask(() async {
      final history = await DatabaseService.getHistoriesByType();
      state = state.copyWith(history: history);
    });
    return MainPageState();
  }

  void setSelectedIndex(int index) {
    if (state.selectedIndex != index) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  void setSelectedGroups(List<int> groups) {
    state = state.copyWith(selectedGroups: groups);
  }

  void setSearchText(String text) {
    state = state.copyWith(searchText: text);
  }

  void updateHistory(List<History> updateValue) {
    state = state.copyWith(history: updateValue);
  }

  void addHistory(History history) {
    state = state.copyWith(history: [history, ...state.history]);
  }

  Future<void> refreshHistory() async {
    final history = await DatabaseService.getHistoriesByType();
    state = state.copyWith(history: history);
  }
}

// Riverpod provider for MainPageNotifier
final mainPageProvider = NotifierProvider<MainPageNotifier, MainPageState>(
  () => MainPageNotifier(),
);

class HomePageCarousel extends ConsumerWidget {
  const HomePageCarousel({super.key, required this.item});
  final History item;

  String convertTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.read(extensionPageProvider).metaData;
    final ExtensionMeta? ext = meta.firstWhereOrNull(
      (element) => element.packageName == item.package,
    );
    return FCard.raw(
      child: Row(
        children: [
          Flexible(
            child: ExtendedImage.network(
              // shape: BoxShape.rectangle,
              fit: BoxFit.fitHeight,
              item.cover ?? '',
              // borderRadius: const BorderRadius.horizontal(
              //   left: Radius.circular(20),
              //   right: Radius.circular(10),
              // ),
            ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            // width: DeviceUtil.getWidth(context) * .2,
            child: DefaultTextStyle(
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              child: SizedBox(
                width: DeviceUtil.device(
                  mobile: DeviceUtil.getWidth(context) - 200,
                  desktop: DeviceUtil.getWidth(context) * .25,
                  context: context,
                ),
                child: Padding(
                  padding: .all(10),
                  child: Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.title,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Text(
                        item.episodeTitle,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            ExtendedImage.network(
                              loadStateChanged: (state) {
                                if (state.extendedImageLoadState ==
                                    LoadState.failed) {
                                  return const Icon(Icons.error);
                                }
                                return null;
                              },
                              cache: true,
                              ext?.icon ?? '',
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ext?.name ?? "Name Not Found",
                              style: const TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(convertTime(item.date)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class HistoryPage extends StatefulHookConsumerWidget {
//   const HistoryPage({super.key});
//   @override
//   createState() => _HistoryPageState();
// }

// class _HistoryPageState extends ConsumerState<HistoryPage> with AutomaticKeepAliveClientMixin {
//   @override
//   get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final history = DatabaseService.historys.query().order(History_.date, flags: Order.descending).build().find();
//       ref.read(mainPageProvider.notifier).updateHistory(history);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final selectedDot = useState(0);
//     final width = DeviceUtil.getWidth(context);
//     final history = ref.watch(mainPageProvider).history;
//     return CustomScrollView(
//       slivers: [
//         const SliverToBoxAdapter(child: SizedBox(height: 10)),
//         SliverToBoxAdapter(
//           child: SizedBox(
//             height: DeviceUtil.device(mobile: 200, desktop: 300, context: context),
//             child: OverflowBox(
//               maxWidth: DeviceUtil.device(mobile: width, desktop: width * .9, context: context),
//               child: MoonCarousel(
//                 loop: true,
//                 autoPlay: true,
//                 autoPlayDelay: const Duration(seconds: 5),
//                 gap: 12,
//                 itemCount: 10,
//                 itemExtent: DeviceUtil.device(mobile: width - 32, desktop: width * .4, context: context),
//                 onIndexChanged: (int index) => selectedDot.value = index,
//                 itemBuilder: (BuildContext context, int itemIndex, int _) {
//                   if (history.length <= itemIndex) {
//                     return const Center(
//                       child: Text('No history', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: "HarmonyOS_Sans")),
//                     );
//                   }
//                   final item = history[itemIndex];
//                   return HomePageCarousel(item: item);
//                 },
//               ),
//             ),
//           ),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           sliver: SliverToBoxAdapter(child: MoonDotIndicator(selectedDot: selectedDot.value, dotCount: 10)),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.all(15.0),
//           sliver: SliverGrid(
//             gridDelegate: DeviceUtil.device(
//               mobile: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: DeviceUtil.getWidth(context) ~/ 110, childAspectRatio: 0.6),
//               desktop: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 180, childAspectRatio: 0.65),
//               context: context,
//             ),
//             delegate: SliverChildBuilderDelegate((context, index) {
//               final item = history[index];
//               return MiruGridTile(
//                 title: item.title,
//                 subtitle: item.episodeTitle,
//                 imageUrl: item.cover,
//                 onTap: () {
//                   final extensionIsExist = ExtensionUtils.runtimes.containsKey(item.package);
//                   if (extensionIsExist) {
//                     context.push('/search/detail', extra: DetailParam(service: ExtensionUtils.runtimes[item.package]!, url: item.url));
//                   }
//                 },
//               );
//             }, childCount: history.length),
//           ),
//         ),
//       ],
//     );
//   }
// }
