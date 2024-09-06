import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:isar/isar.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends StatefulHookWidget {
  const HistoryPage({super.key, required, required this.historyNotifier});
  final HistoryChangeNotifier historyNotifier;
  @override
  createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // late List<History> _history;
  convertTime(DateTime time) {
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
  void initState() {
    final history = DatabaseService.db.historys
        .where()
        .sortByDateDesc()
        .limit(40)
        .findAllSync();
    widget.historyNotifier.update(history);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDot = useState(0);

    return ListenableBuilder(
        listenable: widget.historyNotifier,
        builder: (context, child) => CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 10,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: OverflowBox(
                      maxWidth: MediaQuery.of(context).size.width,
                      child: MoonCarousel(
                        gap: 32,
                        itemCount: 5,
                        itemExtent: MediaQuery.of(context).size.width - 32,
                        physics: const PageScrollPhysics(),
                        onIndexChanged: (int index) =>
                            selectedDot.value = index,
                        itemBuilder:
                            (BuildContext context, int itemIndex, int _) {
                          if (widget.historyNotifier.history.length <=
                              itemIndex) {
                            return const Center(
                              child: Text(
                                'No history',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: "HarmonyOS_Sans"),
                              ),
                            );
                          }
                          final item =
                              widget.historyNotifier.history[itemIndex];
                          final extensionIsExist =
                              ExtensionUtils.runtimes.containsKey(item.package);
                          return GestureDetector(
                              onTap: () {
                                if (extensionIsExist) {
                                  context.go('/search/detail',
                                      extra: DetailParam(
                                          service: ExtensionUtils
                                              .runtimes[item.package]!,
                                          url: item.url));
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: context.moonTheme?.textInputTheme
                                          .colors.textColor
                                          .withAlpha(20),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(children: [
                                    ExtendedImage.network(
                                      shape: BoxShape.rectangle,
                                      fit: BoxFit.fitHeight,
                                      item.cover ?? '',
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                              left: Radius.circular(20),
                                              right: Radius.circular(10)),
                                    ),
                                    const SizedBox(width: 15),
                                    DefaultTextStyle(
                                        style: TextStyle(
                                          color: context.moonTheme?.chipTheme
                                              .colors.textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        child: SizedBox(
                                            width:
                                                DeviceUtil.getWidth(context) -
                                                    200,
                                            child: Flex(
                                              direction: Axis.vertical,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 10),
                                                Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      item.title,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontFamily:
                                                              "HarmonyOS_Sans"),
                                                    )),
                                                const Expanded(
                                                    flex: 1,
                                                    child:
                                                        SizedBox(height: 10)),
                                                Text(item.episodeTitle,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        fontFamily:
                                                            "HarmonyOS_Sans")),
                                                const SizedBox(height: 10),
                                                SizedBox(
                                                  height: 20,
                                                  child: Row(
                                                    children: [
                                                      ExtendedImage.network(
                                                        loadStateChanged:
                                                            (state) {
                                                          if (state
                                                                  .extendedImageLoadState ==
                                                              LoadState
                                                                  .failed) {
                                                            return const Icon(
                                                                Icons.error);
                                                          }
                                                          return null;
                                                        },
                                                        cache: true,
                                                        extensionIsExist
                                                            ? ExtensionUtils
                                                                    .runtimes[item
                                                                        .package]!
                                                                    .extension
                                                                    .icon ??
                                                                ''
                                                            : '',
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        extensionIsExist
                                                            ? ExtensionUtils
                                                                .runtimes[item
                                                                    .package]!
                                                                .extension
                                                                .name
                                                            : 'Unknown',
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                "HarmonyOS_Sans"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      convertTime(item.date),
                                                    )),
                                              ],
                                            )))
                                  ])));
                        },
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    sliver: SliverToBoxAdapter(
                      child: MoonDotIndicator(
                        selectedDot: selectedDot.value,
                        dotCount: 5,
                      ),
                    )),
                // LayoutBuilder(
                //   builder: (context, constraints) => MiruGridView.silver(
                //       mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //         crossAxisCount: constraints.maxWidth ~/ 110,
                //         childAspectRatio: 0.6,
                //       ),
                //       desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //         crossAxisCount: constraints.maxWidth ~/ 110,
                //         childAspectRatio: 0.6,
                //       ),
                //       itemBuilder: (context, index) {
                //         final item = history[index];
                //         return MiruGridTile(
                //           title: item.title,
                //           subtitle: item.date.toString(),
                //           imageUrl: item.cover,
                //           onTap: () {
                //             // Handle item tap
                //           },
                //         );
                //       },
                //       itemCount: history.length),
                // ),
                SliverPadding(
                  padding: const EdgeInsets.all(15.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: DeviceUtil.getWidth(context) ~/ 110,
                      childAspectRatio: 0.6,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = widget.historyNotifier.history[index];
                        return MiruGridTile(
                          title: item.title,
                          subtitle: item.episodeTitle,
                          imageUrl: item.cover,
                          onTap: () {
                            final extensionIsExist = ExtensionUtils.runtimes
                                .containsKey(item.package);
                            if (extensionIsExist) {
                              context.go('/search/detail',
                                  extra: DetailParam(
                                      service: ExtensionUtils
                                          .runtimes[item.package]!,
                                      url: item.url));
                            }
                          },
                        );
                      },
                      childCount: widget.historyNotifier.history.length,
                    ),
                  ),
                ),
              ],
            ));
  }
}

class HistoryChangeNotifier with ChangeNotifier {
  List<History> history = [];

  void update(List<History> updateValue) {
    history = updateValue;
    notifyListeners();
  }
}

class HomePage extends StatefulHookWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _categories = ['歷史', '收藏夹'];
  static final List<DateTime?> _times = [
    null,
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().subtract(const Duration(days: 30)),
  ];
  static const List<ExtensionType?> _types = [
    null,
    ExtensionType.bangumi,
    ExtensionType.manga,
    ExtensionType.fikushon,
  ];
  int _selectedTime = 0;
  int _selectedType = 0;
  List<History> filterByDateAndCategory(DateTime? date, ExtensionType? type) {
    if (date == null && type == null) {
      return DatabaseService.db.historys
          .where()
          .sortByDateDesc()
          .limit(40)
          .findAllSync();
    }
    if (date != null && type != null) {
      return DatabaseService.db.historys
          .filter()
          .dateLessThan(date)
          .typeEqualTo(type)
          .findAllSync();
    }
    if (date == null) {
      return DatabaseService.db.historys
          .filter()
          .typeEqualTo(type!)
          .findAllSync();
    }
    return DatabaseService.db.historys
        .filter()
        .dateLessThan(date)
        .findAllSync();
  }

  final historyNotifier = HistoryChangeNotifier();
  @override
  Widget build(BuildContext context) {
    final controler = useTabController(initialLength: _categories.length);
    return MiruScaffold(
      // appBar: const MiruAppBar(
      //   // title: Text('Home'),
      // ),
      sidebar: (DeviceUtil.getWidth(context) < 800)
          //mobile
          ? <Widget>[
              const SideBarListTitle(title: '主页'),
              const SideBarSearchBar(),
              const SizedBox(height: 10),
              MoonTabBar(
                tabController: controler,
                tabs: List.generate(
                  _categories.length,
                  (index) => MoonTab(
                    label: Text(_categories[index]),
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              SizedBox(
                  height: 300,
                  child: TabBarView(controller: controler, children: <Widget>[
                    DefaultTextStyle(
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "HarmonyOS_Sans"),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'Time',
                              ),
                              CatergoryGroupChip(
                                  maxSelected: 1,
                                  minSelected: 1,
                                  items: const [
                                    'All',
                                    '1 day',
                                    '1 week',
                                    '1 month'
                                  ],
                                  onpress: (val) {
                                    _selectedTime = val[0];
                                    final history = filterByDateAndCategory(
                                        _times[_selectedTime],
                                        _types[_selectedType]);
                                    debugPrint(history.toString());
                                    historyNotifier.update(history);
                                  },
                                  intitSelected: const [0]),
                              const SizedBox(height: 10),
                              const Text('Category'),
                              CatergoryGroupChip(
                                  maxSelected: 1,
                                  minSelected: 1,
                                  items: const [
                                    'All',
                                    'Video',
                                    'Comic',
                                    'Novel'
                                  ],
                                  onpress: (val) {
                                    _selectedType = val[0];
                                    final history = filterByDateAndCategory(
                                        _times[_selectedTime],
                                        _types[_selectedType]);
                                    debugPrint(history.toString());
                                    historyNotifier.update(history);
                                  },
                                  intitSelected: const [0]),
                            ])),
                    CatergoryGroupChip(
                        items: const ['全部'],
                        onpress: (val) {},
                        intitSelected: const [1])
                  ])),
            ]
          : <Widget>[
              const SideBarListTitle(title: '主页'),
              const SideBarSearchBar(),
              const SizedBox(height: 10),
              SidebarExpander(
                title: "歷史",
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false, items: const ['全部'], onpress: (val) {}),
              ),
              SidebarExpander(
                title: "分类",
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false,
                    items: const ['全部', '影視', '漫畫', '小說'],
                    onpress: (val) {}),
              ),
              const SizedBox(height: 10),
              SidebarExpander(
                title: '收藏夹',
                actions: [
                  Button(
                    onPressed: () {},
                    child: const Icon(
                      Icons.add,
                      size: 15,
                    ),
                  ),
                ],
                expanded: true,
                child: CategoryGroup(
                    needSpacer: false, items: const ['全部'], onpress: (val) {}),
              ),
            ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return TabBarView(controller: controler, children: <Widget>[
            HistoryPage(historyNotifier: historyNotifier),
            // MiruGridView(
            //   desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: constraints.maxWidth ~/ 150,
            //     childAspectRatio: 0.6,
            //   ),
            //   mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: constraints.maxWidth ~/ 110,
            //     childAspectRatio: 0.6,
            //   ),
            //   itemBuilder: (context, index) {
            //     return Container();
            //     // return MiruGridTile(
            //     //   title: 'Title $index',
            //     //   subtitle: 'Subtitle $index',
            //     //   imageUrl: 'https://picsum.photos/200/300?random=$index',
            //     //   onTap: () {
            //     //     Get.to(() => const DetailPage(), id: 1, popGesture: false);
            //     //   },
            //     // );
            //   },
            //   itemCount: 20,
            // ),
            Container(),
            // Container()
          ]);
        },
      ),
    );
  }
}
