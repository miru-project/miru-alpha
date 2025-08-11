import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/objectbox.g.dart';
import 'package:miru_app_new/provider/anilist_change_notifier.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/tracking/anilist_provider.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/pages/download_page.dart';
import 'package:miru_app_new/views/pages/home/index.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:go_router/go_router.dart';

class MainPageState {
  int selectedIndex;
  List<int> selectedGroups;
  String searchText;
  List<History> history;

  MainPageState({this.selectedIndex = 0, this.selectedGroups = const [], this.searchText = '', this.history = const []});

  MainPageState copyWith({int? selectedIndex, List<int>? selectedGroups, String? searchText, List<History>? history}) {
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
    // Initial load of history
    final history = DatabaseService.historys.query().order(History_.date, flags: Order.descending).build().find();
    return MainPageState(history: history);
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
}

// Riverpod provider for MainPageNotifier
final mainPageProvider = NotifierProvider<MainPageNotifier, MainPageState>(() => MainPageNotifier());

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
    final extensionIsExist = ExtensionUtils.runtimes.containsKey(item.package);
    return GestureDetector(
      onTap: () {
        if (extensionIsExist) {
          context.push('/search/detail', extra: DetailParam(service: ExtensionUtils.runtimes[item.package]!, url: item.url));
        }
      },
      child: Container(
        decoration: BoxDecoration(color: context.theme.colors.muted, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            ExtendedImage.network(
              shape: BoxShape.rectangle,
              fit: BoxFit.fitHeight,
              item.cover ?? '',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(10)),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: DeviceUtil.getWidth(context) * .2,
              child: DefaultTextStyle(
                style: TextStyle(color: context.moonTheme?.chipTheme.colors.textColor, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                child: SizedBox(
                  width: DeviceUtil.device(mobile: DeviceUtil.getWidth(context) - 200, desktop: DeviceUtil.getWidth(context) * .25, context: context),
                  child: Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(flex: 3, child: Text(item.title, maxLines: 2, style: const TextStyle(fontSize: 20, fontFamily: "HarmonyOS_Sans"))),
                      const Expanded(flex: 1, child: SizedBox(height: 10)),
                      Text(item.episodeTitle, maxLines: 2, style: const TextStyle(fontSize: 17, fontFamily: "HarmonyOS_Sans")),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            ExtendedImage.network(
                              loadStateChanged: (state) {
                                if (state.extendedImageLoadState == LoadState.failed) {
                                  return const Icon(Icons.error);
                                }
                                return null;
                              },
                              cache: true,
                              extensionIsExist ? ExtensionUtils.runtimes[item.package]!.meta.icon ?? '' : '',
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              extensionIsExist ? ExtensionUtils.runtimes[item.package]!.meta.name : 'Unknown',
                              style: const TextStyle(fontFamily: "HarmonyOS_Sans"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(flex: 1, child: Text(convertTime(item.date))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

class FavoriteTab extends ConsumerStatefulWidget {
  const FavoriteTab({super.key});
  @override
  createState() => _FavoriteTabState();
}

class _FavoriteTabState extends ConsumerState<FavoriteTab> {
  final ValueNotifier<List<FavoriateGroup>> favGroup = ValueNotifier([]);
  final ValueNotifier<List<int>> setLongPress = ValueNotifier([]);
  @override
  void initState() {
    favGroup.value = DatabaseService.getAllFavoriteGroup();
    DatabaseService.favGroup.query().watch().listen((query) {
      favGroup.value = DatabaseService.getAllFavoriteGroup();
    });
    super.initState();
  }

  String text = '';
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final errorText = useState<String?>(null);
    final isShowAddPopUp = useState(false);

    textController.addListener(() {
      text = textController.text;
      if (text.isEmpty) {
        errorText.value = 'Name is empty';
        return;
      }
      if (favGroup.value.any((element) => element.name == text)) {
        errorText.value = 'Same name exists';
        return;
      }
      errorText.value = null;
    });

    final selected = ref.watch(mainPageProvider).selectedGroups;

    void showPopUp(List<FavoriateGroup> favGroupValue, int index) {
      textController.text = favGroupValue[index].name;
      setLongPress.value = [index];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: (ValueListenableBuilder(
        valueListenable: favGroup,
        builder:
            (context, favGroupValue, _) => DeviceUtil.deviceWidgetFunction(
              child: <Widget>[
                ...List.generate(
                  favGroupValue.length,
                  (index) => GestureDetector(
                    onSecondaryTap: () => showPopUp(favGroupValue, index),
                    child: MoonPopover(
                      onTapOutside: () {
                        setLongPress.value = [];
                      },
                      maxWidth: 170,
                      decoration: BoxDecoration(color: context.moonTheme?.chipTheme.colors.backgroundColor, borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      popoverPosition: MoonPopoverPosition.bottom,
                      content: Column(
                        children: [
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: context.moonTheme?.chipTheme.colors.textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: "HarmonyOS_Sans",
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Material(
                              child: MoonFormTextInput(
                                errorText: errorText.value,
                                inactiveBorderColor: Colors.transparent,
                                hintText: 'Group Name',
                                trailing: MoonButton.icon(
                                  onTap: () {
                                    textController.clear();
                                  },
                                  buttonSize: MoonButtonSize.sm,
                                  icon: const Icon(MoonIcons.controls_close_24_regular),
                                ),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans"),
                                controller: textController,
                              ),
                            ),
                          ),
                          // const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MoonButton.icon(
                                onTap: () {
                                  // delete group
                                  DatabaseService.deleteFavoriteGroup([favGroupValue[index].name]);
                                  if (selected.contains(index)) {
                                    final update = List<int>.from(selected);
                                    update.removeWhere((element) => element == index);
                                    ref.read(mainPageProvider.notifier).setSelectedGroups(update);
                                    setLongPress.value = [];
                                    return;
                                  }
                                  //shift the selected index after delete
                                  for (int i = 0; i < selected.length; i++) {
                                    if (selected[i] > index) {
                                      selected[i]--;
                                    }
                                  }
                                  setLongPress.value = [];
                                },
                                icon: const Icon(MoonIcons.generic_delete_24_light),
                                // label: const Text('Remove'),
                              ),
                              MoonButton.icon(
                                iconColor: context.moonTheme?.segmentedControlTheme.colors.backgroundColor,
                                icon: const Icon(MoonIcons.generic_edit_24_regular),
                                onTap:
                                    errorText.value == null
                                        ? () {
                                          final oldname = favGroupValue[index].name;
                                          DatabaseService.renameFavoriteGroup(oldname, textController.text);
                                          setLongPress.value = [];
                                        }
                                        : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      show: setLongPress.value.contains(index),
                      child: MoonChip(
                        onLongPress: () => showPopUp(favGroupValue, index),
                        onTap: () {
                          final update = List<int>.from(selected);
                          if (selected.contains(index)) {
                            update.remove(index);
                            ref.read(mainPageProvider.notifier).setSelectedGroups(update);
                            return;
                          }
                          update.add(index);
                          ref.read(mainPageProvider.notifier).setSelectedGroups(update);
                        },
                        isActive: selected.contains(index),
                        gap: 5,
                        label: Text(
                          favGroupValue[index].name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans"),
                        ),
                      ),
                    ),
                  ),
                ),
                MoonPopover(
                  popoverPosition: MoonPopoverPosition.bottom,
                  onTapOutside: () => isShowAddPopUp.value = false,
                  show: isShowAddPopUp.value,
                  decoration: BoxDecoration(color: context.moonTheme?.chipTheme.colors.backgroundColor, borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  maxWidth: 170,
                  content: Column(
                    children: [
                      Text(
                        'Add',
                        style: TextStyle(
                          color: context.moonTheme?.chipTheme.colors.textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: "HarmonyOS_Sans",
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Material(
                          child: MoonFormTextInput(
                            errorText: errorText.value,
                            inactiveBorderColor: Colors.transparent,
                            hintText: 'Group Name',
                            trailing: MoonButton.icon(
                              onTap: () {
                                textController.clear();
                              },
                              buttonSize: MoonButtonSize.sm,
                              icon: const Icon(MoonIcons.controls_close_24_regular),
                            ),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans"),
                            // textInputSize:
                            //     MoonTextInputSize.sm,
                            controller: textController,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 10),
                      MoonButton.icon(
                        iconColor: context.moonTheme?.segmentedControlTheme.colors.backgroundColor,
                        icon: const Text('Confirm'),
                        onTap:
                            errorText.value == null
                                ? () {
                                  DatabaseService.putFavoriteGroup(textController.text);
                                  textController.clear();
                                  isShowAddPopUp.value = false;
                                  context.pop();
                                }
                                : null,
                      ),
                    ],
                  ),
                  child: MoonButton(
                    backgroundColor: context.moonTheme?.chipTheme.colors.backgroundColor,
                    leading: const Icon(MoonIcons.controls_plus_24_regular),
                    onTap: () {
                      textController.clear();
                      isShowAddPopUp.value = !isShowAddPopUp.value;
                    },
                    label: const Text('ADD'),
                  ),
                ),
              ],
              mobile: (children) => Wrap(spacing: 5, runSpacing: 10, children: children),
              desktop: (children) => SizedBox(height: 35, child: ListView(scrollDirection: Axis.horizontal, children: children)),
              context: context,
            ),
      )),
    );
  }
}

final _notifer = AnilistPageNotifier();

class HomePage extends StatefulHookConsumerWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _categories = ['History', 'Favorite', 'Tracking', 'Download'];
  static final List<DateTime?> _times = [
    null,
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().subtract(const Duration(days: 30)),
  ];
  static const List<ExtensionType?> _types = [null, ExtensionType.bangumi, ExtensionType.manga, ExtensionType.fikushon];
  int _selectedTime = 0;
  int _selectedType = 0;

  List<History> filterByDateAndCategory(DateTime? date, ExtensionType? type) {
    if (date == null && type == null) {
      // return DatabaseService.db.historys
      //     .where()
      //     .sortByDateDesc()
      //     .limit(40)
      //     .findAllSync();
      final query = DatabaseService.historys.query().order(History_.date, flags: Order.descending).build();
      return query.find();
    }
    if (date != null && type != null) {
      final query =
          DatabaseService.historys
              .query(History_.date.lessThanDate(date) & History_.type.equals(EnumToString.convertToString(type)))
              .order(History_.date, flags: Order.descending)
              .build();
      return query.find();
      // return DatabaseService.db.historys
      //     .filter()
      //     .dateLessThan(date)
      //     .typeEqualTo(type)
      //     .findAllSync();
    }
    if (date == null) {
      final query =
          DatabaseService.historys
              .query(History_.type.equals(EnumToString.convertToString(type!)))
              .order(History_.date, flags: Order.descending)
              .build();
      return query.find();
      // return DatabaseService.db.historys
      //     .filter()
      //     .typeEqualTo(type!)
      //     .findAllSync();
    }
    return DatabaseService.historys.query(History_.date.lessThanDate(date)).build().find();
    // return DatabaseService.db.historys
    //     .filter()
    //     .dateLessThan(date)
    //     .findAllSync();
  }

  Widget buildHomeSearchBar(TextEditingController textcontroller, ValueNotifier<String> search) {
    return SideBarSearchBar(
      controller: textcontroller,
      trailing: MoonButton.icon(
        icon: const Icon(MoonIcons.controls_close_24_regular),
        onTap: () {
          textcontroller.clear();
          search.value = '';
        },
      ),
      onChanged: (p0) {
        search.value = p0;
      },
    );
  }

  static const _anilistStatus = ['CURRENT', 'PLANNING', 'COMPLETED', 'DROPPED', 'PAUSED', 'REPEATING'];
  @override
  Widget build(BuildContext context) {
    //  final selected = useState(<int>[]);
    final currentTab = useState(0);
    final tabcontroller = useTabController(initialLength: _categories.length);
    final search = useState('');
    final anilistCurrentStatus = useState(_anilistStatus[0]);
    final textcontroller = useTextEditingController();
    final aniListisAnime = useState(true);
    tabcontroller.addListener(() {
      currentTab.value = tabcontroller.index;
    });
    // final setLongPress = useState(<int>[]);
    return MiruScaffold(
      mobileHeader: SideBarListTitle(title: (tabcontroller.index == 2) ? 'Anilist' : 'Home'),
      sidebar: DeviceUtil.device(
        context: context,
        mobile: <Widget>[
          if (tabcontroller.index == 2)
            ListenableBuilder(
              listenable: _notifer,
              builder: (context, _) {
                if (!_notifer.anilistIsLogin) {
                  return const SizedBox(height: 40);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ExtendedImage.network(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        width: 40,
                        height: 40,
                        _notifer.anilistUserData.userData["UserAvatar"],
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _notifer.anilistUserData.userData["User"],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans"),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            buildHomeSearchBar(textcontroller, search),

          const SizedBox(height: 10),
          MoonTabBar(tabController: tabcontroller, tabs: List.generate(_categories.length, (index) => MoonTab(label: Text(_categories[index])))),
          // const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: tabcontroller,
              children: <Widget>[
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans"),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text('Time'),
                        CatergoryGroupChip(
                          maxSelected: 1,
                          minSelected: 1,
                          items: const ['All', '1 day', '1 week', '1 month'],
                          onpress: (val) {
                            _selectedTime = val[0];
                            final history = filterByDateAndCategory(_times[_selectedTime], _types[_selectedType]);
                            debugPrint(history.toString());
                            ref.read(mainPageProvider.notifier).updateHistory(history);
                          },
                          initSelected: const [0],
                        ),
                        const SizedBox(height: 10),
                        const Text('Category'),
                        CatergoryGroupChip(
                          maxSelected: 1,
                          minSelected: 1,
                          items: const ['All', 'Video', 'Comic', 'Novel'],
                          onpress: (val) {
                            _selectedType = val[0];
                            final history = filterByDateAndCategory(_times[_selectedTime], _types[_selectedType]);
                            debugPrint(history.toString());
                            ref.read(mainPageProvider.notifier).updateHistory(history);
                          },
                          initSelected: const [0],
                        ),
                      ],
                    ),
                  ),
                ),
                FavoriteTab(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text('Anilist'),
                        CatergoryGroupChip(
                          maxSelected: 1,
                          minSelected: 1,
                          items: const ['Anime', 'Manga'],
                          onpress: (val) {
                            aniListisAnime.value = val[0] == 0;
                          },
                          initSelected: const [0],
                        ),
                        const SizedBox(height: 10),
                        const Text('Anilist Status'),
                        CatergoryGroupChip(
                          maxSelected: 1,
                          minSelected: 1,
                          items: _anilistStatus,
                          onpress: (val) {
                            anilistCurrentStatus.value = _anilistStatus[val[0]];
                          },
                          initSelected: const [0],
                        ),
                      ],
                    ),
                  ),
                ),
                DownloadPage(),
              ],
            ),
          ),
        ],
        desktop: <Widget>[
          const SideBarListTitle(title: 'Home'),
          buildHomeSearchBar(textcontroller, search),
          const SizedBox(height: 10),
          if (currentTab.value == 0) ...[
            SidebarExpander(
              title: 'Time',
              expanded: true,
              child: CategoryGroup(
                needSpacer: false,
                items: const ['All', '1 day', '1 week', '1 month'],
                onpress: (val) {
                  final history = filterByDateAndCategory(_times[val], _types[_selectedType]);
                  debugPrint(history.toString());
                  ref.read(mainPageProvider.notifier).updateHistory(history);
                },
              ),
            ),
            const SizedBox(height: 10),
            SidebarExpander(
              title: 'Type',
              expanded: true,
              child: CategoryGroup(
                needSpacer: false,
                items: const ['ALL', 'Video', 'Comic', 'Novel'],
                onpress: (val) {
                  final history = filterByDateAndCategory(_times[_selectedTime], _types[val]);
                  debugPrint(history.toString());
                  ref.read(mainPageProvider.notifier).updateHistory(history);
                },
              ),
            ),
          ] else if (currentTab.value == 2) ...[
            ListenableBuilder(
              listenable: _notifer,
              builder:
                  (context, _) => SidebarExpander(
                    title: 'Anilist',
                    actions:
                        _notifer.anilistIsLogin
                            ? [
                              MoonButton.icon(
                                icon: const Text('Logout'),
                                onTap: () {
                                  _notifer.logoutAniList();
                                },
                              ),
                            ]
                            : null,
                    expanded: true,
                    child: CategoryGroup(
                      needSpacer: false,
                      items: const ['Anime', 'Manga'],
                      onpress: (val) {
                        aniListisAnime.value = val == 0;
                      },
                    ),
                  ),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
      body: PlatformWidget(
        mobileWidget: TabBarView(
          controller: tabcontroller,
          children: <Widget>[
            HistoryPage(),
            FavoritePage(),
            _AnilistHomePage(anilistStatus: anilistCurrentStatus, anilistisAnime: aniListisAnime),
            DownloadPage(),
          ],
        ),
        desktopWidget: HistoryPage(),
        // LayoutBuilder(
        //   builder:
        //       (context, cons) => Column(
        //         children: [
        //           const SizedBox(height: 10),
        //           Center(
        //             child: Container(
        //               decoration: BoxDecoration(color: context.theme.colors.muted, borderRadius: BorderRadius.circular(15)),
        //               child: Padding(
        //                 padding: const EdgeInsets.fromLTRB(12, 5, 12, 7),
        //                 child: MoonTabBar(
        //                   tabController: tabcontroller,
        //                   tabs: List.generate(
        //                     _categories.length,
        //                     (index) => MoonTab(
        //                       tabStyle: const MoonTabStyle(indicatorHeight: 3, textStyle: TextStyle(fontSize: 17)),
        //                       label: Text(_categories[index]),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           if (currentTab.value == 1) FavoriteTab(),
        //           if (currentTab.value == 2) ...[
        //             const SizedBox(height: 20),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: List.generate(
        //                 _anilistStatus.length,
        //                 (index) => MoonChip(
        //                   onTap: () {
        //                     anilistCurrentStatus.value = _anilistStatus[index];
        //                   },
        //                   isActive: anilistCurrentStatus.value == _anilistStatus[index],
        //                   chipSize: MoonChipSize.sm,
        //                   label: Text(_anilistStatus[index], style: const TextStyle(fontFamily: 'HarmonyOS_Sans', fontWeight: FontWeight.bold)),
        //                 ),
        //               ),
        //             ),
        //           ],
        //           const SizedBox(height: 10),
        //           Expanded(
        //             child: TabBarView(
        //               controller: tabcontroller,
        //               children: <Widget>[
        //                 HistoryPage(),
        //                 FavoritePage(),
        //                 _AnilistHomePage(anilistisAnime: aniListisAnime, anilistStatus: anilistCurrentStatus),
        //                 DownloadPage(),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        // ),
      ),
    );
  }
}

class _AnilistHomePage extends ConsumerStatefulWidget {
  @override
  createState() => _AnilistHomePageState();
  final ValueNotifier<String> anilistStatus;
  final ValueNotifier<bool> anilistisAnime;
  const _AnilistHomePage({required this.anilistStatus, required this.anilistisAnime});
}

class _AnilistHomePageState extends ConsumerState<_AnilistHomePage> with AutomaticKeepAliveClientMixin {
  @override
  get wantKeepAlive => true;
  bool isLogin = false;

  final type = ValueNotifier(AnilistType.anime);
  @override
  void initState() {
    _notifer.init();
    _notifer.anilistDataLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: _notifer,
      builder: (context, child) {
        if (_notifer.anilistIsLogin) {
          if (_notifer.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          debugPrint(_notifer.anilistUserData.userData.toString());
          // debugPrint(notifer.anilistUserData.animeData["CURRENT"].toString());
          return ValueListenableBuilder(
            valueListenable: widget.anilistisAnime,
            builder: (context, isanime, child) {
              return ValueListenableBuilder(
                valueListenable: widget.anilistStatus,
                builder:
                    (context, value, child) => LayoutBuilder(
                      builder: (context, cons) {
                        final element = isanime ? _notifer.anilistUserData.animeData[value] : _notifer.anilistUserData.mangaData[value];

                        if (element == null) {
                          return const Center(
                            child: Text('No data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans")),
                          );
                        }
                        return MiruGridView(
                          mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cons.maxWidth ~/ 110, childAspectRatio: 0.6),
                          desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cons.maxWidth ~/ 180,
                            childAspectRatio: 0.65,
                          ),
                          itemBuilder:
                              (context, index) => MiruGridTile(
                                onTap: () {
                                  context.push('/search', extra: element[index]["media"]["title"]["userPreferred"]);
                                },
                                imageUrl: element[index]["media"]["coverImage"]["large"],
                                title: element[index]["media"]["title"]["userPreferred"],
                                subtitle:
                                    '${element[index]["progress"]} / ${element[index]["media"]["episodes"]} / ${element[index]["media"]["episodes"]}',
                              ),
                          itemCount: element.length,
                        );
                      },
                    ),
              );
            },
          );
        }
        return Center(
          child: MoonButton(
            label: const Text('Login to Anilist'),
            onTap: () {
              _notifer.loginAniList(context);
            },
          ),
        );
      },
    );
  }
}
